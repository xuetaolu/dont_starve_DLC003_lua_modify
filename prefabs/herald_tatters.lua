local assets =
{
	Asset("ANIM", "anim/ancient_remnant.zip"),
    Asset("INV_IMAGE", "ancient_remnant"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.LIGHT, TUNING.WINDBLOWN_SCALE_MAX.LIGHT)

    inst.AnimState:SetBank("ancient_remnant")
    inst.AnimState:SetBuild("ancient_remnant")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

    inst:AddTag("cattoy")

    inst:AddComponent("inspectable")

    inst:AddComponent("appeasement")
    inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_LARGE
    
    inst:AddComponent("inventoryitem")

    return inst
end

return Prefab( "common/inventory/ancient_remnant", fn, assets)

