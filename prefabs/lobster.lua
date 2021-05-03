require "stategraphs/SGrabbit"

local assets=
{
	Asset("ANIM", "anim/lobster_build.zip"),
	Asset("ANIM", "anim/lobster_build_color.zip"),
	Asset("ANIM", "anim/lobster.zip"),
	Asset("SOUND", "sound/rabbit.fsb"),
}

local prefabs =
{
	"smallmeat",
	"cookedsmallmeat",
	"lobster_dead",
}

local brain = require "brains/lobsterbrain"

local function StartDay(inst)
	if inst:IsAsleep() and inst.components.homeseeker then
		inst.components.homeseeker:ForceGoHome()
	end
end

local function GetCookProductFn(inst)
	return "lobster_dead_cooked"
end

local function OnCookedFn(inst)
	inst.SoundEmitter:PlaySound("dontstarve/rabbit/scream_short")
end

local function OnAttacked(inst, data)
	local x,y,z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x,y,z, 30, {'lobster'})
	
	local num_friends = 0
	local maxnum = 5
	for k,v in pairs(ents) do
		v:PushEvent("gohome")
		num_friends = num_friends + 1
		
		if num_friends > maxnum then
			break
		end
	end
end

local function canbeattackedfn(inst)
	local onwater = inst:GetIsOnWater()
	--Can't be attacked if under water.
	return not onwater
end

local function onpickup(inst)
	inst.components.timer:StopTimer("dryout")
end

local function onhitground(inst, onwater)
	if onwater then
		inst:AddTag("aquatic")
		inst:AddTag("fireimmune")
	else
		inst:RemoveTag("aquatic")
		inst:RemoveTag("fireimmune")
	end
end

local function ondrop(inst)
	local onwater = inst:GetIsOnWater()

	--See where it is dropped
	--Start "death" logic if dropped on ground
	--Release if dropped in water.

	if not onwater then
	    inst.AnimState:SetMultColour(1, 1, 1, 1)
		inst.AnimState:SetBuild("lobster_build_color")
		inst.sg:GoToState("stunned")
		inst.components.timer:StartTimer("dryout", 15)
		inst:RemoveTag("fireimmune")
	else
		--Play splash
		SpawnPrefab("splash_water_drop").Transform:SetPosition(inst:GetPosition():Get())
	    inst.AnimState:SetMultColour(1, 1, 1, .30)
		inst.AnimState:SetBuild("lobster_build")
		inst.sg:GoToState("idle")
		inst:AddTag("fireimmune")
	end
end

local function ontimerdone(inst, data)
	if data.name and data.name == "dryout" then
		inst.components.health:Kill()
	end
end

local function onload(inst)
	if inst:GetIsOnWater() then
		inst:AddTag("aquatic")
		inst:AddTag("fireimmune")
	end
end

local function ShouldSleep(inst)
	return DefaultSleepTest(inst) and inst:GetIsOnWater()
end

local function ShouldWake(inst)
	return DefaultWakeTest(inst) or not inst:GetIsOnWater()
end

local function onsleep(inst)
	if not inst:GetIsOnWater() then
		inst.components.health:Kill()
	end
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local physics = inst.entity:AddPhysics()
	local sound = inst.entity:AddSoundEmitter()
	inst.Transform:SetFourFaced()

	MakeUnderwaterCharacterPhysics(inst, 1, 0.5)
	MakePoisonableCharacter(inst)
	
	inst:AddTag("animal")
	inst:AddTag("prey")
	inst:AddTag("smallcreature")
	inst:AddTag("canbetrapped")
	inst:AddTag("packimfood")
	inst:AddTag("fireimmune")

	anim:SetBank("lobster")
	anim:SetBuild("lobster_build")
	anim:PlayAnimation("idle")
	anim:SetLayer(LAYER_BACKGROUND)
	anim:SetSortOrder(3)
	
    inst.AnimState:SetMultColour(1, 1, 1, .30)

	inst:AddComponent("locomotor")
	inst.components.locomotor.walkspeed = TUNING.LOBSTER_WALK_SPEED
	inst.components.locomotor.runspeed = TUNING.LOBSTER_RUN_SPEED
	
	inst:AddComponent("eater")
	inst.components.eater:SetCarnivore()

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.nobounce = true
	inst.components.inventoryitem.canbepickedup = false
	inst.components.inventoryitem.nosink = true
	inst.components.inventoryitem:SetOnPickupFn(onpickup)
	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
    inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD

	inst:AddComponent("cookable")
	inst.components.cookable.product = GetCookProductFn
	inst.components.cookable:SetOnCookedFn(OnCookedFn)
	
	inst:AddComponent("knownlocations")

	inst:AddComponent("combat")
	inst.components.combat.hiteffectsymbol = "chest"
	inst.components.combat.canbeattackedfn = canbeattackedfn

	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(TUNING.LOBSTER_HEALTH)
	inst.components.health.murdersound = "dontstarve_DLC002/creatures/lobster/death"
	
	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot({"lobster_dead"})
	inst.components.lootdropper.nojump = true
	
	inst:AddComponent("inspectable")

	inst:AddComponent("sleeper")
	inst.components.sleeper:SetNocturnal(true)
    inst.components.sleeper:SetWakeTest(ShouldWake)
    inst.components.sleeper:SetSleepTest(ShouldSleep)

	inst:AddComponent("appeasement")
	inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_MEDIUM
	
	inst:AddComponent("timer")
	inst:ListenForEvent("timerdone", ontimerdone)

	MakeFeedablePet(inst, TUNING.TOTAL_DAY_TIME*2, nil, ondrop)
	MakeSmallBurnableCharacter(inst, "chest")
	MakeTinyFreezableCharacter(inst, "chest")

	inst.no_wet_prefix = true
	inst:ListenForEvent("onhitground", onhitground)
	inst:ListenForEvent("attacked", OnAttacked)
	inst:SetStateGraph("SGlobster")
	inst:SetBrain(brain)
	inst.OnLoad = onload

	inst:ListenForEvent( "daytime", function() StartDay( inst ) end, GetWorld())
	inst:ListenForEvent("gotosleep", onsleep)

	return inst
end

return Prefab("forest/animals/lobster", fn, assets, prefabs)
