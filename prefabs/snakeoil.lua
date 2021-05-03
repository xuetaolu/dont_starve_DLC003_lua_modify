local assets=
{
	Asset("ANIM", "anim/snakeoil.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst)
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.HEAVY, TUNING.WINDBLOWN_SCALE_MAX.HEAVY)

    inst.AnimState:SetBank("snakeoil")
    inst.AnimState:SetBuild("snakeoil")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = 0

    inst:AddComponent("poisonhealer")
    inst.components.poisonhealer.enabled = false

    return inst
end

return Prefab( "common/inventory/snakeoil", fn, assets)