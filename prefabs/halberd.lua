local assets=
{
	Asset("ANIM", "anim/halberd.zip"),
	Asset("ANIM", "anim/swap_halberd.zip"),

}

local function onfinished(inst)
	inst:Remove()
end

local function onequip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_halberd", "swap_halberd")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "idle_water", "idle")

	anim:SetBank("halberd")
	anim:SetBuild("halberd")
	anim:PlayAnimation("idle")

	inst:AddTag("halberd")

	inst:AddTag("sharp")

	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(TUNING.HALBERD_DAMAGE)

	-----
	inst:AddComponent("tool")
	inst.components.tool:SetAction(ACTIONS.CHOP)
	-------
	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(TUNING.HALBERD_USES)
	inst.components.finiteuses:SetUses(TUNING.HALBERD_USES)
	inst.components.finiteuses:SetOnFinished( onfinished)
	inst.components.finiteuses:SetConsumption(ACTIONS.CHOP, 1)
	-------

	inst:AddComponent("inspectable")


	inst:AddComponent("equippable")

	inst.components.equippable:SetOnEquip( onequip )

	inst.components.equippable:SetOnUnequip( onunequip)

	return inst
end

local function normal(Sim)
	local inst = fn(Sim)

	inst:AddComponent("inventoryitem")

	return inst
end


return Prefab( "common/inventory/halberd", normal, assets)
