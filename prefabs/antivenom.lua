local assets =
{
	Asset("ANIM", "anim/poison_antidote.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "idle_water", "idle")
	
	inst.AnimState:SetBank("poison_antidote")
	inst.AnimState:SetBuild("poison_antidote")
	inst.AnimState:PlayAnimation("idle")
	
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("inspectable")
	
	inst:AddComponent("inventoryitem")

	inst:AddComponent("poisonhealer")
	
	return inst
end

return Prefab( "common/inventory/antivenom", fn, assets) 

