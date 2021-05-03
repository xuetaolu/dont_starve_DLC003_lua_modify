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

	Asset("IMAGE", "images/colour_cubes/deep_jungle_dusk_cc.tex"),
	Asset("IMAGE", "images/colour_cubes/blank_cc.tex"),

    Asset("ANIM", "anim/snow.zip"),
    Asset("ANIM", "anim/lightning.zip"),
    Asset("ANIM", "anim/splash_ocean.zip"),
    Asset("ANIM", "anim/frozen.zip"),

    Asset("SOUND", "sound/forest_stream.fsb"),
    --Asset("SOUND", "sound/amb_stream.fsb"),

	Asset("IMAGE", "levels/textures/snow.tex"),
	Asset("IMAGE", "levels/textures/mud.tex"),
	Asset("IMAGE", "images/wave.tex"),
}

local forest_prefabs = 
{
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

	"deflated_balloon",	
	"spat",
}

local function OnSeasonChange(inst, data)
	if data.season == "spring" then
		inst.Map:SetOverlayTexture( "levels/textures/mud.tex" )
		inst.Map:SetOverlayColor0( 11/255,15/255,23/255,.30 )
		inst.Map:SetOverlayColor1( 11/255,15/255,23/255,.20 )
		inst.Map:SetOverlayColor2( 11/255,15/255,23/255,.12 )
	elseif data.season == "winter" then
		inst.Map:SetOverlayTexture( "levels/textures/snow.tex" )
		inst.Map:SetOverlayColor0( 1,1,1,1 )
		inst.Map:SetOverlayColor1( 1,1,1,1 )
		inst.Map:SetOverlayColor2( 1,1,1,1 )
	end
end

local function fn(Sim)
	local inst = SpawnPrefab("world")
	inst.prefab = "forest"
	inst.entity:SetCanSleep(false)	
	
	--add waves
	local waves = inst.entity:AddWaveComponent()
    inst.WaveComponent:SetRegionSize(13.5, 2.5)						-- wave texture u repeat, forward distance between waves
    inst.WaveComponent:SetWaveSize(80, 3.5)							-- wave mesh width and height
	waves:SetWaveTexture( "images/wave.tex" )

	-- See source\game\components\WaveRegion.h
	waves:SetWaveEffect( "shaders/waves.ksh" ) -- texture.ksh
	--waves:SetWaveEffect( "shaders/texture.ksh" ) -- 

    inst:AddComponent("clock")
	inst:AddComponent("seasonmanager")
	inst:DoTaskInTime(0, function(inst) inst.components.seasonmanager:SetOverworld() end)
    inst:AddComponent("flowerspawner")
    inst:AddComponent("lureplantspawner")
    inst:AddComponent("birdspawner")
    inst:AddComponent("butterflyspawner")
	--inst:AddComponent("interiorspawner")
	inst:AddComponent("hounded")
	inst:AddComponent("hunter")

	inst:AddComponent("basehassler")

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

	inst:AddComponent("frograin")
	inst:AddComponent("bigfooter")
	inst:AddComponent("penguinspawner")

	inst:AddComponent("colourcubemanager")
	inst.Map:SetOverlayTexture( "levels/textures/snow.tex" )
	inst.Map:SetOverlayColor0( 1,1,1,1 )
	inst.Map:SetOverlayColor1( 1,1,1,1 )
	inst.Map:SetOverlayColor2( 1,1,1,1 )

	inst:ListenForEvent("seasonChange", OnSeasonChange)

	-- local rog_enabled = false -- TODO: replace with actual RoG check
	-- if rog_enabled then
	-- 	SpawnPrefab("rogsupport")
	-- end

    return inst
end

return Prefab( "worlds/forest", fn, assets, forest_prefabs) 
