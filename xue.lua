require 'util'

-- xkill()
-- xday()
-- xreset()
-- xue()
-- xmaze()
-- xboons()
-- xtraps()
-- xpres()
-- xinterest()
-- xlayouts()
-- Save()
-- Load()

local layout_name = ""

local function GetKeyArrayFromDisc(dis)
    local res = {}
    if type(dis) ~= 'table' then return res end
    for k,v in pairs(dis) do
        table.insert(res, k)
    end
    return res
end

function xclear()
    xkill( 256 )
end

function xkill( range )
    range = range or 10
    local x,y,z = TheInput:GetWorldPosition():Get()
    for k,v in pairs( TheSim:FindEntities( x,y,z, range) ) do
        if v ~= GetPlayer() then
            if v.components.health then
                v.components.health:Kill()
            elseif v.Remove then
                v:Remove()
            end
            if v:HasTag('wall') then v:Remove() return end
        end
    end
end

function xday()
    GetClock():Reset()
end

local _g = {}

function xreset()
    _g = {}
end

function xue()
    loadfile('xue')()
end

function xmaze( )
    -- local maze_layouts = require 'map/maze_layouts'
    -- local name = GetRandomKey( maze_layouts.Layouts )
    local maze_layouts = require('map/maze_layouts')
    _g.xmaze = _g.xmaze or {}
    _g.xmaze.index = _g.xmaze.index and (_g.xmaze.index+1) or 1
    _g.xmaze.typeIndex = _g.xmaze.typeIndex or 1
    _g.xmaze.names = _g.xmaze.names or GetKeyArrayFromDisc( maze_layouts.Layouts )
    _g.xmaze.types = _g.xmaze.types or GetKeyArrayFromDisc( maze_layouts.AllLayouts )
    local name = _g.xmaze.names[_g.xmaze.index]
    local type = _g.xmaze.types[_g.xmaze.typeIndex]
    if not name then 
        _g.xmaze.index = 1 
        _g.xmaze.typeIndex = _g.xmaze.typeIndex+1
    end
    local name = _g.xmaze.names[_g.xmaze.index]
    local type = _g.xmaze.types[_g.xmaze.typeIndex]
    if not name or not type then return end
    -- SpawnLayoutAtPoint( _g.xmaze.names[_g.xmaze.index], nil, nil, 4.0,  )
    SpawnLayoutAtPoint( name, nil, nil, 4.0, {type} )

end

function xboons( )
    _g.boon = _g.boon or {}
    _g.boon.index = _g.boon.index and (_g.boon.index+1) or 1
    _g.boon.names = _g.boon.names or GetKeyArrayFromDisc( require('map/boons').Layouts )
    if not _g.boon.names[_g.boon.index] then return end
    SpawnLayoutAtPoint( _g.boon.names[_g.boon.index], nil, nil, 4.0 )
end

function xtraps( )
    _g.traps = _g.traps or {}
    _g.traps.index = _g.traps.index and (_g.traps.index+1) or 1
    _g.traps.names = _g.traps.names or GetKeyArrayFromDisc( require('map/traps').Layouts )
    if not _g.traps.names[_g.traps.index] then return end
    SpawnLayoutAtPoint( _g.traps.names[_g.traps.index], nil, nil, 4.0 )
end

function xpres()
    _g.xpres = _g.xpres or {}
    _g.xpres.index = _g.xpres.index and (_g.xpres.index+1) or 1
    _g.xpres.names = _g.xpres.names or GetKeyArrayFromDisc( require('map/protected_resources').Layouts )
    if not _g.xpres.names[_g.xpres.index] then return end
    SpawnLayoutAtPoint( _g.xpres.names[_g.xpres.index], nil, nil, 4.0 )
end

function xinterest()
    _g.xinterest = _g.xinterest or {}
    _g.xinterest.index = _g.xinterest.index and (_g.xinterest.index+1) or 1
    _g.xinterest.names = _g.xinterest.names or GetKeyArrayFromDisc( require('map/pointsofinterest').Layouts )
    if not _g.xinterest.names[_g.xinterest.index] then return end
    SpawnLayoutAtPoint( _g.xinterest.names[_g.xinterest.index], nil, nil, 4.0 )
end

function xlayouts()
    _g.xlayouts = _g.xlayouts or {}
    _g.xlayouts.index = _g.xlayouts.index and (_g.xlayouts.index+1) or 1
    _g.xlayouts.names = _g.xlayouts.names or GetKeyArrayFromDisc( require('map/layouts').Layouts )
    if not _g.xlayouts.names[_g.xlayouts.index] then return end
    SpawnLayoutAtPoint( _g.xlayouts.names[_g.xlayouts.index], nil, nil, 4.0 )
end


function SpawnLayoutAtPoint( name, _x, _z, _scale, choices )
    layout_name = name and name or layout_name
    print(name)
    require 'debugtools'
    local object_layout = require("map/object_layout")
    local InteriorSpawner = require "components/interiorspawner"
    local position      = {(TheInput:GetWorldPosition()):Get()}
    -- local position      = {GetPlayer().Transform:GetWorldPosition()}
    position = {position[1], position[3]}
    if _x and _z then position = {_x,_z} end
    local entities      = {}
    -- local map_width,map_height = WorldSim:GetWorldSize()
    local map_width,map_height = 256, 256
    local map_scale = 1
    map_width = map_width * map_scale
    map_height = map_height * map_scale
    local add_fn = {fn=function(prefab, points_x, points_y, current_pos_idx, entitiesOut, width, height, prefab_list, prefab_data, rand_offset) 
                WorldSim:ReserveTile(points_x[current_pos_idx], points_y[current_pos_idx])
                -- local x = (points_x[current_pos_idx] - width/2.0) * TILE_SCALE
                -- local y = (points_y[current_pos_idx] - height/2.0) * TILE_SCALE
                local name_scale_table = {
                    -- tallbird_rocks = 4.0,
                }

                local x = points_x[current_pos_idx]
                local y = points_y[current_pos_idx]
                x = x ~= 0 and math.floor(x*100)/100.0 or 0
                y = y ~= 0 and math.floor(y*100)/100.0 or 0


                if entitiesOut[prefab] == nil then entitiesOut[prefab] = {} end
                local save_data = {x=x, z=y}
                if prefab_data then
                    if prefab_data.data then if type(prefab_data.data) == "function" then save_data["data"] = prefab_data.data() else save_data["data"] = prefab_data.data end
                end
                    if prefab_data.id then save_data["id"] = prefab_data.id end
                    if prefab_data.scenario then save_data["scenario"] = prefab_data.scenario end
                end
                -- print( string.format('points_x_y: %s, %s', points_x[current_pos_idx], points_y[current_pos_idx]) )
                table.insert(entitiesOut[prefab], save_data)
                -- print( x,y )
            end,
            args={entitiesOut=entities, width=map_width, height=map_height, rand_offset = false, debug_prefab_list=nil}
        }
    -- object_layout.Place( position, layout_name, add_fn, nil)
    assert(layout_name and layout_name ~= "", "Must provide a valid layout name, got nothing.")
    local layout = object_layout.LayoutForDefinition(layout_name, choices)
    layout.scale = (layout.scale or 1.0) * (_scale or 1.0)
    local prefabs = object_layout.ConvertLayoutToEntitylist(layout)
    object_layout.ReserveAndPlaceLayout("POSITIONED", layout, prefabs, add_fn, position)
    -- dumptable(entities)
    -- local saveslot = SaveGameIndex:GetCurrentSaveSlot()
    -- local savedata = SaveGameIndex:GetSaveData(saveslot, SaveGameIndex:GetCurrentMode(saveslot))

    local newents = {}
    local replace = { 
                    farmplot = "slow_farmplot", farmplot2 = "fast_farmplot", 
                    farmplot3 = "fast_farmplot", sinkhole= "cave_entrance",
                    cave_stairs= "cave_entrance"
                }
    local deprecated = { turf_webbing = true }
    local shouldMoveInteriorSpawnOrigin = false

    local instList = {}

    for prefab, ents in pairs(entities) do
        local prefab = replace[prefab] or prefab
        if not deprecated[prefab] then
            for k,v in ipairs(ents) do
                v.prefab = v.prefab or prefab -- prefab field is stripped out when entities are saved in global entity collections, so put it back
                -- modify spawn location if this entity is in the misplaced spawn-origin location
                if shouldMoveInteriorSpawnOrigin then
                    -- this is remarkably horrific. See comment for InteriorSpawner.FixForSpawnOriginMigration
                    v.x, v.y, v.z = InteriorSpawner.FixForSpawnOriginMigration(v.x or 0, v.y or 0, v.z or 0,v.prefab)
                end
                local inst = SpawnSaveRecord(v, newents)
                -- print( inst.Transform:GetWorldPosition() )
                table.insert( instList, inst )
            end
        end
    end

    for _, ent in ipairs(instList) do
        if ent.components.scenariorunner then
            ent.components.scenariorunner:Run()
        end
    end

    -- print( string.format( 'position %s %s', unpack(position) ) )
end

c_enablecheats()

function Save()
    SaveGameIndex:SaveCurrent()
end

function Load()
    StartNextInstance({reset_action = RESET_ACTION.LOAD_SLOT, save_slot=SaveGameIndex:GetCurrentSaveSlot()})
end

-- for k,v in pairs(newents) do
--     v.entity:LoadPostPass(newents, v.data)
-- end
-- -- GetWorld():LoadPostPass(newents, savedata.map.persistdata)

-- if SaveGameIndex:GetCurrentMode() ~= "cave" then -- not SaveGameIndex:IsModeShipwrecked() and
--     local savegamepatcher = require("savegamepatcher")
--     savegamepatcher.AddMissingEntities(savedata.ents, newents)
-- end

-- for k,v in pairs(newents) do
--     if v.entity.components.floatable then 
--         v.entity.components.floatable:SetAnimationFromPosition()
--     end 
-- end

-- if SaveGameIndex:GetCurrentMode() ~= "cave" then -- not SaveGameIndex:IsModeShipwrecked() and
--     local savegamepatcher = require("savegamepatcher")
--     savegamepatcher.AddMissingEntities(savedata.ents, newents)
-- end


-- dumptable(newents)

            -- WorldSim:ReserveTile(points_x[current_pos_idx], points_y[current_pos_idx])
            -- local x = (points_x[current_pos_idx] - width/2.0)*TILE_SCALE
            -- local y = (points_y[current_pos_idx] - height/2.0)*TILE_SCALE
            -- x = math.floor(x*100)/100.0
            -- y = math.floor(y*100)/100.0
            -- if entitiesOut[prefab] == nil then
            --     entitiesOut[prefab] = {}
            -- end
            -- local save_data = {x=x, z=y}
            -- if prefab_data then
            --     if prefab_data.data then
            --         if type(prefab_data.data) == "function" then
            --             save_data["data"] = prefab_data.data()
            --         else
            --             save_data["data"] = prefab_data.data
            --         end
            --     end
            --     if prefab_data.id then
            --         save_data["id"] = prefab_data.id
            --     end
            --     if prefab_data.scenario then
            --         save_data["scenario"] = prefab_data.scenario
            --     end
            -- end
            -- table.insert(entitiesOut[prefab], save_data)


