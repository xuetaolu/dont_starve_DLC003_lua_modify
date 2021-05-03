local assets=
{
	Asset("ANIM", "anim/permit_reno.zip"),
}

local function makefn(inst)
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)   

    inst.AnimState:SetBank("permit_reno")
    inst.AnimState:SetBuild("permit_reno")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/jewlery"
    
    inst:AddComponent("roombuilder")

    MakeInventoryFloatable(inst, "idle_water", "idle")

    return inst
end

return Prefab( "common/inventory/construction_permit", makefn, assets)