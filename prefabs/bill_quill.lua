local assets=
{
	Asset("ANIM", "anim/bill_quill.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	
	inst:AddTag("billquill")
    
    inst.AnimState:SetBank("bill_quill")
    inst.AnimState:SetBuild("bill_quill")
    inst.AnimState:PlayAnimation("idle")
    MakeInventoryPhysics(inst)

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    MakeInventoryFloatable(inst, "idle_water", "idle")
    
    inst:AddComponent("inspectable")    
    
    inst:AddComponent("inventoryitem")
    
    return inst
end

return Prefab( "common/inventory/bill_quill", fn, assets) 
