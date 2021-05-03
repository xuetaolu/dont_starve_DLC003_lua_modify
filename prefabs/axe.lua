local assets=
{
	Asset("ANIM", "anim/axe.zip"),
	Asset("ANIM", "anim/axe_obsidian.zip"),
	Asset("ANIM", "anim/goldenaxe.zip"),
	Asset("ANIM", "anim/swap_axe.zip"),
	Asset("ANIM", "anim/swap_goldenaxe.zip"),
	Asset("ANIM", "anim/swap_axe_obsidian.zip"),
}

local function onfinished(inst)
	inst:Remove()
end

local function onequip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_axe", "swap_axe")
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

	anim:SetBank("axe")
	anim:SetBuild("axe")
	anim:PlayAnimation("idle")

	inst:AddTag("sharp")

	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(TUNING.AXE_DAMAGE)

	-----
	inst:AddComponent("tool")
	inst.components.tool:SetAction(ACTIONS.CHOP)
	-------
	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(TUNING.AXE_USES)
	inst.components.finiteuses:SetUses(TUNING.AXE_USES)
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

local function onequipgold(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_goldenaxe", "swap_goldenaxe")
	owner.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
end

local function golden(Sim)
	local inst = fn(Sim)
	
	inst:AddComponent("inventoryitem")
	
	inst.AnimState:SetBuild("goldenaxe")
	inst.AnimState:SetBank("goldenaxe")
	inst.AnimState:PlayAnimation("idle")
	inst.components.finiteuses:SetConsumption(ACTIONS.CHOP, 1 / TUNING.GOLDENTOOLFACTOR)
	inst.components.weapon.attackwear = 1 / TUNING.GOLDENTOOLFACTOR
	inst.components.equippable:SetOnEquip( onequipgold )

	return inst
end

local function onequipobsidian(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_axe_obsidian", "swap_axe")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
end

local function obsidian(Sim)
	local inst = fn(Sim)

	inst:AddComponent("inventoryitem")
	inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(0)
    inst.no_wet_prefix = true

	inst.AnimState:SetBuild("axe_obsidian")
	inst.AnimState:SetBank("axe_obsidian")
	inst.AnimState:PlayAnimation("idle")

	inst.components.finiteuses:SetConsumption(ACTIONS.CHOP, 1 / TUNING.OBSIDIANTOOLFACTOR)
	inst.components.weapon.attackwear = 1 / TUNING.OBSIDIANTOOLFACTOR
	inst.components.equippable:SetOnEquip(onequipobsidian)

	inst.components.tool:SetAction(ACTIONS.CHOP, TUNING.OBSIDIANTOOL_WORK)

	MakeObsidianTool(inst, "axe")

	return inst
end

return Prefab( "common/inventory/axe", normal, assets),
	   Prefab( "common/inventory/goldenaxe", golden, assets),
	   Prefab( "common/inventory/obsidianaxe", obsidian, assets)
