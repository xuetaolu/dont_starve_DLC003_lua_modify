
require "stategraphs/SGroc_head"

local trace = function() end

local assets=
{
	Asset("ANIM", "anim/roc_head_build.zip"),
	Asset("ANIM", "anim/roc_head_basic.zip"),
	Asset("ANIM", "anim/roc_head_actions.zip"),
	Asset("ANIM", "anim/roc_head_attacks.zip"),
}

local prefabs =
{

}

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local physics = inst.entity:AddPhysics()
	local sound = inst.entity:AddSoundEmitter()
	--local shadow = inst.entity:AddDynamicShadow()
	--shadow:SetSize( 2.5, 1.5 )
	inst.Transform:SetEightFaced()

	inst:AddTag("scarytoprey")
	inst:AddTag("monster")
	inst:AddTag("hostile")
	inst:AddTag("roc")
	inst:AddTag("roc_head")
	inst:AddTag("noteleport")

   -- MakeObstaclePhysics(inst, 2)
   inst.Transform:SetScale(.8,.8,.8)

	anim:SetBank("head")
	anim:SetBuild("roc_head_build")
	anim:PlayAnimation("idle_loop")
	--inst.AnimState:SetRayTestOnBB(true)

	inst:AddComponent("knownlocations")

	--inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
	--inst.components.locomotor.runspeed = TUNING.SNAKE_SPEED

	inst:SetStateGraph("SGroc_head")

--	inst:AddComponent("health")
--	inst.components.health:SetMaxHealth(TUNING.SNAKE_HEALTH)
	--inst.components.health.poison_damage_scale = 0 -- immune to poison

	inst:AddComponent("groundpounder")	
    inst.components.groundpounder.destroyer = true
    inst.components.groundpounder.damageRings = 2
    inst.components.groundpounder.destructionRings = 1
    inst.components.groundpounder.numRings = 3


	inst:AddComponent("combat")
	inst.components.combat:SetDefaultDamage(1000)
	inst:AddComponent("inspectable")

	inst:AddComponent("sanityaura")
	inst.components.sanityaura.aurafn = function() return -TUNING.SANITYAURA_LARGE end

	--inst:ListenForEvent("attacked", OnAttacked)
	--inst:ListenForEvent("onattackother", OnAttackOther)

	return inst
end

return Prefab("monsters/roc_head", fn, assets, prefabs)

