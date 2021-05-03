local wallWidth = 7
local wallLength = 24

local BigPopupDialogScreen = require "screens/bigpopupdialog"
local PopupDialogScreen = require "screens/popupdialog"

local function GetVerb(inst, doer)
	return STRINGS.ACTIONS.JUMPIN.ENTER
end

local ANTHILL_DUNGEON_NAME = "ANTHILL1"

-- don't ask 'why these numbers'
-- Well, okay - It's a good bit out of the map gen space but within max world extents (2048)
-- (and they had to be a good bit apart from each other as well)
-- I just picked something with those constraints
-- (update: well, that didn't pan out well, see InteriorSpawner.FixForSpawnOriginMigration)
local interior_spawn_origin = Vector3(2000,0,0)
local interior_spawn_storage_origin = Vector3(2000,0,2000)

local InteriorSpawner = Class(function(self, inst)
    self.inst = inst

	self:SetUpInteriorManagement()
	
    self.interiors = {}

	self.doors = {}

	self.next_interior_ID = 0

	self.getverb = GetVerb

	self.interior_spawn_origin = nil

	self.current_interior = nil

	-- true if we're considered inside an interior, which is also during transition in/out of
	self.considered_inside_interior = {}

	self.from_inst = nil		
	self.to_inst = nil	
	self.to_target = nil
	
	self.prev_player_pos_x = 0.0
	self.prev_player_pos_y = 0.0
	self.prev_player_pos_z = 0.0
	
	self.interiorEntryPosition = Vector3()

	self.dungeon_entries = {}

	self.exteriorCamera = TheCamera
	self.interiorCamera = InteriorCamera()

	self.homeprototyper = SpawnPrefab("home_prototyper")
	self.homeprototyper.Transform:SetPosition(interior_spawn_storage_origin:Get())
	-- for debugging the black room issue
	self.alreadyFlagged = {}
	self.was_invincible = false

	self.player_homes = {}

	-- This has to happen after the fade for....reasons
	self.inst:DoTaskInTime(2, function() self:getSpawnOrigin() end)

	self.inst:DoTaskInTime(1, function() self:FixDoors() end)
	self.inst:DoTaskInTime(0.1, function() self:CleanupBlackRoomAfterHiddenDoor() end)

	-- Tear down the wall!
	self.inst:DoTaskInTime(0.1, function() self:WallCleanUp() end)

	-- Fixup because the items weren't put back in locked cabinets
	self.inst:DoTaskInTime(2, function() self:FixShelfItems() end)
                              
	-- Fixup mirrored ruins from beta bug. Alas, anthills were affected as well
	self.inst:DoTaskInTime(0.1, function() 
									self:UnRuinRuins() 
									self:FixupAnthills() 
								end)

	-- Fixup doors pointing nowhere, from beta - after the door name fixing	
	self.inst:DoTaskInTime(1.1, function() self:FixupDoorsPointingNowhere() end)
	self.inst:DoTaskInTime(0, function() 
									self:InvertPlayerInteriors() 
									self:FixupPlayerInteriorGridError()
									self:FixupPlayerInteriorGridDuplicates()
								end)

	-- Some more cleanup
	self.inst:DoTaskInTime(0.1, function() 
									self:RenameQueenChamberDungeon() 
									-- Fixup has to happen after the rename
									self:FixupQueenChamberDoors()
								end)
    -- Guess...
	self.inst:DoTaskInTime(0, function() 
									self:FixupVampireBatCaves()	
							    end)
end)

local NO_INTERIOR = -1

function InteriorSpawner:CreateWalls()
	-- create 4 walls will be reconfigured for each room
	self.walls = {}
	local origWidth = 1
	local delta = (2 * wallWidth - 2 * origWidth) / 2

	local wall 

	local spawnStorage = self:getSpawnStorage()

	wall = SpawnPrefab("generic_wall_back")
	--wall.Transform:SetPosition(x - (interior_definition.depth/2) +1 - delta,y,z)
	wall.Transform:SetPosition(spawnStorage.x, spawnStorage.y, spawnStorage.z)
	wall.setUp(wall,wallLength, nil, nil, wallWidth)
	self.walls[1] = wall

	-- front wall
	wall = SpawnPrefab("generic_wall_back")
	--wall.Transform:SetPosition(x + (interior_definition.depth/2) + 3 + delta,y,z)
	wall.Transform:SetPosition(spawnStorage.x, spawnStorage.y, spawnStorage.z)
	wall.setUp(wall,wallLength, nil, nil, wallWidth)
	self.walls[2] = wall	
	--Spawn Side Walls [TODO] Base Values On Interior Width And Height

	-- right wall
	wall = SpawnPrefab("generic_wall_back")
	--wall.Transform:SetPosition(x,y,z + (interior_definition.width/2) +1+delta)
	wall.Transform:SetPosition(spawnStorage.x, spawnStorage.y, spawnStorage.z)
	wall.setUp(wall,wallWidth,nil,nil,wallLength)				
	self.walls[3] = wall
	
	-- left wall
	wall = SpawnPrefab("generic_wall_back")
	--wall.Transform:SetPosition(x,y,z - (interior_definition.width/2) -1-delta)
	wall.Transform:SetPosition(spawnStorage.x, spawnStorage.y, spawnStorage.z)
	wall.setUp(wall,wallWidth,nil,nil,wallLength)
	self.walls[4] = wall

	return self.walls
end

-- When we have an old save where we exited this world from inside an interior 
-- and we come back another way (eg house on volcano), come back through main island and seaworthy)
-- we would be be stuck in interior mode but we really are not in interior mode
function InteriorSpawner:CheckIfPlayerIsInside()
	local player = GetPlayer()
	player:UpdateIsInInterior()
	if self.current_interior and not player:CheckIsInInterior() then
		-- Play an instant transition out of this interior (no fades)
		self:PlayTransition(GetPlayer(), nil, nil, GetPlayer():GetPosition(), true, true)
	end
end

function InteriorSpawner:SetUpInteriorManagement()
	InteriorManager:SetInteriorTile(GROUND.INTERIOR)
	InteriorManager:SetCurrentCenterPos2d( interior_spawn_origin.x, interior_spawn_origin.z )
	InteriorManager:SetDormantCenterPos2d( interior_spawn_storage_origin.x, interior_spawn_storage_origin.z )
end

function InteriorSpawner:FixShelfItems()
	for i,v in pairs(Ents) do
		if v.components.inventoryitem and v.onshelf then
			local shelf = v.onshelf
			local pocket = shelf.components.pocket
			local pocketitem = pocket:GetItem("shelfitem")
			-- if there's something in the pocket we have a different issue, don't touch it
			if shelf and not pocketitem then
				-- check if the shelf_slot contains us?
				local shelfer = shelf.components.shelfer
				if shelfer then
					local gift = shelfer:GetGift()
					if gift ~= v then
						-- in case it's locked (and it probably is, because that's why this whole function is here)
						local enabled = shelfer.enabled
						shelfer.enabled = true
						shelfer:UpdateGift(nil, v)	
						-- and lock it again if needed
						if enabled then
							shelfer:Enable()
						else
							shelfer:Disable()
						end
					end
				end
			end
		end
	end
end

function InteriorSpawner:WallCleanUp()
	-- Delete all existing instances of generic_wall_back. There's a ton of em that aren't needed and are wrong to boot
	local entsToRemove = {}
	for i,v in pairs(Ents) do
		if v.prefab == "generic_wall_back" and not table.contains(self.walls, v) then
			entsToRemove[v] = true
			v:Remove()
		end
	end
	-- see if any interior was referencing any of these walls, if so, remove them
	for _,interior in pairs(self.interiors) do
		if interior.object_list and #interior.object_list > 0 then
			local new_list = {}
			for n,obj in pairs(interior.object_list) do
				if not entsToRemove[obj] then
					table.insert(new_list, obj)
				end
			end
			interior.object_list = new_list
		end
	end


	
end

function InteriorSpawner:ConfigureWalls(interior)
	self.walls = self.walls or self:CreateWalls()

	local spawnOrigin = self:getSpawnOrigin()
	local x,y,z = spawnOrigin.x, spawnOrigin.y, spawnOrigin.z

	local origwidth = 1
	local delta = (2 * wallWidth - 2 * origwidth) / 2

	local depth = interior.depth
	local width = interior.width

	-- back, front wall
	self:Teleport(self.walls[1], Vector3(x - (depth/2) - 1 - delta,y,z))
	self:Teleport(self.walls[2], Vector3(x + (depth/2) + 1 + delta,y,z))

	-- left, right wall
	self:Teleport(self.walls[3], Vector3(x,y,z + (width/2) + 1 + delta))
	self:Teleport(self.walls[4], Vector3(x,y,z - (width/2) - 1 -delta))

	for i=1,4 do
		self.walls[i]:ReturnToScene()
		self.walls[i]:RemoveTag("INTERIOR_LIMBO")
	end

	-- stomp out the walls for pathfinding
	self:SetUpPathFindingBarriers(x,y,z,width, depth)
end

function InteriorSpawner:SetUpPathFindingBarriers(x,y,z,width, depth)
    local ground = GetWorld()
	self.pathfindingBarriers = {}
    if ground then
		for r = -width/2, width/2 do
			table.insert(self.pathfindingBarriers, Vector3(x+(depth/2)+0.5, y, z+r))
			table.insert(self.pathfindingBarriers, Vector3(x-(depth/2)-0.5, y, z+r))
		end
		for r = -depth/2, depth/2 do
			table.insert(self.pathfindingBarriers, Vector3(x+r,y,z-(width / 2)-0.5))
			table.insert(self.pathfindingBarriers, Vector3(x+r,y,z+(width / 2)+0.5))
		end
	end
	for i,pt in pairs(self.pathfindingBarriers) do
		ground.Pathfinder:AddWall(pt.x, pt.y, pt.z)
		--local r = SpawnPrefab("acorn")
		--RemovePhysicsColliders(r)
		--r.Transform:SetPosition(pt.x, pt.y, pt.z)
	end
end

function InteriorSpawner:ClearPathfindingBarriers()
    local ground = GetWorld()
	for i,pt in pairs(self.pathfindingBarriers) do
		ground.Pathfinder:RemoveWall(pt.x, pt.y, pt.z)
	end
	self.pathfindingBarriers = {}
end

local dodebug = false

-- local function doprint(text)
-- 	if dodebug then
-- 		print(text)
-- 	end
-- end

local EAST  = { x =  1, y =  0, label = "east" }
local WEST  = { x = -1, y =  0, label = "west" }
local NORTH = { x =  0, y =  1, label = "north" }
local SOUTH = { x =  0, y = -1, label = "south" }

local dir_str =
{
	"north",
	"east",
	"south",
	"west",
}

local op_dir_str =
{
	["north"] = "south",
	["east"]  = "west",
	["south"] = "north",
	["west"]  = "east",
}

local dir =
{
    EAST,
    WEST,
    NORTH,
    SOUTH,
}

local dir_opposite =
{
    WEST,
    EAST,
    SOUTH,
    NORTH,
}

function createInteriorHandle(interior)
	
	local wallsTexture = "levels/textures/interiors/harlequin_panel.tex"
	local floorTexture = "levels/textures/interiors/noise_woodfloor.tex"

	if interior.walltexture ~= nil then
		wallsTexture = interior.walltexture
	end

	if interior.floortexture ~= nil then
		floorTexture = interior.floortexture
	end

	local height = 5
	if interior.height then
		height = interior.height
	end

	local handle = InteriorManager:CreateInterior(interior.width, height, interior.depth, wallsTexture, floorTexture)  

	GetWorld().Map:AddInterior( handle )		

	return handle
end

function InteriorSpawner:UpdateInteriorHandle(interior) 	
	GetWorld().Map:SetInteriorFloorTexture( interior.handle, interior.floortexture )
	GetWorld().Map:SetInteriorWallsTexture( interior.handle, interior.walltexture )
end

-- fixup all the stored rooms. Entities are around worldgen interior_spawn_storage's position. 
-- Since Spawn storage moved (and interior_spawn_storage is not used anymore), update all the interior's stored entities to hang around at the new location
function InteriorSpawner:FixupSpawnStorage(originalStorageLocation, newStorageLocation)
	print("Migrating Storage Origin")
	for i,interior in pairs(self.interiors) do
		--print(i,interior)
		if interior.object_list and #interior.object_list > 0 then
			local storageOriginDelta = newStorageLocation - originalStorageLocation
			for n,obj in pairs(interior.object_list) do
				--print("",n,obj)
				local position = obj:GetPosition()
				position = position + storageOriginDelta
				self:Teleport(obj, position, true)
			end
		end
	end
end

-- If the game was saved inside an interior its entities will be around the worldgenned interior_spawn_origin
-- Since the spawn location moved - move those entities
function InteriorSpawner:FixupSpawnOrigin(originalSpawnLocation, newSpawnLocation)
	if self.current_interior then
		print("Migrating Spawn Origin")
		-- scoop up the entities around the spawn location
		-- can't use self:GetCurrentInteriorEntities, it'll be using the wrong position now
		-- (and I dare not set it after because I don't know what interactions happen, and I want them to refer to the new location)
		local ents = TheSim:FindEntities(originalSpawnLocation.x, originalSpawnLocation.y, originalSpawnLocation.z, 20, nil, {"INTERIOR_LIMBO","interior_spawn_storage"})
		assert(ents ~= nil)

		local prev_ents = ents
		for i = #ents, 1, -1 do
			if ents[i]:HasTag("interior_spawn_origin") or ents[i]:HasTag("INTERIOR_LIMBO_IMMUNE") then
				table.remove(ents, i)		
			end		
		end

		local spawnOriginDelta = newSpawnLocation - originalSpawnLocation
		-- move em!
		for i,obj in pairs(ents) do
			if not obj.parent then
				local position = obj:GetPosition()
				position = position + spawnOriginDelta
				self:Teleport(obj, position, true)
			end
		end

		self.spawnOriginDelta = spawnOriginDelta
	end
end

-- Clean up the what remains in the map of the original island used to hold interiors. 
-- Called with a delay because we don't want some objects to think they're not on land
function InteriorSpawner:CleanUpOldStorageLocation()
	print("Removing interior storage location created by worldgen")
	local ground = GetWorld()
	local w,h = ground.Map:GetSize()
	for x = 0,w-1 do
		for y=-0,h-1 do
			local tile = ground.Map:GetTile(x,y)
			if tile == GROUND.INTERIOR then 
				ground.Map:SetTile(x,y,GROUND.IMPASSABLE)
			end
		end
	end
end

function InteriorSpawner:getSpawnOrigin()
	local pt = nil
	if not self.interior_spawn_origin then
		self.interior_spawn_origin = Vector3(interior_spawn_origin:Get())
		InteriorManager:SetCurrentCenterPos2d( self.interior_spawn_origin.x, self.interior_spawn_origin.z )
		for k, v in pairs(Ents) do
			if v:HasTag("interior_spawn_origin") and not v.fixedInteriorLocation then
				v.fixedInteriorLocation = true
				self:FixupSpawnOrigin(v:GetPosition(),  interior_spawn_origin)
			end
		end		
		self.inst:DoTaskInTime(2, function() self:CleanUpOldStorageLocation() end)
	end	
	return Vector3(self.interior_spawn_origin:Get())
end

function InteriorSpawner:getSpawnStorage()
	local pt = nil
	if not self.interior_spawn_storage_origin then
		for k, v in pairs(Ents) do
			if v:HasTag("interior_spawn_storage") and not v.fixedInteriorLocation then
				v.fixedInteriorLocation = true
				self:FixupSpawnStorage(v:GetPosition(), interior_spawn_storage_origin)
			end
		end
		self.interior_spawn_storage_origin = Vector3(interior_spawn_storage_origin:Get())
		InteriorManager:SetDormantCenterPos2d( self.interior_spawn_storage_origin.x, self.interior_spawn_storage_origin.z )
	end	
	return Vector3(self.interior_spawn_storage_origin:Get())
end

function InteriorSpawner:PushDirectionEvent(target, direction)
	target:UpdateIsInInterior()
end

function InteriorSpawner:CheckIsFollower(inst)
	local isfollower = false
	-- CURRENT ASSUMPTION IS THAT ONLY THE PLAYER USES DOORS!!!!
	local player = GetPlayer()

	local eyebone = nil

	for follower, v in pairs(player.components.leader.followers) do					
		if follower == inst then
			isfollower = true
		end
	end

	if player.components.inventory then
		for k, item in pairs(player.components.inventory.itemslots) do

			if item.components.leader then
				if item:HasTag("chester_eyebone") then
					eyebone = item
				end
				for follower, v in pairs(item.components.leader.followers) do
					if follower == inst then
						isfollower = true
					end
				end
			end
		end
		-- special special case, look inside equipped containers
		for k, equipped in pairs(player.components.inventory.equipslots) do
			if equipped and equipped.components.container then

				local container = equipped.components.container
				for j, item in pairs(container.slots) do
					
					if item.components.leader then
						if item:HasTag("chester_eyebone") then
							eyebone = item
						end
						for follower, v in pairs(item.components.leader.followers) do
							if follower == inst then
								isfollower = true
							end
						end
					end
				end
			end
		end
		-- special special special case: if we have an eyebone, then we have a container follower not actually in the inventory. Look for inventory items with followers there.
		if eyebone and eyebone.components.leader then
			for follower, v in pairs(eyebone.components.leader.followers) do
				
				if follower and (not follower.components.health or (follower.components.health and not follower.components.health:IsDead())) and follower.components.container then					
					for j,item in pairs(follower.components.container.slots) do

						if item.components.leader then
							for follower, v in pairs(item.components.leader.followers) do
								if follower and (not follower.components.health or (follower.components.health and not follower.components.health:IsDead())) then
									if follower == inst then
										isfollower = true
									end
								end
							end
						end
					end
				end
			end
		end
	end

	-- spells that are targeting the player are...followers too
	if inst.components.spell and inst.components.spell.target == GetPlayer() then
		isfollower = true
	end

	if inst and not isfollower and inst:GetGrandParent() == GetPlayer() then
		print("FOUND A CHILD",inst.prefab)
		isfollower = true
	end

	return isfollower
end

function InteriorSpawner:ExecuteTeleport(doer, destination, direction)	
	self:Teleport(doer, destination)

	if direction then
		self:PushDirectionEvent(doer, direction)
	end

	if doer.components.leader then
		for follower, v in pairs(doer.components.leader.followers) do			
			self:Teleport(follower, destination)
			if direction then
				self:PushDirectionEvent(follower, direction)
			end
		end
	end

	local eyebone = nil

	--special case for the chester_eyebone: look for inventory items with followers
	if doer.components.inventory then
		for k, item in pairs(doer.components.inventory.itemslots) do

			if direction then
				self:PushDirectionEvent(item, direction)
			end

			if item.components.leader then
				if item:HasTag("chester_eyebone") then
					eyebone = item
				end
				for follower,v in pairs(item.components.leader.followers) do
					self:Teleport(follower, destination)
				end
			end
		end
		-- special special case, look inside equipped containers
		for k, equipped in pairs(doer.components.inventory.equipslots) do
			if equipped and equipped.components.container then

				if direction then
					self:PushDirectionEvent(equipped, direction)
				end

				local container = equipped.components.container
				for j, item in pairs(container.slots) do
					
					if direction then
						self:PushDirectionEvent(item, direction)
					end

					if item.components.leader then
						if item:HasTag("chester_eyebone") then
							eyebone = item
						end
						for follower,v in pairs(item.components.leader.followers) do
							self:Teleport(follower, destination)
						end
					end
				end
			end
		end
		-- special special special case: if we have an eyebone, then we have a container follower not actually in the inventory. Look for inventory items with followers there.
		if eyebone and eyebone.components.leader then
			for follower, v in pairs(eyebone.components.leader.followers) do

				if direction then
					self:PushDirectionEvent(follower, direction)
				end
				
				if follower and (not follower.components.health or (follower.components.health and not follower.components.health:IsDead())) and follower.components.container then					
					for j, item in pairs(follower.components.container.slots) do

						if direction then
							self:PushDirectionEvent(item, direction)
						end

						if item.components.leader then
							for follower, v in pairs(item.components.leader.followers) do
								if follower and (not follower.components.health or (follower.components.health and not follower.components.health:IsDead())) then
									self:Teleport(follower, destination)
								end
							end
						end
					end
				end
			end
		end
	end


	if doer == GetPlayer() and GetPlayer().components.kramped then
		
		local kramped = GetPlayer().components.kramped
		kramped:TrackKrampusThroughInteriors(destination)
end
end

function InteriorSpawner:Teleport(obj, destination, dontRotate)
	-- at this point destination can be a prefab or just a pt. 
	local pt = nil
	if destination.prefab then
		pt = destination:GetPosition()
	else
		pt = destination
	end

	if not obj:IsValid() then return end


	if obj.Physics then
		if obj.Transform then 
			local displace = Vector3(0,0,0)
			if destination.prefab and destination.components.door and destination.components.door.outside then
				local down = TheCamera:GetDownVec()	
				local angle = math.atan2(down.z, down.x)
				obj.Transform:SetRotation(angle)

			elseif destination.prefab and destination.components.door and destination.components.door.angle then
				obj.Transform:SetRotation(destination.components.door.angle)
				print("destination.components.door.angle",destination.components.door.angle)
				--displace.x = math.cos(
				local angle = (destination.components.door.angle * 2 * PI) / 360
				local magnitude = 1
				local dx = math.cos(angle) * magnitude
				local dy = math.sin(angle) * magnitude
				print("dx,dy",dx,dy)
				displace.x = dx
				displace.z = -dy
			else
				if not dontRotate then
					obj.Transform:SetRotation(180)	
				end
			end			
			obj.Physics:Teleport(pt.x + displace.x, pt.y + displace.y, pt.z + displace.z)
		end 
	elseif obj.Transform then
		obj.Transform:SetPosition(pt.x, pt.y, pt.z)
	end
end


function InteriorSpawner:FadeInFinished(was_invincible)
	-- Last step in transition
	local player = GetPlayer()
	player.components.health:SetInvincible(was_invincible)
	
	player.components.playercontroller:Enable(true)
	GetWorld():PushEvent("enterroom")
end	

function InteriorSpawner:SetCameraOffset(cameraoffset, zoom)
	local pt = self:getSpawnOrigin()

	-- cameraoffset = -2
	-- zoom = 35
	
	TheCamera.interior_currentpos_original = Vector3(pt.x+cameraoffset, 0, pt.z)
	TheCamera.interior_currentpos = Vector3(pt.x+cameraoffset, 0, pt.z)

	TheCamera.interior_distance = zoom
end

local function GetTileType(pt)
	local ground = GetWorld()
	local tile
	if ground and ground.Map then
		tile = ground.Map:GetTileAtPoint(pt:Get())
	end
	local groundstring = "unknown"
	for i,v in pairs(GROUND) do
		if tile == v then
			groundstring = i
		end
	end
	return groundstring
end

function InteriorSpawner:GetDoor(door_id)
	return self.doors[door_id]
end

function InteriorSpawner:ApplyInteriorCamera(destination)
	local pt = self:getSpawnOrigin()
	self:ApplyInteriorCameraWithPosition(destination, pt)
end

function InteriorSpawner:ApplyInteriorCameraWithPosition(destination, pt)
	local cameraoffset = -2.5 		--10x15
	local zoom = 23
		
	if destination.cameraoffset and destination.zoom then
		cameraoffset = destination.cameraoffset
		zoom = destination.zoom
	elseif destination.depth == 12 then    --12x18
		cameraoffset = -2
		zoom = 25
	elseif destination.depth == 16 then --16x24
		cameraoffset = -1.5
		zoom = 30
	elseif destination.depth == 18 then --18x26
		cameraoffset = -2 -- -1
		zoom = 35
	end
		
	TheCamera.interior_currentpos_original = Vector3(pt.x+cameraoffset, 0, pt.z)
	TheCamera.interior_currentpos = Vector3(pt.x+cameraoffset, 0, pt.z)

	TheCamera.interior_distance = zoom
end

function InteriorSpawner:FadeOutFinished(dont_fadein)
	-- THIS ASSUMES IT IS THE PLAYER WHO MOVED
	local player = GetPlayer()

	local x, y, z = player.Transform:GetWorldPosition()
	self.prev_player_pos_x = x
	self.prev_player_pos_y = y
	self.prev_player_pos_z = z

	-- Now that we are faded to black, perform transition
	TheFrontEnd:SetFadeLevel(1)
	--current_inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door") 
	
	local wasinterior = TheCamera.interior

	--if the door has an interior name, then we are going to a room, otherwise we are going out
	if self.to_interior then
		TheCamera = self.interiorCamera		
	--	TheCamera:SetTarget( self.interior_spawn_origin )		
	else		
		TheCamera = self.exteriorCamera
	end

	local direction = nil
	if wasinterior and not TheCamera.interior then		
		direction = "out"		
		-- if going outside, blank the interior color cube setting.
		GetWorld().components.colourcubemanager:SetInteriorColourCube(nil)
	end
	if not wasinterior and TheCamera.interior then
		-- If the user is the player, then the perspective of things will move inside
		direction = "in"		

		local x, y, z = player.Transform:GetWorldPosition()
		-- if there happens to be a door into this dungeon then use that instead
		self:SetInteriorEntryPosition(x,y,z)
	end

	local from_interior = self.current_interior

	self:UnloadInterior()

	GetWorld().components.ambientsoundmixer:SetReverbPreset("default")

	local destination = self:GetInteriorByName(self.to_interior) 
	
	if destination then

		if destination.reverb then
			GetWorld().components.ambientsoundmixer:SetReverbPreset(destination.reverb)			
		end

		-- set the interior color cube
		GetWorld().components.colourcubemanager:SetInteriorColourCube( destination.cc )
		
		self:LoadInterior(destination)

		-- Configure The Camera	
		self:ApplyInteriorCamera(destination)
	else
		GetWorld().Map:SetInterior( NO_INTERIOR )		
	end

    if direction == "in" then
		local x, y, z = player.Transform:GetWorldPosition()
		self:SetInteriorEntryPosition(x,y,z)
	end


	local to_target_position
	if not self.to_target and self.from_inst.components.door then
		-- by now the door we want to spawn at should be created and/or placed.	
		self.to_target = self.doors[self.from_inst.components.door.target_door_id].inst
		if direction == "out" then
			local radius = 1.75
			if self.to_target and self.to_target:IsValid() then
				if self.to_target and self.to_target.Physics then
					radius = self.to_target.Physics:GetRadius() + GetPlayer().Physics:GetRadius()
				end
				-- make sure this is a walkable spot
				local pt = self.to_target:GetPosition()

				local cameraAngle = TheCamera:GetHeadingTarget()
				local angle = cameraAngle * 2 * PI / 360
				local offset = FindValidExitPoint(pt,-angle,radius,8, 0.75)
				if offset then
					self.to_target = pt + offset
				end
			else
				local cameraAngle = TheCamera:GetHeadingTarget()
				local angle = cameraAngle * 2 * PI / 360
				local pt = Vector3(self:GetInteriorEntryPosition(from_interior))
				self.to_target = pt
				local offset = FindValidExitPoint(pt,-angle,radius,8, 0.75)
				if offset then
					self.to_target = pt + offset
				end
			end
		end
	end


	self:ExecuteTeleport(player, self.to_target, direction)
	-- Log some info for debugging purposes
	if destination then
		local pt1 = self:getSpawnOrigin()
		local pt2 = self:getSpawnStorage()
		print("SpawnOrigin:",pt1,GetTileType(pt1))
		print("SpawnStorage:",pt2,GetTileType(pt2))
		print("SpawnDelta:",pt2-pt1)
		local ppt = GetPlayer():GetPosition()
		print("Player at ",ppt, GetTileType(ppt))
	end

	GetPlayer().components.locomotor:UpdateUnderLeafCanopy() 

	if direction =="out" then
		-- turn off amb snd

		GetWorld():PushEvent("exitinterior", {to_target = self.to_target})
	elseif direction == "in" then
		--change amb sound ot this room.

		GetWorld():PushEvent("enterinterior", {to_target = self.to_target})
	end

	--GetWorld():PushEvent("onchangecanopyzone", {instant=true})
	--local ColourCubeManager = GetWorld().components.colourcubemanager
	--ColourCubeManager:StartBlend(0)

	if player:HasTag("wanted_by_guards") then
		player:RemoveTag("wanted_by_guards")
		local x, y, z = player.Transform:GetWorldPosition()
		local ents = TheSim:FindEntities(x, y, z, 35, {"guard"})
		if #ents> 0 then
			for i, guard in ipairs(ents)do
				guard:PushEvent("attacked", {attacker = player, damage = 0, weapon = nil})
			end
		end
	end
	if self.from_inst and self.from_inst.components.door then
		GetWorld():PushEvent("doorused", {door = self.to_target, from_door = self.from_inst})
	end

	if self.from_inst and self.from_inst:HasTag("ruins_entrance") and not self.to_interior then
		GetPlayer():PushEvent("exitedruins")
	end

	if self.to_target.prefab then

		if self.to_target:HasTag("ruins_entrance") then
			GetPlayer():PushEvent("enteredruins")
			-- unlock all doors
			self:UnlockAllDoors(self.to_target)
		end

		if self.to_target:HasTag("shop_entrance") then
			GetPlayer():PushEvent("enteredshop")
		end	

		if self.to_target:HasTag("anthill_inside") then
			GetPlayer():PushEvent("entered_anthill")
		end

		if self.to_target:HasTag("anthill_outside") then
			GetPlayer():PushEvent("exited_anthill")
		end
	end

	TheCamera:SetTarget(GetPlayer())
	TheCamera:Snap()

	GetWorld():PushEvent("endinteriorcam")

	self.from_inst = nil

	self.to_target = nil
	if self.HUDon == true then
		GetPlayer().HUD:Show()
		self.HUDon = nil
	end

	if dont_fadein then
		self:FadeInFinished(self.was_invincible)
	else
		TheFrontEnd:Fade(true, 1, function() self:FadeInFinished(self.was_invincible) end)
	end
	GetWorld().doorfreeze = nil
end

function InteriorSpawner:GatherAllRooms(from_room, allrooms)
	if allrooms[from_room] then 
		-- already did this room
		return
	end
	allrooms[from_room] = true
	local interior = self:GetInteriorByName(from_room) 
	if interior then		
		--print("interior = ",interior)		
		--print("prefabs:",interior.prefabs)
		if interior.prefabs then
			-- room was never spawned
			--assert(false)
			for k, prefab in ipairs(interior.prefabs) do
				if prefab.name == "prop_door" then
					if  prefab.door_closed then
						prefab.door_closed["door"] = nil
					end
					local target_interior = prefab.target_interior	
					print("target_interior:",target_interior)
					if target_interior then
						self:GatherAllRooms(target_interior, allrooms)
					end
				end
			end
		else
			-- go through the object list and see what entities are doors
			if interior.object_list and #interior.object_list > 0 then
				--print("Room has been spawned but was unspawned")
				-- room was spawned but is unspawned
				for i,v in pairs(interior.object_list) do
					--print(i,v)
					if v.prefab == "prop_door" then
						if v.components.door then
							--v.components.door:checkDisableDoor(nil, "door")
							v:PushEvent("open", {instant=true})
							local target_interior = v.components.door.target_interior	
							--print("target_interior:",target_interior)
							if target_interior then
								self:GatherAllRooms(target_interior, allrooms)
							end
						end
					end
				end
			else
				-- we're in the room
				print("Inside the room")
				local ents = self:GetCurrentInteriorEntities()
				for i,v in pairs(ents) do
					if v.prefab == "prop_door" then
						--print(v)
						if v.components.door then
							--v.components.door:checkDisableDoor(nil, "door")
							v:PushEvent("open", {instant=true})
							local target_interior = v.components.door.target_interior	
							--print("target_interior:",target_interior)
							if target_interior then
								self:GatherAllRooms(target_interior, allrooms)
							end
						end
					end
				end
			end
		end
	else
		assert(false)
	end

end

function InteriorSpawner:UnlockAllDoors(from_door)
	-- gather all rooms that can be reached from this room
	local allrooms = {}
	local target_interior
	if from_door then
		target_interior = from_door.components.door and from_door.components.door.interior_name
	else
		target_interior = self.current_interior and self.current_interior.unique_name
	end
	if target_interior then
		print("Unlocking all doors coming from", target_interior)
		self:GatherAllRooms(target_interior, allrooms)
    else
		print("Nothing to unlock")
	end
	--for i,v in pairs(allrooms) do
	--	print(i,v)
	--end
end

function InteriorSpawner:PlayTransition(doer, inst, interiorID, to_target, dont_fadeout, dont_fadein)	
	-- the usual use of this function is with doer and inst.. where inst has the door component.

	-- but you can provide an interiorID and a to_target instead and bypass the door stuff.

	-- to_target can be a pt or an inst

	self.from_inst = inst
	
	self.to_interior = nil
	
	if interiorID then
		self.to_interior = interiorID
	else
		if inst then
			self.to_interior = inst.components.door.target_interior
		end
	end


	if to_target then		
		self.to_target = to_target
	end
	
	if doer:HasTag("player") then
		if self.to_interior then
			self:ConsiderPlayerInside(self.to_interior)
		end

		GetWorld().doorfreeze = true		
		self.was_invincible = doer.components.health:IsInvincible()
		doer.components.health:SetInvincible(true)
		

		doer.components.playercontroller:Enable(false)
		
		if GetPlayer().HUD and GetPlayer().HUD.shown then
			self.HUDon = true
			GetPlayer().HUD:Hide()
		end

		if dont_fadeout then
			self:FadeOutFinished(dont_fadein)
		else
			TheFrontEnd:Fade(false, 0.5, function() self:FadeOutFinished(dont_fadein) end)
		end
	else
		print("!!ERROR: Tried To Execute Transition With Non Player Character")
	end
end



function InteriorSpawner:GetNewID()
	self.next_interior_ID = self.next_interior_ID + 1
	return self.next_interior_ID
end

function InteriorSpawner:GetDir()
	return dir
end

function InteriorSpawner:GetNorth()
	return NORTH
end
function InteriorSpawner:GetSouth()
	return SOUTH
end
function InteriorSpawner:GetWest()
	return WEST
end
function InteriorSpawner:GetEast()
	return EAST
end

function InteriorSpawner:GetDirOpposite()
	return dir_opposite
end

function InteriorSpawner:GetOppositeFromDirection(direction)
	if direction == NORTH then
		return self:GetSouth()
	elseif direction == EAST then
		return self:GetWest()
	elseif direction == SOUTH then
		return self:GetNorth()
	else
		return self:GetEast()
	end
end

function InteriorSpawner:CreateRoom(interior, width, height, depth, dungeon_name, roomindex, addprops, exits, walltexture, floortexture, minimaptexture, cityID, cc, batted, playerroom, reverb, ambsnd, groundsound, cameraoffset, zoom, forceInteriorMinimap)
    if not interior then
        interior = "generic_interior"
    end
    if not width then            
        width = 15
    end
    if not depth then
        depth = 10
    end        

    assert(roomindex)

	-- SET A DEFAULT CC FOR INTERIORS
    if not cc then
    	cc = "images/colour_cubes/day05_cc.tex"
    end       

    local interior_def =
    {
        unique_name = roomindex,
        dungeon_name = dungeon_name,
        width = width,
        height = height,
        depth = depth,
        prefabs = {},
        walltexture = walltexture,
        floortexture = floortexture,
        minimaptexture = minimaptexture,
        cityID = cityID,
        cc = cc,
        visited = false,
        batted = batted,
        playerroom = playerroom,
        enigma = false,
        reverb = reverb,
        ambsnd = ambsnd,
        groundsound = groundsound,
        cameraoffset = cameraoffset,
        zoom = zoom,
		forceInteriorMinimap = forceInteriorMinimap
    }

    table.insert(interior_def.prefabs, { name = interior, x_offset = -2, z_offset = 0 })

    local prefab = {}

    for i, prefab  in ipairs(addprops) do
        table.insert(interior_def.prefabs, prefab)           
    end

    for t, exit in pairs(exits) do

    	if not exit.house_door then
	        if     t == NORTH then
	            prefab = { name = "prop_door", x_offset = -depth/2, z_offset = 0, sg_name = exit.sg_name, startstate = exit.startstate, animdata = { minimapicon = exit.minimapicon, bank = exit.bank, build = exit.build, anim = "north", background = true },
	                        my_door_id = roomindex.."_NORTH", target_door_id = exit.target_room.."_SOUTH", target_interior = exit.target_room, rotation = -90, hidden = false, angle=0, addtags = { "lockable_door", "door_north" } }
	        
	        elseif t == SOUTH then
	            prefab = { name = "prop_door", x_offset = (depth/2), z_offset = 0, sg_name = exit.sg_name, startstate = exit.startstate, animdata = { minimapicon = exit.minimapicon, bank = exit.bank, build = exit.build, anim = "south", background = false },
	                        my_door_id = roomindex.."_SOUTH", target_door_id = exit.target_room.."_NORTH", target_interior = exit.target_room, rotation = -90, hidden = false, angle=180, addtags = { "lockable_door", "door_south" } }
	            
	            if not exit.secret then
	            	table.insert(interior_def.prefabs, { name = "prop_door_shadow", x_offset = (depth/2), z_offset = 0, animdata = { bank = exit.bank, build = exit.build, anim = "south_floor" } })
	            end

	        elseif t == EAST then
	            prefab = { name = "prop_door", x_offset = 0, z_offset = width/2, sg_name = exit.sg_name, startstate = exit.startstate, animdata = { minimapicon = exit.minimapicon, bank = exit.bank, build = exit.build, anim = "east", background = true },
	                        my_door_id = roomindex.."_EAST", target_door_id = exit.target_room.."_WEST", target_interior = exit.target_room, rotation = -90, hidden = false, angle=90, addtags = { "lockable_door", "door_east" } }
	        
	        elseif t == WEST then
	            prefab = { name = "prop_door", x_offset = 0, z_offset = -width/2, sg_name = exit.sg_name, startstate = exit.startstate, animdata = { minimapicon = exit.minimapicon, bank = exit.bank, build = exit.build, anim = "west", background = true },
	                        my_door_id = roomindex.."_WEST", target_door_id = exit.target_room.."_EAST", target_interior = exit.target_room, rotation = -90, hidden = false, angle=270, addtags = { "lockable_door", "door_west" } }
	        end
	    else
			local doordata = player_interior_exit_dir_data[t.label]
	            prefab = { name = exit.prefab_name, x_offset = doordata.x_offset, z_offset = doordata.z_offset, sg_name = exit.sg_name, startstate = exit.startstate, animdata = { minimapicon = exit.minimapicon, bank = exit.bank, build = exit.build, anim = exit.prefab_name .. "_open_"..doordata.anim, background = doordata.background },
	                        my_door_id = roomindex..doordata.my_door_id_dir, target_door_id = exit.target_room..doordata.target_door_id_dir, target_interior = exit.target_room, rotation = -90, hidden = false, angle=doordata.angle, addtags = { "lockable_door", doordata.door_tag } }

	    end

        if exit.vined then
        	prefab.vined = true
        end

        if exit.secret then
        	prefab.secret = true
        	prefab.hidden = true
        end

        table.insert(interior_def.prefabs, prefab)
    end

    self:AddInterior(interior_def)
end

function InteriorSpawner:GetInteriorsByDungeonName(dungeonname)
	if dungeonname == nil then
		return nil
	else
		local tempinteriors = {}
		for i,interior in pairs(self.interiors)do
			if interior.dungeon_name == dungeonname then
				table.insert(tempinteriors,interior)
			end
		end
		return tempinteriors
	end
end

function InteriorSpawner:GetInteriorsByDungeonNameStart(dungeonnameStart)
	if dungeonnameStart == nil then
		return nil
	else
		local tempinteriors = {}
		local len = #dungeonnameStart
		for i,interior in pairs(self.interiors)do
			if string.sub(interior.dungeon_name, 1, len) == dungeonnameStart then
				table.insert(tempinteriors,interior)
			end
		end
		return tempinteriors
	end
end

function InteriorSpawner:GetInteriorByName(name)
	if name == nil then
		return nil
	else
		local interior = self.interiors[name]
		if interior == nil then
			print("!!ERROR: Unable To Find Interior Named:"..name)
		end
		
		return interior
	end
end

function InteriorSpawner:GetInteriorByDoorId(door_id)
	local interior = nil
	local door_data = self.doors[door_id]
	if door_data and door_data.my_interior_name then
		interior = self.interiors[door_data.my_interior_name]
	end
	
	if not interior then 
		print("THERE WAS NO INTERIOR FOR THIS DOOR, ITS A WORLD DOOR.", door_id)
	end
	-- assert(interior,"!!ERROR: Unable To Find Interior Due To Missing Door Data, For Door Id:"..door_id)

	return interior
end

function InteriorSpawner:RefreshDoorsNotInLimbo()
	
	local pt = self:getSpawnOrigin()

	--collect all the things in the "interior area" minus the interior_spawn_origin and the player
	local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 50, nil, {"INTERIOR_LIMBO"})
--		dumptable(ents,1,1,1)
	local south_door = nil
	local shadow = nil
--	print(#ents)
	for i = #ents, 1, -1 do
		if ents[i] then				
--			print(i)
			
			if ents[i]:HasTag("door_south") then
				south_door = ents[i]
			end

			if ents[i].prefab == "prop_door_shadow" then
				shadow = ents[i]
			end
		end
	end

	if south_door and shadow then
		south_door.shadow = shadow
	end

	for i = #ents, 1, -1 do
		if ents[i] then
			if ents[i].components.door then
				ents[i].components.door:updateDoorVis()
			end
		end
	end

	return ents
	
end

function InteriorSpawner:GetCurrentInteriorEntities()
	local pt = self:getSpawnOrigin()

	-- collect all the things in the "interior area" minus the interior_spawn_origin and the player

	local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 20, nil, {"INTERIOR_LIMBO","interior_spawn_storage"})
	assert(ents ~= nil)
	assert(#ents > 0)

	--local deleteents = {}
	local prev_ents = ents
	for i = #ents, 1, -1 do
		local following = self:CheckIsFollower(ents[i])
		if not ents[i] then
			print("entry", i, "was null for some reason?!?")
		end

		if following or ents[i]:HasTag("interior_spawn_origin") or (ents[i] == GetPlayer()) or ents[i]:IsInLimbo() or ents[i]:HasTag("INTERIOR_LIMBO_IMMUNE") then
			table.remove(ents, i)		
		end		
	end

	return ents
end

function InteriorSpawner:PrintDoorStatus(objectInInterior, tagName)
    local tagMsg = ""
    local entMsg = ""

    if objectInInterior.components.door.hidden then tagMsg = "disabled" else tagMsg = "enabled" end
    if objectInInterior.entity:IsVisible() then entMsg = "visible" else entMsg = "invisible" end
    print("INTERIOR SPAWNER: "..tagName.." (tag indicates "..tagMsg.. ") (ent = "..entMsg..")")
end

function InteriorSpawner:DebugPrint()
	local relatedInteriors = self:GetCurrentInteriors()
	print("INTERIOR SPAWNER: PRINTING INTERIOR")

	if self.current_interior then
		print("INTERIOR SPAWNER: CURRENT INTERIOR = "..self.current_interior.unique_name)
		local pt = self:getSpawnOrigin()

		--collect all the things in the "interior area" minus the interior_spawn_origin and the player
		local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 50, nil, {"INTERIOR_LIMBO"})

		for k, v in ipairs(ents) do
			if v.components.door then
				if v:HasTag("door_north") then
					self:PrintDoorStatus(v, "door_north")
				elseif v:HasTag("door_south") then
					self:PrintDoorStatus(v, "door_south")
				elseif v:HasTag("door_east") then
					self:PrintDoorStatus(v, "door_east")
				elseif v:HasTag("door_west") then
					self:PrintDoorStatus(v, "door_west")
				end
			end
		end
	end
end

local function IsCompleteDisguise(target)
   return target:HasTag("has_antmask") and target:HasTag("has_antsuit")
end

function InteriorSpawner:SetPropToInteriorLimbo(prop,interior,ignoredisplacement)
	if not prop.persists then
		prop:Remove()
	else
		if interior then
			table.insert(interior.object_list, prop)
		end
		prop:AddTag("INTERIOR_LIMBO")
		prop.interior = interior.unique_name

		if prop.components.playerprox and prop.components.playerprox.onfar then 
			prop.components.playerprox.onfar(prop)			
		end

	    if prop.SoundEmitter then
	        prop.SoundEmitter:OverrideVolumeMultiplier(0)
	    end
	    
		if prop.Physics and not prop.Physics:IsActive() then
			prop.dissablephysics = true			
		end
		if prop.removefrominteriorscene then
			prop.removefrominteriorscene(prop)
		end
		prop:RemoveFromScene(true)
	end
end

function InteriorSpawner:MovePropToInteriorStorage(prop,interior,ignoredisplacement)
	if prop:IsValid() then
		local pt1 = self:getSpawnOrigin()		
		local pt2 = self:getSpawnStorage()	

		if pt2 and not prop.parent and not ignoredisplacement then			
			local diffx = pt2.x - pt1.x 
			local diffz = pt2.z - pt1.z

			local proppt = Vector3(prop.Transform:GetWorldPosition())
			prop.Transform:SetPosition(proppt.x + diffx, proppt.y, proppt.z +diffz)
		end
	end
end

function InteriorSpawner:PutPropIntoInteriorLimbo(prop,interior,ignoredisplacement)
	self:SetPropToInteriorLimbo(prop, interior, ignoredisplacement)
	self:MovePropToInteriorStorage(prop, interior, ignoredisplacement)
end

function InteriorSpawner:LeaveCurrentInterior()
	if self.current_interior then
		local dungeon_name = self.current_interior.unique_name
		print("we're in dungeon",dungeon_name)
		for i,v in pairs(self.doors) do
			print(i,v,v.target_interior)
			if v.target_interior == dungeon_name then
				print("This is it")
				for i,v in pairs(v) do
					print("",i,v)
				end
				GetPlayer():Teleport(v.inst, true)
				break
			end
		end
	end
end

function InteriorSpawner:UnloadInterior()
	self:SanityCheck("Pre UnloadInterior")
	if self.current_interior then
		print("Unload interior "..self.current_interior.unique_name.."("..self.current_interior.dungeon_name..")")
		-- THIS UNLOADS THE CURRENT INTERIOR IN THE WORLD
		local interior = self.current_interior

		local ents = self:GetCurrentInteriorEntities()

		-- whipe the rooms object list, then fill it with all the stuff found at this place, 
		-- then remove them from the scene
		interior.object_list = {}
		-- this is done in two passes, since entities may rely on the sleep event and query other objects' locations
		-- pass one - put everyone to sleep
		for k, v in ipairs(ents) do
			if v.prefab == "antman" then
				local target = v.components.combat.target
				if target and IsCompleteDisguise(target) then
					v.combatTargetWasDisguisedOnExit = true
				end
			end
			self:SetPropToInteriorLimbo(v, interior)
		end
		-- pass two, teleport everyone
		for k, v in ipairs(ents) do
			self:MovePropToInteriorStorage(v, interior)
		end

		self:ConsiderPlayerNotInside(self.current_interior.unique_name)
		self.current_interior = nil
		self:ClearPathfindingBarriers()
	else		
		print("COMING FROM OUTSIDE, NO INTERIOR TO UNLOAD")
	end
	self:SanityCheck("Post UnLoadInterior")
end

function InteriorSpawner:ReturnItemToScene(entity, doors_in_limbo)
	entity:ReturnToScene()
	entity.interior = nil
	entity:RemoveTag("INTERIOR_LIMBO")

    if entity.SoundEmitter then
        entity.SoundEmitter:OverrideVolumeMultiplier(1)
    end

	if entity.dissablephysics then
		entity.dissablephysics = nil
		entity.Physics:SetActive(false)
	end

	-- I am really not pleased with this function. TODO: Use callbacks to entities/components for this
	if entity.prefab == "antman" then
		if IsCompleteDisguise(GetPlayer()) and not entity.combatTargetWasDisguisedOnExit then
			entity.components.combat.target = nil
		end
		entity.combatTargetWasDisguisedOnExit = false
	end

	if entity.Light and entity.components.machine and not entity.components.machine.ison then
    	entity.Light:Enable(false)
	end	    

	if entity:HasTag("interior_door") and doors_in_limbo then
		table.insert(doors_in_limbo, entity)
	end
	if entity.returntointeriorscene then
		entity.returntointeriorscene(entity)
	end
	if not entity.persists then
		entity:Remove()
	end			
end

function InteriorSpawner:LoadInterior(interior)
	self:SanityCheck("Pre LoadInterior")
	assert(interior, "No interior was set to load")

	-- THIS IS WHERE THE INTERIOR SHOULD BE SET
	print("Loading Interior "..interior.unique_name.. " With Handle "..interior.handle)
	GetWorld().Map:SetInterior( interior.handle )

	local hasdoors = false
	-- when an interior is called, it will either need to spawn all of it's contents the first time (prefabs attribute)
	-- or move its contents from limbo. (object_list attribute)
	if interior.prefabs then
		self:SpawnInterior(interior)
		self:RefreshDoorsNotInLimbo()
		interior.prefabs = nil
	else
		local prop_door_shadow = nil
		local doors_in_limbo = {}

		local pt1 = self:getSpawnStorage()		
		local pt2 = self:getSpawnOrigin()

		local objects_to_return	= {}	-- make a copy, as it can be modified during iteration
		for k, v in ipairs(interior.object_list) do
			objects_to_return[k] = v
		end
		-- bring the items back in two passes, first move everytone, then wake them up, in case awake relies on position of another entity
		for k, v in ipairs(objects_to_return) do
			if v:IsValid() then
				
				if pt1 and not v.parent then
					local diffx = pt2.x - pt1.x 
					local diffz = pt2.z - pt1.z

					local proppt = Vector3(v.Transform:GetWorldPosition())
					v.Transform:SetPosition(proppt.x + diffx, proppt.y, proppt.z +diffz)
				end

				if v.prefab == "prop_door_shadow" then
					prop_door_shadow = v
				end
			end
		end
		-- pass two, wake everyone up
		for k, v in ipairs(objects_to_return) do
			if v:IsValid() then
				self:ReturnItemToScene(v, doors_in_limbo)
			end
		end
		for k, v in ipairs(doors_in_limbo) do
			hasdoors = true
			v:ReturnToScene()
			v:RemoveTag("INTERIOR_LIMBO")
			if (v.sg == nil) and (v.sg_name ~= nil) then
				v:SetStateGraph(v.sg_name)
				v.sg:GoToState(v.startstate)
			end			

			if v:HasTag("door_south") then
				v.shadow = prop_door_shadow
			end

			v.components.door:updateDoorVis()
		end

		interior.object_list = {}
	end

	interior.enigma = false
	self.current_interior = interior
	self:ConsiderPlayerInside(self.current_interior.unique_name)

	if not hasdoors then
		print("*** Warning *** InteriorSpawner:LoadInterior - no doors for interior "..interior.unique_name.." ("..interior.dungeon_name..")")
	end

	-- Loaded interior, configure the walls
	self:ConfigureWalls(interior)

	self:SanityCheck("Post LoadInterior")
end

function InteriorSpawner:insertprefab(interior, prefab, offset, prefabdata)
	if interior == self.current_interior then
		print("CURRENT")
		local pt = self:getSpawnOrigin()
		local object = SpawnPrefab(prefab)	
		object.Transform:SetPosition(pt.x + offset.x_offset, 0, pt.z + offset.z_offset)
		if prefabdata and prefabdata.startstate then
			object.sg:GoToState(prefabdata.startstate)
			if prefabdata.startstate == "forcesleep" then
				object.components.sleeper.hibernate = true
				object.components.sleeper:GoToSleep()
			end
		end		
	elseif interior.visited then
		print("VISITED")
		local pt = self:getSpawnOrigin()
		local object = SpawnPrefab(prefab)	
		object.Transform:SetPosition(pt.x + offset.x_offset, 0, pt.z + offset.z_offset)			
		if prefabdata and prefabdata.startstate then
			object.sg:GoToState(prefabdata.startstate)
			if prefabdata.startstate == "forcesleep" then
				object.components.sleeper.hibernate = true
				object.components.sleeper:GoToSleep()
			end
		end
		self:PutPropIntoInteriorLimbo(object,interior)
	else
		local data = {name = prefab, x_offset = offset.x_offset, z_offset = offset.z_offset }
		if prefabdata then
			for arg, param in pairs(prefabdata) do
				data[arg] = param
			end
		end
		table.insert(interior.prefabs, data)
	end
end

function InteriorSpawner:InsertHouseDoor(interior, door_data)

	if interior.visited then
		local pt = self:getSpawnOrigin()

		local object = SpawnPrefab(door_data.name)
		object.Transform:SetPosition(pt.x + door_data.x_offset, 0, pt.z + door_data.z_offset)
		object.Transform:SetRotation(door_data.rotation)
		object.initInteriorPrefab(object, GetPlayer(), door_data, interior)

		self:AddDoor(object, door_data)
		self:PutPropIntoInteriorLimbo(object, interior)

	else
		local data = door_data
		table.insert(interior.prefabs, data)
	end
end

function InteriorSpawner:InsertDoor(interior, door_data)
	
	if interior.visited then

		local pt = self:getSpawnOrigin()

		local object = SpawnPrefab("prop_door")
		object.Transform:SetPosition(pt.x + door_data.x_offset, 0, pt.z + door_data.z_offset)
		-- object:RemoveFromScene(true)
		-- object:AddTag("INTERIOR_LIMBO")
		
		object.initInteriorPrefab(object, GetPlayer(), door_data, interior)

		self.doors[door_data.my_door_id] = { my_interior_name = door_data.my_interior_name, inst = object, target_interior = door_data.target_interior }
		self:PutPropIntoInteriorLimbo(object, interior)
	else
		local data = door_data
		table.insert(interior.prefabs, data)
	end
end

function InteriorSpawner:SpawnInterior(interior)

	-- this function only gets run once per room when the room is first called. 
	-- if the room has a "prefabs" attribute, it means the prefabs have not yet been spawned.
	-- if it does not have a prefab attribute, it means they have bene spawned and all the rooms
	-- contents will now be in object_list

	print("SPAWNING INTERIOR, FIRST TIME ONLY")

	local pt = self:getSpawnOrigin()

	for k, prefab in ipairs(interior.prefabs) do

		if GetWorld().getworldgenoptions(GetWorld())[prefab.name] and GetWorld().getworldgenoptions(GetWorld())[prefab.name] == "never" then
			print("CANCEL SPAWN ITEM DUE TO WORLD GEN PREFS", prefab.name)
	 	else

			print("SPAWN ITEM", prefab.name)

			local object = SpawnPrefab(prefab.name)
			object.Transform:SetPosition(pt.x + prefab.x_offset, 0, pt.z + prefab.z_offset)	

			-- flips the art of the item. This must be manually saved on items it it's to persist over a save
			if prefab.flip then
				local rx, ry, rz = object.Transform:GetScale()
				object.flipped = true
				object.Transform:SetScale(rx, ry, -rz)
			end

			-- sets the initial roation of an object, NOTE: must be manually saved by the item to survive a save
			if prefab.rotation then
				object.Transform:SetRotation(prefab.rotation)
			end

			-- adds tags to the object
			if prefab.addtags then
				for i, tag in ipairs(prefab.addtags) do
					object:AddTag(tag)
				end			
			end

			if prefab.hidden then
				object.components.door.hidden = true			
			end
			if prefab.angle then
				object.components.door.angle = prefab.angle			
			end

			-- saves the roomID on the object
			if object.components.shopinterior or object.components.shopped or object.components.shopdispenser then
				object.interiorID = interior.unique_name
			end

			-- sets an anim to start playing
			if prefab.startAnim then
				object.AnimState:PlayAnimation(prefab.startAnim)
				object.startAnim = prefab.startAnim
			end	

			if prefab.usesounds then
				object.usesounds = prefab.usesounds
			end	

			if prefab.saleitem then
				object.saleitem = prefab.saleitem
			end

			if prefab.justsellonce then
				object:AddTag("justsellonce")
			end	

			if prefab.startstate then
				object.startstate = prefab.startstate
				if object.sg == nil then
					object:SetStateGraph(prefab.sg_name)
					object.sg_name = prefab.sg_name
				end

				object.sg:GoToState(prefab.startstate)

				if prefab.startstate == "forcesleep" then
					object.components.sleeper.hibernate = true
					object.components.sleeper:GoToSleep()
				end
			end

			if prefab.shelfitems then
				object.shelfitems = prefab.shelfitems
			end		

			-- this door should have vines
			if prefab.vined and object.components.vineable then
				object.components.vineable:SetUpVine()
			end


			-- this function processes the extra data that the prefab has attached to it for interior stuff. 
			if object.initInteriorPrefab then
				object.initInteriorPrefab(object, GetPlayer(), prefab, interior)
			end

			-- should the door be closed for some reason?
			-- needs to happen after the object initinterior so the door info is there. 
			if prefab.door_closed then
				for cause,setting in pairs(prefab.door_closed)do
					object.components.door:checkDisableDoor(setting, cause)
				end
			end

			if prefab.secret then
				object:AddTag("secret")
				object:RemoveTag("lockable_door")
				object:Hide()

				self.inst:DoTaskInTime(0, function()
					local crack = SpawnPrefab("wallcrack_ruins")
					crack.SetCrack(crack, object)
				end)
			end

			-- needs to happen after the door_closed stuff has happened.
			if object.components.vineable then
				object.components.vineable:InitInteriorPrefab()
			end

			if interior.cityID then
	    		object:AddComponent("citypossession")
	    		object.components.citypossession:SetCity(interior.cityID)
			end

			if object.decochildrenToRemove then
				for i, child in ipairs(object.decochildrenToRemove) do
					if child then          
						local ptc = Vector3(object.Transform:GetWorldPosition())
	                	child.Transform:SetPosition( ptc.x ,ptc.y, ptc.z )
	                	child.Transform:SetRotation( object.Transform:GetRotation() )
	            	end
				end
			end
		end
	end

	interior.visited = true
end

function InteriorSpawner:IsInInterior()
	return TheCamera == self.interiorCamera
end 

function InteriorSpawner:GetInteriorDoors(interiorID)
	local found_doors = {}

	for k, door in pairs(self.doors) do
		if door.my_interior_name == interiorID then
			table.insert(found_doors, door)
		end
	end

	return found_doors

end

function InteriorSpawner:GetDoorInst(door_id)
	local door_data = self.doors[door_id]
	if door_data then
		if door_data.my_interior_name then
			local interior = self.interiors[door_data.my_interior_name]
			for k, v in ipairs(interior.object_list) do
				if v.components.door and v.components.door.door_id == door_id then
					return v
				end
			end
		else
			return door_data.inst
		end
	end
	return nil
end

function InteriorSpawner:AddDoor(inst, door_definition)
	--print("ADDING DOOR", door_definition.my_door_id)
	-- this sets some properties on the door component of the door object instance
	-- this also adds the door id to a list here in interiorspawner so it's easier to find what room needs to load when a door is used
	self.doors[door_definition.my_door_id] = { my_interior_name = door_definition.my_interior_name, inst = inst, target_interior = door_definition.target_interior }

	if inst ~= nil then
		if inst.components.door == nil then
			inst:AddComponent("door")
		end
		inst.components.door.door_id = door_definition.my_door_id
		inst.components.door.interior_name = door_definition.my_interior_name
		inst.components.door.target_door_id = door_definition.target_door_id
		inst.components.door.target_interior = door_definition.target_interior
	end
end

function InteriorSpawner:RemoveDoor(door_id)
	if not self.doors[door_id] then
		print ("ERROR: TRYING TO REMOVE A NON EXISTING DOOR DEFINITION")
		return
	end

	self.doors[door_id] = nil
	GetWorld():PushEvent("doorremoved")
end

function InteriorSpawner:RemoveDoorFromInterior(interior_id, door_id)
	local interior = self.interiors[interior_id]
	if interior then
		if not interior.visited then
			if interior.prefabs then
				for i,v in pairs(interior.prefabs) do
					if v.my_door_id == door_id then
						table.remove(interior.prefabs,i)
						return
					end
				end
			end
		else
			if interior.object_list and #interior.object_list > 0 then
				for n,obj in pairs(interior.object_list) do
					-- is this the target door?
					if obj.components.door and obj.components.door.door_id == door_id then
						table.remove(interior.object_list,n)
						return
					end
				end
			end
		end
	end
end

function InteriorSpawner:AddInterior(interior_definition)	
	-- print("CREATING ROOM", interior_definition.unique_name)
	local spawner_definition = self.interiors[interior_definition.unique_name]

	assert(not spawner_definition, "THIS ROOM ALREADY EXISTS: "..interior_definition.unique_name)

	spawner_definition = interior_definition
	spawner_definition.object_list = {}
	spawner_definition.handle = createInteriorHandle(spawner_definition)
	self.interiors[spawner_definition.unique_name] = spawner_definition

	-- if batcave, register with the batted component.
	if spawner_definition.batted then
		if GetWorld().components.batted then
			GetWorld().components.batted:registerInterior(spawner_definition.unique_name)
		end
	end
end

function InteriorSpawner:RemoveInterior(interior_id)
	
	if self.interiors[interior_id].batted and GetWorld().components.batted then
		GetWorld().components.batted:UnregisterInterior(self.interiors[interior_id])
	end

	self.interiors[interior_id]	= nil
end

function InteriorSpawner:CreatePlayerHome(house_id, interior_id)
	self.player_homes[house_id] = 
	{
		[interior_id] = { x = 0, y = 0}
	}
end

function InteriorSpawner:GetPlayerHome(house_id)
	return self.player_homes[house_id]
end

function InteriorSpawner:GetPlayerRoomIndex(house_id, interior_id)
	if self.player_homes[house_id] and self.player_homes[house_id][interior_id] then
		return self.player_homes[house_id][interior_id].x, self.player_homes[house_id][interior_id].y
	end
end

function InteriorSpawner:GetCurrentPlayerRoomConnectedToExit(exclude_dir, exclude_room_id)
	if self.current_interior then
		return self:PlayerRoomConnectedToExit(self.current_interior.dungeon_name, self.current_interior.unique_name, exclude_dir, exclude_room_id)
	end
end

function InteriorSpawner:PlayerRoomConnectedToExit(house_id, interior_id, exclude_dir, exclude_room_id)
	if not self.player_homes[house_id] then
		print ("NO HOUSE FOUND WITH THE PROVIDED ID")
		return false
	end

	local checked_rooms = {}

	local function DirConnected(current_interior_id, dir)

		if current_interior_id == exclude_room_id then
			return false
		end

		checked_rooms[current_interior_id] = true

		local index_x, index_y = self:GetPlayerRoomIndex(house_id, current_interior_id)
		if index_x == 0 and index_y == 0 then
			return true
		end

		local surrounding_rooms = self:GetConnectedSurroundingPlayerRooms(house_id, current_interior_id, dir)

		if next(surrounding_rooms) == nil then
			return false
		end

		for next_dir, room_id in pairs(surrounding_rooms) do
			if not checked_rooms[room_id] then
				local dir_connected = DirConnected(room_id, op_dir_str[next_dir])
				if dir_connected then
					return true
				elseif not dir_connected and next(surrounding_rooms, next_dir) == nil then
					return false
				end
			end
		end
	end

	return DirConnected(interior_id, exclude_dir)
end

function InteriorSpawner:GetPlayerRoomIdByIndex(house_id, x, y)
	if self.player_homes[house_id] then
		for id, interior in pairs(self.player_homes[house_id]) do
			if interior.x == x and interior.y == y then
				return id
			end
		end
	end
end

function InteriorSpawner:GetPlayerRoomInDirection(house_id, id, dir)
	local x, y = self:GetPlayerRoomIndex(house_id, id)

	if x and y then
		if dir == "north" then
		    y = y + 1
		elseif dir == "east" then
		    x = x + 1
		elseif dir == "south" then
			y = y - 1
		elseif dir == "west" then
		    x = x - 1
		end
	end

    return self:GetPlayerRoomIdByIndex(house_id, x, y)
end

function InteriorSpawner:GetSurroundingPlayerRooms(house_id, id, exclude_dir)
	local found_rooms = {}
	for _, dir in ipairs(dir_str) do
		local room = self:GetPlayerRoomInDirection(house_id, id, dir)
		if room and dir ~= exclude_dir then
			found_rooms[dir] = room
		end
	end

	return found_rooms
end

function InteriorSpawner:GetConnectedSurroundingPlayerRooms(house_id, id, exclude_dir)
	local found_doors = {}
	local doors = self:GetInteriorDoors(id)
	local curr_x, curr_y = self:GetPlayerRoomIndex(house_id, id)

	for _, door in ipairs(doors) do
		if door.inst.prefab ~= "prop_door" then
			local target_x, target_y = self:GetPlayerRoomIndex(house_id, door.target_interior)

			if target_y > curr_y and exclude_dir ~= "north" then -- North door
				found_doors["north"] = door.target_interior
			elseif target_y < curr_y and exclude_dir ~= "south" then -- South door
				found_doors["south"] = door.target_interior
			elseif target_x > curr_x and exclude_dir ~= "east" then -- East Door
				found_doors["east"] = door.target_interior
			elseif target_x < curr_x and exclude_dir ~= "west" then -- West Door
				found_doors["west"] = door.target_interior
			end
		end
	end

	return found_doors
end

function InteriorSpawner:AddPlayerRoom(house_id, id, from_id, dir)
	if self.player_homes[house_id] then
		local x, y = self:GetPlayerRoomIndex(house_id, from_id)

		if x and y then
			if dir == "north" then
		        y = y + 1
		    elseif dir == "south" then
		        y = y - 1
		    elseif dir == "east" then
		        x = x + 1
		    elseif dir == "west" then
		        x = x - 1
		    end

		    self.player_homes[house_id][id] = {x = x, y = y}
		end
	end
end

function InteriorSpawner:RemovePlayerRoom(house_id, id)
	if self.player_homes[house_id] then
		if self.player_homes[house_id][id] then
			self.player_homes[house_id][id] = nil
		else
			print ("TRYING TO REMOVE INEXISTENT PLAYER ROOM WITH ID", id)
		end
	else
		print ("NO PLAYER HOME FOUND WITH ID", house_id)
	end
end

function InteriorSpawner:GetCurrentPlayerRoomIndex()
	if self.current_interior then
		return self:GetPlayerRoomIndex( self.current_interior.dungeon_name , self.current_interior.unique_name )
	end
end

function InteriorSpawner:getPropInterior(inst)
	if inst.interior then
		return inst.interior
	end

	for room, data in pairs(self.interiors)do
		for p, prop in ipairs(data.object_list)do
			if inst == prop then
				return room
			end
		end 
	end
end

function InteriorSpawner:removeprefab(inst,interiorID)
	print("trying to remove",inst.prefab,interiorID)
	local interior = self.interiors[interiorID]
	if interior then
		for i, prop in ipairs(interior.object_list) do
			if prop == inst then
				print("REMOVING",prop.prefab)
				table.remove(interior.object_list, i)
				inst.interior = nil
				break
			end
		end
	end
end

function InteriorSpawner:injectprefab(inst,interiorID)
	local interior = self.interiors[interiorID]
	inst:RemoveFromScene(true)
	inst:AddTag("INTERIOR_LIMBO")
	inst.interior = interiorID
	table.insert(interior.object_list, inst)
end

-- almost the same as injectprefab but this goes to the dance of calling relevant events
function InteriorSpawner:AddPrefabToInterior(inst,destInterior)
	if destInterior then
		local interior = self.interiors[destInterior]
		if interior then
			-- add the new entity. The position should already be of an object in interior space
			self:PutPropIntoInteriorLimbo(inst,interior,true)
		end
	end
end

function InteriorSpawner:SwapPrefab(inst,replacement)
	if inst.interior then
		local interior = self.interiors[inst.interior]
		if interior then
			-- remove the old entity
			self:removeprefab(inst, inst.interior)
			self:AddPrefabToInterior(inst, destInterior)
		end
	end
end

function InteriorSpawner:OnSave()
	-- print("InteriorSpawner:OnSave")
	self:SanityCheck("Pre Save")

	local data =
	{ 
		interiors = {}, 
		doors = {}, 
		next_interior_ID = self.next_interior_ID, 	
		current_interior = self.current_interior and self.current_interior.unique_name or nil,
		player_homes = self.player_homes
	}	

	local refs = {}
	
	for k, room in pairs(self.interiors) do
		
		local prefabs = nil
		if room.prefabs then
			prefabs = {}
			for k, prefab in ipairs(room.prefabs) do
				local prefab_data = prefab
				table.insert(prefabs, prefab_data)
			end
		end

		local object_list = {}
		for k, object in ipairs(room.object_list) do
			local save_data = object.GUID
			table.insert(object_list, save_data)
			table.insert(refs, object.GUID)
		end

		local interior_data =
		{
			unique_name = k, 
			z = room.z, 
			x = room.x, 
			dungeon_name = room.dungeon_name,
			width = room.width, 
			height = room.height, 
			depth = room.depth, 
			object_list = object_list, 
			prefabs = prefabs,
			walltexture = room.walltexture,
			floortexture = room.floortexture,
			minimaptexture = room.minimaptexture,
			cityID = room.cityID,
			cc = room.cc,
			visited = room.visited,
			batted = room.batted,
			playerroom = room.playerroom,
			enigma = room.enigma,
			reverb = room.reverb,
			ambsnd = room.ambsnd,
			groundsound = room.groundsound,
			zoom = room.zoom,
			cameraoffset = room.cameraoffset,
			forceInteriorMinimap = room.forceInteriorMinimap,
		}

		table.insert(data.interiors, interior_data)		
	end

	for k, door in pairs(self.doors) do
		local door_data =
		{
			name = k, 
			my_interior_name = door.my_interior_name,
			target_interior = door.target_interior,
			secret = door.secret,
		}						
		if door.inst then
			door_data.inst_GUID = door.inst.GUID
			table.insert(refs, door.inst.GUID)
		end
		table.insert(data.doors, door_data)
	end
	
	--Store camera details 
	if TheCamera.interior_distance then
		data.interior_x = TheCamera.interior_currentpos.x
		data.interior_y = TheCamera.interior_currentpos.y
		data.interior_z = TheCamera.interior_currentpos.z
		data.interior_distance = TheCamera.interior_distance
	end
	
	data.prev_player_pos = {x = self.prev_player_pos_x, y = self.prev_player_pos_y, z = self.prev_player_pos_z}

	local x,y,z = self.interiorEntryPosition:Get()
	data.interiorEntryPosition = {x=x, y=y, z=z}
	return data, refs
end

function InteriorSpawner:OnLoad(data)
	self.interiors = {}
	for k, int_data in ipairs(data.interiors) do		
		-- Create placeholder definitions with saved locations
		self.interiors[int_data.unique_name] =
		{ 
			unique_name = int_data.unique_name,
			z = int_data.z, 
			x = int_data.x, 
			dungeon_name = int_data.dungeon_name,
			width = int_data.width, 
			height = int_data.height,
			depth = int_data.depth,			
			object_list = {}, 
			prefabs = int_data.prefabs, 			
			walltexture = int_data.walltexture,
			floortexture = int_data.floortexture,
			minimaptexture = int_data.minimaptexture,
			cityID = int_data.cityID,
			cc = int_data.cc,
			visited = int_data.visited,
			batted = int_data.batted,
			playerroom = int_data.playerroom,
			enigma = int_data.enigma,
			reverb = int_data.reverb,
			ambsnd = int_data.ambsnd,
			groundsound = int_data.groundsound,
			zoom = int_data.zoom,
			cameraoffset = int_data.cameraoffset,
			forceInteriorMinimap = int_data.forceInteriorMinimap,
		}

		self.interiors[int_data.unique_name].handle = createInteriorHandle(self.interiors[int_data.unique_name])

		-- if batcave, register with the batted component.
		if int_data.batted then
			if GetWorld().components.batted then
				GetWorld().components.batted:registerInterior(int_data.unique_name)
			end
		end
	end

	for k, door_data in ipairs(data.doors) do
		self.doors[door_data.name] =  { my_interior_name = door_data.my_interior_name, target_interior = door_data.target_interior, secret = door_data.secret } 			
	end	

	GetWorld().components.colourcubemanager:SetInteriorColourCube(nil)

	if data.current_interior then
		self.current_interior = self:GetInteriorByName(data.current_interior)
		self:ConsiderPlayerInside(self.current_interior.unique_name)
		GetWorld().components.colourcubemanager:SetInteriorColourCube( self.current_interior.cc )		
	end

	if data.prev_player_pos then
		self.prev_player_pos_x, self.prev_player_pos_y, self.prev_player_pos_z = data.prev_player_pos.x, data.prev_player_pos.y, data.prev_player_pos.z
	end
	if data.interiorEntryPosition then
		local vec = data.interiorEntryPosition
		self.interiorEntryPosition = Vector3(vec.x, vec.y, vec.z)
	end
	self.next_interior_ID = data.next_interior_ID
	
	if data.player_homes then
		self.player_homes = data.player_homes
	end
end

function InteriorSpawner:CleanUpMessAroundOrigin()
	local function removeStray(ent)
		print("Removing stray "..ent.prefab)
		ent:Remove()
	end
	for i,v in pairs(Ents) do
		if v.Transform then
			local pos = v:GetPosition()
			if v.prefab == "window_round_light" and pos == Vector3(0,0,0) then
				removeStray(v)
			end
			if v.prefab == "window_round_light_backwall" and pos == Vector3(0,0,0) then
				removeStray(v)
			end
			if v.prefab == "home_prototyper" and v ~= self.homeprototyper then
				removeStray(v)
			end
		end
	end
end

function InteriorSpawner:LoadPostPass(ents, data)
	self:CleanUpMessAroundOrigin()

	self:RefreshDoorsNotInLimbo()

	-- fill the object list
	for k, room in pairs(data.interiors) do
		local interior = self:GetInteriorByName(room.unique_name)
		if interior then 
			for i, object in pairs(room.object_list) do
				if object and ents[object] then										
					local object_inst = ents[object].entity
					table.insert(interior.object_list, object_inst)	
					object_inst.interior = room.unique_name
				else
					print("*** Warning *** InteriorSpawner:LoadPostPass object "..tostring(object).." not found for interior "..interior.unique_name)
				end
			end
		else
			print("*** Warning *** InteriorSpawner:LoadPostPass Could not fetch interior "..room.unique_name)			
		end
	end

	-- fill the inst of the doors. 
	for k, door_data in pairs(data.doors) do
		if door_data.inst_GUID then		
			if 	ents[door_data.inst_GUID] then
				self.doors[door_data.name].inst =  ents[door_data.inst_GUID].entity 
			end
		end
	end

	-- camera load stuff
	if self.exteriorCamera == nil then
		-- TODO: Find better location for this
		self.exteriorCamera = TheCamera
		self.interiorCamera = InteriorCamera()
	end

	if data.interior_x then
		local player = GetPlayer()
		TheCamera = self.interiorCamera 
		local interior_pos = Vector3(data.interior_x, data.interior_y, data.interior_z)
		if self.spawnOriginDelta then
			interior_pos = interior_pos + self.spawnOriginDelta
		end
		if InteriorSpawner.deltaForSpawnOriginMigration then
			-- Again: this is horrific, see comment at InteriorSpawner.FixForSpawnOriginMigration
			interior_pos = interior_pos + InteriorSpawner.deltaForSpawnOriginMigration
		end

		TheCamera.interior_currentpos = interior_pos
		TheCamera.interior_distance = data.interior_distance
		TheCamera:SetTarget(player)
	end

	if self.current_interior then		
		local pt_current = self:getSpawnOrigin()
		local pt_dormant = self:getSpawnStorage()
		InteriorManager:SetCurrentCenterPos2d( pt_current.x, pt_current.z )
		InteriorManager:SetDormantCenterPos2d( pt_dormant.x, pt_dormant.z )
		GetWorld().Map:SetInterior( self.current_interior.handle )		
		-- ensure the interior is loaded
		self:ConfigureWalls(self.current_interior)
	end	

	self:SanityCheck("Post Load")
	self:FixRelicOutOfBounds()

	self:CheckIfPlayerIsInside()
end

-- find the world entry points into dungeons. For multipe entries into one dungeon this is non-deterministic
function InteriorSpawner:CheckForInvalidSpawnOrigin()
	-- Trying to detect the issue with clouds in rooms/unplacable items
	local pt1 = self:getSpawnOrigin()
	print("SpawnOrigin:",pt1,GetTileType(pt1))
	if (GetTileType(pt1) == "IMPASSABLE") then
		print("World has suspicious SpawnOrigin")
	end
end

function InteriorSpawner:ClampPosition(vec, origin, w, h)
	local work = Vector3(vec:Get())

	local dx = work.x - origin.x
	local dz = work.z - origin.z

	if dx > w then
		work.x = origin.x + w
	elseif dx < -w then
		work.x = origin.z - w
	end

	if dz > h then
		work.z = origin.z + h
	elseif dz < -h then
		work.z = origin.z - h
	end
	return work			
end
                                                              
function InteriorSpawner:FixRelicOutOfBounds()


	print("FIXING RELIC OUT OF BOUNDS")
	for k, room in pairs(self.interiors) do
		local interior = self:GetInteriorByName(room.unique_name)

		if interior == self.current_interior then			
			local pt = self:getSpawnOrigin()
			local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 40,nil,{"INTERIOR_LIMBO"})

			if ents and #ents > 0 then								
				for i,ent in ipairs(ents)do
					if ent.prefab == "pig_ruins_truffle" or ent.prefab == "pig_ruins_sow" then
						local objectPos = ent:GetPosition()
						local spawnOrigin = self:getSpawnOrigin()
						local modifiedPos = self:ClampPosition(objectPos, spawnOrigin, room.depth/2 - 2, room.width/2 - 2) 
						ent.Transform:SetPosition(modifiedPos:Get())						
					end
				end
			end
		else
			if room.prefabs and #room.prefabs > 0 then
				for i,prefab in ipairs(room.prefabs) do
					if prefab.name == "pig_ruins_truffle" or prefab.name == "pig_ruins_sow" then
						local origin = Vector3(0,0,0)
						local objectPos = Vector3(prefab.x_offset, 0, prefab.z_offset)
						local modifiedPos = self:ClampPosition(objectPos, origin, room.depth/2 - 2, room.width/2 - 2) 
						prefab.x_offset = modifiedPos.x
						prefab.z_offset = modifiedPos.z
					end
				end
			end
			if room.object_list and #room.object_list > 0 then
				for i,object in ipairs(room.object_list) do					
					if object.prefab == "pig_ruins_truffle" or object.prefab == "pig_ruins_sow" then
						local objectPos = object:GetPosition()
						local storageOrigin = self:getSpawnStorage()
						local modifiedPos = self:ClampPosition(objectPos, storageOrigin, room.depth/2 - 2, room.width/2 - 2) 
						object.Transform:SetPosition(modifiedPos:Get())
					end
				end
			end 
		end
	end
end

-- Sanity check. If we are in a room, that room has no prefabs nor object_list
-- all other rooms need either object_list (when stored) or prefabs (when never instantiated)
function InteriorSpawner:SanityCheck(reason)
	assert(reason)
	self:CheckForInvalidSpawnOrigin()
	for k, room in pairs(self.interiors) do
		local interior = self:GetInteriorByName(room.unique_name)
		if interior and not self.alreadyFlagged[room.unique_name] then 
			local hasObjects = (#interior.object_list > 0)
			local hasPrefabs = (interior.prefabs ~= nil)
			if interior == self.current_interior then
				if (hasObjects or hasPrefabs) then
					self.alreadyFlagged[room.unique_name] = true
					print("*** Error *** InteriorSpawner ("..reason..")  Error: current interior "..room.unique_name.." ("..room.dungeon_name..") has objects or prefabs")
					print(debugstack())
				end
				--assert(not hasObjects and not hasPrefabs)
			else
				if (not (hasObjects or hasPrefabs)) then
					self.alreadyFlagged[room.unique_name] = true
					print("*** Error *** InteriorSpawner ("..reason..")  Error: non-current interior "..room.unique_name.." ("..room.dungeon_name..") has neither objects nor prefabs")
					print(debugstack())
				elseif (hasObjects and hasPrefabs) then
					self.alreadyFlagged[room.unique_name] = true
					print("*** Error *** InteriorSpawner ("..reason..") Error: non-current interior "..room.unique_name.." ("..room.dungeon_name..") has objects and prefabs")
					print(debugstack())
				end
				--assert(hasObjects or hasPrefabs)
				--assert(not (hasObjects and hasPrefabs))
			end
		end
	end
end

function InteriorSpawner:GetCurrentInterior()
	return self.current_interior
end

function InteriorSpawner:GetCurrentInteriors()
	local relatedInteriors = {}

	if self.current_interior then
		for key, interior in pairs(self.interiors) do
			if self.current_interior.dungeon_name == interior.dungeon_name then
				table.insert(relatedInteriors, interior)
			end
		end
	end

	return relatedInteriors
end

function InteriorSpawner:CountPrefabs(prefabName)
    local prefabCount = 0
    local relatedInteriors = self:GetCurrentInteriors()

	for i, interior in ipairs(relatedInteriors) do
        if interior == self.current_interior then
            local pt = self:getSpawnOrigin()
            -- collect all the things in the "interior area" minus the interior_spawn_origin and the player
            local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 50, {"interior_door"}, {"INTERIOR_LIMBO"})
            for p, objectInInterior in ipairs(ents) do
                if objectInInterior.prefab == prefabName then
                    prefabCount = prefabCount + 1
                end
            end
        elseif interior.object_list and (#interior.object_list > 0) then
            for p, objectInInterior in ipairs(interior.object_list) do
                if objectInInterior.prefab == prefabName then
                    prefabCount = prefabCount + 1
                end
            end
        end
    end

    return prefabCount
end


-- Try to fix up a really nasty bug that has crept in through a global variable 'name' 
function InteriorSpawner:FixDoors()
	-- Get all player houses
        local interior_spawner = GetWorld().components.interiorspawner
	local playerInteriors = {}
	for i,v in pairs(interior_spawner.interiors) do
		if v.playerroom then
			if type(v.unique_name) == "number" then
				local name = v.unique_name
				playerInteriors[name]=v
			end
		end
	end

	local function fixDoorName(name, interior)
		local tail = name and name:sub(-5) or ""
		if tail == "_door" or tail=="_exit" then
			local wanted_tail = interior..tail		
			local actual_tail = name:sub(-#wanted_tail)
			if (actual_tail == wanted_tail) then	
				local doorname = "playerhouse"..interior..tail
				return doorname			
			end
		end
		return name
	end

	-- find all outside that refer to these interiors
	for i,v in pairs(Ents) do
		if v.components.door then
			local door_id = v.components.door.door_id
			if door_id then
				-- door going from outside to inside
				local target_interior = v.components.door.target_interior	
				if playerInteriors[target_interior] then
					--print("has one as target_interior:",door_id)
					local oldname = v.components.door.door_id
					local newname = fixDoorName(oldname, target_interior)
					if oldname ~= newname then
						print("change",oldname,"to",newname)
						v.components.door.door_id = newname
					end
					local oldname = v.components.door.target_door_id
					local newname = fixDoorName(oldname, target_interior)
					if oldname ~= newname then
						print("change",oldname,"to",newname)
						v.components.door.target_door_id = newname
					end
				end
			end
		end
	end
	-- and all inside doors
	for i,v in pairs(Ents) do
		if v.components.door then
			local door_id = v.components.door.door_id
			if door_id then
				-- door going from outside to inside
				local interior_name = v.components.door.interior_name	
				if playerInteriors[interior_name] then
					--print("has one as interior_name:",door_id)
					local oldname = v.components.door.door_id
					local newname = fixDoorName(oldname, interior_name)
					if oldname ~= newname then
						print("change",oldname,"to",newname)
						v.components.door.door_id = newname
					end
					local oldname = v.components.door.target_door_id
					local newname = fixDoorName(oldname, interior_name)
					if oldname ~= newname then
						print("change",oldname,"to",newname)
						v.components.door.target_door_id = newname
					end
				end
			end
		end
	end
	-- and now all doors in the InteriorManager
	local replaceDoors = {}
	for i,v in pairs(playerInteriors) do
		local interiorID = v.unique_name
		for j,k in pairs(interior_spawner.doors) do
			if k.my_interior_name == interiorID or k.target_interior == interiorID then
				--print("name:",j,"is one that qualifies for replacement")
				local oldname = j
				local newname = fixDoorName(oldname, v.unique_name)
				if oldname ~= newname then
					replaceDoors[oldname] = {name = newname, contents = k}
				end				
			end
		end
	end	
	-- do the replacements
	for i,v in pairs(replaceDoors) do
		print("Replace door",i,"with",v.name)
		-- nuke the old one
		interior_spawner.doors[i] = nil
		-- set the new one
		interior_spawner.doors[v.name] = v.contents
	end
	-- modify dungeon name if exists
	for i,v in pairs(playerInteriors) do
		local oldname = v.dungeon_name
		local newname = "playerhouse"..v.unique_name
		if oldname ~= newname then
			print("Changing dungeon name from",oldname,"to",newname)
			v.dungeon_name = newname
		end
		-- check if there's any prefabs in this dungeon that need to be renamed
		if v.prefabs then
			for j,k in pairs(v.prefabs) do
				if k.name=="prop_door" then
					-- my_door_id
					if k.my_door_id then
						local oldname = k.my_door_id
						local newname = fixDoorName(oldname, v.unique_name)
						if oldname ~= newname then
							print("change",oldname,"to",newname)
							k.my_door_id = newname
						end
					end
					if k.target_door_id then
						local oldname = k.target_door_id
						local newname = fixDoorName(oldname, v.unique_name)
						if oldname ~= newname then
							print("change",oldname,"to",newname)
							k.target_door_id = newname
						end
					end
				end
			end	
		end
	end
end

function InteriorSpawner:IsPlayerConsideredInside(interior)
	-- if we're transitioning into, inside, or transitioning out of this will return true
	if interior then
		return self.considered_inside_interior[interior]
	else
		-- if no interior specified, return if considered inside any interior
		for i,v in pairs(self.considered_inside_interior) do
			return true
		end
	end
end

function InteriorSpawner:ConsiderPlayerInside(interior)
	self.considered_inside_interior[interior] = true
end

function InteriorSpawner:ConsiderPlayerNotInside(interior)
	self.considered_inside_interior[interior] = nil
end

function InteriorSpawner:ReturnFromHiddenDoorLimbo(v)
	local pt1 = self:getSpawnStorage()		
	local pt2 = self:getSpawnOrigin()

	local prop_door_shadow = nil
	local doors_in_limbo = {}
	local hasdoors = false

	if pt1 and not v.parent then
		local diffx = pt2.x - pt1.x 
		local diffz = pt2.z - pt1.z
		local proppt = Vector3(v.Transform:GetWorldPosition())
		v.Transform:SetPosition(proppt.x + diffx, proppt.y, proppt.z +diffz)
	end
	v:ReturnToScene()
	v:RemoveTag("INTERIOR_LIMBO")
	v.interior = nil

    if v.SoundEmitter then
        v.SoundEmitter:OverrideVolumeMultiplier(1)
    end

	if v.dissablephysics then
		v.dissablephysics = nil
		v.Physics:SetActive(false)
	end

	if v.prefab == "antman" then
		if IsCompleteDisguise(GetPlayer()) and not v.combatTargetWasDisguisedOnExit then
			v.components.combat.target = nil
		end
		v.combatTargetWasDisguisedOnExit = false
	end

	if v.prefab == "prop_door_shadow" then
		prop_door_shadow = v
	end

	if v:HasTag("interior_door") then
		table.insert(doors_in_limbo, v)
	end
	if v.returntointeriorscene then
		v.returntointeriorscene(v)
	end
	if not v.persists then
		v:Remove()
	end			

	for k, v in ipairs(doors_in_limbo) do
		hasdoors = true
		v:ReturnToScene()
		v:RemoveTag("INTERIOR_LIMBO")
		if (v.sg == nil) and (v.sg_name ~= nil) then
			v:SetStateGraph(v.sg_name)
			v.sg:GoToState(v.startstate)
		end			

		if v:HasTag("door_south") then
			v.shadow = prop_door_shadow
		end

		v.components.door:updateDoorVis()
	end
end

-- the hidden doors caused an issue. Try to clean up the damage
function InteriorSpawner:CleanupBlackRoomAfterHiddenDoor()
	local function PutInInterior(entity, interiorName)
		if self.current_interior and interiorName == self.current_interior.unique_name then
			-- needs to be moved in
			--assert(false)
			print("Returning",entity)
			self:ReturnFromHiddenDoorLimbo(entity)
		else
			local interior = self.interiors[interiorName]
			--assert(interior)
			--print("interior:",interior,interior.unique_name)
			-- add this entity to the object list for this interior
			if interior.object_list and #interior.object_list > 0 then
				local found = false
				for i,v in pairs(interior.object_list) do
					if v == entity then
						found = true
						break
					end
				end
				if not found then 
					table.insert(interior.object_list,entity)
				end
			end
		end
	end
	local pt = self:getSpawnStorage()
	-- collect all the things in the "interior storage area" minus the interior_spawn_origin and the player
	local interior = self.current_interior
	if interior then	
		print("We are currently in interior",interior.unique_name)
	else
		print("We are currently not in an interior")
	end
	local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 20, {"INTERIOR_LIMBO"}, {"interior_spawn_storage"})
	local lastpos
	for i,v in pairs(ents) do
		if v.interior then
			PutInInterior(v,v.interior)
		else
			-- ergh, no interior set on this, can we still salvage it?
			-- is it a door? 
			if v.components.door then
				PutInInterior(v,v.components.door.interior_name)
				lastpos = v:GetPosition()
			end
		end
	end
	-- Is the player sitting near the spawn storage? Let's maybe not do that
	local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 20, nil, {"interior_spawn_storage"})
	for i,v in pairs(ents) do
		if v == GetPlayer() then
			local ent = SpawnPrefab("acorn")	-- everyone needs a magic acorn
			if lastpos then
				ent.Transform:SetPosition(lastpos.x, lastpos.y, lastpos.z)
			else
				-- no door to teleport to. Just try something
				local pt1 = self:getSpawnOrigin()		
				local pt2 = self:getSpawnStorage()	
				local delta = pt1-pt2
				local rightpos = v:GetPosition() + delta
				ent.Transform:SetPosition(rightpos.x, rightpos.y, rightpos.z)
			end
			self:ExecuteTeleport(v, ent)
			ent:Remove()
			break
		end
	end
	-- While at it, what about those that had no interior? Do they exist in an object list?
	local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 20, nil, {"INTERIOR_LIMBO", "interior_spawn_storage"})
end

function InteriorSpawner:InPlayerRoom()
    return self.current_interior and self.current_interior.playerroom or false
end


function InteriorSpawner:getOriginForInteriorInst(inst)
	-- it's either in interior storage or in interior spawn, return the right origin to work relative to
	local spawnStorage = self:getSpawnStorage()
	local spawnOrigin = self:getSpawnOrigin()

	local pos = inst:GetPosition()
	local storageDist = (pos - spawnStorage):Length()
	local spawnDist = (pos - spawnOrigin):Length()
	local origin = (storageDist < spawnDist) and spawnStorage or spawnOrigin
	return origin, pos
end

function InteriorSpawner:GetExitDirection(inst)
	local origin = self:getOriginForInteriorInst(inst)
	local position = inst:GetPosition()
	local delta = position - origin
	if math.abs(delta.x) > math.abs(delta.z) then
		-- north or south
		if delta.x > 0 then
			return "south"
		else
			return "north"
		end
	else
		-- east or west
		if delta.z < 0 then
			return "west"
		else
			return "east"
		end
	end

end

function InteriorSpawner:GetPrevPlayerPos()
	return self.prev_player_pos_x, self.prev_player_pos_y, self.prev_player_pos_z
end

function InteriorSpawner:SetupInteriorEntries()
	self.dungeon_entries = {}
	for i,door in pairs(self.doors) do
		if not door.my_interior_name then
			local target_interior = self.interiors[door.target_interior]
			local inst = door.inst
			if target_interior and inst and inst:IsValid() then
				local dungeon_name = target_interior.dungeon_name
				self.dungeon_entries[dungeon_name] = inst:GetPosition()
			end
		end
	end
end

-- return the world position of the entry leading into the underlying dungeon for this interior
-- if all else fails we return the last position a dungeon was entered from the overworld
function InteriorSpawner:GetInteriorEntryPosition(optional_interior)
	local current_interior = optional_interior or self.current_interior
	if current_interior then
		if not self.dungeon_entries[self.current_interior] then
			self:SetupInteriorEntries()
		end
		local entry = self.dungeon_entries[current_interior.dungeon_name]
		if entry then
			return entry:Get()
		end
	end
	return self.interiorEntryPosition:Get()
end

function InteriorSpawner:SetInteriorEntryPosition(x,y,z)
	self.interiorEntryPosition = Vector3(x,y,z)
end

-- Beta issue: The beta caused ruins to be mirrored, because doors had the wrong directional tags. 
-- Somewhat undesirable, so try to clean up
function InteriorSpawner:UnRuinRuins()
	local spawnStorage = self:getSpawnStorage()
	local spawnOrigin = self:getSpawnOrigin()

	local function getOriginForDoor(door)
		-- it's either in interior storage or in interior spawn, return the right origin to work relative to
		local pos = door:GetPosition()
		local storageDist = (pos - spawnStorage):Length()
		local spawnDist = (pos - spawnOrigin):Length()
		local origin = (storageDist < spawnDist) and spawnStorage or spawnOrigin
		return origin, pos
	end

	for i,door in pairs(Ents) do
		if door.prefab == "prop_door" then
			if door.components.door then
				if door:HasTag("door_east") then
					-- is this door actually to the east?
					local exitdirection = self:GetExitDirection(door)
					if exitdirection == "west" then
						door:RemoveTag("door_east")
						door:AddTag("door_west")
					end
				elseif door:HasTag("door_west") then
					-- is this door actually to the west?
					local exitdirection = self:GetExitDirection(door)
					if exitdirection == "east" then
						door:RemoveTag("door_west")
						door:AddTag("door_east")
					end
				end
			end
		end
	end

	local function FixupPrefabsForInterior(interior)
		if interior.prefabs then
			for j,k in pairs(interior.prefabs) do
				if k.name == "prop_door" then
					if k.addtags then
						local tag = k.addtags[2]
						if tag == "door_east" then
							if k.z_offset < 0 then
								k.addtags[2] = "door_west"
							end
						elseif tag == "door_west" then
							if k.z_offset > 0 then
								k.addtags[2] = "door_east"
							end	
						end
					end
				end
			end	
		end
	end

	-- doors that yet have to be spawned
	for i, interior in pairs(self.interiors) do
		-- Handle the prefabs (doors that still need to be spawned)
		FixupPrefabsForInterior(interior)
	end
end


-- Interior Beta issue: The beta caused anthill connection logic to be mirrored as well, because doors had the wrong directional tags. 
function InteriorSpawner:FixupAnthills()
	for i,v in pairs(Ents) do
		if v.prefab == "anthill" then
			v:FixupDoors()
		end
	end
end

-- Beta issue. The Anthill Queen Chambers all have their own dungeon name. This is not needed and breaks the minimap logic
-- Chuck em all in dungeon QUEEN_CHAMBERS_DUNGEON
function InteriorSpawner:RenameQueenChamberDungeon()
	for i,v in pairs(self.interiors) do
		if v.dungeon_name == "QUEEN_CHAMBERS_"..v.unique_name or v.dungeon_name == "FINAL_QUEEN_CHAMBER" then
			v.dungeon_name = "QUEEN_CHAMBERS_DUNGEON"			
		end
	end
end

-- Beta issue. Another issue with the Anthill Queen Chambers.
-- The north doors in the Queen Chambers are labelled 'door_south' which confuses the minimapper
-- While at it - the doors in the queen chambers have minimap icons - they shouldn't, so clear those as well (leave it on the one room leading out)
function InteriorSpawner:FixupQueenChamberDoors()

	local function FixupSpawnedDoors()
		-- find all spawned doors that point to the wrong grid position
		local doorsToRemove = {}
		for i,door in pairs(Ents) do
			if door.prefab == "prop_door" then
				local source_interior = door.interior or (self.current_interior and self.current_interior.unique_name)
				local interior = self.interiors[source_interior]
				if interior and interior.dungeon_name == "QUEEN_CHAMBERS_DUNGEON" then
					if door:HasTag("door_south") then
						local exitDirection = self:GetExitDirection(door)
						if exitDirection == "north" then
							door:RemoveTag("door_south")
							door:AddTag("door_north")
						end
					end
					-- while at it, remove the minimap icon, they shouldn't have them (leave it on the one door leading out of here
					local target_interior = door.components.door and door.components.door.target_interior
					target_interior = self.interiors[target_interior]
					if target_interior and target_interior.dungeon_name == "QUEEN_CHAMBERS_DUNGEON" then
						if door.MiniMapEntity then
							door.MiniMapEntity = nil
						end
					end
				end
			end
		end
	end

	local function FixupUnspawnedDoors(interior)
		if interior.dungeon_name == "QUEEN_CHAMBERS_DUNGEON" then
			for j,door in ipairs(interior.prefabs or {}) do
				local target_interior = door.target_interior

				if target_interior then
					if table.contains(door.addtags, "door_south") then
						if door.x_offset < 0 then -- is actually a north door
							for i=1, #door.addtags do
								if door.addtags[i] == "door_south" then
									door.addtags[i] = "door_north"
								end
							end
						end
					end
					-- while at it, remove the minimap icon, they shouldn't have them (leave it on the one door leading out of here
					target_interior = self.interiors[target_interior]
					if target_interior and target_interior.dungeon_name == "QUEEN_CHAMBERS_DUNGEON" then
						if door.animdata then
							door.animdata.minimapicon = nil
						end
					end
				end
			end	
		end
	end

	-- Fixup all spawned doors 
	FixupSpawnedDoors()
	-- and the unspawned ones
	for i,interior in pairs(self.interiors) do
		FixupUnspawnedDoors(interior)
	end
end

-- Beta issue - If a room was denolished and then saved the door was still under the impression it was there
-- Which allowed you to try to demolish it again, alas, this caused the universe to collapse
function InteriorSpawner:FixupDoorsPointingNowhere()
	-- find all doors that are in a non-existing interior. 
	local doorsToRemove = {}
	for i,door in pairs(self.doors) do
		local interior = door.my_interior_name
		-- only doors that are in an interior to begin with
		if interior then
			-- if we're in an interior that doesn't exist, remove us
			if not self.interiors[interior] then
				printf("Door %s is missing it's interior %s", i, interior)
				doorsToRemove[i] = true
			end
		end
	end
	for i,v in pairs(doorsToRemove) do
		printf("Removing door %s",i)
		self.doors[i] = nil
	end

	local function InteriorHasDoor(interior, door)
		if interior then
			local interior = self.interiors[interior]
			if not interior.visited then
				-- unspawned interior - check if the interior contains a definition for the door
				local found = false
				if interior.prefabs then
					for i,v in pairs(interior.prefabs) do
						if v.my_door_id == door then
							return true
						end
					end
				end
			else
				if self.doors[door] then
					return true
				end
			end
		end
		return false
	end

	-- find all spawned doors that point to a non-existing interior or a non-existing door and deactivate them
	for i,door in pairs(Ents) do
		if door:HasTag("house_door") then
			if door.components.door then
				local target_interior = door.components.door.target_interior
				local target_door = door.components.door.target_door_id
				-- only doors that have a target interior to begin with
				if target_interior then
					if not self.interiors[target_interior] then
						printf("Deactivating door %s because it points to a non-existing interior %s",i,tostring(target_interior))
						door:DeactivateSelf()
					else
						if not InteriorHasDoor(target_interior, target_door) then
							printf("Deactivating door %s because it points to a non-existing door %s",i,tostring(target_door))
							door:DeactivateSelf()
						end
					end
				end
			end
		end
	end

	local function FixupDoorsInUnspawnedPlayerRooms(interior)
		if interior.prefabs and interior.playerroom then
			local doorsToRemove = {}
			for j,door in ipairs(interior.prefabs) do
				local target_interior = door.target_interior
				local target_door = door.target_door_id
				local keepDoor = true
				-- only doors that lead to other rooms
				if target_interior then
					if not self.interiors[target_interior] then
						printf("Unspawned door %d in interior %s points to non existing interior %s",j,tostring(interior.unique_name),tostring(target_interior))
						keepDoor = false
					else
						if not InteriorHasDoor(target_interior, target_door) then
							printf("Unspawned door %d in interior %s points to non existing door %s",j,tostring(interior.unique_name),tostring(target_door))
							keepDoor = false
						end
					end							
				end
				if not keepDoor then
					table.insert(doorsToRemove, j)
				end
			end	
			for i = #doorsToRemove,1,-1 do
				local index = doorsToRemove[i]
				printf("Removing door %d from interior %s", index, interior.unique_name)
				table.remove(interior.prefabs, index)
			end
		end
	end
	-- Now find unspawned player doors that may be pointing to non existing doors or non-existing interiors
	for i,interior in pairs(self.interiors) do
		FixupDoorsInUnspawnedPlayerRooms(interior)
	end

end

-- Beta issue: The grid locations for the player crafted rooms were mirrored on the x-axis
-- This gets called on each world. 
-- New worlds and worlds not having gone through the beta wouldn't have playerrooms so it's harmless
function InteriorSpawner:InvertPlayerInteriors()
	if GetWorld().fixedInteriorMirroring then
		return
	end
	GetWorld().fixedInteriorMirroring = true
	local function invertPlayerHome(home)
		for i,v in pairs(home) do
			v.x = 0 - v.x
		end
	end
	-- Invert the grid positions...
	if self.player_homes then
		print("Inverting player interiors")
		for i,v in pairs(self.player_homes) do
			invertPlayerHome(v)
		end
	end
end

-- Another beta issue. Due to an oversight the interior mirroring for playerhouses happened every load
-- so a righthand room would be a lefthand room at next load, making the connection logic quite confused.
-- Try to clean up the damage from this. Doing this by closing doors that point to rooms that are not where they should be.
-- Sadly can't really deduce the correct configuration beyond that as rooms may have been added with save/loads inbetween then.
function InteriorSpawner:FixupPlayerInteriorGridError()
	if GetWorld().fixedPlayerInteriorGridError then
		return
	end
	printf("Fixup for playerroom grid error")
	GetWorld().fixedPlayerInteriorGridError = true

	local function getPlayerRoomGridPos(interiorname)
		local interior = self.interiors[interiorname]
		local rooms = self.player_homes[interior.dungeon_name]
		if rooms then
			local room = rooms[interiorname]
			return room.x, room.y
		end
	end

	local function reimburseFor(door)
		-- Give the player the ingredients needed to craft this recipe
		local recipe = GetRecipe(door)
		local player = GetPlayer()

		if recipe and player then
			for i,v in pairs(recipe.ingredients) do
				for i=1,v.amount do
					local inst = SpawnPrefab(v.type)
					if inst then
						player.components.inventory:GiveItem(inst)
					end
				end
			end
		end
	end

	local function FixupSpawnedDoors()
		-- find all spawned doors that point to the wrong grid position
		local doorsToRemove = {}
		for i,door in pairs(Ents) do
			if door:HasTag("house_door") then
				if door.components.door then
					local keepDoor = true

					local target_interior = door.components.door.target_interior
					local source_interior = door.interior or (self.current_interior and self.current_interior.unique_name)

					if source_interior and target_interior then
						local src_x, src_y = getPlayerRoomGridPos(source_interior)
						local dst_x, dst_y = getPlayerRoomGridPos(target_interior)
						if src_x and dst_x then
							if door:HasTag("door_east") then
								if dst_x < src_x then
									keepDoor = false
								end
							elseif door:HasTag("door_west") then
								if dst_x > src_x then
									keepDoor = false
								end
							end
						end
					end
					if not keepDoor then
						table.insert(doorsToRemove, door)
					end
				end
			end
		end
		for i,door in pairs(doorsToRemove) do
			printf("   Reimbursing player for spawned door %s",door.prefab)
			reimburseFor(door.prefab)
			door:DeactivateSelf()
			door:Remove()
		end
	end

	local function FixupDoorsInUnspawnedPlayerRooms(interior)
		if interior.prefabs and interior.playerroom then
			local doorsToRemove = {}
			for j,door in ipairs(interior.prefabs) do
				local keepDoor = true
				local target_interior = door.target_interior
                local source_interior = interior.unique_name

				if source_interior and target_interior then
					local src_x, src_y = getPlayerRoomGridPos(source_interior)
					local dst_x, dst_y = getPlayerRoomGridPos(target_interior)

					if src_x and dst_x then
						if table.contains(door.addtags, "door_east") then
							if dst_x < src_x then
								keepDoor = false
							end
						elseif table.contains(door.addtags, "door_west") then
							if dst_x > src_x then
								keepDoor = false
							end
						end
					end
				end
				if not keepDoor then
					table.insert(doorsToRemove, j)
				end
			end	
			for i = #doorsToRemove,1,-1 do
				local index = doorsToRemove[i]
				local door = interior.prefabs[index]
				printf("   Rembursing player for unspawned door %s from interior %s", index, door.name, interior.unique_name)
				reimburseFor(door.name)
				table.remove(interior.prefabs, index)
			end
		end
	end
	-- Fixup all spawned doors that are pointing to a misplaced room
	FixupSpawnedDoors()
	-- Now find unspawned player doors that point to misplaced rooms
	for i,interior in pairs(self.interiors) do
		FixupDoorsInUnspawnedPlayerRooms(interior)
	end
	printf("Done playerroom grid error fixup")
end


-- And yet another beta issue. Due to an oversight when fixing the playerhouse mirroring another issue was created 
-- that could lead to multiple rooms in the same grid location which is...awkward.
-- Locate duplicate rooms and move the them to a free position. Disconnect doors leading into/out of them.
function InteriorSpawner:FixupPlayerInteriorGridDuplicates()
	if GetWorld().fixedPlayerInteriorGridDuplication then
		return
	end
	printf("Fixup for playerroom grid duplication")
	GetWorld().fixedPlayerInteriorGridDuplication = true

	local interiorsToRemoveDoorsFrom = {}

	local function relocateRoom(housename, house, roomdata)
		-- move the room to the first free grid position on the left (has to go *somewhere*)
		local interior = self.interiors[roomdata.name]
		if interior then
			local x = roomdata.x
			local y = roomdata.y
			local posOccupied = true
			while posOccupied do
				x = x - 1
				posOccupied = self:GetPlayerRoomIdByIndex(housename, x, y)
			end
			-- move it!
			house[roomdata.name].x = x
			house[roomdata.name].y = y
			-- remove all doors leading out/into this room
			interiorsToRemoveDoorsFrom[interior.unique_name] = true
		end
	end

	local function fixPlayerHome(housename, house)
		local allrooms = {}
		local relocate = {}
		-- count rooms for each grid position
		for i,v in pairs(house) do
			local key = v.x .. ",".. v.y
			allrooms[key] = allrooms[key] or {}
			table.insert(allrooms[key], {name = i, x = v.x, y=v.y})
			interiorsToRemoveDoorsFrom[i] = true
		end
		for key,rooms in pairs(allrooms) do
			local count = #rooms 
		 	if count > 1 then
				-- all rooms over 1 need to be relocated
				for i = 2,count do
					local room = rooms[i]
					print("relocate room",i, room.name, room.x, room.y)
					relocate[#relocate+1] = room
				end
			end
		end
		for i,room in pairs(relocate) do
			relocateRoom(housename,house,room)
		end
	end
	-- locate duplicated rooms
	for i,v in pairs(self.player_homes) do
		fixPlayerHome(i,v)
	end

	local function reimburseFor(door)
		-- Give the player the ingredients needed to craft this recipe
		local recipe = GetRecipe(door)
		local player = GetPlayer()

		if recipe and player then
			for i,v in pairs(recipe.ingredients) do
				for i=1,v.amount do
					local inst = SpawnPrefab(v.type)
					if inst then
						player.components.inventory:GiveItem(inst)
					end
				end
			end
		end
	end

	local function FixupSpawnedDoors()
		-- find all spawned doors that have a relationship to the relocated rooms
		local doorsToRemove = {}
		for i,door in pairs(Ents) do
			if door:HasTag("house_door") then
				if door.components.door then
					local keepDoor = true

					local target_interior = door.components.door.target_interior
					local source_interior = door.interior or (self.current_interior and self.current_interior.unique_name)

					-- if this door points to a moved room, or is in a moved room, alas, we had fun together
					if interiorsToRemoveDoorsFrom[target_interior] or interiorsToRemoveDoorsFrom[source_interior] then
						table.insert(doorsToRemove, door)
					end
				end
			end
		end
		for i,door in pairs(doorsToRemove) do
			printf("   Reimbursing player for spawned door %s",door.prefab)
			reimburseFor(door.prefab)
			door:DeactivateSelf()
			door:Remove()
		end
	end

	local function FixupDoorsInUnspawnedPlayerRooms(interior)
		if interior.prefabs and interior.playerroom then
			local doorsToRemove = {}
			for j,door in ipairs(interior.prefabs) do
				local keepDoor = true
				local target_interior = door.target_interior
                local source_interior = interior.unique_name

				-- is it an actual interior door?
				if source_interior and target_interior then
					-- that is related to one of the moved rooms?
					if interiorsToRemoveDoorsFrom[source_interior] or  interiorsToRemoveDoorsFrom[target_interior] then
						table.insert(doorsToRemove, j)
					end
				end
			end	
			for i = #doorsToRemove,1,-1 do
				local index = doorsToRemove[i]
				local door = interior.prefabs[index]
				printf("   Rembursing player for unspawned door %s from interior %s", index, door.name, interior.unique_name)
				reimburseFor(door.name)
				table.remove(interior.prefabs, index)
			end
		end
	end
	-- remove doors from/into all erroneour interiors (*unless it's the exit door!")
	-- Process all spawned doors
	FixupSpawnedDoors()
	-- Now find unspawned player doors that point to moved rooms
	for i,interior in pairs(self.interiors) do
		FixupDoorsInUnspawnedPlayerRooms(interior)
	end
end

-- And another beta issue. All batcaves had the same name, which is cool, but it makes them part of the same dungeon and 
-- the minimapper would draw them all on top of eachoter, which was slightly less cool.
function InteriorSpawner:FixupVampireBatCaves()
	for i,v in pairs(self.interiors) do
		if v.dungeon_name == "vampirebatcave" then
			v.dungeon_name = "vampirebatcave_"..i
			v.forceInteriorMinimap = true
		end
	end	
end

-- This is horrific, but I saw no decent way around it.
-- In my infinite wisdom (this is not up for debate) I put interior spawn location at 2000,0,-2000. This all worked 
-- fine *except* that the pathfinder doesn't like coordinates below absolute zero (top left corner of world map).
-- So I had to move the interior spawn origin and any ents that happened to be around there. No big deal, could just
-- do it on postload....except that then the entities there will think they spawn on water (objects that spawn outside
-- map space are considered to be on water, and we wouldn't want some entities in an interior to randomly sink.
-- Alas, my workaround is this, entities from an older world that are in interior spawn space get moved right before 
-- they spawn so they will be on solid ground.
function InteriorSpawner.FixForSpawnOriginMigration(x,y,z,name)
	local pos = Vector3(x,y,z)
	local original_spawn_location = Vector3(2000,0,-2000)
	local new_spawn_location = interior_spawn_origin
	local delta = pos:Dist(original_spawn_location)
	if delta <= 50 then
		pos = pos - original_spawn_location
		pos = pos + new_spawn_location
		if name then
			print("----> moving",name, "with interior delta",delta,"from",Vector3(x,y,z),"to",pos)
		end
		return pos:Get()
	end
	return x,y,z
end

return InteriorSpawner