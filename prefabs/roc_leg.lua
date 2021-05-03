
require "stategraphs/SGroc_leg"

local trace = function() end

local assets=
{
	Asset("ANIM", "anim/roc_leg.zip"),
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
	inst.Transform:SetSixFaced()

	inst:AddTag("scarytoprey")
	inst:AddTag("monster")
	inst:AddTag("hostile")
	inst:AddTag("roc")
	inst:AddTag("roc_leg")
	inst:AddTag("noteleport")	

    MakeObstaclePhysics(inst, 2)

	anim:SetBank("foot")
	anim:SetBuild("roc_leg")
	anim:PlayAnimation("stomp_loop")
	--inst.AnimState:SetRayTestOnBB(true)

	inst:AddComponent("knownlocations")

	--inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
	--inst.components.locomotor.runspeed = TUNING.SNAKE_SPEED

	inst:SetStateGraph("SGroc_leg")

--	inst:AddComponent("health")
--	inst.components.health:SetMaxHealth(TUNING.SNAKE_HEALTH)
	--inst.components.health.poison_damage_scale = 0 -- immune to poison

	inst:AddComponent("groundpounder")	
    inst.components.groundpounder.destroyer = true
    inst.components.groundpounder.damageRings = 2
    inst.components.groundpounder.destructionRings = 1
    inst.components.groundpounder.numRings = 2	
    
	inst:AddComponent("combat")
	inst.components.combat:SetDefaultDamage(1000)
	inst:AddComponent("inspectable")

	inst:AddComponent("sanityaura")
	inst.components.sanityaura.aurafn = function() return -TUNING.SANITYAURA_LARGE end

	--inst:ListenForEvent("attacked", OnAttacked)
	--inst:ListenForEvent("onattackother", OnAttackOther)

	return inst
end

return Prefab("monsters/roc_leg", fn, assets, prefabs)
