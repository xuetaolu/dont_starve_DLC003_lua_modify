local assets=
{
	Asset("ANIM", "anim/permit_demolition.zip"),
}

local function makefn(inst)
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)   

    inst.AnimState:SetBank("permit_demolition")
    inst.AnimState:SetBuild("permit_demolition")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/jewlery"
    
    inst:AddComponent("roomdemolisher")

    MakeInventoryFloatable(inst, "idle_water", "idle")

    return inst
end

return Prefab( "common/inventory/demolition_permit", makefn, assets)