require "constants"

local ADDITIONAL_TEXTURES =
{
	-- "levels/textures/fog_cloud.tex"
	"levels/textures/ds_fog1.tex",

	"levels/textures/water_fall_mangrove_opaque.tex",
	"levels/textures/interiors/harlequin_panel.tex",
	"levels/textures/interiors/ground_ruins_slab.tex",
	
	"levels/textures/interiors/shop_wall_woodwall.tex",
	"levels/textures/interiors/shop_wall_sunflower.tex",
	"levels/textures/interiors/shop_wall_floraltrim2.tex",
	"levels/textures/interiors/shop_wall_sunflower2.tex",
	"levels/textures/interiors/shop_wall_marble.tex",
	"levels/textures/interiors/shop_wall_tiles.tex",
	"levels/textures/interiors/shop_wall_checkered.tex",
	"levels/textures/interiors/shop_wall_checkered_metal.tex",
	"levels/textures/interiors/shop_wall_upholstered.tex",
	"levels/textures/interiors/shop_wall_moroc.tex",
	"levels/textures/interiors/shop_wall_circles.tex",
	"levels/textures/interiors/shop_wall_bricks.tex",

	"levels/textures/interiors/shop_floor_checker.tex",
	"levels/textures/interiors/shop_floor_checkered.tex",
	"levels/textures/interiors/shop_floor_marble.tex",
	"levels/textures/interiors/shop_floor_woodmetal.tex",
	"levels/textures/interiors/shop_floor_sheetmetal.tex",
	"levels/textures/interiors/shop_floor_herringbone.tex",
	"levels/textures/interiors/shop_floor_octagon.tex",
    "levels/textures/interiors/shop_floor_hexagon.tex",
	"levels/textures/interiors/shop_floor_woodpaneling2.tex",    

	"levels/textures/interiors/floor_gardenstone.tex", 
	"levels/textures/interiors/floor_geometrictiles.tex", 
	"levels/textures/interiors/floor_shag_carpet.tex", 
	"levels/textures/interiors/floor_transitional.tex", 
	"levels/textures/interiors/floor_woodpanels.tex", 

	"levels/textures/interiors/wall_peagawk.tex", 
	"levels/textures/interiors/wall_plain_DS.tex", 
	"levels/textures/interiors/wall_plain_RoG.tex", 
	"levels/textures/interiors/wall_rope.tex", 

	"levels/textures/interiors/pig_ruins_panel.tex",
	"levels/textures/interiors/pig_ruins_panel_blue.tex",	

	"levels/textures/interiors/batcave_floor.tex",
	"levels/textures/interiors/batcave_wall_rock.tex",

	"levels/textures/interiors/antcave_floor.tex",
	"levels/textures/interiors/antcave_wall_rock.tex",
	
	"levels/textures/interiors/wall_mayorsoffice_whispy.tex",
	"levels/textures/interiors/floor_cityhall.tex",

	"levels/textures/interiors/shop_floor_hoof_curvy.tex",
	"levels/textures/interiors/shop_wall_fullwall_moulding.tex",

	"levels/textures/interiors/wall_royal_high.tex",
	"levels/textures/interiors/floor_marble_royal.tex",

--	"levels/textures/map_interior/minimap_floor.tex",
	"levels/textures/map_interior/mini_ruins_slab.tex",
	"levels/textures/map_interior/mini_vamp_cave_noise.tex",
	"levels/textures/map_interior/mini_antcave_floor.tex",
	"levels/textures/map_interior/mini_floor_marble_royal.tex",

	"levels/textures/map_interior/exit.tex",
	"levels/textures/map_interior/frame.tex",
	"levels/textures/map_interior/passage.tex",
	"levels/textures/map_interior/passage_blocked.tex",
	"levels/textures/map_interior/passage_unknown.tex",


	"levels/textures/interiors/ground_ruins_slab_blue.tex",
	"levels/textures/interiors/shop_wall_fullwall_moulding.tex",
	"levels/textures/interiors/shop_floor_hoof_curvy.tex",	
}

local GROUND_PROPERTIES =
{
-- DIRT AND GRASS REVERSED
--	{ GROUND.MANGROVE,	{ name = "water_medium",	noise_texture = "levels/textures/Ground_water_mangrove.tex",	runsound="run_marsh",		walksound="walk_marsh",		snowsound="run_snow", mudsound = "run_mud"	} },

	{ GROUND.INTERIOR,		{ name = "blocky",	noise_texture = "levels/textures/interior.tex",			runsound="run_dirt",		walksound="walk_dirt",		snowsound="run_snow", mudsound = "run_mud"	} },

	{ GROUND.BEACH,		{ name = "beach",		noise_texture = "levels/textures/Ground_noise_sand.tex",			runsound="run_sand",		walksound="walk_sand",		snowsound="run_snow", mudsound = "run_mud"	} },
	{ GROUND.ROAD,		{ name = "cobblestone",		noise_texture = "images/square.tex",							runsound="run_dirt",		walksound="walk_dirt",		snowsound="run_ice", mudsound = "run_mud"		} },
	{ GROUND.MARSH,		{ name = "marsh",		noise_texture = "levels/textures/Ground_noise_marsh.tex",			runsound="run_marsh",		walksound="walk_marsh",		snowsound="run_ice", mudsound = "run_mud"		} },
	{ GROUND.ROCKY,		{ name = "rocky",		noise_texture = "levels/textures/noise_rocky.tex",					runsound="run_dirt",		walksound="walk_dirt",		snowsound="run_ice", mudsound = "run_mud"		} },
	{ GROUND.SAVANNA,	{ name = "yellowgrass",	noise_texture = "levels/textures/Ground_noise_grass_detail.tex",	runsound="run_tallgrass",	walksound="walk_tallgrass",	snowsound="run_snow", mudsound = "run_mud"	} },
	{ GROUND.FOREST,	{ name = "forest",		noise_texture = "levels/textures/Ground_noise.tex",					runsound="run_woods",		walksound="walk_woods",		snowsound="run_snow", mudsound = "run_mud"	} },
	{ GROUND.GRASS,		{ name = "grass",		noise_texture = "levels/textures/Ground_noise.tex",					runsound="run_grass",		walksound="walk_grass",		snowsound="run_snow", mudsound = "run_mud"	} },
	{ GROUND.DIRT,		{ name = "dirt",		noise_texture = "levels/textures/Ground_noise_dirt.tex",			runsound="run_dirt",		walksound="walk_dirt",		snowsound="run_snow", mudsound = "run_mud"	} },
	{ GROUND.DECIDUOUS,	{ name = "deciduous",	noise_texture = "levels/textures/Ground_noise_deciduous.tex",		runsound="run_carpet",		walksound="walk_carpet",	snowsound="run_snow", mudsound = "run_mud"	} },
	{ GROUND.DESERT_DIRT,{ name = "desert_dirt", noise_texture = "levels/textures/Ground_noise_dirt.tex",			runsound="run_dirt",		walksound="walk_dirt",		snowsound="run_snow", mudsound = "run_mud"	} },

	{ GROUND.VOLCANO_ROCK,{ name = "rocky",		noise_texture = "levels/textures/ground_volcano_noise.tex",			runsound="run_rock",		walksound="walk_rock",		snowsound="run_ice", mudsound = "run_mud"		} },
	{ GROUND.VOLCANO,	{ name = "cave",		noise_texture = "levels/textures/ground_lava_rock.tex",				runsound="run_rock",		walksound="walk_rock",		snowsound="run_ice", mudsound = "run_mud"		} },
	{ GROUND.ASH,		{ name = "cave",		noise_texture = "levels/textures/ground_ash.tex",					runsound="run_dirt",		walksound="walk_dirt",		snowsound="run_ice", mudsound = "run_mud"		} },

	{ GROUND.JUNGLE,	{ name = "jungle",		noise_texture = "levels/textures/Ground_noise_jungle.tex",			runsound="run_woods",		walksound="walk_woods",		snowsound="run_snow", mudsound = "run_mud"	} },
	{ GROUND.SWAMP,		{ name = "swamp",		noise_texture = "levels/textures/Ground_noise_swamp.tex",			runsound="run_marsh",		walksound="walk_marsh",		snowsound="run_snow", mudsound = "run_mud"	} },
	{ GROUND.MAGMAFIELD,{ name = "cave",		noise_texture = "levels/textures/Ground_noise_magmafield.tex",		runsound="run_dirt",		walksound="walk_dirt",		snowsound="run_ice", mudsound = "run_mud"		} },
	{ GROUND.TIDALMARSH,{ name = "tidalmarsh",	noise_texture = "levels/textures/Ground_noise_tidalmarsh.tex",		runsound="run_marsh",		walksound="walk_marsh",		snowsound="run_snow", mudsound = "run_mud"	} },
	{ GROUND.MEADOW,	{ name = "jungle",		noise_texture = "levels/textures/Ground_noise_savannah_detail.tex",	runsound="run_tallgrass",	walksound="walk_tallgrass",	snowsound="run_snow", mudsound = "run_mud"	} },

	{ GROUND.CAVE,		{ name = "cave",		noise_texture = "levels/textures/noise_cave.tex",					runsound="run_dirt",		walksound="walk_dirt",		snowsound="run_ice", mudsound = "run_mud"		} },
	{ GROUND.FUNGUS,	{ name = "cave",		noise_texture = "levels/textures/noise_fungus.tex",					runsound="run_moss",		walksound="walk_moss",		snowsound="run_ice", mudsound = "run_mud"		} },
	{ GROUND.FUNGUSRED,	{ name = "cave",		noise_texture = "levels/textures/noise_fungus_red.tex",				runsound="run_moss",		walksound="walk_moss",		snowsound="run_ice", mudsound = "run_mud"		} },
	{ GROUND.FUNGUSGREEN,{ name = "cave",		noise_texture = "levels/textures/noise_fungus_green.tex", 			runsound="run_moss",		walksound="walk_moss",		snowsound="run_ice", mudsound = "run_mud"		} },
	
	{ GROUND.SINKHOLE,	{ name = "cave",		noise_texture = "levels/textures/noise_sinkhole.tex",				runsound="run_dirt",		walksound="walk_dirt",		snowsound="run_snow", mudsound = "run_mud"	} },
	{ GROUND.UNDERROCK,	{ name = "cave",		noise_texture = "levels/textures/noise_rock.tex",					runsound="run_dirt",		walksound="walk_dirt",		snowsound="run_ice", mudsound = "run_mud"		} },
	{ GROUND.MUD,		{ name = "cave",		noise_texture = "levels/textures/noise_mud.tex",					runsound="run_mud",			walksound="walk_mud",		snowsound="run_snow", mudsound = "run_mud"	} },

	{ GROUND.PIGRUINS,		 		{ name = "blocky",			noise_texture = "levels/textures/interiors/ground_ruins_slab.tex",			runsound="run_dirt",		walksound="walk_dirt",		snowsound="run_ice", 	mudsound = "run_mud"	} },				
	{ GROUND.PIGRUINS_NOCANOPY,		{ name = "blocky",			noise_texture = "levels/textures/interiors/ground_ruins_slab.tex",			runsound="run_dirt",		walksound="walk_dirt",		snowsound="run_ice", 	mudsound = "run_mud"	} },					

	{ GROUND.DEEPRAINFOREST_NOCANOPY,{ name = "jungle_deep",	noise_texture = "levels/textures/Ground_noise_jungle_deep.tex",			runsound="run_woods",		walksound="walk_woods",		snowsound="run_snow", 	mudsound = "run_mud"	} },					
	
	{ GROUND.PAINTED,          { name = "swamp",		noise_texture = "levels/textures/Ground_bog.tex",				runsound="run_sand",		walksound="walk_sand",		snowsound="run_snow", 	mudsound = "run_sand"	} },			

	{ GROUND.PLAINS,        	{ name = "jungle",		noise_texture = "levels/textures/Ground_plains.tex",			runsound="run_tallgrass",		walksound="walk_tallgrass",		snowsound="run_snow", 	mudsound = "run_mud"	} },	

	{ GROUND.RAINFOREST,	{ name = "rain_forest",		noise_texture = "levels/textures/Ground_noise_rainforest.tex",		runsound="run_woods",		walksound="walk_woods",		snowsound="run_snow", 	mudsound = "run_mud"	} },		
	{ GROUND.DEEPRAINFOREST,{ name = "jungle_deep",		noise_texture = "levels/textures/Ground_noise_jungle_deep.tex",		runsound="run_woods",		walksound="walk_woods",		snowsound="run_snow", 	mudsound = "run_mud"	} },	
	
	{ GROUND.BATTLEGROUND,     { name = "jungle_deep",		noise_texture = "levels/textures/Ground_battlegrounds.tex",		runsound="run_woods",		walksound="walk_woods",		snowsound="run_snow", 	mudsound = "run_mud"	} },		

	{ GROUND.FIELDS,		{ name = "jungle",		noise_texture = "levels/textures/noise_farmland.tex",				runsound="run_woods",		walksound="walk_woods",		snowsound="run_snow", 	mudsound = "run_mud"	} },	
	{ GROUND.SUBURB,	    { name = "deciduous",		noise_texture = "levels/textures/noise_mossy_blossom.tex",			runsound="run_dirt",		walksound="walk_dirt",		snowsound="run_ice", 	mudsound = "run_mud"	} },
	{ GROUND.FOUNDATION,	{ name = "blocky",			noise_texture = "levels/textures/noise_ruinsbrick_scaled.tex",		runsound="run_slate",		walksound="walk_slate",		snowsound="run_ice", 	mudsound = "run_mud"	} },
	{ GROUND.LAWN,			{ name = "pebble",			noise_texture = "levels/textures/ground_noise_checkeredlawn.tex",	runsound="run_grass",		walksound="walk_grass",		snowsound="run_snow", 	mudsound = "run_mud"	} },		
	{ GROUND.COBBLEROAD,	{ name = "stoneroad",		noise_texture = "levels/textures/Ground_noise_cobbleroad.tex",		runsound="run_rock",		walksound="walk_rock",		snowsound="run_ice", 	mudsound = "run_mud"	} },	
	{ GROUND.GASJUNGLE,		{ name = "jungle_deep",		noise_texture = "levels/textures/ground_noise_gas.tex",				runsound="run_moss",		walksound="walk_moss",		snowsound="run_snow", 	mudsound = "run_mud"	} },	
	
	{ GROUND.BRICK_GLOW,{ name = "cave",		noise_texture = "levels/textures/noise_ruinsbrick.tex",				runsound="run_dirt",		walksound="walk_dirt",		snowsound="run_ice", mudsound = "run_mud"		} },
	{ GROUND.BRICK,		{ name = "cave",		noise_texture = "levels/textures/noise_ruinsbrickglow.tex",			runsound="run_moss",		walksound="walk_moss",		snowsound="run_ice", mudsound = "run_mud"		} },
	{ GROUND.TILES_GLOW,{ name = "cave",		noise_texture = "levels/textures/noise_ruinstile.tex",				runsound="run_dirt",		walksound="walk_dirt",		snowsound="run_snow", mudsound = "run_mud"	} },
	{ GROUND.TILES,		{ name = "cave",		noise_texture = "levels/textures/noise_ruinstileglow.tex",			runsound="run_dirt",		walksound="walk_dirt",		snowsound="run_ice", mudsound = "run_mud"		} },
	{ GROUND.TRIM_GLOW,	{ name = "cave",		noise_texture = "levels/textures/noise_ruinstrim.tex",				runsound="run_dirt",		walksound="walk_dirt",		snowsound="run_snow", mudsound = "run_mud"	} },
	{ GROUND.TRIM,		{ name = "cave",		noise_texture = "levels/textures/noise_ruinstrimglow.tex",			runsound="run_dirt",		walksound="walk_dirt",		snowsound="run_ice", mudsound = "run_mud"		} },
	{ GROUND.FLOOD,		{ name = "flood",		noise_texture = "levels/textures/Ground_noise_flood.tex",runsound="run_marsh",		walksound="walk_marsh",		snowsound="run_snow", mudsound = "run_mud"	} },

	{ GROUND.WOODFLOOR,	{ name = "blocky",		noise_texture = "levels/textures/noise_woodfloor.tex",				runsound="run_wood",		walksound="walk_wood",		snowsound="run_ice", mudsound = "run_mud"		} },
	{ GROUND.CHECKER,	{ name = "blocky",		noise_texture = "levels/textures/noise_checker.tex",				runsound="run_marble",		walksound="walk_marble",	snowsound="run_ice", mudsound = "run_mud"		} },
	{ GROUND.SNAKESKIN,	{ name = "carpet",		noise_texture = "levels/textures/noise_snakeskinfloor.tex",			runsound="run_carpet",		walksound="walk_carpet",	snowsound="run_snow", mudsound = "run_mud"		} },
	{ GROUND.CARPET,	{ name = "carpet",		noise_texture = "levels/textures/noise_carpet.tex",					runsound="run_carpet",		walksound="walk_carpet",	snowsound="run_snow", mudsound = "run_mud"	} },	
	
	{ GROUND.BEARDRUG,	{ name = "carpet",		noise_texture = "levels/textures/Ground_beard_hair.tex",					runsound="run_carpet",		walksound="walk_carpet",	snowsound="run_snow", mudsound = "run_mud"	} },		

	{ GROUND.LILYPOND,	{ name = "water_medium",	noise_texture = "levels/textures/Ground_lilypond2.tex",	runsound="run_marsh",		walksound="walk_marsh",		snowsound="run_snow", mudsound = "run_mud"	} },	
		
	{ GROUND.MANGROVE,	{ name = "water_medium",	noise_texture = "levels/textures/Ground_water_mangrove.tex",	runsound="run_marsh",		walksound="walk_marsh",		snowsound="run_snow", mudsound = "run_mud"	} },	
	
	{ GROUND.MANGROVE_SHORE,	{ name = "water_medium",	noise_texture = "levels/textures/Ground_water_mangrove.tex",	runsound="run_marsh",		walksound="walk_marsh",		snowsound="run_snow", mudsound = "run_mud"	} },
	{ GROUND.OCEAN_SHORE,	{ name = "water_medium",	noise_texture = "levels/textures/Ground_noise_water_shallow.tex",		runsound="run_marsh",		walksound="walk_marsh",		snowsound="run_snow", mudsound = "run_mud"	} },	
	{ GROUND.OCEAN_SHALLOW,	{ name = "water_medium",	noise_texture = "levels/textures/Ground_noise_water_shallow.tex",		runsound="run_marsh",		walksound="walk_marsh",		snowsound="run_snow", mudsound = "run_mud"	} },
	{ GROUND.OCEAN_CORAL,	{ name = "water_medium",	noise_texture = "levels/textures/Ground_water_coral.tex",		runsound="run_marsh",		walksound="walk_marsh",		snowsound="run_snow", mudsound = "run_mud"	} },
	{ GROUND.OCEAN_CORAL_SHORE,	{ name = "water_medium",	noise_texture = "levels/textures/Ground_water_coral.tex",		runsound="run_marsh",		walksound="walk_marsh",		snowsound="run_snow", mudsound = "run_mud"	} },
	{ GROUND.OCEAN_MEDIUM,	{ name = "water_medium",	noise_texture = "levels/textures/Ground_noise_water_medium.tex",	runsound="run_marsh",		walksound="walk_marsh",		snowsound="run_snow", mudsound = "run_mud"	} },
	{ GROUND.OCEAN_DEEP,	{ name = "water_medium",	noise_texture = "levels/textures/Ground_noise_water_deep.tex",		runsound="run_marsh",		walksound="walk_marsh",		snowsound="run_snow", mudsound = "run_mud"	} },
	{ GROUND.OCEAN_SHIPGRAVEYARD,{ name = "water_medium",	noise_texture = "levels/textures/Ground_water_graveyard.tex",		runsound="run_marsh",		walksound="walk_marsh",		snowsound="run_snow", mudsound = "run_mud"	} },
	
	-- USED FOR INTERIOR FLOORS
	{"WOOD",    { runsound="run_wood", 		walksound="walk_wood", 		snowsound="run_ice",  mudsound = "run_mud"} },
	{"STONE",   { runsound="run_dirt",		walksound="walk_dirt",		snowsound="run_ice",  mudsound = "run_mud"} },
	{"CARPET",  { runsound="run_carpet",	walksound="walk_carpet",	snowsound="run_snow", mudsound = "run_mud"} },	
	{"DIRT",    { runsound="run_dirt",		walksound="walk_dirt",		snowsound="run_snow", mudsound = "run_mud"} },	
}

local WALL_PROPERTIES =
{
	{ GROUND.UNDERGROUND,	{ name = "falloff", noise_texture = "images/square.tex" } },
	{ GROUND.WALL_MARSH,	{ name = "walls", 	noise_texture = "images/square.tex" } },--"levels/textures/wall_marsh_01.tex" } },
	{ GROUND.WALL_ROCKY,	{ name = "walls", 	noise_texture = "images/square.tex" } },--"levels/textures/wall_rock_01.tex" } },
	{ GROUND.WALL_DIRT,		{ name = "walls", 	noise_texture = "images/square.tex" } },--"levels/textures/wall_dirt_01.tex" } },

	{ GROUND.WALL_CAVE,		{ name = "walls",	noise_texture = "images/square.tex" } },--"levels/textures/wall_cave_01.tex" } },
	{ GROUND.WALL_FUNGUS,	{ name = "walls",	noise_texture = "images/square.tex" } },--"levels/textures/wall_fungus_01.tex" } },
	{ GROUND.WALL_SINKHOLE, { name = "walls",	noise_texture = "images/square.tex" } },--"levels/textures/wall_sinkhole_01.tex" } },
	{ GROUND.WALL_MUD,		{ name = "walls",	noise_texture = "images/square.tex" } },--"levels/textures/wall_mud_01.tex" } },
	{ GROUND.WALL_TOP,		{ name = "walls",	noise_texture = "images/square.tex" } },--"levels/textures/cave_topper.tex" } },
	{ GROUND.WALL_WOOD,		{ name = "walls",	noise_texture = "images/square.tex" } },--"levels/textures/cave_topper.tex" } },

	{ GROUND.WALL_HUNESTONE_GLOW,		{ name = "walls",	noise_texture = "images/square.tex" } },--"levels/textures/wall_cave_01.tex" } },
	{ GROUND.WALL_HUNESTONE,	{ name = "walls",	noise_texture = "images/square.tex" } },--"levels/textures/wall_fungus_01.tex" } },
	{ GROUND.WALL_STONEEYE_GLOW, { name = "walls",	noise_texture = "images/square.tex" } },--"levels/textures/wall_sinkhole_01.tex" } },
	{ GROUND.WALL_STONEEYE,		{ name = "walls",	noise_texture = "images/square.tex" } },--"levels/textures/wall_mud_01.tex" } },
}

local underground_layers =
{
	{ GROUND.UNDERGROUND, { name = "falloff", noise_texture = "images/square.tex" } },
}

local GROUND_CREEP_PROPERTIES =
{
	{ 1, { name = "web", noise_texture = "levels/textures/web_noise.tex" } },
}

local FLOODING_PROPERTIES =
{
	{ 2, { name = "flood", noise_texture = "levels/textures/Ground_noise_flood.tex" } },
	--{ 2, { name = "beach", noise_texture = "levels/textures/Ground_noise_sand.tex" } },
}

function GroundImage( name )
	return "levels/tiles/" .. name .. ".tex"
end

function GroundAtlas( name )
	return "levels/tiles/" .. name .. ".xml"
end

local function AddAssets( assets, layers )
	for i, data in ipairs( layers ) do
		local tile_type, properties = unpack( data )
		if properties.name and properties.noise_texture then
			table.insert( assets, Asset( "IMAGE", properties.noise_texture ) )
			table.insert( assets, Asset( "IMAGE", GroundImage( properties.name ) ) )
			table.insert( assets, Asset( "FILE", GroundAtlas( properties.name ) ) )
		end
	end
end

local assets = {}
AddAssets( assets, WALL_PROPERTIES )
AddAssets( assets, GROUND_PROPERTIES )
AddAssets( assets, underground_layers ) 
AddAssets( assets, GROUND_CREEP_PROPERTIES )


for i,v in ipairs(ADDITIONAL_TEXTURES) do
	table.insert( assets, Asset( "IMAGE", v ) )
end


function GetTileInfo( tile )
	for k, data in ipairs( GROUND_PROPERTIES ) do
		local tile_type, tile_info = unpack( data )
		if tile == tile_type then
			return tile_info
		end
	end
	return nil
end


local WEB_FOOTSTEP_SOUNDS =
{
	[CREATURE_SIZE.SMALL]	=	{ runsound = "run_web_small",		walksound = "walk_web_small" },
	[CREATURE_SIZE.MEDIUM]	=	{ runsound = "run_web",				walksound = "walk_web" },
	[CREATURE_SIZE.LARGE]	=	{ runsound = "run_web_large",		walksound = "walk_web_large" },
}


function PlayFootstep(inst, volume)
	volume = volume or 1
	
    local sound = inst.SoundEmitter
    if sound then
        local tile, tileinfo = inst:GetCurrentTileType()
        
        if tile and tileinfo then       	
			local x, y, z = inst.Transform:GetWorldPosition()
			local ontar = inst.slowing_objects and next(inst.slowing_objects)
			local oncreep = GetWorld().GroundCreep:OnCreep( x, y, z )
			local onflood = GetWorld().Flooding and GetWorld().Flooding:OnFlood( x, y, z )
			local onsnow = GetSeasonManager() and GetSeasonManager():GetSnowPercent() > 0.15
			local onmud = GetWorld().components.moisturemanager:GetWorldMoisture() > 15
			local ininterior = tile == GROUND.INTERIOR
			--this is only for playerd for the time being because isonroad is suuuuuuuper slow.
			local onroad = inst:HasTag("player") and RoadManager ~= nil and RoadManager:IsOnRoad( x, 0, z )
			if onroad then
				tile = GROUND.ROAD
				tileinfo = GetTileInfo( GROUND.ROAD )
			end

			local footstep_path = inst.footstep_path_override or "dontstarve/movement/"

			local creature_size = CREATURE_SIZE.MEDIUM
			local size_affix = ""
			if inst:HasTag("smallcreature") then
				creature_size = CREATURE_SIZE.SMALL
				size_affix = "_small"
			elseif inst:HasTag("largecreature") then
				creature_size = CREATURE_SIZE.LARGE
				size_affix = "_large"
			end
			
			if ininterior then
 				local interiorSpawner = GetWorld().components.interiorspawner
 				if interiorSpawner.current_interior then			
					tileinfo = GetTileInfo( interiorSpawner.current_interior.groundsound )
					if not tileinfo then						
						tileinfo = GetTileInfo( "DIRT" )						
					end
				end
			end

			if onsnow then
				sound:PlaySound(footstep_path .. tileinfo.snowsound .. size_affix, nil, volume)
			elseif onmud then
				sound:PlaySound(footstep_path .. tileinfo.mudsound .. size_affix, nil, volume)
			else
				if inst.sg and inst.sg:HasStateTag("running") then
					sound:PlaySound(footstep_path .. tileinfo.runsound .. size_affix, nil, volume)
				else
					sound:PlaySound(footstep_path .. tileinfo.walksound .. size_affix, nil, volume)
				end
			end

			if oncreep then
				sound:PlaySound(footstep_path .. WEB_FOOTSTEP_SOUNDS[ creature_size ].runsound, nil, volume)
			end
			if onflood then
				sound:PlaySound(footstep_path .. WEB_FOOTSTEP_SOUNDS[ creature_size ].runsound, nil, volume) --play this for now
			end

			if ontar then
				sound:PlaySound(footstep_path .. tileinfo.mudsound .. size_affix, nil, volume)
			end		
        end
    end
end

return 
{
	ground = GROUND_PROPERTIES,
	creep = GROUND_CREEP_PROPERTIES,
	flooding = FLOODING_PROPERTIES,
	wall = WALL_PROPERTIES,
	underground = underground_layers,
	assets = assets,
}
