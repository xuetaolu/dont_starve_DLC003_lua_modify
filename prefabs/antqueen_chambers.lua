require "prefabutil"
require "recipes"

local assets =
{
    Asset("SOUND", "sound/pig.fsb"),
	Asset("ANIM", "anim/ant_hill_entrance.zip"),
    Asset("MINIMAP_IMAGE", "ant_hill_entrance"), 
}

local prefabs =
{
	"antman",
    "int_ceiling_dust_fx",
    "antchest",
    "giantgrub",
    "ant_cave_lantern",
    "antqueen_chambers"
}

local function getlocationoutofcenter(dist, hole, random, invert)
    local pos =  (math.random() * ((dist / 2) - (hole / 2))) + hole / 2    
    if invert or (random and math.random() < 0.5) then
        pos = pos *-1
    end
    return pos
end

local function CreateRooms( inst, room_count )
    
    local interior_spawner = GetWorld().components.interiorspawner
    local width = 24
    local depth = 18

    local floortexture = "levels/textures/interiors/antcave_floor.tex"
    local walltexture = "levels/textures/interiors/antcave_wall_rock.tex"
    local minimaptexture = "levels/textures/map_interior/mini_antcave_floor.tex"
    local addprops = {}
    
    local ids = {}
    local interiors = {}

    local QUEEN_CHAMBERS = "QUEEN_CHAMBERS_"
    local FROM_STRING = "ANTQUEEN_CHAMBERS_FROM_"
    local TO_STRING = "ANTQUEEN_CHAMBERS_TO_"

    for i=1, room_count do
        local newid = interior_spawner:GetNewID()
        table.insert(ids, newid)
    end

    for i=1, room_count do
        local addprops = {}

        if i ~= 1 then
            local door_from =
            {
                my_door_id = FROM_STRING .. ids[i],
                target_door_id = TO_STRING .. ids[i],
                target_interior = ids[i-1],
            }

            table.insert( addprops,
            {
                name = "prop_door", x_offset = depth/2, z_offset = 0, animdata = { minimapicon = "pig_ruins_exit_int.png", bank = "ant_cave_door", build = "ant_cave_door", anim = "south", light = true },
                my_door_id = door_from.my_door_id, target_door_id = door_from.target_door_id, target_interior = door_from.target_interior, rotation = -90, angle=0, addtags = { "door_south" }
            })
        else
            local door_to_interior =
            {
                my_door_id = "ANTQUEEN_CHAMBERS_EXIT",
                target_door_id = "ANTQUEEN_CHAMBERS_ENTRANCE",
                target_interior = ids[1],
            }
            --interior_spawner:AddDoor(inst, door_to_interior)

            local door_to_exterior =
            {
                my_door_id = "ANTQUEEN_CHAMBERS_ENTRANCE",
                target_door_id = "ANTQUEEN_CHAMBERS_EXIT",
                target_interior = interior_spawner.source_interior_id,
            }

            table.insert(addprops,
            {
                name = "prop_door", x_offset = depth/2, z_offset = 0, animdata = { minimapicon = "pig_ruins_exit_int.png", bank = "ant_cave_door", build = "ant_cave_door", anim = "south", light = true },
                my_door_id = door_to_exterior.my_door_id, target_door_id = door_to_interior.target_door_id, target_interior = door_to_exterior.target_interior, rotation = -90, angle=0, addtags = { "door_south" }
            })
        end

        if i ~= room_count then
            local door_to =
            {
                my_door_id = TO_STRING .. ids[i+1],
                target_door_id = FROM_STRING .. ids[i+1],
                target_interior = ids[i+1],
            }

            table.insert (addprops,
            {
                name = "prop_door", x_offset = -depth/2, z_offset = 0, animdata = { minimapicon = "pig_ruins_exit_int.png", bank = "ant_cave_door", build = "ant_cave_door", anim = "day_loop", light = true },
                my_door_id = door_to.my_door_id, target_door_id = door_to.target_door_id, target_interior = door_to.target_interior, rotation = -90, angle=0, addtags = { "door_south" }
            })


            -- Adds random deco and props and whatnot (same as the anthill)
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

            local function spawnhoney() 
                local choice = math.random(1, 4)
                if choice == 1 then
                     table.insert(addprops, { name = "deco_cave_honey_drip_1", x_offset = -depth/2, z_offset = getlocationoutofcenter(width*0.65, 3, true), rotation =- 90 })
                elseif choice == 2 then
                     table.insert(addprops, { name = "deco_cave_ceiling_drip_2", x_offset = -depth/2, z_offset = getlocationoutofcenter(width*0.65, 3, true), rotation =- 90 })
                elseif choice == 3 then
                    if math.random() < 0.5 then
                        table.insert(addprops, { name = "deco_cave_honey_drip_side_1", x_offset = getlocationoutofcenter(depth*0.65, 3, true), z_offset = -width/2, rotation =- 90 })
                    else
                        table.insert(addprops, { name = "deco_cave_honey_drip_side_1", x_offset = getlocationoutofcenter(depth*0.65, 3, true), z_offset =  width/2, rotation =- 90, flip = true })
                    end
                elseif choice == 4 then
                    if math.random() < 0.5 then
                        table.insert(addprops, { name = "deco_cave_honey_drip_side_2", x_offset = getlocationoutofcenter(depth*0.65, 3, true), z_offset = -width/2, rotation =- 90 })
                    else
                        table.insert(addprops, { name = "deco_cave_honey_drip_side_2", x_offset = getlocationoutofcenter(depth*0.65, 3, true), z_offset = width/2, rotation =- 90, flip = true })
                    end
                end
            end

            local drips = math.random(1, 6) - 1
            while drips > 0 do
                spawnhoney() 
                drips = drips -1
            end

            for i=1,math.random(1, 5) do
                table.insert(addprops, {name = "antman_warrior", x_offset = getlocationoutofcenter(depth*0.65, 5, true), z_offset = getlocationoutofcenter(depth*0.65, 5, true)})
            end

        else
            table.insert (addprops, { name = "antqueen", x_offset = 0, z_offset = 0 })
            table.insert(addprops, { name = "ant_cave_lantern", x_offset = -depth/2, z_offset = 0 })

            table.insert(addprops, { name = "ant_cave_lantern", x_offset = -depth/2, z_offset = (depth/2) - 2 }) 
            table.insert(addprops, { name = "ant_cave_lantern", x_offset = -depth/2, z_offset = (-depth/2) + 2 }) 
            
            table.insert(addprops, { name = "ant_cave_lantern", x_offset = 0, z_offset = (depth/2) + 1 }) 
            table.insert(addprops, { name = "ant_cave_lantern", x_offset = 0, z_offset = (-depth/2) - 1 })
        end

        interior_spawner:CreateRoom("generic_interior", width, 7, depth, QUEEN_CHAMBERS .. ids[i], ids[i], addprops, {}, walltexture, floortexture, minimaptexture, nil, "images/colour_cubes/pigshop_interior_cc.tex", nil, nil, "anthill")
    end
end

local function createChamberContent(inst)
    if not inst:HasTag("maze_generated") then
        --createRoom(inst)
        local number_of_rooms = math.random(3, 6)
        CreateRooms(inst, number_of_rooms)
        inst:AddTag("maze_generated")
    end
end

local function onsave()
end

local function onload()
end

local function makefn(buildanthill)
    local function fn(Sim)
    	local inst = CreateEntity()
    	local trans = inst.entity:AddTransform()
    	local anim = inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()

        local minimap = inst.entity:AddMiniMapEntity()
        minimap:SetIcon("ant_hill_entrance.png")
        
        local light = inst.entity:AddLight()
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
        inst:AddComponent("lootdropper")

        inst.name = STRINGS.NAMES.ANTQUEEN_CHAMBERS

        inst:AddComponent("door")
        inst.components.door.outside = true

        if buildanthill then            
            inst:DoTaskInTime(0, function() createChamberContent(inst) end)
        end

        inst.OnSave = onsave 
        inst.OnLoad = onload

        local interior_spawner = GetWorld().components.interiorspawner
        inst.source_interior_id = interior_spawner:GetInteriorByName(interior_spawner.to_interior).unique_name

        return inst
    end
    return fn
end

return Prefab("common/objects/antqueen_chambers", makefn(true), assets, prefabs)