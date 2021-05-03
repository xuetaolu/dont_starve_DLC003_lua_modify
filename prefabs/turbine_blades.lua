local assets=
{
	Asset("ANIM", "anim/blades.zip"),
}

local function fn()
	local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")
    
    inst.AnimState:SetBank("blades")
    inst.AnimState:SetBuild("blades")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

	return inst
end

return Prefab("objects/turbine_blades", fn, assets)