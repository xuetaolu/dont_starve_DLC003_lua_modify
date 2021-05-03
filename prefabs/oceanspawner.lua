
local tiles =
{
	GROUND.OCEAN_SHALLOW,
	GROUND.OCEAN_MEDIUM,
	GROUND.OCEAN_DEEP
}

local prefabs = 
{
	"seaweed_planted",
	"jellyfish_planted",
	"log",
	"twigs",
	"cutgrass",
	"coconut",
	"bamboo",
}

local function OnSave(inst, data)
	if inst and data then
		data.prefab = inst.components.areaspawner.prefab
	end
end

local function OnLoad(inst, data)
	if inst and data then
		inst.components.areaspawner:SetPrefab(data.prefab)
		if data.phase then
			inst.components.areaspawner:SetSpawnPhase(data.phase)
		end
		if data.range or data.density then
			inst.components.areaspawner:SetDensityInRange(data.range, data.density)
		end
		if data.basetime or data.randtime then
			inst.components.areaspawner:SetRandomTimes(data.basetime, data.randtime)
		end
	end
end

local function OnEntitySleep(inst)
	inst.components.areaspawner:Stop()
end

local function OnEntityWake(inst)
	inst.components.areaspawner:Start()
end

local function OnSpawn(inst, newent, ground)
	if newent and newent.components and newent.components.OnHitGround then
		newent.components.OnHitGround()
	end
end

local function OnSeasonChange(inst)
	local t = inst.normal
	local sm = GetSeasonManager()
	if sm:IsGreenSeason() then
		t = inst.green
	end
	inst.components.areaspawner:SetRandomTimes(t.basetime, t.randtime)
	inst.components.areaspawner:SetDensityInRange(t.range, t.density)
end

local function commonfn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "obelisk.png" )

	inst:AddTag("NOCLICK")

	inst.OnSave = OnSave
	inst.OnLoad = OnLoad
	inst.OnLoadPostPass = function(inst, ents, data) OnSeasonChange(inst) end
	inst.OnEntitySleep = OnEntitySleep
	inst.OnEntityWake = OnEntityWake

	inst.normal =
	{
		range = 20,
		density = 10,
		basetime = 30,
		randtime = 10
	}
	inst.green =
	{
		range = 20,
		density = 20,
		basetime = 15,
		randtime = 5
	}

	inst:AddComponent("areaspawner")
	inst.components.areaspawner:SetValidTileType(tiles)
	inst.components.areaspawner:SetOnSpawnFn(OnSpawn)
	OnSeasonChange(inst)

	inst:ListenForEvent("seasonChange", function() OnSeasonChange(inst) end, GetWorld())

	return inst
end

local function GetPrefab()
	return prefabs[math.random(1, #prefabs)]
end

local function manyfn(Sim)
	local inst = commonfn(Sim)
	inst.components.areaspawner:SetPrefabFn(GetPrefab)
	return inst
end

local function MakeOceanSpawnerEx(spawnername, prefabname)
	local function fn(Sim)
		local inst = commonfn(Sim)
		inst.components.areaspawner:SetPrefab(prefabname)
		return inst
	end
	return Prefab("shipwrecked/objects/" .. spawnername, fn, nil, {prefabname})
end

local function MakeOceanSpawner(prefabname)
	return MakeOceanSpawnerEx("oceanspawner_"..prefabname, prefabname)
end

return MakeOceanSpawnerEx("oceanspawner", nil),
	MakeOceanSpawner("seaweed_planted"),
	MakeOceanSpawner("log"),
	MakeOceanSpawner("twigs"),
	MakeOceanSpawner("cutgrass"),
	MakeOceanSpawner("coconut"),
	MakeOceanSpawner("bamboo"),
	Prefab("shipwrecked/objects/oceanspawner_many", manyfn, nil, prefabs)
