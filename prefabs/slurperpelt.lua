local assets=
{
	Asset("ANIM", "anim/slurper_pelt.zip"),
    Asset("INV_IMAGE", "slurper_pelt"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    inst.AnimState:SetBank("slurper_pelt")
    inst.AnimState:SetBuild("slurper_pelt")
    inst.AnimState:PlayAnimation("idle")
    MakeInventoryPhysics(inst)
    
    inst:AddComponent("inventoryitem")

    MakeInventoryFloatable(inst, "idle_water", "idle")
    
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
    
    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)
    
    inst:AddComponent("tradable")    
    inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
    
    
    inst:AddComponent("edible")
    inst.components.edible.foodtype = "HORRIBLE"

    return inst
end

return Prefab( "common/inventory/slurper_pelt", fn, assets) 
