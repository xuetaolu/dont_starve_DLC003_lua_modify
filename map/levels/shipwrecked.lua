require("map/level")


----------------------------------
-- Survival levels
----------------------------------

AddLevel(LEVELTYPE.SHIPWRECKED, {
		id="SHIPWRECKED_DEFAULT",
		name=STRINGS.UI.CUSTOMIZATIONSCREEN.SHIPWRECKEDLEVELS[1],
		desc=STRINGS.UI.CUSTOMIZATIONSCREEN.SHIPWRECKEDLEVELDESC[1],
		overrides={
				{"start_setpeice", 	"ShipwreckedStart"}, --You start in a setpiece, this one is a grass patch with flowers. 
				{"start_node",		"BeachSand"},  --This is the room (biome) you start in 'BeachSand' comes from terrain_beach.lua
				{"start_task",		"HomeIsland"}, --The island (task) you start on. From the list of 'tasks' below
				{"location",		"shipwrecked"},
				{"roads", 			"never"}, --Does the map have roads?
				{"loop",			"never"},
				{"poi",				"never"},
				{"world_size",		"default"}, --World size: tiny, small, default, medium, large, or huge. Actual values are in map/forest_map.lua approx line 270
				--{"mild_season",		20},
				--{"wet_season",		16},
				--{"green_season",	21},
				--{"dry_season",		16},
		},

		--Tasks (Island recipes) are sets of rooms (biomes) that define an island. These tasks will be inserted
		--into the world based on a lock/key system. Tasks can only be used once
		--Shipwrecked tasks are currently in map/tasks/island.lua
		--Original tasks are in map/tasks.lua

		--To add a new task to the world add the task name to the 'tasks' or 'optionaltasks' list.
		--see map/tasks/island.lua for making tasks

		--One of these tasks is picked as the start_task, based on weight
		--start_setpiece and start_node, from above, are the defaults
		start_tasks = {
			--["HomeIslandSingleTree"] = {
			--	weight = .1,
			--	start_setpiece = "BeachRaftHome",
			--	start_node = "OceanShallow"
			--},
			["HomeIslandVerySmall"] = {
				weight = .5,
				start_setpiece = "ShipwreckedStart",
				start_node = "BeachSandHome"
			},
			["HomeIslandSmall"] = {
				weight = 1,
				start_setpiece = "ShipwreckedStart",
				start_node = "BeachSandHome"
			},
			["HomeIslandSmallBoon"] = {
				weight = .2,
				start_setpiece = "ShipwreckedStart",
				start_node = "BeachSandHome"
			},
			["HomeIslandMed"] = {
				weight = 1,
				start_setpiece = "ShipwreckedStart",
				start_node = "BeachSandHome"
			},
			["HomeIslandLarge"] = {
				weight = .75,
				start_setpiece = "ShipwreckedStart",
				start_node = "BeachSandHome"
			},
			["HomeIslandLargeBoon"] = {
				weight = .2,
				start_setpiece = "ShipwreckedStart",
				start_node = "BeachSandHome"
			},
		},

		--These tasks are always part of the world.
		tasks = {
		-- ======================================================================================= ORIGINAL BATCH ===========================================================================
			--"HomeIslandSmall",
			--"DesertIsland",
			--"BeachJingleS",
			--"BeachBothJungles",
			--"PalmTreeIsland",
			--"ThemePigIsland",
			--"ThemeMarshCity",
			--"JungleMarsh",
			--"Spiderland",
			--"FullofBees",
			--"DoydoyIslandGirl",
			--"DoydoyIslandBoy",
			--"KelpForest",
			--"GreatShoal",
			--"BarrierReef",
			--"IslandJungleMonkeyHell",
			--"LagoonTest",
			-- ====================================================================================== NEW LIST ==============================================================================
			"DesertIsland",
			"DoydoyIslandGirl",
			"DoydoyIslandBoy",
			"IslandCasino",
			"PirateBounty", --NEW
			"ShellingOut", --NEW
			"JungleMarsh",
			"IslandMangroveOxBoon",
			"SharkHome",
			"IslandOasis",
			},



-- ===================================================================================================================================================
--                                                                  "RING" GENERATION METHOD
-- ===================================================================================================================================================

	

		--These are optional tasks. World gen will randomly pick 'numoptionaltasks' from the list
		--and add them to the world
		--numoptionaltasks = 9,
		--optionaltasks = {
		--},

		--These are optional tasks. For each group WorldGen will randomly pick between 'min' and 'max'
		--from the 'task_choices' and add them to the world.
		selectedtasks = {
			{ -- RING NONE
				min = 2,
				max = 3, --want this to be 3 but need another island to add in here
				task_choices = {
					"BeachBothJungles",
					"IslandParadise",
					"Cranium",
				}
			},
			{ -- RING 1
				min = 3,
				max = 5,
				task_choices = {
					"BeachJingleS",
					"BeachSavanna",
					"GreentipA",
					"GreentipB",
					"HalfGreen",
					"BeachRockyland",
					"LotsaGrass",
					"CrashZone",
					--"IslandJungleGrassy",
					--"IslandJungleSappy",
				}
			},
			{ -- RING 2
				min = 3, --was 6
				max = 4, --was 9
				task_choices = {
					"BeachJungleD",
					"AllBeige",
					"BeachMarsh",
					"Verdant",
					"Vert",
					"VerdantMost",
					--"JungleBoth", --cut this because it's boring
					"Florida Timeshare",
					"PiggyParadise",
					"BeachPalmForest",
					"IslandJungleShroomin",
					"IslandJungleNoFlowers", 
					"IslandBeachGrassy",
					"IslandBeachRocky",
					"IslandBeachSpider",
					"IslandBeachNoCrabbits",
					--"IslandSavannaSpider",
				}
			},
			{ -- RING 3
				min = 4, --was 10
				max = 6, --was 12
				task_choices = {
					"JungleSRockyland",
					"JungleSSavanna",
					"JungleBeige",
					"Spiderland",
					"IslandJungleBamboozled",
					"IslandJungleNoBerry",
					"IslandBeachDunes",
					"IslandBeachSappy",
					--"IslandBeachFlowers",
					"IslandBeachNoLimpets",
					"JungleDense",
					"JungleDMarsh",
					"JungleDRockyland",
					"JungleDRockyMarsh", --maybe cut this? 
					"JungleDSavanna",
					"JungleDSavRock",
					"ThemeMarshCity",
					"IslandJungleCritterCrunch",
					"IslandRockyTallJungle",
					"IslandBeachNoFlowers",
					--"IslandSavannaSappy",
					"NoGreen A",
					"KelpForest",
					"GreatShoal",
					"BarrierReef",
				}
			},
			{ -- RING 4
				min = 6, --was 6
				max = 8, --was 8
				task_choices = {
					"HotNSticky",
					"Marshy",
					"Rockyland",
					--"PalmTreeIsland", --doesn't work well with giant rooms
					"IslandJungleMonkeyHell",
					"IslandJungleSkeleton",
					"FullofBees",
					"IslandJungleRockyDrop",
					"IslandJungleEvilFlowers",
					"IslandBeachCrabTown",
					"IslandBeachForest",
					--"IslandMeadowWetlands",
					--"IslandSavannaRocky",
					"IslandJungleNoRock",
					--"JungleSparse",
					"IslandJungleNoMushroom",
					"NoGreen B",
					"Savanna",
					--"IslandMagmaJungle",
					"IslandBeachLimpety",
					"IslandMeadowBees",
					"IslandRockyGold",
					"IslandRockyTallBeach",
					--"IslandJungleNoGrass",
					--"IslandJungleMorePalms",
					--"IslandGravy",
					--"IslandJungleEyePlant",
					--"IslandMangroveOxBoon",
					--"IslandSavannaFlowery",
					"IslandMeadowCarroty",
					--"IslandRockyBlueMushroom",
					--"PirateBounty",
					--"ShellingOut",
				}
			},
		},


-- ===================================================================================================================================================
--                                                                 END OF "RING" GENERATION METHOD
-- ===================================================================================================================================================

		--The random range of background rooms (biomes) that get added to each room in a task.
		background_node_range = {0, 2},

		water_content = {
			["WaterAll"] = {checkFn = function(ground) return WorldSim:IsWater(ground) and not WorldSim:IsShore(ground) end},
			["WaterShallow"] = {checkFn = function(ground) return ground == GROUND.OCEAN_SHALLOW end},
			["WaterMedium"] = {checkFn = function(ground) return ground == GROUND.OCEAN_MEDIUM end},
			["WaterDeep"] = {checkFn = function(ground) return ground == GROUND.OCEAN_DEEP end},
			["WaterCoral"] = {checkFn = function(ground) return ground == GROUND.OCEAN_CORAL end},
			--["WaterMangrove"] = {checkFn = function(ground) return ground == GROUND.MANGROVE end},
			["WaterShipGraveyard"] = {checkFn = function(ground) return ground == GROUND.OCEAN_SHIPGRAVEYARD end},
		},

		set_pieces = {
			["ResurrectionStoneSw"] = { count=2, tasks={ "IslandParadise", "VerdantMost", "AllBeige", "NoGreen B", "Florida Timeshare","PiggyParadise","JungleDRockyland","JungleDRockyMarsh","JungleDSavRock","IslandJungleRockyDrop", } },
			--["ShipwreckedExit"] = { count=1, tasks={ "IslandParadise", "DesertIsland" } },
			--["RockSkull"] = { count=1, tasks={ "Cranium" } },

			["SWPortal"] = { count=1, tasks={ 
					"IslandParadise",
					"VerdantMost",
					"BeachJingleS",
					"BeachSavanna",
					"GreentipA",
					"GreentipB",
					"HalfGreen",
					"BeachRockyland",
					"LotsaGrass",
					"BeachJungleD",
					"AllBeige",
					"BeachMarsh",
					"Verdant",
					"Vert",
					"VerdantMost",
					"Florida Timeshare",
					"PiggyParadise",
					"BeachPalmForest",
					"IslandJungleShroomin",
					"IslandJungleNoFlowers", 
					"IslandBeachGrassy",
					"IslandBeachRocky",
					"IslandBeachSpider",
					"IslandBeachNoCrabbits",
					"JungleSRockyland",
					"JungleSSavanna",
					"JungleBeige",
					"Spiderland",
					"IslandJungleBamboozled",
					"IslandJungleNoBerry",
					"IslandBeachDunes",
					"IslandBeachSappy",
					"IslandBeachNoLimpets",
					"JungleDense",
					"JungleDMarsh",
					"JungleDRockyland",
					"JungleDRockyMarsh",
					"JungleDSavanna",
					"JungleDSavRock",
					"ThemeMarshCity",
					"IslandJungleCritterCrunch",
					"IslandRockyTallJungle",
					"IslandBeachNoFlowers",
					"NoGreen A",
					"HotNSticky",
					"Marshy",
					"Rockyland",
					"IslandJungleMonkeyHell",
					"IslandJungleSkeleton",
					"FullofBees",
					"IslandJungleRockyDrop",
					"IslandJungleEvilFlowers",
					"IslandBeachCrabTown",
					"IslandBeachForest",
					"IslandJungleNoRock",
					"IslandJungleNoMushroom",
					"NoGreen B",
					"Savanna",
					"IslandBeachLimpety",
					"IslandMeadowBees",
					"IslandRockyGold",
					"IslandRockyTallBeach",
					"IslandMeadowCarroty",
				} 
			},
		},

		numrandom_set_pieces = 0,
		random_set_pieces = {
		},

		water_prefill_setpieces = {
			["TeleportatoSwBaseLayout"] = {count = 1}
		},

		-- water_setpieces =
		-- {
		-- 	"WilburUnlock",
		-- },

		treasures = {
			["TestTreasure"] = { count = 1, treasuretasks = {"DesertIsland"}, maptasks = {"IslandParadise"}, tasks = {"IslandParadise"} },
		},

		numoptional_treasures = 0,
		optional_treasures = {
		},

		numrandom_treasures = 16,
		random_treasures = {
			"SeaPackageQuest",
			"PirateBank",
			"PiratePeanuts",
			"RandomGem",
			"DubloonsGem",
			"minerhat",
			"SuperTelescope",
			"ChickenOfTheSea",
			--"WoodlegsKey1",
			--"WoodlegsKey2",
			--"WoodlegsKey3",
			"BootyInDaBooty",
			"OneTrueEarring",
			"PegLeg",
			"VolcanoStaff",
			"Gladiator",
			"FancyHandyMan",
			"LobsterMan",
			"Compass",
			"Scientist",
			"Alchemist",
			"Shaman",
			"FireBrand",
			"SailorsDelight",
			"WarShip",
			"Desperado",
			"JewelThief",
			"AntiqueWarrior",
			"Yaar",
			"GdayMate",
			"ToxicAvenger",
			"MadBomber",
			"FancyAdventurer",
			"ThunderBall",
			"TombRaider",
			"SteamPunk",
			"CapNCrunch",
			"AyeAyeCapn",
			"BreakWind",
			"Diviner",
			"GoesComesAround",
			"GoldGoldGold",
			"FirePoker",
		},

		ordered_story_setpieces = {
			"TeleportatoSwRingLayout",
			"TeleportatoSwBoxLayout",
			"TeleportatoSwCrankLayout",
			"TeleportatoSwPotatoLayout",
			--"TeleportatoSwBaseLayout",
		},

		required_prefabs = 
		{
			"volcano", 
			"packim_fishbone", 
			"sharkittenspawner",
			"octopusking",
			"teleportato_sw_ring", 
			"teleportato_sw_box", 
			"teleportato_sw_crank", 
			"teleportato_sw_potato", 
			"teleportato_sw_base",
			"wilbur_unlock_marker",
			"portal_shipwrecked"
		},

		required_prefab_count = 
		{
			["doydoy"] = 2
		},

		required_treasures = {}
	})