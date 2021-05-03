local assets=
{
	Asset("ANIM", "anim/pan.zip"),
	Asset("ANIM", "anim/swap_pan.zip"),
}

local function onfinished(inst)
	inst:Remove()
end

local function onequip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_pan", "swap_pan")
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

	anim:SetBank("pan")
	anim:SetBuild("pan")
	anim:PlayAnimation("idle")	

	inst:AddTag("worksOnFloor")

	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(TUNING.AXE_DAMAGE)

	-----
	inst:AddComponent("tool")
	inst.components.tool:SetAction(ACTIONS.PAN)
	-------
	inst:AddComponent("finiteuses")

	local uses = TUNING.PAN_USES
    local player = GetPlayer()
    if player and player:HasTag("treasure_hunter") then
        uses = uses * 2
    end

	inst.components.finiteuses:SetMaxUses(uses)
	inst.components.finiteuses:SetUses(uses)
	inst.components.finiteuses:SetOnFinished( onfinished)
	inst.components.finiteuses:SetConsumption(ACTIONS.PAN, 1)
	-------
	inst:AddComponent("inspectable")
	-------
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

return Prefab( "common/inventory/goldpan", normal, assets)
