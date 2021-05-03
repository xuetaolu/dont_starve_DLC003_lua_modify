require "brains/scarerbrain"
require "stategraphs/SGscarer"

local assets=
{
	Asset("ANIM", "anim/krampus_basic.zip"),
	Asset("ANIM", "anim/krampus_build.zip"),

    Asset("ANIM", "anim/krampus_hawaiian_basic.zip"),
    Asset("ANIM", "anim/krampus_hawaiian_build.zip"),


	Asset("SOUND", "sound/krampus.fsb"),
}

local prefabs =
{
	"charcoal",
	"monstermeat",
	"krampus_sack",
}

SetSharedLootTable( 'krampus',
{
    {'monstermeat',  1.0},
    {'charcoal',     1.0},
    {'charcoal',     1.0},
    {'krampus_sack', .01},
})

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    --inst.components.combat:ShareTarget(data.attacker, SEE_DIST, function(dude) return dude:HasTag("hound") and not dude.components.health:IsDead() end, 5)
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local physics = inst.entity:AddPhysics()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 3, 1 )
    inst.Transform:SetFourFaced()
	
	inst:AddTag("scarytoprey")
    inst:AddTag("animal")
    inst:AddTag("largecreature")
	
    MakePoisonableCharacter(inst)
    MakeCharacterPhysics(inst, 10, .5)

    inst:AddComponent("inventory")
    inst.components.inventory.ignorescangoincontainer = true

    if SaveGameIndex:IsModeShipwrecked() then
        anim:SetBank("krampus")
        anim:SetBuild("krampus_hawaiian_build")
    else 
        anim:SetBank("krampus")
        anim:SetBuild("krampus_build")
    end 
   

    anim:PlayAnimation("run_loop", true)
    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = TUNING.SCARER_SPEED
    inst:SetStateGraph("SGscarer")


    local brain = require "brains/scarerbrain"
    inst:SetBrain(brain)
    
    MakeLargeBurnableCharacter(inst, "krampus_torso")
    MakeLargeFreezableCharacter(inst, "krampus_torso")
    
 --[[   inst:AddComponent("eater")
    inst.components.eater:SetCarnivore()
	inst.components.eater:SetCanEatHorrible()
    inst.components.eater.strongstomach = true -- can eat monster meat!--]]
    
    inst:AddComponent("sleeper")
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.KRAMPUS_HEALTH)
    
    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.KRAMPUS_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.KRAMPUS_ATTACK_PERIOD)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('krampus')
    
    inst:AddComponent("inspectable")
	inst.components.inspectable:RecordViews()
    
    inst:ListenForEvent("attacked", OnAttacked)

    return inst
end


return Prefab( "monsters/pigscarer", fn, assets, prefabs) 
