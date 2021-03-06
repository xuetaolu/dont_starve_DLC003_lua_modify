local assets=
{
	Asset("ANIM", "anim/goose_feather.zip"),
}

local function fn()
	local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.LIGHT, TUNING.WINDBLOWN_SCALE_MAX.LIGHT)

    inst.AnimState:SetBank("goose_feather")
    inst.AnimState:SetBuild("goose_feather")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "idle_water", "idle")

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM


	return inst
end

return Prefab("objects/goose_feather", fn, assets)