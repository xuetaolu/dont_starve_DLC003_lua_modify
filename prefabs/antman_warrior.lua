require "brains/antwarriorbrain"
require "stategraphs/SGwarriorant"
require "brains/antwarriorbrain_egg"

local assets =
{
	Asset("ANIM", "anim/antman_basic.zip"),
	Asset("ANIM", "anim/antman_attacks.zip"),
	Asset("ANIM", "anim/antman_actions.zip"),
    Asset("ANIM", "anim/antman_egghatch.zip"),
    Asset("ANIM", "anim/antman_guard_build.zip"),
    Asset("ANIM", "anim/antman_warpaint_build.zip"),

    Asset("ANIM", "anim/antman_translucent_build.zip"),
}

local prefabs =
{
    "monstermeat",
    "chitin",
    "antman_warrior_egg"
}

local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 30

local function ontalk(inst, script)
	inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/crickant/abandon")
end

local function SpringMod(amt)
    if GetSeasonManager() and (GetSeasonManager():IsSpring() or GetSeasonManager():IsGreenSeason()) then
        return amt --* TUNING.SPRING_COMBAT_MOD
    else
        return amt
    end
end

local function OnAttackedByDecidRoot(inst, attacker)
    local fn = function(dude) return dude:HasTag("antman") end

    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = nil
    ents = TheSim:FindEntities(x, y, z, SHARE_TARGET_DIST / 2)
    
    if ents then
        local num_helpers = 0
        for k, v in pairs(ents) do
            if v ~= inst and v.components.combat and not (v.components.health and v.components.health:IsDead()) and fn(v) then
                if v:PushEvent("suggest_tree_target", {tree=attacker}) then
                    num_helpers = num_helpers + 1
                end
            end
            if num_helpers >= MAX_TARGET_SHARES then
                break
            end     
        end
    end
end

local function OnAttacked(inst, data)
    local attacker = data.attacker
    inst:ClearBufferedAction()

    if attacker.prefab == "deciduous_root" and attacker.owner then
        OnAttackedByDecidRoot(inst, attacker.owner)
    elseif attacker.prefab ~= "deciduous_root" then
        inst.components.combat:SetTarget(attacker)
        inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, function(dude) return dude:HasTag("ant") end, MAX_TARGET_SHARES)
    end
end

local builds = {"antman_translucent_build"}-- {"antman_build"} 

local function is_complete_disguise(target)
    return target:HasTag("has_antmask") and target:HasTag("has_antsuit")
end

local function NormalRetargetFn(inst)
    return FindEntity(inst, TUNING.ANTMAN_WARRIOR_TARGET_DIST,
        function(guy)
            if guy.components.health and not guy.components.health:IsDead() and inst.components.combat:CanTarget(guy) then
                if guy:HasTag("monster") then return guy end
                if guy:HasTag("player") and guy.components.inventory and guy:GetDistanceSqToInst(inst) < TUNING.ANTMAN_WARRIOR_ATTACK_ON_SIGHT_DIST*TUNING.ANTMAN_WARRIOR_ATTACK_ON_SIGHT_DIST and not guy:HasTag("ant_disguise") then return guy end
            end
        end
    )
end

local function NormalKeepTargetFn(inst, target)
    --give up on dead guys, or guys in the dark, or werepigs
    return inst.components.combat:CanTarget(target)
           and (not target.LightWatcher or target.LightWatcher:IsInLight())
           and not (target.sg and target.sg:HasStateTag("transform") )
end

local function TransformToNormal(inst)
    local normal = SpawnPrefab("antman")
    normal.Transform:SetPosition(  inst.Transform:GetWorldPosition() )
    -- re-register us with the childspawner and interior
    ReplaceEntity(inst, normal)

    inst:Remove()
end

local function SetNormalAnt(inst)
    local brain = require "brains/antwarriorbrain"
    inst:SetBrain(brain)
    inst:SetStateGraph("SGwarriorant")
	inst.AnimState:SetBuild(inst.build)
    
    inst.components.sleeper.onlysleepsfromitems = true

    inst.components.combat:SetDefaultDamage(TUNING.ANTMAN_WARRIOR_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.ANTMAN_WARRIOR_ATTACK_PERIOD)
    inst.components.combat:SetKeepTargetFunction(NormalKeepTargetFn)
    
    inst.components.locomotor.runspeed = TUNING.ANTMAN_WARRIOR_RUN_SPEED
    inst.components.locomotor.walkspeed = TUNING.ANTMAN_WARRIOR_WALK_SPEED
    
    inst.components.lootdropper:SetLoot({})
    inst.components.lootdropper:AddRandomLoot("monstermeat", 3)
    inst.components.lootdropper:AddRandomLoot("chitin", 1)
    inst.components.lootdropper.numrandomloot = 1

    inst.components.health:SetMaxHealth(TUNING.ANTMAN_WARRIOR_HEALTH)
    inst.components.combat:SetRetargetFunction(3, NormalRetargetFn)
    inst.components.combat:SetTarget(nil)

    inst.components.talker:StopIgnoringAll()
end

local function common()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize(1.5, .75)

    local light = inst.entity:AddLight()
    light:SetFalloff(.35)
    light:SetIntensity(.25)
    light:SetRadius(1)
    light:SetColour(120/255, 120/255, 120/255)
    light:Enable(false)

    trans:SetFourFaced()
    trans:SetScale(1.15, 1.15, 1.15)

    inst.entity:AddLightWatcher()
    
    inst:AddComponent("talker")
    inst.components.talker.ontalk = ontalk
    inst.components.talker.fontsize = 35
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.offset = Vector3(0, -400, 0)

    MakeCharacterPhysics(inst, 50, .5)
    MakePoisonableCharacter(inst)
    
    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = TUNING.ANTMAN_WARRIOR_RUN_SPEED --5
    inst.components.locomotor.walkspeed = TUNING.ANTMAN_WARRIOR_WALK_SPEED --3

    inst:AddTag("character")
    inst:AddTag("ant")
    inst:AddTag("scarytoprey")
    anim:SetBank("antman")
    anim:PlayAnimation("idle_loop")
    anim:Hide("hat")

    ------------------------------------------
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "antman_torso"
    inst.components.combat.debris_immune = true

    MakeMediumBurnableCharacter(inst, "antman_torso")

    inst:AddComponent("named")
    inst.components.named.possiblenames = STRINGS.ANTWARRIORNAMES
    inst.components.named:PickNewName()
	
    ------------------------------------------
    inst:AddComponent("health")
    inst:AddComponent("inventory")
    inst:AddComponent("lootdropper")
    inst:AddComponent("knownlocations")
    inst:AddComponent("sleeper")
    inst:AddComponent("inspectable")
    ------------------------------------------
    MakeMediumFreezableCharacter(inst, "antman_torso")
    ------------------------------------------

    inst.OnSave = function(inst, data)
        data.build = inst.build

        if inst.queen then
            data.queen_guid = inst.queen.GUID
        end

        if inst:HasTag("aporkalypse_cleanup") then
            data.aporkalypse_cleanup = true
        end

    end        
    
    inst.OnLoad = function(inst, data)
		if data then
			inst.build = data.build or builds[1]
			inst.AnimState:SetBuild(inst.build)
		end
    end

    inst.OnLoadPostPass = function (inst, ents, data)
        if data.queen_guid and ents[data.queen_guid] then
            inst.queen = ents[data.queen_guid].entity
            inst:ListenForEvent("death", function(warrior, data)
                inst.queen.WarriorKilled()
            end)
        end

        if data.aporkalypse_cleanup then
            inst:AddTag("aporkalypse_cleanup")
        end
    end
    
    inst:ListenForEvent("attacked", OnAttacked)
    
    inst.SetAporkalypse = function(enabled)
        if enabled then
            inst.Light:Enable(true)
            inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
            inst.build = "antman_warpaint_build"
        else
            inst.Light:Enable(false)
            inst.AnimState:SetBloomEffectHandle( "" )
            inst.build = "antman_guard_build"
        end

        inst.AnimState:SetBuild(inst.build)
    end

    inst:ListenForEvent("beginaporkalypse", function() inst.SetAporkalypse(true) end, GetWorld())

    inst:ListenForEvent("endaporkalypse", function() 
        if inst:HasTag("aporkalypse_cleanup") then
            if not inst:IsInLimbo() then
                TransformToNormal(inst)
            end
        else
            inst.SetAporkalypse(false)
        end
    end, GetWorld())

    inst:ListenForEvent("exitlimbo", function(inst)
        local aporkalypse = GetAporkalypse()

        if inst:HasTag("aporkalypse_cleanup") and not (aporkalypse and aporkalypse:IsActive()) then 
            TransformToNormal(inst)
        end 
    end)

    return inst
end

local function normal()
    local inst = common()
    inst.build = "antman_guard_build"

    local aporkalypse = GetAporkalypse()
    inst.SetAporkalypse((aporkalypse and aporkalypse:IsActive()))

    SetNormalAnt(inst)
    return inst
end

return Prefab("common/characters/antman_warrior", normal, assets)