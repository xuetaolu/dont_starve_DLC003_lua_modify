local assets=
{
	Asset("ANIM", "anim/bush_vine.zip"),
	Asset("MINIMAP_IMAGE", "bushVine"),
}


local prefabs =
{
    "vine",
    "dug_bush_vine",
    "hacking_fx",
}

local function ontransplantfn(inst)
	if inst.components.hackable then
		inst.components.hackable:MakeBarren()
	end
end

local function dig_up(inst, chopper)
	if inst.components.hackable and inst.components.hackable:CanBeHacked() then
		inst.components.lootdropper:SpawnLootPrefab("vine")
	end
	if inst.components.hackable and not inst.components.hackable.withered then
		local bush = inst.components.lootdropper:SpawnLootPrefab("dug_bush_vine")
	else
		inst.components.lootdropper:SpawnLootPrefab("vine")
	end
	inst:Remove()
end

local function onregenfn(inst)
	inst.AnimState:PlayAnimation("grow")
	inst.AnimState:PushAnimation("idle", true)
	inst.Physics:SetCollides(true)
end

local function makeemptyfn(inst)
	if inst.components.hackable and inst.components.hackable.withered then
		inst.AnimState:PlayAnimation("dead_to_empty")
		inst.AnimState:PushAnimation("hacked_idle")
	else
		inst.AnimState:PlayAnimation("hacked_idle")
	end
	inst.Physics:SetCollides(false)
end

local function makebarrenfn(inst)
	if inst.components.hackable and inst.components.hackable.withered then
		if not inst.components.hackable.hasbeenhacked then
			inst.AnimState:PlayAnimation("full_to_dead")
		else
			inst.AnimState:PlayAnimation("empty_to_dead")
		end
		inst.AnimState:PushAnimation("idle_dead")
	else
		inst.AnimState:PlayAnimation("idle_dead")
	end
	inst.Physics:SetCollides(true)
end


local function onhackedfn(inst, hacker, hacksleft)
	local fx = SpawnPrefab("hacking_fx")
    local x, y, z= inst.Transform:GetWorldPosition()
    fx.Transform:SetPosition(x,y + math.random()*2,z)

	if(hacksleft <= 0) then

		inst.AnimState:PlayAnimation("disappear")

		if inst.components.hackable and inst.components.hackable:IsBarren() then
			inst.AnimState:PushAnimation("idle_dead")
			inst.Physics:SetCollides(true)
		else
			inst.Physics:SetCollides(false)
			inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/vine_drop")
			inst.AnimState:PushAnimation("hacked_idle")
		end
	else
		inst.AnimState:PlayAnimation("chop")
		inst.AnimState:PushAnimation("idle")
	end

	inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/vine_hack")
end

local function inspect_vine(inst)
    if inst:HasTag("burnt") then
        return "BURNT"
    elseif inst:HasTag("stump") then
        return "CHOPPED"
    end
end

local function makefn(stage)
	local function fn(Sim)
		local inst = CreateEntity()
		local trans = inst.entity:AddTransform()
		local anim = inst.entity:AddAnimState()
	    local sound = inst.entity:AddSoundEmitter()
		local minimap = inst.entity:AddMiniMapEntity()

		minimap:SetIcon( "bushVine.png" )

	    anim:SetBank("bush_vine")
	    anim:SetBuild("bush_vine")
	    anim:PlayAnimation("idle",true)
	    anim:SetTime(math.random()*2)
	    local color = 0.75 + math.random() * 0.25
	    anim:SetMultColour(color, color, color, 1)

	    inst:AddTag("vine")
	    inst:AddTag("plant")

		inst:AddComponent("hackable")
		inst.components.hackable:SetUp("vine", TUNING.VINE_REGROW_TIME)
		inst.components.hackable.onregenfn = onregenfn
		inst.components.hackable.onhackedfn = onhackedfn
		inst.components.hackable.makeemptyfn = makeemptyfn
		inst.components.hackable.makebarrenfn = makebarrenfn
		inst.components.hackable.max_cycles = 20
		inst.components.hackable.cycles_left = 20
		inst.components.hackable.ontransplantfn = ontransplantfn
		inst.components.hackable.hacksleft = TUNING.VINE_HACKS
		inst.components.hackable.maxhacks = TUNING.VINE_HACKS

		local variance = math.random() * 4 - 2
		inst.makewitherabletask = inst:DoTaskInTime(TUNING.WITHER_BUFFER_TIME + variance, function(inst) inst.components.hackable:MakeWitherable() end)

	    if stage == 1 then
			inst.components.hackable:MakeBarren()
		end

		inst:AddComponent("lootdropper")
	    inst:AddComponent("inspectable")
	    inst.components.inspectable.getstatus = inspect_vine

		inst:AddComponent("workable")
	    inst.components.workable:SetWorkAction(ACTIONS.DIG)
	    inst.components.workable:SetOnFinishCallback(dig_up)
	    inst.components.workable:SetWorkLeft(1)

	    MakeHackableBlowInWindGust(inst, TUNING.VINE_WINDBLOWN_SPEED, TUNING.VINE_WINDBLOWN_FALL_CHANCE)

	    ---------------------

	    MakeMediumBurnable(inst)
	    MakeSmallPropagator(inst)
	    inst.components.burnable:MakeDragonflyBait(1)
	    MakeObstaclePhysics(inst, .35)

		--MakeNoGrowInWinter(inst)

	    ---------------------

	    return inst
	end

    return fn
end


local function vine(name, stage)
	return Prefab("forest/objects/"..name, makefn(stage), assets, prefabs)
end

return vine("bush_vine", 0),
	   vine("depleted_bush_vine", 1)
