local assets =
{
    Asset("ANIM", "anim/weevole_carapace.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("weevole_carapace")
    inst.AnimState:SetBuild("weevole_carapace")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    return inst
end

return Prefab("weevole_carapace", fn, assets)
