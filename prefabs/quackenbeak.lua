local assets=
{
    Asset("ANIM", "anim/quackenbeak.zip")
}

local function fn(Sim)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")

    inst:AddComponent("inventoryitem")

    inst.AnimState:SetBuild("quackenbeak")
    inst.AnimState:SetBank("quackenbeak")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("inspectable")
    inst:AddComponent("waterproofer")

    return inst
end

return Prefab( "common/inventory/quackenbeak", fn, assets)
