local assets=
{
	Asset("ANIM", "anim/nightmarefuel.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_loop_water", "idle_loop")
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.LIGHT, TUNING.WINDBLOWN_SCALE_MAX.LIGHT)
    
    inst.AnimState:SetBank("nightmarefuel")
    inst.AnimState:SetBuild("nightmarefuel")
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:SetMultColour(1, 1, 1, 0.5)
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM    
    inst:AddComponent("inspectable")
    inst:AddComponent("tradable")
    inst:AddComponent("fuel")
    inst.components.fuel.fueltype = "NIGHTMARE"
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL

    inst:AddComponent("inventoryitem")

    inst:AddComponent("appeasement")
    inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_SMALL
    
	return inst
end

return Prefab( "common/inventory/nightmarefuel", fn, assets) 
