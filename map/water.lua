require "constants"
require "spawnutil"
require "mathutil"

local function is_waterlined(ground)
	return WorldSim:IsLand(ground) or ground == GROUND.OCEAN_CORAL or ground == GROUND.MANGROVE
end

local function fillGroundType(width, height, x, y, offset, depth, ground)
	if depth <= 0 then
		return
	end

	if not (0 <= x and x < width and 0 <= y and y < height) then
		return
	end

	local t = WorldSim:GetTile(x, y)
	if is_waterlined(t) then
		return
	end
	--[[if t ~= GROUND.IMPASSABLE and not (ground == GROUND.OCEAN_SHALLOW and t == GROUND.OCEAN_MEDIUM) then
		return
	end]]

	WorldSim:SetTile(x, y, ground)
	depth = depth - 1

	fillGroundType(width, height, x + offset, y, offset, depth, ground)
	fillGroundType(width, height, x - offset, y, offset, depth, ground)
	fillGroundType(width, height, x, y + offset, offset, depth, ground)
	fillGroundType(width, height, x, y - offset, offset, depth, ground)
end

local function placeGroundType(width, height, x, y, offx, offy, depth, ground)
	local i = 0;
	while i < depth and 0 <= x and x < width and 0 < y and y < height do
		local t = WorldSim:GetTile(x, y)
		if not is_waterlined(t) then --if t == GROUND.IMPASSABLE then
			WorldSim:SetTile(x, y, ground)
			x = x + offx
			y = y + offy
			i = i + 1
		else
			break
		end
	end
	return x, y
end

local function placeFilledGroundType(width, height, x, y, offx, offy, depth, ground, fillOffset, fillDepth)
	local i = 0;
	while i < depth and 0 <= x and x < width and 0 < y and y < height do
		local t = WorldSim:GetTile(x, y)
		if not is_waterlined(t) then --if t == ground then
			fillGroundType(width, height, x + fillOffset, y, fillOffset, fillDepth, ground)
			fillGroundType(width, height, x - fillOffset, y, fillOffset, fillDepth, ground)
			fillGroundType(width, height, x, y + fillOffset, fillOffset, fillDepth, ground)
			fillGroundType(width, height, x, y - fillOffset, fillOffset, fillDepth, ground)
			x = x + offx
			y = y + offy
			i = i + 1
		else
			break
		end
	end
	return x, y
end

local function placeWaterline(width, height, x, y, offx, offy, depthShallow, depthMed)
	x, y = placeGroundType(width, height, x, y, offx, offy, depthShallow, GROUND.OCEAN_SHALLOW)
	x, y = placeGroundType(width, height, x, y, offx, offy, depthMed, GROUND.OCEAN_MEDIUM)
end

local function placeWaterlineFilled(width, height, x, y, offx, offy, depthShallow, depthMed, fillOffset, fillDepth)
	placeWaterline(width, height, x, y, offx, offy, depthShallow, depthMed)
	x, y = placeFilledGroundType(width, height, x, y, offx, offy, depthMed, GROUND.OCEAN_MEDIUM, fillOffset, fillDepth)
	x, y = placeFilledGroundType(width, height, x, y, offx, offy, depthShallow, GROUND.OCEAN_SHALLOW, fillOffset, fillDepth)
end

local function squareFill(width, height, x, y, radius, ground)
	for yy = y - radius, y + radius, 1 do
		for xx = x - radius, x + radius, 1 do
			if 0 <= xx and xx < width and 0 <= yy and yy < height then
				local t = WorldSim:GetTile(xx, yy)
				if not is_waterlined(t) then
					WorldSim:SetTile(xx, yy, ground)
				end
			end
		end
	end
end

local function getEdgeFalloff(x, y, width, height, mindist, maxdist, min, max)
	local distx = math.min(x, width - x)
	local disty = math.min(y, height - y)
	assert(distx >= 0)
	assert(disty >= 0)
	local edgedist = math.min(distx, disty)
	local dist = (edgedist - mindist) / (maxdist - mindist)
	return (max - min) * math.clamp(dist, 0.0, 1.0) + min
end

local function simplexnoise2d(x, y, octaves, persistence)
	local noise = 0
	local amps = 0
	local amp = 1
	local freq = 2
	for i = 0, math.max(octaves-1, 1), 1 do
		noise = noise + amp * perlin(freq * x, freq * y, 0)
		amps = amps + amp
		amp = amp * persistence
		freq = freq * 2
	end
	return noise / amps
end

function ConvertImpassibleToWater0()
	print("Convert impassible to water...")
	local el, elw, elh = WorldSim:GenerateBlendedNoiseMap(15, 2.0, 6, 0.6, 5, 0, 0) --elevation
	local veg, vegw, vegh = WorldSim:GenerateBlendedNoiseMap(15, 2.0, 4, 0.5, 2, 0, 0) --vegetation?
	for y = 0, elh - 1, 1 do
		for x = 0, elw - 1, 1 do
			local falloff = getEdgeFalloff(x, y, elw, elh, TUNING.MAPWRAPPER_LOSECONTROL_RANGE + 2, TUNING.MAPWRAPPER_WARN_RANGE + 4, 0.4/0.56, 1.0)
			local ellevel = el[y * elw + x] * falloff
			local veglevel = veg[y * elw + x] * falloff
			local rocklevel = veg[x * elw + y] * falloff
			--local ellevel = 1.5 * simplexnoise2d(x, y, 6, 0.5) * falloff
			if ellevel > 0.58 then
				if veglevel < 0.41 then
					WorldSim:SetTile(x, y, GROUND.MAGMAFIELD)
				elseif veglevel < 0.43 then
					WorldSim:SetTile(x, y, GROUND.TIDALMARSH)
				else
					WorldSim:SetTile(x, y, GROUND.JUNGLE)
				end
			elseif ellevel > 0.56  then
				WorldSim:SetTile(x, y, GROUND.BEACH)
			elseif ellevel > 0.50  then
				if veglevel > 0.6 then
					WorldSim:SetTile(x, y, GROUND.MANGROVE)
				elseif veglevel < 0.35 then
					WorldSim:SetTile(x, y, GROUND.OCEAN_CORAL)
				else
					WorldSim:SetTile(x, y, GROUND.OCEAN_SHALLOW)
				end
			elseif ellevel > 0.4 then
				WorldSim:SetTile(x, y, GROUND.OCEAN_MEDIUM)
			else
				WorldSim:SetTile(x, y, GROUND.OCEAN_DEEP)
			end
		end
	end
end

function ConvertImpassibleToWater(width, height, data)
	print("Convert impassible to water...")

	if data == nil then
		data = {}
	end

	local function do_waterline(depthShallow, depthMed, fillOffset, fillDepth)
		print("  Waterline...")
		for y = 0, height - 1, 1 do
			for x = 0, width - 1, 1 do
				local ground = WorldSim:GetTile(x, y)
				if is_waterlined(ground) then
					placeWaterline(width, height, x + 1, y, 1, 0, depthShallow, depthMed, fillOffset, fillDepth)
					placeWaterline(width, height, x - 1, y, -1, 0, depthShallow, depthMed, fillOffset, fillDepth)
					placeWaterline(width, height, x, y + 1, 0, 1, depthShallow, depthMed, fillOffset, fillDepth)
					placeWaterline(width, height, x, y - 1, 0, -1, depthShallow, depthMed, fillOffset, fillDepth)

					placeWaterline(width, height, x + 1, y + 1, 1, 1, depthShallow, depthMed, fillOffset, fillDepth)
					placeWaterline(width, height, x - 1, y + 1, -1, 1, depthShallow, depthMed, fillOffset, fillDepth)
					placeWaterline(width, height, x + 1, y - 1, 1, -1, depthShallow, depthMed, fillOffset, fillDepth)
					placeWaterline(width, height, x - 1, y - 1, -1, -1, depthShallow, depthMed, fillOffset, fillDepth)
				end
			end
		end
	end

	local function do_filledwaterline(depthShallow, depthMed, fillOffset, fillDepth)
		print("  Filled Waterline...")
		for y = 0, height - 1, 1 do
			for x = 0, width - 1, 1 do
				local ground = WorldSim:GetTile(x, y)
				if is_waterlined(ground) then
					placeWaterlineFilled(width, height, x + 1, y, 1, 0, depthShallow, depthMed, fillOffset, fillDepth)
					placeWaterlineFilled(width, height, x - 1, y, -1, 0, depthShallow, depthMed, fillOffset, fillDepth)
					placeWaterlineFilled(width, height, x, y + 1, 0, 1, depthShallow, depthMed, fillOffset, fillDepth)
					placeWaterlineFilled(width, height, x, y - 1, 0, -1, depthShallow, depthMed, fillOffset, fillDepth)

					placeWaterlineFilled(width, height, x + 1, y + 1, 1, 1, depthShallow, depthMed, fillOffset, fillDepth)
					placeWaterlineFilled(width, height, x - 1, y + 1, -1, 1, depthShallow, depthMed, fillOffset, fillDepth)
					placeWaterlineFilled(width, height, x + 1, y - 1, 1, -1, depthShallow, depthMed, fillOffset, fillDepth)
					placeWaterlineFilled(width, height, x - 1, y - 1, -1, -1, depthShallow, depthMed, fillOffset, fillDepth)
				end
			end
		end
	end

	local function do_groundfill(fillTile, fillOffset, fillDepth, landRadius)
		print("  Ground fill...")
		for y = 0, height - 1, 1 do
			for x = 0, width - 1, 1 do
				local ground = WorldSim:GetTile(x, y)
				--if ground == GROUND.OCEAN_SHALLOW and IsCloseToLand(x, y, landRadius) then
				if is_waterlined(ground) then
					fillGroundType(width, height, x + 1, y, fillOffset, fillDepth, fillTile)
					fillGroundType(width, height, x - 1, y, fillOffset, fillDepth, fillTile)
					fillGroundType(width, height, x, y + 1, fillOffset, fillDepth, fillTile)
					fillGroundType(width, height, x, y - 1, fillOffset, fillDepth, fillTile)
				end
			end
			--print(string.format("  Ground fill %4.2f", (y * width) / (width * height) * 100))
		end
		--print("  Ground fill done.")
	end

	local function do_squarefill(shallowRadius, mediumRadius)
		print("  Square fill...")
		--[[for y = 0, height - 1, 1 do
			for x = 0, width - 1, 1 do
				local ground = WorldSim:GetTile(x, y)
				if is_waterlined(ground) and IsCloseToTileType(x, y, 1, GROUND.IMPASSABLE) then
					squareFill(width, height, x, y, mediumRadius, GROUND.OCEAN_MEDIUM)
				end
			end
			print(string.format("  Square fill %4.2f\n", (y * width) / (width * height) * 100))
		end]]
		for y = 0, height - 1, 1 do
			for x = 0, width - 1, 1 do
				local ground = WorldSim:GetTile(x, y)
				if is_waterlined(ground) and (IsCloseToTileType(x, y, shallowRadius, GROUND.IMPASSABLE) or IsCloseToWater(x, y, shallowRadius)) then
					squareFill(width, height, x, y, shallowRadius, GROUND.OCEAN_SHALLOW)
				end
			end
			--print(string.format("  Square fill %4.2f", (y * width) / (width * height) * 100))
		end
		--print("  Square fill done.")
	end

	local function do_noise()
		print("  Noise...")
		local offx_water, offy_water = math.random(-width, width), math.random(-height, height) --2*math.random()-1, 2*math.random()-1
		local offx_coral, offy_coral = math.random(-width, width), math.random(-height, height) --2*math.random()-1, 2*math.random()-1
		local offx_grave, offy_grave = math.random(-width, width), math.random(-height, height) --2*math.random()-1, 2*math.random()-1
		--local offx_mangrove, offy_mangrove = 0, 0 --2*math.random()-1, 2*math.random()-1
		local noise_octave_water = data.noise_octave_water or 6
		local noise_octave_coral = data.noise_octave_coral or 4
		local noise_octave_grave = data.noise_octave_grave or 4
		local noise_persistence_water = data.noise_persistence_water or 0.5
		local noise_persistence_coral = data.noise_persistence_coral or 0.5
		local noise_persistence_grave = data.noise_persistence_grave or 0.5
		local noise_scale_water = data.noise_scale_water or 3
		local noise_scale_coral = data.noise_scale_coral or 6
		local noise_scale_grave = data.noise_scale_grave or 6
		--local noise_scale_mangrove = data.noise_scale_mangrove or 6
		local init_level_coral = data.init_level_coral or 0.65
		local init_level_grave = data.init_level_grave or 0.65
		local init_level_medium = data.init_level_medium or 0.5
		for y = 0, height - 1, 1 do
			for x = 0, width - 1, 1 do
				local ground = WorldSim:GetTile(x, y)
				if ground == GROUND.IMPASSABLE then
					local nx, ny = x/width - 0.5, y/height - 0.5
					if simplexnoise2d(noise_scale_coral * (nx + offx_coral), noise_scale_coral * (ny + offy_coral), noise_octave_coral, noise_persistence_coral) > init_level_coral then
						WorldSim:SetTile(x, y, GROUND.OCEAN_CORAL)
					--elseif simplexnoise2d(noise_scale_mangrove * (nx + offx_mangrove), noise_scale_mangrove * (ny + offy_mangrove), 4, 0.25) > 0.65 then
						--WorldSim:SetTile(x, y, GROUND.MANGROVE)
					else
						local waternoise = simplexnoise2d(noise_scale_water * (nx + offx_water), noise_scale_water * (ny + offy_water), noise_octave_water, noise_persistence_water)
						--if waternoise > 0.6 then
							--WorldSim:SetTile(x, y, GROUND.OCEAN_SHALLOW)
						if waternoise > init_level_medium then
							WorldSim:SetTile(x, y, GROUND.OCEAN_MEDIUM)
						else
							local gravenoise = simplexnoise2d(noise_scale_grave * (nx + offx_grave), noise_scale_grave * (ny + offy_grave), noise_octave_grave, noise_persistence_grave)
							if gravenoise > init_level_grave then
								WorldSim:SetTile(x, y, GROUND.OCEAN_SHIPGRAVEYARD)
							else
								WorldSim:SetTile(x, y, GROUND.OCEAN_DEEP)
							end
						end
					end
				end
			end
		end
	end

	local function do_blend()
		print("  Blend...")
		local kernelSize = data.kernelSize or 15 --don't recommend increasing this
		local sigma = data.sigma or 2.0 --used for blending

		local cmlevels =
		{
			{GROUND.OCEAN_CORAL, 1.0}
		}
		local cm, cmw, cmh = WorldSim:GenerateBlendedMap(kernelSize, sigma, cmlevels, 0.0)
		--print(width, height, cmw, cmh)
		--assert(width == cmw)
		--assert(height == cmh)

		local glevels =
		{
			{GROUND.OCEAN_SHIPGRAVEYARD, 1.0}
		}
		local g, gw, gh = WorldSim:GenerateBlendedMap(kernelSize, sigma, glevels, 0.0)

		local ellevels = nil
		if data.ellevels then
			ellevels = data.ellevels
		else
			ellevels =
			{
				{GROUND.OCEAN_CORAL, 1.0},
				{GROUND.MANGROVE, 1.0},
				{GROUND.JUNGLE, 1.0},
				{GROUND.BEACH, 1.0},
				{GROUND.MAGMAFIELD, 1.0},
				{GROUND.TIDALMARSH, 1.0},
				{GROUND.OCEAN_SHALLOW, 0.9},
				{GROUND.OCEAN_MEDIUM, 0.6},
				{GROUND.OCEAN_DEEP, 0.0},
				{GROUND.OCEAN_SHIPGRAVEYARD, 0.0},
				{GROUND.IMPASSABLE, 0.0}
			}
		end
		local el, elw, elh = WorldSim:GenerateBlendedMap(kernelSize, sigma, ellevels, 1.0)
		--print(width, height, elw, elh)
		--assert(width == elw)
		--assert(height == elh)

		local final_level_shallow = data.final_level_shallow or 0.7
		local final_level_medium = data.final_level_medium or 0.004
		local final_level_coral = data.final_level_coral or 0.2
		local final_level_mangrove = data.final_level_mangrove or 0.2
		local final_level_grave = data.final_level_grave or 0.3
		for y = 0, height - 1, 1 do
			for x = 0, width - 1, 1 do
				local tile = WorldSim:GetTile(x, y)
				if (WorldSim:IsWater(tile) and tile ~= GROUND.MANGROVE) or tile == GROUND.IMPASSABLE then
					local falloff = getEdgeFalloff(x, y, width, height, TUNING.MAPWRAPPER_WARN_RANGE + 1, TUNING.MAPWRAPPER_WARN_RANGE + 5, 0.0, 1.0)
					local ellevel = el[y * width + x]
					local cmlevel = cm[y * width + x] * falloff
					local glevel = g[y * width + x] * falloff
					if ellevel > final_level_shallow then
						if cmlevel > final_level_coral and tile == GROUND.OCEAN_CORAL then
							WorldSim:SetTile(x, y, GROUND.OCEAN_CORAL)
						--elseif cmlevel > final_level_mangrove then
							--WorldSim:SetTile(x, y, GROUND.MANGROVE)
						else
							WorldSim:SetTile(x, y, GROUND.OCEAN_SHALLOW)
						end
					elseif ellevel > final_level_medium then
						WorldSim:SetTile(x, y, GROUND.OCEAN_MEDIUM)
					else
						if glevel > final_level_grave then
							WorldSim:SetTile(x, y, GROUND.OCEAN_SHIPGRAVEYARD)
						else
							WorldSim:SetTile(x, y, GROUND.OCEAN_DEEP)
						end
					end
				end
			end
		end
	end

	local depthShallow = data.depthShallow or 10
	local depthMed = data.depthMed or 20
	local fillDepth = data.fillDepth or 5
	local fillOffset = data.fillOffset or 4

	if not data.nowaterline then
		do_waterline(depthShallow, depthMed, fillOffset, fillDepth)
	elseif not data.nofilledwaterline then
		do_filledwaterline(depthShallow, depthMed, fillOffset, fillDepth)
	end
	if not data.nosqaurefill then
		do_squarefill(data.shallowRadius or 5, data.mediumRadius or 10)
	end
	if not data.nogroundfill then
		--do_groundfill(GROUND.OCEAN_MEDIUM, 2 * fillOffset, fillDepth)
		do_groundfill(GROUND.OCEAN_SHALLOW, fillOffset, fillDepth, data.shallowRadius or 5)
	end
	if not data.nonoise then
		do_noise()
	end
	if not data.noblend then
		do_blend()
	end
end

function AddShoreline(width, height)
	print("Adding shoreline...")

	for y = 0, height - 1, 1 do
		for x = 0, width - 1, 1 do
			local ground = WorldSim:GetTile(x, y)
			if WorldSim:IsWater(ground) and not IsSurroundedByWaterOrInvalid(x, y, 1) then
				if ground == GROUND.MANGROVE then
					WorldSim:SetTile(x, y, GROUND.MANGROVE_SHORE)
				elseif ground == GROUND.OCEAN_CORAL then
					WorldSim:SetTile(x, y, GROUND.OCEAN_CORAL_SHORE)
				else
					WorldSim:SetTile(x, y, GROUND.OCEAN_SHORE)
				end
			end
		end
	end
end

function RemoveSingleWaterTile(width, height)
	print("Removing single tiles...")

	local function isLand(x, y)
		return 0 < x and x < width and 0 < y and y < height and WorldSim:IsLand(WorldSim:GetTile(x, y))
	end

	for y = 0, height - 1, 1 do
		for x = 0, width - 1, 1 do
			local ground = WorldSim:GetTile(x, y)
			if WorldSim:IsWater(ground) and isLand(x - 1, y) and isLand(x + 1, y) and isLand(x, y - 1) and isLand(x, y + 1) then
				if x + 1 < width then
					WorldSim:SetTile(x, y, WorldSim:GetTile(x + 1, y))
				else
					WorldSim:SetTile(x, y, WorldSim:GetTile(x - 1, y))
				end
			end
		end
	end
end

local function checkTile(x, y, checkFn)
	return not WorldSim:IsTileReserved(x, y) and (checkFn == nil or checkFn(WorldSim:GetTile(x, y), x, y))
end

function GetRandomWaterPoints(checkFn, width, height, edge_dist, needed)
	local get_points = function(points, checkFn, width, height, edge_dist, needed, inc)
		local adj_width, adj_height = width - 2 * edge_dist, height - 2 * edge_dist
		local start_x, start_y = math.random(0, adj_width), math.random(0, adj_height)
		local i, j = 0, 0
		while j < adj_height and #points < needed do
			local y = ((start_y + j) % adj_height) + edge_dist
			while i < adj_width and #points < needed do
				local x = ((start_x + i) % adj_width) + edge_dist
				--local ground = WorldSim:GetTile(x, y)
				--if checkFn(ground, x, y) then
				if checkTile(x, y, checkFn) then
					table.insert(points, {x=x, y=y})
				end
				i = i + inc
			end
			j = j + inc
			i = 0
		end
	end

	local points = {}
	local points_x = {}
	local points_y = {}
	local incs = {263, 137, 67, 31, 17, 9, 5, 3, 1}

	for i = 1, #incs, 1 do
		if #points < needed then
			get_points(points, checkFn, width, height, edge_dist, needed, incs[i])
			--print(string.format("%d (of %d) points found", #points, needed))
		end
	end

	points = shuffleArray(points)
	for i = 1, #points, 1 do
		table.insert(points_x, points[i].x)
		table.insert(points_y, points[i].y)
	end

	return points_x, points_y
end

local function checkAllTiles(checkFn, x1, y1, x2, y2)
	for j = y1, y2, 1 do
		for i = x1, x2, 1 do
			--if not checkFn(WorldSim:GetTile(i, j), i, j) then
			if not checkTile(i, j, checkFn) then
				return false, i, j
			end
		end
	end
	return true, 0, 0
end

local function fillAllTiles(x1, y1, x2, y2)
	for j = y1, y2, 1 do
		for i = x1, x2, 1 do
			WorldSim:SetTile(i, j, GROUND.SAVANNA)
		end
	end
	--[[WorldSim:SetTile(x1, y1, GROUND.SAVANNA)
	WorldSim:SetTile(x1, y2, GROUND.SAVANNA)
	WorldSim:SetTile(x2, y1, GROUND.SAVANNA)
	WorldSim:SetTile(x2, y2, GROUND.SAVANNA)]]
end

local function findLayoutPositions(radius, edge_dist, checkFn, count)
	local positions = {}
	local size = 2 * radius
	edge_dist = edge_dist or 0

	local width, height = WorldSim:GetWorldSize()
	local adj_width, adj_height = width - 2 * edge_dist - size, height - 2 * edge_dist - size
	local start_x, start_y = math.random(0, adj_width), math.random(0, adj_height)
	local i, j = 0, 0
	while j < adj_height and (count == nil or #positions < count) do
		local y = ((start_y + j) % adj_height) + edge_dist
		while i < adj_width and (count == nil or #positions < count) do
			-- check the corners first
			local x = ((start_x + i) % adj_width) + edge_dist
			local x2, y2 = x + size - 1, y + size - 1
			if checkTile(x2, y, checkFn) and checkTile(x2, y2, checkFn) then
			--if checkFn(WorldSim:GetTile(x2, y), x2, y) and checkFn(WorldSim:GetTile(x2, y2), x2, y2) then
				if checkTile(x, y, checkFn) and checkTile(x, y2, checkFn) then
				--if checkFn(WorldSim:GetTile(x, y), x, y) and checkFn(WorldSim:GetTile(x, y2), x, y2) then
					--print("Found 4 corners", x, y, x2, y2)

					--check all tiles
					local ok, last_x, last_y = checkAllTiles(checkFn, x, y, x2, y2)
					if ok == true then
						--fillAllTiles(checkFn, x, y, x2, y2)
						--bottom-left
						--print(string.format("Location found (%4.2f, %4.2f)", x, y))
						--local adj = 0.5 * (size - actualsize)
						--return {x + adj, y2 - adj} --{0.5 * (x + x2), 0.5 * (y + y2)}
						--table.insert(positions, {x = x + adj, y = y2 - adj})
						table.insert(positions, {x = x, y = y, x2 = x2, y2 = y2, size = size})
						i = i + size + 1
					else
						--print(string.format("Failed at (%4.2f, %4.2f) skip, (%4.2f, %4.2f)", last_x, last_y, x, y))
						i = i + last_x - x + 1
					end
				else
					i = i + 1
				end
			else
				--print(string.format("Failed on x2, skip (%4.2f, %4.2f)", x, y))
				i = i + size + 1
			end
		end
		j = j + 1
		i = 0
	end

	return positions
end

local function findEdgeLayoutPositions(radius, edge_dist, checkFn)
	local positions = {}
	local size = 2 * radius
	edge_dist = edge_dist or 0

	local width, height = WorldSim:GetWorldSize()
	local adj_width, adj_height = width - 2 * edge_dist - size, height - 2 * edge_dist - size
	
	local edge_x = function(start_y)
		local x, y = 0, 0
		local i = 0
		while i < adj_width do
			x = i + edge_dist
			y = start_y
			local x2, y2 = x + size - 1, y + size - 1
			if checkTile(x2, y, checkFn) and checkTile(x2, y2, checkFn) then
			--if checkFn(WorldSim:GetTile(x2, y), x2, y) and checkFn(WorldSim:GetTile(x2, y2), x2, y2) then
				if checkTile(x, y, checkFn) and checkTile(x, y2, checkFn) then
				--if checkFn(WorldSim:GetTile(x, y), x, y) and checkFn(WorldSim:GetTile(x, y2), x, y2) then
					--print("Found 4 corners", x, y, x2, y2)

					--check all tiles
					local ok, last_x, last_y = checkAllTiles(checkFn, x, y, x2, y2)
					if ok == true then
						table.insert(positions, {x = x, y = y, x2 = x2, y2 = y2, size = size})
						i = i + size + 1
					else
						--print(string.format("Failed at (%4.2f, %4.2f) skip, (%4.2f, %4.2f)", last_x, last_y, x, y))
						i = i + last_x - x + 1
					end
				else
					i = i + 1
				end
			else
				--print(string.format("Failed on x2, skip (%4.2f, %4.2f)", x, y))
				i = i + size + 1
			end
		end
	end

	local edge_y = function(start_x)
		local x, y = 0, 0
		local i = 0
		while i < adj_height do
			x = start_x
			y = i + edge_dist + size
			local x2, y2 = x + size - 1, y + size - 1
			if checkTile(x2, y, checkFn) and checkTile(x2, y2, checkFn) then
			--if checkFn(WorldSim:GetTile(x2, y), x2, y) and checkFn(WorldSim:GetTile(x2, y2), x2, y2) then
				if checkTile(x, y, checkFn) and checkTile(x, y2, checkFn) then
				--if checkFn(WorldSim:GetTile(x, y), x, y) and checkFn(WorldSim:GetTile(x, y2), x, y2) then
					--print("Found 4 corners", x, y, x2, y2)

					--check all tiles
					local ok, last_x, last_y = checkAllTiles(checkFn, x, y, x2, y2)
					if ok == true then
						table.insert(positions, {x = x, y = y, x2 = x2, y2 = y2, size = size})
						i = i + size + 1
					else
						--print(string.format("Failed at (%4.2f, %4.2f) skip, (%4.2f, %4.2f)", last_x, last_y, x, y))
						i = i + last_y - y + 1
					end
				else
					i = i + 1
				end
			else
				--print(string.format("Failed on x2, skip (%4.2f, %4.2f)", x, y))
				i = i + size + 1
			end
		end
	end

	edge_x(edge_dist)
	edge_x(adj_height)

	edge_y(edge_dist)
	edge_y(adj_width)

	return positions
end

function PlaceWaterLayout(layout, prefabs, add_entity, checkFn, radius)
	local obj_layout = require("map/object_layout")
	local layoutsize = GetLayoutRadius(layout, prefabs)
	local r = math.max(layoutsize, radius or 0)
	local positions = findLayoutPositions(r, TUNING.MAPWRAPPER_WARN_RANGE + 8, checkFn, 1)
	if positions and #positions > 0 then
		local pos = math.random(1, #positions)
		local adj = 0.5 * (positions[pos].size - layoutsize)
		local x, y = positions[pos].x + adj, positions[pos].y + adj --bottom-left
		--print(string.format("PlaceWaterLayout (%f, %f) from %d of %d", x, y, pos, #positions))
		obj_layout.ReserveAndPlaceLayout("POSITIONED", layout, prefabs, add_entity, {x, y})

		for yy = positions[pos].y, positions[pos].y2, 1 do
			for xx = positions[pos].x, positions[pos].x2, 1 do
				WorldSim:ReserveTile(xx, yy)
			end
		end
	end
end

function PlaceSingleWaterSetPiece(name, add_entity, checkFn, radius)
	local obj_layout = require("map/object_layout")
	local layout = obj_layout.LayoutForDefinition(name)
	local prefabs = obj_layout.ConvertLayoutToEntitylist(layout)
	PlaceWaterLayout(layout, prefabs, add_entity, checkFn, radius)
end

function PlaceWaterSetPieces(set_pieces, add_entity, checkFn)
	local obj_layout = require("map/object_layout")
	for name, data in pairs(set_pieces) do
		local layout = obj_layout.LayoutForDefinition(name)
		local prefabs = obj_layout.ConvertLayoutToEntitylist(layout)
		for i = 1, data.count or 1, 1 do
			PlaceWaterLayout(layout, prefabs, add_entity, checkFn, data.radius or 0)
		end
	end
end

function FillOpenWater(set_pieces, entitiesOut, width, height)
	print("Fill open water...")

	local prefab_list = {}

	local checkFn = function(ground, x, y)
		return ground == GROUND.IMPASSABLE
	end

	local add_fn = {
		fn=function(prefab, points_x, points_y, idx, entitiesOut, width, height, prefab_list, prefab_data, rand_offset)
			AddEntity(prefab, points_x[idx], points_y[idx], entitiesOut, width, height, prefab_list, prefab_data, rand_offset)
		end,
		args={entitiesOut=entitiesOut, width=width, height=height, rand_offset = true, debug_prefab_list=prefab_list}
	}

	local obj_layout = require("map/object_layout")

	local positions = {}
	local curidx = {}
	local radius = {50}
	for i = 1, #radius, 1 do
		positions[i] = shuffleArray(findEdgeLayoutPositions(radius[i], TUNING.MAPWRAPPER_WARN_RANGE + 8, checkFn))
		curidx[i] = 1
		print(string.format("Found %d positions, radius %d", #positions[i], radius[i]))
	end

	for name, data in pairs(set_pieces) do
		local layout = obj_layout.LayoutForDefinition(name)
		local prefabs = obj_layout.ConvertLayoutToEntitylist(layout)
		local layoutsize = GetLayoutRadius(layout, prefabs)
		local count = data.count or 1

		for j = 1, count, 1 do
			local radiusidx = 1

			local i = 0
			while i < count and radiusidx <= #radius do
				if curidx[radiusidx] >= #positions[radiusidx] or radius[radiusidx] < layoutsize then
					radiusidx = radiusidx + 1
				else
					local pos = positions[radiusidx][curidx[radiusidx]]
					local adj = 0.5 * (pos.size - layoutsize)
					local x, y = pos.x + adj, pos.y2 - adj --bottom-left
					print(string.format("Place fill layout %s at (%f, %f)", name, x, y))
					obj_layout.ReserveAndPlaceLayout("POSITIONED", layout, prefabs, add_fn, {x, y})
					curidx[radiusidx] = curidx[radiusidx] + 1
					i = i + 1
				end
			end
		end
	end
end

local function AdjustDistribution(water_contents, world_gen_choices)
	--mod distribution based on world gen params

	if world_gen_choices == nil then
		return
	end

	local get_total = function(distributeprefabs)
		local total = 0
		for prefab, dist in pairs(distributeprefabs) do
			total = total + dist
		end
		return total
	end

	local get_dist = function(distributeprefabs, prefab, mul)
		local total = get_total(distributeprefabs)
		local olddist = distributeprefabs[prefab]
		local atotal = total - olddist
		print("Dist before", prefab, olddist, olddist / total)
		local newdist = (mul * atotal / (atotal + olddist - mul * olddist)) * olddist --mul * (olddist - total) / (mul * olddist - 1) ---mul * olddist * (total - olddist) / (mul * olddist - 1)
		print("Dist change", prefab, mul, olddist, newdist)
		print("Dist after", prefab, newdist, (newdist / olddist) * (olddist / total), newdist / (atotal + newdist))
		return newdist
	end
		
	if water_contents.distributepercent and water_contents.distributeprefabs then
		for prefab, mul in pairs(world_gen_choices) do
			if water_contents.distributeprefabs[prefab] then
				--local old = water_contents.distributeprefabs[prefab] / get_total(water_contents.distributeprefabs)
				--print("Dist before", prefab, old)
				--print("Dist change", prefab, mul, water_contents.distributeprefabs[prefab], mul * water_contents.distributeprefabs[prefab])
				water_contents.distributeprefabs[prefab] = get_dist(water_contents.distributeprefabs, prefab, mul) --mul * water_contents.distributeprefabs[prefab]
				--local new = water_contents.distributeprefabs[prefab] / get_total(water_contents.distributeprefabs)
				--print("Dist after", prefab, new, new / old, old / new)
				--water_contents.distributeprefabs[prefab] = get_dist(water_contents.distributeprefabs, prefab, mul)
			end
		end
	end

	if water_contents.countprefabs then
		for prefab, mul in pairs(world_gen_choices) do
			if water_contents.countprefabs[prefab] then
				water_contents.countprefabs[prefab] = mul * water_contents.countprefabs[prefab]
			end
		end
	end
end

function PopulateWaterExtra(checkFn, spawnFn, entitiesOut, width, height, edge_dist, water_contents, world_gen_choices, prefab_list)
	print("Populate water extras...")

	local generate_these = {}
	local pos_needed = 0

	if world_gen_choices == nil then
		return
	end

	for prefab, mul in pairs(world_gen_choices) do
		if prefab_list[prefab] then
			generate_these[prefab] = prefab_list[prefab] * math.max(mul - 1.0, 0.0)
			pos_needed = pos_needed + generate_these[prefab]
		end
	end

	print("generate_these, before", pos_needed)
	dumptable(prefab_list, 1, 2)
	dumptable(generate_these, 1, 2)

	local points_x, points_y = GetRandomWaterPoints(checkFn, width, height, edge_dist, pos_needed + 20)

	local pos_cur = 1
	for prefab, count in pairs(generate_these) do 
		local added = 0
		while added < count and pos_cur <= #points_x do
			if AddEntityCheck(prefab, points_x[pos_cur], points_y[pos_cur], entitiesOut, water_contents.prefabspawnfn) then
				local prefab_data = {}
				prefab_data.data = water_contents.prefabdata and water_contents.prefabdata[prefab] or nil
				AddEntity(prefab, points_x[pos_cur], points_y[pos_cur], entitiesOut, width, height, prefab_list, prefab_data)
				added = added + 1
			end
			pos_cur = pos_cur + 1
		end
	end

	print("generate_these, after", pos_needed)
	dumptable(prefab_list, 1, 2)
end

local function PopulateWaterType(checkFn, spawnFn, entitiesOut, width, height, edge_dist, water_contents, world_gen_choices)
	local prefab_list = {}
	local generate_these = {}
	local pos_needed = 0

	assert(edge_dist < width)
	assert(edge_dist < height)

	if water_contents.countstaticlayouts ~= nil then
		local add_fn = {
			fn=function(prefab, points_x, points_y, idx, entitiesOut, width, height, prefab_list, prefab_data, rand_offset)
				AddEntity(prefab, points_x[idx], points_y[idx], entitiesOut, width, height, prefab_list, prefab_data, rand_offset)
			end,
			args={entitiesOut=entitiesOut, width=width, height=height, rand_offset = true, debug_prefab_list=prefab_list}
		}

		for set_piece, count in pairs(water_contents.countstaticlayouts) do
			if type(count) == "function" then
				count = count()
			end
			if water_contents.staticlayoutspawnfn and water_contents.staticlayoutspawnfn[set_piece] then
				local fn = function(ground, x, y) return checkFn(ground, x, y) and water_contents.staticlayoutspawnfn[set_piece](x, y, entitiesOut) end
				for i = 1, count, 1 do
					PlaceSingleWaterSetPiece(set_piece, add_fn, fn)
				end
			else
				for i = 1, count, 1 do
					PlaceSingleWaterSetPiece(set_piece, add_fn, checkFn)
				end
			end
		end
	end

	if water_contents.countprefabs ~= nil then
		for prefab, count in pairs(water_contents.countprefabs) do
			if type(count) == "function" then
				count = count()
			end
			generate_these[prefab] = count
			pos_needed = pos_needed + count
		end

		--get a bunch of points
		local points_x, points_y = GetRandomWaterPoints(checkFn, width, height, edge_dist, 2 * pos_needed + 10)

		local pos_cur = 1
		for prefab, count in pairs(generate_these) do 
			local added = 0
			while added < count and pos_cur <= #points_x do
			--for id = 1, math.min(count, #points_x) do
				--if water_contents.prefabspawnfn == nil or water_contents.prefabspawnfn[prefab] == nil or water_contents.prefabspawnfn[prefab](points_x[pos_cur], points_y[pos_cur], entitiesOut) then
				if AddEntityCheck(prefab, points_x[pos_cur], points_y[pos_cur], entitiesOut, water_contents.prefabspawnfn) then
					local prefab_data = {}
					prefab_data.data = water_contents.prefabdata and water_contents.prefabdata[prefab] or nil
					AddEntity(prefab, points_x[pos_cur], points_y[pos_cur], entitiesOut, width, height, prefab_list, prefab_data)
					added = added + 1
				end
				pos_cur = pos_cur + 1
			end
		end
	end

	if water_contents.distributepercent and water_contents.distributeprefabs then
		for y = edge_dist, height - edge_dist - 1, 1 do
			for x = edge_dist, width - edge_dist - 1, 1 do
				if checkTile(x, y, checkFn) then
					local ground = WorldSim:GetTile(x, y)
				--if checkFn(ground, x, y) then
					if math.random() < water_contents.distributepercent then
						local prefab = spawnFn.pickspawnprefab(water_contents.distributeprefabs, ground)
						if prefab ~= nil then
							--if water_contents.prefabspawnfn == nil or water_contents.prefabspawnfn[prefab] == nil or water_contents.prefabspawnfn[prefab](x, y, entitiesOut) then
							if AddEntityCheck(prefab, x, y, entitiesOut, water_contents.prefabspawnfn) then
								local prefab_data = {}
								prefab_data.data = water_contents.prefabdata and water_contents.prefabdata[prefab] or nil
								AddEntity(prefab, x, y, entitiesOut, width, height, prefab_list, prefab_data)
							end
						end
					end
				end
			end
		end
	end

	PopulateWaterExtra(checkFn, spawnFn, entitiesOut, width, height, edge_dist, water_contents, world_gen_choices, prefab_list)
end

function PopulateWater(spawnFn, entitiesOut, width, height, water_contents, world_gen_choices)
	print("Populate water...")

	local edge_dist = TUNING.MAPWRAPPER_WARN_RANGE + 2 --16

	for i, content in ipairs(water_contents) do
		--AdjustDistribution(content.data.contents, world_gen_choices)
		PopulateWaterType(content.checkFn, spawnFn, entitiesOut, width, height, edge_dist, content.data.contents, world_gen_choices)
	end
end