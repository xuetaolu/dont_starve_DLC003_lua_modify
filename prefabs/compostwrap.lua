local assets =
{
	Asset("ANIM", "anim/healing_cream.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")
    
    inst.AnimState:SetBank("healing_cream")
    inst.AnimState:SetBuild("healing_cream")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("heal_fertilize")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("healer")
    inst.components.healer:SetHealthAmount(TUNING.HEALING_MEDLARGE)
    
    return inst
end

return Prefab( "common/inventory/compostwrap", fn, assets) 

