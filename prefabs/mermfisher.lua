require "brains/mermfisherbrain"
require "stategraphs/SGmerm"

local assets=
{
	Asset("ANIM", "anim/merm_fisherman_build.zip"),
	Asset("ANIM", "anim/ds_pig_basic.zip"),
	Asset("ANIM", "anim/ds_pig_actions.zip"),
	Asset("ANIM", "anim/ds_pig_attacks.zip"),
    Asset("ANIM", "anim/merm_fishing.zip"),
	Asset("SOUND", "sound/merm.fsb"),
}

local prefabs =
{
    "tropical_fish",
}

local loot =
{
    "tropical_fish",
}

local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 40

local function ontalk(inst, script)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/merm/idle")
end

local function ShouldSleep(inst)
    return GetClock():IsDay()
           and not (inst.components.combat and inst.components.combat.target)
           and not (inst.components.homeseeker and inst.components.homeseeker:HasHome() )
           and not (inst.components.burnable and inst.components.burnable:IsBurning() )
           and not (inst.components.freezable and inst.components.freezable:IsFrozen() )
end

local function ShouldWake(inst)
    return not GetClock():IsDay()
           or (inst.components.combat and inst.components.combat.target)
           or (inst.components.homeseeker and inst.components.homeseeker:HasHome() )
           or (inst.components.burnable and inst.components.burnable:IsBurning() )
           or (inst.components.freezable and inst.components.freezable:IsFrozen() )
end

local NO_TAGS = {"FX", "NOCLICK", "DECOR", "INLIMBO"}
local HOUSE_TAGS = {"mermhouse"}

local function OnAttacked(inst, data)
    local attacker = data and data.attacker
    if attacker then
        inst.components.combat:SetTarget(attacker)

        local pt = inst:GetPosition()
        local homes = TheSim:FindEntities(pt.x, pt.y, pt.z, 20, HOUSE_TAGS, NO_TAGS)

        for k,v in pairs(homes) do
            if v and v.components.childspawner then
                v.components.childspawner:ReleaseAllChildren(attacker)
            end
        end

        inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, 
            function(dude) return dude:HasTag("mermfighter") end, MAX_TARGET_SHARES)
    end
end

local function retargetfn(inst, target)
    local tar = FindEntity(inst, 20, nil, nil, {"merm"}, {"player", "monster", "character"})

    if tar and tar:IsValid() and inst.components.combat:CanTarget(tar) then
        return tar
    end
end

local function keeptargetfn(inst, target)
    return inst.components.combat:CanTarget(target) and target:GetPosition():Dist(inst:GetPosition()) < 25
end

local function ontimerdone(inst, data)
    if data.name == "fish" then
        inst.CanFish = true
    end
end

local function oncollect(inst)
    inst.CanFish = false
    
    if inst.components.timer:TimerExists("fish") then
        inst.components.timer:StopTimer("fish")
    end

    inst.components.timer:StartTimer("fish", TUNING.SEG_TIME * 2)
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 1.5, .75 )
    inst.Transform:SetFourFaced()

    MakeCharacterPhysics(inst, 50, .5)

    anim:SetBank("pigman")
    anim:SetBuild("merm_fisherman_build")

    inst:AddComponent("locomotor")
    inst.components.locomotor.runspeed = TUNING.MERM_RUN_SPEED
    inst.components.locomotor.walkspeed = TUNING.MERM_WALK_SPEED

    inst:SetStateGraph("SGmerm")
    anim:Hide("hat")

    inst:AddTag("character")
    inst:AddTag("merm")
    inst:AddTag("mermfisher")
    inst:AddTag("wet")

    local brain = require "brains/mermfisherbrain"
    inst:SetBrain(brain)

    inst:AddComponent("eater")
    inst.components.eater:SetVegetarian()

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetWakeTest(ShouldWake)
    inst.components.sleeper:SetSleepTest(ShouldSleep)

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "pig_torso"
    inst.components.combat:SetRetargetFunction(3, retargetfn)
    inst.components.combat:SetKeepTargetFunction(keeptargetfn)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.MERM_FISHER_HEALTH)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(loot)

    inst:AddComponent("inventory")

    inst:AddComponent("inspectable")
    inst:AddComponent("knownlocations")

    inst:AddComponent("talker")
    inst.components.talker.ontalk = ontalk
    inst.components.talker.fontsize = 35
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.offset = Vector3(0,-400,0)

    inst:AddComponent("fishingrod")
    inst.components.fishingrod:SetWaitTimes(TUNING.BIG_FISHING_ROD_MIN_WAIT_TIME, TUNING.BIG_FISHING_ROD_MAX_WAIT_TIME)
    inst.components.fishingrod:SetStrainTimes(0, 5)
    inst.components.fishingrod.basenibbletime = TUNING.BIG_FISHING_ROD_BASE_NIBBLE_TIME
    inst.components.fishingrod.nibbletimevariance = TUNING.BIG_FISHING_ROD_NIBBLE_TIME_VARIANCE
    inst.components.fishingrod.nibblestealchance = 0

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", ontimerdone)

    inst:ListenForEvent("fishingcollect", oncollect)

    inst:AddComponent("named")
    inst.components.named.possiblenames = STRINGS.MERMNAMES
    inst.components.named:PickNewName()

    inst.CanFish = true

    MakeMediumBurnableCharacter(inst, "pig_torso")
    MakeMediumFreezableCharacter(inst, "pig_torso")

    inst:ListenForEvent("attacked", OnAttacked)

    return inst
end

return Prefab("mermfisher", fn, assets, prefabs)
