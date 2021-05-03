local assets=
{
	Asset("ANIM", "anim/charcoal.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.LIGHT, TUNING.WINDBLOWN_SCALE_MAX.LIGHT)

    inst.AnimState:SetBank("charcoal")
    inst.AnimState:SetBuild("charcoal")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    
    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL

    inst:AddComponent("appeasement")
    inst.components.appeasement.appeasementvalue = TUNING.WRATH_SMALL
    
    
	MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
    MakeSmallPropagator(inst)
    inst.components.burnable:MakeDragonflyBait(3)

    ---------------------       
    
    inst:AddComponent("bait")
    inst:AddTag("molebait")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
   
    return inst
end

return Prefab( "common/inventory/charcoal", fn, assets) 

