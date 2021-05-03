require "brains/ghostbrain"
require "stategraphs/SGghost"

local assets =
{
	Asset("ANIM", "anim/ghost.zip"),
	Asset("ANIM", "anim/ghost_build.zip"),
	Asset("SOUND", "sound/ghost.fsb"),
   -- Asset("ANIM", "anim/ghost_pig_build.zip"),    
}

local prefabs = 
{
}

local assets_pirate =
{
    Asset("ANIM", "anim/ghost.zip"),
    Asset("ANIM", "anim/ghost_pirate_build.zip"),
}

local assets_pig =
{
    Asset("ANIM", "anim/ghost.zip"),
    Asset("ANIM", "anim/ghost_pig_build.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
    local light = inst.entity:AddLight()
    inst.entity:AddPhysics()
    anim:SetBloomEffectHandle( "shaders/anim.ksh" )
    
    MakeAmphibiousGhostPhysics(inst, 1, .5)
    
    light:SetIntensity(.6)
    light:SetRadius(.5)
    light:SetFalloff(.6)
    light:Enable(true)
    light:SetColour(180/255, 195/255, 225/255)
    
    local brain = require "brains/ghostbrain"
    inst:SetBrain(brain)
    
    anim:SetBank("ghost")
    anim:SetBuild("ghost_build")
    anim:PlayAnimation("idle", true)
    --inst.AnimState:SetMultColour(1,1,1,.6)
    
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("ghost")
    inst:AddTag("noauradamage")

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.GHOST_SPEED
    inst.components.locomotor.runspeed = TUNING.GHOST_SPEED
    inst.components.locomotor.directdrive = true
    
    inst:SetStateGraph("SGghost")
    
	inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED
    
    inst:AddComponent("inspectable")
    
	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(TUNING.GHOST_HEALTH)
    
    inst:AddComponent("combat")
    inst.components.combat.defaultdamage = TUNING.GHOST_DAMAGE
    inst.components.combat.playerdamagepercent = TUNING.GHOST_DMG_PLAYER_PERCENT

    inst:AddComponent("aura")
    inst.components.aura.radius = TUNING.GHOST_RADIUS
    inst.components.aura.tickperiod = TUNING.GHOST_DMG_PERIOD
    
    ------------------    
    inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_howl_LP", "howl")
    
    return inst
end

local function piratefn(Sim)
    local inst = fn(Sim)
    inst.AnimState:SetBuild("ghost_pirate_build")
    return inst
end

local function onsave(inst, data)
    if inst:HasTag("aporkalypse_cleanup")then
        data.aporkalypse_cleanup = true
    end
end

local function onload(inst, data)
    if data then 
        if data.aporkalypse_cleanup then
            inst:AddTag("aporkalypse_cleanup")
        end        
    end    
end

local function pigfn(Sim)
    local inst = fn(Sim)
    inst.AnimState:SetBuild("ghost_pig_build")

    inst.OnSave = onsave
    inst.OnLoad = onload

    inst:ListenForEvent("endaporkalypse", 
        function(_)
            if inst:HasTag("aporkalypse_cleanup") then
                inst:Remove()
            end
        end, 
    GetWorld())

    return inst
end


return Prefab( "common/monsters/ghost", fn, assets, prefabs ),
       Prefab( "common/monsters/pirateghost", piratefn, assets_pirate, prefabs),
       Prefab( "common/monsters/pigghost", pigfn, assets_pig, prefabs)