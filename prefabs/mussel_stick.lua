local assets =
{
	Asset("ANIM", "anim/musselfarm_stick.zip"),
}

local prefabs =
{
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

	MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "idle_water", "idle")

	inst.no_wet_prefix = true
	
	inst.AnimState:SetBuild("musselFarm_stick")
	inst.AnimState:SetBank("musselFarm_stick")
	inst.AnimState:PlayAnimation("idle")
	

	inst:AddComponent("sticker")
	inst:AddComponent("inspectable")

	inst:AddComponent("stackable")
	
	inst:AddComponent("inventoryitem")
	
	return inst
end

return Prefab( "common/inventory/mussel_stick", fn, assets, prefabs) 

