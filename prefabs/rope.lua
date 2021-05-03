local assets=
{
	Asset("ANIM", "anim/rope.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    inst.AnimState:SetBank("rope")
    inst.AnimState:SetBuild("rope")
    inst.AnimState:PlayAnimation("idle")
    MakeInventoryPhysics(inst)
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.MEDIUM, TUNING.WINDBLOWN_SCALE_MAX.MEDIUM)
    MakeInventoryFloatable(inst, "idle_water", "idle")


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

return Prefab( "common/inventory/rope", fn, assets) 
