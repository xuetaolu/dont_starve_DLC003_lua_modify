local assets=
{
	Asset("ANIM", "anim/hand_lens.zip"),
	Asset("ANIM", "anim/swap_hand_lens.zip"),
}

local prefabs =
{
}

local function onequip(inst, owner) 
	owner.AnimState:OverrideSymbol("swap_object", "swap_hand_lens", "swap_hand_lens")
	owner.AnimState:Show("ARM_carry") 
	owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner)
	owner.AnimState:Hide("ARM_carry") 
	owner.AnimState:Show("ARM_normal") 
end

local function onfinished(inst)
    inst:Remove()
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	MakeInventoryPhysics(inst)
	-------
	inst:AddComponent("finiteuses")

	local uses = TUNING.MAGNIFYING_GLASS_USES
	local player = GetPlayer()
	if player and player:HasTag("treasure_hunter") then
		uses = uses * 2
	end

	inst.components.finiteuses:SetMaxUses(uses)
	inst.components.finiteuses:SetUses(uses)
	
	inst.components.finiteuses:SetConsumption(ACTIONS.SPY, 1)
	inst.components.finiteuses:SetOnFinished(onfinished)
	-------
	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(TUNING.MAGNIFYING_GLASS_DAMAGE)

	inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.SPY)
	-------
	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")
	
	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)
	
	inst:AddComponent("lighter")
	inst:AddTag("magnifying_glass")

	inst.AnimState:SetBank("hand_lens")
	inst.AnimState:SetBuild("hand_lens")
	inst.AnimState:PlayAnimation("idle")

	--inst.components.inventoryitem.imagename = "hand_lens"

	return inst
end

local function warbucks_mag_fn()
	local inst = fn()
	inst:RemoveComponent("finiteuses")
end

return Prefab( "common/inventory/magnifying_glass", fn, assets, prefabs)