
require "prefabutil"
require "maputil"

local StaticLayout = require("map/static_layout")

local entities = {} -- the list of entities that will fill the whole world. imported from  world gen (forest_map)
-- local world 

local WIDTH = 0
local HEIGHT = 0

local function setConstants(setentities, setwidth, setheight)
    entities = setentities

    WIDTH = setwidth
    HEIGHT = setheight
end

local function setEntity(prop, x, z)
    if entities[prop] == nil then
        entities[prop] = {}
    end

    local scenario = nil

    local save_data = {x= (x - WIDTH/2.0)*TILE_SCALE , z= (z - HEIGHT/2.0)*TILE_SCALE, scenario = scenario}
    table.insert(entities[prop], save_data)    
end


local function getdiv1tile(x,y,z)
    local fx,fy,fz = x,y,z

    fx = x - ( math.fmod(x,1) )
    fz = z - ( math.fmod(z,1) )

    return fx,fy,fz
end

function makeinteriorspawner(entities, topology_save, worldsim, map_width, map_height)

    setConstants(entities ,map_width, map_height)

    local interior_spawner_potential_coords = {}

    local potential_nodes = topology_save.GlobalTags["interior_potential"]

    if potential_nodes then

        for task, nodes in pairs(potential_nodes) do
            
            for i,node in ipairs(nodes)do                    
                
                local c_x, c_y = WorldSim:GetSiteCentroid(potential_nodes[task][i])            
                local x, y, z = getdiv1tile(c_x,0,c_y)
                local nodedata = {x=x, y=y, z=z}

                table.insert(interior_spawner_potential_coords,nodedata)             
            end
        end
    end
    
    local fx,fy,fz = 0,0,0

    for i, coords in ipairs(interior_spawner_potential_coords)do
        fx = fx + coords.x
        fy = fy + coords.y
        fz = fz + coords.z
    end

    fx = fx/#interior_spawner_potential_coords
    fy = fy/#interior_spawner_potential_coords
    fz = fz/#interior_spawner_potential_coords

    local choice = {x=fx, y=fy, z=fz} -- interior_spawner_potential_coords[math.random(#interior_spawner_potential_coords)]

    setEntity("interior_spawn_origin", choice.x, choice.z)

    return entities
end


	   


