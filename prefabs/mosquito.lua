require("brains/mosquitobrain")
require "stategraphs/SGmosquito"

local assets=
{
	Asset("ANIM", "anim/mosquito.zip"),
	Asset("ANIM", "anim/mosquito_build.zip"),
	Asset("ANIM", "anim/mosquito_yellow_build.zip"),
	Asset("INV_IMAGE", "mosquito_yellow"),
}

local prefabs = 
{
	"mosquitosack",
	"mosquitosack_yellow",
}

local sounds =
{
	takeoff = "dontstarve/creatures/mosquito/mosquito_takeoff",
	attack = "dontstarve/creatures/mosquito/mosquito_attack",
	buzz = "dontstarve/creatures/mosquito/mosquito_fly_LP",
	hit = "dontstarve/creatures/mosquito/mosquito_hurt",
	death = "dontstarve/creatures/mosquito/mosquito_death",
	explode = "dontstarve/creatures/mosquito/mosquito_explo",
}

SetSharedLootTable( 'mosquito',
{
	{'mosquitosack', .5},
})

SetSharedLootTable( 'poisonmosquito',
{
	{'mosquitosack_yellow', .5},
	{'venomgland', .25},
})

local SHARE_TARGET_DIST = 30
local MAX_TARGET_SHARES = 10



local function StopTrackingInSpawner(inst)
	local ground = GetWorld()
	if ground and ground.components.mosquitospawner then
		ground.components.mosquitospawner:StopTracking(inst)
	end
end


local function OnWorked(inst, worker)
	local owner = inst.components.homeseeker and inst.components.homeseeker.home
	if owner and owner.components.childspawner then
		owner.components.childspawner:OnChildKilled(inst)
	end
	StopTrackingInSpawner(inst)
	if METRICS_ENABLED and worker.components.inventory then
		FightStat_Caught(inst)
		worker.components.inventory:GiveItem(inst, nil, Vector3(TheSim:GetScreenPos(inst.Transform:GetWorldPosition())))
	end
end

local function OnWake(inst)
	if not inst.components.inventoryitem:IsHeld() then
		inst.SoundEmitter:PlaySound(inst.sounds.buzz, "buzz")
	end
	if inst.components.tiletracker then
		inst.components.tiletracker:Start()
	end
end

local function OnSleep(inst)
	inst.SoundEmitter:KillSound("buzz")
	if inst.components.tiletracker then
		inst.components.tiletracker:Stop()
	end
end

local function OnDropped(inst)
	inst.sg:GoToState("idle")
	if inst.components.workable then
		inst.components.workable:SetWorkLeft(1)
	end
	if inst.brain then
		inst.brain:Start()
	end
	if inst.sg then
		inst.sg:Start()
	end
	if inst.components.stackable then
		while inst.components.stackable:StackSize() > 1 do
			local item = inst.components.stackable:Get()
			if item then
				if item.components.inventoryitem then
					item.components.inventoryitem:OnDropped()
				end
				item.Physics:Teleport(inst.Transform:GetWorldPosition() )
			end
		end
	end
end

local function OnPickedUp(inst)
	inst.SoundEmitter:KillSound("buzz")
end

local function KillerRetarget(inst)
	local range = 20
	if GetSeasonManager() and (GetSeasonManager():IsSpring() or GetSeasonManager():IsGreenSeason()) then
		range = range * TUNING.SPRING_COMBAT_MOD
	end
	local notags = {"FX", "NOCLICK","INLIMBO", "insect"}
	local yestags = {"character", "animal", "monster"}
	return FindEntity(inst, range, function(guy)
		return inst.components.combat:CanTarget(guy)
	end, nil, notags, yestags)
end

local function SwapBelly(inst, size)
	for i=1,4 do
		if i == size then
			inst.AnimState:Show("body_"..tostring(i))
		else
			inst.AnimState:Hide("body_"..tostring(i))
		end
	end
end

local function TakeDrink(inst, data)
	inst.drinks = inst.drinks + 1
	if inst.drinks > inst.maxdrinks then
		inst.toofat = true
		inst.components.health:Kill()
	else
		SwapBelly(inst, inst.drinks)
	end
end

local function OnAttacked(inst, data)
	inst.components.combat:SetTarget(data.attacker)
	local shareRange = SHARE_TARGET_DIST
	if GetSeasonManager() and (GetSeasonManager():IsSpring() or GetSeasonManager():IsGreenSeason()) then
		shareRange = shareRange * TUNING.SPRING_COMBAT_MOD
	end
	inst.components.combat:ShareTarget(data.attacker, shareRange, function(dude) return dude:HasTag("mosquito") and not dude.components.health:IsDead() end, MAX_TARGET_SHARES)
end


local function OnWaterChange(inst, onwater)
	if onwater then
		inst.onwater = true
	else
		inst.onwater = false		
	end
end



local function commonfn(Sim)
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddLightWatcher()
	inst.entity:AddDynamicShadow()
	inst.DynamicShadow:SetSize( .8, .5 )
	inst.Transform:SetFourFaced()

	inst:SetBrain(require("brains/mosquitobrain"))

	----------

	inst:AddTag("mosquito")
	inst:AddTag("animal")
	inst:AddTag("insect")
	inst:AddTag("flying")
	inst:AddTag("smallcreature")

	MakeAmphibiousCharacterPhysics(inst, 1, .5)
	inst.Physics:SetCollisionGroup(COLLISION.FLYERS)
	inst.Physics:CollidesWith(COLLISION.FLYERS)	
	
	inst.AnimState:SetBank("mosquito")
	inst.AnimState:SetBuild("mosquito_build")
	inst.AnimState:PlayAnimation("idle")
	inst.AnimState:SetRayTestOnBB(true)

	inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
	inst.components.locomotor:EnableGroundSpeedMultiplier(false)
	inst.components.locomotor:SetTriggersCreep(false)
	inst.components.locomotor.walkspeed = TUNING.MOSQUITO_WALKSPEED
	inst.components.locomotor.runspeed = TUNING.MOSQUITO_RUNSPEED
	inst:SetStateGraph("SGmosquito")

	inst.sounds = sounds

	inst.OnEntityWake = OnWake
	inst.OnEntitySleep = OnSleep    

	inst:AddComponent("tiletracker")
	inst.components.tiletracker:SetOnWaterChangeFn(OnWaterChange)


	inst:AddComponent("inventoryitem")
	inst:AddComponent("stackable")
	--inst.components.inventoryitem:SetOnDroppedFn(OnDropped) Done in MakeFeedablePet
	--inst.components.inventoryitem:SetOnPutInInventoryFn(OnPickedUp)
	inst.components.inventoryitem.canbepickedup = false

	---------------------

	inst:AddComponent("lootdropper")

	inst:AddComponent("tradable")
	inst:AddTag("cattoyairborne")

	 ------------------
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.NET)
	inst.components.workable:SetWorkLeft(1)
	inst.components.workable:SetOnFinishCallback(OnWorked)

	MakeSmallBurnableCharacter(inst, "body", Vector3(0, -1, 1))
	MakeTinyFreezableCharacter(inst, "body", Vector3(0, -1, 1))

	------------------
	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(TUNING.MOSQUITO_HEALTH)

	------------------
	inst:AddComponent("combat")
	inst.components.combat.hiteffectsymbol = "body"
	inst.components.combat:SetDefaultDamage(TUNING.MOSQUITO_DAMAGE)
	inst.components.combat:SetAttackPeriod(TUNING.MOSQUITO_ATTACK_PERIOD)
	inst.components.combat:SetRetargetFunction(2, KillerRetarget)

	inst.drinks = 1
	inst.maxdrinks = TUNING.MOSQUITO_MAX_DRINKS
	inst:ListenForEvent("onattackother", TakeDrink)
	SwapBelly(inst, 1)

	------------------
	inst:AddComponent("sleeper")

	------------------
	inst:AddComponent("knownlocations")

	------------------
	inst:AddComponent("inspectable")

	inst:ListenForEvent("attacked", OnAttacked)

	MakeFeedablePet(inst, TUNING.TOTAL_DAY_TIME*2, OnPickedUp, OnDropped)

	return inst
end

local function mosquitofn(sim)
	local inst = commonfn(sim)
	MakePoisonableCharacter(inst)
	inst.components.lootdropper:SetChanceLootTable('mosquito')	
	return inst 
end 

local function poisonfn(Sim)
	local inst = commonfn(Sim)

	inst.AnimState:SetBank("mosquito")
	inst.AnimState:SetBuild("mosquito_yellow_build")
	inst.components.combat.poisonous = true
	inst.components.inventoryitem.imagename = "mosquito_yellow"
	inst.components.lootdropper:SetChanceLootTable('poisonmosquito')	

	local s = 1.18
	inst.Transform:SetScale(s,s,s)

	inst:ListenForEvent("onremove", StopTrackingInSpawner)
	
	return inst
end

return Prefab( "forest/monsters/mosquito", mosquitofn, assets, prefabs),
	   Prefab( "forest/monsters/mosquito_poison", poisonfn, assets, prefabs)
