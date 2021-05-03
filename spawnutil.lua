
function GetShortestDistToPrefab(x, y, ents, prefab)
	local w, h = WorldSim:GetWorldSize()
	local halfw, halfh = w / 2, h / 2
	local dist = 100000
	if ents ~= nil and ents[prefab] ~= nil then
		for i,spawn in ipairs(ents[prefab]) do
			local sx, sy = spawn.x, spawn.z
			local dx, dy = (x - halfw)*TILE_SCALE - sx, (y - halfh)*TILE_SCALE - sy
			local d = math.sqrt(dx * dx + dy * dy)
			if d < dist then
				dist = d
			end
			--print(string.format("GetShortestDistToPrefab (%d, %d) -> (%d, %d) = %d", x, y, sx, sy, dist))
		end
	end
	return dist
end

function GetDistToSpawnPoint(x, y, ents)
	return GetShortestDistToPrefab(x, y, ents, "spawnpoint")
end

function GetDistFromEdge(x, y, w, h)
	local distx = math.min(x, w - x)
	local disty = math.min(y, h - y)
	local dist = math.min(distx, disty)
	--print(string.format("GetDistanceFromEdge (%d, %d), (%d, %d) = %d\n", x, y, w, h, dist))
	return dist
end

function IsSurroundedByWater(x, y, radius)
	for i = -radius, radius, 1 do
		if not WorldSim:IsWater(WorldSim:GetTile(x - radius, y + i)) or not WorldSim:IsWater(WorldSim:GetTile(x + radius, y + i)) then
			return false
		end
	end
	for i = -(radius - 1), radius - 1, 1 do
		if not WorldSim:IsWater(WorldSim:GetTile(x + i, y - radius)) or not WorldSim:IsWater(WorldSim:GetTile(x + i, y + radius)) then
			return false
		end
	end
	return true
end

local function isWaterOrInvalid(ground)
	return WorldSim:IsWater(ground) or ground == GROUND.INVALID
end

function IsSurroundedByWaterOrInvalid(x, y, radius)
	for i = -radius, radius, 1 do
		if not isWaterOrInvalid(WorldSim:GetTile(x - radius, y + i)) or not isWaterOrInvalid(WorldSim:GetTile(x + radius, y + i)) then
			return false
		end
	end
	for i = -(radius - 1), radius - 1, 1 do
		if not isWaterOrInvalid(WorldSim:GetTile(x + i, y - radius)) or not isWaterOrInvalid(WorldSim:GetTile(x + i, y + radius)) then
			return false
		end
	end
	return true
end

function IsCloseToWater(x, y, radius)
	for i = -radius, radius, 1 do
		if WorldSim:IsWater(WorldSim:GetTile(x - radius, y + i)) or WorldSim:IsWater(WorldSim:GetTile(x + radius, y + i)) then
			return true
		end
	end
	for i = -(radius - 1), radius - 1, 1 do
		if WorldSim:IsWater(WorldSim:GetTile(x + i, y - radius)) or WorldSim:IsWater(WorldSim:GetTile(x + i, y + radius)) then
			return true
		end
	end
	return false
end

function IsCloseToLand(x, y, radius)
	for i = -radius, radius, 1 do
		if WorldSim:IsLand(WorldSim:GetTile(x - radius, y + i)) or WorldSim:IsLand(WorldSim:GetTile(x + radius, y + i)) then
			return true
		end
	end
	for i = -(radius - 1), radius - 1, 1 do
		if WorldSim:IsLand(WorldSim:GetTile(x + i, y - radius)) or WorldSim:IsLand(WorldSim:GetTile(x + i, y + radius)) then
			return true
		end
	end
	return false
end

function IsCloseToTileType(x, y, radius, tile)
	for i = -radius, radius, 1 do
		if WorldSim:GetTile(x - radius, y + i) == tile or WorldSim:GetTile(x + radius, y + i) == tile then
			return true
		end
	end
	for i = -(radius - 1), radius - 1, 1 do
		if WorldSim:GetTile(x + i, y - radius) == tile or WorldSim:GetTile(x + i, y + radius) == tile then
			return true
		end
	end
	return false
end

local commonspawnfn = {
	spiderden = function(x, y, ents)
		return not IsCloseToWater(x, y, 5) and GetDistToSpawnPoint(x, y, ents) >= 100
	end,
	fishinhole = function(x, y, ents)
		local tile = WorldSim:GetTile(x, y)
		return (tile == GROUND.OCEAN_CORAL or tile == GROUND.MANGROVE or (WorldSim:IsWater(tile) and not IsCloseToTileType(x, y, 5, GROUND.OCEAN_SHALLOW))) and IsSurroundedByWater(x, y, 1)
	end,
	tidalpool = function(x, y, ents)
		return not IsCloseToWater(x, y, 2) and GetShortestDistToPrefab(x, y, ents, "tidalpool") >= 3 * TILE_SCALE
	end,

	seashell_beached = function(x, y, ents)
		return (not IsCloseToWater(x, y, 1)) and IsCloseToWater(x,y,4)
	end,
	mangrovetree = function(x, y, ents)
		return WorldSim:GetTile(x, y) == GROUND.MANGROVE and IsSurroundedByWater(x, y, 1)
	end,
	grass_water = function(x, y, ents)
		return WorldSim:GetTile(x, y) == GROUND.MANGROVE and IsSurroundedByWater(x, y, 1)
	end,
	
}

local function surroundedbywater(x, y, ents)
	return IsSurroundedByWater(x, y, 1)
end

local function notclosetowater(x, y, ents)
	return not IsCloseToWater(x, y, 1)
end


local waterprefabs =
{
	"coralreef", "seaweed_planted", "mussel_farm", "lobsterhole", "messagebottle", "messagebottleempty", "wreck"
}

local landprefabs =
{
	"jungletree", "palmtree", "bush_vine", "limpetrock", "sandhill", "sapling", "poisonhole",
	"wildborehouse", "mermhouse", "magmarock", "magmarock_gold", "flower", "fireflies", "grass",
	"bambootree", "berrybush", "berrybush_snake", "berrybush2", "berrybush2_snake", "crabhole", "rock1", "rock2",
	"rock_flintless", "rocks", "flint", "goldnugget", "gravestone", "mound", "red_mushroom", "blue_mushroom",
	"green_mushroom", "carrot_planted", "beehive", "reeds", "marsh_tree", "snakeden", "pond", "primeapebarrel",
	"mandrake", "mermhouse_fisher", "sweet_potato_planted", "flup", "flupspawner_sparse", "wasphive",
	"beachresurrector", "flower_evil", "crate", "tallbirdnest"
}


for i = 1, #waterprefabs, 1 do
	assert(commonspawnfn[waterprefabs[i]] == nil) --don't replace an existing one
	commonspawnfn[waterprefabs[i]] = surroundedbywater
end

for i = 1, #landprefabs, 1 do
	assert(commonspawnfn[landprefabs[i]] == nil) --don't replace an existing one
	commonspawnfn[landprefabs[i]] = notclosetowater
end


function GetCommonSpawnFn(prefab, x, y, ents)
	return prefab ~= nil and (commonspawnfn[prefab] == nil or commonspawnfn[prefab](x, y, ents))
end

function GetLayoutRadius(layout, prefabs)
	assert(layout ~= nil)
	assert(prefabs ~= nil)

	local extents = {xmin = 1000000, ymin = 1000000, xmax = -1000000, ymax = -1000000}
	for i = 1, #prefabs, 1 do
		--print(string.format("Prefab %s (%4.2f, %4.2f)", tostring(prefabs[i].prefab), prefabs[i].x, prefabs[i].y))
		if prefabs[i].x < extents.xmin then extents.xmin = prefabs[i].x end
		if prefabs[i].x > extents.xmax then extents.xmax = prefabs[i].x end
		if prefabs[i].y < extents.ymin then extents.ymin = prefabs[i].y end
		if prefabs[i].y > extents.ymax then extents.ymax = prefabs[i].y end
	end

	local e_width, e_height = extents.xmax - extents.xmin, extents.ymax - extents.ymin
	local size = math.ceil(layout.scale * math.max(e_width, e_height))

	if layout.ground then
		size = math.max(size, #layout.ground)
	end

	--print(string.format("Layout %s dims (%4.2f x %4.2f), size %4.2f", layout.name, e_width, e_height, size))

	return size
end

function SpawnWaves(inst, numWaves, totalAngle, waveSpeed, wavePrefab, initialOffset, idleTime, instantActive, random_angle)
	wavePrefab = wavePrefab or "rogue_wave"
	totalAngle = math.clamp(totalAngle, 1, 360)

    local pos = inst:GetPosition()
    local startAngle = (random_angle and math.random(-180, 180)) or inst.Transform:GetRotation()
    local anglePerWave = totalAngle/(numWaves - 1)

	if totalAngle == 360 then
		anglePerWave = totalAngle/numWaves
	end

    --[[
    local debug_offset = Vector3(2 * math.cos(startAngle*DEGREES), 0, -2 * math.sin(startAngle*DEGREES)):Normalize()
    inst.components.debugger:SetOrigin("debugy", pos.x, pos.z)
    local debugpos = pos + (debug_offset * 2)
    inst.components.debugger:SetTarget("debugy", debugpos.x, debugpos.z)
    inst.components.debugger:SetColour("debugy", 1, 0, 0, 1)
	--]]

    for i = 0, numWaves - 1 do
        local wave = SpawnPrefab(wavePrefab)

        local angle = (startAngle - (totalAngle/2)) + (i * anglePerWave)
        local rad = initialOffset or (inst.Physics and inst.Physics:GetRadius()) or 0.0
        local total_rad = rad + wave.Physics:GetRadius() + 0.1
        local offset = Vector3(math.cos(angle*DEGREES),0, -math.sin(angle*DEGREES)):Normalize()
        local wavepos = pos + (offset * total_rad)

        if inst:GetIsOnWater(wavepos:Get()) then
	        wave.Transform:SetPosition(wavepos:Get())

	        local speed = waveSpeed or 6
	        wave.Transform:SetRotation(angle)
	        wave.Physics:SetMotorVel(speed, 0, 0)
	        wave.idle_time = idleTime or 5

	        if instantActive then
	        	wave.sg:GoToState("idle")
	        end

	        if wave.soundtidal then
	        	wave.SoundEmitter:PlaySound("dontstarve_DLC002/common/rogue_waves/"..wave.soundtidal)
	        end
        else
        	wave:Remove()
        end
    end
end
