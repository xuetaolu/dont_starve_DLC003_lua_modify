require "prefabutil"
require "recipes"

local assets =
{
	Asset("ANIM", "anim/ant_hill_entrance.zip"),
    Asset("ANIM", "anim/ant_queen_entrance.zip"),
    Asset("SOUND", "sound/pig.fsb"),
    Asset("MINIMAP_IMAGE", "ant_hill_entrance"), 
    Asset("MINIMAP_IMAGE", "ant_cave_door"), 
}

local prefabs = 
{
	"antman",
    "antman_warrior",
    "int_ceiling_dust_fx",
    "antchest",
    "giantgrub",
    "ant_cave_lantern",
    "antqueen",
}

local dodebug = false

function shuffle(tbl)
    local size = #tbl

    for i = size, 1, -1 do
        local rand = math.random(size)
        tbl[i], tbl[rand] = tbl[rand], tbl[i]
    end

    return tbl
end

-- The camera is setup in the interiors such that it looks along the x axis.
-- Therefore, the x values are back to front, and the z values are side to side.

local function getOffsetX()
    return (math.random() * 7) - (7 / 2)
end

local function getOffsetBackX()
    return (math.random(0, 0.3) * 7) - (7 / 2)
end

local function getOffsetFrontX()
    return (math.random(0.7, 1.0) * 7) - (7 / 2)
end

local function getOffsetZ()
    return (math.random() * 13) - (13 / 2)
end

local function getOffsetLhsZ()
    return (math.random(0, 0.3) * 13) - (13 / 2)
end

local function getOffsetRhsZ()
    return (math.random(0.7, 1.0) * 13) - (13 / 2)
end

-- These are the room quadrants for
-- generating lanterns in the anthill.
-- |-------|-------|
-- |   1   |   2   |
-- |-------|-------|
-- |   3   |   4   |
-- |-------|-------|

local ROOM_QUADRANT_1 = 1
local ROOM_QUADRANT_2 = 2
local ROOM_QUADRANT_3 = 3
local ROOM_QUADRANT_4 = 4

local function getOffsetConstrainedToQuadrant(roomQuadrant)
    local x = 0
    local z = 0

    if roomQuadrant == ROOM_QUADRANT_1 then
        x = getOffsetBackX()
        z = getOffsetLhsZ()
    end

    if roomQuadrant == ROOM_QUADRANT_2 then
        x = getOffsetBackX()
        z = getOffsetRhsZ()
    end

    if roomQuadrant == ROOM_QUADRANT_3 then
        x = getOffsetFrontX()
        z = getOffsetLhsZ()
    end

    if roomQuadrant == ROOM_QUADRANT_4 then
        x = getOffsetFrontX()
        z = getOffsetRhsZ()
    end

    return { x_offset = x, z_offset = z }
end

local function addLanternTables(roomItems, minLanterns, maxLanterns)
    assert((minLanterns > 0) and (minLanterns <= maxLanterns))
    local numLanterns = math.random(minLanterns, maxLanterns)
    local quadrants = shuffle({ ROOM_QUADRANT_1, ROOM_QUADRANT_2, ROOM_QUADRANT_3, ROOM_QUADRANT_4 })

    for i = 1, numLanterns, 1 do
        local offsets = getOffsetConstrainedToQuadrant(quadrants[i])
        local itemTable = { name = "ant_cave_lantern", x_offset = offsets.x_offset, z_offset = offsets.z_offset }
        table.insert(roomItems, itemTable)
    end
end

local function addItemTables(itemTypeName, roomItems, minItems, maxItems)
    assert((minItems > 0) and (minItems <= maxItems))
    local numItems = math.random(minItems, maxItems)

    for i = 1, numItems, 1 do
        local itemTable = { name = itemTypeName, x_offset = getOffsetX(), z_offset = getOffsetZ() }
        table.insert(roomItems, itemTable)
    end
end

local ANTHILL_DUNGEON_NAME = "ANTHILL1"

local EMPTY_ROOM_IDX         = 1
local ANT_HOME_ROOM_IDX      = 2
local WANDERING_ANT_ROOM_IDX = 3
local TREASURE_ROOM_IDX      = 4

local MIN_LANTERNS = 1
local MAX_LANTERNS = 3

local room_setup_fns =
{
    function()
        local roomItems = {}
        addLanternTables(roomItems, MIN_LANTERNS, MAX_LANTERNS)
        return roomItems
    end, -- EMPTY ROOM

    function()
        local roomItems = {}
        addItemTables("antcombhome", roomItems, 1, 2)
        addItemTables("antman", roomItems, 3, 4)
        addLanternTables(roomItems, MIN_LANTERNS, MAX_LANTERNS)
        return roomItems
    end, -- ANT HOME ROOM

    function()
        local roomItems = {}
        addItemTables("antman", roomItems, 1, 3)
        addLanternTables(roomItems, MIN_LANTERNS, MAX_LANTERNS)
        return roomItems
    end, -- WANDERING ANT ROOM

    function()
        local roomItems = {}
        addItemTables("antcombhome", roomItems, 1, 1)
        addItemTables("antman", roomItems, 1, 2)
        addItemTables("antchest", roomItems, 1, 2)
        addLanternTables(roomItems, MIN_LANTERNS, MAX_LANTERNS)
        return roomItems
    end, -- TREASURE ROOM
}

-- Each value here indicates how many of the 25 rooms are created with each room setup.
local roomCardinality = { 7, 5, 10, 3 }

local dirNames = { "east", "west", "north", "south" }
local dirNamesOpposite = { "west", "east", "south", "north" }

local EAST_DOOR_IDX  = 1
local WEST_DOOR_IDX  = 2
local NORTH_DOOR_IDX = 3
local SOUTH_DOOR_IDX = 4

local NUM_ENTRANCES = 3
local NUM_CHAMBER_ENTRANCES = 1--3

local NUM_ROWS = 5
local NUM_COLS = 5

local function buildFloorPlan(inst)
    local NUM_TILE_ROWS = 5
    local NUM_TILE_COLS = 5

    local tiles = {}

    for i = 1, NUM_TILE_ROWS, 1 do
        local tileRow = {}

        for j = 1, NUM_TILE_COLS, 1 do
            local tile = false
            table.insert(tileRow, tile)
        end

        table.insert(tiles, tileRow)
    end

    return tiles
end

local function getlocationoutofcenter(dist, hole, random, invert)
    local pos =  (math.random() * ((dist / 2) - (hole / 2))) + hole / 2    
    if invert or (random and math.random() < 0.5) then
        pos = pos *-1
    end
    return pos
end

local function buildEntrances(inst)
    local numEntrancesChosen = 0

    repeat
        local rowIndex = math.random(1, NUM_ROWS)
        local colIndex = math.random(1, NUM_COLS)

        if not inst.rooms[rowIndex][colIndex].isEntrance then
            inst.rooms[rowIndex][colIndex].isEntrance = true
            numEntrancesChosen = numEntrancesChosen + 1
        end
    until (numEntrancesChosen == NUM_ENTRANCES)
end

local function buildChamberEntrances(inst)
   local numEntrancesChosen = 0

    repeat
        local rowIndex = math.random(1, NUM_ROWS)
        local colIndex = math.random(1, NUM_COLS)

        if not inst.rooms[rowIndex][colIndex].isEntrance and not inst.rooms[rowIndex][colIndex].isChamberEntrance then
            inst.rooms[rowIndex][colIndex].isChamberEntrance = true
            numEntrancesChosen = numEntrancesChosen + 1
        end
    until (numEntrancesChosen == NUM_CHAMBER_ENTRANCES) 
end

local function connectRooms(inst, dirIndex, sourceRoom, destRoom)
    local interior_spawner = GetWorld().components.interiorspawner
    local dirs = interior_spawner:GetDir()
    local dirsOpposite = interior_spawner:GetDirOpposite()

    sourceRoom.exits[dirs[dirIndex]] =
    {
        target_room = destRoom.idx,
        bank  = "ant_cave_door",
        build = "ant_cave_door",
        room  = sourceRoom.idx,
        sg_name = "SGanthilldoor_"..dirNames[dirIndex],
        startstate = "idle_"..dirNames[dirIndex],
    }

    destRoom.exits[dirsOpposite[dirIndex]] =
    {
        target_room = sourceRoom.idx,
        bank  = "ant_cave_door",
        build = "ant_cave_door",
        room  = destRoom.idx,
        sg_name = "SGanthilldoor_"..dirNamesOpposite[dirIndex],
        startstate = "idle_"..dirNamesOpposite[dirIndex],
    }
end

local function buildDoors(inst)
    for i = 1, #inst.rooms, 1 do
        for j = 1, #inst.rooms[i], 1 do
            local sourceRoom = inst.rooms[i][j]

            -- EAST
            if (sourceRoom.x + 1) <= NUM_COLS then
                local destRoom = inst.rooms[sourceRoom.y][sourceRoom.x + 1]
                connectRooms(inst, EAST_DOOR_IDX, sourceRoom, destRoom)
            end

            -- WEST
            if (sourceRoom.x - 1) >= 1 then
                local destRoom = inst.rooms[sourceRoom.y][sourceRoom.x - 1]
                connectRooms(inst, WEST_DOOR_IDX, sourceRoom, destRoom)
            end

            -- NORTH
            -- The entrance is always from the north, so when attempting to link
            -- to a northern room, give up if the current room is an entrance.
            if ((sourceRoom.y - 1) >= 1) and not sourceRoom.isEntrance then
                local destRoom = inst.rooms[sourceRoom.y - 1][sourceRoom.x]
                connectRooms(inst, NORTH_DOOR_IDX, sourceRoom, destRoom)
            end

            -- SOUTH
            if (sourceRoom.y + 1) <= NUM_ROWS then
                -- The entrance is always from the north, so when attempting
                -- to link to a southern room, give up if it's an entrance.
                local destRoom = inst.rooms[sourceRoom.y + 1][sourceRoom.x]
                if not destRoom.isEntrance then
                    connectRooms(inst, SOUTH_DOOR_IDX, sourceRoom, destRoom)
                end
            end
        end
    end
end

local function rebuildGrid(inst)
    for i = 1, NUM_ROWS, 1 do
        for j = 1, NUM_COLS, 1 do
            inst.rooms[i][j].parentRoom = nil
            inst.rooms[i][j].doorsEnabled = { false, false, false, false }
            inst.rooms[i][j].dirsExplored = { false, false, false, false }
        end
    end
end

local function buildGrid(inst)
    local interior_spawner = GetWorld().components.interiorspawner

    inst.rooms = {}

    for i = 1, NUM_ROWS, 1 do
        local roomRow = {}

        for j = 1, NUM_COLS, 1 do
            local room =
            {
                x = j,
                y = i,
                idx = "ANTHILL_"..interior_spawner:GetNewID(), 
                exits = {},
                isEntrance = false,
                isChamberEntrance = false,
                parentRoom = nil,
                doorsEnabled = { false, false, false, false },
                dirsExplored = { false, false, false, false },
            }

            table.insert(roomRow, room)
        end

        table.insert(inst.rooms, roomRow)
    end

    buildEntrances(inst)
    buildChamberEntrances(inst)

    -- All possible doors are built, and then the doorsEnabled flag
    -- is what indicates if they should actually be in use or not.
    buildDoors(inst)
end

local function link(inst, sourceRoom)
    if dodebug then
        print("ANTHILL: link sourceRoom = "..sourceRoom.idx)
        print("ANTHILL: col = "..sourceRoom.x)
        print("ANTHILL: row = "..sourceRoom.y)
    end
    local interior_spawner = GetWorld().components.interiorspawner
    local row = 0
    local col = 0
    local dir = 0

    local dirsOpposite = { WEST_DOOR_IDX, EAST_DOOR_IDX, SOUTH_DOOR_IDX, NORTH_DOOR_IDX }

    if sourceRoom == nil then
        return nil
    end

    -- While there are still directions to explore.
    while not (sourceRoom.dirsExplored[EAST_DOOR_IDX] and sourceRoom.dirsExplored[WEST_DOOR_IDX] and sourceRoom.dirsExplored[NORTH_DOOR_IDX] and sourceRoom.dirsExplored[SOUTH_DOOR_IDX]) do
        local dirIndex = math.random(#sourceRoom.dirsExplored)

        -- If already explored, then try again.
        if not sourceRoom.dirsExplored[dirIndex] then
            sourceRoom.dirsExplored[dirIndex] = true

            local dirPossible = false
            if dirIndex == EAST_DOOR_IDX then -- EAST
                if (sourceRoom.x + 1 <= NUM_COLS) then
                    col = sourceRoom.x + 1
                    row = sourceRoom.y
                    dirPossible = true
                end
            elseif dirIndex == SOUTH_DOOR_IDX then -- SOUTH
                if (sourceRoom.y + 1 <= NUM_ROWS) then
                    -- The entrance is always from the north, so when attempting
                    -- to link to a southern room, give up if it's an entrance.
                    local destRoom = inst.rooms[sourceRoom.y + 1][sourceRoom.x]
                    if not destRoom.isEntrance then
                        col = sourceRoom.x
                        row = sourceRoom.y + 1
                        dirPossible = true
                    end
                end
            elseif dirIndex == WEST_DOOR_IDX then -- WEST
                if (sourceRoom.x - 1 >= 1) then
                    col = sourceRoom.x - 1
                    row = sourceRoom.y
                    dirPossible = true
                end
            elseif dirIndex == NORTH_DOOR_IDX then -- NORTH
                -- The entrance is always from the north, so when attempting to link
                -- to a northern room, give up if the current room is an entrance.
                if ((sourceRoom.y - 1 >= 1) and not sourceRoom.isEntrance) then
                    col = sourceRoom.x
                    row = sourceRoom.y - 1
                    dirPossible = true
                end
            end

            if dirPossible then
                -- Get destination node into pointer (makes things a tiny bit faster)
                local destRoom = inst.rooms[row][col]

                -- If destination is a linked node already - abort
                if (destRoom.parentRoom == nil) then
                     -- Otherwise, adopt node
                    destRoom.parentRoom = sourceRoom

                    -- Remove wall between nodes (ie. Create door.)
                    sourceRoom.doorsEnabled[dirIndex] = true
                    destRoom.doorsEnabled[dirsOpposite[dirIndex]] = true
                    if dodebug then
                        print("ANTHILL: "..sourceRoom.idx.." connected to "..destRoom.idx)
                    end

                    -- Return address of the child node
                    return destRoom
                end
            end
        end
    end

    -- If nothing more can be done here - return parent's address
    return sourceRoom.parentRoom
end

local function buildWalls(inst)
    local startRoom = inst.rooms[1][1]
    startRoom.parentRoom = startRoom
    local lastRoom = startRoom

    -- Connect nodes until start node is reached and can't be left
    repeat
        lastRoom = link(inst, lastRoom)
    until (lastRoom == startRoom)
end

local queenchamber_placement_id = nil
local queen_chamber_ids = {}
local final_chamber_id = "FINAL_QUEEN_CHAMBER"

local function spawnhoney()
    local width = TUNING.ROOM_LARGE_WIDTH
    local depth = TUNING.ROOM_LARGE_DEPTH

    local choice = math.random(1, 4)
    if choice == 1 then
         return { name = "deco_cave_honey_drip_1", x_offset = -depth/2, z_offset = getlocationoutofcenter(width*0.65, 3, true), rotation =- 90 }
    elseif choice == 2 then
         return { name = "deco_cave_ceiling_drip_2", x_offset = -depth/2, z_offset = getlocationoutofcenter(width*0.65, 3, true), rotation =- 90 }
    elseif choice == 3 then
        if math.random() < 0.5 then
            return { name = "deco_cave_honey_drip_side_1", x_offset = getlocationoutofcenter(depth*0.65, 3, true), z_offset = -width/2, rotation =- 90 }
        else
            return { name = "deco_cave_honey_drip_side_1", x_offset = getlocationoutofcenter(depth*0.65, 3, true), z_offset =  width/2, rotation =- 90, flip = true }
        end
    elseif choice == 4 then
        if math.random() < 0.5 then
            return { name = "deco_cave_honey_drip_side_2", x_offset = getlocationoutofcenter(depth*0.65, 3, true), z_offset = -width/2, rotation =- 90 }
        else
            return { name = "deco_cave_honey_drip_side_2", x_offset = getlocationoutofcenter(depth*0.65, 3, true), z_offset = width/2, rotation =- 90, flip = true }
        end
    end
end

local function AddCommonDeco(addprops)

    local width = TUNING.ROOM_LARGE_WIDTH
    local depth = TUNING.ROOM_LARGE_DEPTH

    table.insert(addprops, { name = "deco_hive_cornerbeam",  x_offset = -depth/2, z_offset = -width/2, rotation = -90 })
    table.insert(addprops, { name = "deco_hive_cornerbeam",  x_offset = -depth/2, z_offset =  width/2, rotation = -90, flip = true })
    table.insert(addprops, { name = "deco_hive_pillar_side", x_offset =  depth/2, z_offset = -width/2, rotation = -90 })
    table.insert(addprops, { name = "deco_hive_pillar_side", x_offset =  depth/2, z_offset =  width/2, rotation = -90, flip = true })        

    table.insert(addprops, { name = "deco_hive_floor_trim", x_offset = depth/2, z_offset = -width/4, rotation = -90 })
    table.insert(addprops, { name = "deco_hive_floor_trim", x_offset = depth/2, z_offset =        0, rotation = -90 })
    table.insert(addprops, { name = "deco_hive_floor_trim", x_offset = depth/2, z_offset =  width/4, rotation = -90 })

    return addprops
end

local function AddChamberDeco(addprops)

   local width = TUNING.ROOM_LARGE_WIDTH
    local depth = TUNING.ROOM_LARGE_DEPTH

    addprops = AddCommonDeco(addprops)

    for i=1, math.random(8, 16) do
        table.insert(addprops, { name = "rock_antcave", x_offset = getlocationoutofcenter(depth*0.65, 3, true), z_offset = getlocationoutofcenter(width*0.65, 3, true) })
    end
  
    if math.random() < 0.3 then
        table.insert(addprops, { name = "deco_hive_debris", x_offset = depth*0.65 * math.random() - depth*0.65/2, z_offset = width*0.65 * math.random() - width*0.65/2 })
    end

    if math.random() < 0.3 then
        table.insert(addprops, { name = "deco_hive_debris", x_offset = depth*0.65 * math.random() - depth*0.65/2, z_offset = width*0.65 * math.random() - width*0.65/2 })
    end

    local drips = math.random(1, 6) - 1
    while drips > 0 do
        table.insert(addprops, spawnhoney())
        drips = drips -1
    end

    return addprops
end

local function AddDeco(addprops)
    
    local width = TUNING.ROOM_LARGE_WIDTH
    local depth = TUNING.ROOM_LARGE_DEPTH

    addprops = AddCommonDeco(addprops)

    if math.random() < 0.5 then
        table.insert(addprops, { name = "rock_antcave", x_offset = -depth/2*0.65 * math.random(), z_offset = getlocationoutofcenter(width*0.65, 3, true) })
    end

    if math.random() < 0.5 then
        table.insert(addprops, { name = "rock_antcave", x_offset = -depth/2*0.65 * math.random(), z_offset = getlocationoutofcenter(width*0.65, 3, true) })
    end

    if math.random() < 0.5 then
        table.insert(addprops, { name = "rock_antcave", x_offset = -depth/2*0.65 * math.random(), z_offset = getlocationoutofcenter(width*0.65, 3, true) })
    end
  
    if math.random() < 0.3 then
        table.insert(addprops, { name = "deco_hive_debris", x_offset = depth*0.65 * math.random() - depth*0.65/2, z_offset = width*0.65 * math.random() - width*0.65/2 })
    end

    if math.random() < 0.3 then
        table.insert(addprops, { name = "deco_hive_debris", x_offset = depth*0.65 * math.random() - depth*0.65/2, z_offset = width*0.65 * math.random() - width*0.65/2 })
    end

    local drips = math.random(1, 6) - 1
    while drips > 0 do
        table.insert(addprops, spawnhoney())
        drips = drips -1
    end

    return addprops
end

local function buildAllRooms(inst)
    local interior_spawner = GetWorld().components.interiorspawner

    local doorwayPrefabs = { inst }

    for i, ent in pairs(Ents) do
        if ent:HasTag("ANTHILL_EXIT") then
            ent:RemoveTag("ANTHILL_EXIT")
            table.insert(doorwayPrefabs, ent)
        end
    end

    local doorway = 1

    local room_idx_list = {}
    for roomIdx = 1, #roomCardinality, 1 do
        local cardinality = roomCardinality[roomIdx]

        for k = 1, cardinality, 1 do
            table.insert(room_idx_list, roomIdx)
        end
    end

    room_idx_list = shuffle(room_idx_list)
    local currentRoomSetupIndex = 1

    for i = 1, #inst.rooms, 1 do
        for j = 1, #inst.rooms[i], 1 do
            local room = inst.rooms[i][j]
            local addprops = {}

            local floorPlan = buildFloorPlan()
            local propFn = room_setup_fns[room_idx_list[currentRoomSetupIndex]]
            local props = propFn()

            for p, prop in ipairs(props) do
                if room.isChamberEntrance then
                    break
                end

                local newTileFound = false

                repeat
                    local rowTileIndex = math.random(1, #floorPlan)
                    local colTileIndex = math.random(1, #floorPlan[1])
                    newTileFound = not floorPlan[rowTileIndex][colTileIndex]

                    if newTileFound then
                        floorPlan[rowTileIndex][colTileIndex] = true

                        local rowFloorTilePos = rowTileIndex / #floorPlan
                        local colFloorTilePos = colTileIndex / #floorPlan[1]

                        local offsetX = (rowFloorTilePos *  7) - ( 7 / 2)
                        local offsetZ = (colFloorTilePos * 13) - (13 / 2)

                        prop.x_offset = offsetX
                        prop.z_offset = offsetZ
                    end
                until newTileFound

                table.insert(addprops, prop)
            end

            currentRoomSetupIndex = currentRoomSetupIndex + 1

            if room.isEntrance then
                assert(doorway <= NUM_ENTRANCES)
                local prefab = { name = "prop_door", x_offset = -TUNING.ROOM_LARGE_DEPTH/2, z_offset = 0,  animdata = { minimapicon = "ant_cave_door.png", bank = "ant_cave_door", build = "ant_cave_door", anim = "day_loop", light = true },
                                my_door_id = "ANTHILL_"..doorway.."_EXIT", target_door_id = "ANTHILL_"..doorway.."_ENTRANCE", rotation = -90, angle=0, addtags = { "timechange_anims", "anthill_inside" } }
                table.insert(addprops, prefab)

                local exterior_door_def =
                {
                    my_door_id = "ANTHILL_"..doorway.."_ENTRANCE",
                    target_door_id = "ANTHILL_"..doorway.."_EXIT",
                    target_interior = room.idx,
                }

                interior_spawner:AddDoor(doorwayPrefabs[doorway], exterior_door_def)
                doorway = doorway + 1
                addprops = AddDeco(addprops)

            elseif room.isChamberEntrance then

                local width = TUNING.ROOM_LARGE_WIDTH
                local depth = TUNING.ROOM_LARGE_DEPTH

                local antqueen_chamber_pts = 
                {
                    { x =  (depth/2) - 3.5, z =  (width/2) - 5.5},
                    { x = -(depth/2) + 3.5, z =  (width/2) - 5.5},
                    { x =  (depth/2) - 3.5, z = -(width/2) + 5.5},
                    { x = -(depth/2) + 3.5, z = -(width/2) + 5.5},
                }

                local spawn_pt = antqueen_chamber_pts[math.random(1, #antqueen_chamber_pts)]
                --local spawn_pt = antqueen_chamber_pts[1]

                queenchamber_placement_id = room.idx
                local prefab = 
                { 
                    name = "prop_door",
                    x_offset = spawn_pt.x,
                    z_offset = spawn_pt.z,
                    animdata = { minimapicon = "ant_queen_entrance.png", bank = "entrance", build = "ant_queen_entrance", anim = "idle"},
                    my_door_id = "ANTQUEEN_CHAMBERS_ENTRANCE",
                    target_door_id = "ANTQUEEN_CHAMBERS_EXIT",
                    target_interior = queen_chamber_ids[1],
                    make_obstacle = true,
                    obstacle_scale = 2,
                    rotation = -90,
                    addtags = {"chamber_entrance"},
                }

                table.insert(addprops, prefab)
                for i=1,math.random(2, 4) do
                    table.insert(addprops, {name = "antman_warrior", x_offset = getlocationoutofcenter(depth*0.65, 5, true), z_offset = getlocationoutofcenter(width*0.65, 5, true)})
                end
                
                for i=1,math.random(2, 4) do
                    table.insert(addprops, {name = "ant_cave_lantern", x_offset = getlocationoutofcenter(depth*0.65, 5, true), z_offset = getlocationoutofcenter(width*0.65, 5, true)})
                end

            else
                addprops = AddDeco(addprops)
            end

            local floortexture = "levels/textures/interiors/antcave_floor.tex"
            local walltexture = "levels/textures/interiors/antcave_wall_rock.tex"
            local minimaptexture = "levels/textures/map_interior/mini_antcave_floor.tex"

            interior_spawner:CreateRoom("generic_interior", TUNING.ROOM_LARGE_WIDTH, 7, TUNING.ROOM_LARGE_DEPTH, ANTHILL_DUNGEON_NAME, room.idx, addprops, room.exits, walltexture, floortexture, minimaptexture, nil, "images/colour_cubes/pigshop_interior_cc.tex", nil, nil, "anthill","ANT_HIVE","DIRT")
        end
    end
end

-- We generate these outside of the CreateQueenChambers function because we need the ids to
-- link it to the regular anthill
local function GenerateQueenChamberIDS(inst, room_count)
    local interior_spawner = GetWorld().components.interiorspawner
    for i=1, room_count do
        local newid = interior_spawner:GetNewID()
        table.insert(queen_chamber_ids, newid)
    end
end

local function CreateQueenChambers( inst, room_count )
    
    local interior_spawner = GetWorld().components.interiorspawner

    local floortexture = "levels/textures/interiors/antcave_floor.tex"
    local walltexture = "levels/textures/interiors/antcave_wall_rock.tex"
    local minimaptexture = "levels/textures/map_interior/mini_antcave_floor.tex"
    local addprops = {}
    
    local interiors = {}

    local QUEEN_CHAMBERS = "QUEEN_CHAMBERS_"
    local FROM_STRING = "ANTQUEEN_CHAMBERS_FROM_"
    local TO_STRING = "ANTQUEEN_CHAMBERS_TO_"

    local depth = TUNING.ROOM_LARGE_DEPTH
    local width = TUNING.ROOM_LARGE_WIDTH

    for i=1, room_count do
        local addprops = {}

        if i ~= room_count then
            
            addprops = AddChamberDeco(addprops)
            for i=1,math.random(2, 5) do
                table.insert(addprops, {name = "antman_warrior", x_offset = getlocationoutofcenter(depth*0.65, 5, true), z_offset = getlocationoutofcenter(width*0.65, 5, true)})
            end

            local target_interior_id = i ~= room_count - 1 and queen_chamber_ids[i+1] or final_chamber_id


            local door_to =
            {
                my_door_id = TO_STRING .. queen_chamber_ids[i+1],
                target_door_id = FROM_STRING .. queen_chamber_ids[i+1],
                target_interior = target_interior_id,
            }

            table.insert (addprops,
            {
                name = "prop_door", x_offset = -depth/2, z_offset = 0, animdata = { bank = "ant_cave_door", build = "ant_cave_door", anim = "day_loop" },
                my_door_id = door_to.my_door_id, target_door_id = door_to.target_door_id, target_interior = door_to.target_interior, rotation = -90, angle=0, addtags = { "door_north" }
            })

        else
            addprops = AddCommonDeco(addprops)

            table.insert (addprops, { name = "antqueen", x_offset = 0, z_offset = 0 })
            table.insert (addprops, { name = "ant_cave_lantern", x_offset = -depth/2, z_offset = 0 }) -- Behind the queen, placed there for better lighting

            table.insert(addprops, { name = "ant_cave_lantern", x_offset = -depth/2, z_offset = (depth/2) - 2 }) 
            table.insert(addprops, { name = "ant_cave_lantern", x_offset = -depth/2, z_offset = (-depth/2) + 2 }) 
            
            table.insert(addprops, { name = "ant_cave_lantern", x_offset = 0, z_offset = (depth/2) + 1 }) 
            table.insert(addprops, { name = "ant_cave_lantern", x_offset = 0, z_offset = (-depth/2) - 1 })

            -------------
            -- Gross
            table.insert (addprops, { name = "throne_wall_large", x_offset = 1, z_offset = 2.25   })
            table.insert (addprops, { name = "throne_wall", x_offset =  2.2, z_offset = 2.5 })
            table.insert (addprops, { name = "throne_wall", x_offset =  1.9, z_offset = 3   })
            table.insert (addprops, { name = "throne_wall", x_offset =  1.6, z_offset = 3.5 })
            table.insert (addprops, { name = "throne_wall", x_offset =  1.3, z_offset = 4   })
            table.insert (addprops, { name = "throne_wall", x_offset =  1,   z_offset = 4.5 })
            table.insert (addprops, { name = "throne_wall", x_offset =  0.7, z_offset = 5   })
            table.insert (addprops, { name = "throne_wall", x_offset =  0.4, z_offset = 5.5 })
            table.insert (addprops, { name = "throne_wall", x_offset =  0.1, z_offset = 6   })
            table.insert (addprops, { name = "throne_wall", x_offset = -0.4, z_offset = 6   })
            
            table.insert (addprops, { name = "throne_wall", x_offset =  -3.25, z_offset = 1.5 })
            table.insert (addprops, { name = "throne_wall", x_offset =  -3,    z_offset = 2   })
            table.insert (addprops, { name = "throne_wall", x_offset =  -2.75, z_offset = 2.5 })
            table.insert (addprops, { name = "throne_wall", x_offset =  -2.5,  z_offset = 3   })
            table.insert (addprops, { name = "throne_wall", x_offset =  -2.25, z_offset = 3.5 })
            table.insert (addprops, { name = "throne_wall", x_offset =  -2,    z_offset = 4   })
            table.insert (addprops, { name = "throne_wall", x_offset =  -1.75, z_offset = 4.5 })
            table.insert (addprops, { name = "throne_wall", x_offset =  -1.5,  z_offset = 5   })
            table.insert (addprops, { name = "throne_wall", x_offset =  -1.25, z_offset = 5.5 })
            table.insert (addprops, { name = "throne_wall", x_offset =  -1,    z_offset = 6   })

            table.insert (addprops, { name = "throne_wall", x_offset =  -3.25, z_offset =  1   })
            table.insert (addprops, { name = "throne_wall", x_offset =  -3.25, z_offset =  0.5 })
            table.insert (addprops, { name = "throne_wall", x_offset =  -3.25, z_offset = -0   })
            table.insert (addprops, { name = "throne_wall", x_offset =  -3.25, z_offset = -0.5 })
            table.insert (addprops, { name = "throne_wall", x_offset =  -3.25, z_offset = -1   })
            table.insert (addprops, { name = "throne_wall", x_offset =  -3.25, z_offset = -1.5 })
            table.insert (addprops, { name = "throne_wall", x_offset =  -3,    z_offset = -2   })
            table.insert (addprops, { name = "throne_wall", x_offset =  -2.75, z_offset = -2.5 })
            table.insert (addprops, { name = "throne_wall", x_offset =  -2.5,  z_offset = -3   })
            table.insert (addprops, { name = "throne_wall", x_offset =  -2.25, z_offset = -3.5 })
            table.insert (addprops, { name = "throne_wall", x_offset =  -2,    z_offset = -4   })
            table.insert (addprops, { name = "throne_wall", x_offset =  -1.75, z_offset = -4.5 })
            table.insert (addprops, { name = "throne_wall", x_offset =  -1.5,  z_offset = -5   })
            table.insert (addprops, { name = "throne_wall", x_offset =  -1.25, z_offset = -5.5 })
            table.insert (addprops, { name = "throne_wall", x_offset =  -1,    z_offset = -6   })

            table.insert (addprops, { name = "throne_wall_large", x_offset =  1.5,  z_offset = -2.5   })
            table.insert (addprops, { name = "throne_wall", x_offset =  2,    z_offset = -3   })
            table.insert (addprops, { name = "throne_wall", x_offset =  1.75, z_offset = -3.5 })
            table.insert (addprops, { name = "throne_wall", x_offset =  1.5,  z_offset = -4   })
            table.insert (addprops, { name = "throne_wall", x_offset =  1.25, z_offset = -4.5 })
            table.insert (addprops, { name = "throne_wall", x_offset =  1,    z_offset = -5   })
            table.insert (addprops, { name = "throne_wall", x_offset =  0.75, z_offset = -5.5 })
            table.insert (addprops, { name = "throne_wall", x_offset =  0,    z_offset = -6   })
            table.insert (addprops, { name = "throne_wall", x_offset = -0.5,  z_offset = -6   })
        end

        if i ~= 1 then
            local door_from =
            {
                my_door_id = FROM_STRING .. queen_chamber_ids[i],
                target_door_id = TO_STRING .. queen_chamber_ids[i],
                target_interior = queen_chamber_ids[i-1],
            }

            table.insert( addprops,
            {
                name = "prop_door", x_offset = depth/2, z_offset = 0, animdata = { bank = "ant_cave_door", build = "ant_cave_door", anim = "south"},
                my_door_id = door_from.my_door_id, target_door_id = door_from.target_door_id, target_interior = door_from.target_interior, rotation = -90, angle=0, addtags = { "door_south" }
            })
        else
            local door_to_exterior =
            {
                my_door_id = "ANTQUEEN_CHAMBERS_EXIT",
                target_door_id = "ANTQUEEN_CHAMBERS_ENTRANCE",
                target_interior = queenchamber_placement_id,
            }

            table.insert(addprops,
            {
                name = "prop_door", x_offset = depth/2, z_offset = 0, animdata = { minimapicon = "ant_cave_door.png", bank = "ant_cave_door", build = "ant_cave_door", anim = "south"},
                my_door_id = door_to_exterior.my_door_id, target_door_id = door_to_exterior.target_door_id, target_interior = door_to_exterior.target_interior, rotation = -90, angle=0, addtags = { "door_south" }
            })
        end

        if i ~= room_count then
            interior_spawner:CreateRoom("generic_interior", TUNING.ROOM_LARGE_WIDTH, 7, TUNING.ROOM_LARGE_DEPTH, "QUEEN_CHAMBERS_DUNGEON", queen_chamber_ids[i], addprops, {}, walltexture, floortexture, minimaptexture, nil, "images/colour_cubes/pigshop_interior_cc.tex", nil, nil, "anthill","ANT_HIVE","DIRT")
        else
            interior_spawner:CreateRoom("generic_interior", TUNING.ROOM_LARGE_WIDTH, 7, TUNING.ROOM_LARGE_DEPTH, "QUEEN_CHAMBERS_DUNGEON", final_chamber_id, addprops, {}, walltexture, floortexture, minimaptexture, nil, "images/colour_cubes/pigshop_interior_cc.tex", nil, nil, "anthill","ANT_HIVE","DIRT", -3.5, 40)            
        end
    end
end

local function setDoorHiddenStatus(objectInInterior, show)
    if show then
        objectInInterior.components.door:sethidden(false)
    else
        objectInInterior.components.door:sethidden(true)
    end
end

local function setCurrentDoorHiddenStatus(objectInInterior, show, direction)
    if not objectInInterior.sg then
        print("MISSING sg FOR DIRECTION ("..direction..") AND PREFAB ("..objectInInterior.prefab..")")
    end

    if show and objectInInterior.components.door.hidden then
        objectInInterior.sg:GoToState("open_"..direction)
    elseif not show and not objectInInterior.components.door.hidden then
        objectInInterior.sg:GoToState("shut_"..direction)
    end
end

local function printDoorStatus(objectInInterior, tagName, doorEnabled)
    local tagMsg = ""
    local entMsg = ""
    local doorEnabledMsg = ""

    if doorEnabled then doorEnabledMsg = "true" else doorEnabledMsg = "false" end
    if objectInInterior.components.door.hidden then tagMsg = "disabled" else tagMsg = "enabled" end
    if objectInInterior.entity:IsVisible() then entMsg = "visible" else entMsg = "invisible" end
    print("DOOR_STATUS: "..tagName.. " (tag = "..tagMsg.. ") (ent = "..entMsg..") (room.doorEnabled = "..doorEnabledMsg..")")
end

local function refreshDoor(room, objectInInterior)    
    if objectInInterior.components.door then
        if objectInInterior:HasTag("door_north") then
            setDoorHiddenStatus(objectInInterior, room.doorsEnabled[NORTH_DOOR_IDX])
            -- printDoorStatus(objectInInterior, "door_north", room.doorsEnabled[NORTH_DOOR_IDX])
        elseif objectInInterior:HasTag("door_south") then
            setDoorHiddenStatus(objectInInterior, room.doorsEnabled[SOUTH_DOOR_IDX])
            -- printDoorStatus(objectInInterior, "door_south", room.doorsEnabled[SOUTH_DOOR_IDX])
        elseif objectInInterior:HasTag("door_east") then
            setDoorHiddenStatus(objectInInterior, room.doorsEnabled[EAST_DOOR_IDX])
            -- printDoorStatus(objectInInterior, "door_east", room.doorsEnabled[EAST_DOOR_IDX])
        elseif objectInInterior:HasTag("door_west") then
            setDoorHiddenStatus(objectInInterior, room.doorsEnabled[WEST_DOOR_IDX])
            -- printDoorStatus(objectInInterior, "door_west", room.doorsEnabled[WEST_DOOR_IDX])
        end
    end
end

local function refreshCurrentDoor(room, objectInInterior)
    if objectInInterior.components.door then
        if objectInInterior:HasTag("door_north") then
            print("ANTHILL DOOR: door_north "..objectInInterior.prefab)
            setCurrentDoorHiddenStatus(objectInInterior, room.doorsEnabled[NORTH_DOOR_IDX], "north")
            -- printDoorStatus(objectInInterior, "door_north", room.doorsEnabled[NORTH_DOOR_IDX])
        elseif objectInInterior:HasTag("door_south") then
            print("ANTHILL DOOR: door_south "..objectInInterior.prefab)
            setCurrentDoorHiddenStatus(objectInInterior, room.doorsEnabled[SOUTH_DOOR_IDX], "south")
            -- printDoorStatus(objectInInterior, "door_south", room.doorsEnabled[SOUTH_DOOR_IDX])
        elseif objectInInterior:HasTag("door_east") then
            print("ANTHILL DOOR: door_east "..objectInInterior.prefab)
            setCurrentDoorHiddenStatus(objectInInterior, room.doorsEnabled[EAST_DOOR_IDX], "east")
            -- printDoorStatus(objectInInterior, "door_east", room.doorsEnabled[EAST_DOOR_IDX])
        elseif objectInInterior:HasTag("door_west") then
            print("ANTHILL DOOR: door_west "..objectInInterior.prefab)
            setCurrentDoorHiddenStatus(objectInInterior, room.doorsEnabled[WEST_DOOR_IDX], "west")
            -- printDoorStatus(objectInInterior, "door_west", room.doorsEnabled[WEST_DOOR_IDX])
        end
    end
end

local function refreshFutureDoor(room, objectInInterior)
    if objectInInterior.addtags then
        local doorName = objectInInterior.addtags[2]
        local doorEnabled = true
        -- local doorMsg = ""

        if doorName == "door_north" then
            doorEnabled = room.doorsEnabled[NORTH_DOOR_IDX]
            objectInInterior.hidden = not doorEnabled
        elseif doorName == "door_south" then
            doorEnabled = room.doorsEnabled[SOUTH_DOOR_IDX]
            objectInInterior.hidden = not doorEnabled
        elseif doorName == "door_east" then
            doorEnabled = room.doorsEnabled[EAST_DOOR_IDX]
            objectInInterior.hidden = not doorEnabled
        elseif doorName == "door_west" then
            doorEnabled = room.doorsEnabled[WEST_DOOR_IDX]
            objectInInterior.hidden = not doorEnabled
        end
    end
end

local function refreshDoors(inst)
    local interior_spawner = GetWorld().components.interiorspawner
    for i = 1, #inst.rooms, 1 do
        for j = 1, #inst.rooms[i], 1 do
            local room = inst.rooms[i][j]

            local interior = interior_spawner:GetInteriorByName(room.idx)

            if interior == interior_spawner.current_interior then
                local pt = interior_spawner:getSpawnOrigin()    
                -- collect all the things in the "interior area" minus the interior_spawn_origin and the player
                local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 50, {"interior_door"}, {"INTERIOR_LIMBO"})
                for p, objectInInterior in ipairs(ents) do
                    refreshCurrentDoor(room, objectInInterior)
                end
            elseif interior.prefabs and (#interior.prefabs > 0) then
                for p, objectInInterior in ipairs(interior.prefabs) do
                    refreshFutureDoor(room, objectInInterior)
                end
            elseif interior.object_list and (#interior.object_list > 0) then
                for p, objectInInterior in ipairs(interior.object_list) do
                    refreshDoor(room, objectInInterior)
                end
            end
        end
    end
end

local function spawnDust(inst, dustCount)
    if dustCount > 0 then
        local interior_spawner = GetWorld().components.interiorspawner
        local current_interior = interior_spawner.current_interior

        local pt = interior_spawner:getSpawnOrigin()
        local fx = SpawnPrefab("int_ceiling_dust_fx")
        local VARIANCE = 8.0

        fx.Transform:SetPosition(pt.x + math.random(-VARIANCE, VARIANCE), 0.0, pt.z + math.random(-VARIANCE, VARIANCE))
        fx.Transform:SetScale(2.0, 2.0, 2.0)
        inst:DoTaskInTime(0.5, function() spawnDust(inst, dustCount - 1) end)
    else
        inst:DoTaskInTime(0.5, function() inst.SoundEmitter:KillSound("miniearthquake") end)
    end
end

local function earthquake(inst)
    local interior_spawner = GetWorld().components.interiorspawner
    local current_interior = interior_spawner.current_interior

    if current_interior and (current_interior.dungeon_name == ANTHILL_DUNGEON_NAME) then
        interior_spawner.interiorCamera:Shake("FULL", 5.0, 0.025, 0.8)
        inst.SoundEmitter:PlaySound("dontstarve/cave/earthquake", "miniearthquake")
        inst.SoundEmitter:SetParameter("miniearthquake", "intensity", 1)
        spawnDust(inst, 10)

        for i = 1, #inst.rooms, 1 do
            for j = 1, #inst.rooms[i], 1 do
                local room = inst.rooms[i][j]
                local interior = interior_spawner:GetInteriorByName(room.idx)
                interior.enigma = not (interior == current_interior or not interior.visited)
            end
        end
    end
end

local function debugPrintRooms(inst, printDoors)
    local interior_spawner = GetWorld().components.interiorspawner

    for i = 1, #inst.rooms, 1 do
        for j = 1, #inst.rooms[i], 1 do
            local room = inst.rooms[i][j]
            local interior = interior_spawner:GetInteriorByName(room.idx)
            local entranceMsg = ""

            if room.isEntrance then
                entranceMsg = " ENTRANCE"
            end

            print("ANTHILL: room "..room.idx.." row = "..i.." col = "..j..entranceMsg)

            if interior.enigma then
                print("ANTHILL: is enigma")
            else
                print("ANTHILL: is known")
            end

            if printDoors then
                for k = 1, #dirNames, 1 do
                    if room.doorsEnabled[k] then
                        print("ANTHILL: "..dirNames[k].." door enabled")
                    else
                        print("ANTHILL: "..dirNames[k].." door disabled")
                    end
                end
            end
        end
    end
end

local function debugPrintMaze(inst)
    local interior_spawner = GetWorld().components.interiorspawner
    for i = 1, #inst.rooms, 1 do
        for j = 1, #inst.rooms[i], 1 do
            local room = inst.rooms[i][j]
            local interior = interior_spawner:GetInteriorByName(room.idx)
            local entranceMsg = ""

            if room.isEntrance then
                entranceMsg = " ENTRANCE"
            end

            print("ANTHILL: DOORS IN "..room.idx.." ROW = "..i.." COL = "..j..entranceMsg)
            if interior.prefabs and (#interior.prefabs) then
                for p, objectInInterior in ipairs(interior.prefabs) do
                    if objectInInterior.addtags then
                        local hiddenMsg = ""

                        if prefab.hidden then
                            hiddenMsg = " hidden"
                        end

                        print("ANTHILL: "..objectInInterior.addtags[2]..hiddenMsg)
                    end
                end
            end
        end
    end
end

local function createMazeContent(inst)
    if not inst:HasTag("maze_generated") then
        local queen_chamber_count = math.random(3,6)
        GenerateQueenChamberIDS(inst, queen_chamber_count)
        buildGrid(inst)
        buildAllRooms(inst)
        CreateQueenChambers(inst, queen_chamber_count)
        buildWalls(inst)
        refreshDoors(inst)
        inst:AddTag("maze_generated")
    end
end

local function generateMaze(inst)
    rebuildGrid(inst)
    buildWalls(inst)
    refreshDoors(inst)
    earthquake(inst)
end

local function onfar(inst) 
end

local function getstatus(inst)
    if inst:HasTag("burnt") then
        return "BURNT"
    elseif inst.components.spawner and inst.components.spawner:IsOccupied() then
        if inst.lightson then
            return "FULL"
        else
            return "LIGHTSOUT"
        end
    end
end

local function onnear(inst) 
end

local function onwere(child)
    if child.parent and not child.parent:HasTag("burnt") then
        child.parent.SoundEmitter:KillSound("pigsound")
        child.parent.SoundEmitter:PlaySound("dontstarve/pig/werepig_in_hut", "pigsound")
    end
end

local function onnormal(child)
    if child.parent and not child.parent:HasTag("burnt") then
        child.parent.SoundEmitter:KillSound("pigsound")
        child.parent.SoundEmitter:PlaySound("dontstarve/pig/pig_in_hut", "pigsound")
    end
end

local function onoccupied(inst, child)
    if not inst:HasTag("burnt") then
    	inst.SoundEmitter:PlaySound("dontstarve/pig/pig_in_hut", "pigsound")
        inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")
    	
        if inst.doortask then
            inst.doortask:Cancel()
            inst.doortask = nil
        end
    	inst.doortask = inst:DoTaskInTime(1, function() if not inst.components.playerprox:IsPlayerClose() then LightsOn(inst) end end)
    end
end

local function onvacate(inst, child)
    if not inst:HasTag("burnt") then
        if inst.doortask then
            inst.doortask:Cancel()
            inst.doortask = nil
        end
        inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")
        inst.SoundEmitter:KillSound("pigsound")
    	
    	if child then
    		if child.components.health then
    		    child.components.health:SetPercent(1)
    		end
    	end    
    end
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle")
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or inst:HasTag("fire") then
        data.burnt = true
    end

    if inst:HasTag("maze_generated") then
        data.maze_generated = true
    end

    if inst.rooms then
        data.rooms = inst.rooms

        -- parentRoom and exits are not necessary to save and cause the
        -- game to crash upon saving, so they are stripped out here.
        for i = 1, #inst.rooms, 1 do
            for j = 1, #inst.rooms[i], 1 do
                data.rooms[i][j].parentRoom = nil
                data.rooms[i][j].exits = nil
            end
        end
    end
end

local function onload(inst, data)
    if data and data.burnt then
        inst.components.burnable.onburnt(inst)
    end

    if data and data.maze_generated then
        inst:AddTag("maze_generated")
    end

    if data and data.rooms then
        inst.rooms = data.rooms
    end
end

local function onloadpostpass(inst)
	-- band-aid fix for anthills that can apparently go awol until we find out why they go awol to begin with
	if inst.prefab == "anthill_exit" then
		-- make sure, if an anthill_exit exists that an anthill exists
		for i,v in pairs(Ents) do
			if v.prefab == "anthill" then
				return -- seems we're good to go
			end
		end		
		-- if we made it here, we don't have an anthill. That's not good
		print("** No anthill found....need to spawn one!")
		-- find a location to spawn it
		local replace_one
		local replacements = {}
		for i,v in pairs(Ents) do
			if v.prefab == "tree_pillar" then
				replacements[#replacements+1] = v
			end
		end		
		print(string.format("Have %d potential replacees",#replacements))
		assert(#replacements > 0, "Could not find a replacee for the anthill that went MIA")
		local toreplace = replacements[math.random(#replacements)]
		local pt = toreplace:GetPosition()
		local hill = SpawnPrefab("anthill")
		toreplace:Remove()
		hill.Transform:SetPosition(pt.x, pt.y, pt.z)
	end
end

local function fixupDoors(inst)
	refreshDoors(inst)
end

local function makefn(buildanthill)
    local function fn(Sim)
    	local inst = CreateEntity()
    	local trans = inst.entity:AddTransform()
    	local anim = inst.entity:AddAnimState()
        local light = inst.entity:AddLight()
        inst.entity:AddSoundEmitter()

    	local minimap = inst.entity:AddMiniMapEntity()
    	minimap:SetIcon("ant_hill_entrance.png")
    
        light:SetFalloff(1)
        light:SetIntensity(.5)
        light:SetRadius(1)
        light:Enable(false)
        light:SetColour(180/255, 195/255, 50/255)

        inst.Transform:SetScale(0.8, 0.8, 0.8)

        MakeObstaclePhysics(inst, 1.3)

        anim:SetBank("ant_hill_entrance")
        anim:SetBuild("ant_hill_entrance")
        anim:PlayAnimation("idle", true)

        inst:AddTag("structure")

        inst:AddTag("anthill_outside")

        inst:AddComponent("lootdropper")

        inst:AddComponent("childspawner")
        inst.components.childspawner.childname = "antman"
        inst.components.childspawner:SetRegenPeriod(TUNING.ANTMAN_REGEN_TIME)
        inst.components.childspawner:SetSpawnPeriod(TUNING.ANTMAN_RELEASE_TIME)
        inst.components.childspawner:SetMaxChildren(math.random(TUNING.ANTMAN_MIN, TUNING.ANTMAN_MAX))
        inst.components.childspawner:StartSpawning()

    	inst:AddComponent("playerprox")
        inst.components.playerprox:SetDist(10, 13)
        inst.components.playerprox:SetOnPlayerNear(onnear)
        inst.components.playerprox:SetOnPlayerFar(onfar)

        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = getstatus
        inst.components.inspectable.nameoverride = "anthill"

        inst.name = STRINGS.NAMES.ANTHILL

        inst:AddComponent("door")
        inst.components.door.outside = true

        if buildanthill then
            inst:DoTaskInTime(0, function() createMazeContent(inst) end)
            inst:DoPeriodicTask(TUNING.TOTAL_DAY_TIME / 3, function() generateMaze(inst) end)
	    inst.OnRemoveEntity = function()
					-- this is really bad but apparently can happen. But how....
					assert(false, "anthill got removed.  Please submit a bug report!")
				  end
        else
            inst:AddTag("ANTHILL_EXIT")
        end

        inst.generateMaze = generateMaze
        inst.debugPrintRooms = debugPrintRooms

    	MakeSnowCovered(inst, .01)

        inst.OnSave = onsave 
        inst.OnLoad = onload
        -- OnLoadPostPass to band-aid the potential disappearance to anthills
        inst.OnLoadPostPass = onloadpostpass

    	inst:ListenForEvent("onbuilt", onbuilt)

		-- alas, we were affected by a mirroring bug during beta, we need to expose this
		inst.FixupDoors = fixupDoors

        return inst
    end
    return fn
end

return Prefab("common/objects/anthill", makefn(true), assets, prefabs),
       Prefab("common/objects/anthill_exit", makefn(false), assets, prefabs)