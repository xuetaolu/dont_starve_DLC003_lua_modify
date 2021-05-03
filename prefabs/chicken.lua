require "stategraphs/SGchicken"

local INTENSITY = .5

local assets =
{
	Asset("ANIM", "anim/chicken.zip"),
	Asset("SOUND", "sound/rabbit.fsb"),
}

local prefabs =
{
	"smallmeat",
	"cookedsmallmeat",
}

local chickensounds = 
{
	scream = "dontstarve_DLC003/creatures/piko/scream",
	hurt = "dontstarve_DLC003/creatures/piko/scream",
}

local brain = require "brains/chickenbrain"

local function OnWake(inst)
	-- TODO: Decide what happens when a chicken wakes.
end

local function OnSleep(inst)
	if inst.checktask then
		inst.checktask:Cancel()
		inst.checktask = nil
	end
end

local function GetCookableProduct(inst)
	return "drumstick_cooked" 
end

local function OnCooked(inst)
	inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/piko/scream")
end

-- TODO: Change this function so that the chicken runs away.
local function OnAttacked(inst, data)
	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, 30, {'chicken'})

	local num_friends = 0
	local maxnum = 5
	for k, v in pairs(ents) do
		num_friends = num_friends + 1

		if num_friends > maxnum then
			break
		end
	end
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local physics = inst.entity:AddPhysics()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()

	shadow:SetSize(1, 0.75)
	
	inst.Transform:SetFourFaced()

	MakeCharacterPhysics(inst, 1, 0.12)
	MakePoisonableCharacter(inst)	

	anim:SetBank("chicken")
	anim:SetBuild("chicken")
	anim:PlayAnimation("idle", true)

	inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
	inst.components.locomotor.runspeed = TUNING.CHICKEN_RUN_SPEED

	inst:SetStateGraph("SGchicken")

	inst:AddTag("animal")
	inst:AddTag("prey")
	inst:AddTag("chicken")
	inst:AddTag("smallcreature")
	inst:AddTag("canbetrapped")

	inst:SetBrain(brain)

	inst.data = {}

	inst:AddComponent("eater")
	inst.components.eater:SetBird()

	inst.force_onwenthome_message = true
	inst:AddComponent("sanityaura")

	inst:AddComponent("cookable")
	inst.components.cookable.product = GetCookableProduct
	inst.components.cookable:SetOnCookedFn(OnCooked)

	inst:AddComponent("knownlocations")

	inst:AddComponent("combat")
	inst.components.combat.hiteffectsymbol = "chest"

	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(TUNING.CHICKEN_HEALTH)
	inst.components.health.murdersound = "dontstarve/rabbit/scream_short"
	
	MakeSmallBurnableCharacter(inst, "chest")
	MakeTinyFreezableCharacter(inst, "chest")

	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot({"drumstick"})

	inst:AddComponent("inspectable")
	inst:AddComponent("sleeper")

	inst.sounds = chickensounds

	inst.OnEntityWake = OnWake
	inst.OnEntitySleep = OnSleep   

	inst:ListenForEvent("attacked", OnAttacked)

	inst:DoPeriodicTask(10.0, function() inst.improvise = true end)

	return inst
end

return Prefab("forest/animals/chicken", fn, assets, prefabs)
