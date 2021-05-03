require "brains/sharxbrain"
require "stategraphs/SGsharx"

local trace = function() end

local assets=
{
	--Asset("ANIM", "anim/hound_basic.zip"),
    Asset("ANIM", "anim/sharx.zip"),
	Asset("ANIM", "anim/sharx_build.zip"),

	--Asset("SOUND", "sound/hound.fsb"),
}

local prefabs =
{
    "shark_fin",
	"shark_gills",
	"monstermeat",
	--"redgem",
	--"bluegem",
}

SetSharedLootTable( 'sharx',
{
    {'monstermeat', 1.000},
    {'shark_fin',  0.125},
    {'houndstooth',  0.125},
})
 

local SHARE_TARGET_DIST = 30


local NO_TAGS = {"FX", "NOCLICK","DECOR","INLIMBO"}


local function retargetfn(inst)
    local notags = {"FX", "NOCLICK","INLIMBO", "sharx"}
    local yestags = {"aquatic"}

    local dist = TUNING.HOUND_TARGET_DIST
    return FindEntity(inst, dist, function(guy) 
	   return inst.components.combat:CanTarget(guy)
    end, yestags, notags)
end

local function KeepTarget(inst, target)
    local shouldkeep = inst.components.combat:CanTarget(target) and (not inst:HasTag("pet_hound") or inst:IsNear(target, TUNING.HOUND_FOLLOWER_TARGET_KEEP))
    --local onboat = target.components.driver and target.components.driver:GetIsDriving()
    local onwater = target:HasTag("aquatic")
    return shouldkeep and onwater
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, SHARE_TARGET_DIST, function(dude) return dude:HasTag("sharx")  and not dude.components.health:IsDead() end, 5)
end

local function OnAttackOther(inst, data)
    inst.components.combat:ShareTarget(data.target, SHARE_TARGET_DIST, function(dude) return dude:HasTag("sharx")  and not dude.components.health:IsDead() end, 5)
end

local function OnNewTarget(inst, data)
    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
end

local function fncommon()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local physics = inst.entity:AddPhysics()
	local sound = inst.entity:AddSoundEmitter()
	--local shadow = inst.entity:AddDynamicShadow()
	--shadow:SetSize( 2.5, 1.5 )
    inst.Transform:SetFourFaced()
	
	inst:AddTag("scarytoprey")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("sharx")
    inst:AddTag("aquatic")
	
    MakeCharacterPhysics(inst, 10, .5)
    MakePoisonableCharacter(inst)
     
    anim:SetBank("sharx")
    anim:SetBuild("sharx_build")
    anim:PlayAnimation("idle")
    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = TUNING.SHARX_SPEED
    inst:SetStateGraph("SGsharx")

    local brain = require "brains/sharxbrain"
    inst:SetBrain(brain)

    inst:AddComponent("follower")
    
    inst:AddComponent("eater")
    inst.components.eater:SetCarnivore()
	inst.components.eater:SetCanEatHorrible()

    inst.components.eater.strongstomach = true -- can eat monster meat!
    
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.SHARX_HEALTH)
    
    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED
    
    
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.SHARX_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.SHARX_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(3, retargetfn)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetHurtSound( "dontstarve_DLC002/creatures/sharx/hurt")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('sharx')
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    inst.components.sleeper.onlysleepsfromitems = true 
    
    inst:ListenForEvent("newcombattarget", OnNewTarget)

    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("onattackother", OnAttackOther)

    MakeMediumFreezableCharacter(inst, "sharx_body")


    return inst
end

local function fndefault()
	local inst = fncommon(Sim)
	
    --MakeMediumFreezableCharacter(inst, "hound_body")
    --MakeMediumBurnableCharacter(inst, "hound_body")
	return inst
end



return Prefab( "monsters/sharx", fndefault, assets, prefabs)
