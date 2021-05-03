local assets=
{
	Asset("ANIM", "anim/fabric.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    inst.AnimState:SetBank("fabric")
    inst.AnimState:SetBuild("fabric")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.LIGHT, TUNING.WINDBLOWN_SCALE_MAX.LIGHT)
    
    inst:AddComponent("stackable")

    inst:AddComponent("inspectable")
    
	MakeSmallBurnable(inst, TUNING.LARGE_BURNTIME)
    MakeSmallPropagator(inst)
    inst.components.burnable:MakeDragonflyBait(3)
    
    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL

    inst:AddComponent("appeasement")
    inst.components.appeasement.appeasementvalue = TUNING.WRATH_SMALL
    
    inst:AddTag("cattoy")
    inst:AddComponent("tradable")
    
    inst:AddComponent("inventoryitem")
    
    return inst
end

return Prefab( "common/inventory/fabric", fn, assets) 
