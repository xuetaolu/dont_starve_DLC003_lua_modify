local assets=
{
	Asset("ANIM", "anim/woodlegs_key.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	
	MakeInventoryPhysics(inst)

	local minimap = inst.entity:AddMiniMapEntity()

	inst.AnimState:SetBank("woodlegs_key")
	inst.AnimState:SetBuild("woodlegs_key")
	
	---------------------       

	inst:AddTag("woodlegs_key")
	
	inst:AddComponent("inspectable")	
	inst:AddComponent("inventoryitem")
	inst:AddComponent("tradable")

	return inst
end

local function key1fn(Sim)
	local inst = fn(Sim)
	
	MakeInventoryFloatable(inst, "key1_water", "key1")
	inst.AnimState:PlayAnimation("key1")

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("woodlegs_key1.png")
	inst:AddTag("woodlegs_key1")

	return inst
end

local function key2fn(Sim)
	local inst = fn(Sim)
	
	MakeInventoryFloatable(inst, "key2_water", "key2")
	inst.AnimState:PlayAnimation("key2")

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("woodlegs_key2.png")
	inst:AddTag("woodlegs_key2")

	return inst
end

local function key3fn(Sim)
	local inst = fn(Sim)
	
	MakeInventoryFloatable(inst, "key3_water", "key3")
	inst.AnimState:PlayAnimation("key3")

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("woodlegs_key3.png")

	inst:AddTag("woodlegs_key3")

	return inst
end

return Prefab( "common/inventory/woodlegs_key1", key1fn, assets),
	   Prefab( "common/inventory/woodlegs_key2", key2fn, assets),
	   Prefab( "common/inventory/woodlegs_key3", key3fn, assets)
