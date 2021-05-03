

local prefabs = 
{
	"jellyfish_planted",
}

local function initspawn(inst, n)
	local x, y, z = inst.Transform:GetWorldPosition()
	for i = 1, n, 1 do
		local angle = 2 * PI * math.random()
		local rad = math.random(1, 30) * TILE_SCALE
		local dx, dy, dz = x + rad * math.cos(angle), y, z + rad * math.sin(angle)
		local ent = SpawnPrefab(inst.components.childspawner.childname)
		if ent:IsPosSurroundedByWater(dx, dy, dz, 1) then
			ent.Transform:SetPosition(dx, dy, dz)
		else
			ent.Transform:SetPosition(x, y, z)
		end
		inst.components.childspawner:TakeOwnership(ent)
	end
end

local function loadpostpass(inst, ents, data)
	if inst.components.childspawner.childreninside > 0  then
		initspawn(inst, inst.components.childspawner.childreninside)
		inst.components.childspawner.childreninside = 0
	end
	inst.components.childspawner:StartSpawning()
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()

	inst:AddTag("NOCLICK")

	inst:AddComponent( "childspawner" )
	inst.components.childspawner.childname = "jellyfish_planted"
	inst.components.childspawner.spawnoffscreen = true
	inst.components.childspawner:SetRegenPeriod(60)
	inst.components.childspawner:SetSpawnPeriod(.1)	
	inst.components.childspawner:SetMaxChildren(5)

	inst.OnLoadPostPass = loadpostpass

    return inst
end

return Prefab( "common/jellyfish_spawner", fn, nil, prefabs)
