require "hamletislandconnector"

local assets =
{
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

	Asset("IMAGE", "images/colour_cubes/pork_temperate_day_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/pork_temperate_dusk_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/pork_temperate_night_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/pork_temperate_fullmoon_cc.tex"),

	Asset("IMAGE", "images/colour_cubes/pork_cold_day_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/pork_cold_dusk_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/pork_cold_night_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/pork_cold_fullmoon_cc.tex"),

	Asset("IMAGE", "images/colour_cubes/pork_warm_day_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/pork_warm_dusk_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/pork_warm_night_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/pork_warm_fullmoon_cc.tex"),

	Asset("IMAGE", "images/colour_cubes/pork_lush_dusk_test.tex"),
	Asset("IMAGE", "images/colour_cubes/pork_lush_day_test.tex"),

	Asset("IMAGE", "images/colour_cubes/pork_warm_bloodmoon_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/pork_temperate_bloodmoon_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/pork_cold_bloodmoon_cc.tex"),

	Asset("IMAGE", "images/fog_cloud.tex"),	
	Asset("IMAGE", "levels/textures/snow.tex"),
	Asset("IMAGE", "levels/textures/mud.tex"),
	Asset("IMAGE", "images/wave.tex"),

	Asset("IMAGE", "images/tree.tex"),
	
	Asset("INV_IMAGE", "bananas"),
	Asset("INV_IMAGE", "bananas_cooked"),
	Asset("INV_IMAGE", "butterflywings_tropical"),
	Asset("INV_IMAGE", "butterfly_tropical"),
	Asset("INV_IMAGE", "conch"),
	Asset("INV_IMAGE", "freshfruitcrepes"),
	Asset("INV_IMAGE", "monstertartare"),
	Asset("INV_IMAGE", "musselbouillabaise"),
	Asset("INV_IMAGE", "portablecookpot_item"),
	Asset("INV_IMAGE", "shark_tooth"),
	Asset("INV_IMAGE", "spear_wathgrithr"),
	Asset("INV_IMAGE", "spicepack"),
	Asset("INV_IMAGE", "stunrod"),
	Asset("INV_IMAGE", "surfboard_item"),
	Asset("INV_IMAGE", "sweetpoatosouffle"),
	Asset("INV_IMAGE", "volcanohat_on"),
	Asset("INV_IMAGE", "volcanohat_off"),
	Asset("INV_IMAGE", "wathgrithrhat"),

    Asset("ANIM", "anim/hat_snakeskin_scaly.zip"),
	Asset("INV_IMAGE", "snakeskinhat_scaly"),
	Asset("INV_IMAGE", "snakeskinsail_scaly"),
    Asset("INV_IMAGE", "armor_snakeskin_scaly"), 
    Asset("INV_IMAGE", "snakeskin_scaly"),     

	Asset("INV_IMAGE", "dug_nettle"),

	Asset("INV_IMAGE", "health_max"),	
	Asset("INV_IMAGE", "health_down"),
	Asset("INV_IMAGE", "half_health"),
	Asset("INV_IMAGE", "decrease_health"),
	Asset("INV_IMAGE", "sanity_max"),	
	Asset("INV_IMAGE", "sanity_down"),
	Asset("INV_IMAGE", "half_sanity"),
	Asset("INV_IMAGE", "decrease_sanity"),	

	Asset("MINIMAP_IMAGE", "warbucks"),
--	Asset("MINIMAP_IMAGE", "wilba"),

    Asset("ANIM", "anim/snow.zip"),
    Asset("ANIM", "anim/lightning.zip"),
    Asset("ANIM", "anim/splash_ocean.zip"),
    Asset("ANIM", "anim/frozen.zip"),

	Asset("SOUNDPACKAGE", "sound/dontstarve_DLC003.fev"),
    Asset("SOUND", "sound/DLC003_AMB_stream.fsb"), 
    Asset("SOUND", "sound/DLC003_sfx.fsb"),
    Asset("SOUND", "sound/forest_stream.fsb"),
    --Asset("SOUND", "sound/amb_stream.fsb"),
}

local forest_prefabs = 
{
	"DLC0003",
	"world",
	"adventure_portal",
	"resurrectionstone",
    "deerclops",
    "gravestone",
    "flower",
    "animal_track",
    "dirtpile",
    "beefaloherd",
    "beefalo",
    "penguinherd",
    "penguin_ice",
    "penguin",
    "koalefant_summer",
    "koalefant_winter",
    "beehive",
	"wasphive",
    "walrus_camp",
    "pighead",
    "mermhead",
    "rabbithole",
    "molehill",
    "carrot_planted",
    "tentacle",
	"wormhole",
    "cave_entrance",
	"teleportato_base",
	"teleportato_ring",
	"teleportato_box",
	"teleportato_crank",
	"teleportato_potato",
	"pond", 
	"marsh_tree", 
	"marsh_bush", 
	"reeds", 
	"mist",
	"poisonmist",
	"snow",
	"rain",
	"maxwellthrone",
	"maxwellendgame",
	"maxwelllight",
	"horizontal_maxwelllight",	
	"vertical_maxwelllight",	
	"quad_maxwelllight",	
	"area_maxwelllight",	
	"maxwelllock",
	"maxwellphonograph",
	"puppet_wilson",
	"puppet_willow",
	"puppet_wendy",
	"puppet_wickerbottom",
	"puppet_wolfgang",
	"puppet_wx78",
	"puppet_wes",
	"marblepillar",
	"marbletree",
	"statueharp",
	"statuemaxwell",
	"eyeplant",
	"lureplant",
	"purpleamulet",
	"monkey",
	"livingtree",
	"tumbleweed",
	"rock_ice",
	"catcoonden",
	"bigfoot",
	"inventorygrave",
	"flotsam",
	"flotsam_debris",
	"pighouse_trader",
	"shop_spawner",
	"batcavemanager",
	"shop_trinket",
	"acorn_door",
	"side_door",
	"generic_door",
	"generic_interior",
	"generic_interior_art",
	"generic_wall_side",
	"generic_wall_back",
	"test_interior_floor",
	"test_interior_pole",
	"pigthought",
	"pigtrader", 
	"pigshop",
	"vampirebatcave_potential",
	"peagawk",
	"peekhen",
	"circlingpeekhen",
	"peekhenspawner",
	"peagawkfeather",
	"peagawkfeather_prism",
	"peagawk_bush",
	"pig_palace",
	
	"shop_buyer", 
	"shop_seller",

	"tree_pillar",
	"vampirebat",
	"vampirebatcave",

	"pig_shop_academy",
	"pig_shop_cityhall",

	"pigman_collector",
	"pigman_banker",
	"pigman_beautician",
	"pigman_florist",
	"pigman_mayor",
	"pigman_mechanic",
	"pigman_royalguard",
	"pigman_storeowner",
	"pigman_shopkeep",

	"pigbandit",
	"pigbanditexit",

	"pighouse_city",
	"pig_guard_tower",

	"deep_jungle_fern_noise",

	"city_lamp",
	"city_lamp_inside",

	"dungbeetle",
	"dungpile",

	"spider_monkey",
	-- "spider_monkey_nest",
	"spider_monkey_tree",
	"spider_monkey_herd",
	 
	"lawnornament_1",
	"lawnornament_2",
	"lawnornament_3",
	"lawnornament_4",
	"lawnornament_5",
	"lawnornament_6",
	"lawnornament_7",

	"topiary_1",
	"topiary_2",
	"topiary_3",
	"topiary_4",
		
	"hedge_block",
	"hedge_cone",
	"hedge_layered",

	"mean_flytrap",
	"adult_flytrap", 
	--"nice_flytrap",
	"snapdragon",
	"snapdragonherd",
	"whisperpod",

	"wall_test",

	"pigeon",
	"pigeon_swarm",
	"reconstruction_project",

	"rainforesttree",
	"lightrays",

	"flower_rainforest",	
	"halberd",

	"pig_ruins_entrance",
	"test_interior_floor",
	"test_interior_pole",
	"grass_tall",
	"grass_tall_patch",
	"porkland_entrance",
	--"rogsupport",	
	"glowfly",
	"prop_door",
	"grabbing_vine",
	"hanging_vine",
	"zebherd",
	"hippoherd",

	"wall_interior",
	"floor_interior",
	"scorpion",
	"piko",
	"antman",
	"anthill",
	"anthill_exit",
	"antqueen_chambers",
	"antqueen_throne",
	"pheromonestone",
	"relic_1",
	"relic_2",
	"relic_3",
	"relic_4",
	"relic_5",	
	"walkingstick",
	"gasarea",
	"lilypad",
	"grass_water",
	"reeds_water",
	"interior_spawn_origin",
	"interior_spawn_storage",
	"lotus",
	"lotus_flower",
	"pig_ruins_torch",
	"pig_ruins_head",
	"pig_ruins_artichoke",
	"pig_ruins_pig",
	"pig_ruins_ant",
	"rabid_beetle",
	"oinc",
	"oinc10",
	"oinc100",
	"cloudpuff",

	"acorn_light",
	"kingfisher",
	"parrot_blue",
	"burr",
	"hippopotamoose",
	"antcombhome",
	--"cloud_spawner",
	"playerhouse_city",
	"mandrakeman",
	"mandrakehouse",

	"interior_floor_marble",
	"spider_monkey_herd",
	"rock_flippable",
	"jellybug",
	"slugbug",
	"bill",
	"giantgrub",

	"player_house_villa",
	"player_house_cottage_craft",
	"player_house_villa_craft",

	"clippings",
	"antsuit",
	"antmaskhat",
	"gasmaskhat",
	"pithhat",
	"thunderhat",
	"bandithat",
	"peagawkfeatherhat",
	"pigcrownhat",
	"bathat",
	"hayfeverhat",

	"candlehat",
	"candlefire",

	"porkland_intro_basket",
	"porkland_intro_balloon",
	"porkland_intro_trunk",
	"porkland_intro_suitcase",

	"porkland_intro_wormwood",

	"bramble",	
	"bramblespike",
	"nettle",

	"ro_bin",

	"deco_ruins_fountain",
	-- "honeychest",
	"warbucks",
	"wilba",
	"wheeler",

	"pugalisk",
	"pugalisk_fountain",
	"pugalisk_ruins_pillar",
	"pugalisk_trap_door",

	"ant_cave_lantern",
	"rock_antcave",

	"teatree",
	"wall_pig_ruins",
	"antchest",
	"nectar_pod",
	"disarming_kit",
	"pig_ruins_pigman_relief_dart1",
	"pig_ruins_pigman_relief_dart2",
	"pig_ruins_pigman_relief_dart3",
	"pig_ruins_pigman_relief_dart4",
	"pig_ruins_pigman_relief_leftside_dart",
	"pig_ruins_pigman_relief_rightside_dart",
	"waterfall",
	"pig_ruins_spear_trap",
	"pig_ruins_light_beam",
	"ballpein_hammer",
	"gold_dust",
	"chicken",
    "aloe_planted",
    "asparagus_planted",
    "radish_planted",

    "clawpalmtree",
    "shears",
    "magnifying_glass",

    "iron",
    
	"deco_accademy_barrier",
    "deco_accademy_barrier_vert",
    "deco_accademy_vause",
    "deco_accademy_graniteblock",
    "deco_accademy_potterywheel_urn",
    "deco_accademy_potterywheel",
    "deco_accademy_anvil",
    "deco_accademy_table_books",
    "deco_accademy_cornerbeam",
    "deco_accademy_beam",
    "deco_accademy_pig_king_painting",

	"deco_antiquities_screamcatcher",
    "deco_antiquities_windchime",
    "deco_antiquities_cornerbeam",
    "deco_antiquities_cornerbeam2",
    "deco_antiquities_endbeam",
    "deco_antiquities_beefalo_side",
    "deco_antiquities_beefalo",
    "deco_antiquities_wallfish_side",
    "deco_antiquities_wallfish",
    "deco_antiquities_pallet_sidewall",
    "deco_antiquities_wallpaper_rip1",
    "deco_antiquities_wallpaper_rip2",
    "deco_antiquities_wallpaper_rip3",
    "deco_antiquities_walllight",

	"deco_chair_classic",
    "deco_chair_corner",
    "deco_chair_bench",
    "deco_chair_horned",
    "deco_chair_footrest",
    "deco_chair_lounge",
    "deco_chair_massager",
    "deco_chair_stuffed",
    "deco_chair_rocking",
    "deco_chair_ottoman",

	"deco_florist_vines1",
    "deco_florist_vines2",
    "deco_florist_vines3",

    "deco_florist_hangingplant1",
    "deco_florist_hangingplant2",

    "deco_florist_plantholder",
    "deco_florist_latice_front",
    "deco_florist_latice_side",
    "deco_florist_pillar_front",
    "deco_florist_pillar_side",
    "deco_florist_picture",
    "deco_florist_cagedplant",

	"deco_lamp_fringe",
    "deco_lamp_stainglass",
    "deco_lamp_downbridge",
    "deco_lamp_2embroidered",
    "deco_lamp_ceramic",
    "deco_lamp_glass",
    "deco_lamp_2fringes",
    "deco_lamp_candelabra",
    "deco_lamp_elizabethan",
    "deco_lamp_gothic",
    "deco_lamp_orb",
    "deco_lamp_bellshade",
    "deco_lamp_crystals",
    "deco_lamp_upturn",
    "deco_lamp_2upturns",
    "deco_lamp_spool",
    "deco_lamp_edison",
    "deco_lamp_adjustable",
    "deco_lamp_rightangles",
    "deco_lamp_hoofspa",

	"deco_plantholder_basic",
    "deco_plantholder_wip",
    "deco_plantholder_fancy",
    "deco_plantholder_bonsai",
    "deco_plantholder_dishgarden",
    "deco_plantholder_philodendron",
    "deco_plantholder_orchid",
    "deco_plantholder_draceana",
    "deco_plantholder_xerographica",
    "deco_plantholder_birdcage",
    "deco_plantholder_palm",
    "deco_plantholder_zz",
    "deco_plantholder_fernstand",
    "deco_plantholder_fern",
    "deco_plantholder_terrarium",
    "deco_plantholder_plantpet",
    "deco_plantholder_traps",
    "deco_plantholder_pitchers",
    "deco_plantholder_marble",

	"deco_table_crate",
    "deco_table_raw",
    "deco_table_diy",
    "deco_table_round",
    "deco_table_banker",
    "deco_table_chess",

	"swinging_light_basic_bulb",
    "swinging_light_floral_bloomer",
    "swinging_light_basic_metal",
    "swinging_light_chandalier_candles",
    "swinging_light_rope_1",
    "swinging_light_rope_2",
    "swinging_light_floral_bulb",
    "swinging_light_pendant_cherries",
    "swinging_light_floral_scallop",
    "swinging_light_floral_bloomer",
    "swinging_light_tophat",
    "swinging_light_derby",

	"deco_wallornament_photo",
	"deco_wallornament_fulllength_mirror",
	"deco_wallornament_embroidery_hoop",
	"deco_wallornament_mosaic",
	"deco_wallornament_wreath",
	"deco_wallornament_axe",
	"deco_wallornament_hunt",
	"deco_wallornament_periodic_table",
	"deco_wallornament_gears_art",
	"deco_wallornament_cape",
	"deco_wallornament_no_smoking",
	"deco_wallornament_black_cat",

	"thunderbirdnest",
	"thunderbird",

	"weevole",
	"armor_weevole",

	"tubertree",
	"cork",
	"cork_bat",
	"corkboat",
	"corkboat_item",

	"bat_hide",

	"ancient_robot_ribs",
	"ancient_robot_claw",
	"ancient_robot_leg",
	
	"laser",
	"clawpalmtree_sapling",

	"sedimentpuddle",
	
	"goldpan",

	"musac",
	"pogherd",
	"pog",

	"pangolden",

	"roc",
	"cave_entrance_roc",
	"cave_exit_roc",

	"gnatmound",

	"smelter",
	"basefan",

	"sprinkler",
	"water_pipe",
	"hatpropeller",

	"alloy",
	"armor_metalplate",
	"bugrepellent",

	"jungle_border_vine",	
    "key_to_city",	
    "city_hammer",
    "ancient_herald",

    "pig_ruins_dart_statue",

    "house_door",
    "ancient_hulk",

	"teleportato_hamlet_base",
	"teleportato_hamlet_ring",
	"teleportato_hamlet_box",
	"teleportato_hamlet_crank",
	"teleportato_hamlet_potato",

}

local function OnSeasonChange(inst, data)
	--print("Plateau")
	--inst.components.seasonmanager:Plateau()
end

local function SetupSeason(inst)
	print("Plateau")
	inst.components.seasonmanager:Plateau()
end

-- one-time world repair to connect disconnected island fragments
local function ConnectIslands(inst)
	if not inst.connectedIslands then
		DetectDisconnectedIslands()
		inst:DoTaskInTime(1, function()
								FixDisconnectedIslands()
							end)
		inst.connectedIslands = true
	end
end

local function OnSave(inst, data)
	data.connectedIslands = inst.connectedIslands
end

local function OnLoad(inst, data)
	if data then
		inst.connectedIslands = data.connectedIslands
	end
end

local function fn(Sim)
	print("porkland")
	local inst = SpawnPrefab("world")
	inst:AddTag("porkland")
	inst.prefab = "porkland"
	inst.entity:SetCanSleep(false)

	local clouds = inst.entity:AddCloudComponent()
    clouds:SetRegionSize(13.5, 2.5)						-- wave texture u repeat, forward distance between waves
    clouds:SetCloudSize(80, 3.5)							-- wave mesh width and height
	clouds:SetCloudTexture("images/fog_cloud.tex")

	-- See source\game\components\WaveRegion.h
	clouds:SetCloudEffect("shaders/waves.ksh") -- texture.ksh

    inst:AddComponent("clock")
	inst:AddComponent("seasonmanager")
    inst:AddComponent("aporkalypse")
	
	SetupSeason(inst)
	inst:DoTaskInTime(0, function(inst) inst.components.seasonmanager:SetOverworld() end)
    
    inst:AddComponent("flowerspawner")    
    inst:AddComponent("flowerspawner_rainforest")     
    inst:AddComponent("birdspawner")
    inst:AddComponent("butterflyspawner")
    inst:AddComponent("glowflyspawner")    
	inst:AddComponent("giantgrubspawner")
	inst:AddComponent("batted")
	inst:AddComponent("banditmanager")	
	inst.components.economy:AddCity(2)
	
	inst:AddComponent("basehassler")
	inst:AddComponent("ripplemanager")
	inst:AddComponent("cloudpuffmanager")	
	inst:AddComponent("bramblemanager")
	inst:AddComponent("shadowmanager")
	inst:AddComponent("rocmanager")	


	inst:AddComponent("cityalarms")
	inst.components.cityalarms:AddCity(1)
	inst.components.cityalarms:AddCity(2)

	--inst:AddComponent("lureplantspawner")
	--inst:AddComponent("hunter")	

	local is_rog = IsDLCInstalled(REIGN_OF_GIANTS)
	if is_rog then
		inst:AddComponent("worlddeciduoustreeupdater")
		
		local hasslers = require("basehasslers")
		for k,v in pairs(hasslers) do
			inst.components.basehassler:AddHassler(k, v)
		end	
	end
	
    inst.components.butterflyspawner:SetButterfly("butterfly")

    inst:AddComponent("worldwind")
   	
   	inst:AddComponent("quaker_interior")
   	inst.components.quaker_interior:SetNextQuakes(false)

	inst:AddComponent("bigfooter")	

	inst:AddComponent("colourcubemanager")
	inst.Map:SetOverlayTexture( "levels/textures/snow.tex" )
	inst.Map:SetOverlayColor0( 1,1,1,1 )
	inst.Map:SetOverlayColor1( 1,1,1,1 )
	inst.Map:SetOverlayColor2( 1,1,1,1 )

	inst:ListenForEvent("seasonChange", OnSeasonChange)

	inst:AddComponent("canopymanager")
	inst.components.canopymanager:SetRotSpeed(1/5) -- 1.5
	inst.components.canopymanager:SetTransSpeed(1/5) -- 2
	inst.components.canopymanager:SetMaxRotation(20)
	inst.components.canopymanager:SetMaxTranslation(1)
	inst.components.canopymanager:SetScale(6)
	inst.components.canopymanager:SetMinStrength(0.2)	-- modified by ambient
	inst.components.canopymanager:SetMaxStrength(0.7)	-- modified by ambient
	inst.components.canopymanager:SetTexture("images/tree.tex")
	inst.components.canopymanager:SetEnabled(true)
	inst.components.canopymanager:SetTileTypes(IS_CANOPY_TILE)

	inst:DoTaskInTime(1,
		function(inst)
			local numWaterfalls = inst.Map:GetNumWaterfalls()

			for i = 1, numWaterfalls, 1 do
				local x, y, z = inst.Map:GetWaterfallPosition(i - 1)

				if x and y and z then
					local waterfall = SpawnPrefab("waterfall")
					waterfall.Transform:SetPosition(x, y, z)
				end
			end
		end)

	local oldOnSave = inst.OnSave
	inst.OnSave = function(inst, data) 
				      	oldOnSave(inst, data) 
					  	OnSave(inst,data)
				   end
	local oldOnLoad = inst.OnLoad
    inst.OnLoad = function(inst, data) 
						oldOnLoad(inst,data) 
						OnLoad(inst,data) 
					end
	inst.ConnectIslands = ConnectIslands
    return inst
end

return Prefab( "worlds/porkland", fn, assets, forest_prefabs)