local assets = {}

local prefabs = {}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()  
    return inst
end

-- This is a dummy prefab used to mark the point/home in the world
-- where the bandit will return to with his coins/oincs to escape.
return Prefab("common/inventory/pigbanditexit", fn, assets, prefabs)
