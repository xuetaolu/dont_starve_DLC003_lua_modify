local assets =
{
    Asset("ANIM", "anim/cutnettle.zip"),
    Asset("INV_IMAGE", "cutnettle"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.LIGHT, TUNING.WINDBLOWN_SCALE_MAX.LIGHT)

    inst.AnimState:SetBank("cutnettle")
    inst.AnimState:SetBuild("cutnettle")

    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM    

    inst:AddComponent("edible")
    inst.components.edible.foodtype = "VEGGIE"
    inst.components.edible.antihistamine = 200

    inst:AddTag("cattoy")
    inst:AddComponent("tradable")

    inst:AddComponent("inspectable")

    inst:AddComponent("appeasement")
    inst.components.appeasement.appeasementvalue = TUNING.WRATH_SMALL
    
	MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    inst.components.burnable:MakeDragonflyBait(3)


    inst:AddComponent("inventoryitem")
    --inst.components.inventoryitem:ChangeImageName("cutnettle")
    return inst
end

return Prefab( "common/inventory/cutnettle", fn, assets)

