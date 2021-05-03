require("constants")

local StaticLayout = require("map/static_layout")
local ExampleLayout = 
	{
		["Farmplot"] = 
						{
							-- Choose layout type
							type = LAYOUT.STATIC,
							
							-- Add any arguments for the layout function
							args = nil,
							
							-- Define a choice list for substitution below
							defs = 
								{
								 	unknown_plant = { "carrot_planted","flower", "grass", "berrybush2" },
								},
							
							-- Lay the objects in whatever pattern
							layout = 
								{
									unknown_plant = {
													 {x=-1,y=-1}, {x=0,y=-1}, {x=1,y=-1},
													 {x=-1, y=0}, {x=0, y=0}, {x=1, y=0},
													 {x=-1, y=1}, {x=0, y=1}, {x=1, y=1}
													},
								},
								
							-- Either choose to specify the objects positions or a number of objects
							count = nil,
								
							-- Choose a scale on which to place everything
							scale = 0.3
						},
		["StoneHenge"] = 
						{
							type = LAYOUT.CIRCLE_EDGE,
							defs = 
								{
								 	unknown_plant = { "rock2", "rock1", "evergreen_tall", "evergreen_normal", "evergreen_short", "sapling"},
								},
							count = 
								{
									unknown_plant = 9,
								},
							scale = 1.2
						},						 
		["CropCircle"] = 
						{
							type = LAYOUT.CIRCLE_RANDOM,
							defs = 
								{
								 	unknown_plant = { "carrot_planted", "grass", "flower", "berrybush2"},
								},
							count = 
								{
									unknown_plant = 15,
								},
							scale = 1.5
						},
		["TreeFarm"] = 
						{
							type = LAYOUT.GRID,
							count = 
								{
									evergreen_short = 16,
								},
							scale = 0.9
						},
		["MushroomRingSmall"] = 
						{
							type = LAYOUT.CIRCLE_EDGE,
							defs = 
								{
								 	unknown_plant = { "red_mushroom", "green_mushroom", "blue_mushroom"},
								},
							count = 
								{
									unknown_plant = 7,
								},
							scale = 1
						},
		["MushroomRingMedium"] = 
						{
							type = LAYOUT.CIRCLE_EDGE,
							defs = 
								{
								 	unknown_plant = { "red_mushroom", "green_mushroom", "blue_mushroom"},
								},
							count = 
								{
									unknown_plant = 10,
								},
							scale = 1.2
						},
		["MushroomRingLarge"] = 
						{
							type = LAYOUT.CIRCLE_EDGE,
							defs = 
								{
								 	unknown_plant = { "red_mushroom", "green_mushroom", "blue_mushroom"},
								},
							count = 
								{
									unknown_plant = 15,
								},
							scale = 1.5
						},
		["SimpleBase"] = StaticLayout.Get("map/static_layouts/simple_base", {
							areas = {
								construction_area = function() return PickSome(2, { "birdcage", "cookpot", "firepit", "homesign", "beebox", "meatrack", "icebox", "tent" }) end,
							},
						}),
		["RuinedBase"] = StaticLayout.Get("map/static_layouts/ruined_base", {
							areas = {
								construction_area = function() return PickSome(2, { "birdcage", "cookpot", "firepit", "homesign", "beebox", "meatrack", "icebox", "tent" }) end,
							},
						}),
		["Grotto"] = StaticLayout.Get("map/static_layouts/grotto"),


		["ResurrectionStone"] = StaticLayout.Get("map/static_layouts/resurrectionstone", {border=1}),
		["ResurrectionStoneLit"] = StaticLayout.Get("map/static_layouts/resurrectionstonelit"),
		["ResurrectionStoneWinter"] = StaticLayout.Get("map/static_layouts/resurrectionstone_winter", {
				areas = {
					item_area = function() return nil end,							
					resource_area = function() 
							local choices = {{"cutgrass","cutgrass","twigs", "twigs"}, {"cutgrass","cutgrass","cutgrass","log", "log"}}
							return choices[math.random(1,#choices)] 
						end,
					},
			}),

		["WesUnlock"] = StaticLayout.Get("map/static_layouts/wes_unlock", {
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN,
						}),

		["LivingTree"] = StaticLayout.Get("map/static_layouts/livingtree", {
							
						}),

		
--------------------------------------------------------------------------------
-- MacTusk 
--------------------------------------------------------------------------------
		["MacTuskTown"] = StaticLayout.Get("map/static_layouts/mactusk_village"),
		["MacTuskCity"] = StaticLayout.Get("map/static_layouts/mactusk_city", {
							start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER
						}),

--------------------------------------------------------------------------------
-- Pigs 
--------------------------------------------------------------------------------
		["MaxMermShrine"] = StaticLayout.Get("map/static_layouts/maxwell_merm_shrine"),

		["MaxPigShrine"] = StaticLayout.Get("map/static_layouts/maxwell_pig_shrine"),
		["VillageSquare"] = 
						{
							type = LAYOUT.RECTANGLE_EDGE,
							count = 
								{
									wildborehouse = 8,
								},
							scale = 0.5
						},
		["PigTown"] = StaticLayout.Get("map/static_layouts/pigtown"),
		["Pig_MainStreet"] = StaticLayout.Get("map/static_layouts/pig_mainstreet"),
		["InsanePighouse"] = StaticLayout.Get("map/static_layouts/insane_pig"),
		["InsaneWildborehouse"] = StaticLayout.Get("map/static_layouts/insane_wildbore"),
		["DefaultPigking"] = StaticLayout.Get("map/static_layouts/default_pigking", {
			start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
			fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
			layout_position = LAYOUT_POSITION.CENTER
        }),
		["TorchPigking"] = StaticLayout.Get("map/static_layouts/torch_pigking"),
		["FisherPig"] = 
						{
							type = LAYOUT.STATIC,
							defs = 
								{
								 	unknown_hanging = { "drumstick", "smallmeat", "monstermeat", "meat"},
								 	unknown_fruit = { "pumpkin", "eggplant", "durian", "pomegranate", "dragonfruit"},
								},
							ground_types = {GROUND.IMPASSABLE, GROUND.WOODFLOOR},
							ground =
								{
									{0, 0, 1, 1, 1, 1, 1, 0},
									{0, 1, 1, 1, 1, 1, 1, 1},
									{0, 1, 1, 1, 1, 1, 1, 1},
									{0, 1, 1, 2, 2, 2, 1, 1},
									{0, 1, 1, 2, 2, 2, 1, 1},
									{0, 1, 1, 2, 2, 2, 1, 1},
									{0, 1, 1, 1, 2, 1, 1, 1},
									{0, 0, 1, 1, 2, 1, 1, 0},
								},
							layout = 
								{
									unknown_fruit = 	{ {x=-0.3, y=   0} },
									wildborehouse = 	{ {x=   0, y=   0} },
									unknown_hanging =  	{ {x= 0.8, y=-0.5} },
									firepit =  			{ {x=   1, y=   1} },
									wall_wood = {
													 {x=-1.5,y=1.5},{x=-1.25,y=1.5}, {x=-1,y=1.5}, {x=-0.75,y=1.5},       {x=0.75,y=1.5}, {x=1,y=1.5}, {x=1.25,y=1.5}, {x=1.5,y=1.5},
																		 		  {x=-0.5,y=1.75}, {x=0.5,y=1.75},
																		 		  {x=-0.5,y=   2}, {x=0.5,y=   2}, 
																		 		  {x=-0.5,y=2.25}, {x=0.5,y=2.25},
																		 		  {x=-0.5,y= 2.5}, {x=0.5,y= 2.5}, 
																		 		  {x=-0.5,y=2.75}, {x=0.5,y=2.75}, 
																		 		  {x=-0.5,y=   3}, {x=0.5,y=   3}, 
																		 		  {x=-0.5,y=3.25}, {x=0.5,y=3.25}, 
																		 		  {x=-0.5,y= 3.5}, {x=0.5,y= 3.5}, 
												},
								},
							scale = 1 -- scale must be 1 if we set grount tiles
						},
		["SwampPig"] = 
						{
							type = LAYOUT.STATIC,
							defs = 
								{
								 	unknown_bird = { "crow", "robin"},
								 	unknown_fruit = { "pumpkin", "eggplant", "durian", "pomegranate", "dragonfruit"},
								 	unknown_bird = { "carrot_planted","flower", "grass"},
								},
							layout = 
								{
									unknown_plant = {
													 {x=-1,y=-1}, {x=0,y=-1}, {x=1,y=-1},
													 {x=-1,y= 0}, {x=0,y= 0}, {x=1,y= 0},
													 {x=-1,y= 1}, {x=0,y= 1}, {x=1,y= 1}
													},
								},
							scale = 0.3
						},
						
--------------------------------------------------------------------------------
-- Start Nodes 
--------------------------------------------------------------------------------
		["DefaultStart"] = StaticLayout.Get("map/static_layouts/default_start"),
		["CaveStart"] = StaticLayout.Get("map/static_layouts/cave_start"),
		["RuinsStart"] = StaticLayout.Get("map/static_layouts/ruins_start"),
		["RuinsStart2"] = StaticLayout.Get("map/static_layouts/ruins_start2"),
		["CaveTestStart"] = StaticLayout.Get("map/static_layouts/cave_test_start"),
		["DefaultPlusStart"] = StaticLayout.Get("map/static_layouts/default_plus_start"),
		["NightmareStart"] = StaticLayout.Get("map/static_layouts/nightmare"),
		["BargainStart"] = StaticLayout.Get("map/static_layouts/bargain_start"),
		["ThisMeansWarStart"] = StaticLayout.Get("map/static_layouts/thismeanswar_start"),
		["WinterStartEasy"] = StaticLayout.Get("map/static_layouts/winter_start_easy"),
		["WinterStartMedium"] = StaticLayout.Get("map/static_layouts/winter_start_medium"),
		["WinterStartHard"] = StaticLayout.Get("map/static_layouts/winter_start_hard"),
		["PreSummerStart"] = StaticLayout.Get("map/static_layouts/presummer_start"),
		["DarknessStart"] =StaticLayout.Get("map/static_layouts/total_darkness_start"),
		
--------------------------------------------------------------------------------
-- Chess bits
--------------------------------------------------------------------------------
		
		["ChessSpot1"] = StaticLayout.Get("map/static_layouts/chess_spot", {
								defs={
									evil_thing={"marblepillar","flower_evil","marbletree"},
								},
							}),
		["ChessSpot2"] = StaticLayout.Get("map/static_layouts/chess_spot2", {
								defs={
									evil_thing={"marblepillar","flower_evil","marbletree"},
								},
							}),
		["ChessSpot3"] = StaticLayout.Get("map/static_layouts/chess_spot3", {
								defs={
									evil_thing={"marblepillar","flower_evil","marbletree"},
								},
							}),
		["Maxwell1"] = StaticLayout.Get("map/static_layouts/maxwell_1"),
		["Maxwell2"] = StaticLayout.Get("map/static_layouts/maxwell_2"),
		["Maxwell3"] = StaticLayout.Get("map/static_layouts/maxwell_3"),
		["Maxwell4"] = StaticLayout.Get("map/static_layouts/maxwell_4"),
		["Maxwell5"] = StaticLayout.Get("map/static_layouts/maxwell_5"),
		["Maxwell6"] = StaticLayout.Get("map/static_layouts/maxwell_6"),
		["Maxwell7"] = StaticLayout.Get("map/static_layouts/maxwell_7"),

--------------------------------------------------------------------------------
-- Blockers 
--------------------------------------------------------------------------------
		["TreeBlocker"] = 
						{
							type = LAYOUT.CIRCLE_RANDOM,
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
							ground_types = {GROUND.FOREST},
							ground =
								{
									{1,1},{1,1},
									--{0, 0, 1, 1, 0, 0},
									--{0, 1, 1, 1, 1, 0},
									--{1, 1, 1, 1, 1, 1},
									--{1, 1, 1, 1, 1, 1},
									--{0, 1, 1, 1, 1, 0},
									--{0, 0, 1, 1, 0, 0},
								},
							defs = 
								{
								 	trees = { "evergreen_short", "evergreen_normal", "evergreen_tall"},
								},
							count = 
								{
									trees = 185,
								},
							scale = 0.9,
						},
		["RockBlocker"] = 
						{
							type = LAYOUT.CIRCLE_EDGE,
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
							ground_types = {GROUND.ROCKY},
							defs = 
								{
								 	rocks = { "rock1", "rock2"},
								},
							count = 
								{
									rocks = 35,
								},
							scale = 1.9,
						},
		["InsanityBlocker"] = 
						{
							type = LAYOUT.CIRCLE_EDGE,
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
							ground_types = {GROUND.ROCKY},
							defs = 
								{
								 	rocks = { "insanityrock"},
								},
							count = 
								{
									rocks = 55,
								},
							scale = 4.0,
						},
		["SanityBlocker"] = 
						{
							type = LAYOUT.CIRCLE_EDGE,
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
							ground_types = {GROUND.ROCKY},
							defs = 
								{
								 	rocks = { "sanityrock"},
								},
							count = 
								{
									rocks = 55,
								},
							scale = 4.0,
						},
		["InsaneFlint"] = StaticLayout.Get("map/static_layouts/insane_flint"),
		["PigGuardsEasy"] = StaticLayout.Get("map/static_layouts/pigguards_easy", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER
						}),
		["PigGuards"] = StaticLayout.Get("map/static_layouts/pigguards", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER
						}),
		["PigGuardsB"] = StaticLayout.Get("map/static_layouts/pigguards_b", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER
						}),
		["TallbirdBlockerSmall"] = StaticLayout.Get("map/static_layouts/tallbird_blocker_small", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
						}),
		["TallbirdBlocker"] = StaticLayout.Get("map/static_layouts/tallbird_blocker", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
						}),
		["TallbirdBlockerB"] = StaticLayout.Get("map/static_layouts/tallbird_blocker_b", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
						}),
		["TentacleBlockerSmall"] = StaticLayout.Get("map/static_layouts/tentacles_blocker_small", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
						}),
		["TentacleBlocker"] = StaticLayout.Get("map/static_layouts/tentacles_blocker", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
						}),
		["SpiderBlockerEasy"] = StaticLayout.Get("map/static_layouts/spider_blocker_easy", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
						}),
		["SpiderBlockerEasyB"] = StaticLayout.Get("map/static_layouts/spider_blocker_easy_b", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
						}),
		["SpiderBlocker"] = StaticLayout.Get("map/static_layouts/spider_blocker", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
						}),
		["SpiderBlockerB"] = StaticLayout.Get("map/static_layouts/spider_blocker_b", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
						}),
		["SpiderBlockerC"] = StaticLayout.Get("map/static_layouts/spider_blocker_c", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
						}),
		["ChessBlocker"] = StaticLayout.Get("map/static_layouts/chess_blocker", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
						}),
		["ChessBlockerB"] = StaticLayout.Get("map/static_layouts/chess_blocker_b", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
							areas={
								flower_area = ExtendedArray({}, "flower_evil", 15),
							},
						}),
		["ChessBlockerC"] = StaticLayout.Get("map/static_layouts/chess_blocker_c", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
						}),
		["MaxwellHome"] = StaticLayout.Get("map/static_layouts/maxwellhome", {
							areas = 
							{								
								barren_area = function(area) return PickSomeWithDups( 0.5 * area
									, {"marsh_tree", "marsh_bush", "rock1", "rock2", "evergreen_burnt", "evergreen_stump"}) end,
								gold_area = function() return PickSomeWithDups(math.random(15,20), {"goldnugget"}) end,
								livinglog_area = function() return PickSomeWithDups(math.random(5, 10), {"livinglog"}) end,
								nightmarefuel_area = function() return PickSomeWithDups(math.random(5, 10), {"nightmarefuel"}) end,
								deadlyfeast_area = function() return PickSomeWithDups(math.random(25,30), {"monstermeat", "green_cap", "red_cap", "spoiled_food", "meat"}) end,
								marblegarden_area = function(area) return PickSomeWithDups(1.5*area, {"marbletree", "flower_evil"}) end,
							},
							start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
							disable_transform = true
						}),

		["PermaWinterNight"] = StaticLayout.Get("map/static_layouts/nightmare_begin_blocker", {
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
						}),
				
--------------------------------------------------------------------------------
-- Wormhole 
--------------------------------------------------------------------------------
		-- "Generic" wormholes
		["WormholeGrass"] = StaticLayout.Get("map/static_layouts/wormhole_grass"),

		-- "Fancy" wormholes
		["InsaneEnclosedWormhole"] = StaticLayout.Get("map/static_layouts/insane_wormhole"),
		["InsaneWormhole"] = StaticLayout.Get("map/static_layouts/insanity_wormhole_1"),
		["SaneWormhole"] = StaticLayout.Get("map/static_layouts/sanity_wormhole_1"),
		["SaneWormholeOneShot"] = StaticLayout.Get("map/static_layouts/sanity_wormhole_oneshot"),
		["WormholeOneShot"] = StaticLayout.Get("map/static_layouts/wormhole_oneshot", {
			areas= {
				bones_area = {"houndbone"},
			},
		}),
		
--------------------------------------------------------------------------------
-- Eyebone 
--------------------------------------------------------------------------------
		["InsaneEyebone"] = StaticLayout.Get("map/static_layouts/insane_eyebone"),

--------------------------------------------------------------------------------
-- TELEPORTATO 
--------------------------------------------------------------------------------
		["TeleportatoBoxLayout"] = StaticLayout.Get("map/static_layouts/teleportato_box_layout"),
		["TeleportatoRingLayout"] = 
						{
							type = LAYOUT.CIRCLE_EDGE,
							start_mask = PLACE_MASK.NORMAL,
							fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
							layout_position = LAYOUT_POSITION.CENTER,
							ground_types = {GROUND.GRASS},
							ground = {
									{0, 1, 1, 1, 0},
									{1, 1, 1, 1, 1},
									{1, 1, 1, 1, 1},
									{1, 1, 1, 1, 1},
									{0, 1, 1, 1, 0},
								},
							count = {
									flower_evil = 15,
								},
							layout = {
									teleportato_ring = { {x=0,y=0} },
								},

							scale = 1,
						},
		["TeleportatoPotatoLayout"] = StaticLayout.Get("map/static_layouts/teleportato_potato_layout"),
		["TeleportatoCrankLayout"] = StaticLayout.Get("map/static_layouts/teleportato_crank_layout"),
		["TeleportatoBaseLayout"] = StaticLayout.Get("map/static_layouts/teleportato_base_layout"),
		["TeleportatoBaseAdventureLayout"] = StaticLayout.Get("map/static_layouts/teleportato_base_layout_adv"),
		["AdventurePortalLayout"] = StaticLayout.Get("map/static_layouts/adventure_portal_layout"),

--------------------------------------------------------------------------------
-- MAX PUZZLE 
--------------------------------------------------------------------------------
		--["SymmetryTest"] = StaticLayout.Get("map/static_layouts/symmetry_test"),
		--["SymmetryTest2"] = StaticLayout.Get("map/static_layouts/symmetry_test2"),
		["test"] = StaticLayout.Get("map/static_layouts/test", {
			areas = {
				area_1 = {"rocks","log"},
				area_2 = {"grass","berrybush"},
			},
		}),
		["MaxPuzzle1"] = StaticLayout.Get("map/static_layouts/MAX_puzzle1"),
		["MaxPuzzle2"] = StaticLayout.Get("map/static_layouts/MAX_puzzle2"),
		["MaxPuzzle3"] = StaticLayout.Get("map/static_layouts/MAX_puzzle3"),



--------------------------------------------------------------------------------
-- CAVES 
--------------------------------------------------------------------------------

	["CaveBase"] = StaticLayout.Get("map/static_layouts/cave_base_1"),
	["MushBase"] = StaticLayout.Get("map/static_layouts/cave_base_2"),
	["SinkBase"] = StaticLayout.Get("map/static_layouts/cave_base_3"),
	["RabbitTown"] = StaticLayout.Get("map/static_layouts/rabbittown"),
	["CaveArtTest"] = StaticLayout.Get("map/static_layouts/cave_art_test_start"),
	["RabbitCity"] = StaticLayout.Get("map/static_layouts/insane_rabbit_king",
				{
				start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
				fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
				layout_position = LAYOUT_POSITION.RANDOM,
			}
		),
	["TorchRabbitking"] = StaticLayout.Get("map/static_layouts/torch_rabbit_cave",
				{
				start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
				fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
				layout_position = LAYOUT_POSITION.RANDOM,
			}
		),
	

--------------------------------------------------------------------------------
-- RUINS
--------------------------------------------------------------------------------


	["WalledGarden"] = StaticLayout.Get("map/static_layouts/walledgarden",
		{
			areas = 
			{
				plants = function(area) return PickSomeWithDups(0.3 * area, {"cave_fern", "lichen", "flower_cave", "flower_cave_double", "flower_cave_triple"}) end,
			},
			start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
			fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
			layout_position = LAYOUT_POSITION.CENTER
		}),
	["MilitaryEntrance"] = StaticLayout.Get("map/static_layouts/military_entrance", {			
			start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
			fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
			layout_position = LAYOUT_POSITION.CENTER}),
	
	--SACRED GROUNDS

	["AltarRoom"] = StaticLayout.Get("map/static_layouts/altar"),
	["Barracks"] = StaticLayout.Get("map/static_layouts/barracks"),
	["Barracks2"] = StaticLayout.Get("map/static_layouts/barracks_two"),
	["Spiral"] = StaticLayout.Get("map/static_layouts/spiral"),
	["BrokenAltar"] = StaticLayout.Get("map/static_layouts/brokenaltar"),

	--

	["CornerWall"] = StaticLayout.Get("map/static_layouts/walls_corner"),
	["StraightWall"] = StaticLayout.Get("map/static_layouts/walls_straight"),

	["CornerWall2"] = StaticLayout.Get("map/static_layouts/walls_corner2"),
	["StraightWall2"] = StaticLayout.Get("map/static_layouts/walls_straight2"),

	["RuinsCamp"] = StaticLayout.Get("map/static_layouts/ruins_camp"),

	["DeciduousPond"] = StaticLayout.Get("map/static_layouts/deciduous_pond", {disable_transform = true}),

	["Chessy_1"] = StaticLayout.Get("map/static_layouts/chessy_1"),
	["Chessy_2"] = StaticLayout.Get("map/static_layouts/chessy_2"),
	["Chessy_3"] = StaticLayout.Get("map/static_layouts/chessy_3"),
	["Chessy_4"] = StaticLayout.Get("map/static_layouts/chessy_4"),
	["Chessy_5"] = StaticLayout.Get("map/static_layouts/chessy_5"),
	["Chessy_6"] = StaticLayout.Get("map/static_layouts/chessy_6"),

	["Warzone_1"] = StaticLayout.Get("map/static_layouts/warzone_1"),
	["Warzone_2"] = StaticLayout.Get("map/static_layouts/warzone_2"),
	["Warzone_3"] = StaticLayout.Get("map/static_layouts/warzone_3"),

--------------------------------------------------------------------------------
-- SHIPWRECKED
--------------------------------------------------------------------------------
	["ShipwreckedStart"] = StaticLayout.Get("map/static_layouts/shipwrecked_start", {
		start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
		fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
		layout_position = LAYOUT_POSITION.CENTER,
		disable_transform = true,
	}),
	["VolcanoStart"] = StaticLayout.Get("map/static_layouts/volcano_start", {
		start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
		fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
		layout_position = LAYOUT_POSITION.CENTER,
		disable_transform = true,
	}),
	["Casino"] = StaticLayout.Get("map/static_layouts/casino", {border = 1}),
	["BeachRaftHome"] = StaticLayout.Get("map/static_layouts/beach_raft_home", {start_mask = PLACE_MASK.IGNORE_WATER, fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_WATER}),
	["Xspot"] = StaticLayout.Get("map/static_layouts/x_spot"),
	["SharkHome"] = StaticLayout.Get("map/static_layouts/sharkhome"),
	["DoydoyGirl"] = StaticLayout.Get("map/static_layouts/doydoy1", {fill_mask = PLACE_MASK.IGNORE_WATER}),
	["DoydoyBoy"] = StaticLayout.Get("map/static_layouts/doydoy2", {fill_mask = PLACE_MASK.IGNORE_WATER}),
	["VolcanoAltar"] = StaticLayout.Get("map/static_layouts/volcano_altar"),
	["BerryBushBunch"] = StaticLayout.Get("map/static_layouts/berrybushbunch"),
	["CoffeeBushBunch"] = StaticLayout.Get("map/static_layouts/coffeebushbunch"),
	["SWPortal"] = StaticLayout.Get("map/static_layouts/sw_portal"),
	["JungleOasis"] = StaticLayout.Get("map/static_layouts/oasis2"),
	["BuriedTreasureLayout"] = 
		{
			type = LAYOUT.STATIC,
			ground = {
					{0, 0,},
					{0, 0,},
				},
			layout = {
					buriedtreasure = { {x=0,y=0} },
				},
			scale = 1
		},
	["TreasureHunterMap"] = StaticLayout.Get("map/static_layouts/small_boon", {
			areas = {
				item_area = {"messagebottle", "piratehat"},
				resource_area = {"dubloon"},
				},
		}),
	["TreasureHunterBoon"] = StaticLayout.Get("map/static_layouts/small_boon", {
			areas = {
				item_area = {"messagebottle", "messagebottleempty", "strawhat"},
				resource_area = {},
				},
		}),
	["PalmTreeIsland"] = StaticLayout.Get("map/static_layouts/islands/palmtreeisland", {
			disable_transform = true,
			areas = {
				item_area = {"palmtree", "skeleton", "seashell_beached"}
			}
		}),
	["ShipwreckedEntrance"] = 
		{
			type = LAYOUT.STATIC,
			layout = {
					shipwrecked_entrance = { {x=0,y=0} },
				},
			scale = 1,
		},
	["ShipwreckedExit"] = StaticLayout.Get("map/static_layouts/islands/palmtreeisland"),
		-- {
		-- 	type = LAYOUT.STATIC,
		-- 	layout = {
		-- 			shipwrecked_exit = { {x=0,y=0} },
		-- 		},
		-- 	scale = 1,
		-- },
	["LivingJungleTree"] = StaticLayout.Get("map/static_layouts/livingjungletree"),
	["ResurrectionStoneSw"] = StaticLayout.Get("map/static_layouts/resurrectionstone_sw", {border=1}),
	["RockSkull"] = StaticLayout.Get("map/static_layouts/skull_isle2", {
			areas = {
				area_1 = function() return PickSomeWithDups(math.random(5,8), {"rocks", "flint"}) end,
				area_2 = function() return PickSomeWithDups(math.random(5,8), {"rocks", "flint"}) end,
				area_3 = function() return PickSomeWithDups(math.random(5,8), {"rocks", "flint"}) end,
				area_4 = function() return PickSomeWithDups(math.random(5,8), {"rocks", "flint"}) end,
				area_5 = function() return PickSomeWithDups(math.random(5,8), {"rocks", "flint"}) end,
				area_6 = function() return PickSomeWithDups(math.random(5,8), {"rocks", "flint"}) end,
				area_7 = function() return PickSomeWithDups(math.random(4,7), {"rocks", "flint"}) end,
				area_8 = function() return PickSomeWithDups(math.random(5,8), {"rocks", "flint"}) end,
				area_9 = function() return PickSomeWithDups(math.random(4,7), {"rocks", "flint", "goldnugget"}) end,
				area_10 = function() return PickSomeWithDups(math.random(5,8), {"rocks", "flint", "goldnugget"}) end,
			},
			fill_mask = PLACE_MASK.IGNORE_WATER
		}),
	["TidalpoolMedium"] = 
		{
			type = LAYOUT.STATIC,
			ground = {
					{0, 0,},
					{0, 0,},
				},
			layout = {
					tidalpool = { {x=0,y=0,properties={data={size=2}}} },
				},
			scale = 1,
		},
	["TidalpoolLarge"] = 
		{
			type = LAYOUT.STATIC,
			ground = {
					{0, 0,},
					{0, 0,},
				},
			layout = {
					tidalpool = { {x=0,y=0,properties={data={size=3}}} },
				},
			scale = 1,
		},
	["ObsidianWorkbench"] = StaticLayout.Get("map/static_layouts/volcano_workbench"),
	["Volcano"] =
		{
			type = LAYOUT.STATIC,
			ground = {
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
				},
			layout = {
					volcano = { {x=0,y=0} },
				},
			scale = 1,
		},

	["WilburUnlock"] = StaticLayout.Get("map/static_layouts/wilbur_unlock", {water = true}),
	["WoodlegsUnlock"] = StaticLayout.Get("map/static_layouts/woodlegs_unlock"),
	--[[["Wreck"] =
		{
			type = LAYOUT.STATIC,
			water = true,
			ground = {
					{0, 0, 0},
					{0, 0, 0},
					{0, 0, 0},
				},
			areas = {
					ship_area = {"wreck"},
					mast_area = function() if math.random() < 0.5 then return {"wreck_mast"} else return {} end end,
					debris_area = PickSomeWithDups(math.random(0, 3), {"boards", "rope", "messagebottleempty"})
			},
			layout = {
					ship_area = { {x=0,y=0,width=1,height=1,properties={data={isnamed=true}}} },
				},
			scale = 1,
		},]]
	["Wreck"] = StaticLayout.Get("map/static_layouts/wreck", {
			water = true,
			areas = {
					ship_area = {"wreck"},
					mast_area = function() if math.random() < 0.75 then return {"wreck"} else return {} end end,
					debris_area = PickSomeWithDups(math.random(1, 4), {"boards", "rope", "fabric", "messagebottleempty"})
			},
			--layout = {
			--	ship_area = { {properties={data={isnamed=true}}} }
			--}
		}),
	["OctopusKing"] = 
		{
			type = LAYOUT.STATIC,
			water = true,
			ground = {
					{0, 0,},
					{0, 0,},
				},
			layout = {
					octopusking = { {x=0,y=0} },
				},
			scale = 1,
		},
	["ShipgraveLuggage"] = 
		{
			type = LAYOUT.STATIC,
			water = true,
			ground = {
					{0},
				},
			layout = {
					luggagechest = { {x=0,y=0,properties={scenario="chest_shipgrave"}} },
				},
			scale = 1,
		},

--------------------------------------------------------------------------------
-- SHIPWRECKED TELEPORTATO 
--------------------------------------------------------------------------------
	["TeleportatoSwBoxLayout"] = StaticLayout.Get("map/static_layouts/teleportato_sw_box_layout", {
        border = 1,
        start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
        fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
        layout_position = LAYOUT_POSITION.CENTER,
    }),
	["TeleportatoSwRingLayout"] = StaticLayout.Get("map/static_layouts/teleportato_sw_ring_layout", {
        border = 1,
        start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
        fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
        layout_position = LAYOUT_POSITION.CENTER,
    }),
	["TeleportatoSwPotatoLayout"] = StaticLayout.Get("map/static_layouts/teleportato_sw_potato_layout", {
        border = 1,
        start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
        fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
        layout_position = LAYOUT_POSITION.CENTER,
    }),
	["TeleportatoSwCrankLayout"] = StaticLayout.Get("map/static_layouts/teleportato_sw_crank_layout", {
        border = 1,
        start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
        fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
        layout_position = LAYOUT_POSITION.CENTER,
    }),
	["TeleportatoSwBaseLayout"] = StaticLayout.Get("map/static_layouts/teleportato_sw_base_layout", {
        water = true,
        start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
        fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
        layout_position = LAYOUT_POSITION.CENTER,
    }),

	["city_1"] = StaticLayout.Get("map/static_layouts/city_1"),
	["city_1_2"] = StaticLayout.Get("map/static_layouts/city_1"),
	["city_1_3"] = StaticLayout.Get("map/static_layouts/city_1"),
	["city_1_4"] = StaticLayout.Get("map/static_layouts/city_1"),

	["city_1_5"] = StaticLayout.Get("map/static_layouts/city_1"),
	["city_1_6"] = StaticLayout.Get("map/static_layouts/city_1"),
	["city_1_7"] = StaticLayout.Get("map/static_layouts/city_1"),

	["city_2"] = StaticLayout.Get("map/static_layouts/city_2"),	
	["city_2_2"] = StaticLayout.Get("map/static_layouts/city_2"),	
	["city_2_3"] = StaticLayout.Get("map/static_layouts/city_2"),	
	["city_2_4"] = StaticLayout.Get("map/static_layouts/city_2"),	
	["city_2_5"] = StaticLayout.Get("map/static_layouts/city_2"),	


--PORKLAND
	["PorklandStart"] = StaticLayout.Get("map/static_layouts/porkland_start"),
	["PigRuinsEntrance1"] = StaticLayout.Get("map/static_layouts/pig_ruins_entrance_1",{
		areas = {
				item1 = function() if math.random()<1 then return {"smashingpot"} else return nil end end,
				item2 = function() if math.random()<1 then return {"smashingpot"} else return nil end end,
				item3 = function() if math.random()<1 then return {"smashingpot"} else return nil end end
			}
	}),
	["PigRuinsExit1"] = StaticLayout.Get("map/static_layouts/pig_ruins_exit_1"),
	["PigRuinsEntrance2"] = StaticLayout.Get("map/static_layouts/pig_ruins_entrance_2"),
	["PigRuinsExit2"] = StaticLayout.Get("map/static_layouts/pig_ruins_exit_2",{
		areas = { item1 = function() if math.random()<0.7 then return {"smashingpot"} else return nil end end,
				  item2 = function() if math.random()<0.7 then return {"smashingpot"} else return nil end end,
				  item3 = function() if math.random()<0.7 then return {"smashingpot"} else return nil end end
			}
	}),

	["PigRuinsEntrance3"] = StaticLayout.Get("map/static_layouts/pig_ruins_entrance_3"),
	["PigRuinsEntrance4"] = StaticLayout.Get("map/static_layouts/pig_ruins_entrance_4",{
		areas = {
				item1 = function() if math.random()<1 then return {"smashingpot"} else return nil end end,
				item2 = function() if math.random()<1 then return {"smashingpot"} else return nil end end,
				item3 = function() if math.random()<1 then return {"smashingpot"} else return nil end end
			}
	}),
	["PigRuinsExit4"] = StaticLayout.Get("map/static_layouts/pig_ruins_exit_4",{
		areas = { item1 = function() if math.random()<0.7 then return {"smashingpot"} else return nil end end,
				  item2 = function() if math.random()<0.7 then return {"smashingpot"} else return nil end end,
				  item3 = function() if math.random()<0.7 then return {"smashingpot"} else return nil end end
			}
	}),	
	["PigRuinsEntrance5"] = StaticLayout.Get("map/static_layouts/pig_ruins_entrance_5",{
		areas = {
				item1 = function() if math.random()<1 then return {"smashingpot"} else return nil end end,
				item2 = function() if math.random()<1 then return {"smashingpot"} else return nil end end,
				item3 = function() if math.random()<1 then return {"smashingpot"} else return nil end end
			}
	}),	

	["lilypad"] = StaticLayout.Get("map/static_layouts/lilypad", {
		water = true,
		areas = { resource_area = {"lilypad"}},
	}),
	["lilypad2"] = StaticLayout.Get("map/static_layouts/lilypad_2", {
		water = true,
		areas = { resource_area = {"lilypad"},
				  resource_area2 = {"lilypad"}
				  },				  
	}),
	["PigRuinsHead"] = StaticLayout.Get("map/static_layouts/pig_ruins_head",{
		areas = { item1 = {"pig_ruins_head"},
				  item2 = function() 		  			
			  				local list = {"smashingpot","grass","pig_ruins_torch"} 
			  				for i=#list,1,-1 do
			  					if math.random()<0.7 then
			  						table.remove(list,i)
			  					end
			  				end
			  				return list
				  		end,
				  },
	}),
	["PigRuinsArtichoke"] = StaticLayout.Get("map/static_layouts/pig_ruins_artichoke",{
		areas = { item1 = function() if math.random()<0.7 then return {"smashingpot"} else return nil end end,
				  item2 = {"pig_ruins_artichoke"}
		          },
	}),
	["mandraketown"] = StaticLayout.Get("map/static_layouts/mandraketown"),
	["nettlegrove"] = StaticLayout.Get("map/static_layouts/nettlegrove"),
	["fountain_of_youth"] = StaticLayout.Get("map/static_layouts/pugalisk_fountain"),	

	["pig_ruins_nocanopy"] = StaticLayout.Get("map/static_layouts/pig_ruins_nocanopy"),	
	["pig_ruins_nocanopy_2"] = StaticLayout.Get("map/static_layouts/pig_ruins_nocanopy_2"),		
	["pig_ruins_nocanopy_3"] = StaticLayout.Get("map/static_layouts/pig_ruins_nocanopy_3"),		
	["pig_ruins_nocanopy_4"] = StaticLayout.Get("map/static_layouts/pig_ruins_nocanopy_4"),		

	["roc_nest"] = StaticLayout.Get("map/static_layouts/roc_nest"),	
	["roc_cave"] = StaticLayout.Get("map/static_layouts/roc_cave"),		

--------------------------------------------------------------------------------
-- HAMLET TELEPORTATO 
--------------------------------------------------------------------------------

	["TeleportatoHamletBaseLayout"] = StaticLayout.Get("map/static_layouts/teleportato_hamlet_base_layout", {
        border = 1,
        layout_position = LAYOUT_POSITION.CENTER,
    }),	
	["TeleportatoHamletBoxLayout"] = StaticLayout.Get("map/static_layouts/teleportato_hamlet_box_layout", {
        border = 1,
        layout_position = LAYOUT_POSITION.CENTER,
    }),	 
	["TeleportatoHamletCrankLayout"] = StaticLayout.Get("map/static_layouts/teleportato_hamlet_crank_layout", {
        border = 1,
        layout_position = LAYOUT_POSITION.CENTER,
    }),	     
    ["TeleportatoHamletRingLayout"] = StaticLayout.Get("map/static_layouts/teleportato_hamlet_ring_layout", {
        border = 1,
        layout_position = LAYOUT_POSITION.CENTER,
    }),	   
    --[[
    	["TeleportatoHamletPotatoLayout"] = StaticLayout.Get("map/static_layouts/teleportato_hamlet_potato_layout", {
        border = 1,
        layout_position = LAYOUT_POSITION.CENTER,
    	}),	   
    ]]
}
	
return {Layouts = ExampleLayout}
