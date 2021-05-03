local assets =
{
	Asset("ANIM", "anim/cutgrass.zip"),
    Asset("ANIM", "anim/cutgrassgreen.zip"),
    Asset("INV_IMAGE", "cutgrass_green"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.LIGHT, TUNING.WINDBLOWN_SCALE_MAX.LIGHT)

    if SaveGameIndex:IsModeShipwrecked() then
        inst.AnimState:SetBank("cutgrass")
        inst.AnimState:SetBuild("cutgrassgreen")
    else
        inst.AnimState:SetBank("cutgrass")
        inst.AnimState:SetBuild("cutgrass")
    end
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("edible")
    inst.components.edible.foodtype = "ROUGHAGE"
    inst.components.edible.woodiness = 1

    inst:AddTag("cattoy")
    inst:AddComponent("tradable")

    inst:AddComponent("inspectable")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    inst:AddComponent("appeasement")
    inst.components.appeasement.appeasementvalue = TUNING.WRATH_SMALL
    
	MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    inst.components.burnable:MakeDragonflyBait(3)
    
	inst:AddComponent("repairer")
	inst.components.repairer.repairmaterial = "hay"
	inst.components.repairer.healthrepairvalue = TUNING.REPAIR_CUTGRASS_HEALTH
    
    inst:AddComponent("inventoryitem")

    return inst
end

return Prefab( "common/inventory/cutgrass", fn, assets)

