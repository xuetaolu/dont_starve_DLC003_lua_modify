local islandmappings = {}
local islandTiles = {}


local function color(x,y,tiles,islands,value)
	tiles[y][x] = false
	islands[y][x] = value
end

local function check_validity(x,y,w,h,tiles,stack)
	if x >= 1 and y >= 1 and x <= w and y <= h and tiles[y][x] then
		stack[#stack+1] = {x=x,y=y}
	end
end

local function floodfill(x,y,w,h,tiles,islands,value)
	local q = {}
    q[#q+1] = {x=x,y=y}
	while #q > 0 do
		local el = q[#q] 
		table.remove(q)
		local x1,y1 = el.x, el.y
		color(x1,y1,tiles,islands,value)
                            
        check_validity(x1+1,y1,w,h,tiles,q)
		check_validity(x1-1,y1,w,h,tiles,q)
		check_validity(x1,y1+1,w,h,tiles,q)
       	check_validity(x1,y1-1,w,h,tiles,q)
		-- diagonals
        check_validity(x1-1,y1-1,w,h,tiles,q)
		check_validity(x1-1,y1+1,w,h,tiles,q)
		check_validity(x1+1,y1-1,w,h,tiles,q)
       	check_validity(x1+1,y1+1,w,h,tiles,q)
	end
end

local function FloodFillAllIslands(w, h, tiles, islands)
	local index = 1
	local rescan = true
	for y = 1,h do
		for x = 1,w do
			local val = tiles[y][x]
			if val then
				floodfill(x,y,w,h,tiles,islands,index)
				index = index + 1
			end
		end
	end
end

local function FloodFillSingle(x, y, w, h, tiles, islands, color)
	local val = tiles[y][x]
	if val then
		floodfill(x,y,w,h,tiles,islands,color)
	end
end

-- Detect actual islands. Each disconnected blob will have a unique numbering
local function FindRealIslands()
	print("...Finding actual islands")

	local islands = {}
	local tiles = {}
	local map = GetWorld().Map
	local w,h = map:GetSize()
	for y = 1,h do
		tiles[y] = {}
		islands[y] = {}
		for x = 1, w do
			local tile = map:GetTile(x-1,y-1)
			tiles[y][x] = tile ~= GROUND.IMPASSABLE
		end                                          
	end
	FloodFillAllIslands(w,h,tiles, islands)

	return islands
end

local function GetTileCenterAtTileXY(x,y)
	local map = GetWorld().Map
	local w,h = map:GetSize()

	local tilesize = 4
	local tilegrid_width = w
	local tilegrid_height = h

	local ppx = (x) * tilesize - (tilesize * tilegrid_width)  / 2
	local ppy = (y) * tilesize - (tilesize * tilegrid_height)  / 2

	return ppx, ppy
end

local function InsertWormHole(from, tiles)
	-- Try to get some breathing room, but if that fails fall back to narrower situations
	local distances = {2.5, 1, 1.5, 1, 0.5}
	for _,distance in pairs(distances) do
		for i,v in pairs(tiles) do
			local x,y = v[1], v[2]
			local cx,cy = GetTileCenterAtTileXY(x-1,y-1)

			local ground = GetWorld()				
			local tile = ground.Map:GetTileAtPoint(cx, 0, cy)
			local onWater = ground.Map:IsWater(tile)

            if not onWater then                    
				local ents = TheSim:FindEntities(cx, 0, cy, distance)			
				if #ents == 0 then
					local prefab = SpawnPrefab("wormhole")
					prefab.Transform:SetPosition(cx,0,cy)
					return prefab
				end
			end
		end
	end
end

local function ConnectIslands(from, to, islandTiles)
	print(string.format("  - Connecting island %d to %d",from,to))
	local map = GetWorld().Map
	local wormhole_1 = InsertWormHole(from, islandTiles[from])
	local wormhole_2 = InsertWormHole(to, islandTiles[to])
	if wormhole_1 and wormhole_2 then
		wormhole_1.components.teleporter:Target(wormhole_2)
		wormhole_2.components.teleporter:Target(wormhole_1)
	else
		if wormhole_1 then
			wormhole_1:Remove()
		end
		if wormhole_2 then
			wormhole_2:Remove()
		end
	end
end

local function RepairIslands(--[[realIslands,]] islandTiles, i, islands) 
	local flattened = {}
	for i,v in pairs(islands) do
		table.insert(flattened,i)
	end
	print(string.format("- WorldGen island %d actually has %d islands",i,#flattened))
	-- Now worldgenIslands is a table of island that need to be connected
	-- Connect each of them to the next 
	local islands = {}
	for i=1,#flattened-1 do
		ConnectIslands(flattened[i], flattened[i+1], islandTiles)
	end
end


function bresenham(x1, y1, x2, y2)
  delta_x = x2 - x1
  ix = delta_x > 0 and 1 or -1
  delta_x = 2 * math.abs(delta_x)
 
  delta_y = y2 - y1
  iy = delta_y > 0 and 1 or -1
  delta_y = 2 * math.abs(delta_y)
 
  plot(x1, y1)
 
  if delta_x >= delta_y then
    error = delta_y - delta_x / 2
 
    while x1 ~= x2 do
      if (error > 0) or ((error == 0) and (ix > 0)) then
        error = error - delta_x
        y1 = y1 + iy
      end
 
      error = error + delta_y
      x1 = x1 + ix
 
      plot(x1, y1)
    end
  else
    error = delta_x - delta_y / 2
 
    while y1 ~= y2 do
      if (error > 0) or ((error == 0) and (iy > 0)) then
        error = error - delta_y
        x1 = x1 + ix
      end
 
      error = error + delta_x
      y1 = y1 + iy
 
      plot(x1, y1)
    end
  end
end


-- bressenham line algorithm. 
-- sample - a function that should return true if done prematurely
-- param - whatever you want, you can do bookkeeping in the sample function
local function Line(x0, y0, x1, y1, sample, param)
-- print(">>Line from",x0,y0,x1,y1)
	local steep = math.abs(y1 - y0) > math.abs(x1 - x0)
	if steep then
		x0, y0 = y0,x0
		x1, y1 = y1,x1
	end
	if (x0 > x1) then
		x0,x1 = x1,x0
		y0,y1 = y1,y0
	end
	local dX = (x1 - x0)
	local dY = math.abs(y1 - y0)
	local err = math.floor(dX / 2)
	local ystep = (y0 < y1 and 1 or -1)
	local y = y0

	for x=x0,x1 do
		local done
		if steep then
			done = sample(y, x, param) 
		else 
			done = sample(x, y, param)
		end
		if done then
			return param
		end

		err = err - dY
		if (err < 0) then 
			y = y + ystep
			err = err+ dX	
		end
	end
	return param
end

local function CountTilesAlongLine(tiles,sx,sy,ex,ey)
	local map = GetWorld().Map
	local sx,sy = map:GetTileXYAtPoint(sx,0,sy)
	local ex,ey = map:GetTileXYAtPoint(ex,0,ey)
	local pixels = {0}
	local pixels = Line(sx,sy,ex,ey, 	
						function(x,y,param)
							param[1] = param[1] + (tiles[y+1][x+1] and 1 or 0)
							return false
						end, pixels)
	
	return pixels[1]
end

local function FindValidStartTile(cx,cy,node,tiles)
	local map = GetWorld().Map
	local x,y = map:GetTileXYAtPoint(cx,0,cy)
	local tile = tiles[y+1][x+1]	

	-- We can't always fill from the center of a region. Sometimes a region is very long and the center is actually off land
	-- sample a line to every corner of the region, and count the valid tiles. The one with the most tiles should lead into
	-- this region's actual landmass. Any tile of that mass will do as a starting point for the floodfill
	if not tile then
		local maxpixels = 0
		local maxpair
		--print("Not valid!",x,y)
		for i,v in pairs(node.poly) do
			if v then
				local pixels = CountTilesAlongLine(tiles,cx,cy,v[1],v[2])
				--print(i, cx,cy,v[1],v[2], pixels)
				if pixels > maxpixels then
					maxpixels = pixels                                                                                                                                               
					maxpair = {cx,cy,v[1],v[2]}                                                                                                                 
				end
			end                                                                                                                                                
		end
		if maxpixels ~= 0 then
			--print("maxpair:",maxpair[1],maxpair[2],maxpair[3],maxpair[4])
			local sx,sy = map:GetTileXYAtPoint(maxpair[1],0,maxpair[2])
			local ex,ey = map:GetTileXYAtPoint(maxpair[3],0,maxpair[4])

			-- We have the line with the most tiles along it. Any tile along this line
			-- should qualify as a fill starting point for this region
			local center = {}
			Line(sx, sy, ex, ey , 	
							function(x,y,param)
								local tile = tiles[y+1][x+1]
								if tile then
									param.x = x
									param.y = y
									return true
								end
								return false
							end, center)
			x,y = center.x, center.y
			return x,y
		end
		return nil
	end	
	return x,y
end

-- Find the islands as the worldgen sees them. This may have disconnected areas labeled the same
local function FindWorldGenIslands()
	print("...Finding world gen islands")
	local islandRegionMapping = {}
	local function AddIslandRegionMapping(name, ident)
		islandRegionMapping[name] = ident
	end

	AddIslandRegionMapping("START", 			"A")

	AddIslandRegionMapping("Edge_of_the_unknown", 			"A")
	AddIslandRegionMapping("painted_sands", 				"A")
	AddIslandRegionMapping("plains", 						"A")
	AddIslandRegionMapping("rainforests", 					"A")
	AddIslandRegionMapping("rainforest_ruins", 			"A")
	AddIslandRegionMapping("plains_ruins", 				"A")  
	AddIslandRegionMapping("Edge_of_civilization", 		"A")  
	AddIslandRegionMapping("Deep_rainforest", 				"A")
	AddIslandRegionMapping("Pigtopia", 					"A")
	AddIslandRegionMapping("Pigtopia_capital", 			"A")
	AddIslandRegionMapping("Deep_lost_ruins_gas", 			"A")		
	AddIslandRegionMapping("Edge_of_the_unknown_2", 		"A")
	AddIslandRegionMapping("Lilypond_land", 				"A")				
	AddIslandRegionMapping("Lilypond_land_2", 				"A")	
	AddIslandRegionMapping("this_is_how_you_get_ants", 	"A")
	AddIslandRegionMapping("Deep_rainforest_2", 			"A")
	AddIslandRegionMapping("Lost_Ruins_1", 				"A")
	AddIslandRegionMapping("Lost_Ruins_4", 				"A")		

	AddIslandRegionMapping("Deep_rainforest_3", 			"B")		
	AddIslandRegionMapping("Deep_rainforest_mandrake", 	"B")			
	AddIslandRegionMapping("Path_to_the_others", 			"B")
	AddIslandRegionMapping("Other_edge_of_civilization", 	"B")
	AddIslandRegionMapping("Other_pigtopia", 				"B")
	AddIslandRegionMapping("Other_pigtopia_capital", 		"B")

	AddIslandRegionMapping("Deep_lost_ruins4", 			"C")		
	AddIslandRegionMapping("lost_rainforest", 				"C")		
	AddIslandRegionMapping("interior_space", 				"D")

	AddIslandRegionMapping("pincale", 						"E")

	AddIslandRegionMapping("Deep_wild_ruins4", 			"F")
	AddIslandRegionMapping("wild_rainforest", 			"F")
	AddIslandRegionMapping("wild_ancient_ruins", 		"F")
	AddIslandRegionMapping("Land_Divide_1", 		"G")
	AddIslandRegionMapping("Land_Divide_2", 		"G")
	AddIslandRegionMapping("Land_Divide_3", 		"G")
	AddIslandRegionMapping("Land_Divide_4", 		"G")

	local islands = {}
	local tiles = {}
	local map = GetWorld().Map
	local w,h = map:GetSize()

	for y = 1,h do
		tiles[y] = {}
		islands[y] = {}
		for x = 1, w do
			local tile = map:GetTile(x-1,y-1)
			tiles[y][x] = tile ~= GROUND.IMPASSABLE
		end                                          
	end

	local fillPoints = {}
	-- Build an array of the island indices as Hamlet sees them by floodfilling every map region with the island it should map to
	local ground = GetWorld()
	local map = GetWorld().Map
    for t,node in ipairs(ground.topology.nodes)do
		local nodename = ground.topology.ids[node.idx]
		local cx,cy = node.cent[1], node.cent[2]
		-- Do a floodfill for this node
		local colon = nodename:find(":",1,true)
		local actualNodeName
		if colon then
			actualNodeName = nodename:sub(1, colon-1)
		else
			if nodename == "START" then
				actualNodeName = "START"
			else
				print(nodename)
				assert(false)
			end
		end
			
		local islandIdent = islandRegionMapping[actualNodeName]
		-- don't fill empty space and interior space
		if islandIdent ~= "G" and islandIdent ~= "D" then
			-- floodfill this island
			-- is this tile on the island?
			local x,y = FindValidStartTile(cx,cy,node,tiles)
			if x then
				table.insert(fillPoints, {x=x, y=y, color = string.byte(islandIdent) - string.byte("A")})
			end
		end
    end

	for i,v in pairs(fillPoints) do
		FloodFillSingle(v.x+1, v.y+1, w, h, tiles, islands, v.color)
	end

	return islands
end

function ConnectDisconnectedIslands()
	print("Doing one-time world repair")
	print("...Checking for disconnected islands")
	TheSim:StartTimer()
	-- find the actual islands that are on the map
	local realIslands = FindRealIslands()
	-- find the islands as worldgen sees them
	local worldgenIslands = FindWorldGenIslands()

	-- Find islands that are mapped non-uniformly
	local map = GetWorld().Map
	local w,h = map:GetSize()
	for y = 1,h do
		for x = 1, w do
			local realIsland = realIslands[y][x]
			local worldgenIsland = worldgenIslands[y][x]
			if realIsland and worldgenIsland then	
				islandmappings[worldgenIsland] = islandmappings[worldgenIsland] or {}
				islandmappings[worldgenIsland][realIsland] = true
			end
		end
	end

	worldgenIslands = nil -- don't need it anymore

	-- flatten real islands to lists of tiles
	for y = 1,h do
		for x = 1, w do
			local island = realIslands[y][x]
			if island then
				islandTiles[island] = islandTiles[island] or {}
				table.insert(islandTiles[island], {x,y})
			end
		end
	end
	-- shuffle em up for later
	for i,v in pairs(islandTiles) do
		shuffleArray(v)
	end

	realIslands = nil

	local repaired = 0
	-- flatten these mappings
	for i,v in pairs(islandmappings) do
		local count = 0
		local flattened = {}
		for i,v in pairs(v) do
			count = count + 1
		end
		if count > 1 then
			RepairIslands(islandTiles, i, v) 
			repaired = repaired + 1
		end
	end
	local time = TheSim:StopTimer()
	if repaired == 0 then
		print(string.format("Done - Nothing to repair - took %2.2f seconds", time))
	else
		print(string.format("Repaired %d islands, took %2.2f seconds", repaired, time))
	end
	islandmappings = {}
	islandTiles = {}
end

function DetectDisconnectedIslands()
	print("Doing one-time world repair")
	print("...Checking for disconnected islands")
	TheSim:StartTimer()
	-- find the actual islands that are on the map
	local realIslands = FindRealIslands()
	-- find the islands as worldgen sees them
	local worldgenIslands = FindWorldGenIslands()

	-- Find islands that are mapped non-uniformly
	local map = GetWorld().Map
	local w,h = map:GetSize()
	for y = 1,h do
		for x = 1, w do
			local realIsland = realIslands[y][x]
			local worldgenIsland = worldgenIslands[y][x]
			if realIsland and worldgenIsland then	
				islandmappings[worldgenIsland] = islandmappings[worldgenIsland] or {}
				islandmappings[worldgenIsland][realIsland] = true
			end
		end
	end

	worldgenIslands = nil -- don't need it anymore

	-- flatten real islands to lists of tiles
	for y = 1,h do
		for x = 1, w do
			local island = realIslands[y][x]
			if island then
				islandTiles[island] = islandTiles[island] or {}
				table.insert(islandTiles[island], {x,y})
			end
		end
	end
	-- shuffle em up for later
	for i,v in pairs(islandTiles) do
		shuffleArray(v)
	end

	realIslands = nil
	print(string.format("Done, took %2.2f seconds", TheSim:StopTimer()))
end

function FixDisconnectedIslands()
	print("Connecting disconnected islands")
	TheSim:StartTimer()
	local repaired = 0
	-- flatten these mappings

	for i,v in pairs(islandmappings) do
		local count = 0
		local flattened = {}
		for i,v in pairs(v) do
			count = count + 1
		end
		if count > 1 then
			RepairIslands(islandTiles, i, v) 
			repaired = repaired + 1
		end
	end
	local time = TheSim:StopTimer()
	if repaired == 0 then
		print(string.format("Done - Nothing to repair - took %2.2f seconds", time))
	else
		print(string.format("Repaired %d islands, took %2.2f seconds", repaired, time))
	end
	islandmappings = {}
	islandTiles = {}
end
