local assets = {}

local prefabs = 
{
	"swordfish",
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()

	inst:AddComponent( "childspawner" )
	inst.components.childspawner:SetRegenPeriod(60)
	inst.components.childspawner:SetSpawnPeriod(55)
	inst.components.childspawner:SetMaxChildren(1)
	inst.components.childspawner.childname = "swordfish"
	inst.components.childspawner.spawnoffscreen = true

	inst.components.childspawner:StartSpawning()

    return inst
end

return Prefab( "common/swordfish_spawner", fn, assets, prefabs) 
