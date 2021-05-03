local assets=
{
	Asset("ANIM", "anim/dorsalfin.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

    inst.AnimState:SetBank("dorsalfin")
    inst.AnimState:SetBuild("dorsalfin")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")

    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
	inst:AddComponent("waterproofer")

	MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)


	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT

    inst:AddComponent("inventoryitem")

    inst:AddComponent("edible")
    inst.components.edible.foodtype = "HORRIBLE"


    return inst
end

return Prefab( "common/inventory/dorsalfin", fn, assets)
