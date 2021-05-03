require "brains/antqueenbrain"
require "stategraphs/SGantqueen"

local assets=
{
    --Asset("ANIM", "anim/perd_basic.zip"),
    Asset("ANIM", "anim/crickant_queen_basics.zip"),
}

local prefabs =
{
    "antman_warrior",
    "antman_warrior_egg",
    "warningshadow",
    "throne_wall_large",
    "throne_wall",
}

local loot =
{
    "pigcrownhat",
    "monstermeat",
    "monstermeat",
    "monstermeat",
    "monstermeat",
    "monstermeat",
    "chitin",
    "chitin",
    "chitin",
    "chitin",
    "honey",
    "honey",
    "honey",
    "honey",
    "honey",
    "bundlewrap_blueprint",
}

local spawn_positions =
{
    {x = 6, z = -6},
    {x = 6, z = 6 },
    {x = 6, z = 0 },
}

local function SpawnWarrior(inst)
    
    local x, y, z = inst.Transform:GetWorldPosition()
    local random_offset = spawn_positions[math.random(1, #spawn_positions)]

    x = x + random_offset.x + math.random(-1.5, 1.5)
    y = 35
    z = z + random_offset.z + math.random(-1.5, 1.5)

    local egg = SpawnPrefab("antman_warrior_egg")
    egg.queen = inst
    egg.Physics:Teleport(x, y, z)

    egg.start_grounddetection(egg)

    local shadow = SpawnPrefab("warningshadow")
    shadow.Transform:SetPosition(x, 0.2, z)
    shadow:shrink(1.5, 1.5, 0.25)

    inst.warrior_count = inst.warrior_count + 1
end

local function WarriorKilled(inst)
    inst.warrior_count = inst.warrior_count - 1
    if inst.warrior_count <= 0 then
        inst.components.combat.canattack = true
        inst.warrior_count = 0
    end
end

local function OnLoad(inst, data)
    if data.currentstate then
        inst.sg:GoToState(data.currentstate)
    end

    inst.warrior_count = data.warrior_count
end

local function OnSave( inst, data )
    data.currentstate = inst.sg.currentstate.name
    data.warrior_count = inst.warrior_count or 0
end

local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()

    trans:SetScale(0.9, 0.9, 0.9)

    MakeObstaclePhysics(inst, 2)
    MakePoisonableCharacter(inst)
     
    anim:SetBank ("crick_crickantqueen")
    anim:SetBuild("crickant_queen_basics")
    anim:AddOverrideBuild("throne")
    
    inst:AddComponent("locomotor")
    inst:SetStateGraph("SGantqueen")
    inst:AddTag("antqueen")
    inst:AddTag("epic")

    local brain = require "brains/antqueenbrain"
    inst:SetBrain(brain)

    inst:AddComponent("sleeper")
    inst.components.sleeper.onlysleepsfromitems = true
    
    inst:AddComponent("combat")
    inst.components.combat.canattack = false
    inst.components.combat.debris_immune = true

    inst.components.combat:SetOnHit(function() 
        local health_percent = inst.components.health:GetPercent()

        if health_percent <= 0.75 and health_percent > 0.5 then
            inst.summon_count = 4
            inst.min_combat_cooldown = 3
            inst.max_combat_cooldown = 5
        elseif health_percent <= 0.5 and health_percent > 0.25 then
            inst.max_sanity_attack_count = 3
            inst.max_jump_attack_count = 3
            inst.min_combat_cooldown = 1
            inst.max_combat_cooldown = 3
        elseif health_percent <= 0.25 then
            inst.min_combat_cooldown = 1
            inst.max_combat_cooldown = 1
        end
    end)
    
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.ANTQUEEN_HEALTH)
    inst.components.health:StartRegen(1, 4)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(loot)
    
    inst:AddComponent("inspectable")

    -- Used in SGantqueen
    inst.jump_count = 1
    inst.jump_attack_count = 0
    inst.max_jump_attack_count = 3

    inst.sanity_attack_count = 0
    inst.max_sanity_attack_count = 2

    inst.summon_count = 3
    inst.current_summon_count = 0

    inst.min_combat_cooldown = 5
    inst.max_combat_cooldown = 7

    MakeLargeFreezableCharacter(inst, "pig_torso")

    inst.warrior_count = 0
    inst.SpawnWarrior = SpawnWarrior
    inst.WarriorKilled = function () WarriorKilled(inst) end

    GetWorld():ListenForEvent("exitinterior", function(world, data)  
        if data.to_target.prefab and data.to_target:HasTag("anthill_outside") then
            inst.sg:GoToState("sleep")
            inst.components.combat.target = nil
        end
    end)

    GetWorld():ListenForEvent("doorused", function( world, data) 
        if data.from_door.components.door.target_interior == "FINAL_QUEEN_CHAMBER" then
            if inst.last_attack_time and inst.chamber_exit_time then
                inst.last_attack_time = GetTime() - (inst.chamber_exit_time - inst.last_attack_time)
            end
        else
            inst.chamber_exit_time = GetTime()
        end
    end)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst:ListenForEvent("attacked", function() 
        if inst.sg.currentstate.name == "sleeping" or inst.sg.currentstate.name == "sleep" then
            if inst.components.combat.target == nil then
                inst.components.combat:SetTarget(GetPlayer())
                inst.sg:GoToState("wake")
            end
        end
    end)

    return inst
end

local function make_throne_fn(size)

    local function fn()
        local inst = CreateEntity()
        local trans = inst.entity:AddTransform()

        inst:AddTag("throne_wall")
        MakeObstaclePhysics(inst, size)

        return inst
    end

    return fn
end

local function makethronewall(name, physics_size, assets, prefabs)
    return Prefab("common/objects/" .. name, make_throne_fn(physics_size), assets, prefabs )
end

return Prefab( "common/monsters/antqueen", fn,   assets, prefabs),
       makethronewall("throne_wall",       0.25, assets, prefabs),
       makethronewall("throne_wall_large", 0.5,  assets, prefabs)