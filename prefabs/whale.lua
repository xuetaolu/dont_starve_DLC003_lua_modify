local bluebrain = require "brains/bluewhalebrain"
local whitebrain = require "brains/whitewhalebrain"
require "stategraphs/SGwhale"

local assets=
{
	Asset("ANIM", "anim/whale.zip"),
	Asset("ANIM", "anim/whale_blue_build.zip"),
	Asset("ANIM", "anim/whale_moby_build.zip"),
	Asset("SOUND", "sound/koalefant.fsb"),
}

local prefabs =
{
	"fish_med_cooked",
	"boneshard",
	"whale_carcass_blue",
	"whale_carcass_white",
	"whale_bubbles",
	"whale_track",
}

local bluesounds = 
{
	death = "dontstarve_DLC002/creatures/blue_whale/death",
	hit = "dontstarve_DLC002/creatures/blue_whale/hit",
	idle = "dontstarve_DLC002/creatures/blue_whale/idle",
	breach_swim = "dontstarve_DLC002/creatures/blue_whale/beach_swim",
	sleep = "dontstarve_DLC002/creatures/blue_whale/sleep",
	rear_attack = "dontstarve_DLC002/creatures/blue_whale/rear_attack",
	mouth_open = "dontstarve_DLC002/creatures/blue_whale/mouth_open",
	bite_chomp = "dontstarve_DLC002/creatures/blue_whale/bite_chomp",
	bite = "dontstarve_DLC002/creatures/blue_whale/bite",
}

local whitesounds = 
{
	death = "dontstarve_DLC002/creatures/white_whale/death",
	hit = "dontstarve_DLC002/creatures/white_whale/hit",
	idle = "dontstarve_DLC002/creatures/white_whale/idle",
	breach_swim = "dontstarve_DLC002/creatures/white_whale/breach_swim",
	sleep = "dontstarve_DLC002/creatures/white_whale/sleep",
	rear_attack = "dontstarve_DLC002/creatures/white_whale/rear_attack",
	mouth_open = "dontstarve_DLC002/creatures/white_whale/mouth_open",
	bite_chomp = "dontstarve_DLC002/creatures/white_whale/bite_chomp",
	bite = "dontstarve_DLC002/creatures/white_whale/bite",
}

local loot_blue = {"fish_med_cooked","fish_med_cooked","fish_med_cooked","fish_med_cooked","fish_med_cooked","fish_med_cooked","boneshard","boneshard","boneshard","boneshard"}
local loot_white = {"fish_med_cooked","fish_med_cooked","fish_med_cooked","fish_med_cooked","fish_med_cooked","fish_med_cooked","boneshard","boneshard","boneshard","boneshard"}


local WAKE_TO_RUN_DISTANCE = 10
local SLEEP_NEAR_ENEMY_DISTANCE = 14

local function ShouldWakeUp(inst)
	return DefaultWakeTest(inst) or inst:IsNear(GetPlayer(), WAKE_TO_RUN_DISTANCE)
end

local function ShouldSleep(inst)
	return DefaultSleepTest(inst) and not inst:IsNear(GetPlayer(), SLEEP_NEAR_ENEMY_DISTANCE)
end



local function OnAttacked(inst, data)
	inst.components.combat:SetTarget(data.attacker)
	inst.components.combat:ShareTarget(data.attacker, 30,function(dude)
		return dude:HasTag("whale") and not dude:HasTag("player") and not dude.components.health:IsDead()
	end, 5)
end

local function OnEntityWake(inst)
	inst.components.tiletracker:Start()
end

local function OnEntitySleep(inst)
	inst.components.tiletracker:Stop()
end

local function OnLoad(inst, data)
	if not data then
		return
	end
	
	inst.hitshallow = data.hitshallow
end

local function OnSave(inst, data)
	data.hitshallow = inst.hitshallow
end

local function create_base(sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	inst.Transform:SetFourFaced()

	MakePoisonableCharacter(inst)
	MakeCharacterPhysics(inst, 100, .75)

	inst:AddTag("whale")
	anim:SetBank("whale")
	anim:PlayAnimation("idle", true)

	inst:AddTag("animal")
	inst:AddTag("largecreature")
	inst:AddTag("aquatic")

	inst:AddComponent("combat")

	inst:ListenForEvent("attacked", function(inst, data) OnAttacked(inst, data) end)

	inst:AddComponent("health")

	inst:AddComponent("inspectable")

	MakeLargeFreezableCharacter(inst)

	inst:AddComponent("knownlocations")
	inst:AddComponent("locomotor")

	inst:AddComponent("sleeper")
	inst.components.sleeper.onlysleepsfromitems = true 
	inst.components.sleeper:SetSleepTest(ShouldSleep)
	inst.components.sleeper:SetWakeTest(ShouldWakeUp)

	inst:SetStateGraph("SGwhale")

	inst:AddComponent("tiletracker")
	-- inst.components.tiletracker:SetOnWaterChangeFn(OnWaterChange)

	inst.OnEntityWake = OnEntityWake
	inst.OnEntitySleep = OnEntitySleep

	inst.OnLoad = OnLoad
	inst.OnSave = OnSave

	return inst
end

local function KeepTargetBlue(inst, target)
	return distsq(Vector3(target.Transform:GetWorldPosition() ), Vector3(inst.Transform:GetWorldPosition() ) ) < TUNING.WHALE_BLUE_CHASE_DIST * TUNING.WHALE_BLUE_CHASE_DIST
end

local function create_blue(sim)
	local inst = create_base(sim)

	inst.AnimState:SetBuild("whale_blue_build")
	inst.carcass = "whale_carcass_blue"

	inst.sounds = bluesounds
	inst.components.combat:SetHurtSound(inst.sounds.hit)

	inst.components.locomotor.walkspeed = TUNING.WHALE_BLUE_SPEED * 0.5
	inst.components.locomotor.runspeed = TUNING.WHALE_BLUE_SPEED

	inst.components.combat:SetKeepTargetFunction(KeepTargetBlue)
	inst.components.combat:SetDefaultDamage(TUNING.WHALE_BLUE_DAMAGE)
	inst.components.combat:SetAttackPeriod(3.5)

	inst.components.health:SetMaxHealth(TUNING.WHALE_BLUE_HEALTH)

	inst.components.sleeper:SetResistance(3)

	inst:SetBrain(bluebrain)

	return inst
end

local function KeepTargetWhite(inst, target)
	return distsq(Vector3(target.Transform:GetWorldPosition() ), Vector3(inst.Transform:GetWorldPosition() ) ) < TUNING.WHALE_WHITE_CHASE_DIST * TUNING.WHALE_WHITE_CHASE_DIST
end

local function RetargetWhite(inst)
	--White Whale is aggressive. Look for targets.
	local notags = {"FX", "NOCLICK","INLIMBO"}
    return FindEntity(inst, TUNING.WHALE_WHITE_TARGET_DIST, function(guy) 
        return inst.components.combat:CanTarget(guy) and guy:HasTag("aquatic")
    end, nil, notags)
end

local function create_white(sim)
	local inst = create_base(sim)

	local s = 1.25
	inst.Transform:SetScale(s,s,s)

	inst.AnimState:SetBuild("whale_moby_build")
	inst.carcass = "whale_carcass_white"

	inst.sounds = whitesounds
	inst.components.combat:SetHurtSound(inst.sounds.hit)

	inst.components.locomotor.walkspeed = TUNING.WHALE_WHITE_SPEED * 0.5
	inst.components.locomotor.runspeed = TUNING.WHALE_WHITE_SPEED

	inst.components.combat:SetKeepTargetFunction(KeepTargetWhite)
	inst.components.combat:SetDefaultDamage(TUNING.WHALE_WHITE_DAMAGE)
	inst.components.combat:SetRetargetFunction(1, RetargetWhite)
	inst.components.combat:SetAttackPeriod(3)

	inst.components.health:SetMaxHealth(TUNING.WHALE_WHITE_HEALTH)

	inst.components.sleeper:SetResistance(5)

	inst:SetBrain(whitebrain)

	return inst
end

return Prefab( "forest/animals/whale_blue", create_blue, assets, prefabs),
	   Prefab( "forest/animals/whale_white", create_white, assets, prefabs)
