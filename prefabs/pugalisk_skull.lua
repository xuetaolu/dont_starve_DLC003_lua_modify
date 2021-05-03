local assets=
{
	Asset("ANIM", "anim/snake_skull.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	
	inst:AddTag("pugalisk_skull")
    
    inst.AnimState:SetBank("snake_skull")
    inst.AnimState:SetBuild("snake_skull")
    inst.AnimState:PlayAnimation("idle")
    MakeInventoryPhysics(inst)

    MakeInventoryFloatable(inst, "idle_water", "idle")
    
    inst:AddComponent("inspectable")    
    
    inst:AddComponent("inventoryitem")

    return inst
end

return Prefab( "common/inventory/pugalisk_skull", fn, assets) 
