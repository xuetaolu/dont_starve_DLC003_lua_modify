local assets = {}
local prefabs = {"flup"}

local function spawntestfn(inst, ground, x, y, z)
	return inst:IsPosSurroundedByWater(x, y, z, 1)
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()

	inst:AddTag("NOBLOCK")
	
	inst:AddComponent("areaspawner")
	inst.components.areaspawner:SetValidTileType(GROUND.TIDALMARSH)
	inst.components.areaspawner:SetPrefab("flup")
	inst.components.areaspawner:SetDensityInRange(40, 5)
	inst.components.areaspawner:SetMinimumSpacing(10)
	inst.components.areaspawner:SetSpawnTestFn(spawntestfn)
	inst.components.areaspawner:SetRandomTimes(TUNING.TOTAL_DAY_TIME * 3, TUNING.TOTAL_DAY_TIME)
	inst.components.areaspawner:Start()

	return inst
end

local function dense_fn()
	local inst = fn()

	inst.components.areaspawner:SetDensityInRange(40, 10)

	return inst
end

local function sparse_fn()
	local inst = fn()

	inst.components.areaspawner:SetDensityInRange(40, 2)

	return inst
end

return Prefab("flupspawner", fn, assets, prefabs),
Prefab("flupspawner_dense", dense_fn, assets, prefabs),
Prefab("flupspawner_sparse", sparse_fn, assets, prefabs)
