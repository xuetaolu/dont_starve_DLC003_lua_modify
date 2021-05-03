require "brains/snapdragonbrain"
require "stategraphs/SGSnapdragon"

local assets=
{
    Asset("ANIM", "anim/snapdragon.zip"),
    Asset("ANIM", "anim/snapdragon_build.zip"),
	Asset("SOUND", "sound/beefalo.fsb"),
}

local prefabs =
{
    --TODO !!
}

SetSharedLootTable( 'snapdragon',
{
    {'whisperpod',             1.00},
    {'flower',                 1.00},
})

local periodictable = 
{
    {'dragonfruit_seeds',      0.05},
    {'whisperpod',             0.05},
    {'flower',                 0.90},
}


local sounds = 
{
    walk = "dontstarve/beefalo/walk",
    grunt = "dontstarve/beefalo/grunt",
    yell = "dontstarve/beefalo/yell",
    swish = "dontstarve/beefalo/tail_swish",
    curious = "dontstarve/beefalo/curious",
    angry = "dontstarve/beefalo/angry",
}

local function Retarget(inst)
end

local function KeepTarget(inst, target)
    return true 
end

local function OnNewTarget(inst, data)
    if inst.components.follower and data and data.target and data.target == inst.components.follower.leader then
        inst.components.follower:SetLeader(nil)
    end
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, 30,function(dude)
        return dude:HasTag("snapdragon") and not dude:HasTag("player") and not dude.components.health:IsDead()
    end, 5)
end

local function OnEat(inst, data)
    -- Increase the amount of food in the stomach.
    inst.foodItemsEatenCount = inst.foodItemsEatenCount + 1
end

local function GetStatus(inst)
    if inst.components.follower.leader ~= nil then
        return "FOLLOWER"
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	inst.sounds = sounds
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 6, 2 )
    inst.Transform:SetFourFaced()
    inst.foodItemsEatenCount = 0
    
    MakePoisonableCharacter(inst)
    MakeCharacterPhysics(inst, 100, .5)
    local scale = 1.22
    inst.Transform:SetScale(scale, scale, scale)
    
    inst:AddTag("snapdragon")

    anim:SetBank("snapdragon")
    anim:SetBuild("snapdragon_build")
    anim:PlayAnimation("idle", true)

    inst:AddTag("animal")
    inst:AddTag("largecreature")
    
    inst:AddComponent("eater")
    inst.components.eater:SetVegetarian()
    inst.components.eater:SetOnEatFn(OnEat)
    
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "beefalo_body"
    inst.components.combat:SetDefaultDamage(TUNING.BEEFALO_DAMAGE)
    inst.components.combat:SetRetargetFunction(1, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
     
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.BEEFALO_HEALTH)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('snapdragon')    
    
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus
    
    inst:AddComponent("knownlocations")
    inst:AddComponent("herdmember")
    inst.components.herdmember:SetHerdPrefab("snapdragonherd")
    
    inst:AddComponent("leader")
    inst:AddComponent("follower")
    inst.components.follower.maxfollowtime = TUNING.BEEFALO_FOLLOW_TIME
    inst.components.follower.canaccepttarget = false
    inst:ListenForEvent("newcombattarget", OnNewTarget)
    inst:ListenForEvent("attacked", OnAttacked)

    inst:AddComponent("periodicspawner")
    -- inst.components.periodicspawner:SetPrefab("poop")
    inst.components.periodicspawner.chancetable = periodictable
    inst.components.periodicspawner:SetRandomTimes(40, 60)
    inst.components.periodicspawner:SetDensityInRange(20, 2)
    inst.components.periodicspawner:SetMinimumSpacing(8)
    inst.components.periodicspawner:Start()

    MakeLargeBurnableCharacter(inst, "swap_fire")
    MakeLargeFreezableCharacter(inst, "beefalo_body")
    
    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 4
    
    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    
    local brain = require "brains/snapdragonbrain"
    inst:SetBrain(brain)
    inst:SetStateGraph("SGSnapdragon")
    return inst
end

return Prefab( "forest/animals/snapdragon", fn, assets, prefabs) 
