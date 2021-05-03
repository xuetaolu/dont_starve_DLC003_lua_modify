require "recipe"
require "recipecategory"
require "tuning"

local mergedGameTypes = {RECIPE_GAME_TYPE.VANILLA,RECIPE_GAME_TYPE.SHIPWRECKED,RECIPE_GAME_TYPE.PORKLAND}
local cityRecipeGameTypes = RECIPE_GAME_TYPE.COMMON
--Note: If you want to add a new tech tree you must also add it into the "TECH" constant in constants.lua

--LIGHT
Recipe("campfire", {Ingredient("cutgrass", 3),  Ingredient("log", 2)}, RECIPETABS.LIGHT, TECH.NONE, RECIPE_GAME_TYPE.COMMON, "campfire_placer")
Recipe("firepit",  {Ingredient("log", 2),	    Ingredient("rocks", 12)}, RECIPETABS.LIGHT, TECH.NONE, RECIPE_GAME_TYPE.COMMON, "firepit_placer")
Recipe("chiminea", {Ingredient("limestone", 2), Ingredient("sand", 2), Ingredient("log", 2)}, RECIPETABS.LIGHT, TECH.NONE, RECIPE_GAME_TYPE.SHIPWRECKED, "chiminea_placer")
Recipe("torch",    {Ingredient("cutgrass", 2),  Ingredient("twigs", 2)}, RECIPETABS.LIGHT, TECH.NONE)
Recipe("tarlamp",  {Ingredient("seashell", 1),  Ingredient("tar", 1)}, RECIPETABS.LIGHT, TECH.NONE, RECIPE_GAME_TYPE.SHIPWRECKED)

Recipe("coldfire", {Ingredient("cutgrass", 3), Ingredient("nitre", 2)}, RECIPETABS.LIGHT, TECH.SCIENCE_ONE, {RECIPE_GAME_TYPE.VANILLA,RECIPE_GAME_TYPE.ROG,RECIPE_GAME_TYPE.SHIPWRECKED}, "coldfire_placer")
Recipe("coldfirepit", {Ingredient("nitre", 2), Ingredient("cutstone", 4), Ingredient("transistor", 2)}, RECIPETABS.LIGHT, TECH.SCIENCE_TWO, {RECIPE_GAME_TYPE.VANILLA,RECIPE_GAME_TYPE.ROG,RECIPE_GAME_TYPE.SHIPWRECKED}, "coldfirepit_placer")
Recipe("obsidianfirepit", {Ingredient("log", 3),Ingredient("obsidian", 8)}, RECIPETABS.LIGHT, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.SHIPWRECKED, "obsidianfirepit_placer")

Recipe("candlehat", {Ingredient("cork", 4),Ingredient("iron", 2)}, RECIPETABS.LIGHT, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.PORKLAND)
Recipe("minerhat", {Ingredient("strawhat", 1),Ingredient("goldnugget", 1),Ingredient("fireflies", 1)}, RECIPETABS.LIGHT, TECH.SCIENCE_TWO)

Recipe("bottlelantern", {Ingredient("messagebottleempty", 1), Ingredient("bioluminescence", 2)}, RECIPETABS.LIGHT, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("boat_torch", {Ingredient("twigs", 2), Ingredient("torch", 1)}, RECIPETABS.LIGHT, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("boat_lantern", {Ingredient("messagebottleempty", 1), Ingredient("twigs", 2), Ingredient("fireflies", 1)}, RECIPETABS.LIGHT, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("sea_chiminea", {Ingredient("sand", 4), Ingredient("tar", 6), Ingredient("limestone", 6)}, RECIPETABS.LIGHT, TECH.NONE, RECIPE_GAME_TYPE.SHIPWRECKED, "sea_chiminea_placer", nil, nil, nil, true)

-- ROG
Recipe("molehat", {Ingredient("mole", 2), Ingredient("transistor", 2), Ingredient("wormlight", 1)}, RECIPETABS.LIGHT,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.ROG)
Recipe("bathat", {Ingredient("pigskin", 2),Ingredient("batwing", 1), Ingredient("compass", 1)}, RECIPETABS.LIGHT,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.PORKLAND)
Recipe("pumpkin_lantern", {Ingredient("pumpkin", 1), Ingredient("fireflies", 1)}, RECIPETABS.LIGHT, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.VANILLA)
Recipe("lantern", {Ingredient("twigs", 3), Ingredient("rope", 2), Ingredient("lightbulb", 2)}, RECIPETABS.LIGHT, TECH.SCIENCE_TWO, {RECIPE_GAME_TYPE.VANILLA,RECIPE_GAME_TYPE.PORKLAND})

--STRUCTURES
Recipe("treasurechest", {Ingredient("boards", 3)}, RECIPETABS.TOWN, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.COMMON, "treasurechest_placer",1)
Recipe("waterchest", {Ingredient("tar", 1), Ingredient("boards", 4)}, RECIPETABS.TOWN, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED, "waterchest_placer", 1, nil, nil, true)
Recipe("corkchest", {Ingredient("cork", 2), Ingredient("rope", 1)}, RECIPETABS.TOWN, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.PORKLAND, "corkchest_placer", 1)
Recipe("homesign", {Ingredient("boards", 1)}, RECIPETABS.TOWN, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.COMMON, "homesign_placer")
Recipe("minisign_item", {Ingredient("boards", 1)}, RECIPETABS.TOWN, TECH.SCIENCE_ONE, nil, nil, nil, nil, 4)

Recipe("fence_gate_item", {Ingredient("boards", 2), Ingredient("rope", 1) }, RECIPETABS.TOWN, TECH.SCIENCE_TWO,nil,nil,nil,nil,1)
Recipe("fence_item", {Ingredient("twigs", 3), Ingredient("rope", 1) }, RECIPETABS.TOWN, TECH.SCIENCE_ONE, nil,nil,nil,nil,6)

Recipe("wall_hay_item", {Ingredient("cutgrass", 4), Ingredient("twigs", 2) }, RECIPETABS.TOWN, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.COMMON, nil,nil,nil,4)
Recipe("wall_wood_item", {Ingredient("boards", 2),Ingredient("rope", 1)}, RECIPETABS.TOWN,  TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.COMMON, nil,nil,nil,8)
Recipe("wall_stone_item", {Ingredient("cutstone", 2)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.COMMON, nil,nil,nil,6)
Recipe("wall_limestone_item", {Ingredient("limestone", 2)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.SHIPWRECKED, nil,nil,nil,6)
Recipe("wall_enforcedlimestone_item", {Ingredient("limestone", 2), Ingredient("seaweed", 4)}, RECIPETABS.TOWN, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED, nil,nil,nil,6)
Recipe("pighouse", {Ingredient("boards", 4), Ingredient("cutstone", 3), Ingredient("pigskin", 4)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.VANILLA, "pighouse_placer")
Recipe("wildborehouse", {Ingredient("bamboo", 8), Ingredient("palmleaf", 5), Ingredient("pigskin", 4)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.SHIPWRECKED, "wildborehouse_placer")
--Recipe("monkeybarrel", {Ingredient("twigs", 10), Ingredient("cave_banana", 3), Ingredient("poop", 4)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.SHIPWRECKED, "monkeybarrel_placer")
Recipe("ballphinhouse", {Ingredient("limestone", 4), Ingredient("seaweed", 4), Ingredient("dorsalfin", 2)}, RECIPETABS.TOWN, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED, "ballphinhouse_placer", 100, nil, nil, true)
Recipe("primeapebarrel", {Ingredient("twigs", 10), Ingredient("cave_banana", 3), Ingredient("poop", 4)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.SHIPWRECKED, "primeapebarrel_placer")
Recipe("dragoonden", {Ingredient("dragoonheart", 1), Ingredient("rocks", 5), Ingredient("obsidian", 4)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.SHIPWRECKED, "dragoonden_placer")
Recipe("rabbithouse", {Ingredient("boards", 4), Ingredient("carrot", 10), Ingredient("manrabbit_tail", 4)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.VANILLA, "rabbithouse_placer")
Recipe("birdcage", {Ingredient("papyrus", 2), Ingredient("goldnugget", 6), Ingredient("seeds", 2)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.COMMON, "birdcage_placer")

Recipe("turf_road", {Ingredient("turf_rocky", 1), Ingredient("boards", 1)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, {RECIPE_GAME_TYPE.VANILLA,RECIPE_GAME_TYPE.PORKLAND})
Recipe("turf_road", {Ingredient("turf_magmafield", 1), Ingredient("boards", 1)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("turf_woodfloor", {Ingredient("boards", 1)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO)

Recipe("turf_checkerfloor", {Ingredient("marble", 1)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, {RECIPE_GAME_TYPE.VANILLA,RECIPE_GAME_TYPE.PORKLAND})
Recipe("turf_carpetfloor", {Ingredient("boards", 1), Ingredient("beefalowool", 1)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, {RECIPE_GAME_TYPE.VANILLA,RECIPE_GAME_TYPE.PORKLAND})
Recipe("turf_snakeskinfloor", {Ingredient("snakeskin", 2), Ingredient("fabric", 1)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, {RECIPE_GAME_TYPE.SHIPWRECKED})

Recipe("turf_beard_hair", {Ingredient("beardhair", 1), Ingredient("cutgrass", 1)}, RECIPETABS.TOWN, TECH.SCIENCE_ONE, {RECIPE_GAME_TYPE.PORKLAND})

Recipe("turf_lawn", {Ingredient("cutgrass", 2), Ingredient("nitre", 1)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.PORKLAND)
Recipe("turf_fields", {Ingredient("turf_rainforest", 1), Ingredient("ash", 1)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.PORKLAND)
Recipe("turf_deeprainforest_nocanopy", {Ingredient("bramble_bulb", 1), Ingredient("cutgrass", 2), Ingredient("ash", 1)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.PORKLAND)

Recipe("pottedfern", {Ingredient("foliage", 5), Ingredient("slurtle_shellpieces",1 )}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.VANILLA, "pottedfern_placer", 0.9)
Recipe("sandbagsmall_item", {Ingredient("fabric", 2), Ingredient("sand", 3)}, RECIPETABS.TOWN, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED, nil,nil,nil,4)
Recipe("sand_castle", {Ingredient("sand", 4), Ingredient("palmleaf", 2), Ingredient("seashell", 3)}, RECIPETABS.TOWN,  TECH.NONE, RECIPE_GAME_TYPE.SHIPWRECKED, "sandcastle_placer")
Recipe("dragonflychest", {Ingredient("dragon_scales", 1), Ingredient("boards", 4), Ingredient("goldnugget", 10)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.ROG, "dragonflychest_placer", 1.5)

--FARM
Recipe("mussel_stick", {Ingredient("bamboo", 2), Ingredient("vine", 1), Ingredient("seaweed", 1)}, RECIPETABS.FARM,  TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("slow_farmplot", {Ingredient("cutgrass", 8),Ingredient("poop", 4),Ingredient("log", 4)}, RECIPETABS.FARM,  TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.COMMON, "slow_farmplot_placer")
Recipe("fast_farmplot", {Ingredient("cutgrass", 10),Ingredient("poop", 6),Ingredient("rocks", 4)}, RECIPETABS.FARM,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.COMMON, "fast_farmplot_placer")
Recipe("fertilizer", {Ingredient("poop",3), Ingredient("boneshard", 2), Ingredient("log", 4)}, RECIPETABS.FARM, TECH.SCIENCE_TWO)
Recipe("beebox", {Ingredient("boards", 2),Ingredient("honeycomb", 1),Ingredient("bee", 4)}, RECIPETABS.FARM, TECH.SCIENCE_ONE, {RECIPE_GAME_TYPE.VANILLA,RECIPE_GAME_TYPE.ROG,RECIPE_GAME_TYPE.SHIPWRECKED}, "beebox_placer")
Recipe("meatrack", {Ingredient("twigs", 3),Ingredient("charcoal", 2), Ingredient("rope", 3)}, RECIPETABS.FARM, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.COMMON, "meatrack_placer")
Recipe("cookpot", {Ingredient("cutstone", 3),Ingredient("charcoal", 6), Ingredient("twigs", 6)}, RECIPETABS.FARM,  TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.COMMON, "cookpot_placer")
Recipe("icebox", {Ingredient("goldnugget", 2), Ingredient("gears", 1), Ingredient("cutstone", 1)}, RECIPETABS.FARM,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.COMMON, "icebox_placer", 1.5)
Recipe("fish_farm", {Ingredient("coconut", 4),Ingredient("rope", 2),Ingredient("silk", 2)}, RECIPETABS.FARM,  TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED, "fish_farm_placer", nil, nil, nil, true)
Recipe("mussel_bed", {Ingredient("mussel", 1),Ingredient("coral", 1)}, RECIPETABS.FARM,  TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("sprinkler", {Ingredient("alloy", 2), Ingredient("bluegem", 1),Ingredient("ice", 6)}, RECIPETABS.FARM,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.PORKLAND, "sprinkler_placer")

--SURVIVAL
Recipe("trap", {Ingredient("twigs", 2),Ingredient("cutgrass", 6)}, RECIPETABS.SURVIVAL, TECH.NONE)
Recipe("birdtrap", {Ingredient("twigs", 3),Ingredient("silk", 4)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_ONE)

Recipe("bugnet", {Ingredient("twigs", 4), Ingredient("silk", 2), Ingredient("rope", 1)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_ONE)
Recipe("fishingrod", {Ingredient("twigs", 2),Ingredient("silk", 2)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_ONE)
Recipe("monkeyball", {Ingredient("snakeskin", 2), Ingredient("cave_banana", 1), Ingredient("rope", 2)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED)
--Recipe("bigfishingrod", {Ingredient("twigs", 2),Ingredient("silk", 2)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_ONE)
Recipe("grass_umbrella", {Ingredient("twigs", 4) ,Ingredient("cutgrass", 3), Ingredient("petals", 6)}, RECIPETABS.SURVIVAL, TECH.NONE, RECIPE_GAME_TYPE.ROG)
Recipe("palmleaf_umbrella", {Ingredient("twigs", 4) ,Ingredient("palmleaf", 3), Ingredient("petals", 6)}, RECIPETABS.SURVIVAL, TECH.NONE, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("umbrella", {Ingredient("twigs", 6) ,Ingredient("pigskin", 1), Ingredient("silk",2 )}, RECIPETABS.SURVIVAL, TECH.SCIENCE_ONE)

Recipe("bugrepellent", {Ingredient("tuber_crop", 6) ,Ingredient("venus_stalk", 1)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.PORKLAND)

Recipe("bandage", {Ingredient("papyrus", 1), Ingredient("honey", 2)}, RECIPETABS.SURVIVAL,  TECH.SCIENCE_TWO)
Recipe("healingsalve", {Ingredient("ash", 2), Ingredient("rocks", 1), Ingredient("spidergland",1)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_ONE)
Recipe("antivenom", {Ingredient("venomgland", 1), Ingredient("seaweed", 3), Ingredient("coral", 2)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("compass", {Ingredient("goldnugget", 1), Ingredient("papyrus", 1)}, RECIPETABS.SURVIVAL,  TECH.SCIENCE_ONE)
Recipe("heatrock", {Ingredient("rocks", 10),Ingredient("pickaxe", 1),Ingredient("flint", 3)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_TWO, {RECIPE_GAME_TYPE.VANILLA,RECIPE_GAME_TYPE.ROG,RECIPE_GAME_TYPE.SHIPWRECKED})

Recipe("thatchpack", {Ingredient("palmleaf", 4)}, RECIPETABS.SURVIVAL, TECH.NONE, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("backpack", {Ingredient("cutgrass", 4), Ingredient("twigs", 4)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_ONE)
Recipe("piggyback", {Ingredient("pigskin", 4), Ingredient("silk", 6), Ingredient("rope", 2)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_TWO)
Recipe("bedroll_straw", {Ingredient("cutgrass", 6), Ingredient("rope", 1)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_ONE)
Recipe("bedroll_furry", {Ingredient("bedroll_straw", 1), Ingredient("manrabbit_tail", 2)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.VANILLA)
Recipe("tent", {Ingredient("silk", 6),Ingredient("twigs", 4),Ingredient("rope", 3)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.COMMON, "tent_placer")
Recipe("siestahut", {Ingredient("silk", 2),Ingredient("boards", 4),Ingredient("rope", 3)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.COMMON, "siestahut_placer")
Recipe("palmleaf_hut", {Ingredient("palmleaf", 4),Ingredient("bamboo", 4),Ingredient("rope", 3)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.SHIPWRECKED, "palmleaf_hut_placer")
Recipe("featherfan", {Ingredient("goose_feather", 5), Ingredient("cutreeds", 2), Ingredient("rope", 2)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_TWO, {RECIPE_GAME_TYPE.ROG, RECIPE_GAME_TYPE.PORKLAND})
Recipe("tropicalfan", {Ingredient("doydoyfeather", 5), Ingredient("cutreeds", 2), Ingredient("rope", 2)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("icepack", {Ingredient("bearger_fur", 1), Ingredient("gears", 3), Ingredient("transistor", 3)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.ROG)
Recipe("seasack", {Ingredient("seaweed", 5), Ingredient("vine", 2), Ingredient("shark_gills", 1)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("doydoynest", {Ingredient("twigs", 8), Ingredient("doydoyfeather", 2), Ingredient("poop", 4)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.SHIPWRECKED, "doydoynest_placer")
Recipe("bundlewrap", {Ingredient("waxpaper", 1), Ingredient("rope", 1)}, RECIPETABS.SURVIVAL, TECH.LOST, RECIPE_GAME_TYPE.COMMON)

Recipe("antler", {Ingredient("hippo_antler", 1),Ingredient("bill_quill", 3),Ingredient("flint", 1)}, RECIPETABS.SURVIVAL, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.PORKLAND)

--TOOLS
Recipe("axe", {Ingredient("twigs", 1),Ingredient("flint", 1)}, RECIPETABS.TOOLS, TECH.NONE)
Recipe("goldenaxe", {Ingredient("twigs", 4),Ingredient("goldnugget", 2)}, RECIPETABS.TOOLS,  TECH.SCIENCE_TWO)

Recipe("machete", {Ingredient("twigs", 1),Ingredient("flint", 3)}, RECIPETABS.TOOLS, TECH.NONE)
Recipe("goldenmachete", {Ingredient("twigs", 4),Ingredient("goldnugget", 2)}, RECIPETABS.TOOLS,  TECH.SCIENCE_TWO)

Recipe("pickaxe", {Ingredient("twigs", 2),Ingredient("flint", 2)}, RECIPETABS.TOOLS, TECH.NONE)
Recipe("goldenpickaxe", {Ingredient("twigs", 4),Ingredient("goldnugget", 2)}, RECIPETABS.TOOLS,  TECH.SCIENCE_TWO)

Recipe("shears", {Ingredient("twigs", 2),Ingredient("iron", 2)}, RECIPETABS.TOOLS, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.PORKLAND)

Recipe("shovel", {Ingredient("twigs", 2),Ingredient("flint", 2)}, RECIPETABS.TOOLS,  TECH.SCIENCE_ONE)
Recipe("goldenshovel", {Ingredient("twigs", 4),Ingredient("goldnugget", 2)}, RECIPETABS.TOOLS,  TECH.SCIENCE_TWO)

Recipe("hammer", {Ingredient("twigs", 3),Ingredient("rocks", 3), Ingredient("cutgrass", 6)}, RECIPETABS.TOOLS, TECH.NONE)
Recipe("pitchfork", {Ingredient("twigs", 2),Ingredient("flint", 2)}, RECIPETABS.TOOLS,  TECH.SCIENCE_ONE)
Recipe("razor", {Ingredient("twigs", 2), Ingredient("flint", 2)}, RECIPETABS.TOOLS,  TECH.SCIENCE_ONE)
Recipe("featherpencil", {Ingredient("twigs", 1), Ingredient("charcoal", 1), Ingredient("feather_crow", 1)}, RECIPETABS.TOOLS,  TECH.SCIENCE_ONE)

Recipe("saddlehorn", {Ingredient("twigs", 2), Ingredient("boneshard", 2), Ingredient("feather_crow", 1)}, RECIPETABS.TOOLS,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.VANILLA)
Recipe("saddle_basic", {Ingredient("beefalowool", 4), Ingredient("pigskin", 4), Ingredient("goldnugget", 4)}, RECIPETABS.TOOLS,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.VANILLA)
Recipe("saddle_war", {Ingredient("rabbit", 4), Ingredient("steelwool", 4), Ingredient("log", 10)}, RECIPETABS.TOOLS,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.VANILLA) 
Recipe("saddle_race", {Ingredient("livinglog", 2), Ingredient("silk", 4), Ingredient("butterflywings", 68)}, RECIPETABS.TOOLS,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.VANILLA)
Recipe("brush", {Ingredient("walrus_tusk", 1), Ingredient("steelwool", 1), Ingredient("goldnugget", 2)}, RECIPETABS.TOOLS,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.VANILLA) 
Recipe("saltlick", {Ingredient("boards", 2), Ingredient("nitre", 4)}, RECIPETABS.TOOLS,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.VANILLA, "saltlick_placer")


--SCIENCE
Recipe("researchlab", {Ingredient("goldnugget", 1), Ingredient("log", 4), Ingredient("rocks", 4)}, RECIPETABS.SCIENCE, TECH.NONE, RECIPE_GAME_TYPE.COMMON, "researchlab_placer")
Recipe("researchlab2", {Ingredient("boards", 4), Ingredient("cutstone", 2), Ingredient("transistor", 2)}, RECIPETABS.SCIENCE, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.COMMON, "researchlab2_placer")
Recipe("researchlab5", {Ingredient("limestone", 4), Ingredient("sand", 2), Ingredient("transistor", 2)}, RECIPETABS.SCIENCE, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED, "researchlab5_placer", nil, nil, nil, true)
Recipe("transistor", {Ingredient("goldnugget", 2), Ingredient("cutstone", 1)}, RECIPETABS.SCIENCE, TECH.SCIENCE_ONE)
Recipe("diviningrod", {Ingredient("twigs", 1), Ingredient("nightmarefuel", 4), Ingredient("gears", 1)}, RECIPETABS.SCIENCE, TECH.SCIENCE_TWO)
Recipe("winterometer", {Ingredient("boards", 2), Ingredient("goldnugget", 2)}, RECIPETABS.SCIENCE,  TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.COMMON, "winterometer_placer")
Recipe("rainometer", {Ingredient("boards", 2), Ingredient("goldnugget", 2), Ingredient("rope",2)}, RECIPETABS.SCIENCE,  TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.COMMON, "rainometer_placer")
Recipe("gunpowder", {Ingredient("rottenegg", 1), Ingredient("charcoal", 1), Ingredient("nitre", 1)}, RECIPETABS.SCIENCE,  TECH.SCIENCE_TWO)
Recipe("lightning_rod", {Ingredient("goldnugget", 4), Ingredient("cutstone", 1)}, RECIPETABS.SCIENCE,  TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.COMMON, "lightning_rod_placer")
Recipe("firesuppressor", {Ingredient("gears", 2), Ingredient("ice", 15), Ingredient("transistor", 2)}, RECIPETABS.SCIENCE,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.COMMON, "firesuppressor_placer")
Recipe("smelter", {Ingredient("cutstone", 6), Ingredient("boards", 4), Ingredient("redgem", 1)}, RECIPETABS.SCIENCE, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.PORKLAND, "smetler_placer")
Recipe("basefan", {Ingredient("alloy", 2), Ingredient("transistor", 2),Ingredient("gears", 1)}, RECIPETABS.SCIENCE,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.PORKLAND, "basefan_placer")
Recipe("icemaker", {Ingredient("heatrock", 1), Ingredient("bamboo", 5), Ingredient("transistor", 2)}, RECIPETABS.SCIENCE,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.SHIPWRECKED, "icemaker_placer")
Recipe("quackendrill", {Ingredient("quackenbeak", 1), Ingredient("gears", 1), Ingredient("transistor", 2)}, RECIPETABS.SCIENCE,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.SHIPWRECKED)

--MAGIC
Recipe("hogusporkusator", {Ingredient("pigskin", 4), Ingredient("boards", 4), Ingredient("feather_robin_winter", 4)}, RECIPETABS.MAGIC, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.PORKLAND, "hogusporkusator_placer")
Recipe("piratihatitator", {Ingredient("parrot", 1), Ingredient("boards", 4), Ingredient("piratehat", 1)}, RECIPETABS.MAGIC, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED, "piratihatitator_placer")
Recipe("researchlab4", {Ingredient("rabbit", 4), Ingredient("boards", 4), Ingredient("tophat", 1)}, RECIPETABS.MAGIC, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.VANILLA, "researchlab4_placer")
Recipe("researchlab3", {Ingredient("livinglog", 3), Ingredient("purplegem", 1), Ingredient("nightmarefuel", 7)}, RECIPETABS.MAGIC, TECH.MAGIC_TWO, RECIPE_GAME_TYPE.COMMON, "researchlab3_placer")
Recipe("resurrectionstatue", {Ingredient("boards", 4),Ingredient("cookedmeat", 4),Ingredient("beardhair", 4)}, RECIPETABS.MAGIC,  TECH.MAGIC_TWO, RECIPE_GAME_TYPE.COMMON, "resurrectionstatue_placer")
Recipe("panflute", {Ingredient("cutreeds", 5), Ingredient("mandrake", 1), Ingredient("rope", 1)}, RECIPETABS.MAGIC,  TECH.MAGIC_TWO)
Recipe("ox_flute", {Ingredient("ox_horn", 1), Ingredient("nightmarefuel", 2), Ingredient("rope", 1)}, RECIPETABS.MAGIC,  TECH.MAGIC_TWO, RECIPE_GAME_TYPE.SHIPWRECKED)

Recipe("bell", {Ingredient("glommerwings", 1), Ingredient("glommerflower", 1)}, RECIPETABS.MAGIC,  TECH.LOST, {RECIPE_GAME_TYPE.ROG,RECIPE_GAME_TYPE.PORKLAND})
Recipe("onemanband", {Ingredient("goldnugget", 2),Ingredient("nightmarefuel", 4),Ingredient("pigskin", 2)}, RECIPETABS.MAGIC, TECH.MAGIC_TWO)
Recipe("nightlight", {Ingredient("goldnugget", 8), Ingredient("nightmarefuel", 2),Ingredient("redgem", 1)}, RECIPETABS.MAGIC,  TECH.MAGIC_TWO, RECIPE_GAME_TYPE.COMMON, "nightlight_placer")
Recipe("armor_sanity", {Ingredient("nightmarefuel", 5),Ingredient("papyrus", 3)}, RECIPETABS.MAGIC,  TECH.MAGIC_THREE)

Recipe("armorvortexcloak", {Ingredient("ancient_remnant", 5),Ingredient("armor_sanity", 1)}, RECIPETABS.MAGIC,  TECH.LOST, RECIPE_GAME_TYPE.PORKLAND)
Recipe("living_artifact", {Ingredient("infused_iron", 6),Ingredient("waterdrop", 1)}, RECIPETABS.MAGIC,  TECH.LOST, RECIPE_GAME_TYPE.PORKLAND)

Recipe("nightsword", {Ingredient("nightmarefuel", 5),Ingredient("livinglog", 1)}, RECIPETABS.MAGIC,  TECH.MAGIC_THREE)
Recipe("batbat", {Ingredient("batwing", 5), Ingredient("livinglog", 2), Ingredient("purplegem", 1)}, RECIPETABS.MAGIC, TECH.MAGIC_THREE, {RECIPE_GAME_TYPE.VANILLA,RECIPE_GAME_TYPE.PORKLAND})
Recipe("armorslurper", {Ingredient("slurper_pelt", 6),Ingredient("rope", 2),Ingredient("nightmarefuel", 2)}, RECIPETABS.MAGIC,  TECH.MAGIC_THREE, RECIPE_GAME_TYPE.VANILLA)

Recipe("roottrunk_child", {Ingredient("bramble_bulb", 1), Ingredient("venus_stalk", 2),Ingredient("boards", 3)}, RECIPETABS.MAGIC,  TECH.MAGIC_TWO, RECIPE_GAME_TYPE.COMMON, "roottrunk_child_placer")

Recipe("amulet", {Ingredient("goldnugget", 3), Ingredient("nightmarefuel", 2),Ingredient("redgem", 1)}, RECIPETABS.MAGIC,  TECH.MAGIC_TWO)
Recipe("blueamulet", {Ingredient("goldnugget", 3), Ingredient("bluegem", 1)}, RECIPETABS.MAGIC, TECH.MAGIC_TWO)
Recipe("purpleamulet", {Ingredient("goldnugget", 6), Ingredient("nightmarefuel", 4),Ingredient("purplegem", 2)}, RECIPETABS.MAGIC,  TECH.MAGIC_THREE)
Recipe("firestaff", {Ingredient("nightmarefuel", 2), Ingredient("spear", 1), Ingredient("redgem", 1)}, RECIPETABS.MAGIC, TECH.MAGIC_THREE)
Recipe("icestaff", {Ingredient("spear", 1),Ingredient("bluegem", 1)}, RECIPETABS.MAGIC,  TECH.MAGIC_TWO)
Recipe("bonestaff", {Ingredient("pugalisk_skull", 1), Ingredient("boneshard", 1), Ingredient("nightmarefuel", 2)}, RECIPETABS.MAGIC, TECH.MAGIC_THREE,RECIPE_GAME_TYPE.PORKLAND)
Recipe("telestaff", {Ingredient("nightmarefuel", 4), Ingredient("livinglog", 2), Ingredient("purplegem", 2)}, RECIPETABS.MAGIC, TECH.MAGIC_THREE, nil)
Recipe("telebase", {Ingredient("nightmarefuel", 4), Ingredient("livinglog", 4), Ingredient("goldnugget", 8)}, RECIPETABS.MAGIC, TECH.MAGIC_THREE, nil, "telebase_placer")
Recipe("shipwrecked_entrance", {Ingredient("nightmarefuel", 4), Ingredient("livinglog", 4), Ingredient("sunken_boat_trinket_4", 1)}, RECIPETABS.MAGIC, TECH.MAGIC_THREE, {RECIPE_GAME_TYPE.VANILLA, RECIPE_GAME_TYPE.ROG, RECIPE_GAME_TYPE.SHIPWRECKED }, "shipwrecked_entrance_placer")
-- This is here so that the exit in the world can be hammered for goods.
Recipe("shipwrecked_exit", {Ingredient("nightmarefuel", 4), Ingredient("livinglog", 4), Ingredient("sunken_boat_trinket_4", 1)}, nil, TECH.LOST, RECIPE_GAME_TYPE.SHIPWRECKED, "shipwrecked_entrance_placer")
Recipe("porkland_entrance", {Ingredient("nightmarefuel", 4), Ingredient("livinglog", 4), Ingredient("trinket_giftshop_4", 1)}, RECIPETABS.MAGIC, TECH.MAGIC_THREE, RECIPE_GAME_TYPE.COMMON, "porkland_entrance_placer")




--REFINE
Recipe("rope", {Ingredient("cutgrass", 3)}, RECIPETABS.REFINE,  TECH.SCIENCE_ONE)
Recipe("boards", {Ingredient("log", 4)}, RECIPETABS.REFINE,  TECH.SCIENCE_ONE)
Recipe("cutstone", {Ingredient("rocks", 3)}, RECIPETABS.REFINE,  TECH.SCIENCE_ONE)
Recipe("clawpalmtree_sapling", {Ingredient("cork", 1), Ingredient("poop", 1)}, RECIPETABS.REFINE, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.PORKLAND,"clawpalmtree_sapling_placer")
Recipe("papyrus", {Ingredient("cutreeds", 4)}, RECIPETABS.REFINE,  TECH.SCIENCE_ONE)
Recipe("fabric", {Ingredient("bamboo", 3)}, RECIPETABS.REFINE,  TECH.SCIENCE_ONE, {RECIPE_GAME_TYPE.SHIPWRECKED, RECIPE_GAME_TYPE.VANILLA, RECIPE_GAME_TYPE.ROG })
Recipe("limestone", {Ingredient("coral", 3)}, RECIPETABS.REFINE,  TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("nubbin", {Ingredient("limestone", 3), Ingredient("corallarve", 1)}, RECIPETABS.REFINE, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("goldnugget", {Ingredient("gold_dust", 6)}, RECIPETABS.REFINE,  TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.PORKLAND)
Recipe("goldnugget", {Ingredient("dubloon", 3)}, RECIPETABS.REFINE,  TECH.SCIENCE_ONE)
Recipe("venomgland", {Ingredient("froglegs_poison", 3)}, RECIPETABS.REFINE,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.PORKLAND)

Recipe("ice", {Ingredient("hail_ice", 4)}, RECIPETABS.REFINE, TECH.SCIENCE_TWO, {RECIPE_GAME_TYPE.SHIPWRECKED})
Recipe("messagebottleempty", {Ingredient("sand", 3)}, RECIPETABS.REFINE,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("nightmarefuel", {Ingredient("petals_evil", 4)}, RECIPETABS.REFINE, TECH.MAGIC_TWO)
Recipe("purplegem", {Ingredient("redgem",1), Ingredient("bluegem", 1)}, RECIPETABS.REFINE, TECH.MAGIC_TWO)

Recipe("beeswax", {Ingredient("honeycomb", 1)}, RECIPETABS.REFINE, TECH.SCIENCE_ONE)
Recipe("waxpaper", {Ingredient("beeswax", 1), Ingredient("papyrus", 1)}, RECIPETABS.REFINE, TECH.SCIENCE_ONE)

--WAR
Recipe("spear", {Ingredient("twigs", 2),Ingredient("rope", 1),Ingredient("flint", 1) }, RECIPETABS.WAR,  TECH.SCIENCE_ONE)
Recipe("halberd", {Ingredient("alloy", 1), Ingredient("twigs", 2)}, RECIPETABS.WAR, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.PORKLAND)
Recipe("spear_poison", {Ingredient("spear", 1), Ingredient("venomgland", 1) }, RECIPETABS.WAR,  TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED)

Recipe("cork_bat", {Ingredient("cork", 3), Ingredient("boards", 1)}, RECIPETABS.WAR,  TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.PORKLAND)

Recipe("hambat", {Ingredient("pigskin", 1), Ingredient("twigs", 2), Ingredient("meat", 2)}, RECIPETABS.WAR,  TECH.SCIENCE_TWO)
Recipe("nightstick", {Ingredient("lightninggoathorn", 1), Ingredient("transistor", 2), Ingredient("nitre", 2)}, RECIPETABS.WAR, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.ROG)
Recipe("armorgrass", {Ingredient("cutgrass", 10), Ingredient("twigs", 2)}, RECIPETABS.WAR,  TECH.NONE, RECIPE_GAME_TYPE.VANILLA)
Recipe("armorwood", {Ingredient("log", 8),Ingredient("rope", 2)}, RECIPETABS.WAR,  TECH.SCIENCE_ONE)
Recipe("armorseashell", {Ingredient("seashell", 10),Ingredient("seaweed", 2),Ingredient("rope", 1)}, RECIPETABS.WAR,  TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("armormarble", {Ingredient("marble", 12),Ingredient("rope", 4)}, RECIPETABS.WAR,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.VANILLA)
Recipe("armorlimestone", {Ingredient("limestone", 3), Ingredient("rope", 2)}, RECIPETABS.WAR, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("armorcactus", {Ingredient("needlespear", 3), Ingredient("armorwood", 1)}, RECIPETABS.WAR, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("armor_weevole", {Ingredient("weevole_carapace", 4), Ingredient("chitin", 2)}, RECIPETABS.WAR, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.PORKLAND)

Recipe("antmaskhat", {Ingredient("chitin", 5),Ingredient("footballhat", 1)}, RECIPETABS.WAR, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.PORKLAND)
Recipe("antsuit", {Ingredient("chitin", 5),Ingredient("armorwood", 1)}, RECIPETABS.WAR, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.PORKLAND)

Recipe("footballhat", {Ingredient("pigskin", 1), Ingredient("rope", 1)}, RECIPETABS.WAR,  TECH.SCIENCE_TWO)
Recipe("oxhat", {Ingredient("ox_horn", 1), Ingredient("seashell", 4), Ingredient("rope", 1)}, RECIPETABS.WAR,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.SHIPWRECKED)

Recipe("metalplatehat", {Ingredient("alloy", 3),Ingredient("cork", 3)}, RECIPETABS.WAR, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.PORKLAND)
Recipe("armor_metalplate", {Ingredient("alloy", 3),Ingredient("hammer", 1)}, RECIPETABS.WAR, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.PORKLAND)

Recipe("blowdart_pipe", {Ingredient("cutreeds", 2),Ingredient("houndstooth", 1),Ingredient("feather_robin_winter", 1) }, RECIPETABS.WAR,  TECH.SCIENCE_ONE)
Recipe("blowdart_sleep", {Ingredient("cutreeds", 2),Ingredient("stinger", 1),Ingredient("feather_crow", 1) }, RECIPETABS.WAR,  TECH.SCIENCE_ONE)
Recipe("blowdart_fire", {Ingredient("cutreeds", 2),Ingredient("charcoal", 1),Ingredient("feather_robin", 1) }, RECIPETABS.WAR,  TECH.SCIENCE_ONE)
Recipe("blowdart_poison", {Ingredient("cutreeds", 2),Ingredient("venomgland", 1),Ingredient("feather_crow", 1) }, RECIPETABS.WAR,  TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("boomerang", {Ingredient("boards", 1),Ingredient("silk", 1),Ingredient("charcoal", 1)}, RECIPETABS.WAR,  TECH.SCIENCE_TWO)
Recipe("beemine", {Ingredient("boards", 1),Ingredient("bee", 4),Ingredient("flint", 1) }, RECIPETABS.WAR,  TECH.SCIENCE_ONE)
Recipe("trap_teeth", {Ingredient("log", 1),Ingredient("rope", 1),Ingredient("houndstooth", 1)}, RECIPETABS.WAR,  TECH.SCIENCE_TWO)
Recipe("coconade", {Ingredient("coconut", 1), Ingredient("gunpowder", 1), Ingredient("rope", 1)}, RECIPETABS.WAR, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED)

Recipe("spear_launcher", {Ingredient("bamboo", 3), Ingredient("jellyfish", 1)}, RECIPETABS.WAR,  TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED)
-- Recipe("speargun", {Ingredient("seashell", 1), Ingredient("bamboo", 3),  Ingredient("jellyfish", 1)}, RECIPETABS.WAR, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED)
-- Recipe("speargun_poison", {Ingredient("seashell", 3), Ingredient("bamboo", 1),  Ingredient("venomgland", 1)}, RECIPETABS.WAR, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED)

Recipe("cutlass", {Ingredient("dead_swordfish", 1), Ingredient("goldnugget", 2), Ingredient("twigs", 1)}, RECIPETABS.WAR, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("armordragonfly", {Ingredient("dragon_scales", 1), Ingredient("armorwood", 1), Ingredient("pigskin", 3)}, RECIPETABS.WAR,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.ROG)
Recipe("staff_tornado", {Ingredient("goose_feather", 10), Ingredient("lightninggoathorn", 1), Ingredient("gears", 1)}, RECIPETABS.WAR,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.ROG)
Recipe("blunderbuss", {Ingredient("boards", 2), Ingredient("oinc10", 1), Ingredient("gears", 1)}, RECIPETABS.WAR,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.PORKLAND)

--DRESSUP
Recipe("sewing_kit", {Ingredient("log", 1), Ingredient("silk", 8), Ingredient("houndstooth", 2)}, RECIPETABS.DRESS, TECH.SCIENCE_TWO)
Recipe("flowerhat", {Ingredient("petals", 12)}, RECIPETABS.DRESS, TECH.NONE)
Recipe("strawhat", {Ingredient("cutgrass", 12)}, RECIPETABS.DRESS,  TECH.NONE)
Recipe("tophat", {Ingredient("silk", 6)}, RECIPETABS.DRESS,  TECH.SCIENCE_ONE)
Recipe("rainhat", {Ingredient("mole", 2), Ingredient("strawhat", 1), Ingredient("boneshard", 1)}, RECIPETABS.DRESS, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.ROG, nil, nil, nil, nil, true)

Recipe("earmuffshat", {Ingredient("rabbit", 2), Ingredient("twigs",1)}, RECIPETABS.DRESS, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.VANILLA)
Recipe("beefalohat", {Ingredient("beefalowool", 8),Ingredient("horn", 1)}, RECIPETABS.DRESS,  TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.VANILLA)
Recipe("winterhat", {Ingredient("beefalowool", 4),Ingredient("silk", 4)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.VANILLA)
Recipe("catcoonhat", {Ingredient("coontail", 4), Ingredient("silk", 4)}, RECIPETABS.DRESS, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.ROG)

Recipe("gasmaskhat", {Ingredient("peagawkfeather", 4), Ingredient("pigskin", 1), Ingredient("fabric", 1)}, RECIPETABS.DRESS, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.PORKLAND, nil, nil, nil, nil, true)

-- Recipe("eurekahat", {Ingredient("coral_brain", 1), Ingredient("transistor", 2), Ingredient("sand", 6)}, RECIPETABS.DRESS, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("brainjellyhat", {Ingredient("coral_brain", 1), Ingredient("jellyfish", 1), Ingredient("rope", 2)}, RECIPETABS.DRESS, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("watermelonhat", {Ingredient("watermelon", 1), Ingredient("twigs", 3)}, RECIPETABS.DRESS, TECH.SCIENCE_ONE, {RECIPE_GAME_TYPE.VANILLA,RECIPE_GAME_TYPE.ROG,RECIPE_GAME_TYPE.SHIPWRECKED})
Recipe("pithhat", {Ingredient("fabric", 1),Ingredient("vine", 3),Ingredient("cork", 6)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.PORKLAND)
Recipe("thunderhat", {Ingredient("feather_thunder", 1),Ingredient("goldnugget", 2),Ingredient("cork", 3)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.PORKLAND)
Recipe("shark_teethhat", {Ingredient("houndstooth", 5), Ingredient("goldnugget", 1)}, RECIPETABS.DRESS,  TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("icehat", {Ingredient("transistor", 2), Ingredient("rope", 4), Ingredient("ice", 10)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO, {RECIPE_GAME_TYPE.VANILLA,RECIPE_GAME_TYPE.ROG,RECIPE_GAME_TYPE.SHIPWRECKED})
Recipe("beehat", {Ingredient("silk", 8), Ingredient("rope", 1)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO, {RECIPE_GAME_TYPE.VANILLA,RECIPE_GAME_TYPE.ROG,RECIPE_GAME_TYPE.SHIPWRECKED})
Recipe("featherhat", {Ingredient("feather_crow", 3),Ingredient("feather_robin", 2), Ingredient("tentaclespots", 2)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO)
--Recipe("peagawkfeatherhat", {Ingredient("peagawkfeather", 3),Ingredient("foliage", 2)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.PORKLAND)
Recipe("bushhat", {Ingredient("strawhat", 1),Ingredient("rope", 1),Ingredient("dug_berrybush", 1)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO)

Recipe("snakeskinhat", {Ingredient("snakeskin", 1), Ingredient("strawhat", 1), Ingredient("boneshard", 1)}, RECIPETABS.DRESS, TECH.SCIENCE_TWO, {RECIPE_GAME_TYPE.SHIPWRECKED,RECIPE_GAME_TYPE.PORKLAND}, nil, nil, nil, nil, true)
Recipe("raincoat", {Ingredient("tentaclespots", 2), Ingredient("rope", 2), Ingredient("boneshard", 2)}, RECIPETABS.DRESS, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.ROG, nil, nil, nil, nil, true)

Recipe("armor_snakeskin", {Ingredient("snakeskin", 2), Ingredient("vine", 2), Ingredient("boneshard", 2)}, RECIPETABS.DRESS, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.COMMON, nil, nil, nil, nil, true)
Recipe("blubbersuit", {Ingredient("blubber", 4), Ingredient("fabric", 2), Ingredient("palmleaf", 2)}, RECIPETABS.DRESS, TECH.SCIENCE_TWO, {RECIPE_GAME_TYPE.VANILLA,RECIPE_GAME_TYPE.ROG,RECIPE_GAME_TYPE.SHIPWRECKED}, nil, nil, nil, nil, true)
Recipe("tarsuit", {Ingredient("tar", 4), Ingredient("fabric", 2), Ingredient("palmleaf", 2)}, RECIPETABS.DRESS, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED, nil, nil, nil, nil, true)
Recipe("sweatervest", {Ingredient("houndstooth", 8),Ingredient("silk", 6)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.VANILLA)
Recipe("trunkvest_summer", {Ingredient("trunk_summer", 1),Ingredient("silk", 8)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.VANILLA)
Recipe("trunkvest_winter", {Ingredient("trunk_winter", 1),Ingredient("silk", 8), Ingredient("beefalowool", 2)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.VANILLA)
Recipe("reflectivevest", {Ingredient("rope", 1), Ingredient("feather_robin", 3), Ingredient("pigskin", 2)}, RECIPETABS.DRESS,  TECH.SCIENCE_ONE, {RECIPE_GAME_TYPE.VANILLA,RECIPE_GAME_TYPE.ROG,RECIPE_GAME_TYPE.SHIPWRECKED})
Recipe("hawaiianshirt", {Ingredient("papyrus", 3), Ingredient("silk", 3), Ingredient("petals", 5)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("hawaiianshirt", {Ingredient("papyrus", 3), Ingredient("silk", 3), Ingredient("cactus_flower", 5)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.ROG)
Recipe("cane", {Ingredient("goldnugget", 2), Ingredient("walrus_tusk", 1), Ingredient("twigs", 4)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.VANILLA)
Recipe("beargervest", {Ingredient("bearger_fur", 1), Ingredient("sweatervest", 1), Ingredient("rope", 2)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.ROG)
Recipe("eyebrellahat", {Ingredient("deerclops_eyeball", 1), Ingredient("twigs", 15), Ingredient("boneshard", 4)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.ROG)
Recipe("double_umbrellahat", {Ingredient("shark_gills", 2), Ingredient("umbrella", 1), Ingredient("strawhat", 1)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("armor_windbreaker", {Ingredient("blubber", 2), Ingredient("fabric", 1), Ingredient("rope", 1)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.SHIPWRECKED) -- CHECK  THIS
Recipe("gashat", {Ingredient("messagebottleempty", 2), Ingredient("coral", 3), Ingredient("jellyfish", 1)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("aerodynamichat", {Ingredient("shark_fin", 1), Ingredient("vine", 2), Ingredient("coconut", 1)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.SHIPWRECKED)
----GEMS----

----ANCIENT----
Recipe("thulecite", {Ingredient("thulecite_pieces", 6)}, RECIPETABS.ANCIENT, TECH.ANCIENT_TWO, mergedGameTypes , nil, nil, true)

Recipe("wall_ruins_item", {Ingredient("thulecite", 1)}, RECIPETABS.ANCIENT, TECH.ANCIENT_TWO, mergedGameTypes, nil, nil, true, 6)

Recipe("nightmare_timepiece", {Ingredient("thulecite", 2), Ingredient("nightmarefuel", 2)}, RECIPETABS.ANCIENT, TECH.ANCIENT_TWO, mergedGameTypes, nil, nil, true)

Recipe("orangeamulet", {Ingredient("thulecite", 2), Ingredient("nightmarefuel", 3),Ingredient("orangegem", 1)}, RECIPETABS.ANCIENT,  TECH.ANCIENT_FOUR, mergedGameTypes, nil, nil, true)
Recipe("yellowamulet", {Ingredient("thulecite", 2), Ingredient("nightmarefuel", 3),Ingredient("yellowgem", 1)}, RECIPETABS.ANCIENT, TECH.ANCIENT_TWO, mergedGameTypes, nil, nil, true)
Recipe("greenamulet", {Ingredient("thulecite", 2), Ingredient("nightmarefuel", 3),Ingredient("greengem", 1)}, RECIPETABS.ANCIENT,  TECH.ANCIENT_TWO, mergedGameTypes, nil, nil, true)

Recipe("orangestaff", {Ingredient("nightmarefuel", 2), Ingredient("cane", 1), Ingredient("orangegem", 2)}, RECIPETABS.ANCIENT, TECH.ANCIENT_FOUR, mergedGameTypes, nil, nil, true)
Recipe("yellowstaff", {Ingredient("nightmarefuel", 4), Ingredient("livinglog", 2), Ingredient("yellowgem", 2)}, RECIPETABS.ANCIENT, TECH.ANCIENT_TWO, mergedGameTypes, nil, nil, true)
Recipe("greenstaff", {Ingredient("nightmarefuel", 4), Ingredient("livinglog", 2), Ingredient("greengem", 2)}, RECIPETABS.ANCIENT, TECH.ANCIENT_TWO, mergedGameTypes, nil, nil, true)

Recipe("multitool_axe_pickaxe", {Ingredient("goldenaxe", 1),Ingredient("goldenpickaxe", 1), Ingredient("thulecite", 2)}, RECIPETABS.ANCIENT, TECH.ANCIENT_FOUR, mergedGameTypes, nil, nil, true)

Recipe("ruinshat", {Ingredient("thulecite", 4), Ingredient("nightmarefuel", 4)}, RECIPETABS.ANCIENT, TECH.ANCIENT_FOUR, mergedGameTypes, nil, nil, true)
Recipe("armorruins", {Ingredient("thulecite", 6), Ingredient("nightmarefuel", 4)}, RECIPETABS.ANCIENT, TECH.ANCIENT_FOUR, mergedGameTypes, nil, nil, true)
Recipe("ruins_bat", {Ingredient("livinglog", 3), Ingredient("thulecite", 4), Ingredient("nightmarefuel", 4)}, RECIPETABS.ANCIENT, TECH.ANCIENT_FOUR, mergedGameTypes, nil, nil, true)
Recipe("eyeturret_item", {Ingredient("deerclops_eyeball", 1), Ingredient("minotaurhorn", 1), Ingredient("thulecite", 5)}, RECIPETABS.ANCIENT, TECH.ANCIENT_FOUR, mergedGameTypes, nil, nil, true)


if ACCOMPLISHMENTS_ENABLED then
	Recipe("accomplishment_shrine", {Ingredient("goldnugget", 10), Ingredient("cutstone", 1), Ingredient("gears", 6)}, RECIPETABS.SCIENCE, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.COMMON, "accomplishment_shrine_placer")
end

----NAUTICAL----

Recipe("lograft", {Ingredient("log", 6), Ingredient("cutgrass", 4)}, RECIPETABS.NAUTICAL, TECH.NONE, {RECIPE_GAME_TYPE.SHIPWRECKED,RECIPE_GAME_TYPE.PORKLAND}, "lograft_placer", nil, nil, nil, true, 4)
Recipe("raft", {Ingredient("bamboo", 4), Ingredient("vine", 3)}, RECIPETABS.NAUTICAL, TECH.NONE, RECIPE_GAME_TYPE.SHIPWRECKED, "raft_placer", nil, nil, nil, true, 4)
Recipe("rowboat", {Ingredient("boards", 3), Ingredient("vine", 4)}, RECIPETABS.NAUTICAL, TECH.SCIENCE_ONE, {RECIPE_GAME_TYPE.SHIPWRECKED,RECIPE_GAME_TYPE.PORKLAND}, "rowboat_placer", nil, nil, nil, true, 4)
Recipe("corkboat", {Ingredient("cork", 4), Ingredient("rope", 1)}, RECIPETABS.NAUTICAL, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.PORKLAND, "corkboat_placer", nil, nil, nil, true, 4)
Recipe("cargoboat", {Ingredient("boards", 6), Ingredient("rope", 3)}, RECIPETABS.NAUTICAL, TECH.SCIENCE_TWO, {RECIPE_GAME_TYPE.SHIPWRECKED,RECIPE_GAME_TYPE.PORKLAND}, "cargoboat_placer", nil, nil, nil, true, 4)
Recipe("armouredboat", {Ingredient("boards", 6), Ingredient("rope", 3), Ingredient("seashell", 10)}, RECIPETABS.NAUTICAL, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.SHIPWRECKED, "armouredboat_placer", nil, nil, nil, true, 4)
Recipe("encrustedboat", {Ingredient("boards", 6), Ingredient("rope", 3), Ingredient("limestone", 4)}, RECIPETABS.NAUTICAL, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.SHIPWRECKED, "encrustedboat_placer", nil, nil, nil, true, 4)
Recipe("boatrepairkit", {Ingredient("boards", 2), Ingredient("stinger", 2), Ingredient("rope", 2)}, RECIPETABS.NAUTICAL, TECH.SCIENCE_ONE, {RECIPE_GAME_TYPE.SHIPWRECKED,RECIPE_GAME_TYPE.PORKLAND})
Recipe("sail", {Ingredient("bamboo", 2), Ingredient("vine", 2), Ingredient("palmleaf", 4)}, RECIPETABS.NAUTICAL, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("clothsail", {Ingredient("bamboo", 2), Ingredient("rope", 2), Ingredient("fabric", 2)}, RECIPETABS.NAUTICAL, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("snakeskinsail", {Ingredient("log", 4), Ingredient("rope", 2), Ingredient("snakeskin", 2)}, RECIPETABS.NAUTICAL, TECH.SCIENCE_TWO, {RECIPE_GAME_TYPE.SHIPWRECKED,RECIPE_GAME_TYPE.PORKLAND})
Recipe("feathersail", {Ingredient("bamboo", 2), Ingredient("rope", 2), Ingredient("doydoyfeather", 4)}, RECIPETABS.NAUTICAL, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("ironwind", {Ingredient("turbine_blades", 1), Ingredient("transistor", 1), Ingredient("goldnugget", 2)}, RECIPETABS.NAUTICAL, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("boatcannon", {Ingredient("log", 5), Ingredient("gunpowder", 4), Ingredient("coconut", 6)}, RECIPETABS.NAUTICAL, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("seatrap", {Ingredient("palmleaf", 4),Ingredient("messagebottleempty", 2), Ingredient("jellyfish", 1)}, RECIPETABS.NAUTICAL, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("trawlnet", {Ingredient("rope", 3), Ingredient("bamboo", 2)}, RECIPETABS.NAUTICAL, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("telescope", {Ingredient("messagebottleempty", 1), Ingredient("pigskin", 1), Ingredient("goldnugget", 1) }, RECIPETABS.NAUTICAL, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("supertelescope", {Ingredient("telescope", 1), Ingredient("tigereye", 1), Ingredient("goldnugget", 1) }, RECIPETABS.NAUTICAL, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("captainhat", {Ingredient("seaweed", 1), Ingredient("boneshard", 1), Ingredient("strawhat", 1)}, RECIPETABS.NAUTICAL, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("piratehat", {Ingredient("boneshard", 2), Ingredient("rope", 1), Ingredient("silk", 2)}, RECIPETABS.NAUTICAL,  TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("armor_lifejacket", {Ingredient("fabric", 2), Ingredient("vine", 2), Ingredient("messagebottleempty", 3)}, RECIPETABS.NAUTICAL, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED)
Recipe("buoy", {Ingredient("messagebottleempty", 1), Ingredient("bamboo", 4), Ingredient("bioluminescence", 2)}, RECIPETABS.NAUTICAL, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.SHIPWRECKED, "buoy_placer", nil, nil, nil, true)
Recipe("quackeringram", {Ingredient("quackenbeak", 1), Ingredient("bamboo", 4), Ingredient("rope", 4)}, RECIPETABS.NAUTICAL, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.SHIPWRECKED)

Recipe("tar_extractor", {Ingredient("coconut", 2), Ingredient("bamboo", 4), Ingredient("limestone", 4)}, RECIPETABS.NAUTICAL, TECH.WATER_TWO, RECIPE_GAME_TYPE.SHIPWRECKED, "tar_extractor_placer", nil, nil, nil, true)
Recipe("sea_yard", {Ingredient("log", 4), Ingredient("tar", 6), Ingredient("limestone", 6)}, RECIPETABS.NAUTICAL, TECH.WATER_TWO, RECIPE_GAME_TYPE.SHIPWRECKED, "sea_yard_placer", nil, nil, nil, true)

Recipe("obsidianmachete", {Ingredient("machete", 1), Ingredient("obsidian", 3), Ingredient("dragoonheart", 1)}, RECIPETABS.OBSIDIAN,  TECH.OBSIDIAN_TWO, mergedGameTypes, nil, nil, true)
Recipe("obsidianaxe", {Ingredient("axe", 1), Ingredient("obsidian", 2), Ingredient("dragoonheart", 1)}, RECIPETABS.OBSIDIAN,  TECH.OBSIDIAN_TWO, mergedGameTypes, nil, nil, true)
Recipe("spear_obsidian", {Ingredient("spear", 1), Ingredient("obsidian", 3),Ingredient("dragoonheart", 1) }, RECIPETABS.OBSIDIAN,  TECH.OBSIDIAN_TWO, mergedGameTypes, nil, nil, true)
Recipe("volcanostaff", {Ingredient("firestaff", 1),  Ingredient("obsidian", 4), Ingredient("dragoonheart", 1)}, RECIPETABS.OBSIDIAN, TECH.OBSIDIAN_TWO, mergedGameTypes, nil, nil, true)
Recipe("armorobsidian", {Ingredient("armorwood", 1), Ingredient("obsidian", 5), Ingredient("dragoonheart", 1)}, RECIPETABS.OBSIDIAN,  TECH.OBSIDIAN_TWO, mergedGameTypes, nil, nil, true)
Recipe("obsidiancoconade", {Ingredient("coconade", 3), Ingredient("obsidian", 3), Ingredient("dragoonheart", 1)}, RECIPETABS.OBSIDIAN, TECH.OBSIDIAN_TWO, mergedGameTypes, nil, nil, true, 3)
Recipe("wind_conch", {Ingredient("obsidian", 4), Ingredient("purplegem", 1), Ingredient("magic_seal", 1)}, RECIPETABS.OBSIDIAN, TECH.OBSIDIAN_TWO, mergedGameTypes, nil, nil, true)
Recipe("sail_stick", {Ingredient("obsidian", 2), Ingredient("nightmarefuel", 3), Ingredient("magic_seal", 1)}, RECIPETABS.OBSIDIAN, TECH.OBSIDIAN_TWO, mergedGameTypes, nil, nil, true)

--- ARCHAEOLOGY ---
Recipe("disarming_kit", {Ingredient("iron", 2), Ingredient("cutreeds", 2)}, RECIPETABS.ARCHAEOLOGY, TECH.NONE, RECIPE_GAME_TYPE.PORKLAND)
Recipe("ballpein_hammer", {Ingredient("iron", 2), Ingredient("twigs", 1)}, RECIPETABS.ARCHAEOLOGY, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.PORKLAND)
Recipe("goldpan", {Ingredient("iron", 2), Ingredient("hammer", 1)}, RECIPETABS.ARCHAEOLOGY, TECH.SCIENCE_ONE, RECIPE_GAME_TYPE.PORKLAND)
Recipe("magnifying_glass", {Ingredient("iron", 1), Ingredient("twigs", 1), Ingredient("bluegem", 1)}, RECIPETABS.ARCHAEOLOGY, TECH.SCIENCE_TWO, RECIPE_GAME_TYPE.PORKLAND)

--- CITY ---
Recipe("turf_foundation", {Ingredient("cutstone", 1)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, nil, nil, true)
Recipe("turf_cobbleroad", {Ingredient("cutstone", 2), Ingredient("boards", 1)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, nil, nil, true)
Recipe("city_lamp", {Ingredient("alloy", 1), Ingredient("transistor", 1),Ingredient("lantern",1)}, RECIPETABS.CITY,  TECH.CITY, cityRecipeGameTypes, "city_lamp_placer", nil, true)

Recipe("pighouse_city", {Ingredient("boards", 4), Ingredient("cutstone", 3), Ingredient("pigskin", 4)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, "pighouse_city_placer", nil, true)

Recipe("pig_shop_deli", {Ingredient("boards", 4), Ingredient("honeyham", 1), Ingredient("pigskin", 4)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, "pig_shop_deli_placer", nil, true)
Recipe("pig_shop_general", {Ingredient("boards", 4), Ingredient("axe", 3), Ingredient("pigskin", 4)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, "pig_shop_general_placer", nil, true)

Recipe("pig_shop_hoofspa", {Ingredient("boards", 4), Ingredient("bandage", 3), Ingredient("pigskin", 4)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, "pig_shop_hoofspa_placer", nil, true)
Recipe("pig_shop_produce", {Ingredient("boards", 4), Ingredient("eggplant", 3), Ingredient("pigskin", 4)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, "pig_shop_produce_placer", nil, true)

Recipe("pig_shop_florist", {Ingredient("boards", 4), Ingredient("petals", 12), Ingredient("pigskin", 4)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, "pig_shop_florist_placer", nil, true)
Recipe("pig_shop_antiquities", {Ingredient("boards", 4), Ingredient("ballpein_hammer", 3), Ingredient("pigskin", 4)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, "pig_shop_antiquities_placer", nil, true)

Recipe("pig_shop_arcane", {Ingredient("boards", 4), Ingredient("nightmarefuel", 1), Ingredient("pigskin", 4)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, "pig_shop_arcane_placer", nil, true)
Recipe("pig_shop_weapons", {Ingredient("boards", 4), Ingredient("spear", 3), Ingredient("pigskin", 4)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, "pig_shop_weapons_placer", nil, true)
Recipe("pig_shop_hatshop", {Ingredient("boards", 4), Ingredient("tophat", 2), Ingredient("pigskin", 4)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, "pig_shop_hatshop_placer", nil, true)
Recipe("pig_shop_bank", {Ingredient("cutstone", 4), Ingredient("goldnugget", 2), Ingredient("pigskin", 4)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, "pig_shop_bank_placer", nil, true)

Recipe("pig_shop_tinker", {Ingredient("magnifying_glass", 2), Ingredient("pigskin", 4)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, "pig_shop_tinker_placer", nil, true)

Recipe("pig_shop_cityhall_player", {Ingredient("boards", 4), Ingredient("goldnugget", 4), Ingredient("pigskin", 4)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, "pig_shop_cityhall_placer", nil, true)

Recipe("pig_guard_tower", {Ingredient("cutstone", 3), Ingredient("halberd", 1), Ingredient("pigskin", 4)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, "pig_guard_tower_placer", nil, true)

Recipe("securitycontract", {Ingredient("oinc", 10)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, nil, nil, true)

Recipe("playerhouse_city", {Ingredient("boards", 4), Ingredient("cutstone", 3), Ingredient("oinc", 30)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, "playerhouse_city_placer", nil, true)

Recipe("hedge_block_item", {Ingredient("clippings", 9), Ingredient("nitre", 1)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, nil, nil, true, 3)
Recipe("hedge_cone_item", {Ingredient("clippings", 9), Ingredient("nitre", 1)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, nil, nil, true, 3)
Recipe("hedge_layered_item", {Ingredient("clippings", 9), Ingredient("nitre", 1)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, nil, nil, true, 3)

Recipe("lawnornament_1", {Ingredient("oinc", 10)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, "lawnornament_1_placer", 1, true)
Recipe("lawnornament_2", {Ingredient("oinc", 10)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, "lawnornament_2_placer", 1, true)
Recipe("lawnornament_3", {Ingredient("oinc", 10)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, "lawnornament_3_placer", 1, true)
Recipe("lawnornament_4", {Ingredient("oinc", 10)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, "lawnornament_4_placer", 1, true)
Recipe("lawnornament_5", {Ingredient("oinc", 10)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, "lawnornament_5_placer", 1, true)
Recipe("lawnornament_6", {Ingredient("oinc", 10)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, "lawnornament_6_placer", 1, true)
Recipe("lawnornament_7", {Ingredient("oinc", 10)}, RECIPETABS.CITY, TECH.CITY, cityRecipeGameTypes, "lawnornament_7_placer", 1, true)


-- TINKER SHOP BLUEPRINT ITEMS
Recipe("eyebrellahat", {Ingredient("deerclops_eyeball", 1), Ingredient("twigs", 15), Ingredient("boneshard", 4)}, RECIPETABS.DRESS,  TECH.LOST, cityRecipeGameTypes)
Recipe("cane", {Ingredient("goldnugget", 2), Ingredient("walrus_tusk", 1), Ingredient("twigs", 4)}, RECIPETABS.DRESS,  TECH.LOST, cityRecipeGameTypes)
Recipe("icepack", {Ingredient("bearger_fur", 1), Ingredient("gears", 3), Ingredient("transistor", 3)}, RECIPETABS.SURVIVAL, TECH.LOST, cityRecipeGameTypes)
Recipe("staff_tornado", {Ingredient("goose_feather", 10), Ingredient("lightninggoathorn", 1), Ingredient("gears", 1)}, RECIPETABS.WAR,  TECH.LOST, cityRecipeGameTypes)
Recipe("armordragonfly", {Ingredient("dragon_scales", 1), Ingredient("armorwood", 1), Ingredient("pigskin", 3)}, RECIPETABS.WAR,  TECH.LOST, cityRecipeGameTypes)
Recipe("dragonflychest", {Ingredient("dragon_scales", 1), Ingredient("boards", 4), Ingredient("goldnugget", 10)}, RECIPETABS.TOWN, TECH.LOST, cityRecipeGameTypes, "dragonflychest_placer", 1.5)
Recipe("molehat", {Ingredient("mole", 2), Ingredient("transistor", 2), Ingredient("wormlight", 1)}, RECIPETABS.LIGHT,  TECH.SCIENCE_TWO, cityRecipeGameTypes)
Recipe("beargervest", {Ingredient("bearger_fur", 1), Ingredient("sweatervest", 1), Ingredient("rope", 2)}, RECIPETABS.DRESS,  TECH.SCIENCE_TWO, cityRecipeGameTypes)
Recipe("ox_flute", {Ingredient("ox_horn", 1), Ingredient("nightmarefuel", 2), Ingredient("rope", 1)}, RECIPETABS.MAGIC,  TECH.MAGIC_TWO, cityRecipeGameTypes)

--- HOME ---
--Recipe("exterior_villa", {Ingredient("boards",10)}, RENO_RECIPETABS.HOME, TECH.HOME_TWO, RECIPE_GAME_TYPE.PORKLAND, nil, nil, true)

--Recipe("exterior_villa", {Ingredient("boards",10)}, RENO_RECIPETABS.HOME, TECH.HOME_TWO, RECIPE_GAME_TYPE.PORKLAND, nil, nil, true)
Recipe("player_house_cottage_craft",	{Ingredient("oinc",10)}, RENO_RECIPETABS.HOME_KITS, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)
Recipe("player_house_tudor_craft",		{Ingredient("oinc",10)}, RENO_RECIPETABS.HOME_KITS, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)
Recipe("player_house_gothic_craft",		{Ingredient("oinc",10)}, RENO_RECIPETABS.HOME_KITS, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)
Recipe("player_house_brick_craft",		{Ingredient("oinc",10)}, RENO_RECIPETABS.HOME_KITS, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)
Recipe("player_house_turret_craft",		{Ingredient("oinc",10)}, RENO_RECIPETABS.HOME_KITS, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)
Recipe("player_house_villa_craft",		{Ingredient("oinc",30)}, RENO_RECIPETABS.HOME_KITS, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)
Recipe("player_house_manor_craft",		{Ingredient("oinc",30)}, RENO_RECIPETABS.HOME_KITS, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)

Recipe("deco_chair_classic", 		{Ingredient("oinc",2)}, 		RENO_RECIPETABS.CHAIRS, TECH.HOME_TWO, cityRecipeGameTypes, "chair_classic_placer",	nil, true, nil, nil, nil, true, false, "reno_chair_classic")
Recipe("deco_chair_corner", 		{Ingredient("oinc",2)}, 		RENO_RECIPETABS.CHAIRS, TECH.HOME_TWO, cityRecipeGameTypes, "chair_corner_placer",	nil, true, nil, nil, nil, true, true, "reno_chair_corner")
Recipe("deco_chair_bench", 			{Ingredient("oinc",2)}, 		RENO_RECIPETABS.CHAIRS, TECH.HOME_TWO, cityRecipeGameTypes, "chair_bench_placer",		nil, true, nil, nil, nil, true, true, "reno_chair_bench")
Recipe("deco_chair_horned", 		{Ingredient("oinc",2)}, 		RENO_RECIPETABS.CHAIRS, TECH.HOME_TWO, cityRecipeGameTypes, "chair_horned_placer",	nil, true, nil, nil, nil, true, true, "reno_chair_horned")
Recipe("deco_chair_footrest", 		{Ingredient("oinc",2)}, 		RENO_RECIPETABS.CHAIRS, TECH.HOME_TWO, cityRecipeGameTypes, "chair_footrest_placer",	nil, true, nil, nil, nil, true, true, "reno_chair_footrest")
Recipe("deco_chair_lounge", 		{Ingredient("oinc",2)}, 		RENO_RECIPETABS.CHAIRS, TECH.HOME_TWO, cityRecipeGameTypes, "chair_lounge_placer",	nil, true, nil, nil, nil, true, true, "reno_chair_lounge")
Recipe("deco_chair_massager", 		{Ingredient("oinc",2)}, 		RENO_RECIPETABS.CHAIRS, TECH.HOME_TWO, cityRecipeGameTypes, "chair_massager_placer",	nil, true, nil, nil, nil, true, true, "reno_chair_massager")
Recipe("deco_chair_stuffed", 		{Ingredient("oinc",2)}, 		RENO_RECIPETABS.CHAIRS, TECH.HOME_TWO, cityRecipeGameTypes, "chair_stuffed_placer",	nil, true, nil, nil, nil, true, true, "reno_chair_stuffed")
Recipe("deco_chair_rocking", 		{Ingredient("oinc",2)}, 		RENO_RECIPETABS.CHAIRS, TECH.HOME_TWO, cityRecipeGameTypes, "chair_rocking_placer",	nil, true, nil, nil, nil, true, true, "reno_chair_rocking")
Recipe("deco_chair_ottoman", 		{Ingredient("oinc",2)}, 		RENO_RECIPETABS.CHAIRS, TECH.HOME_TWO, cityRecipeGameTypes, "chair_ottoman_placer",	nil, true, nil, nil, nil, true, true, "reno_chair_ottoman")

Recipe("shelves_wood", 				{Ingredient("oinc",2)}, 		RENO_RECIPETABS.SHELVES, TECH.HOME_TWO, cityRecipeGameTypes, "shelves_wood_placer",			nil, true, nil, nil, nil, true, false, "reno_shelves_wood", 		true)
Recipe("shelves_basic",				{Ingredient("oinc",2)}, 		RENO_RECIPETABS.SHELVES, TECH.HOME_TWO, cityRecipeGameTypes, "shelves_basic_placer",			nil, true, nil, nil, nil, true, false, "reno_shelves_basic", 		true)
Recipe("shelves_cinderblocks", 		{Ingredient("oinc",1)}, 		RENO_RECIPETABS.SHELVES, TECH.HOME_TWO, cityRecipeGameTypes, "shelves_cinderblocks_placer",	nil, true, nil, nil, nil, true, false, "reno_shelves_cinderblocks", true)
Recipe("shelves_marble", 			{Ingredient("oinc",8)}, 		RENO_RECIPETABS.SHELVES, TECH.HOME_TWO, cityRecipeGameTypes, "shelves_marble_placer",			nil, true, nil, nil, nil, true, false, "reno_shelves_marble", true)
Recipe("shelves_glass",				{Ingredient("oinc",8)}, 		RENO_RECIPETABS.SHELVES, TECH.HOME_TWO, cityRecipeGameTypes, "shelves_glass_placer",			nil, true, nil, nil, nil, true, false, "reno_shelves_glass", true)
Recipe("shelves_ladder",			{Ingredient("oinc",8)}, 		RENO_RECIPETABS.SHELVES, TECH.HOME_TWO, cityRecipeGameTypes, "shelves_ladder_placer",			nil, true, nil, nil, nil, true, false, "reno_shelves_ladder", true)
Recipe("shelves_hutch",				{Ingredient("oinc",8)}, 		RENO_RECIPETABS.SHELVES, TECH.HOME_TWO, cityRecipeGameTypes, "shelves_hutch_placer",			nil, true, nil, nil, nil, true, false, "reno_shelves_hutch", true)
Recipe("shelves_industrial",		{Ingredient("oinc",8)}, 		RENO_RECIPETABS.SHELVES, TECH.HOME_TWO, cityRecipeGameTypes, "shelves_industrial_placer",		nil, true, nil, nil, nil, true, false, "reno_shelves_industrial", true)
Recipe("shelves_adjustable",		{Ingredient("oinc",8)}, 		RENO_RECIPETABS.SHELVES, TECH.HOME_TWO, cityRecipeGameTypes, "shelves_adjustable_placer",		nil, true, nil, nil, nil, true, false, "reno_shelves_adjustable", true)
Recipe("shelves_midcentury", 		{Ingredient("oinc",6)}, 		RENO_RECIPETABS.SHELVES, TECH.HOME_TWO, cityRecipeGameTypes, "shelves_midcentury_placer",		nil, true, nil, nil, nil, true, false, "reno_shelves_midcentury", true)
Recipe("shelves_wallmount",			{Ingredient("oinc",6)}, 		RENO_RECIPETABS.SHELVES, TECH.HOME_TWO, cityRecipeGameTypes, "shelves_wallmount_placer",		nil, true, nil, nil, nil, true, false, "reno_shelves_wallmount", true)
Recipe("shelves_aframe",			{Ingredient("oinc",6)}, 		RENO_RECIPETABS.SHELVES, TECH.HOME_TWO, cityRecipeGameTypes, "shelves_aframe_placer",			nil, true, nil, nil, nil, true, false, "reno_shelves_aframe", true)
Recipe("shelves_crates",			{Ingredient("oinc",6)}, 		RENO_RECIPETABS.SHELVES, TECH.HOME_TWO, cityRecipeGameTypes, "shelves_crates_placer",			nil, true, nil, nil, nil, true, false, "reno_shelves_crates", true)
Recipe("shelves_fridge",			{Ingredient("oinc",6)}, 		RENO_RECIPETABS.SHELVES, TECH.HOME_TWO, cityRecipeGameTypes, "shelves_fridge_placer",			nil, true, nil, nil, nil, true, false, "reno_shelves_fridge", true)
Recipe("shelves_floating",			{Ingredient("oinc",6)}, 		RENO_RECIPETABS.SHELVES, TECH.HOME_TWO, cityRecipeGameTypes, "shelves_floating_placer",		nil, true, nil, nil, nil, true, false, "reno_shelves_floating", true)
Recipe("shelves_pipe",				{Ingredient("oinc",6)}, 		RENO_RECIPETABS.SHELVES, TECH.HOME_TWO, cityRecipeGameTypes, "shelves_pipe_placer",			nil, true, nil, nil, nil, true, false, "reno_shelves_pipe", true)
Recipe("shelves_hattree",			{Ingredient("oinc",6)}, 		RENO_RECIPETABS.SHELVES, TECH.HOME_TWO, cityRecipeGameTypes, "shelves_hattree_placer",		nil, true, nil, nil, nil, true, false, "reno_shelves_hattree", true)
Recipe("shelves_pallet",			{Ingredient("oinc",6)}, 		RENO_RECIPETABS.SHELVES, TECH.HOME_TWO, cityRecipeGameTypes, "shelves_pallet_placer",			nil, true, nil, nil, nil, true, false, "reno_shelves_pallet", true)

Recipe("rug_round", 		{Ingredient("oinc",2)}, 			RENO_RECIPETABS.RUGS, TECH.HOME_TWO, cityRecipeGameTypes, "rug_round_placer",		nil, true, nil, nil, nil, true, true, "reno_rug_round")
Recipe("rug_square", 		{Ingredient("oinc",2)}, 			RENO_RECIPETABS.RUGS, TECH.HOME_TWO, cityRecipeGameTypes, "rug_square_placer",	nil, true, nil, nil, nil, true, true, "reno_rug_square")
Recipe("rug_oval", 			{Ingredient("oinc",2)}, 			RENO_RECIPETABS.RUGS, TECH.HOME_TWO, cityRecipeGameTypes, "rug_oval_placer",		nil, true, nil, nil, nil, true, true, "reno_rug_oval")
Recipe("rug_rectangle", 	{Ingredient("oinc",3)}, 			RENO_RECIPETABS.RUGS, TECH.HOME_TWO, cityRecipeGameTypes, "rug_rectangle_placer",	nil, true, nil, nil, nil, true, true, "reno_rug_rectangle")
Recipe("rug_fur", 			{Ingredient("oinc",5)}, 			RENO_RECIPETABS.RUGS, TECH.HOME_TWO, cityRecipeGameTypes, "rug_fur_placer",		nil, true, nil, nil, nil, true, true, "reno_rug_fur")
Recipe("rug_hedgehog", 		{Ingredient("oinc",5)}, 			RENO_RECIPETABS.RUGS, TECH.HOME_TWO, cityRecipeGameTypes, "rug_hedgehog_placer",	nil, true, nil, nil, nil, true, true, "reno_rug_hedgehog")
Recipe("rug_porcupuss", 	{Ingredient("oinc",10)}, 			RENO_RECIPETABS.RUGS, TECH.HOME_TWO, cityRecipeGameTypes, "rug_porcupuss_placer",	nil, true, nil, nil, nil, true, true, "reno_rug_porcupuss")
Recipe("rug_hoofprint", 	{Ingredient("oinc",5)}, 			RENO_RECIPETABS.RUGS, TECH.HOME_TWO, cityRecipeGameTypes, "rug_hoofprint_placer",	nil, true, nil, nil, nil, true, true, "reno_rug_hoofprint")
Recipe("rug_octagon",		{Ingredient("oinc",5)}, 			RENO_RECIPETABS.RUGS, TECH.HOME_TWO, cityRecipeGameTypes, "rug_octagon_placer",	nil, true, nil, nil, nil, true, true, "reno_rug_octagon")
Recipe("rug_swirl",			{Ingredient("oinc",5)}, 			RENO_RECIPETABS.RUGS, TECH.HOME_TWO, cityRecipeGameTypes, "rug_swirl_placer",		nil, true, nil, nil, nil, true, true, "reno_rug_swirl")
Recipe("rug_catcoon",		{Ingredient("oinc",5)}, 			RENO_RECIPETABS.RUGS, TECH.HOME_TWO, cityRecipeGameTypes, "rug_catcoon_placer",	nil, true, nil, nil, nil, true, true, "reno_rug_catcoon")
Recipe("rug_rubbermat",		{Ingredient("oinc",5)}, 			RENO_RECIPETABS.RUGS, TECH.HOME_TWO, cityRecipeGameTypes, "rug_rubbermat_placer",	nil, true, nil, nil, nil, true, true, "reno_rug_rubbermat")
Recipe("rug_web",			{Ingredient("oinc",5)}, 			RENO_RECIPETABS.RUGS, TECH.HOME_TWO, cityRecipeGameTypes, "rug_web_placer",		nil, true, nil, nil, nil, true, true, "reno_rug_web")
Recipe("rug_metal",			{Ingredient("oinc",5)}, 			RENO_RECIPETABS.RUGS, TECH.HOME_TWO, cityRecipeGameTypes, "rug_metal_placer",		nil, true, nil, nil, nil, true, true, "reno_rug_metal")
Recipe("rug_wormhole",		{Ingredient("oinc",5)}, 			RENO_RECIPETABS.RUGS, TECH.HOME_TWO, cityRecipeGameTypes, "rug_wormhole_placer",	nil, true, nil, nil, nil, true, true, "reno_rug_wormhole")
Recipe("rug_braid",			{Ingredient("oinc",5)}, 			RENO_RECIPETABS.RUGS, TECH.HOME_TWO, cityRecipeGameTypes, "rug_braid_placer",		nil, true, nil, nil, nil, true, true, "reno_rug_braid")
Recipe("rug_beard",			{Ingredient("oinc",5)}, 			RENO_RECIPETABS.RUGS, TECH.HOME_TWO, cityRecipeGameTypes, "rug_beard_placer",		nil, true, nil, nil, nil, true, true, "reno_rug_beard")
Recipe("rug_nailbed",		{Ingredient("oinc",5)}, 			RENO_RECIPETABS.RUGS, TECH.HOME_TWO, cityRecipeGameTypes, "rug_nailbed_placer",	nil, true, nil, nil, nil, true, true, "reno_rug_nailbed")
Recipe("rug_crime",			{Ingredient("oinc",5)}, 			RENO_RECIPETABS.RUGS, TECH.HOME_TWO, cityRecipeGameTypes, "rug_crime_placer",		nil, true, nil, nil, nil, true, true, "reno_rug_crime")
Recipe("rug_tiles",			{Ingredient("oinc",5)}, 			RENO_RECIPETABS.RUGS, TECH.HOME_TWO, cityRecipeGameTypes, "rug_tiles_placer",		nil, true, nil, nil, nil, true, true, "reno_rug_tiles")

Recipe("deco_chaise", 				{Ingredient("oinc",15)}, 	RENO_RECIPETABS.CHAIRS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_chaise_placer", nil, true, nil, nil, nil, true, true, "reno_chair_chaise")

Recipe("deco_lamp_fringe",        {Ingredient("oinc",8)}, 	RENO_RECIPETABS.LAMPS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_lamp_fringe_placer",			nil, true, nil, nil, nil, true, false, "reno_lamp_fringe")
Recipe("deco_lamp_stainglass",    {Ingredient("oinc",8)}, 	RENO_RECIPETABS.LAMPS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_lamp_stainglass_placer",		nil, true, nil, nil, nil, true, false, "reno_lamp_stainglass")
Recipe("deco_lamp_downbridge",    {Ingredient("oinc",8)}, 	RENO_RECIPETABS.LAMPS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_lamp_downbridge_placer",		nil, true, nil, nil, nil, true, true, "reno_lamp_downbridge")
Recipe("deco_lamp_2embroidered",  {Ingredient("oinc",8)}, 	RENO_RECIPETABS.LAMPS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_lamp_2embroidered_placer",	nil, true, nil, nil, nil, true, true, "reno_lamp_2embroidered")
Recipe("deco_lamp_ceramic",       {Ingredient("oinc",8)}, 	RENO_RECIPETABS.LAMPS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_lamp_ceramic_placer",		nil, true, nil, nil, nil, true, false, "reno_lamp_ceramic")
Recipe("deco_lamp_glass",         {Ingredient("oinc",8)}, 	RENO_RECIPETABS.LAMPS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_lamp_glass_placer",			nil, true, nil, nil, nil, true, false, "reno_lamp_glass")
Recipe("deco_lamp_2fringes",      {Ingredient("oinc",8)}, 	RENO_RECIPETABS.LAMPS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_lamp_2fringes_placer",		nil, true, nil, nil, nil, true, false, "reno_lamp_2fringes")
Recipe("deco_lamp_candelabra",    {Ingredient("oinc",8)}, 	RENO_RECIPETABS.LAMPS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_lamp_candelabra_placer",		nil, true, nil, nil, nil, true, false, "reno_lamp_candelabra")
Recipe("deco_lamp_elizabethan",   {Ingredient("oinc",8)}, 	RENO_RECIPETABS.LAMPS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_lamp_elizabethan_placer",	nil, true, nil, nil, nil, true, false, "reno_lamp_elizabethan")
Recipe("deco_lamp_gothic",        {Ingredient("oinc",8)}, 	RENO_RECIPETABS.LAMPS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_lamp_gothic_placer",			nil, true, nil, nil, nil, true, false, "reno_lamp_gothic")
Recipe("deco_lamp_orb",           {Ingredient("oinc",8)}, 	RENO_RECIPETABS.LAMPS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_lamp_orb_placer",			nil, true, nil, nil, nil, true, false, "reno_lamp_orb")
Recipe("deco_lamp_bellshade",     {Ingredient("oinc",8)}, 	RENO_RECIPETABS.LAMPS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_lamp_bellshade_placer",		nil, true, nil, nil, nil, true, true, "reno_lamp_bellshade")
Recipe("deco_lamp_crystals",      {Ingredient("oinc",8)}, 	RENO_RECIPETABS.LAMPS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_lamp_crystals_placer",		nil, true, nil, nil, nil, true, true, "reno_lamp_crystals")
Recipe("deco_lamp_upturn",        {Ingredient("oinc",8)}, 	RENO_RECIPETABS.LAMPS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_lamp_upturn_placer",			nil, true, nil, nil, nil, true, false, "reno_lamp_upturn")
Recipe("deco_lamp_2upturns",      {Ingredient("oinc",8)}, 	RENO_RECIPETABS.LAMPS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_lamp_2upturns_placer",		nil, true, nil, nil, nil, true, true, "reno_lamp_2upturns")
Recipe("deco_lamp_spool",         {Ingredient("oinc",8)}, 	RENO_RECIPETABS.LAMPS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_lamp_spool_placer",			nil, true, nil, nil, nil, true, false, "reno_lamp_spool")
Recipe("deco_lamp_edison",        {Ingredient("oinc",8)}, 	RENO_RECIPETABS.LAMPS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_lamp_edison_placer",			nil, true, nil, nil, nil, true, false, "reno_lamp_edison")
Recipe("deco_lamp_adjustable",    {Ingredient("oinc",8)}, 	RENO_RECIPETABS.LAMPS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_lamp_adjustable_placer",		nil, true, nil, nil, nil, true, true, "reno_lamp_adjustable")
Recipe("deco_lamp_rightangles",   {Ingredient("oinc",8)}, 	RENO_RECIPETABS.LAMPS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_lamp_rightangles_placer",	nil, true, nil, nil, nil, true, true, "reno_lamp_rightangles")
Recipe("deco_lamp_hoofspa", 	  {Ingredient("oinc",8)}, 	RENO_RECIPETABS.LAMPS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_lamp_hoofspa_placer",		nil, true, nil, nil, nil, true, true, "reno_lamp_hoofspa")

Recipe("deco_plantholder_basic",        {Ingredient("oinc",6)}, 	RENO_RECIPETABS.PLANT_HOLDERS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_plantholder_basic_placer",			nil, true, nil, nil, nil, true, true, "reno_plantholder_basic")
Recipe("deco_plantholder_wip",          {Ingredient("oinc",6)}, 	RENO_RECIPETABS.PLANT_HOLDERS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_plantholder_wip_placer",				nil, true, nil, nil, nil, true, true, "reno_plantholder_wip")
--Recipe("deco_plantholder_fancy",        {Ingredient("oinc",6)}, 	RENO_RECIPETABS.PLANT_HOLDERS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_plantholder_fancy_placer",			nil, true, nil, nil, nil, true, true, "reno_plantholder_fancy")
Recipe("deco_plantholder_marble",		{Ingredient("oinc",6)}, 	RENO_RECIPETABS.PLANT_HOLDERS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_plantholder_marble_placer",			nil, true, nil, nil, nil, true, true, "reno_plantholder_marble")
Recipe("deco_plantholder_bonsai",       {Ingredient("oinc",6)}, 	RENO_RECIPETABS.PLANT_HOLDERS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_plantholder_bonsai_placer",			nil, true, nil, nil, nil, true, true, "reno_plantholder_bonsai")
Recipe("deco_plantholder_dishgarden",   {Ingredient("oinc",6)}, 	RENO_RECIPETABS.PLANT_HOLDERS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_plantholder_dishgarden_placer",		nil, true, nil, nil, nil, true, true, "reno_plantholder_dishgarden")
Recipe("deco_plantholder_philodendron", {Ingredient("oinc",6)}, 	RENO_RECIPETABS.PLANT_HOLDERS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_plantholder_philodendron_placer",	nil, true, nil, nil, nil, true, true, "reno_plantholder_philodendron")
Recipe("deco_plantholder_orchid",       {Ingredient("oinc",6)}, 	RENO_RECIPETABS.PLANT_HOLDERS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_plantholder_orchid_placer",			nil, true, nil, nil, nil, true, true, "reno_plantholder_orchid")
Recipe("deco_plantholder_draceana",     {Ingredient("oinc",6)}, 	RENO_RECIPETABS.PLANT_HOLDERS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_plantholder_draceana_placer",		nil, true, nil, nil, nil, true, true, "reno_plantholder_draceana")
Recipe("deco_plantholder_xerographica", {Ingredient("oinc",6)}, 	RENO_RECIPETABS.PLANT_HOLDERS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_plantholder_xerographica_placer",	nil, true, nil, nil, nil, true, true, "reno_plantholder_xerographica")
Recipe("deco_plantholder_birdcage",     {Ingredient("oinc",6)}, 	RENO_RECIPETABS.PLANT_HOLDERS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_plantholder_birdcage_placer",		nil, true, nil, nil, nil, true, true, "reno_plantholder_birdcage")
Recipe("deco_plantholder_palm",         {Ingredient("oinc",6)}, 	RENO_RECIPETABS.PLANT_HOLDERS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_plantholder_palm_placer",			nil, true, nil, nil, nil, true, true, "reno_plantholder_palm")
Recipe("deco_plantholder_zz",           {Ingredient("oinc",6)}, 	RENO_RECIPETABS.PLANT_HOLDERS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_plantholder_zz_placer",				nil, true, nil, nil, nil, true, true, "reno_plantholder_zz")
Recipe("deco_plantholder_fernstand",    {Ingredient("oinc",6)}, 	RENO_RECIPETABS.PLANT_HOLDERS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_plantholder_fernstand_placer",		nil, true, nil, nil, nil, true, true, "reno_plantholder_fernstand")
Recipe("deco_plantholder_fern",         {Ingredient("oinc",6)}, 	RENO_RECIPETABS.PLANT_HOLDERS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_plantholder_fern_placer",			nil, true, nil, nil, nil, true, true, "reno_plantholder_fern")
Recipe("deco_plantholder_terrarium",    {Ingredient("oinc",6)}, 	RENO_RECIPETABS.PLANT_HOLDERS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_plantholder_terrarium_placer",		nil, true, nil, nil, nil, true, true, "reno_plantholder_terrarium")
Recipe("deco_plantholder_plantpet",     {Ingredient("oinc",6)}, 	RENO_RECIPETABS.PLANT_HOLDERS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_plantholder_plantpet_placer",		nil, true, nil, nil, nil, true, true, "reno_plantholder_plantpet")
Recipe("deco_plantholder_traps",        {Ingredient("oinc",6)}, 	RENO_RECIPETABS.PLANT_HOLDERS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_plantholder_traps_placer",			nil, true, nil, nil, nil, true, true, "reno_plantholder_traps")
Recipe("deco_plantholder_pitchers",     {Ingredient("oinc",6)}, 	RENO_RECIPETABS.PLANT_HOLDERS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_plantholder_pitchers_placer",		nil, true, nil, nil, nil, true, true, "reno_plantholder_pitchers")


Recipe("deco_plantholder_winterfeasttreeofsadness",		{Ingredient("oinc",2),Ingredient("twigs",1)}, 	cityRecipeGameTypes, TECH.HOME_TWO, cityRecipeGameTypes, "deco_plantholder_winterfeasttreeofsadness_placer", nil, true, nil, nil, nil, true, true, "reno_plantholder_winterfeasttreeofsadness")
Recipe("deco_plantholder_winterfeasttree",              {Ingredient("oinc",50)}, 	                    cityRecipeGameTypes, TECH.HOME_TWO, cityRecipeGameTypes, "deco_plantholder_winterfeasttree_placer",			 nil, true, nil, nil, nil, true, false, "reno_lamp_festivetree") 

Recipe("deco_table_round", 			{Ingredient("oinc",2)}, 	RENO_RECIPETABS.TABLES, TECH.HOME_TWO, cityRecipeGameTypes, "deco_table_round_placer",	nil, true, nil, nil, nil, true, true, "reno_table_round")
Recipe("deco_table_banker", 		{Ingredient("oinc",4)}, 	RENO_RECIPETABS.TABLES, TECH.HOME_TWO, cityRecipeGameTypes, "deco_table_banker_placer",	nil, true, nil, nil, nil, true, false, "reno_table_banker")
Recipe("deco_table_diy", 			{Ingredient("oinc",3)}, 	RENO_RECIPETABS.TABLES, TECH.HOME_TWO, cityRecipeGameTypes, "deco_table_diy_placer",		nil, true, nil, nil, nil, true, true, "reno_table_diy")
Recipe("deco_table_raw", 			{Ingredient("oinc",1)}, 	RENO_RECIPETABS.TABLES, TECH.HOME_TWO, cityRecipeGameTypes, "deco_table_raw_placer",		nil, true, nil, nil, nil, true, false, "reno_table_raw")
Recipe("deco_table_crate", 			{Ingredient("oinc",1)}, 	RENO_RECIPETABS.TABLES, TECH.HOME_TWO, cityRecipeGameTypes, "deco_table_crate_placer",	nil, true, nil, nil, nil, true, true, "reno_table_crate")
Recipe("deco_table_chess", 			{Ingredient("oinc",1)}, 	RENO_RECIPETABS.TABLES, TECH.HOME_TWO, cityRecipeGameTypes, "deco_table_chess_placer",	nil, true, nil, nil, nil, true, false, "reno_table_chess")

Recipe("deco_wallornament_photo",				{Ingredient("oinc",2)}, 						RENO_RECIPETABS.ORNAMENTS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_wallornament_photo_placer",               nil, true, nil, nil, nil, true, false, "reno_wallornament_photo", true)
--Recipe("deco_wallornament_fulllength_mirror",	{Ingredient("oinc",10)}, 						RENO_RECIPETABS.ORNAMENTS, TECH.HOME_TWO, RECIPE_GAME_TYPE.PORKLAND, "deco_wallornament_fulllength_mirror_placer",   nil, true, nil, nil, nil, true, false, "reno_wallornament_fulllength_mirror", true)
Recipe("deco_wallornament_embroidery_hoop",		{Ingredient("oinc",3)}, 						RENO_RECIPETABS.ORNAMENTS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_wallornament_embroidery_hoop_placer",     nil, true, nil, nil, nil, true, false, "reno_wallornament_embroidery_hoop", true)
Recipe("deco_wallornament_mosaic",				{Ingredient("oinc",4)}, 						RENO_RECIPETABS.ORNAMENTS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_wallornament_mosaic_placer",              nil, true, nil, nil, nil, true, false, "reno_wallornament_mosaic", true)
Recipe("deco_wallornament_wreath",				{Ingredient("oinc",4)}, 						RENO_RECIPETABS.ORNAMENTS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_wallornament_wreath_placer",              nil, true, nil, nil, nil, true, false, "reno_wallornament_wreath", true)
Recipe("deco_wallornament_axe",					{Ingredient("oinc",5),	Ingredient("axe",1)}, 	RENO_RECIPETABS.ORNAMENTS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_wallornament_axe_placer",                 nil, true, nil, nil, nil, true, false, "reno_wallornament_axe", true)
Recipe("deco_wallornament_hunt",				{Ingredient("oinc",5),	Ingredient("spear",1)}, RENO_RECIPETABS.ORNAMENTS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_wallornament_hunt_placer",                nil, true, nil, nil, nil, true, false, "reno_wallornament_hunt", true)
Recipe("deco_wallornament_periodic_table",		{Ingredient("oinc",5)}, 						RENO_RECIPETABS.ORNAMENTS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_wallornament_periodic_table_placer",      nil, true, nil, nil, nil, true, false, "reno_wallornament_periodic_table", true)
Recipe("deco_wallornament_gears_art",			{Ingredient("oinc",8)}, 						RENO_RECIPETABS.ORNAMENTS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_wallornament_gears_art_placer",           nil, true, nil, nil, nil, true, false, "reno_wallornament_gears_art", true)
Recipe("deco_wallornament_cape",				{Ingredient("oinc",5)}, 						RENO_RECIPETABS.ORNAMENTS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_wallornament_cape_placer",                nil, true, nil, nil, nil, true, false, "reno_wallornament_cape", true)
Recipe("deco_wallornament_no_smoking",			{Ingredient("oinc",3)}, 						RENO_RECIPETABS.ORNAMENTS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_wallornament_no_smoking_placer",          nil, true, nil, nil, nil, true, false, "reno_wallornament_no_smoking", true)
Recipe("deco_wallornament_black_cat",			{Ingredient("oinc",5)}, 						RENO_RECIPETABS.ORNAMENTS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_wallornament_black_cat_placer",           nil, true, nil, nil, nil, true, false, "reno_wallornament_black_cat", true)
Recipe("deco_antiquities_wallfish", 			{Ingredient("oinc",2),	Ingredient("fish",1)}, 	RENO_RECIPETABS.ORNAMENTS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_antiquities_wallfish_placer",			 nil, true, nil, nil, nil, true, false, "reno_antiquities_wallfish", true)
Recipe("deco_antiquities_beefalo", 				{Ingredient("oinc",10),	Ingredient("horn",1)}, 	RENO_RECIPETABS.ORNAMENTS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_antiquities_beefalo_placer",				 nil, true, nil, nil, nil, true, false, "reno_antiquities_beefalo", true)

--Recipe("window_round_curtains_nails", 		{Ingredient("boards", 2)}, 									RENO_RECIPETABS.HOME, TECH.HOME_TWO, RECIPE_GAME_TYPE.PORKLAND, "window_round_curtains_nails_placer", nil, true, nil, nil, nil, true)
Recipe("window_small_peaked_curtain", 		{Ingredient("oinc",3)}, 	RENO_RECIPETABS.WINDOWS, TECH.HOME_TWO, cityRecipeGameTypes, "window_small_peaked_curtain_placer", 	nil, true, nil, nil, nil, true, false, "reno_window_small_peaked_curtain", true)
Recipe("window_round_burlap", 				{Ingredient("oinc",3)}, 	RENO_RECIPETABS.WINDOWS, TECH.HOME_TWO, cityRecipeGameTypes, "window_round_burlap_placer", 			nil, true, nil, nil, nil, true, false, "reno_window_round_burlap", true)
Recipe("window_small_peaked", 				{Ingredient("oinc",3)}, 	RENO_RECIPETABS.WINDOWS, TECH.HOME_TWO, cityRecipeGameTypes, "window_small_peaked_placer", 			nil, true, nil, nil, nil, true, false, "reno_window_small_peaked", true)
Recipe("window_large_square", 				{Ingredient("oinc",4)}, 	RENO_RECIPETABS.WINDOWS, TECH.HOME_TWO, cityRecipeGameTypes, "window_large_square_placer",			nil, true, nil, nil, nil, true, false, "reno_window_large_square", true)
Recipe("window_tall",		 				{Ingredient("oinc",4)}, 	RENO_RECIPETABS.WINDOWS, TECH.HOME_TWO, cityRecipeGameTypes, "window_tall_placer",					nil, true, nil, nil, nil, true, false, "reno_window_tall", true)
Recipe("window_large_square_curtain", 		{Ingredient("oinc",5)}, 	RENO_RECIPETABS.WINDOWS, TECH.HOME_TWO, cityRecipeGameTypes, "window_large_square_curtain_placer",	nil, true, nil, nil, nil, true, false, "reno_window_large_square_curtain", true)
Recipe("window_tall_curtain",		 		{Ingredient("oinc",5)}, 	RENO_RECIPETABS.WINDOWS, TECH.HOME_TWO, cityRecipeGameTypes, "window_tall_curtain_placer",			nil, true, nil, nil, nil, true, false, "reno_window_tall_curtain", true)

Recipe("window_greenhouse",		 			{Ingredient("oinc",8)}, 	RENO_RECIPETABS.WINDOWS, TECH.HOME_TWO, cityRecipeGameTypes, "window_greenhouse_placer",			nil, true, nil, nil, nil, true, false, "reno_window_greenhouse", true)

Recipe("deco_wood", 						{Ingredient("oinc",1)}, 	RENO_RECIPETABS.COLUMNS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_wood_cornerbeam_placer",		nil, true, nil, nil, nil, true, false, "reno_cornerbeam_wood", true)
Recipe("deco_millinery",					{Ingredient("oinc",1)}, 	RENO_RECIPETABS.COLUMNS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_millinery_cornerbeam_placer",	nil, true, nil, nil, nil, true, false, "reno_cornerbeam_millinery", true)
Recipe("deco_round",						{Ingredient("oinc",1)},		RENO_RECIPETABS.COLUMNS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_round_cornerbeam_placer",		nil, true, nil, nil, nil, true, false, "reno_cornerbeam_round", true)
Recipe("deco_marble", 						{Ingredient("oinc",5)}, 	RENO_RECIPETABS.COLUMNS, TECH.HOME_TWO, cityRecipeGameTypes, "deco_marble_cornerbeam_placer",		nil, true, nil, nil, nil, true, false, "reno_cornerbeam_marble", true)

Recipe("interior_floor_wood", 				{Ingredient("oinc",5)}, 	RENO_RECIPETABS.FLOORING, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)
Recipe("interior_floor_marble", 			{Ingredient("oinc",15)}, 	RENO_RECIPETABS.FLOORING, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)
Recipe("interior_floor_check", 				{Ingredient("oinc",7)}, 	RENO_RECIPETABS.FLOORING, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)
Recipe("interior_floor_plaid_tile", 		{Ingredient("oinc",10)}, 	RENO_RECIPETABS.FLOORING, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)
Recipe("interior_floor_sheet_metal", 		{Ingredient("oinc",6)},		RENO_RECIPETABS.FLOORING, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)

Recipe("interior_floor_gardenstone", 		{Ingredient("oinc",10)},	RENO_RECIPETABS.FLOORING, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)
Recipe("interior_floor_geometrictiles", 	{Ingredient("oinc",12)},	RENO_RECIPETABS.FLOORING, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)
Recipe("interior_floor_shag_carpet", 		{Ingredient("oinc",6)},		RENO_RECIPETABS.FLOORING, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)
Recipe("interior_floor_transitional", 		{Ingredient("oinc",6)},		RENO_RECIPETABS.FLOORING, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)
Recipe("interior_floor_woodpanels", 		{Ingredient("oinc",10)},	RENO_RECIPETABS.FLOORING, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)
Recipe("interior_floor_herringbone", 		{Ingredient("oinc",12)},	RENO_RECIPETABS.FLOORING, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)
Recipe("interior_floor_hexagon",	 		{Ingredient("oinc",12)},	RENO_RECIPETABS.FLOORING, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)
Recipe("interior_floor_hoof_curvy",	 		{Ingredient("oinc",12)},	RENO_RECIPETABS.FLOORING, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)
Recipe("interior_floor_octagon",	 		{Ingredient("oinc",12)},	RENO_RECIPETABS.FLOORING, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)

Recipe("interior_wall_wood", 				{Ingredient("oinc",1)},		RENO_RECIPETABS.WALLPAPER, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)
Recipe("interior_wall_checkered", 			{Ingredient("oinc",6)},		RENO_RECIPETABS.WALLPAPER, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)
Recipe("interior_wall_floral", 				{Ingredient("oinc",6)},		RENO_RECIPETABS.WALLPAPER, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)
Recipe("interior_wall_sunflower", 			{Ingredient("oinc",6)},		RENO_RECIPETABS.WALLPAPER, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)
Recipe("interior_wall_harlequin", 			{Ingredient("oinc",10)}, 	RENO_RECIPETABS.WALLPAPER, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)

Recipe("interior_wall_peagawk", 			{Ingredient("oinc",6)}, 	RENO_RECIPETABS.WALLPAPER, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)
Recipe("interior_wall_plain_ds", 			{Ingredient("oinc",4)}, 	RENO_RECIPETABS.WALLPAPER, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)
Recipe("interior_wall_plain_rog", 			{Ingredient("oinc",4)}, 	RENO_RECIPETABS.WALLPAPER, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)
Recipe("interior_wall_rope", 				{Ingredient("oinc",6)}, 	RENO_RECIPETABS.WALLPAPER, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)
Recipe("interior_wall_circles", 			{Ingredient("oinc",10)}, 	RENO_RECIPETABS.WALLPAPER, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)
Recipe("interior_wall_marble", 				{Ingredient("oinc",15)}, 	RENO_RECIPETABS.WALLPAPER, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)
Recipe("interior_wall_mayorsoffice",		{Ingredient("oinc",15)}, 	RENO_RECIPETABS.WALLPAPER, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)
Recipe("interior_wall_fullwall_moulding",	{Ingredient("oinc",15)}, 	RENO_RECIPETABS.WALLPAPER, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)
Recipe("interior_wall_upholstered",			{Ingredient("oinc",8)}, 	RENO_RECIPETABS.WALLPAPER, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)

Recipe("swinging_light_basic_bulb",			{Ingredient("oinc",5)},		RENO_RECIPETABS.HANGING_LAMPS, TECH.HOME_TWO, cityRecipeGameTypes, "swinging_light_basic_bulb_placer",			nil, true, nil, nil, nil, true, false, "reno_light_basic_bulb")
Recipe("swinging_light_basic_metal",		{Ingredient("oinc",6)}, 	RENO_RECIPETABS.HANGING_LAMPS, TECH.HOME_TWO, cityRecipeGameTypes, "swinging_light_basic_metal_placer",			nil, true, nil, nil, nil, true, false, "reno_light_basic_metal")
Recipe("swinging_light_chandalier_candles", {Ingredient("oinc",8)}, 	RENO_RECIPETABS.HANGING_LAMPS, TECH.HOME_TWO, cityRecipeGameTypes, "swinging_light_chandalier_candles_placer",	nil, true, nil, nil, nil, true, false, "reno_light_chandalier_candles")
Recipe("swinging_light_rope_1",				{Ingredient("oinc",1)}, 	RENO_RECIPETABS.HANGING_LAMPS, TECH.HOME_TWO, cityRecipeGameTypes, "swinging_light_rope_1_placer",				nil, true, nil, nil, nil, true, false, "reno_light_rope_1")
Recipe("swinging_light_rope_2",				{Ingredient("oinc",1)}, 	RENO_RECIPETABS.HANGING_LAMPS, TECH.HOME_TWO, cityRecipeGameTypes, "swinging_light_rope_2_placer",				nil, true, nil, nil, nil, true, false, "reno_light_rope_2")
Recipe("swinging_light_floral_bulb",		{Ingredient("oinc",10)}, 	RENO_RECIPETABS.HANGING_LAMPS, TECH.HOME_TWO, cityRecipeGameTypes, "swinging_light_floral_bulb_placer",			nil, true, nil, nil, nil, true, false, "reno_light_floral_bulb")
Recipe("swinging_light_pendant_cherries", 	{Ingredient("oinc",12)}, 	RENO_RECIPETABS.HANGING_LAMPS, TECH.HOME_TWO, cityRecipeGameTypes, "swinging_light_pendant_cherries_placer",		nil, true, nil, nil, nil, true, false, "reno_light_pendant_cherries")
Recipe("swinging_light_floral_scallop", 	{Ingredient("oinc",12)}, 	RENO_RECIPETABS.HANGING_LAMPS, TECH.HOME_TWO, cityRecipeGameTypes, "swinging_light_floral_scallop_placer",		nil, true, nil, nil, nil, true, false, "reno_light_floral_scallop")
Recipe("swinging_light_floral_bloomer", 	{Ingredient("oinc",12)}, 	RENO_RECIPETABS.HANGING_LAMPS, TECH.HOME_TWO, cityRecipeGameTypes, "swinging_light_floral_bloomer_placer",		nil, true, nil, nil, nil, true, false, "reno_light_floral_bloomer")
Recipe("swinging_light_tophat", 			{Ingredient("oinc",12)}, 	RENO_RECIPETABS.HANGING_LAMPS, TECH.HOME_TWO, cityRecipeGameTypes, "swinging_light_tophat_placer",				nil, true, nil, nil, nil, true, false, "reno_light_tophat")
Recipe("swinging_light_derby", 				{Ingredient("oinc",12)}, 	RENO_RECIPETABS.HANGING_LAMPS, TECH.HOME_TWO, cityRecipeGameTypes, "swinging_light_derby_placer",					nil, true, nil, nil, nil, true, false, "reno_light_derby")

-- DOORS
		--name, 		ingredients, 				tab, 					level,          game_type, 					placer,       min_spacing, nounlock, numtogive, aquatic, distance, decor, flipable, image, wallitem
Recipe("wood_door", 	{Ingredient("oinc", 10)}, 	RENO_RECIPETABS.DOORS, TECH.HOME_TWO, cityRecipeGameTypes, "wood_door_placer",    nil, true, nil, nil, nil, true, false, "wood_door",    true )
Recipe("stone_door",	{Ingredient("oinc", 10)}, 	RENO_RECIPETABS.DOORS, TECH.HOME_TWO, cityRecipeGameTypes, "stone_door_placer",   nil, true, nil, nil, nil, true, false, "stone_door",   true )
Recipe("organic_door", 	{Ingredient("oinc", 15)}, 	RENO_RECIPETABS.DOORS, TECH.HOME_TWO, cityRecipeGameTypes, "organic_door_placer", nil, true, nil, nil, nil, true, false, "organic_door", true )
Recipe("iron_door", 	{Ingredient("oinc", 15)}, 	RENO_RECIPETABS.DOORS, TECH.HOME_TWO, cityRecipeGameTypes, "iron_door_placer",    nil, true, nil, nil, nil, true, false, "iron_door",    true )
Recipe("curtain_door", 	{Ingredient("oinc", 15)}, 	RENO_RECIPETABS.DOORS, TECH.HOME_TWO, cityRecipeGameTypes, "curtain_door_placer", nil, true, nil, nil, nil, true, false, "curtain_door", true )
Recipe("plate_door", 	{Ingredient("oinc", 15)}, 	RENO_RECIPETABS.DOORS, TECH.HOME_TWO, cityRecipeGameTypes, "plate_door_placer", 	nil, true, nil, nil, nil, true, false, "plate_door",   true )
Recipe("round_door", 	{Ingredient("oinc", 20)}, 	RENO_RECIPETABS.DOORS, TECH.HOME_TWO, cityRecipeGameTypes, "round_door_placer", 	nil, true, nil, nil, nil, true, false, "round_door",   true )
Recipe("pillar_door", 	{Ingredient("oinc", 20)}, 	RENO_RECIPETABS.DOORS, TECH.HOME_TWO, cityRecipeGameTypes, "pillar_door_placer",  nil, true, nil, nil, nil, true, false, "pillar_door",  true )

Recipe("construction_permit", {Ingredient("oinc", 50)}, RECIPETABS.HOME, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)
Recipe("demolition_permit", {Ingredient("oinc", 10)}, 	RECIPETABS.HOME, TECH.HOME_TWO, cityRecipeGameTypes, nil, nil, true)

-- Recipes for the interior crafting categories
RecipeCategory("reno_tab_floors", 					RENO_RECIPETABS.FLOORING, 		RECIPETABS.HOME, TECH.HOME_TWO, cityRecipeGameTypes)
RecipeCategory("reno_tab_shelves", 					RENO_RECIPETABS.SHELVES, 		RECIPETABS.HOME, TECH.HOME_TWO, cityRecipeGameTypes)
RecipeCategory("reno_tab_plantholders", 			RENO_RECIPETABS.PLANT_HOLDERS, 	RECIPETABS.HOME, TECH.HOME_TWO, cityRecipeGameTypes)
RecipeCategory("reno_tab_columns", 					RENO_RECIPETABS.COLUMNS,		RECIPETABS.HOME, TECH.HOME_TWO, cityRecipeGameTypes)
RecipeCategory("reno_tab_wallpaper", 				RENO_RECIPETABS.WALLPAPER,		RECIPETABS.HOME, TECH.HOME_TWO, cityRecipeGameTypes)
RecipeCategory("reno_tab_hanginglamps", 			RENO_RECIPETABS.HANGING_LAMPS,	RECIPETABS.HOME, TECH.HOME_TWO, cityRecipeGameTypes)
RecipeCategory("reno_tab_chairs", 					RENO_RECIPETABS.CHAIRS,			RECIPETABS.HOME, TECH.HOME_TWO, cityRecipeGameTypes)
RecipeCategory("reno_tab_homekits", 				RENO_RECIPETABS.HOME_KITS,		RECIPETABS.HOME, TECH.HOME_TWO, cityRecipeGameTypes)
RecipeCategory("reno_tab_doors", 					RENO_RECIPETABS.DOORS, 			RECIPETABS.HOME, TECH.HOME_TWO, cityRecipeGameTypes)
RecipeCategory("reno_tab_windows", 					RENO_RECIPETABS.WINDOWS,		RECIPETABS.HOME, TECH.HOME_TWO, cityRecipeGameTypes)
RecipeCategory("reno_tab_rugs", 					RENO_RECIPETABS.RUGS,			RECIPETABS.HOME, TECH.HOME_TWO, cityRecipeGameTypes)
RecipeCategory("reno_tab_lamps", 					RENO_RECIPETABS.LAMPS,			RECIPETABS.HOME, TECH.HOME_TWO, cityRecipeGameTypes)
RecipeCategory("reno_tab_tables", 					RENO_RECIPETABS.TABLES,			RECIPETABS.HOME, TECH.HOME_TWO, cityRecipeGameTypes)
RecipeCategory("reno_tab_ornaments", 				RENO_RECIPETABS.ORNAMENTS,		RECIPETABS.HOME, TECH.HOME_TWO, cityRecipeGameTypes)