require "prefabutil"

local assets = {}
local prefabs = {}

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	--inst:AddComponent("batcavemanager")     
    return inst
end

return Prefab( "common/objects/batcavemanager", fn, assets, prefabs ) 
