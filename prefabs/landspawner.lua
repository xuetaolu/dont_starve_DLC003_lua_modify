
local oceantiles =
{
	GROUND.OCEAN_SHALLOW,
	GROUND.OCEAN_MEDIUM,
	GROUND.OCEAN_DEEP
}

local landtiles = 
{
	GROUND.BEACH,
	GROUND.JUNGLE,
	GROUND.SWAMP,
	GROUND.VOLCANO,
}
	-- GROUND.FLOOD,
	-- GROUND.VOLCANO_LAVA,

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
	if not inst.components.areaspawner:IsSpawnOffscreen() then
		inst.components.areaspawner:Stop()
	end
end

local function OnEntityWake(inst)
	if not inst.components.areaspawner:IsSpawnOffscreen() then
		inst.components.areaspawner:Start()
	end
end

local function OnSpawn(inst, newent, ground)
	if newent.components.inventoryitem then 
		newent.components.inventoryitem:OnHitGround()
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

--[[
local function GetSpawnPoint(inst, home)
	local rad = 25
	local x,y,z = inst.Transform:GetWorldPosition()
	local nearby_ents = TheSim:FindEntities(x,y,z, rad, {'flower'})
	local mindistance = 36
	local validflowers = {}
	for k,flower in ipairs(nearby_ents) do
		if flower and
		inst:GetDistanceSqToInst(flower) > mindistance then
			table.insert(validflowers, flower)			
		end
	end

	if #validflowers > 0 then
		local f = validflowers[math.random(1, #validflowers)]
		return f
	else
		return nil
	end
end
]]

local function commonfn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()

	--local minimap = inst.entity:AddMiniMapEntity()
	--minimap:SetIcon( "obelisk.png" )

	inst:AddTag("NOCLICK")

	inst.OnSave = OnSave
	inst.OnLoad = OnLoad
	inst.OnLoadPostPass = function(inst, ents, data) OnSeasonChange(inst) end
	inst.OnEntitySleep = OnEntitySleep
	inst.OnEntityWake = OnEntityWake

	inst:AddComponent("areaspawner")
	inst.components.areaspawner:SetOnSpawnFn(OnSpawn)

	inst:ListenForEvent("seasonChange", function() OnSeasonChange(inst) end, GetWorld())

	return inst
end

local function seashellspawntest(inst, ground, x, y, z)
	--don't spawn close to stuff
	local ents = TheSim:FindEntities(x, y, z, 2, nil, {"FX", "NOCLICK", "DECOR", "INLIMBO"})
	return ents == nil or GetTableSize(ents) == 0
end

local function seashellfn(Sim)
	local inst = commonfn(Sim)

	inst.normal =
	{
		range = 20,
		density = 5,
		basetime = 8*TUNING.SEG_TIME,
		randtime = 2*TUNING.SEG_TIME
	}
	inst.green =
	{
		range = 20,
		density = 8,
		basetime = 4*TUNING.SEG_TIME,
		randtime = 1*TUNING.SEG_TIME
	}

	inst.components.areaspawner:SetPrefab("seashell_beached")
	inst.components.areaspawner:SetValidTileType(GROUND.BEACH)
	inst.components.areaspawner:SetSpawnTestFn(seashellspawntest)
	inst.components.areaspawner:SetOnlySpawnOffscreen(true)
	inst.components.areaspawner:Start()
	OnSeasonChange(inst)
	return inst
end

local function MakeLandSpawnerEx(spawnername, prefabname, home)
	local function fn(Sim)
		local inst = CreateEntity()

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

		inst.components.areaspawner:SetPrefab(prefabname)
		inst.components.areaspawner:SetValidTileType(home)
		OnSeasonChange(inst)
		return inst
	end

	return Prefab("shipwrecked/objects/" .. spawnername, fn)
end

local function MakeLandSpawner(prefabname, home)
	return MakeLandSpawnerEx("landspawner_"..prefabname, prefabname, home)
end

return MakeLandSpawner("parrot", landtiles),
	Prefab("shipwrecked/objects/landspawner_seashell_beached", seashellfn)
