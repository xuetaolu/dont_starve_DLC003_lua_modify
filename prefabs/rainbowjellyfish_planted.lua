local assets=
{
	Asset("ANIM", "anim/rainbowjellyfish.zip"),
}

local prefabs=
{
	"rainbowjellyfish_dead",
}

local INTENSITY = 0.65

local function swapColor(inst, light)
	if inst.ispink then
		inst.ispink = false
		inst.isgreen = true
		inst.components.lighttweener:StartTween(light, nil, nil, nil, {0/255, 180/255, 255/255}, 4, swapColor)
	elseif inst.isgreen then
		inst.isgreen = false
		inst.components.lighttweener:StartTween(light, nil, nil, nil, {240/255, 230/255, 100/255}, 4, swapColor)
	else
		inst.ispink = true
		inst.components.lighttweener:StartTween(light, nil, nil, nil, {251/255, 30/255, 30/255}, 4, swapColor)
	end
end

local function turnon(inst)
	
	if inst.Light and not inst.hidden then	
		inst.Light:Enable(true)
		local secs = 1+math.random()
		inst.components.lighttweener:StartTween(inst.Light, 0, nil, nil, nil, 0)
		inst.components.lighttweener:StartTween(inst.Light, INTENSITY, nil, nil, nil, secs, swapColor)		
	end
end


local function turnoff(inst)
	if inst.Light then
		inst.Light:Enable(false)
	end
end


local function fadein(inst)
	inst.hidden = false
	inst.AnimState:PlayAnimation("idle")
	inst:Show()
	inst:RemoveTag("NOCLICK")	
end

local function fadeout(inst)	
	inst.hidden = true
	inst:AddTag("NOCLICK")
	inst:Hide()
end


local function onwake(inst)
	if not GetClock():IsDay() then
		fadein(inst)
		turnon(inst)		
	else
		turnoff(inst)
	end
end

local function onsleep(inst)
	if GetClock():IsDay() then
		fadeout(inst)
		turnoff(inst)
	end
end




local function OnWorked(inst, worker)
    if worker.components.inventory then
        local toGive = SpawnPrefab("rainbowjellyfish")
        worker.components.inventory:GiveItem(toGive, nil, Vector3(TheSim:GetScreenPos(inst.Transform:GetWorldPosition())))
        worker.SoundEmitter:PlaySound("dontstarve_DLC002/common/bugnet_inwater")
		inst.Light:Enable(false)
    end
    inst:Remove()
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.no_wet_prefix = true	

    inst:AddTag("aquatic")
	inst:AddTag("rainbowjellyfish")
	inst.entity:AddTransform()
	inst.Transform:SetScale(0.8, 0.8, 0.8)
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    local physics = inst.entity:AddPhysics()
    MakeCharacterPhysics(inst, 1, 0.5)
    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("rainbowjellyfish")
    inst.AnimState:SetBuild("rainbowjellyfish")
    inst.AnimState:PlayAnimation("idle", true)

	-- locomotor must be constructed before the stategraph
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.RAINBOWJELLYFISH_WALKSPEED

    inst:SetStateGraph("SGrainbowjellyfish")
    --inst.AnimState:SetRayTestOnBB(true);
    inst.AnimState:SetLayer( LAYER_BACKGROUND )
    inst.AnimState:SetSortOrder( 3 )

	local brain = require "brains/rainbowjellyfishbrain"
    inst:SetBrain(brain)

    inst:AddComponent("combat")
    inst.components.combat:SetHurtSound("dontstarve_DLC002/creatures/jellyfish/hit")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.JELLYFISH_HEALTH)

    MakeMediumFreezableCharacter(inst, "jelly")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"rainbowjellyfish_dead"})

    inst:AddComponent("inspectable")
    inst:AddComponent("knownlocations")
    inst:AddComponent("sleeper")
    inst.components.sleeper.onlysleepsfromitems = true

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.NET)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(OnWorked)

	-- light emitting
	inst.OnEntityWake = onwake
	inst.OnEntitySleep = onsleep

	inst:AddComponent("fader")

	inst:AddComponent("lighttweener")
	local light = inst.entity:AddLight()
	inst.Light:SetColour(251/255, 30/255, 30/255)
	inst.Light:Enable(false)
	inst.Light:SetIntensity(0.65)
	inst.Light:SetRadius(1.5)
	inst.Light:SetFalloff(.45)


    inst:ListenForEvent("daytime", function()   inst:DoTaskInTime(2, function()  turnoff(inst) end) end, GetWorld())
    inst:ListenForEvent("dusktime", function() turnon(inst) end, GetWorld())

	inst.ispink = true
	inst.components.lighttweener:StartTween(light, nil, nil, nil, {0/255, 180/255, 255/255}, 4, swapColor)

    return inst
end

return Prefab( "common/inventory/rainbowjellyfish_planted", fn, assets, prefabs)
