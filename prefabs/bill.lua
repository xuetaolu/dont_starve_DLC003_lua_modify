require "stategraphs/SGbill"
local brain = require "brains/billbrain"

local assets =
{
	Asset("ANIM", "anim/bill_agro_build.zip"),
	Asset("ANIM", "anim/bill_calm_build.zip"),
	Asset("ANIM", "anim/bill_basic.zip"),
	Asset("ANIM", "anim/bill_water.zip"),
}

local prefabs =
{
	"bill_quill",
}

local billsounds =
{

}

SetSharedLootTable( 'bill',
{
    {'meat',            1.00},
    {'bill_quill',      1.00},
    {'bill_quill',      1.00},
    {'bill_quill',      0.33},
})



function IsBillFood(item)
	return item:HasTag("billfood")
end

local function UpdateAggro(inst)
	local threatWasNearby = inst.threatNearby
	local player = GetPlayer()

	local instPosition = Vector3(inst.Transform:GetWorldPosition())
	local playerPosition = Vector3(player.Transform:GetWorldPosition())
	inst.lotusTheifNearby = (distsq(playerPosition, instPosition) < (TUNING.BILL_TARGET_DIST * TUNING.BILL_TARGET_DIST)) and player.components.inventory:FindItem(IsBillFood)

	-- If the threat level changes then modify the build.
	if inst.lotusTheifNearby then
		inst.AnimState:SetBuild("bill_agro_build")
	else
		inst.AnimState:SetBuild("bill_calm_build")
	end
end

local function UpdateTumble(inst)
	inst.letsGetReadyToTumble = true
end

local function OnWaterChange(inst, onwater)
    if onwater then
        inst.onwater = true
        inst.AnimState:SetBank("bill_water")
        inst.DynamicShadow:Enable(false)
        inst:PushEvent("switch_to_water")
    else
        inst.onwater = false
        inst.AnimState:SetBank("bill")
        inst.DynamicShadow:Enable(true)
        inst:PushEvent("switch_to_land")
    end
end

local function KeepTarget(inst, target)
    return inst.components.combat:CanTarget(target) and (target == GetPlayer())
end

local function OnEntityWake(inst)
    inst.components.tiletracker:Start()
end

local function OnEntitySleep(inst)
    inst.components.tiletracker:Stop()
end

local function CanEat(inst, item)
	return item:HasTag("billfood")
end

local function OnAttacked(inst, data)
    local attacker = data and data.attacker
    inst.components.combat:SetTarget(attacker)
    inst.components.combat:ShareTarget(attacker, 20, function(dude) return dude:HasTag("platapine") end, 2)
end

local function fn(Sim)
	local inst    = CreateEntity()
	local trans   = inst.entity:AddTransform()
	local anim    = inst.entity:AddAnimState()
	local physics = inst.entity:AddPhysics()
	local sound   = inst.entity:AddSoundEmitter()
	local shadow  = inst.entity:AddDynamicShadow()

	inst.letsGetReadyToTumble = false

	shadow:SetSize(1, 0.75)
	inst.Transform:SetFourFaced()

	MakeAmphibiousCharacterPhysics(inst, 1, 0.5)
	MakePoisonableCharacter(inst)

	anim:SetBank("bill")
	anim:SetBuild("bill_calm_build")
	anim:PlayAnimation("idle", true)

	inst:AddTag("scarytoprey")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("platapine")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('bill')

	inst:AddComponent("locomotor")
	inst.components.locomotor.runspeed = TUNING.BILL_RUN_SPEED

	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(TUNING.BILL_HEALTH)
	inst.components.health.murdersound = "dontstarve/rabbit/scream_short"

	inst:AddComponent("inspectable")
	inst:AddComponent("sleeper")
	inst:AddComponent("eater")
	inst.components.eater:SetCanEatTestFn(CanEat)

    inst:AddComponent("tiletracker")
    inst.components.tiletracker:SetOnWaterChangeFn(OnWaterChange)

	inst:AddComponent("knownlocations")
	inst:DoTaskInTime(0, function() inst.components.knownlocations:RememberLocation("home", Point(inst.Transform:GetWorldPosition()), true) end)

	inst:DoPeriodicTask(1, UpdateAggro)
	inst:DoPeriodicTask(4, UpdateTumble)

	inst:AddComponent("combat")
	inst.components.combat:SetDefaultDamage(TUNING.BILL_DAMAGE)
	inst.components.combat:SetAttackPeriod(TUNING.BILL_ATTACK_PERIOD)
	inst.components.combat:SetRange(2, 3)
	inst.components.combat:SetKeepTargetFunction(KeepTarget)
	inst.components.combat.hiteffectsymbol = "chest"

	MakeSmallBurnableCharacter(inst, "chest")
	MakeTinyFreezableCharacter(inst, "chest")

	inst:ListenForEvent("attacked", OnAttacked)



	inst:SetStateGraph("SGbill")
	inst:SetBrain(brain)
	inst.data = {}

	inst.sounds = billsounds

    inst.OnEntityWake = OnEntityWake
    inst.OnEntitySleep = OnEntitySleep

	return inst
end

return Prefab("forest/animals/bill", fn, assets, prefabs)
