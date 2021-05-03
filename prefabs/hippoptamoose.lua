require "brains/hippopotamoosebrain"
require "stategraphs/SGhippopotamoose"

local assets=
{
	Asset("ANIM", "anim/hippo_basic.zip"),
    Asset("ANIM", "anim/hippo_attacks.zip"),    
    Asset("ANIM", "anim/hippo_water.zip"),
    Asset("ANIM", "anim/hippo_water_attacks.zip"),    
	Asset("ANIM", "anim/hippo_build.zip"),
	Asset("SOUND", "sound/chess.fsb"),
}

local prefabs =
{
    "meat",
    "hippoherd",
    "hippo_antler",
}

SetSharedLootTable( 'hippopotamoose',
{
    {'meat',            1.00},
    {'meat',            1.00},
    {'meat',            1.00},
    {'meat',            1.00},
    {'hippo_antler',    1.00},
})

local sounds = 
{
    emerge = "dontstarve_DLC002/creatures/seacreature_movement/water_emerge_med",
    submerge = "dontstarve_DLC002/creatures/seacreature_movement/water_submerge_med",
}

local SLEEP_DIST_FROMHOME = 1
local SLEEP_DIST_FROMTHREAT = 20
local MAX_CHASEAWAY_DIST = 40
local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 40

local function ShouldSleep(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    local myPos = Vector3(inst.Transform:GetWorldPosition() )
    if not (homePos and distsq(homePos, myPos) <= SLEEP_DIST_FROMHOME*SLEEP_DIST_FROMHOME)
       or (inst.components.combat and inst.components.combat.target)
       or (inst.components.burnable and inst.components.burnable:IsBurning() )
       or (inst.components.freezable and inst.components.freezable:IsFrozen() ) then
        return false
    end
    local nearestEnt = GetClosestInstWithTag("character", inst, SLEEP_DIST_FROMTHREAT)
    return nearestEnt == nil
end

local function ShouldWake(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    local myPos = Vector3(inst.Transform:GetWorldPosition() )
    if (homePos and distsq(homePos, myPos) > SLEEP_DIST_FROMHOME*SLEEP_DIST_FROMHOME)
       or (inst.components.combat and inst.components.combat.target)
       or (inst.components.burnable and inst.components.burnable:IsBurning() )
       or (inst.components.freezable and inst.components.freezable:IsFrozen() ) then
        return true
    end
    local nearestEnt = GetClosestInstWithTag("character", inst, SLEEP_DIST_FROMTHREAT)
    return nearestEnt
end

local function Retarget(inst)
    if inst.components.herdmember
       and inst.components.herdmember:GetHerd()
       and inst.components.herdmember:GetHerd().components.mood
       and inst.components.herdmember:GetHerd().components.mood:IsInMood() then
        return FindEntity(inst, TUNING.BEEFALO_TARGET_DIST, function(guy)
            return not guy:HasTag("hippopotamoose") and 
                    inst.components.combat:CanTarget(guy) and 
                    not guy:HasTag("wall")
        end)
    end
end

local function KeepTarget(inst, target)
    if inst.components.herdmember
       and inst.components.herdmember:GetHerd()
       and inst.components.herdmember:GetHerd().components.mood
       and inst.components.herdmember:GetHerd().components.mood:IsInMood() then
        local herd = inst.components.herdmember and inst.components.herdmember:GetHerd()
        if herd and herd.components.mood and herd.components.mood:IsInMood() then
            return distsq(Vector3(herd.Transform:GetWorldPosition() ), Vector3(inst.Transform:GetWorldPosition() ) ) < TUNING.BEEFALO_CHASE_DIST*TUNING.BEEFALO_CHASE_DIST
        end
    end
    return true
end
--[[
local function Retarget(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    local myPos = Vector3(inst.Transform:GetWorldPosition() )
    if (homePos and distsq(homePos, myPos) > 40*40)  and not
    (inst.components.follower and inst.components.follower.leader)then
        return
    end
    
    local newtarget = FindEntity(inst, TUNING.HIPPO_TARGET_DIST, function(guy)
            return (guy:HasTag("character") or guy:HasTag("monster"))
                   and not (inst.components.follower and inst.components.follower.leader == guy)
                   and not (guy:HasTag("hippopotamoose") and (guy.components.follower and not guy.components.follower.leader))
                   and not ((inst.components.follower and inst.components.follower.leader == GetPlayer()) and (guy.components.follower and guy.components.follower.leader == GetPlayer()))
                   and inst.components.combat:CanTarget(guy)
    end)

    if not newtarget then
        inst:RemoveTag("enraged")
    end
    return newtarget
end

local function KeepTarget(inst, target)

    if (inst.components.follower and inst.components.follower.leader) then
        return true
    end

    if inst.sg and inst.sg:HasStateTag("running") then
        return true
    end

    local homePos = inst.components.knownlocations:GetLocation("home")
    local myPos = Vector3(inst.Transform:GetWorldPosition() )
    return (homePos and distsq(homePos, myPos) < 40*40)
end
]]
local function OnAttacked(inst, data)
    inst:AddTag("enraged")
    local attacker = data and data.attacker
    inst.components.combat:SetTarget(attacker)
    inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, function(dude) return dude:HasTag("hippopotamoose") end, MAX_TARGET_SHARES)
end

local function HitShake()
        --       :Shake(shakeType, duration, speed, scale)
        -- TheCamera:Shake("SIDE", 0.2, 0.05, .1)
        TheCamera:Shake("SIDE", 0.5, 0.05, 0.1)
end

local function DoChargeDamage(inst, target)
    if not inst.recentlycharged then
        inst.recentlycharged = {}
    end

    for k,v in pairs(inst.recentlycharged) do
        if v == target then
            --You've already done damage to this by charging it recently.
            return
        end
    end
    inst.recentlycharged[target] = target
    inst:DoTaskInTime(3, function() inst.recentlycharged[target] = nil end)
    inst.components.combat:DoAttack(target, inst.weapon)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/rook/explo") 
end

local function oncollide(inst, other)
    local v1 = Vector3(inst.Physics:GetVelocity())
    if other == GetPlayer() then
        return
    end
    if v1:LengthSq() < 42 then return end

    HitShake()

    inst:DoTaskInTime(2*FRAMES, function()   
            if  (other and other:HasTag("smashable")) then
                --other.Physics:SetCollides(false)
                other.components.health:Kill()
            elseif other and other.components.workable and other.components.workable.workleft > 0 then
                SpawnPrefab("collapse_small").Transform:SetPosition(other:GetPosition():Get())
                other.components.workable:Destroy(inst)
            elseif other and other.components.health and other.components.health:GetPercent() >= 0 then
                DoChargeDamage(inst, other)
            end
    end)

end

local function CreateWeapon(inst)
    local weapon = CreateEntity()
    weapon.entity:AddTransform()
    weapon:AddComponent("weapon")
    weapon.components.weapon:SetDamage(200)
    weapon.components.weapon:SetRange(0)
    weapon:AddComponent("inventoryitem")
    weapon.persists = false
    weapon.components.inventoryitem:SetOnDroppedFn(function() weapon:Remove() end)
    weapon:AddComponent("equippable")
    inst.components.inventory:GiveItem(weapon)
    inst.weapon = weapon
end


local function OnWaterChange(inst, onwater)
    if onwater then
        inst.onwater = true
        inst.sg:GoToState("submerge")
        inst.DynamicShadow:Enable(false)
    --        inst.components.locomotor.walkspeed = 3
    else
        inst.onwater = false        
        inst.sg:GoToState("emerge")
        inst.DynamicShadow:Enable(true)
    --        inst.components.locomotor.walkspeed = 4
    end
end


local function OnEntityWake(inst)
    inst.components.tiletracker:Start()
end

local function OnEntitySleep(inst)
    inst.components.tiletracker:Stop()
end


local function MakeMoose(nightmare)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()

    inst.sounds = sounds

	shadow:SetSize( 3, 1.25 )
    inst.Transform:SetFourFaced()
    --inst.Transform:SetScale(0.66, 0.66, 0.66)
   -- MakeCharacterPhysics(inst, 50, 1.5)
    MakeAmphibiousCharacterPhysics(inst, 50, 1.5)
    inst.Physics:SetCollisionCallback(oncollide)

    anim:SetBank("hippo")


    inst:AddComponent("tiletracker")
    inst.components.tiletracker:SetOnWaterChangeFn(OnWaterChange)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('hippopotamoose')

    anim:SetBuild("hippo_build")
    
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.HIPPO_WALK_SPEED
    inst.components.locomotor.runspeed =  TUNING.HIPPO_RUN_SPEED
    
    inst:SetStateGraph("SGhippopotamoose")

    inst:AddTag("animal")
    --inst:AddTag("hostile")
    inst:AddTag("hippopotamoose")
    inst:AddTag("huff_idle")    
    inst:AddTag("wavemaker")        
    inst:AddTag("lightshake")
    inst:AddTag("groundpoundimmune")

    local brain = require "brains/hippopotamoosebrain"
    inst:SetBrain(brain)
    
    inst:AddComponent("sleeper")
    inst.components.sleeper:SetWakeTest(ShouldWake)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetResistance(3)

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "spring"
    inst.components.combat:SetAttackPeriod(2)
    inst.components.combat:SetRetargetFunction(3, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.HIPPO_HEALTH)
    inst.components.combat:SetDefaultDamage(TUNING.HIPPO_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.HIPPO_ATTACK_PERIOD)
    --inst.components.combat.playerdamagepercent = 2

    inst:AddComponent("groundpounder")
    inst.components.groundpounder.destroyer = true
    inst.components.groundpounder.damageRings = 2
    inst.components.groundpounder.destructionRings = 1
    inst.components.groundpounder.numRings = 2

    inst:AddComponent("inventory")

    inst:AddComponent("inspectable")
    inst:AddComponent("knownlocations")

    inst:AddComponent("knownlocations")
    inst:AddComponent("herdmember")
    inst.components.herdmember:SetHerdPrefab("hippoherd")
    
    inst:DoTaskInTime(2*FRAMES, function() inst.components.knownlocations:RememberLocation("home", Vector3(inst.Transform:GetWorldPosition()), true) end)

    MakeLargeBurnableCharacter(inst, "swap_fire")
    MakeMediumFreezableCharacter(inst, "spring")
    
    inst:ListenForEvent("attacked", OnAttacked)

    inst.OnEntityWake = OnEntityWake
    inst.OnEntitySleep = OnEntitySleep    

    CreateWeapon(inst)

    --inst:AddComponent("debugger")

    return inst
end

return Prefab("chessboard/hippopotamoose", function() return MakeMoose() end , assets, prefabs)