local assets=
{
	Asset("ANIM", "anim/deerclops_eyeball.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    inst.AnimState:SetBank("deerclops_eyeball")
    inst.AnimState:SetBuild("deerclops_eyeball")
    inst.AnimState:PlayAnimation("idle")
    MakeInventoryPhysics(inst)

    MakeInventoryFloatable(inst, "idle_water", "idle")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("edible")
    inst.components.edible.foodtype = "MEAT"
    inst.components.edible.healthvalue = TUNING.HEALING_HUGE
    inst.components.edible.hungervalue = TUNING.CALORIES_HUGE
    inst.components.edible.sanityvalue = -TUNING.SANITY_MED

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

    return inst
end

return Prefab( "common/inventory/deerclops_eyeball", fn, assets) 
