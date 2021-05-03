
AddTask("SampleTask", { --Name to use in the 'tasks' or 'optionaltasks' list
		--This is the lock that require to use the task
		locks=LOCKS.NONE,

		--These are the key(s) given when the task is used. KEYS.ISLAND1 unlocks LOCK.ISLAND1
		keys_given={KEYS.ISLAND1},

		--This is used add links between biomes in an island which can make interesting shapes
		--0-1 seems to be a good amount
		crosslink_factor=math.random(0,1),

		--When an island is generated this gives a chance the island ends will be connected making
		--a round island and sometimes lagoons
		make_loop=math.random(0, 100) < 50,

		--The rooms (biomes) that the task (island) contains.
		--Rooms can be found in the map/rooms/ folder
		--Shipwrecked files: terrain_beach.lua, terrain_island.lua, terrain_jungle.lua, terrain_ocean.lua, terrain_swamp.lua
		--See map/rooms/terrain_jungle.lua for room info
		room_choices={
			--From terrain_jungle.lua, add 2 + 0 to 3 JungleClearing biomes to the island
			["JungleClearing"] = 2 + math.random(0, 3),

			--From terrain_savanna.lua, add 1 BareMangrove biome to the island
			["BareMangrove"] = 1,

			--From terrain_savanna.lua, add 3 + 0 to 3 Plain biomes to the island
			["Plain"] = 3 + math.random(0, 3),

			--From terrain_forest.lua, add 1 Clearing biome to the island
			["Clearing"] = 1,

			--From terrain_rocky.lua, add 1 + 0 to 3 Rocky biomes to the island
			["RockyIsland"] = 1 + math.random(0, 3),

			--From graveyard.lua, add 0 to 1 Graveyard biomes to the island
			["Graveyard"] = math.random(0, 1),

			--From terrain_jungle.lua, add 0 to 2 JungleDenseVery biomes to the island
			["JungleDenseVery"] = math.random(0, 2),

				--From terrain_jungle.lua, add 0 to 2 JungleDenseVery biomes to the island
			["BeachPalmForest"] = math.random(0, 2),
		},

		--This is a backup basically, a background room of just this tile type is added to the task
		--GROUND (tile types) are in constants.lua
		room_bg=GROUND.JUNGLE,

		--When background rooms are added (based on 'background_node_range' in survival.lua) rooms
		--from this list are randomly picked
		--background_room="BeachSand" --This form can be used for a single room
		background_room={"BeachSand", "BeachGravel", "BeachUnkept", "Jungle"},

		--Used for debug stuff
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("HomeIslandVerySmall", {
		locks=LOCKS.NONE,
		keys_given={KEYS.ISLAND1},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["JungleDenseMedHome"] = 1, -- + math.random(0, 2), --was 5+(0-2) --changed from JungleDense to remove monkeys
			["BeachSandHome"] = 2, --was 5
			--["BeachUnkept"] = 2, --was 3
			--["BGGrassIsland"] = 3,  --added this to try it out
			--["BG_Mangroves"] = 1,  --Savanna --was 3 Plain
			--["MagmaHome"] = 1,	--was 3		
		}, 
		room_bg=GROUND.JUNGLE,
		--background_room={"BeachSandHome", "BeachSandHome", "BeachSandHome", "BeachUnkept"}, --removed BeachUnkept, added unkept above
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("HomeIslandSmall", {
		locks=LOCKS.NONE,
		keys_given={KEYS.ISLAND1},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["JungleDenseMedHome"] = 2, -- + math.random(0, 2), --was 5+(0-2) --changed from JungleDense to remove monkeys
			--["BeachSandHome"] = 2, --was 5
			["BeachUnkept"] = 1, --was 3
			--["BGGrassIsland"] = 3,  --added this to try it out
			--["BG_Mangroves"] = 1,  --Savanna --was 3 Plain
			--["MagmaHome"] = 1,	--was 3		
		}, 
		room_bg=GROUND.JUNGLE,
		background_room={"BeachSandHome"}, --removed BeachUnkept, added unkept above
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("HomeIslandSmallBoon", {
		locks=LOCKS.NONE,
		keys_given={KEYS.ISLAND1},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["JungleDenseHome"] = 2, -- + math.random(0, 2), --was 5+(0-2)
			["JungleDenseMedHome"] = 1, -- + math.random(0, 2), --was 5+(0-2) --changed from JungleDense to remove monkeys
			["BeachSandHome"] = 1, --was 5
			["BeachUnkept"] = 1, --was 3
			--["BGGrassIsland"] = 3,  --added this to try it out
			--["NoOxMangrove"] = 1,  --Savanna --was 3 Plain
			--["MagmaHomeBoon"] = 1,	--was 3		
		}, 
		room_bg=GROUND.JUNGLE,
		background_room={"BeachSandHome"}, --removed BeachUnkept, added unkept above
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("HomeIslandSingleTree", {
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["OceanShallow"] = 1, -- was BeachSinglePalmTreeHome
		}, 
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("HomeIslandMed", {
		locks=LOCKS.NONE,
		keys_given={KEYS.ISLAND1},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["JungleDenseMedHome"] = 3 + math.random(0, 3), --was 5+(0-2) --changed from JungleDense to remove monkeys
			--["BeachSandHome"] = 2, --was 5
			["BeachUnkept"] = 1, --was 3
			--["BGGrassIsland"] = 3,  --added this to try it out
			--["NoOxMangrove"] = 2,  --Savanna --was 3 Plain
			--["MagmaHome"] = 1,	--was 3		
		}, 
		room_bg=GROUND.JUNGLE,
		background_room={"BeachSandHome"}, --removed beach unkept, added unkept above
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("HomeIslandLarge", {
		locks=LOCKS.NONE,
		keys_given={KEYS.ISLAND1},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["JungleDenseMedHome"] = 3 + math.random(0, 3), --was 5+(0-2) --changed from JungleDense to remove monkeys
			--["BeachSandHome"] = 2, --was 5
			["BeachUnkept"] = 2, --was 3
			--["BGGrassIsland"] = 3,  --added this to try it out
			--["NoOxMangrove"] = 2,  --Savanna --was 3 Plain
			--["MagmaHome"] = 2,	--was 3		
		}, 
		room_bg=GROUND.JUNGLE,
		background_room={"BeachSandHome"}, --removed BeachUnkept, added unkept above
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("HomeIslandLargeBoon", {
		locks=LOCKS.NONE,
		keys_given={KEYS.ISLAND1},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["JungleDenseMedHome"] = 3 + math.random(0, 3), --was 5+(0-2) --changed from JungleDense to remove monkeys
			--["BeachSandHome"] = 2, --was 5
			["BeachUnkept"] = 2, --was 3
			--["BGGrassIsland"] = 3,  --added this to try it out
			--["NoOxMangrove"] = 2,  --Savanna --was 3 Plain
			--["MagmaHomeBoon"] = 2,	--was 3		
		}, 
		room_bg=GROUND.JUNGLE,
		background_room={"BeachSandHome"}, --removed BeachUnkept, added unkept above
		colour={r=1,g=1,b=0,a=1}
	})
--[[
AddTask("LagoonTest", {
		locks=LOCKS.NONE,
		keys_given={KEYS.ISLAND1},
		gen_method = "lagoon",
		room_choices={
			{
				["OceanShallow"] = 2
			},
			{
				["BeachSand"] = 5,
			},
			{
				["JungleDense"] = 10,
			},
			{
				["BeachUnkept"] = 18 -- was 3*18
			}, 
		}, 
		room_bg=GROUND.JUNGLE,
		colour={r=1,g=1,b=0,a=1}
	})
]]
AddTask("DesertIsland", {
		locks=LOCKS.NONE,
		keys_given={KEYS.ISLAND1},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["BeachSand"] = 1 + math.random(0, 3),  --CM was 5 +
		}, 
		room_bg=GROUND.BEACH,
		background_room={"BeachSand", "BeachUnkept"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("VolcanoIsland", {
		locks=LOCKS.ISLAND4,
		keys_given={KEYS.NONE},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["VolcanoRock"] = 1,
			["MagmaVolcano"] = 1,
			["VolcanoObsidian"] = 1,
			["VolcanoObsidianBench"] = 1,
			["VolcanoAltar"] = 1,
			["VolcanoLava"] = 1
		}, 
		room_bg=GROUND.BEACH,
		background_room={"BeachSand", "BeachUnkept"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("JungleMarsh", {
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3},
		gen_method = "lagoon",
		room_choices={
			{
				["TidalMarsh"] = 2 --was 3
			},
			{
				["JungleDense"] = 6, --was 8
				["JungleDenseBerries"] = 2
			},
		}, 
		room_bg=GROUND.JUNGLE,
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("BeachJingleS", {
		locks=LOCKS.NONE,
		keys_given={KEYS.ISLAND1},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["JungleDenseMed"] = 3, -- MR went from 1-3
			["BeachUnkept"] = 1 -- MR went from 1-3
		}, 
		room_bg=GROUND.JUNGLE,
		background_room={"BeachSand", "BeachSand", "BeachSand", "BeachUnkept"},
		colour={r=1,g=1,b=0,a=1}
	})
	
AddTask("BeachBothJungles", {
		locks=LOCKS.NONE,
		keys_given={KEYS.ISLAND1},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["JungleDenseMed"] = 1, -- MR went from 1-3
			["JungleDense"] = 2, -- MR went from 1-2
			["BeachSand"] = 3 -- MR went from 1-4
		}, 
		room_bg=GROUND.JUNGLE,
		--background_room={"BeachSand", "BeachUnkept"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("BeachJungleD", {
		locks=LOCKS.ISLAND1,
		keys_given={KEYS.ISLAND2},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["JungleDense"] = 2, -- MR went from 1-2
			["BeachSand"] = 1 -- CM was 3
		}, 
		room_bg=GROUND.JUNGLE,
		background_room={"BeachSand", "BeachUnkept"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("BeachSavanna", {
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["BeachSand"] = 2, -- MR went from 2-4
			["NoOxMeadow"] = 2 -- MR went from 2-4 
		}, 
		room_bg=GROUND.BEACH,
		background_room={"BeachSand", "BeachUnkept"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("GreentipA", {
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["BeachSand"] = 2, -- MR went from 1-5
			["MeadowCarroty"] = 1, -- MR went from 1-3 Plain
			["JungleDenseMed"] = 3, -- MR went from 1-3
			["BeachUnkept"] = 1 --newly added to the mix
		}, 
		room_bg=GROUND.JUNGLE,
		--background_room={"BeachSand", "BeachUnkept"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("GreentipB", {
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["BeachSand"] = 1, -- MR went from 1-3
			["NoOxMangrove"] = 2, -- MR went from 1-4 Plain
			["JungleDense"] = 2 -- MR went from 1-3
		}, 
		room_bg=GROUND.JUNGLE,
		--background_room={"BeachSand", "BeachUnkept"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("HalfGreen", {
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["BeachSand"] = 3, -- MR went from 1-3
			["Mangrove"] = 1, -- MR went from 1-3
			["JungleDenseMed"] = 1, -- MR went from 1-2
			["NoOxMeadow"] = 1 -- MR went from 1-2
		}, 
		room_bg=GROUND.JUNGLE,
		background_room={"BeachSand", "BeachUnkept"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("BeachRockyland", {
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["BeachSand"] = 1, --CM was 3 -- MR went from 1-5
			["Magma"] = 1 --cm was 3 -- MR went from 1-3
		}, 
		room_bg=GROUND.BEACH,
		--background_room={"BeachSand", "BeachUnkept"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("LotsaGrass", {
		locks=LOCKS.ISLAND1,
		keys_given={KEYS.ISLAND2},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["NoOxMangrove"] = 1,
			["JungleDenseMed"] = 1,
			["NoOxMeadow"] = 2 -- was 1
		}, 
		room_bg=GROUND.JUNGLE,
		--background_room={"BeachSand", "JungleSparse"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("AllBeige", {
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["BeachSand"] = 1,
			["Magma"] = 1,
			["NoOxMangrove"] = 1
		}, 
		room_bg=GROUND.BEACH,
		background_room={"BeachSand", "BeachUnkept"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("BeachMarsh", {
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["BeachSand"] = 1,
			["TidalMarsh"] = 2 --was 1
		}, 
		room_bg=GROUND.BEACH,
		background_room={"BeachSand", "BeachUnkept"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("Verdant", {
		locks=LOCKS.ISLAND1,
		keys_given={KEYS.ISLAND2},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["BeachSand"] = 1,
			["BeachPiggy"] = 1,
			["JungleDenseMed"] = 1
		}, 
		room_bg=GROUND.JUNGLE,
		--background_room={"BeachSand", "BeachUnkept"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("VerdantMost", {
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["BeachSand"] = 1,
			["BeachSappy"] = 1,
			["JungleDenseMed"] = 1,
			["JungleDenseBerries"] = 1
		}, 
		room_bg=GROUND.JUNGLE,
		--background_room={"BeachSand", "BeachUnkept"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("Vert", {
		locks=LOCKS.ISLAND1,
		keys_given={KEYS.ISLAND2},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["BeachSand"] = 1,
			["MeadowCarroty"] = 1,
			["JungleDense"] = 1
		}, 
		room_bg=GROUND.JUNGLE,
		--background_room={"BeachSand", "BeachUnkept"},
		colour={r=1,g=1,b=0,a=1}
	})

--[[AddTask("JungleSparse", {
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND5},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["JungleDenseMed"] = 1
		}, 
		room_bg=GROUND.JUNGLE,
		background_room="JungleDenseMed",
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("JungleBoth", {
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["JungleSparse"] = 1,
			["JungleDense"] = 1
		}, 
		room_bg=GROUND.JUNGLE,
		background_room={"JungleSparse", "JungleDense"},
		colour={r=1,g=1,b=0,a=1}
	})
]]
AddTask("Florida Timeshare", {
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["TidalMarsh"] = 1,
			["JungleDenseMed"] = 1
		}, 
		room_bg=GROUND.JUNGLE,
		background_room={"BeachSand"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("JungleSRockyland", {
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3},
		gen_method = "lagoon", --was typical island 
		room_choices={
			{
				["JungleDenseMed"] = 2 --CM was 3 --was 1
			},
			{
				["Magma"] = 6 --CM was 8 --was 1
			},
		}, 
		--room_bg=GROUND.JUNGLE,
		--background_room="JungleSparse",
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("JungleSSavanna", {
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["BareMangrove"] = 1, --was Plain, BareMangrove includes Ox
			["JungleDenseMed"] = 1
		}, 
		room_bg=GROUND.JUNGLE,
		background_room={"JungleDenseMed", "NoOxMangrove"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("JungleBeige", {
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["BareMangrove"] = 1,
			["Magma"] = 1,
			["JungleDenseMed"] = 1
		}, 
		room_bg=GROUND.JUNGLE,
		--background_room={"JungleSparse", "NoOxMangrove"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("FullofBees", {
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["BeesBeach"] = 2,
			--["SavannaBees"] = 1, --was BareMangrove
			["JungleDense"] = 1 --was JungleSparse
		}, 
		room_bg=GROUND.JUNGLE,
		--background_room={"JungleBees", "SavannaBees"}, --was NoOxMangrove and JungleSparse
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("JungleDense", {------THIS IS A GOOD EXAMPLE OF THEMED ISLAND
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["TidalMarsh"] = 1,
			["JungleFlower"] = 1
		}, 
		room_bg=GROUND.JUNGLE,
		background_room="JungleDense",
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("JungleDMarsh", {
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["TidalMarsh"] = 1,
			["JungleDense"] = 1
		}, 
		room_bg=GROUND.JUNGLE,
		background_room={"JungleDenseMed", "TidalMermMarsh"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("JungleDRockyland", {
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		gen_method = "lagoon",
		room_choices={
			{
				["JungleDense"] = 2, --CM was 3
			},
			{
				["Magma"] = 4 --CM was 4 --+ math.random(0,1),
			},
		}, 
		--room_bg=GROUND.JUNGLE,
		--background_room={"JungleDense", "Magma"}, --added Magma here instead ((CM - this makes it so that maybe we won't end up with any rock areas on this island))
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("JungleDRockyMarsh", {
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		gen_method = "lagoon", -- normal gen
		room_choices={ -- included 1: Swamp, Magma, JungleDense
			{
				["TidalMarsh"] = 2 --CM was 3
			},
			{
				["JungleDense"] = 4, --CM was 8
				["Magma"] = 2
			},
		}, 
		--room_bg=GROUND.JUNGLE,
		--background_room={"JungleDense", "BeachSand"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("JungleDSavanna", {
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["BareMangrove"] = 1,
			["JungleDense"] = 1
		}, 
		room_bg=GROUND.JUNGLE,
		background_room={"JungleDense", "NoOxMangrove"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("JungleDSavRock", {
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["BareMangrove"] = 1,
			["Magma"] = 1,
			["JungleDense"] = 1
		}, 
		room_bg=GROUND.JUNGLE,
		--background_room={"JungleDense"}, --"NoOxMangrove",
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("HotNSticky", {  
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["TidalMarsh"] = 2,
			["JungleDenseMed"] = 1,
			["JungleDense"] = 1
		}, 
		room_bg=GROUND.JUNGLE,
		--background_room={"JungleDense", "TidalMarsh"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("Marshy", { -- not being called
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["TidalMarsh"] = 1,
			["TidalMermMarsh"] = 1
		}, 
		room_bg=GROUND.JUNGLE,
		--background_room="TidalMarsh",
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("NoGreen A", {
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["TidalMarsh"] = 1,
			["Magma"] = 1
		}, 
		room_bg=GROUND.JUNGLE,
		background_room={"Magma", "TidalMarsh"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("NoGreen B", {
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["ToxicTidalMarsh"] = 2,
			["Magma"] = 1,
			["BareMangrove"] = 1
		}, 
		room_bg=GROUND.JUNGLE,
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("Savanna", {
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["BeachUnkept"] = 1, --CM was + math.random(0, 2), was BeachGravel
			["BareMangrove"] = 1 --CM was 5 -- MR went from 1-5
		}, 
		room_bg=GROUND.JUNGLE,
		background_room="BeachNoCrabbits",
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("Rockyland", {
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["Magma"] = 2, --was 1
			["ToxicTidalMarsh"] = math.random(0, 1),
		}, 
		room_bg=GROUND.JUNGLE,
		background_room={"BeachUnkept"}, --was BeachGravel
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("PalmTreeIsland", {
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=1,
		make_loop=true,
		room_choices={
			["BeachSinglePalmTree"] = 1, -- MR went from 1-5
			["OceanShallowSeaweedBed"] = 1,
			["OceanShallow"] = 1, --CM was 4
		}, 
		room_bg=GROUND.OCEAN_SHALLOW,
		background_room="OceanShallow",
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("DoydoyIslandGirl", {
		locks=LOCKS.ISLAND4,
		keys_given={KEYS.NONE},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
				["JungleSparse"] = 2, --CM was 2
		}, 
		set_pieces={
			{name="DoydoyGirl"}
		},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("DoydoyIslandBoy", {
		locks=LOCKS.ISLAND4,
		keys_given={KEYS.NONE},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
				["JungleSparse"] = 2, --CM was 2
		},
		set_pieces={
			{name="DoydoyBoy"}
		},
		--room_bg=GROUND.OCEAN_SHALLOW,
		--background_room="OceanShallow",
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("IslandCasino", {
		locks=LOCKS.ISLAND4,
		keys_given={KEYS.ISLAND5},
		crosslink_factor=1, --math.random(0,1),
		make_loop=true, --math.random(0, 100) < 50,
		room_choices={
			["BeachPalmCasino"] = 1, -- MR went from 1-5
			["Mangrove"] = math.random(1, 2)
		}, 
		set_pieces={
			{name="Casino"}
		},
		room_bg=GROUND.OCEAN_SHALLOW,
		background_room="OceanShallow",
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("KelpForest", {
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=1,
		make_loop=true,
		room_choices={
			["OceanMediumSeaweedBed"] = math.random(1, 3), --CM was 2, 5
		},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("GreatShoal", {
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=1,
		make_loop=true,
		room_choices={
			["OceanMediumShoal"] = math.random(1, 3), --CM was 2, 5
		},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("BarrierReef", {
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=0,
		make_loop=false,
		room_choices={
			["OceanCoral"] = math.random(1, 3), --CM was 2, 5
		},
		colour={r=1,g=1,b=0,a=1}
	})

--Test tasks ================================================================================================================================================================
AddTask("IslandParadise", {
		locks=LOCKS.NONE,
		keys_given={KEYS.PICKAXE,KEYS.AXE,KEYS.GRASS,KEYS.WOOD,KEYS.TIER1,KEYS.ISLAND1},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["BeachSand"] = 1, --CM + math.random(0, 2),
			["Jungle"] = 2, --CM + math.random(0, 1),
			["MeadowMandrake"] = 1,
			["Magma"] = 1, --CM + math.random(0, 1),
			["JungleDenseVery"] = math.random(0, 1),
			["BareMangrove"] = 1,
		}, 
		room_bg=GROUND.BEACH,
		--background_room={"BeachSand", "BeachGravel", "BeachUnkept", "Jungle"},
		colour={r=1,g=1,b=0,a=1}
	})

--[[AddTask("ThemePigIsland", {
		locks=LOCKS.ISLAND4,
		keys_given={KEYS.NONE},
		gen_method = "lagoon",
		room_choices={
			{
				["JunglePigs"] = 1, 
				["JungleDenseMed"] = 2
			},
			{
				["JunglePigGuards"] = 5 + math.random(0, 3), --was 5 +
			},
		},
		set_pieces={
			{name="DefaultPigking"}
		},
		--room_bg=GROUND.IMPASSABLE,
		--background_room="BGImpassable",
		room_bg=GROUND.TIDALMARSH,
		background_room={"BeachSand","BeachPiggy","BeachPiggy","BeachPiggy","TidalMarsh"},
		colour={r=0.5,g=0,b=1,a=1}
	})
]]
AddTask("PiggyParadise", {
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3,KEYS.ISLAND4},
		gen_method = "lagoon",
		room_choices={
			{
				["JungleDenseBerries"] = 3, 
			},
			{
				["BeachPiggy"] = 5 + math.random(1, 3),
			},
		},
		--[[set_pieces={
			{name="DefaultPigking"}
		},]]
		--room_bg=GROUND.IMPASSABLE,
		--background_room="BGImpassable",
		room_bg=GROUND.TIDALMARSH,
		background_room={"BeachSand","BeachPiggy","BeachPiggy","BeachPiggy","TidalMarsh"},
		colour={r=0.5,g=0,b=1,a=1}
	})

AddTask("BeachPalmForest", {
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3,KEYS.ISLAND4},
		--entrance_room = "ForceDisconnectedRoom",
		room_choices={
			["BeachPalmForest"] = 1 + math.random(0, 3),
		}, 
		--room_bg=GROUND.IMPASSABLE,
		--background_room="BGImpassable",
		room_bg=GROUND.TIDALMARSH,
		background_room="OceanShallow",
		colour={r=0.5,g=0,b=1,a=1}
	})

AddTask("ThemeMarshCity", {
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		--entrance_room = "ForceDisconnectedRoom",
		room_choices={
			["TidalMermMarsh"] = 1 + math.random(0, 1),
			["ToxicTidalMarsh"] = 1 + math.random(0, 1),
			["JungleSpidersDense"] = 1, --CM was 3,
		}, 
		--room_bg=GROUND.IMPASSABLE,
		--background_room="BGImpassable",
		room_bg=GROUND.TIDALMARSH,
		--background_room={"BeachSand","BeachPiggy","TidalMarsh"},
		colour={r=0.5,g=0,b=1,a=1}
	})

AddTask("Spiderland", {
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["MagmaSpiders"] = 1,
			["JungleSpidersDense"] = 2,
			["JungleSpiderCity"] = 1 --need to make this jungly instead of using basegame trees and ground
		}, 
		room_bg=GROUND.JUNGLE,
		--background_room={"BeachGravel"}, --removed MagmaSpiders
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("IslandJungleBamboozled", {  
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["JungleBamboozled"] = 1 + math.random(0,1), -- added the random bonus room
		}, 
		room_bg=GROUND.JUNGLE,
		background_room={"OceanShallow"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("IslandJungleMonkeyHell", {  
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["JungleMonkeyHell"] = 3,
			--["JungleDenseBerries"] =1,
			--["JungleDenseMedHome"] =1,
		}, 
		room_bg=GROUND.JUNGLE,
		--background_room={"Jungle"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("IslandJungleCritterCrunch", {  
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["JungleCritterCrunch"] = 2,
			["JungleDenseCritterCrunch"] = 1,
			--["Jungle"] = 1,
		}, 
		room_bg=GROUND.JUNGLE,
		--background_room={"JungleDenseCritterCrunch"},
		colour={r=1,g=1,b=0,a=1}
	})

--[[AddTask("IslandMagmaJungle", {  
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["MagmaForest"] = 1,
			--["JungleClearing"] = 1,
			["Jungle"] = 1,
		}, 
		room_bg=GROUND.JUNGLE,
		--background_room={"JungleClearing"},
		colour={r=1,g=1,b=0,a=1}
	})
]]
AddTask("IslandJungleShroomin", {  
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["JungleShroomin"] = 2,
			--["JungleDenseMed"] = 1,
			--["Jungle"] = 1,
		}, 
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("IslandJungleRockyDrop", {  
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		gen_method = "lagoon",
		room_choices={
			{
				["MagmaSpiders"] = 2 --CM was 3
			},
			{
				["JungleRockyDrop"] = 4, --CM was 8
				["Jungle"] = 2
			},
		}, 
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("IslandJungleEyePlant", {  
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["JungleEyeplant"] = 1,
			["TidalMarsh"] = 1,
			--["JungleDense"] = 1,
		}, 
		room_bg=GROUND.JUNGLE,
		background_room={"JungleDenseMedHome"},
		colour={r=1,g=1,b=0,a=1}
	})

--[[AddTask("IslandJungleGrassy", {  
		locks=LOCKS.ISLAND1,
		keys_given={KEYS.ISLAND2},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["JungleGrassy"] = 1,
			["JungleDenseBerries"] = 1,
			["Jungle"] = 1,
		}, 
		room_bg=GROUND.JUNGLE,
		--background_room={"JungleClearing", "JungleDense"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("IslandJungleSappy", {  
		locks=LOCKS.ISLAND1,
		keys_given={KEYS.ISLAND2},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["JungleSappy"] = 1,
			["JungleDenseMedHome"] = 1,
			["JungleDenseVery"] = 1,
		}, 
		room_bg=GROUND.JUNGLE,
		--background_room={"JungleClearing", "Jungle"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("IslandJungleNoGrass", {  
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["JungleNoGrass"] = 2, --CM + math.random(0, 3),
			--["Jungle"] = 1,
		}, 
		room_bg=GROUND.JUNGLE,
		--background_room={"JungleSparseHome", "JungleDenseMed"},
		colour={r=1,g=1,b=0,a=1}
	}) ]]

AddTask("IslandJungleBerries", {  
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["JungleDenseBerries"] = 4,
		}, 
		room_bg=GROUND.JUNGLE,
		--background_room={"JungleSparse", "Jungle"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("IslandJungleNoBerry", {  
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["JungleNoBerry"] = 3,
			--[[ ["Jungle"] = 1,
			["JungleDenseVery"] = 1, ]]
		}, 
		room_bg=GROUND.JUNGLE,
		--background_room={"JungleSparse", "Jungle"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("IslandJungleNoRock", {  
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["JungleNoRock"] = 1,
			--["JungleEyeplant"] = 1,
			["TidalMarsh"] = 1,
		}, 
		room_bg=GROUND.JUNGLE,
		--background_room={"JungleDenseMed", "JungleDense"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("IslandJungleNoMushroom", {  
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["JungleNoMushroom"] = 1,
			--["Jungle"] = 1,
		}, 
		room_bg=GROUND.JUNGLE,
		background_room={"JungleNoMushroom"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("IslandJungleNoFlowers", {  
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["JungleNoFlowers"] = math.random(3,5),
			--["JungleDenseMedHome"] = 1,
		}, 
		room_bg=GROUND.JUNGLE,
		--background_room={"Jungle", "JungleDense"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("IslandJungleEvilFlowers", {  
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["JungleEvilFlowers"] = 2,
			["ToxicTidalMarsh"] = 1,
		}, 
		room_bg=GROUND.JUNGLE,
		--background_room={"JungleDenseMed", "JungleClearing"},
		colour={r=1,g=1,b=0,a=1}
	})

--[[AddTask("IslandJungleMorePalms", {  
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["JungleMorePalms"] = math.random(2,3),
			--["JungleDense"] = 1,
			--["JungleDenseBerries"] = 1,
		}, 
		room_bg=GROUND.JUNGLE,
		--background_room={"JungleSparse", "JungleDense"},
		colour={r=1,g=1,b=0,a=1}
	}) ]]

AddTask("IslandJungleSkeleton", {  
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["JungleSkeleton"] = 1,
			["JungleDenseMedHome"] = 1,
			["TidalMermMarsh"] = 1,
		}, 
		room_bg=GROUND.JUNGLE,
		background_room={"Jungle", "JungleDense"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("IslandBeachCrabTown", {  
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["BeachCrabTown"] = math.random(1,3),
		}, 
		room_bg=GROUND.BEACH,
		--background_room={"BeachSand"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("IslandBeachDunes", {  
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["BeachDunes"] = 1,
			["BeachUnkept"] = 1,
			-- ["BeachSinglePalmTree"] = 1,
		}, 
		room_bg=GROUND.BEACH,
		background_room={"BeachSand", "BeachUnkept"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("IslandBeachGrassy", {  
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["BeachGrassy"] = 1,
			["BeachPalmForest"]=1,
			["BeachSandHome"]=1,
		}, 
		room_bg=GROUND.BEACH,
		--background_room={"BeachUnkept", "BeachGravel"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("IslandBeachSappy", {  
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["BeachSappy"] = 1,
			["BeachSand"] = 1,
			["BeachUnkept"] = 1, --was BeachGravel
		}, 
		room_bg=GROUND.BEACH,
		--background_room={"BeachSandHome", "BeachSappy"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("IslandBeachRocky", {  
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["BeachRocky"] = 1,
			--["BeachGravel"] = 1,
			["BeachUnkept"] = 1,
			["BeachSandHome"] = 1,
		}, 
		room_bg=GROUND.BEACH,
		--background_room={"BeachUnkept", "BeachSandHome"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("IslandBeachLimpety", {  
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["BeachLimpety"] = 1,
			["BeachSand"] = 1,
		}, 
		room_bg=GROUND.BEACH,
		background_room={"BeachSand", "BeachUnkept"}, --was BeachGravel instead of Unkept
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("IslandBeachForest", {  
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["BeachPalmForest"] = 1,
			["BeachSandHome"] = 1,
			-- ["BeachSinglePalmTree"] = 1,
		}, 
		room_bg=GROUND.BEACH,
		background_room={"BeachUnkept", "BeachSandHome"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("IslandBeachSpider", {  
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["BeachSpider"] = 2,
			--["BeachUnkept"] = 1,
		}, 
		room_bg=GROUND.BEACH,
		background_room={"BeachSand", "BeachUnkept"}, --was BeachGravel instead of Unkept
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("IslandBeachNoFlowers", {  
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["BeachNoFlowers"] = 1,
			["BeachUnkept"] = 1, --was BeachGravel
		}, 
		room_bg=GROUND.BEACH,
		--background_room={"BeachSand"},
		colour={r=1,g=1,b=0,a=1}
	})

--[[AddTask("IslandBeachFlowers", {  
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["BeachFlowers"] = 1,
			--["BeachSandHome"] = 1,
		}, 
		room_bg=GROUND.BEACH,
		background_room={"BeachSandHome", "BeachSand"}, --removed BeachGravel
		colour={r=1,g=1,b=0,a=1}
	}) ]]

AddTask("IslandBeachNoLimpets", {  
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["BeachNoLimpets"] = 1,
		}, 
		room_bg=GROUND.BEACH,
		background_room={"BeachSand"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("IslandBeachNoCrabbits", {  
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["BeachNoCrabbits"] = 2,
			--["BeachSinglePalmTree"] = 1, -- this leaves a lot of empty space possibly the size of a whole screen
			--["BeachSandHome"] = 1,
		}, 
		room_bg=GROUND.BEACH,
		background_room={"BeachUnkept", "BeachUnkept"}, --was BeachGravel instead of Unkept
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("IslandMangroveOxBoon", {  
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["MangroveOxBoon"] = 1,
			["MangroveWetlands"] = 1,
			["JungleNoRock"] = 1,
		}, 
		room_bg=GROUND.MANGROVE,
		--background_room={"BeachSandHome", "BeachGravel"},
		colour={r=1,g=1,b=0,a=1}
	})

--[[AddTask("IslandMeadowWetlands", {  
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["MeadowWetlands"] = 2,
			["BG_Mangrove"] = 1,
			["BareMangrove"] = 1,
			--["NoOxMangrove"] = 1,
		}, 
		room_bg=GROUND.MANGROVE,
		--background_room={"BareMangrove", "Plain"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("IslandSavannaFlowery", {  
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["SavannaFlowery"] = 2,
			--["BG_Mangroves"] = 1,
			--["Plain"] = 1,
		}, 
		room_bg=GROUND.MANGROVE,
		--background_room={"BG_Mangroves", "BareMangrove"},
		colour={r=1,g=1,b=0,a=1}
	})
]]
AddTask("IslandMeadowBees", {  
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["MeadowBees"] = 1,
			["NoOxMeadow"] = 1,
		}, 
		room_bg=GROUND.MANGROVE,
		background_room={"NoOxMeadow"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("IslandMeadowCarroty", {  
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["MeadowCarroty"] = 1,
			["NoOxMeadow"] = 1,
		}, 
		room_bg=GROUND.MANGROVE,
		--background_room={"Plain", "BareMangrove"},
		colour={r=1,g=1,b=0,a=1}
	})

--[[AddTask("IslandSavannaSappy", {  
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["SavannaSappy"] = 1,
			--["BareMangrove"] = 1,
			--["BG_Mangroves"] = 1,
		}, 
		room_bg=GROUND.MANGROVE,
		background_room={"SavannaSappy", "SavannaSappy", "SavannaSappy", "BareMangrove", "BeachSappy", "BeachUnkept"}, --was BeachGravel instead of Unkept
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("IslandSavannaSpider", {  
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["SavannaSpider"] = 3,
			--["BareMangrove"] = 1,
			--["NoOxMangrove"] = 1,
			--["Plain"] = 1,
		}, 
		room_bg=GROUND.MANGROVE,
		--background_room={"NoOxMangrove", "BG_Mangroves"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("IslandSavannaRocky", {  
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		gen_method = "lagoon",
		room_choices={
			{
				["SavannaRocky"] = 2
			},
			{
				["BeachRocky"] = 3,  --CM was 4
				["BeachSand"] = 3 --CM was 4
			},
		}, 
		room_bg=GROUND.MANGROVE,
		--background_room={"BareMangrove", "Plain"},
		colour={r=1,g=1,b=0,a=1}
	}) ]]

AddTask("IslandRockyGold", {  
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["MagmaGoldBoon"] = 1,
			["MagmaGold"] = 1,
			["BeachSandHome"] = 1,
		}, 
		room_bg=GROUND.BEACH ,
		--background_room={"BeachSand", "BeachUnkept"},
		colour={r=1,g=1,b=0,a=1}
	})

--[[AddTask("IslandRockyBlueMushroom", {  
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["RockyBlueMushroom"] = 1,
			["MolesvilleRockyIsland"] = 1,
			["BeachSand"] = 1,
		}, 
		room_bg=GROUND.BEACH ,
		--background_room={"BeachGravel", "BeachUnkept"},
		colour={r=1,g=1,b=0,a=1}
	}) ]]

AddTask("IslandRockyTallBeach", {  
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["MagmaTallBird"] = 1,
			["GenericMagmaNoThreat"] = 1,
			["BeachUnkept"] = 1, --was BeachGravel
		}, 
		room_bg=GROUND.BEACH ,
		--background_room={"BeachSand", "BeachUnkept"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("IslandRockyTallJungle", {  
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["MagmaTallBird"] = 1,
			["BG_Magma"] = 1,
			["JungleDenseMed"] = 1,
		}, 
		room_bg=GROUND.JUNGLE ,
		--background_room={"JungleSparseHome", "JungleDense"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("Chess", {
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["MarbleForest"] = 1,
			["ChessArea"] = 1,
			--["ChessMarsh"] = 1,
			--["ChessForest"] = 1,
		},
		colour={r=0.5,g=0.7,b=0.5,a=0.3},						
	})

--[[AddTask("IslandGravy", {  
		locks=LOCKS.ISLAND3,
		keys_given={KEYS.ISLAND4},
		gen_method = "lagoon",
		room_choices={
			{
				["SW_Graveyard"] = 2  --CM was 3
			},
			{
				["JungleDenseMed"] = 3, --CM was 8
				["Jungle"] = 2
			},
		}, 
		room_bg=GROUND.JUNGLE ,
		--background_room={"JungleSparseHome", "JungleDense"},
		colour={r=1,g=1,b=0,a=1}
	}) ]]

AddTask("PirateBounty", {
		locks=LOCKS.ISLAND4,
		keys_given={KEYS.ISLAND5},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["BeachUnkeptDubloon"] = 1,
		},
		set_pieces={
			{name="Xspot"}
		},
		room_bg=GROUND.BEACH ,
		--background_room={"OceanShallowSeaweedBed"}, --removed "OceanShallowReef"
		colour={r=0.5,g=0.7,b=0.5,a=0.3},						
	})

AddTask("IslandOasis", {
		locks=LOCKS.ISLAND4,
		keys_given={KEYS.ISLAND5},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["Jungle"] = 1,
		},
		set_pieces={
			{name="JungleOasis"}
		},
		room_bg=GROUND.BEACH ,
		--background_room={"OceanShallowSeaweedBed"}, --removed "OceanShallowReef"
		colour={r=0.5,g=0.7,b=0.5,a=0.3},						
	})

AddTask("ShellingOut", {
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3, KEYS.ISLAND4},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["BeachShells"] = 2,
		},
		room_bg=GROUND.BEACH ,
		background_room={"OceanShallow"}, --removed "OceanShallowReef"
		colour={r=0.5,g=0.7,b=0.5,a=0.3},						
	})

AddTask("Cranium", {
		locks=LOCKS.ISLAND4,
		keys_given={KEYS.ISLAND5},
		gen_method = "lagoon",
		room_choices={
			{
				["BeachSkull"] = 1,
			},
			{
				["Jungle"] = 6,
			},
		},
		--[[treasures = { 
			{name="DeadmansTreasure"} 
		},]]
		room_bg=GROUND.BEACH,
		--background_room={"BeachSand", "BeachUnkept"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("CrashZone", {
		locks=LOCKS.ISLAND2,
		keys_given={KEYS.ISLAND3},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["Jungle"] = 2,
			["MagmaForest"] = 1,
		}, 
		room_bg=GROUND.BEACH,
		--background_room={"BeachSand", "BeachUnkept"},
		colour={r=1,g=1,b=0,a=1}
	})

AddTask("SharkHome", {
		locks=LOCKS.ISLAND4,
		keys_given={KEYS.ISLAND5},
		crosslink_factor=math.random(0,1),
		make_loop=math.random(0, 100) < 50,
		room_choices={
			["BeachSand"] = 1,
		},
		set_pieces={
			{name="SharkHome"}
		},
		room_bg=GROUND.BEACH ,
		--background_room={"OceanShallowSeaweedBed"}, --removed "OceanShallowReef"
		colour={r=0.5,g=0.7,b=0.5,a=0.3},						
	})