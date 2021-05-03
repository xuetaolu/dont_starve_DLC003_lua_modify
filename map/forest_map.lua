
local SKIP_GEN_CHECKS = false

local function tree()
    return "evergreen"--trees[math.random(#trees)]
end

require "map/terrain"
require "map/water"
require "map/treasurehunt"
require "map/city_builder"
--require "map/interior_spawn_locator"
require "map/bunch_spawner"
require "map/border_finder"
require "map/bramble_spawner"


local function pickspawnprefab(items_in, ground_type)
--	if ground_type == GROUND.ROAD then
--		return
--	end
	local items = {}
	if ground_type ~= nil then		
		-- Filter the items
	    for item,v in pairs(items_in) do
	    	items[item] = items_in[item]
	        if terrain.filter[item]~= nil then
--	        	if ground_type == GROUND.ROAD then
--	        		print ("Filter", item, terrain.filter.Print(terrain.filter[item]), GROUND_NAMES[ground_type])
--	        	end
	        	
	            for idx,gt in ipairs(terrain.filter[item]) do
        			if gt == ground_type then
        				items[item] = nil
        				--print ("Filtered", item, GROUND_NAMES[ground_type], " (".. terrain.filter.Print(terrain.filter[item])..")")
        			end
   				end        
	        end 
	    end
	end
    local total = 0
    for k,v in pairs(items) do
        total = total + v
    end
    if total > 0 then
        local rnd = math.random()*total
        for k,v in pairs(items) do
            rnd = rnd - v
            if rnd <= 0 then
                return k
            end
        end
    end
end

local function pickspawngroup(groups)
    for k,v in pairs(groups) do
        if math.random() < v.percent then
            return v
        end
    end
end

local MULTIPLY = {
		["never"] = 0,
		["rare"] = 0.5,
		["default"] = 1,
		["often"] = 1.5,
		["mostly"] = 1.67, -- Not sure this is getting used...?
		["always"] = 2,		
	}

local level_type = ""
if rawget(_G, "GEN_PARAMETERS") ~= nil then
	local params = json.decode(GEN_PARAMETERS)
	level_type = params.level_type
end

local merm = { "mermhouse" }
local trees = {"evergreen", "evergreen_sparse", "deciduoustree", "marsh_tree"}
local rocks = {"rocks", "rock1", "rock2", "rock_flintless"}
local grass = {"grass","grass_tall","grass_tall_patch"}

if level_type == "shipwrecked" or level_type == "volcano" then
	merm = {"mermhouse_fisher"}
	trees = {"jungletree", "palmtree", "mangrovetree"}
	rocks = {"rocks", "rock1", "rock2", "rock_flintless", "magmarock", "magmarock_gold"}
	grass = {"grass", "grass_water"}
end

local TRANSLATE_TO_PREFABS = {		
		["spiders"] = 			{"spiderden"},
		["tentacles"] = 		{"tentacle"},
		["tallbirds"] = 		{"tallbirdnest"},
		["pigs"] = 				{"pighouse"},
		["ballphins"] = 		{"ballphin", "ballphinhouse"},
		["rabbits"] = 			{"rabbithole"},
		["moles"] =				{"molehill"},
		["beefalo"] = 			{"beefalo"},
		["ponds"] = 			{"pond", "pond_mos"},
		["bees"] = 				{"beehive", "bee"},
		["grass"] = 			grass,
		["rock"] = 				rocks, 
		["rock_ice"] = 			{"rock_ice"}, 
		["sapling"] = 			{"sapling"},
		["reeds"] = 			{"reeds"},	
		["trees"] = 			trees,
		["evergreen"] = 		{"evergreen"},	
		["carrot"] = 			{"carrot_planted"},
		["berrybush"] = 		{"berrybush", "berrybush2", "berrybush2_snake"},
		["maxwelllight"] = 		{"maxwelllight"},
		["maxwelllight_area"] = {"maxwelllight_area"},
		["fireflies"] = 		{"fireflies"},
		["cave_entrance"] = 	{"cave_entrance"},
		["tumbleweed"] = 		{"tumbleweedspawner"},
		["cactus"] = 			{"cactus"},
		["lightninggoat"] = 	{"lightninggoat"},
		["catcoon"] = 			{"catcoonden"},
		["merm"] = 				merm,
		["buzzard"] = 			{"buzzardspawner"},
		["mushroom"] =			{"red_mushroom", "green_mushroom", "blue_mushroom"},
		["marshbush"] = 		{"marsh_bush"},
		["flint"] = 			{"flint"},
		["mandrake"] = 			{"mandrake"},
		["angrybees"] = 		{"wasphive", "killerbee"},
		["houndmound"] = 		{"houndmound"},
		["chess"] = 			{"knight", "bishop", "rook"},
		["walrus"] = 			{"walrus_camp"},

		["crabhole"] =			{"crabhole"},
		["ox"] =				{"ox"},
		["solofish"] =			{"solofish"},
		["jellyfish"] =			{"jellyfish_planted", "jellyfish_spawner"},
		["fishinhole"] =		{"fishinhole"},
		["seashell"] =			{"seashell_beached"},
		["seaweed"] =			{"seaweed_planted"},
		["obsidian"] =			{"obsidian"},
		["limpets"] =			{"limpetrock"},
		["coral"] =				{"coralreef"},
		["coral_brain_rock"] =	{"coral_brain_rock"},
		--["bermudatriangle"] =	{"bermudatriangle_MARKER"},
		["flup"] =				{"flup", "flupspawner", "flupspawner_sparse", "flupspawner_dense"},
		["sweet_potato"] =		{"sweet_potato_planted"},
		["wildbores"] =			{"wildborehouse"},
		["bush_vine"] =			{"bush_vine", "snakeden"},
		["bamboo"] =			{"bamboo", "bambootree"},
		["crate"] =				{"crate"},
		["tidalpool"] =			{"tidalpool"},
		["sandhill"] =			{"sandhill"},
		["poisonhole"] =		{"poisonhole"},
		["mussel_farm"] =		{"mussel_farm"},
		["doydoy"] =			{"doydoy", "doydoybaby"},
		["lobster"] =			{"lobster", "lobsterhole"},
		["primeape"] =			{"primeape", "primeapebarrel"},
		["bioluminescence"] =	{"bioluminescence", "bioluminescence_spawner"},
		["ballphin"] =			{"ballphin", "ballphin_spawner"},
		["swordfish"] =			{"swordfish", "swordfish_spawner"},
		["stungray"] =			{"stungray", "stungray_spawner"},

		["asparagus"] = 		{"asparagus_planted"},
		["aloe"] = 				{"aloe_planted"},
		["clawpalmtree"] =		{"clawpalmtree", "clawpalmtree_normal", "clawpalmtree_tall", "clawpalmtree_short"},
		["rainforesttree"] =	{"rainforesttree", "rainforestree_normal", "rainforesttree_tall", "rainforesttree_short","rainforesttree_rot","rainforestree_rot_normal","rainforesttree_rot_tall","rainforesttree_rot_short"},
		["tubertree"] =			{"tubertree", "tubertree_tall", "tubertree_short"},		
		["teatree"] =           {"teatree","teatree_normal","teatree_tall","teatree_short","teatree_piko_nest"},
		["grass_bunches"] = 	{"grass_tall_patch_rate"},
		["rock_flippable"] = 	{"rock_flippable"},		
		["dungpile"] = 			{"dungpile"},	
		["gnatmound"] =			{"gnatmound"},	
		["lilypad"] = 			{"lilypad"},
		["lotus"] = 			{"lotus"},
		["nettle"] = 			{"nettle"},
		["hippopotamoose"] =	{"hippopotamoose"},
		["pog"] =				{"pog"},
		["pangolden"] = 		{"pangolden"},
		["mean_flytrap"] =		{"mean_flytrap"},
		["adult_flytrap"] =		{"adult_flytrap"},		
		["peagawk"] = 			{"peagawk"},
		["thunderbird"] = 		{"thunderbirdnest"},
		["hanging_vine"] = 		{"hanging_vine","hanging_vine_patch"},
		["grabbing_vine"] = 	{"grabbing_vine"},
		["lost_relics"] = 		{"relic_1","relic_2","relic_3"},
		["ruined_sculptures"] = {"randomdust","pig_ruins_pig","pig_ruins_ant","randomruin","pig_ruins_plaque","pig_ruins_idol"},
		["dungbeetle"] = 		{"dungbeetle"},
		["scorpion"] = 			{"scorpion"},	
		["snake"] = 			{"snake","snake_poison","snake_fire","snake_amphibious"},		
		["bat"] = 				{"bat"},
		["mandrakeman"] = 		{"mandrakeman","mandrakehouse"},		
		["ant_cave_lantern"] =  {"ant_cave_lantern"},
		["antcombhome"] = 		{"antcombhome"},
		["pig_guard_tower"] = 	{"pig_guard_tower"},
		["pighouse_city"] = 	{"pighouse_city","pighouse_farm","pighouse_mine"},
		["pig_ruins_entrance_small"] = {"pig_ruins_entrance_small"},
		["rusted_hulks"] =		{"ancient_robot_ribs","ancient_robot_leg","ancient_robot_claw","ancient_robot_head"},		
		["pugalisk_fountain"] =	{"pugalisk_fountain","pugalisk_trap_door"},		
	}

local TRANSLATE_AND_OVERRIDE = { --These are entities that should be translated to prefabs for world gen but also have a postinit override to do
		["flowers"] =			{"flower", "flower_evil"},
		
		["volcano"]=			{"volcano"},
		["seagull"] =			{"seagullspawner"},

		["piko"] = 				{"piko","piko_orange"},
		["jungle_border_vine"] ={"jungle_border_vine"},
		["flowers_rainforest"] ={"flower_rainforest"},	
		["deep_jungle_fern_noise"] = {"deep_jungle_fern_noise","deep_jungle_fern_noise_plant"},	
		["vampirebat"] = 		{"vampirebat","circlingbat"},
		["vampirebatcave"] = 	{"vampirebatcave"},
		["weevole"] = 			{"weevole"},	
		["gnat"] = 				{"gnat"},			
		["bill"] = 				{"bill"},		
		["mosquito"] = 			{"mosquito"},		
		["frog_poison"] = 		{"frog_poison"},
		["pig_ruins_torch"] = 	{"pig_ruins_torch"},
		["antman"] = 			{"antman"},	
		["pigbandit"] = 		{"pigbandit"},		
		["city_lamp"] = 		{"city_lamp"},			
		["spear_traps"] = 		{"spear_traps"},
		["dart_traps"] = 		{"dart_traps"},			
		["door_vines"] = 		{"door_vines"},		
		["giantgrub"] = 		{"giantgrub"},
		["roc"] = 				{"roc"},
		["pugalisk"] = 			{"pugalisk"},
		["antqueen"] = 			{"antqueen"},
		["hayfever"] = 			{"hayfever"},				
	}


local customise = require("map/customise_pork")
local function TranslateWorldGenChoices(world_gen_choices)
	if world_gen_choices == nil or GetTableSize(world_gen_choices["tweak"]) == 0 then
		return nil, nil
	end
	
	local translated = {}
	local runtime_overrides = {}
	
	for group, items in pairs(world_gen_choices["tweak"]) do
		for selected, v in pairs(items) do
			if v ~= "default" then
				if TRANSLATE_AND_OVERRIDE[selected] ~= nil then --Override and Translate
					--print("Worldgen Choice, Translate and Override", selected, v)
					local area = customise.GetGroupForItem(selected) --Override
					if runtime_overrides[area] == nil then
						runtime_overrides[area] = {}
					end
					table.insert(runtime_overrides[area], {selected, v})

					for i,prefab in ipairs(TRANSLATE_AND_OVERRIDE[selected]) do --Translate
						translated[prefab] = MULTIPLY[v]
					end	
				elseif TRANSLATE_TO_PREFABS[selected] == nil then --Override only
					--print("Worldgen Choice, Override only", selected, v)
					local area = customise.GetGroupForItem(selected)
					if runtime_overrides[area] == nil then
						runtime_overrides[area] = {}
					end
					table.insert(runtime_overrides[area], {selected, v})
				else --Translate only, selected, v)
					for i,prefab in ipairs(TRANSLATE_TO_PREFABS[selected]) do
						translated[prefab] = MULTIPLY[v]
					end	
				end	
			end	
		end
	end
	
	if GetTableSize(translated) == 0 then
		translated = nil
	end

	if GetTableSize(runtime_overrides) == 0 then
		runtime_overrides = nil
	end

	return translated, runtime_overrides
end
	
local function UpdatePercentage(distributeprefabs, world_gen_choices)
	for selected, v in pairs(world_gen_choices) do
		if v ~= "default" then		
			for i, prefab in ipairs(TRANSLATE_TO_PREFABS[selected]) do
				if distributeprefabs[prefab] ~= nil then
					distributeprefabs[prefab] = distributeprefabs[prefab] * MULTIPLY[v]
				end
			end
		end
	end
end
	
local function UpdateTerrainValues(world_gen_choices)
	if world_gen_choices == nil or GetTableSize(world_gen_choices) == 0 then
		return
	end
	
	for name,val in pairs(terrain.rooms) do
		if val.contents.distributeprefabs ~= nil then
			UpdatePercentage(val.contents.distributeprefabs, world_gen_choices)
		end
	end
end

local function GenerateVoro(prefab, map_width, map_height, tasks, world_gen_choices, level_type, level)
	local start_time = GetTimeReal()

    local SpawnFunctions = {
        pickspawnprefab = pickspawnprefab, 
        pickspawngroup = pickspawngroup, 
    }

    local check_col = {}
    
	require "map/storygen"	
	
  	local current_gen_params = deepcopy(world_gen_choices)
	
	local start_node_override = nil
	local islandpercent = nil
	local story_gen_params = {}

  	local defalt_impassible_tile = GROUND.IMPASSABLE
  	if prefab == "cave" then
  		defalt_impassible_tile =  GROUND.WALL_ROCKY
  	elseif prefab == "shipwrecked" then
  		defalt_impassible_tile = GROUND.IMPASSABLE
	elseif prefab == "porkland" then
		WorldSim:AddIslandRegionMapping("Edge_of_the_unknown", 			"A")
		WorldSim:AddIslandRegionMapping("painted_sands", 				"A")
		WorldSim:AddIslandRegionMapping("plains", 						"A")
		WorldSim:AddIslandRegionMapping("rainforests", 					"A")
		WorldSim:AddIslandRegionMapping("rainforest_ruins", 			"A")
		WorldSim:AddIslandRegionMapping("plains_ruins", 				"A")  
		WorldSim:AddIslandRegionMapping("Edge_of_civilization", 		"A")  
		WorldSim:AddIslandRegionMapping("Deep_rainforest", 				"A")
		WorldSim:AddIslandRegionMapping("Pigtopia", 					"A")
		WorldSim:AddIslandRegionMapping("Pigtopia_capital", 			"A")
		WorldSim:AddIslandRegionMapping("Deep_lost_ruins_gas", 			"A")		
		WorldSim:AddIslandRegionMapping("Edge_of_the_unknown_2", 		"A")
		WorldSim:AddIslandRegionMapping("Lilypond_land", 				"A")				
		WorldSim:AddIslandRegionMapping("Lilypond_land_2", 				"A")	
		WorldSim:AddIslandRegionMapping("this_is_how_you_get_ants", 	"A")
		WorldSim:AddIslandRegionMapping("Deep_rainforest_2", 			"A")
		WorldSim:AddIslandRegionMapping("Lost_Ruins_1", 				"A")
		WorldSim:AddIslandRegionMapping("Lost_Ruins_4", 				"A")		

		WorldSim:AddIslandRegionMapping("Deep_rainforest_3", 			"B")		
		WorldSim:AddIslandRegionMapping("Deep_rainforest_mandrake", 	"B")			
		WorldSim:AddIslandRegionMapping("Path_to_the_others", 			"B")
		WorldSim:AddIslandRegionMapping("Other_edge_of_civilization", 	"B")
		WorldSim:AddIslandRegionMapping("Other_pigtopia", 				"B")
		WorldSim:AddIslandRegionMapping("Other_pigtopia_capital", 		"B")

		WorldSim:AddIslandRegionMapping("Deep_lost_ruins4", 			"C")		
		WorldSim:AddIslandRegionMapping("lost_rainforest", 				"C")		

		WorldSim:AddIslandRegionMapping("pincale", 						"E")

		WorldSim:AddIslandRegionMapping("Deep_wild_ruins4", 			"F")
		WorldSim:AddIslandRegionMapping("wild_rainforest", 			    "F")
		WorldSim:AddIslandRegionMapping("wild_ancient_ruins", 			"F")
		
		
		
  	end

  	story_gen_params.impassible_value = defalt_impassible_tile
	story_gen_params.level_type = level_type
	
	if current_gen_params["tweak"] ~=nil and current_gen_params["tweak"]["misc"] ~= nil then
		if  current_gen_params["tweak"]["misc"]["start_setpeice"] ~= nil then
			story_gen_params.start_setpeice = current_gen_params["tweak"]["misc"]["start_setpeice"]
			current_gen_params["tweak"]["misc"]["start_setpeice"] = nil
		end

		if  current_gen_params["tweak"]["misc"]["start_node"] ~= nil then
			story_gen_params.start_node = current_gen_params["tweak"]["misc"]["start_node"]
			current_gen_params["tweak"]["misc"]["start_node"] = nil
		end

		if  current_gen_params["tweak"]["misc"]["start_task"] ~= nil then
			story_gen_params.start_task = current_gen_params["tweak"]["misc"]["start_task"]
			current_gen_params["tweak"]["misc"]["start_task"] = nil
		end
		
		if  current_gen_params["tweak"]["misc"]["islands"] ~= nil then
			local percent = {always=1, never=0,default=0.2, sometimes=0.1, often=0.8}
			story_gen_params.island_percent = percent[current_gen_params["tweak"]["misc"]["islands"]]
			current_gen_params["tweak"]["misc"]["islands"] = nil
		end

		if  current_gen_params["tweak"]["misc"]["branching"] ~= nil then
			story_gen_params.branching = current_gen_params["tweak"]["misc"]["branching"]
			current_gen_params["tweak"]["misc"]["branching"] = nil
		end


		if  current_gen_params["tweak"]["misc"]["world_size"] ~= nil then
			story_gen_params.world_size = current_gen_params["tweak"]["misc"]["world_size"]
			current_gen_params["tweak"]["misc"]["branching"] = nil
		end


		if  current_gen_params["tweak"]["misc"]["loop"] ~= nil then
			local loop_percent = { never=0, default=nil, always=1.0 }
			local loop_target = { never="any", default=nil, always="end"}
			story_gen_params.loop_percent = loop_percent[current_gen_params["tweak"]["misc"]["loop"]]
			story_gen_params.loop_target = loop_target[current_gen_params["tweak"]["misc"]["loop"]]
			current_gen_params["tweak"]["misc"]["loop"] = nil
		end
	end

    print("Creating story...")
	local topology_save

	if prefab == "shipwrecked" then
		topology_save = SHIPWRECKED_STORY(tasks, story_gen_params, level)
	elseif prefab == "volcanolevel" then
		topology_save = VOLCANO_STORY(tasks, story_gen_params, level)
	elseif prefab == "porkland" then
		topology_save = PORKLAND_STORY(tasks, story_gen_params, level)	
	else
		topology_save = DEFAULT_STORY(tasks, story_gen_params, level)
	end

	local entities = {}
 
    local save = {}
    save.ents = {}
    

    --save out the map
    save.map = {
        revealed = "",
        tiles = "",
    }
    
    save.map.prefab = prefab  
   
	local min_size = 350
	local max_size = 750
	if current_gen_params["tweak"] ~= nil and current_gen_params["tweak"]["misc"] ~= nil and current_gen_params["tweak"]["misc"]["world_size"] ~= nil then
		local min_sizes ={
			["mini"] = 75,
			["tiny"] = 150,
			["small"] = 250,
			["default"] = 350,
			["medium"] = 400,
			["large"] = 425,
			["huge"] = 450,
			}
		local max_sizes ={
			["mini"] = 475,
			["tiny"] = 550,
			["small"] = 650,
			["default"] = 750,
			["medium"] = 800,
			["large"] = 825,
			["huge"] = 850,
			}

		local world_size = current_gen_params["tweak"]["misc"]["world_size"]
		min_size = min_sizes[world_size]
		max_size = max_sizes[world_size]
		--print("New size:", min_size, current_gen_params["tweak"]["misc"]["world_size"])
		current_gen_params["tweak"]["misc"]["world_size"] = nil
	end
		
	map_width = min_size
	map_height = min_size
    
    WorldSim:SetWorldSize( map_width, map_height)

    local map_padding = 20
    if prefab == "shipwrecked" then
    	map_padding = TUNING.MAPEDGE_PADDING
    end
    
    print("Baking map...",min_size,max_size,map_padding)
    	
  	if WorldSim:GenerateVoronoiMap(math.random(), 0, map_padding) == false then--math.random(0,100)) -- AM: Dont use the tend
  		return nil
  	end

	topology_save.root:ApplyPoisonTag()
  		
  	if prefab == "cave" then
	  	local nodes = topology_save.root:GetNodes(true)
	  	for k,node in pairs(nodes) do
	  		-- BLAH HACK
	  		if node.data ~= nil and 
	  			node.data.type ~= nil and 
	  			string.find(k, "Room") ~= nil then

	  			WorldSim:SetNodeType(k, NODE_TYPE.Room)
	  		end
	  	end
  	end
  	WorldSim:SetImpassibleTileType(defalt_impassible_tile)
  	
	--WorldSim:ConvertToTileMap(min_size, 500)
	WorldSim:ConvertToTileMap(min_size, max_size)

	--WorldSim:SeparateIslands()
    print("Map Baked!")
	map_width, map_height = WorldSim:GetWorldSize()
	
	local join_islands = prefab ~= "shipwrecked" and string.upper(level_type) ~= "ADVENTURE" and prefab ~= "porkland"
	local ground_fill = GROUND.DIRT
	if prefab == "shipwrecked" then
		ground_fill = GROUND.BEACH
	elseif prefab == "volcanolevel" then
		ground_fill = GROUND.VOLCANO
	end

	WorldSim:ForceConnectivity(join_islands, prefab == "cave", ground_fill)
    
    if prefab ~= "shipwrecked" and  prefab ~= "porkland" then
		topology_save.root:SwapWormholesAndRoadsExtra(entities, map_width, map_height)
		if topology_save.root.error == true and prefab ~= "shipwrecked" then
		    print ("ERROR: Node ", topology_save.root.error_string)
		    if SKIP_GEN_CHECKS == false then
		    	return nil
		    end
		end
	end
	
	if (world_gen_choices["tweak"] == nil or world_gen_choices["tweak"]["misc"] == nil or world_gen_choices["tweak"]["misc"]["roads"] == nil) or world_gen_choices["tweak"]["misc"]["roads"] ~= "never" then
	--if prefab ~= "cave" then
	    WorldSim:SetRoadParameters(
			ROAD_PARAMETERS.NUM_SUBDIVISIONS_PER_SEGMENT,
			ROAD_PARAMETERS.MIN_WIDTH, ROAD_PARAMETERS.MAX_WIDTH,
			ROAD_PARAMETERS.MIN_EDGE_WIDTH, ROAD_PARAMETERS.MAX_EDGE_WIDTH,
			ROAD_PARAMETERS.WIDTH_JITTER_SCALE )
		
		WorldSim:DrawRoads(join_islands) 
	end
		
	-- Run Node specific functions here
	local gen_params, ro = TranslateWorldGenChoices(current_gen_params) --not ideal
	local nodes = topology_save.root:GetNodes(true)
	for k,node in pairs(nodes) do
		node:SetTilesViaFunction(entities, map_width, map_height, SpawnFunctions, gen_params)
	end

	WorldSim:DeleteSpecifiedTiles()

    print("Encoding...")
    
    save.map.topology = {}
    topology_save.root:SaveEncode({width=map_width, height=map_height}, save.map.topology)
    print("Encoding... DONE")

    -- TODO: Double check that each of the rooms has enough space (minimimum # tiles generated) - maybe countprefabs + %
    -- For each item in the topology list
    -- Get number of tiles for that node
    -- if any are less than minumum - restart the generation

    -- Big hacky thing here with the area < 4 which used to be area < 8

    for idx,val in ipairs(save.map.topology.nodes) do
		if string.find(save.map.topology.ids[idx], "LOOP_BLANK_SUB") == nil  then    
 	    	local area = WorldSim:GetSiteArea(save.map.topology.ids[idx])
	    	if area < 8 then
	    		print ("ERROR: Site "..save.map.topology.ids[idx].." area < 8: "..area)
	    		if SKIP_GEN_CHECKS == false then
	    			return nil
	    		end
	   		end
	   	end
	end

	if current_gen_params["tweak"] ~= nil and current_gen_params["tweak"]["misc"] ~= nil then
		if save.map.persistdata == nil then
			save.map.persistdata = {}
		end
		
		local day = current_gen_params["tweak"]["misc"]["day"]
		if day ~= nil then
			save.map.persistdata.clock = {}
		end
		
		if day == "onlynight" then
			save.map.persistdata.clock.phase="night"
		end
		if day == "onlydusk" then
			save.map.persistdata.clock.phase="dusk"
		end
	


		local season = current_gen_params["tweak"]["misc"]["season_start"]

		if season ~= nil then
			if save.map.persistdata.seasonmanager == nil then
				save.map.persistdata.seasonmanager = {}
			end

			if prefab == "porkland" then
				if season == "random" then
					local rand = math.random(1,3)
					if rand == 1 then
						season = "humid"
					elseif rand == 2 then
						season = "lush"
					else
						season = "temperate"
					end					
				end
			elseif prefab == "shipwrecked" then
				if season == "random" then
					local rand = math.random(1,4)
					if rand == 1 then
						season = "dry"
					elseif rand == 2 then
						season = "wet"
					elseif rand == 3 then
						season = "green"
					else
						season = "mild"
					end
				end
			else
				if season == "random" then
					local rand = math.random(1,4)
					if rand == 1 then
						season = "summer"
					elseif rand == 2 then
						season = "winter"
					elseif rand == 3 then
						season = "autumn"
					else
						season = "spring"
					end
				end
			end

			save.map.persistdata.seasonmanager.current_season = season
			if season == "winter" then
				save.map.persistdata.seasonmanager.ground_snow_level = 1
				save.map.persistdata.seasonmanager.percent_season = .2 --.5
			elseif season == "summer" then
				save.map.persistdata.seasonmanager.percent_season = .2 --.5
			end
			
			current_gen_params["tweak"]["misc"]["season_start"] = nil		
		end
	end
	
	local runtime_overrides = nil

    current_gen_params, runtime_overrides = TranslateWorldGenChoices(current_gen_params)

    print("Checking Tags")
	local obj_layout = require("map/object_layout")
		
	local add_fn = {fn=function(prefab, points_x, points_y, current_pos_idx, entitiesOut, width, height, prefab_list, prefab_data, rand_offset) 
				WorldSim:ReserveTile(points_x[current_pos_idx], points_y[current_pos_idx])
		
				local x = (points_x[current_pos_idx] - width/2.0)*TILE_SCALE
				local y = (points_y[current_pos_idx] - height/2.0)*TILE_SCALE
				x = math.floor(x*100)/100.0
				y = math.floor(y*100)/100.0
				if entitiesOut[prefab] == nil then
					entitiesOut[prefab] = {}
				end
				local save_data = {x=x, z=y}
				if prefab_data then
					
					if prefab_data.data then
						if type(prefab_data.data) == "function" then
							save_data["data"] = prefab_data.data()
						else
							save_data["data"] = prefab_data.data
						end
					end
					if prefab_data.id then
						save_data["id"] = prefab_data.id
					end
					if prefab_data.scenario then
						save_data["scenario"] = prefab_data.scenario
					end
				end
				table.insert(entitiesOut[prefab], save_data)
			end,
			args={entitiesOut=entities, width=map_width, height=map_height, rand_offset = false, debug_prefab_list=nil}
		}

   	if topology_save.GlobalTags["Labyrinth"] ~= nil and GetTableSize(topology_save.GlobalTags["Labyrinth"]) >0 then
   		for task, nodes in pairs(topology_save.GlobalTags["Labyrinth"]) do

	   		local val = math.floor(math.random()*10.0-2.5)
	   		local mazetype = MAZE_TYPE.MAZE_GROWINGTREE_4WAY

	   		local xs, ys, types = WorldSim:RunMaze(mazetype, val, nodes)
	   		-- TODO: place items of interest in these locations
			if xs ~= nil and #xs >0 then
				for idx = 1,#xs do
			   		if types[idx] == 0 then	
			   			--Spawning chests within the labyrinth.
						local prefab = "pandoraschest"
						local x = (xs[idx]+1.5 - map_width/2.0)*TILE_SCALE
						local y = (ys[idx]+1.5 - map_height/2.0)*TILE_SCALE
						WorldSim:ReserveTile(xs[idx], ys[idx])
						--print(task.." Labryth Point of Interest:",xs[idx], ys[idx], x, y)

						if entities[prefab] == nil then
							entities[prefab] = {}
						end
						local save_data = {x=x, z=y, scenario = "chest_labyrinth"}
						table.insert(entities[prefab], save_data)
					end
				end
			end
	   		for i,node in ipairs(topology_save.GlobalTags["LabyrinthEntrance"][task]) do 
		   		local entrance_node = topology_save.root:GetNodeById(node)

		   		for id, edge in pairs(entrance_node.edges) do
					WorldSim:DrawCellLine( edge.node1.id, edge.node2.id, NODE_INTERNAL_CONNECTION_TYPE.EdgeSite, GROUND.BRICK)
		   		end
	   		end
	   	end
   	end

   	if topology_save.GlobalTags["Maze"] ~= nil and GetTableSize(topology_save.GlobalTags["Maze"]) >0 then

   		for task, nodes in pairs(topology_save.GlobalTags["Maze"]) do
	 		local xs, ys, types = WorldSim:GetPointsForMetaMaze(nodes)
			
			if xs ~= nil and #xs >0 then
				local closest = Vector3(9999999999, 9999999999, 0)
				local task_node = topology_save.root:GetNodeById(task)
				local choices = task_node.maze_tiles
				local c_x, c_y = WorldSim:GetSiteCentroid(topology_save.GlobalTags["MazeEntrance"][task][1])
				local centroid = Vector3(c_x, c_y, 0)
				for idx = 1,#xs do
					local current = Vector3(xs[idx], ys[idx], 0)

					local diff = centroid - current
					local best = centroid - closest

					if diff:Length() < best:Length() then
						closest = current
					end 

					if types[idx] > 0 then			
						obj_layout.Place({xs[idx], ys[idx]}, MAZE_CELL_EXITS_INV[types[idx]], add_fn, choices.rooms)
					elseif types[idx] < 0 then
						--print(task.." Maze Room of Interest:",xs[idx], ys[idx])
						obj_layout.Place({xs[idx], ys[idx]}, MAZE_CELL_EXITS_INV[-types[idx]], add_fn, choices.bosses)
					else
						print("ERROR Type:",types[idx], MAZE_CELL_EXITS_INV[types[idx]])
					end
				end
				obj_layout.Place({closest.x, closest.y}, "FOUR_WAY", add_fn, choices.rooms)

		   		for i,node in ipairs(topology_save.GlobalTags["MazeEntrance"][task]) do 
			   		local entrance_node = topology_save.root:GetNodeById(node)
			   		for id, edge in pairs(entrance_node.edges) do
						WorldSim:DrawCellLine( edge.node1.id, edge.node2.id, NODE_INTERNAL_CONNECTION_TYPE.EdgeSite, GROUND.BRICK)
			   		end
		   		end
			end
		end
   	end

	if prefab == "shipwrecked" then
		if level.water_prefill_setpieces then
			PlaceWaterSetPieces(level.water_prefill_setpieces, add_fn, function(ground) return ground == GROUND.IMPASSABLE end)
		end
		if level.water_open_setpieces then
			FillOpenWater(level.water_open_setpieces, entities, map_width, map_height)
		end
		ConvertImpassibleToWater(map_width, map_height, require("map/watergen"))
		local required_treasure_placed = WorldGenPlaceTreasures(topology_save.root:GetChildren(), entities, map_width, map_height, 4600000, level)
		if not required_treasure_placed then
			print("PANIC: Missing required treasure!")
			if SKIP_GEN_CHECKS == false then
				return nil
			end
		end
	end

    print("Populating voronoi...")

	topology_save.root:GlobalPrePopulate(entities, map_width, map_height)
    topology_save.root:ConvertGround(SpawnFunctions, entities, map_width, map_height)

	-- Caves can be easily disconnected
 	if prefab == "cave" then
	   	local replace_count = WorldSim:DetectDisconnect()
	    if replace_count >1000 then
	    	print("PANIC: Too many disconnected tiles...",replace_count)
	    	
	    	-- This assert doesn't exist in RoG/Vanilla and it seems to be breaking cave generation
	    	--assert(false, "PANIC: Too many disconnected tiles..."..tostring(replace_count))
	    	
	    	if SKIP_GEN_CHECKS == false then
	    		return nil
	    	end
	    else
	    	print("disconnected tiles...",replace_count)
	    end
	end

   	topology_save.root:PopulateVoronoi(SpawnFunctions, entities, map_width, map_height, current_gen_params, prefab)
	if prefab == "shipwrecked" then
		RemoveSingleWaterTile(map_width, map_height)
		AddShoreline(map_width, map_height)
		PopulateWater(SpawnFunctions, entities, map_width, map_height, topology_save.water, current_gen_params)
	end
	topology_save.root:GlobalPostPopulate(entities, map_width, map_height)

	for k,ents in pairs(entities) do
		for i=#ents, 1, -1 do
			local x = ents[i].x/TILE_SCALE + map_width/2.0 
			local y = ents[i].z/TILE_SCALE + map_height/2.0 

			local tiletype = WorldSim:GetVisualTileAtPosition(x,y)
			local ground_OK = tiletype > GROUND.IMPASSABLE and tiletype < GROUND.UNDERGROUND
			if ground_OK == false then
				table.remove(entities[k], i)
			end
		end
	end

	if prefab == "porkland" then

		-- place jungle border?
		local jungle_border_rate = 1
		if current_gen_params and current_gen_params["jungle_border_vine"] then
			jungle_border_rate = current_gen_params["jungle_border_vine"]
		end
		if jungle_border_rate > 0 then
			makeborder(entities, topology_save, WorldSim, map_width, map_height, "jungle_border_vine", {GROUND.DEEPRAINFOREST,GROUND.GASJUNGLE,GROUND.PIGRUINS}, 0.40* jungle_border_rate)
		end

		--make the city here.
		print("*******************************")		
		print("")		
		print("     BUILDING PIG CULTURE")
		print("")
		print("*******************************")	

		entities = makecities(entities,topology_save, WorldSim, map_width, map_height, current_gen_params)
		
		--Process tallgrass, jungle fernnoise and other prefabs that spawn groups.
		if entities["grass_tall_patch"] then
			for i= #entities["grass_tall_patch"], 1, -1 do
				local ent = entities["grass_tall_patch"][i]
				local grass_tall_patch = 1
				if current_gen_params and current_gen_params["grass_tall_patch_rate"] then
					grass_tall_patch = current_gen_params["grass_tall_patch_rate"]
				end

				local chance = 0.20
				if grass_tall_patch == 0 then
					chance = 0
				elseif grass_tall_patch == 0.5 then
					chance = 0.10
				elseif grass_tall_patch == 1.5 then
					chance = 0.40
				elseif grass_tall_patch == 2 then
					chance = 0.60
				end
				print("MAKE BUNCH?", chance)
				if math.random()< chance then
					print("MAKE BUNCH!!!!!!")
					print("")
					makebunch(entities, topology_save, WorldSim, map_width, map_height, "grass_tall", 12, math.random(50,200),ent.x,ent.z,{GROUND.PLAINS,GROUND.DEEPRAINFOREST,GROUND.RAINFOREST})
				else
					table.remove( entities["grass_tall_patch"], i)
				end
			end							
		end

		if entities["deep_jungle_fern_noise"] then
			for i,ent in ipairs(entities["deep_jungle_fern_noise"]) do
				makebunch(entities, topology_save, WorldSim, map_width, map_height, "deep_jungle_fern_noise_plant", 12, math.random(5,15),ent.x,ent.z, {GROUND.DEEPRAINFOREST})
			end									
		end	

		if entities["teatree_piko_nest_patch"] then
			for i,ent in ipairs(entities["teatree_piko_nest_patch"]) do
				makebunch(entities, topology_save, WorldSim, map_width, map_height, "teatree_piko_nest", 18, math.random(4,8),ent.x,ent.z)
			end									
		end			

		if entities["asparagus_patch"] then
			for i,ent in ipairs(entities["asparagus_patch"]) do
				makebunch(entities, topology_save, WorldSim, map_width, map_height, "asparagus_planted", 2, math.random(2,6),ent.x,ent.z,{GROUND.PLAINS,GROUND.DEEPRAINFOREST,GROUND.RAINFOREST})
			end									
			entities["asparagus_patch"] = nil
		end

		-- filter small ruins doors
		if entities["pig_ruins_entrance_small"] then
			print("FOUND",#entities["pig_ruins_entrance_small"], "RUIN SITES")
			local newents = deepcopy(entities["pig_ruins_entrance_small"])
			entities["pig_ruins_entrance_small"] = {}			
			local num = RUINS.SMALL 

			-- I didn't want to use the same multiply system, so I'm translating it here.
			if current_gen_params and current_gen_params["pig_ruins_entrance_small"] then
				if current_gen_params["pig_ruins_entrance_small"] == 0 then
					num = 0
				elseif current_gen_params["pig_ruins_entrance_small"] == 2 then
					num = num * 3
				elseif current_gen_params["pig_ruins_entrance_small"] == 1.5 then
					num = num * 2
				elseif current_gen_params["pig_ruins_entrance_small"] == 0.5 then
					num = math.ceil(num/2)
				end
			end

			for i=1, num do
				if #newents>0 then
					local rand = math.random(1,#newents)
					local entry = newents[rand]
					table.remove(newents,rand)
					print("INSERTING RUIN")
					table.insert(entities["pig_ruins_entrance_small"],entry)
				end
			end
		end

		-- turn potential bat caves into real bat caves.
		if entities["vampirebatcave_potential"] then
			local ents = entities["vampirebatcave_potential"]

			entities["vampirebatcave"] = {}	
			local num = BATS.CAVE_NUM

			-- I didn't want to use the same multiply system, so I'm translating it here.
			if current_gen_params and current_gen_params["vampirebatcave"] then
				if current_gen_params["vampirebatcave"] == 0 then
					num = 0
				elseif current_gen_params["vampirebatcave"] == 2 then
					num = num * 3
				elseif current_gen_params["vampirebatcave"] == 1.5 then
					num = num * 2
				elseif current_gen_params["vampirebatcave"] == 0.5 then
					num = math.ceil(num/2)
				end
			end

			for i=1, num do 
				if #ents > 0 then						
					local rand =  math.random(1, #ents)
					local save_data = { x=ents[rand].x, z=ents[rand].z }					
	    			table.insert(entities["vampirebatcave"], save_data)  
	    			table.remove(ents,rand)
    			end
			end
			entities["vampirebatcave_potential"] = nil
		end

		
		if not entities["relic_1"] then
			entities["relic_1"] = {}
		end
		if not entities["relic_2"] then
			entities["relic_2"] = {}
		end
		if not entities["relic_3"] then
			entities["relic_3"] = {}
		end

		if not entities["pig_ruins_ant"] then
			entities["pig_ruins_ant"] = {}
		end
		if not entities["pig_ruins_pig"] then
			entities["pig_ruins_pig"] = {}
		end
		if not entities["pig_ruins_idol"] then
			entities["pig_ruins_idol"] = {}
		end
		if not entities["pig_ruins_plaque"] then
			entities["pig_ruins_plaque"] = {}
		end

		if entities["randomrelic"] then
			for i,ent in ipairs(entities["randomrelic"]) do
				local relic = "relic_" .. tostring(math.random(1,3))
				--print("ADDING RELIC",relic)
				local save_data = { x=ent.x, z=ent.z }
				table.insert(entities[relic],save_data)
			end	
			entities["randomrelic"] = nil		
		end

		if entities["randomruin"] then
			for i,ent in ipairs(entities["randomruin"]) do
				local save_data = { x=ent.x, z=ent.z }
				if math.random(1,2) == 1 then
					table.insert(entities["pig_ruins_idol"],save_data)
				else
					table.insert(entities["pig_ruins_plaque"],save_data)
				end				
			end	
			entities["randomruin"] = nil		
		end

		if entities["randomdust"] then
			for i,ent in ipairs(entities["randomdust"]) do
				local save_data = { x=ent.x, z=ent.z }
				if math.random(1,2) == 1 then
					table.insert(entities["pig_ruins_pig"],save_data)
				else
					table.insert(entities["pig_ruins_ant"],save_data)
				end				
			end	
			entities["randomdust"] = nil		
		end
		--entities = makeinteriorspawner(entities,topology_save, WorldSim, map_width, map_height)		

		if entities["pig_scepter"] then			
			while #entities["pig_scepter"] > 1 do
				table.remove(entities["pig_scepter"],math.random(1,#entities["pig_scepter"]))
			end			
		end

		entities = makeBrambleSites(entities,topology_save, WorldSim, map_width, map_height)
	end	   	
   	
    save.map.tiles, save.map.nav, save.map.adj = WorldSim:GetEncodedMap(join_islands)

   	local double_check = level.required_prefabs or {}
   	
	for i,k in ipairs(double_check) do
		if entities[k] == nil then
			print("PANIC: missing required prefab! ",k)
			--assert(false, "PANIC: missing a required prefab ["..tostring(k).."] double check that it's in a required room.")
			if SKIP_GEN_CHECKS == false then
				return nil
			end
		end			
	end

	if level.required_prefab_count then
		for k,n in pairs(level.required_prefab_count) do
			if entities[k] == nil or #entities[k] < n then
				print("PANIC: missing required prefab count!", k, n)
				if SKIP_GEN_CHECKS == false then
					return nil
				end
			end
		end
	end
   	
   	save.map.topology.overrides = runtime_overrides
	if save.map.topology.overrides == nil then
		save.map.topology.overrides = {}
	end
   	save.map.topology.overrides.original = world_gen_choices
   	
   	if current_gen_params ~= nil then
	   	-- Filter out any etities over our overrides
		for prefab,amt in pairs(current_gen_params) do
			if amt < 1 and entities[prefab] ~= nil and #entities[prefab] > 0 then
				local new_amt = math.floor(#entities[prefab]*amt)
				if new_amt == 0 then
					entities[prefab] = nil
				else
					entities[prefab] = shuffleArray(entities[prefab])
					while #entities[prefab] > new_amt do
						table.remove(entities[prefab], 1)
					end
				end
			end
		end	
	end

    save.ents = entities
    
    -- TODO: Double check that the entities are all existing in the world
    -- For each item in each room of the room list
	--
    
    save.map.width, save.map.height = map_width, map_height

    save.playerinfo = {}
	if save.ents.spawnpoint == nil or #save.ents.spawnpoint == 0 then
    	print("PANIC: No start location!")
    	--assert(false, "PANIC: No start location!")
    	if SKIP_GEN_CHECKS == false then
    		return nil
    	else
    		save.ents.spawnpoint={{x=0,y=0,z=0}}
    	end
    end
    
   	save.playerinfo.x = save.ents.spawnpoint[1].x
    save.playerinfo.z = save.ents.spawnpoint[1].z
    save.playerinfo.y = 0
    
    save.ents.spawnpoint = nil

    save.playerinfo.day = 0
    save.map.roads = {}
    if prefab == "forest" then	   	

	    local current_pos_idx = 1
	    if (world_gen_choices["tweak"] == nil or world_gen_choices["tweak"]["misc"] == nil or world_gen_choices["tweak"]["misc"]["roads"] == nil) or world_gen_choices["tweak"]["misc"]["roads"] ~= "never" then
		    local num_roads, road_weight, points_x, points_y = WorldSim:GetRoad(0, join_islands)
		    local current_road = 1
		    local min_road_length = math.random(3,5)
		   	--print("Building roads... Min Length:"..min_road_length, world_gen_choices["tweak"]["misc"]["roads"])
		   	
		    
		    if #points_x>=min_road_length then
		    	save.map.roads[current_road] = {3}
				for current_pos_idx = 1, #points_x  do
						local x = math.floor((points_x[current_pos_idx] - map_width/2.0)*TILE_SCALE*10)/10.0
						local y = math.floor((points_y[current_pos_idx] - map_height/2.0)*TILE_SCALE*10)/10.0
						
						table.insert(save.map.roads[current_road], {x, y})
				end
				current_road = current_road + 1
			end
			
		    for current_road = current_road, num_roads  do
		    	
		    	num_roads, road_weight, points_x, points_y = WorldSim:GetRoad(current_road-1, join_islands)
		    	    
		    	if #points_x>=min_road_length then    	
			    	save.map.roads[current_road] = {road_weight}
				    for current_pos_idx = 1, #points_x  do
						local x = math.floor((points_x[current_pos_idx] - map_width/2.0)*TILE_SCALE*10)/10.0
						local y = math.floor((points_y[current_pos_idx] - map_height/2.0)*TILE_SCALE*10)/10.0
						
						table.insert(save.map.roads[current_road], {x, y})
					end
				end
			end
		end
	end

	print("Done "..prefab.." map gen!")

	return save
end

return {
    Generate = GenerateVoro,
	TRANSLATE_TO_PREFABS = TRANSLATE_TO_PREFABS,
	TRANSLATE_AND_OVERRIDE = TRANSLATE_AND_OVERRIDE,
	MULTIPLY = MULTIPLY,
}

