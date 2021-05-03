local assets=
{
	Asset("ANIM", "anim/shark_gills.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	
	MakeInventoryFloatable(inst, "idle_water", "idle")
	
	inst.AnimState:SetBank("shark_gills")
	inst.AnimState:SetBuild("shark_gills")
	inst.AnimState:PlayAnimation("idle")
	MakeInventoryPhysics(inst)
	
	inst:AddComponent("inspectable")
	
	inst:AddComponent("inventoryitem")

	inst:AddComponent("appeasement")
	inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_LARGE

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

	return inst
end

return Prefab( "common/inventory/shark_gills", fn, assets) 
