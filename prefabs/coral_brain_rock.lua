local assets =
{
	Asset("ANIM", "anim/brain_coral_rock.zip")
}

local prefabs =
{
	"coral_brain",
}

local CORALSTATE =
{
	FULL = "_full",
	PICKED = "_picked",
	GLOW = "_glow",
}

local min_rad = 2.5
local max_rad = 3
local min_falloff = 0.8
local max_falloff = 0.7
local min_intensity = 0.8
local max_intensity = 0.7

local function pulse_light(inst)
    local s = GetSineVal(0.05, true, inst)
    local rad = Lerp(min_rad, max_rad, s)
    local intentsity = Lerp(min_intensity, max_intensity, s)
    local falloff = Lerp(min_falloff, max_falloff, s)
    inst.Light:SetFalloff(falloff)
    inst.Light:SetIntensity(intentsity)
    inst.Light:SetRadius(rad)
end

local function turnon(inst, time)
    inst.Light:Enable(true)

    local s = GetSineVal(0.05, true, inst, time)
    local rad = Lerp(min_rad, max_rad, s)
    local intentsity = Lerp(min_intensity, max_intensity, s)
    local falloff = Lerp(min_falloff, max_falloff, s)

    local startpulse = function()
    	inst.light_pulse = inst:DoPeriodicTask(0.1, pulse_light)
	end

    inst.components.lighttweener:StartTween(inst.Light, rad, intentsity, falloff, nil, time, startpulse)
end

local function turnoff(inst, time)
	if inst.light_pulse then
		inst.light_pulse:Cancel()
		inst.light_pulse = nil
	end

	local lightoff = function() inst.Light:Enable(false) end

    inst.components.lighttweener:StartTween(inst.Light, 0, 0, nil, nil, time, lightoff)
end

local function onduskfn(inst)
	--Start Glow
	local picked = inst.coralstate == CORALSTATE.PICKED

	if not picked then
		turnon(inst, 5)
		inst.coralstate = CORALSTATE.GLOW
	    inst.AnimState:PlayAnimation("glow_pre")
    	inst.AnimState:PushAnimation("idle"..inst.coralstate, true)

	end
end

local function ondayfn(inst)
	--Stop Glow
	local picked = inst.coralstate == CORALSTATE.PICKED

	if not picked then
		turnoff(inst, 5)
		inst.coralstate = CORALSTATE.FULL
		inst.AnimState:PushAnimation("glow_pst", false)
		inst.AnimState:PushAnimation("idle"..inst.coralstate, true)
	end
end

local function getregentimefn(inst)
	if inst.components.pickable then
		return TUNING.CORAL_BRAIN_REGROW
	end
end

local function makefullfn(inst)
	inst.AnimState:PlayAnimation("regrow")
	inst.coralstate = CORALSTATE.FULL
	inst.AnimState:PushAnimation("idle"..inst.coralstate, true)
	--Check for dusk/ night, turn on.
	if GetClock():IsNight() or GetClock():IsDusk() then
		turnon(inst, 5)
		inst.coralstate = CORALSTATE.GLOW
	    inst.AnimState:PlayAnimation("glow_pre")
    	inst.AnimState:PushAnimation("idle"..inst.coralstate, true)
	end
end

local function onpickedfn(inst, picker)
	if inst.components.pickable then
		--turn off light.
		if inst.coralstate == CORALSTATE.GLOW then
			turnoff(inst, 1)
		end

		inst.AnimState:PlayAnimation("picked")
		inst.coralstate = CORALSTATE.PICKED
		inst.AnimState:PushAnimation("idle"..inst.coralstate, true)
	end
end

local function makeemptyfn(inst)
	inst.AnimState:PlayAnimation("idle_picked", true)
end

local function onhammered(inst, worker)
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.components.lootdropper:DropLoot()
	inst:Remove()
end

local function onhit(inst)
	inst.AnimState:PlayAnimation("hit"..inst.coralstate)
	inst.AnimState:PushAnimation("idle"..inst.coralstate, true)
end

local function sanityaurafn(inst, observer)
	if inst.coralstate == CORALSTATE.GLOW then
		return TUNING.SANITYAURA_SMALL
	else
		return 0
	end
end

local function onsave(inst, data)
	data.coralstate = inst.coralstate
end

local function onload(inst, data)
	inst.coralstate = data and data.coralstate or CORALSTATE.FULL

	if inst.coralstate == CORALSTATE.GLOW then
	    inst.AnimState:PlayAnimation("glow_pre")
    	inst.AnimState:PushAnimation("idle"..inst.coralstate, true)
		turnon(inst, 0)
	end
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddLight()
	inst.entity:AddMiniMapEntity()

	inst.MiniMapEntity:SetIcon("coral_brain_rock.png")

    inst.Light:SetColour(210/255, 247/255, 228/255)
    inst.Light:Enable(false)
    inst.Light:SetIntensity(0)
    inst.Light:SetFalloff(0.7)

	MakeObstaclePhysics(inst, 1)

	inst.AnimState:SetBank("brain_coral_rock")
	inst.AnimState:SetBuild("brain_coral_rock")
	inst.AnimState:PlayAnimation("idle_full", true)

	inst:AddComponent("inspectable")

	inst:AddComponent("lighttweener")

	inst:AddComponent("pickable")
	inst.components.pickable:SetUp("coral_brain", TUNING.CORAL_BRAIN_REGROW)
	inst.components.pickable.getregentimefn = getregentimefn
	inst.components.pickable.onpickedfn = onpickedfn
	inst.components.pickable.makeemptyfn = makeemptyfn
	inst.components.pickable.makefullfn = makefullfn
	inst.components.pickable.picksound = "dontstarve_DLC002/common/brain_coral_harvest"

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)

	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot({"limestone", "limestone"})

	inst:AddComponent("sanityaura")
	inst.components.sanityaura.aurafn = sanityaurafn

	inst.coralstate = CORALSTATE.FULL

	inst:ListenForEvent("dusktime", function() onduskfn(inst) end, GetWorld())
	inst:ListenForEvent("daytime", function() ondayfn(inst) end, GetWorld())

	inst.OnSave = onsave
	inst.OnLoad = onload

	return inst
end

return Prefab("coral_brain_rock", fn, assets, prefabs)