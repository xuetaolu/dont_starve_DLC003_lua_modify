local groundtiles = require "worldtiledefs"

local assets =
{
	Asset("IMAGE", "images/customisation.tex" ),
    Asset("ATLAS", "images/customisation.xml" ),
    Asset("IMAGE", "images/customization_shipwrecked.tex" ),
    Asset("ATLAS", "images/customization_shipwrecked.xml" ),
    Asset("IMAGE", "images/customization_porkland.tex" ),
    Asset("ATLAS", "images/customization_porkland.xml" ),

	Asset("IMAGE", "images/colour_cubes/day05_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/dusk03_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/night03_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/snow_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/snowdusk_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/night04_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/insane_day_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/insane_dusk_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/insane_night_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/summer_day_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/summer_dusk_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/summer_night_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/spring_day_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/spring_dusk_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/spring_night_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/purple_moon_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/sw_mild_day_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/sw_mild_dusk_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/sw_wet_day_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/sw_wet_dusk_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/sw_green_day_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/sw_green_dusk_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/sw_dry_day_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/sw_dry_dusk_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/sw_volcano_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/blank_cc.tex"),

	Asset("ANIM", "anim/snow.zip"),
	Asset("ANIM", "anim/lightning.zip"),
	Asset("ANIM", "anim/splash_ocean.zip"),
	Asset("ANIM", "anim/frozen.zip"),
	Asset("ANIM", "anim/ripple_build.zip"),

	--Asset("SOUND", "sound/forest_stream.fsb"),
	--Asset("SOUND", "sound/amb_stream.fsb"),
	--Asset("SOUND", "sound/goosemoose.fsb"),

	Asset("IMAGE", "levels/textures/snow.tex"),
	Asset("IMAGE", "levels/textures/mud.tex"),
	Asset("IMAGE", "images/wave.tex"),

	-- Those are assets whose prefabs come from the base game, but their assets come
    -- from DLC0002, so they're added here to make sure the build process doesn't break
    Asset("ANIM", "anim/abigail_flower.zip"),
    Asset("ANIM", "anim/lucy_axe.zip"),
    Asset("ANIM", "anim/rock_flintless.zip"),
    Asset("ANIM", "anim/hounds_tooth.zip"),
    Asset("ANIM", "anim/gridplacer.zip"),
    Asset("ANIM", "anim/bubbling_water.zip"),
    Asset("ANIM", "anim/shock_machines_fx.zip"), -- No idea where this one comes from...
    Asset("ANIM", "anim/eyebrella.zip"),
    Asset("ANIM", "anim/swap_eyebrella.zip"),

    Asset("SCRIPT", "scripts/prefabs/DLC0002.lua"),
    Asset("SCRIPT", "scripts/prefabs/landspawner.lua"),
    Asset("SCRIPT", "scripts/prefabs/brokenwalls.lua"),
    Asset("SCRIPT", "scripts/prefabs/poisonmistparticle.lua"),

--	Asset("ANIM", "anim/wave_long_build.zip"),
--	Asset("ANIM", "anim/wave_ripple_build.zip"),
--	Asset("ANIM", "anim/wave_shimmer_build.zip"),

	Asset("ANIM", "anim/bishop.zip"),
    Asset("ANIM", "anim/bishop_build.zip"),
    Asset("ANIM", "anim/bishop_nightmare.zip"),
    Asset("ANIM", "anim/flood_edge.zip"),
	Asset("ANIM", "anim/flood_tiles.zip"),
--	Asset("ANIM", "anim/flood_tiles2.zip"),
	Asset("ANIM", "anim/flotsam_debris.zip"),
	Asset("ANIM", "anim/koalephant_trunk.zip"),
	Asset("ANIM", "anim/pumpkin_lantern.zip"),
	Asset("ANIM", "anim/walrus_actions.zip"),
	Asset("ANIM", "anim/walrus_attacks.zip"),
	Asset("ANIM", "anim/walrus_basic.zip"),
	-- Asset("ANIM", "anim/warg_basic.zip"),


    Asset("INV_IMAGE", "sunken_boat_trinket_1"),
    Asset("INV_IMAGE", "sunken_boat_trinket_2"),
    Asset("INV_IMAGE", "sunken_boat_trinket_3"),
    Asset("INV_IMAGE", "sunken_boat_trinket_4"),
    Asset("INV_IMAGE", "sunken_boat_trinket_5"),


	Asset("INV_IMAGE", "bag"),
	Asset("INV_IMAGE", "bat"),
	Asset("INV_IMAGE", "batbat"),
	Asset("INV_IMAGE", "beemine"),
	Asset("INV_IMAGE", "teethmine"),
	Asset("INV_IMAGE", "chester_eyebone"),
	Asset("INV_IMAGE", "chester_eyebone_closed"),
	Asset("INV_IMAGE", "chester_eyebone_closed_shadow"),
	Asset("INV_IMAGE", "chester_eyebone_closed_snow"),
	Asset("INV_IMAGE", "chester_eyebone_shadow"),
	Asset("INV_IMAGE", "chester_eyebone_snow"),
	Asset("INV_IMAGE", "clothes"),
	Asset("INV_IMAGE", "dug_cactus"),
	Asset("INV_IMAGE", "eyebrella"),
	Asset("INV_IMAGE", "eyeturret_item"),
	Asset("INV_IMAGE", "horn"),
	Asset("INV_IMAGE", "skull_wallace"),
	Asset("INV_IMAGE", "skull_waverly"),
	Asset("INV_IMAGE", "skull_wilbur"),
	Asset("INV_IMAGE", "skull_wilton"),
	Asset("INV_IMAGE", "skull_winnie"),
	Asset("INV_IMAGE", "skull_wortox"),
	Asset("INV_IMAGE", "multitool_axe_pickaxe"),
	Asset("INV_IMAGE", "lightbulb"),
	Asset("INV_IMAGE", "slurper"),
	Asset("INV_IMAGE", "slurper_pelt"),
	Asset("INV_IMAGE", "researchlab4"),
	Asset("INV_IMAGE", "nightmare_timepiece"),
	Asset("INV_IMAGE", "nightmare_timepiece_nightmare"),
	Asset("INV_IMAGE", "nightmare_timepiece_warn"),
	Asset("INV_IMAGE", "pumpkin_lantern"),
	Asset("INV_IMAGE", "minotaurhorn"),
	Asset("INV_IMAGE", "phonograph"),
	Asset("INV_IMAGE", "record_01"),
	Asset("INV_IMAGE", "record_02"),
	Asset("INV_IMAGE", "record_03"),
	Asset("INV_IMAGE", "slurtle_shellpieces"),
	Asset("INV_IMAGE", "slurtlehat"),
	Asset("INV_IMAGE", "walrushat"),
	Asset("INV_IMAGE", "walrus_tusk"),
	Asset("INV_IMAGE", "ruins_bat"),
	Asset("INV_IMAGE", "trap_teeth"),
	Asset("INV_IMAGE", "scarecrow"),
	Asset("INV_IMAGE", "snowball"),
	Asset("INV_IMAGE", "stopwatch"),
	Asset("INV_IMAGE", "truffle"),
	Asset("INV_IMAGE", "tentaclespike"),
	Asset("INV_IMAGE", "accomplishment_shrine"),
	Asset("INV_IMAGE", "cane"),
	Asset("INV_IMAGE", "armorsnurtleshell"),
    Asset("INV_IMAGE", "trunk_cooked"),
	Asset("INV_IMAGE", "trunk_summer"),
	Asset("INV_IMAGE", "trunk_winter"),
	Asset("INV_IMAGE", "armormarble"),

	Asset("MINIMAP_IMAGE", "portal"),
    Asset("MINIMAP_IMAGE", "Willow"),
	Asset("MINIMAP_IMAGE", "Wilton"),
	Asset("MINIMAP_IMAGE", "parrot_pirate"),
	Asset("MINIMAP_IMAGE", "wheat"),
	Asset("MINIMAP_IMAGE", "winnie"),
	Asset("MINIMAP_IMAGE", "wortox"),
	Asset("MINIMAP_IMAGE", "phonograph"),
	Asset("MINIMAP_IMAGE", "pond"),
	Asset("MINIMAP_IMAGE", "pond_cave"),
	Asset("MINIMAP_IMAGE", "pond_mos"),
	Asset("MINIMAP_IMAGE", "abigail_flower"),
	Asset("MINIMAP_IMAGE", "accomplishment_shrine"),
	Asset("MINIMAP_IMAGE", "mushroom_tree"),
	Asset("MINIMAP_IMAGE", "mushroom_tree_med"),
	Asset("MINIMAP_IMAGE", "mushroom_tree_small"),
	Asset("MINIMAP_IMAGE", "basalt"),
	Asset("MINIMAP_IMAGE", "batcave"),
	Asset("MINIMAP_IMAGE", "beemine"),
	Asset("MINIMAP_IMAGE", "birdtrap"),
	Asset("MINIMAP_IMAGE", "bulb_plant"),
	Asset("MINIMAP_IMAGE", "cave_banana_tree"),
	Asset("MINIMAP_IMAGE", "chester"),
	Asset("MINIMAP_IMAGE", "chestershadow"),
	Asset("MINIMAP_IMAGE", "chestersnow"),
	Asset("MINIMAP_IMAGE", "gravestones"),
	Asset("MINIMAP_IMAGE", "statue"),
	Asset("MINIMAP_IMAGE", "statue_small"),
	Asset("MINIMAP_IMAGE", "marbletree"),
	Asset("MINIMAP_IMAGE", "pigking"),
	Asset("MINIMAP_IMAGE", "rabbittrap"),
	Asset("MINIMAP_IMAGE", "wormhole"),
	Asset("MINIMAP_IMAGE", "wormhole_sick"),
	Asset("MINIMAP_IMAGE", "whitespider_den"),
	Asset("MINIMAP_IMAGE", "stalagmite"),
	Asset("MINIMAP_IMAGE", "stalagmite_tall"),
	Asset("MINIMAP_IMAGE", "rock"),
	Asset("MINIMAP_IMAGE", "rock_flintless"),
	Asset("MINIMAP_IMAGE", "tentapillar"),
	Asset("MINIMAP_IMAGE", "slurtle_den"),
	Asset("MINIMAP_IMAGE", "diviningrod"),
	Asset("MINIMAP_IMAGE", "eyeball_turret"),
	Asset("MINIMAP_IMAGE", "eyeplant"),
	Asset("MINIMAP_IMAGE", "livingtree"),
	Asset("MINIMAP_IMAGE", "lucy_axe"),
	Asset("MINIMAP_IMAGE", "marblepillar"),
	Asset("MINIMAP_IMAGE", "maxwelltorch"),
	Asset("MINIMAP_IMAGE", "nightmarelight"),
	Asset("MINIMAP_IMAGE", "obelisk"),
	Asset("MINIMAP_IMAGE", "teleportato"),
	Asset("MINIMAP_IMAGE", "toothtrap"),
	Asset("MINIMAP_IMAGE", "teethmine"),
	Asset("MINIMAP_IMAGE", "wasphive"),
	Asset("MINIMAP_IMAGE", "researchlab4"),
	Asset("MINIMAP_IMAGE", "xspot"),

}

local shipwrecked_prefabs =
{
	"world",
	--"adventure_portal",
	"resurrectionstone",
	--"deerclops",
	"gravestone",
	"flower",
	"animal_track",
	"dirtpile",
	--"beefaloherd",
	--"beefalo",
	--"penguinherd",
	--"penguin_ice",
	--"penguin",
	"koalefant_summer",
	"koalefant_winter",
	"beehive",
	"wasphive",
	--"walrus_camp",
	"pighead",
	"mermhead",
	--"rabbithole",
	--"molehill",
	"carrot_planted",
	"tentacle",
	"wormhole",
	"cave_entrance",
	"teleportato_sw_base",
	"teleportato_sw_ring",
	"teleportato_sw_box",
	"teleportato_sw_crank",
	"teleportato_sw_potato",
	"pond",
	"marsh_tree",
	"marsh_bush",
	"mussel",
	"mussel_farm",
	"mussel_stick",
	"reeds",
	"mist",
	"snow",
	"rain",
	"ashfx",
	"maxwellthrone",
	"maxwellendgame",
	"maxwelllight",
	"maxwelllock",
	"maxwellphonograph",
	"puppet_wilson",
	"puppet_willow",
	"puppet_wendy",
	"puppet_wickerbottom",
	"puppet_wolfgang",
	"puppet_wx78",
	"puppet_wes",
	--"marblepillar",
	--"marbletree",
	--"statueharp",
	--"statuemaxwell",
	"eyeplant",
	"lureplant",
	"purpleamulet",
	"primeape",
	"livingtree",
	--"tumbleweed",
	"rock_ice",
	--"catcoonden",
	"bigfoot",

	"antivenom",
	"venomgland",
	"bermudatriangle",
	"buriedtreasure",
	"pike_skull",
	"fishinhole",
	-- "floodsource",
	-- "floodspawner",
	"messagebottle",
	"seashell",
	"seashell_beached",
	"telescope",
	"wave_ripple",
	"wave_shimmer",
	"wave_shore",
	"rogue_wave",
	"palmtree",
	"bambootree",
	"bush_vine",
	"snakeden",
	"crabhole",
	"jungletree",
	"seaweed",
	"limpetrock",
	"toucan",
	"parrot",
	"parrot_pirate",
	"seagull",
	"seagull_water",
    "waterseeds",
	"seagullspawner",
	"seatrap",
	"luggagechest",
	"sandbag",
--	"twister",
	"dubloon",
	"windswirl",
	"sand",
	"sandhill",
	"chiminea",
	"chimineafire",
	"splash_water",
	"splash_water_drop",
	"volcano",
	"obsidian",
	"firerain",
	"firerainshadow",
	"lavapool",
	"lobster",
	"lobsterhole",
	"earring",
	"cutlass",
	"ox",
	"oxherd",
	"babyox",
	"slotmachine",
	"ballphin",
	"ballphinhouse",
    "dorsalfin",
	"floater",
	"nubbin",
	"corallarve",
	"solofish",
	"woodlegs_cage",
	"woodlegs_key1",
	"woodlegs_key2",
	"woodlegs_key3",
	"doydoy",
	"doydoyegg",
	"doydoyherd",
	"doydoynest",
	"doydoybaby",
	"poisonhole",
	"coffeebush",
	"elephantcactus",
	"elephantcactus_active",
	"tigereye",
	"monkeyball",
	"packim",
	"oceanspawner",
	"stungray_spawner",
	"swordfish_spawner",
	"bioluminescence_spawner",
	"jellyfish_spawner",
	"rainbowjellyfish_spawner",
	"rainbowjellyfish",
	"rainbowjellyfish_planted",
	"windtrail",
	"coralreef",
	"haildrop",
	"hail",
	"poisonbubble",
	"poisonbubble_level1",
	"poisonbubble_level1_loop",
	"poisonbubble_level2",
	"poisonbubble_level2_loop",
	"poisonbubble_level3",
	"poisonbubble_level3_loop",
	"poisonbubble_level4",
	"poisonbubble_level4_loop",
	"portal_shipwrecked",
	"whale_blue",
	"whale_white",
	"crocodog",
	"houndstooth",
	"limestone",
	"armor_windbreaker",
	"armorcactus",
	"boatrepairkit",
	"bottlelantern",
	"sandcastle",
	"trident",
	"edgefog",
	"oceanfog",
	"harpoon",
	"dragoon",
	"dragoonegg",
	"dragoonegg_falling",
	"dragoonden",
	"dragoonheart",
	"dragoonheart_light",
	"sandbagsmall",
	"boatspawnpoint",
	"double_umbrellahat",
	"flamegeyser",
	"turf_magmafield",
	"turf_ash",
	"turf_tidalmarsh",
	"turf_lavarock",
	"turf_volcano",
	"magmarock",
	"magmarock_gold",
	"flupspawner",
	"piratepack",
	"coral_brain_rock",
	"tunacan",
	"peg_leg",
	"grass_water",
	"sunkenprefab",
	"mangrovetree",
	"octopusking",
	"redbarrel",
	"wallyintro",
	"tidalpool",
	"mermhouse_fisher",
	"livingjungletree",
	"beachresurrector",
	"ballphin_spawner",
	"DLC0002",
	"butterfly_areaspawner",
	"landspawner",
	"player_common",
	"mailpack", -- Can be removed from here once we add Watricia
	"rawling",
	"boat_indicator",
	"wildbore",
	"sweet_potato_planted",
	"lavalight",
	"poisonmistarea",
	"poisonmistparticle",
	"shock_fx",
	-- ROG stuff we're adding for future reference/need
	"armorslurper",
	"brokenwalls",
	"bell",
	"guano",
	"mosslingherd",
	"obsidianfirefire",
	"perd",
	"pollen",
	"rubble",
	"slurtleslime",
	"trunk",
	"tumbleweedspawner",
	"wormlight",
	"sweet_potato_planted",
	"treeguard",
	"tree_creak_emitter",
	"lightninggoatherd",
	"mysterymeat",
	"soundplayer",

	"shark_teethhat",
	"wildborehead",
	"devtool",
	"chess_navy_spawner",
	"tigershark",
	"sharkittenspawner",
	"crate",
	"buoy",
	"twister",
	"wilbur_unlock",
	"shipwrecked_entrance",
	"shipwrecked_exit",

	"sunken_boat_trinket_1",
	"sunken_boat_trinket_2",
	"sunken_boat_trinket_3",
	"sunken_boat_trinket_4",
	"sunken_boat_trinket_5",

	"flotsam_basegame",

	"wreck",
	"kraken",
	"inventorygrave",
	"inventorywaterygrave",
	"inventorymound",
	"woodlegshat",
	"spear_launcher",
	"pirateghost",
	"waterygrave",

	"knightboat",

	-- quackenloot
	"quackenbeak",
	"quackeringram",
	"quackering_charge_fx",
	"quackering_wake",
	"quackering_wave",

	"tar", 
	"tar_pool",
	"tar_extractor",
	"sea_yard",	
	"fish_farm",
	"tarlamp",
	"tarsuit",
	"roe",
	"seaweed_stalk",
	"mussel_bed",	

	--Can't obtain these anymore but keep them in for older saves
	"speargun",
	"speargun_poison",
	"woodlegsboat",
	"woodlegs_cannonshot",

	"sharx",

	"deflated_balloon",	
}

local function OnSeasonChange(inst, data)
	--disable the overlay for now
	--[[if data.season == "spring" then
		inst.Map:SetOverlayTexture( "levels/textures/mud.tex" )
		inst.Map:SetOverlayColor0( 11/255,15/255,23/255,.30 )
		inst.Map:SetOverlayColor1( 11/255,15/255,23/255,.20 )
		inst.Map:SetOverlayColor2( 11/255,15/255,23/255,.12 )
	elseif data.season == "winter" then
		inst.Map:SetOverlayTexture( "levels/textures/snow.tex" )
		inst.Map:SetOverlayColor0( 1,1,1,1 )
		inst.Map:SetOverlayColor1( 1,1,1,1 )
		inst.Map:SetOverlayColor2( 1,1,1,1 )
	end]]--
end

local function SetupSeason(inst)
	print("tropical")
	inst.components.seasonmanager:Tropical()
end

local function fn(Sim)
	print("shipwrecked")
	local inst = SpawnPrefab("world")
	inst:AddTag("shipwrecked")
	inst.prefab = "shipwrecked"
	inst.entity:SetCanSleep(false)

	local flooding = inst.entity:AddFlooding()

	for i, data in ipairs( groundtiles.flooding ) do
		local tile_type, props = unpack( data )
		local handle = MapLayerManager:CreateRenderLayer(
				tile_type,
				resolvefilepath(GroundAtlas( props.name )),
				resolvefilepath(GroundImage( props.name )),
				resolvefilepath(props.noise_texture ) )
		flooding:AddRenderLayer( handle )
	end

	inst.Map:SetFlooringType(GROUND.BEARDRUG)
	inst.Map:SetFlooringType(GROUND.LAWN)
	inst.Map:SetFlooringType(GROUND.FOUNDATION)
	inst.Map:SetFlooringType(GROUND.COBBLEROAD)
	inst.Map:SetFlooringType(GROUND.FIELDS)	
	inst.Map:SetFlooringType(GROUND.DEEPRAINFOREST_NOCANOPY)	
	

	inst:AddComponent("clock")
	inst:AddComponent("seasonmanager")
	inst:AddComponent("rainbowjellymigration")
	inst:AddComponent("flooding")
	SetupSeason(inst)
	--inst:DoTaskInTime(0, SetupSeason)
	inst:AddComponent("flowerspawner")
	inst:AddComponent("lureplantspawner")
	inst:AddComponent("birdspawner")
	inst:AddComponent("butterflyspawner")
	inst:AddComponent("mosquitospawner")
	inst:AddComponent("hounded")
	inst:AddComponent("whalehunter")
	inst:AddComponent("ocean")
	inst:AddComponent("wavemanager")
	inst:AddComponent("volcanomanager")
	inst:AddComponent("globalsettings")

	inst:AddComponent("basehassler")
	local hasslers = require("basehasslers")
	for k,v in pairs(hasslers) do
		inst.components.basehassler:AddHassler(k, v)
	end

	inst.components.butterflyspawner:SetButterfly("butterfly")
	--inst.components.butterflyspawner:SpawnModeHeavy()

	inst:AddComponent("worldwind")

	--inst:AddComponent("frograin")
	--inst:AddComponent("bigfooter")
	--inst:AddComponent("penguinspawner")

	--inst:AddComponent("doydoyspawner") --added in world.lua

	inst:AddComponent("chessnavy")

	inst:AddComponent("debugger")

	inst:AddComponent("tigersharker")
	inst:DoTaskInTime(0, function()
		inst.components.tigersharker:TrackTarget(GetPlayer())
		inst.components.tigersharker:FindHome()
	end)

	inst:AddComponent("colourcubemanager")
	inst.Map:SetOverlayTexture( "levels/textures/snow.tex" )
	inst.Map:SetOverlayColor0( 1,1,1,1 )
	inst.Map:SetOverlayColor1( 1,1,1,1 )
	inst.Map:SetOverlayColor2( 1,1,1,1 )

	inst:ListenForEvent("seasonChange", OnSeasonChange)

	return inst
end

return Prefab( "worlds/shipwrecked", fn, assets, shipwrecked_prefabs)
