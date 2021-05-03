require("brains/zebbrain")
require "stategraphs/SGzeb"

local assets =
{
    Asset("ANIM", "anim/zeb_build.zip"),
    Asset("ANIM", "anim/zeb.zip"),
    Asset("SOUND", "sound/lightninggoat.fsb"),
}

local prefabs =
{
    "meat",
}

SetSharedLootTable( 'zeb',
{
    {'meat',             1.00},
    {'meat',             1.00},
    {'meat',             0.50},
})

local function RetargetFn(inst)
    if inst.charged then
        -- Look for non-wall targets first
        local targ = FindEntity(inst, TUNING.ZEB_TARGET_DIST, function(guy)
            return not guy:HasTag("zeb") and 
                    inst.components.combat:CanTarget(guy) and 
                    not guy:HasTag("wall")
        end)
        -- If none, look for walls
        if not targ then
            targ = FindEntity(inst, TUNING.ZEB_TARGET_DIST, function(guy)
                return not guy:HasTag("zeb") and 
                        inst.components.combat:CanTarget(guy)
            end)
        end
        return targ
    end
end

local function KeepTargetFn(inst, target)
    if target:HasTag("wall") then 
        local newtarg = FindEntity(inst, TUNING.ZEB_TARGET_DIST, function(guy)
            return not guy:HasTag("zeb") and 
                    inst.components.combat:CanTarget(guy) and 
                    not guy:HasTag("wall")
        end)
        return newtarg == nil
    else
        if inst.components.herdmember
        and inst.components.herdmember:GetHerd() then
            local herd = inst.components.herdmember and inst.components.herdmember:GetHerd()
            if herd then
                return distsq(Vector3(herd.Transform:GetWorldPosition() ), Vector3(inst.Transform:GetWorldPosition() ) ) < TUNING.ZEB_CHASE_DIST*TUNING.ZEB_CHASE_DIST
            end
        end
        return true
    end
end

local function OnAttacked(inst, data)
    local attacker = data and data.attacker
    inst.components.combat:SetTarget(attacker)
    inst.components.combat:ShareTarget(attacker, 20, function(dude) return dude:HasTag("zeb") end, 3) 
end

local function getstatus(inst, viewer)

end

local function fn(Sim)
    local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()

	shadow:SetSize(1.75,.75)
    
    inst.Transform:SetFourFaced()
    
	MakeCharacterPhysics(inst, 100, 1)

    anim:SetBank("zeb")
    anim:SetBuild("zeb_build")
    anim:PlayAnimation("idle_loop", true)
    
    ------------------------------------------

    inst:AddTag("zeb")
    inst:AddTag("animal")    
    ------------------------------------------

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(350)
    
    ------------------
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.ZEB_DAMAGE)
    inst.components.combat:SetRange(TUNING.ZEB_ATTACK_RANGE)
    inst.components.combat.hiteffectsymbol = "sprint"
    inst.components.combat:SetAttackPeriod(TUNING.ZEB_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(1, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetHurtSound("dontstarve_DLC003/creatures/zeb/hurt")
    ------------------------------------------
 
    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(4)
    
    ------------------------------------------

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('zeb') 
    
    ------------------------------------------

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    ------------------------------------------

    inst:AddComponent("knownlocations")
    inst:AddComponent("herdmember")
    inst.components.herdmember:SetHerdPrefab("zebherd")

    ------------------------------------------

    inst:ListenForEvent("attacked", OnAttacked)

    ------------------------------------------

    MakeMediumBurnableCharacter(inst, "spring")
    MakeMediumFreezableCharacter(inst, "spring")

    ------------------------------------------

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.ZEB_WALK_SPEED
    inst.components.locomotor.runspeed = TUNING.ZEB_RUN_SPEED

    inst:SetStateGraph("SGzeb")
    local brain = require("brains/zebbrain")
    inst:SetBrain(brain)

    return inst
end

return Prefab( "common/monsters/zeb", fn, assets, prefabs) 
