require("constants")


local assets =
{
	--Asset( "IMAGE", texture ),
	--Asset( "SHADER", shader ),
}

local MAX_FLOOD_WIDTH = 52 --Number of tiles, how many is too many?
local TILE_SIZE = 2

local prefabs =
{
	--"mosquito",
	--"frog", 
--	"floodtile",
}


--[[

Old stuff 

local function OnWaterLevelChanged(inst, waterlevel, waterlevelprev)
	--print(waterlevel .. ", ".. waterlevelprev)
	if waterlevel > 1 then
		inst.FloodingEntity:SetRadius(2 * waterlevel)
		GetWorld().components.flooding:BroadcastFloodChange()
	end
end

local function OnWaterLevelZero(inst)
	--print("Flood dried up!")
	--inst.FloodingEntity:SetRadius(0)
	--inst:Remove()
end

]]



--Input positions should be relative to the position of this prefab 
local function getFloodTileAtLocalPosition(inst,x,y,z)
	local leftX = 1-MAX_FLOOD_WIDTH/2 * TILE_SIZE 
	local bottomZ = 1-MAX_FLOOD_WIDTH/2 * TILE_SIZE 

	local xDiff  = x - leftX 
	local zDiff = z - bottomZ

	local xIndex = math.floor(xDiff/TILE_SIZE) + 1 
	local zIndex = math.floor(zDiff/TILE_SIZE) + 1
	if inst.tilegrid[xIndex]and inst.tilegrid[xIndex][zIndex] then 
		return inst.tilegrid[xIndex][zIndex].tile or nil 
	end 
end 

local function getFloodTileAtWorldPosition(inst, x,y,z)
	local mx, my, mz = inst.Transform:GetWorldPosition()
	return getFloodTileAtLocalPosition(inst,x-mx, y-my, z-mz)
end 

local function getFloodTileUnderMouse(inst)

	local pos = TheInput:GetWorldPosition()
	local tile = getFloodTileAtWorldPosition(inst, pos.x, pos.y,pos.z)
	return tile 
end 


local function testpos(x,y,z) --Is this a valid place to put a flood tile? 
	local map = GetWorld().Map
	local ground =  map:GetTileAtPoint(x ,y, z)
	if  map:IsWater(ground) and not map:IsShore(ground) then
		return false 
	end 
	return true 
end 

--If the blockers position is on the tilemap, mark the tile as blocked
local function addFloodBlocker(inst, blocker)
	--print("add flood blocker", inst)
	local bx, by, bz = blocker.Transform:GetWorldPosition()
	local tile =  getFloodTileAtWorldPosition(inst, bx, by, bz)
	if tile then 
		tile.blocked = true 
	end 
end 


--It the blockers position is on the tilemap, mark the tile as not blocked 
local function removeFloodBlocker(inst, blocker)
	local bx, by, bz = blocker.Transform:GetWorldPosition()
	local tile =  getFloodTileAtWorldPosition(inst, bx, by, bz)
	if tile then 
		tile.blocked = false
	end 
end 

local function createtiles(inst) 
	--Create the tilemap and tiles for all valid positions 
 	for i = 1, MAX_FLOOD_WIDTH, 1 do 
		inst.tilegrid[i] = {}
		for j = 1, MAX_FLOOD_WIDTH, 1 do 
			local x, y, z = inst.Transform:GetWorldPosition()
    		x = x + (i - math.floor(MAX_FLOOD_WIDTH/2)) * TILE_SIZE 
    		z = z + (j - math.floor(MAX_FLOOD_WIDTH/2))  * TILE_SIZE 
			inst.tilegrid[i][j] = {}
			if testpos(x,y,z) then 
				local tile = SpawnPrefab("floodtile")
				tile:setDepth(0)
	    		tile.Transform:SetPosition( x, .01, z )
	    		inst.tilegrid[i][j].tile = tile 
	    		inst.tilegrid[i][j].tile.x = i 
	    		inst.tilegrid[i][j].tile.y = j

	    		inst.validTiles[#inst.validTiles + 1] = tile
	    		local map = GetWorld().Map
				local ground =  map:GetTileAtPoint(x ,y, z)
				if map:IsShore(ground) then
				--if ground == GROUND.OCEAN_SHORE then 
					inst.rootTiles[#inst.rootTiles + 1] = inst.tilegrid[i][j] 
				end 
	    		--tile:doDepthDelta(5)
	    	end 
		end 
	end 
	
	--Find all existing flood blocking entities and mark the corresponding tiles as blocked 
	local x, y, z = inst.Transform:GetWorldPosition()
	local range = MAX_FLOOD_WIDTH/2 * TILE_SIZE + 4 -- +4 margin just to be sure? 
	local blockers = TheSim:FindEntities(x, y, z, range, {"floodblocker"})

	if #blockers > 0 then
		for i = 1, #blockers do
			addFloodBlocker(inst, blockers[i])
		end 
	end 
end




local function getwaterrise(inst)
	return 1
end 


local function equalizeTiles(tile1, tile2)
	local diff = math.abs(tile1.depth - tile2.depth)
	if diff < 2 then 
		return 
	end
	local change = math.floor(diff/2)
	if tile1.depth > tile2.depth then 
		tile1:doDepthDelta(-change)
		tile2:doDepthDelta(change)
	else 
		tile1:doDepthDelta(change)
		tile2:doDepthDelta(-change)
	end  
end  


local function getneighbourtile(inst, x, y, index) 
	assert(index >= 0 and index <=3 )

	if index == 0 then --up
		y = y - 1 
	elseif index == 1 then --right
		x = x + 1
	elseif index == 2 then --down 
		y = y + 1 
	elseif index == 3 then --left
		x = x - 1 
	end 
	if x >= 1 and y >= 1 and x <= MAX_FLOOD_WIDTH and y <= MAX_FLOOD_WIDTH then 
		return inst.tilegrid[x][y].tile
	end 
end 


local function dogrowth(inst)
	for i = 1, #inst.rootTiles, 1 do 
		inst.rootTiles[i].tile:doDepthDelta(getwaterrise(inst))
	end 	
end 



local function dospread(inst)
	local tilesperupdate = #inst.validTiles/1 --Do the spread update over multiple frames... if we want... right now it just does them all 

	for i = 1, tilesperupdate, 1 do
		if inst.currentIndex == 1 then 
			dogrowth(inst)
		end 
		local tile = inst.validTiles[inst.currentIndex]
		if tile.blocked ~= true then 
			local x = tile.x 
			local y = tile.y 
			--Check surrounding tiles, starting with a random one 
			
			for j = 0, 3, 1 do 
				local start = 1 
				local neighbour = getneighbourtile(inst, x, y, (start + j) % 4 )
				if neighbour ~= nil and neighbour.blocked ~= true then 
					equalizeTiles(tile, neighbour)
				end 
			end 
		end 
		inst.currentIndex = inst.currentIndex + 1
		if inst.currentIndex > #inst.validTiles then 
			inst.currentIndex = 1 
		end 
	end 
end 




local function doupdate(inst)
	--[[
	local tile = getFloodTileUnderMouse(inst)

	if tile and TheInput:IsKeyDown(KEY_SHIFT) then 
		if TheInput:IsMouseDown(MOUSEBUTTON_LEFT) then 
			tile:doDepthDelta(1)
		elseif TheInput:IsMouseDown(MOUSEBUTTON_RIGHT) then 
			tile:doDepthDelta(-1)
		end 
	end 
	]]
	--dogrowth(inst)
	if inst.updateCount == nil then inst.updateCount = 0 end 
	inst.updateCount = inst.updateCount + 1 
	if inst.updateCount == 10 then 
		dospread(inst)
		inst.updateCount = 0 
	end 
end 

local function startflood(inst)
	--Just put one root tle from the middle for now 
	 --inst.rootTiles[1] = inst.tilegrid[math.floor(MAX_FLOOD_WIDTH/2)][math.floor(MAX_FLOOD_WIDTH/2)]
	inst.growthTask = inst:DoPeriodicTask(FRAMES*1, function(inst) doupdate(inst) end)
end 

local function setup(inst)
	--position myself in the proper space based on tiles I guess that would mean right on the intersection of four tiles? 
	local ptx, pty, ptz = inst.Transform:GetWorldPosition()
	local x,y,z = GetWorld().Map:GetTileCenterPoint(ptx,pty,ptz)
	--x = x + 2
	--y = y + 2
	inst.Transform:SetPosition(x+ TILE_SIZE/2,y,z+ TILE_SIZE/2)
	createtiles(inst)

	--bargle 
	startflood(inst)
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	--inst.entity:AddFloodingEntity()

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "pond_cave.png" )

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

	inst.tilegrid = {} --All possible positions for tiles within the max size 
	inst.rootTiles = {} --The sources of the flood, water gets added to the system through these tiles 
	inst.validTiles = {} --Tile pointers that point to an actual tile as opposed to nil, for more effecient iteration during updates. 

	inst.currentIndex = 1 --To track tile updates over multiple frames 

	inst:DoTaskInTime(1, setup)

	--For when a sandbag or other flodd blcoker is created 
	inst:ListenForEvent("floodblockercreated", 
		function(it, data)
			addFloodBlocker(inst, data.blocker)
		end, 
	GetWorld())

	--For when a sandbag or other floodblocker is removed 
	inst:ListenForEvent("floodblockerremoved", 
		function(it, data)
			removeFloodBlocker(inst, data.blocker)
		end, 
	GetWorld())

	--@bargle:todo 
	inst.OnSave = function(inst, data)
	end
	--@bargle:todo
	inst.OnLoad = function(inst, data)
	end

    return inst
end

return Prefab( "shipwrecked/objects/floodspawner", fn, assets, prefabs )
