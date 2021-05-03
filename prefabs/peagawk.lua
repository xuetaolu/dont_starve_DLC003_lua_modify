require "brains/peagawkbrain"
require "stategraphs/SGpeagawk"

local MAX_PRISM_DROPS = 5

local assets=
{
    Asset("ANIM", "anim/peagawk_basic.zip"),
    Asset("ANIM", "anim/peagawk_actions.zip"),
    Asset("ANIM", "anim/peagawk_charge.zip"),
    Asset("ANIM", "anim/peagawk_build.zip"),
    Asset("ANIM", "anim/peagawk_prism_build.zip"),
    Asset("ANIM", "anim/eyebush.zip"),
    Asset("ANIM", "anim/eyebush_prism_build.zip"),
	Asset("SOUND", "sound/perd.fsb"),
}

local prefabs =
{
    "drumstick",
    "peagawkfeather",
}

local loot = 
{
    "drumstick",
    "drumstick",
    "peagawkfeather",
}

local TAIL_FEATHERS_MAX = TUNING.PEAGAWK_TAIL_FEATHERS_MAX

local function refreshart(inst)
    for i=1,TAIL_FEATHERS_MAX do
        if inst.feathers < i then
            inst.AnimState:Hide("perd_tail_"..i)
        else
            inst.AnimState:Show("perd_tail_"..i)
        end
    end
end

local function TransformToRainbow(inst)
    if inst.is_bush then
        inst.AnimState:SetBuild("eyebush_prism_build")
    else
        inst.AnimState:SetBuild("peagawk_prism_build")
    end

    inst.prism = true
    inst.prismdroptask = inst:DoPeriodicTask(1, function() inst:PrismDrop() end)
    inst.prismdropped = 0

    inst.components.pickable:SetUp("peagawkfeather_prism", TUNING.PEAGAWK_REGROW_TIME)
    inst:SetupPrismTimer(PRISM_STOP_TIMER)
end 

local function UnRainbow(inst)
    inst.prism = false

    if inst.is_bush then
        inst.AnimState:SetBuild("eyebush")
    else
        inst.AnimState:SetBuild("peagawk_build")
    end

    if inst.prismdroptask ~= nil then
        inst.prismdroptask:Stop()
    end 
end 

local function PrismDrop(inst)
    local pos = inst.Transform:GetWorldPosition()
    if distsq(Vector3(pos), Vector3(inst.lastpos)) >= 10*10 and inst.prismdropped < MAX_PRISM_DROPS then
        local feather = SpawnPrefab("peagawkfeather_prism")
        local x,y,z = inst.Transform:GetWorldPosition()
        feather.Transform:SetPosition(x,y,z)
        inst.lastpos = pos 
        inst.prismdropped = inst.prismdropped + 1
    end
end

local function SetupPrismTimer(inst, prismtimer)
    inst.prismtimer = prismtimer
    inst.prismtask = inst:DoTaskInTime(inst.prismtimer, function() inst:UnRainbow() end)
end

local function canbepickedfn(inst)
    --print ("CAN BE PICKED ", inst.feathers and inst.feathers >= 1)

    return inst.feathers and inst.feathers >= 1
end

local function OnRegen(inst)
    inst.feathers = inst.feathers+1
    if inst.feathers < TAIL_FEATHERS_MAX then
        local pickable = inst.components.pickable
        pickable.task = inst:DoTaskInTime(pickable.regentime, inst.components.pickable.Regen, "regen")
        pickable.targettime = GetTime() + pickable.regentime
    end
    refreshart(inst)
end

local function TransformToAnimal(inst, ignore_state)
    inst.AnimState:SetBank("peagawk")
    inst.components.inspectable.nameoverride = nil

    if inst.prism then
        inst.AnimState:SetBuild("peagawk_prism_build")
    else
        inst.AnimState:SetBuild("peagawk_build")
    end

    inst.is_bush = false

    if not ignore_state then
        inst.sg:GoToState("appear")
    end
end

local function TransformToBush(inst)
    inst.AnimState:SetBank("eyebush")
    inst.components.inspectable.nameoverride = "peagawk_bush"

    if inst.prism then
        inst.AnimState:SetBuild("eyebush_prism_build")
    else
        inst.AnimState:SetBuild("eyebush")
    end

    inst.is_bush = true
end

local function OnPicked(inst, picker, loot)
    if inst.components.sleeper.isasleep then
        inst.components.sleeper:WakeUp()
    elseif inst.is_bush then
        inst.AnimState:PlayAnimation("picked", false)
    end

    inst.feathers = inst.feathers - 1
    refreshart(inst)

    inst:DoTaskInTime(0.1, function() 
        if inst.feathers > 0 then
            inst.components.pickable.canbepicked = true
            inst.components.pickable.hasbeenpicked = false
        end
    end)
    
end


local function OnSave(inst, data)
    data.feathers = inst.feathers
    data.is_bush = inst.is_bush
    data.prism = inst.prism

    if inst.is_bush then
        inst.TransformToBush(inst)
    end

    if inst.prism then
        inst.TransformToRainbow(inst)
    end
end

local function OnLoad(inst, data)
    if data and data.feathers then
        inst.feathers = data.feathers
        inst.prism = data.prism
    end
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
    MakePoisonableCharacter(inst)
     
    anim:SetBank("peagawk")
    anim:SetBuild("peagawk_build")
    
    inst:AddComponent("locomotor")
    inst.components.locomotor.runspeed = TUNING.PEAGAWK_RUN_SPEED
    inst.components.locomotor.walkspeed = TUNING.PEAGAWK_WALK_SPEED
    
    inst:SetStateGraph("SGpeagawk")
    anim:Hide("hat")

    inst:AddTag("character")
    inst:AddTag("berrythief")
    inst:AddTag("smallcreature")

    local brain = require "brains/peagawkbrain"
    inst:SetBrain(brain)
    
    inst:AddComponent("pickable")
    inst.components.pickable:SetUp("peagawkfeather", TUNING.PEAGAWK_REGROW_TIME)
    inst.components.pickable.canbepickedfn = canbepickedfn 
    inst.components.pickable.onregenfn = OnRegen
    inst.components.pickable.onpickedfn = OnPicked

    inst:AddComponent("eater")
    inst.components.eater:SetVegetarian()
    table.insert(inst.components.eater.foodprefs, "RAW")
    table.insert(inst.components.eater.ablefoods, "RAW")
    
    inst:AddComponent("sleeper")
    inst.components.sleeper:SetWakeTest( function() return true end)    --always wake up if we're asleep

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "pig_torso"
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.PERD_HEALTH)
    inst.components.combat:SetDefaultDamage(TUNING.PERD_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.PERD_ATTACK_PERIOD)

    inst:AddComponent("lootdropper") 
    inst.components.lootdropper:SetLoot(loot)

    inst.TransformToRainbow = TransformToRainbow
    inst.UnRainbow = UnRainbow
    inst.PrismDrop = PrismDrop
    inst.SetupPrismTimer = SetupPrismTimer
    inst.prism = false 
    inst.prismtimer = 0
    inst.prismdropped = 0 
    inst.lastpos = inst.Transform:GetWorldPosition()
    
    inst:AddComponent("inventory")
    inst:AddComponent("inspectable")
    
    MakeMediumBurnableCharacter(inst, "pig_torso")
    MakeMediumFreezableCharacter(inst, "pig_torso")

    inst.refreshart = refreshart
    inst.feathers = TAIL_FEATHERS_MAX

    inst.is_bush = false
    inst.TransformToBush = TransformToBush
    inst.TransformToAnimal = TransformToAnimal

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.refreshart = refreshart

    inst.TransformToAnimal(inst)
    
    return inst
end

return Prefab( "forest/animals/peagawk", fn, assets, prefabs)