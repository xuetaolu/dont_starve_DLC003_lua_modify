local freqency_descriptions
if PLATFORM ~= "PS4" then
	freqency_descriptions = {
		{ text = STRINGS.UI.SANDBOXMENU.SLIDENEVER, data = "never" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDERARE, data = "rare" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEOFTEN, data = "often" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEALWAYS, data = "always" },
	}
else
	freqency_descriptions = {
		{ text = STRINGS.UI.SANDBOXMENU.SLIDENEVER, data = "never" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDERARE, data = "rare" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" }
	}
	freqency_descriptions_ps4_exceptions = {
		{ text = STRINGS.UI.SANDBOXMENU.SLIDENEVER, data = "never" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDERARE, data = "rare" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEOFTEN, data = "often" },
		{ text = STRINGS.UI.SANDBOXMENU.SLIDEALWAYS, data = "always" },
	}
end

local speed_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEVERYSLOW, data = "veryslow" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDESLOW, data = "slow" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEFAST, data = "fast" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEVERYFAST, data = "veryfast" },
}

local rate_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.SLIDENEVER, data = "never" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEVERYRARE, data = "veryrare" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDERARE, data = "rare" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEOFTEN, data = "often" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEALWAYS, data = "always" },
}

local day_descriptions = {

	{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },

	{ text = STRINGS.UI.SANDBOXMENU.SLIDELONG.." "..STRINGS.UI.SANDBOXMENU.DAY, data = "longday" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDELONG.." "..STRINGS.UI.SANDBOXMENU.DUSK, data = "longdusk" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDELONG.." "..STRINGS.UI.SANDBOXMENU.NIGHT, data = "longnight" },

	{ text = STRINGS.UI.SANDBOXMENU.EXCLUDE.." "..STRINGS.UI.SANDBOXMENU.DAY, data = "noday" },
	{ text = STRINGS.UI.SANDBOXMENU.EXCLUDE.." "..STRINGS.UI.SANDBOXMENU.DUSK, data = "nodusk" },
	{ text = STRINGS.UI.SANDBOXMENU.EXCLUDE.." "..STRINGS.UI.SANDBOXMENU.NIGHT, data = "nonight" },

	{ text = STRINGS.UI.SANDBOXMENU.SLIDEALL.." "..STRINGS.UI.SANDBOXMENU.DAY, data = "onlyday" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEALL.." "..STRINGS.UI.SANDBOXMENU.DUSK, data = "onlydusk" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEALL.." "..STRINGS.UI.SANDBOXMENU.NIGHT, data = "onlynight" },
}

local season_length_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.SLIDENEVER, data = "noseason" },	
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEVERYSHORT, data = "veryshortseason" },	
	{ text = STRINGS.UI.SANDBOXMENU.SLIDESHORT, data = "shortseason" },	
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDELONG, data = "longseason" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEVERYLONG, data = "verylongseason" },
	{ text = STRINGS.UI.SANDBOXMENU.RANDOM, data = "random"},
}

local season_start_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.TEMPERATE, data = "temperate"},-- 	image = "season_start_autumn.tex" },
	{ text = STRINGS.UI.SANDBOXMENU.HUMID, data = "humid"},-- 	image = "season_start_winter.tex" },
	{ text = STRINGS.UI.SANDBOXMENU.LUSH, data = "lush"},-- 	image = "season_start_spring.tex" },	
	{ text = STRINGS.UI.SANDBOXMENU.RANDOM, data = "random"},-- 	image = "season_start_summer.tex" },
}

local size_descriptions = nil
if PLATFORM == "PS4" then
	size_descriptions = {
		{ text = STRINGS.UI.SANDBOXMENU.SLIDESMALL, data = "default"},-- 	image = "world_size_small.tex"}, 	--350x350
		{ text = STRINGS.UI.SANDBOXMENU.SLIDESMEDIUM, data = "medium"},-- 	image = "world_size_medium.tex"},	--450x450
		{ text = STRINGS.UI.SANDBOXMENU.SLIDESLARGE, data = "large"},-- 	image = "world_size_large.tex"},	--550x550
	}
else
	size_descriptions = {
		{ text = STRINGS.UI.SANDBOXMENU.SLIDESMALL, data = "default"},-- 	image = "world_size_small.tex"}, 	--350x350
		{ text = STRINGS.UI.SANDBOXMENU.SLIDESMEDIUM, data = "medium"},-- 	image = "world_size_medium.tex"},	--450x450
		{ text = STRINGS.UI.SANDBOXMENU.SLIDESLARGE, data = "large"},-- 	image = "world_size_large.tex"},	--550x550
		--{ text = STRINGS.UI.SANDBOXMENU.SLIDESHUGE, data = "huge"},-- 		image = "world_size_huge.tex"},	--800x800
	}
end


local branching_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.BRANCHINGNEVER, data = "never" },
	{ text = STRINGS.UI.SANDBOXMENU.BRANCHINGLEAST, data = "least" },
	{ text = STRINGS.UI.SANDBOXMENU.BRANCHINGANY, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.BRANCHINGMOST, data = "most" },
}

local loop_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.LOOPNEVER, data = "never" },
	{ text = STRINGS.UI.SANDBOXMENU.LOOPRANDOM, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.LOOPALWAYS, data = "always" },
}

local complexity_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEVERYSIMPLE, data = "verysimple" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDESIMPLE, data = "simple" },
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEDEFAULT, data = "default" },	
	{ text = STRINGS.UI.SANDBOXMENU.SLIDECOMPLEX, data = "complex" },	
	{ text = STRINGS.UI.SANDBOXMENU.SLIDEVERYCOMPLEX, data = "verycomplex" },	
}

-- Read this from the levels.lua
local preset_descriptions = {
}

-- TODO: Read this from the tasks.lua
local yesno_descriptions = {
	{ text = STRINGS.UI.SANDBOXMENU.YES, data = "default" },
	{ text = STRINGS.UI.SANDBOXMENU.NO, data = "never" },
}

local GROUP = {
	["monsters"] = 	{	-- These guys come after you	
						order = 5,
						text = STRINGS.UI.SANDBOXMENU.CHOICEMONSTERS, 
						desc = freqency_descriptions,
						enable = false,
						items={							
							["mandrakeman"] = {value = "default", enable = false, spinner = nil, image = "mandrake_men.tex", order = 1},																				
							["antman"] = {value = "default", enable = false, spinner = nil, image = "mants.tex", order = 2},																				
							["giantgrub"] = {value = "default", enable = false, spinner = nil, image = "giant_grubs.tex", order = 3},
							["frog_poison"] = {value = "default", enable = false, spinner = nil, image = "poison_dart_frogs.tex", order = 4},
							["mosquito"] = {value = "default", enable = false, spinner = nil, image = "mosquitos.tex", order = 5},
							["bat"] = {value = "default", enable = false, spinner = nil, image = "bats.tex", order = 6},
							["weevole"] = {value = "default", enable = false, spinner = nil, image = "weevole.tex", order = 7},
							["gnat"] = {value = "default", enable = false, spinner = nil, image = "gnat.tex", order = 8},
							["bill"] = {value = "default", enable = false, spinner = nil, image = "platypine.tex", order = 9},
							["snake"] = {value = "default", enable = false, spinner = nil, image = "snakes.tex", order = 10},
							["scorpion"] = {value = "default", enable = false, spinner = nil, image = "scorpions.tex", order = 11},
							["grabbing_vine"] = {value = "default", enable = false, spinner = nil, image = "grabbing_vines.tex", order = 12},
							["mean_flytrap"] = {value = "default", enable = false, spinner = nil, image = "mean_flytraps.tex", order = 13},
							["adult_flytrap"] = {value = "default", enable = false, spinner = nil, image = "adult_flytraps.tex", order = 14},
							["pigghost"] = {value = "default", enable = false, spinner = nil, image = "pig_ghosts.tex", desc = yesno_descriptions, order = 15},
							["roc"] = {value = "default", enable = false, spinner = nil, image = "roc.tex", desc = yesno_descriptions, order = 16},
							["pugalisk"] = {value = "default", enable = false, spinner = nil, image = "pugalisk.tex", desc = yesno_descriptions, order = 17},
							["antqueen"] = {value = "default", enable = false, spinner = nil, image = "mant_queen.tex", desc = yesno_descriptions, order = 18},
						}
					},
	["animals"] =  	{	-- These guys live and let live
						order= 4,
						text = STRINGS.UI.SANDBOXMENU.CHOICEANIMALS, 
						desc = freqency_descriptions,
						enable = false,
						items={
							["butterfly"] = {value = "default", enable = false, spinner = nil, image = "butterfly.tex", order = 1},
							["birds"] = {value = "default", enable = false, spinner = nil, image = "kingfisher.tex", order = 2},
							["glowfly"] = {value = "default", enable = false, spinner = nil, image = "glowflies.tex", order = 3},
							["hippopotamoose"] = {value = "default", enable = false, spinner = nil, image = "hippopotamoose.tex", order = 4},
							["pog"] = {value = "default", enable = false, spinner = nil, image = "pogs.tex", order = 5},
							["pangolden"] = {value = "default", enable = false, spinner = nil, image = "pangolden.tex", order = 6},
							["peagawk"] = {value = "default", enable = false, spinner = nil, image = "peagawk.tex", order = 7},
							["thunderbird"] = {value = "default", enable = false, spinner = nil, image = "thunderbirds.tex", order = 8},
							["dungbeetle"] = {value = "default", enable = false, spinner = nil, image = "dung_beetles.tex", order = 9},
							["piko"] = {value = "default", enable = false, spinner = nil, image = "orange_pikos.tex", order = 10},
						}
					},
	["resources"] = {
						order= 2,
						text = STRINGS.UI.SANDBOXMENU.CHOICERESOURCES, 
						desc = freqency_descriptions,
						enable = false,
						items={
							["flowers"] = {value = "default", enable = false, spinner = nil, image = "flowers.tex", order = 1},
							["flowers_rainforest"] = {value = "default", enable = false, spinner = nil, image = "tropical_flowers.tex", order = 2},
							["grass"] = {value = "default", enable = false, spinner = nil, image = "tall_grass.tex", order = 3},
							["grass_bunches"] = {value = "default", enable = false, spinner = nil, image = "grass_bunches.tex", order = 4},
							["sapling"] = {value = "default", enable = false, spinner = nil, image = "sapling.tex", order = 5},
							["reeds"] = {value = "default", enable = false, spinner = nil, image = "reeds.tex", order = 6},
							["rainforesttree"] = {value = "default", enable = false, spinner = nil, image = "rainforest_trees.tex", order = 7},
							["clawpalmtree"] = {value = "default", enable = false, spinner = nil, image = "claw_trees.tex", order = 8},
							["tubertree"] = {value = "default", enable = false, spinner = nil, image = "tuber_trees.tex", order = 9},
							["teatree"] = {value = "default", enable = false, spinner = nil, image = "tea_trees.tex", order = 10},
							["rock_flippable"] = {value = "default", enable = false, spinner = nil, image = "flipping_rocks.tex", order = 11},
							["dungpile"] = {value = "default", enable = false, spinner = nil, image = "dung_piles.tex", order = 12},
							["gnatmound"] = {value = "default", enable = false, spinner = nil, image = "gnat_mounds.tex", order = 13},
							["lilypad"] = {value = "default", enable = false, spinner = nil, image = "lily_pads.tex", order = 14},
							["lotus"] = {value = "default", enable = false, spinner = nil, image = "lotus.tex", order = 15},
							["nettle"] = {value = "default", enable = false, spinner = nil, image = "nettle.tex", order = 16},
							["hanging_vine"] = {value = "default", enable = false, spinner = nil, image = "hanging_vines.tex", order = 17},
							["ruined_sculptures"] = {value = "default", enable = false, spinner = nil, image = "lost_sculptures.tex", desc = freqency_descriptions, order = 18},
							["antcombhome"] = {value = "default", enable = false, spinner = nil, image = "mant_comb_homes.tex", desc = yesno_descriptions, order = 19},							
							["ant_cave_lantern"] = {value = "default", enable = false, spinner = nil, image = "mant_lamps.tex", desc = yesno_descriptions, order = 20},																					
							["city_lamp"] = {value = "default", enable = false, spinner = nil, image = "lamp_posts.tex", desc = yesno_descriptions, order = 21},																																										
							["rusted_hulks"] = {value = "default", enable = false, spinner = nil, image = "rusted_hulks.tex", desc = yesno_descriptions, order = 22},																																																	
						}
					},
	["unprepared"] ={
						order= 3,
						text = STRINGS.UI.SANDBOXMENU.CHOICEFOOD, 
						desc = freqency_descriptions,
						enable = true,
						items={
							["aloe"] = {value = "default", enable = true, spinner = nil, image = "aloe.tex", order = 1}, 				
							["asparagus_planted"] = {value = "default", enable = true, spinner = nil, image = "asparagus.tex", order = 2}, 				
							["radish"] = {value = "default", enable = true, spinner = nil, image = "radish.tex", order = 3}, 
							["mushroom"] = {value = "default", enable = false, spinner = nil, image = "mushrooms.tex", order = 4},
						}
					},
	["misc"] =		{
						order= 1,
						text = STRINGS.UI.SANDBOXMENU.CHOICEMISC, 
						desc = nil,
						enable = true,
						items={
							["world_size"] = {value = "default", enable = false, spinner = nil, image = "world_size.tex", desc = size_descriptions, order = 1},
							["temperate_season"] = {value = "default", enable = true, spinner = nil, image = "temperate.tex", desc = season_length_descriptions, order = 2},
							["humid_season"] = {value = "default", enable = true, spinner = nil, image = "humid.tex", desc = season_length_descriptions, order = 3},
							["lush_season"] = {value = "default", enable = true, spinner = nil, image = "lush.tex", desc = season_length_descriptions, order = 4},							
							["season_start"] = {value = "temperate", enable = false, spinner = nil, image = "season_start.tex", desc = season_start_descriptions, order = 5},
							["day"] = {value = "default", enable = false, spinner = nil, image = "day.tex", desc = day_descriptions, order = 6},
							["weather"] = {value = "default", enable = false, spinner = nil, image = "rain.tex", desc = freqency_descriptions, order = 7},
							["lightning"] = {value = "default", enable = false, spinner = nil, image = "lightning.tex", desc = freqency_descriptions, order = 8},							
							["fog"] = {value = "default", enable = false, spinner = nil, image = "fog.tex", desc = yesno_descriptions, order = 9},
							["brambles"] = {value = "default", enable = false, spinner = nil, image = "brambles.tex", desc = yesno_descriptions, order = 10},
							["hayfever"] = {value = "default", enable = false, spinner = nil, image = "hayfever.tex", desc = yesno_descriptions, order = 11},							
							["boons"] = {value = "default", enable = false, spinner = nil, image = "skeletons.tex", desc = freqency_descriptions, order = 12},
							["glowflycycle"] = {value = "default", enable = false, spinner = nil, image = "glowfly_life_cycle.tex", desc = yesno_descriptions, order = 13},
							["deep_jungle_fern_noise"] = {value = "default", enable = false, spinner = nil, image = "noise_ferns.tex", desc = freqency_descriptions, order = 14},
							["jungle_border_vine"] = {value = "default", enable = false, spinner = nil, image = "canopy_loops.tex", desc = freqency_descriptions, order = 15},
							["lost_relics"] = {value = "default", enable = false, spinner = nil, image = "lost_relics.tex", desc = freqency_descriptions, order = 16},
							["pig_ruins_torch"] = {value = "default", enable = false, spinner = nil, image = "crumbling_brazier.tex", desc = freqency_descriptions, order = 17},
							["vampirebat"] = {value = "default", enable = false, spinner = nil, image = "vampire_bats.tex", desc = freqency_descriptions, order = 18},
							["vampirebatcave"] = {value = "default", enable = false, spinner = nil, image = "vampire_bat_caves.tex", desc = freqency_descriptions, order = 19},
							["pighouse_city"] = {value = "default", enable = false, spinner = nil, image = "pig_houses.tex", desc = yesno_descriptions, order = 20},																																			
							["pig_guard_tower"] = {value = "default", enable = false, spinner = nil, image = "guard_towers.tex", desc = yesno_descriptions, order = 21},																												
							["pigbandit"] = {value = "default", enable = false, spinner = nil, image = "pig_bandit.tex", desc = freqency_descriptions, order = 22},
							["pig_ruins_entrance_small"] = {value = "default", enable = false, spinner = nil, image = "small_ruins.tex", desc = freqency_descriptions, order = 23},
							["dart_traps"] = {value = "default", enable = false, spinner = nil, image = "dart_traps.tex", desc = yesno_descriptions, order = 24},
							["spear_traps"] = {value = "default", enable = false, spinner = nil, image = "spike_traps.tex", desc = yesno_descriptions, order = 25},
							["door_vines"] = {value = "default", enable = false, spinner = nil, image = "creeping_vines.tex", desc = yesno_descriptions, order = 26},
							["pugalisk_fountain"] = {value = "default", enable = false, spinner = nil, image = "pugalisk_fountain.tex", desc = yesno_descriptions, order = 27},
						}
					},
}

-- Fixup for frequency spinners that are _actually_ frequency (not density)
if PLATFORM == "PS4" then
	GROUP["monsters"].items["treeguard"] = {value = "default", enable = false, spinner = nil, image = "treeguard.tex", desc = freqency_descriptions_ps4_exceptions, order = 9}
	GROUP["monsters"].items["krampus"] = {value = "default", enable = false, spinner = nil, image = "krampus.tex", desc = freqency_descriptions_ps4_exceptions, order = 11}
	GROUP["monsters"].items["deerclops"] = {value = "default", enable = false, spinner = nil, image = "deerclops.tex", desc = freqency_descriptions_ps4_exceptions, order = 13}
	GROUP["monsters"].items["bearger"] = {value = "default", enable = false, spinner = nil, image = "bearger.tex", desc = freqency_descriptions_ps4_exceptions, order = 12}
	GROUP["monsters"].items["goosemoose"] = {value = "default", enable = false, spinner = nil, image = "goosemoose.tex", desc = freqency_descriptions_ps4_exceptions, order = 14}
	GROUP["monsters"].items["dragonfly"] = {value = "default", enable = false, spinner = nil, image = "dragonfly.tex", desc = freqency_descriptions_ps4_exceptions, order = 15}
	GROUP["monsters"].items["deciduousmonster"] = {value = "default", enable = false, spinner = nil, image = "deciduouspoison.tex", desc = freqency_descriptions_ps4_exceptions, order = 10}

	GROUP["animals"].items["hunt"] = {value = "default", enable = false, spinner = nil, image = "tracks.tex", desc = freqency_descriptions_ps4_exceptions, order = 13}
	GROUP["animals"].items["warg"] = {value = "default", enable = false, spinner = nil, image = "warg.tex", desc = freqency_descriptions_ps4_exceptions, order = 14}

	GROUP["misc"].items["weather"] = {value = "default", enable = false, spinner = nil, image = "rain.tex", desc = freqency_descriptions_ps4_exceptions, order = 11}
	GROUP["misc"].items["lightning"] = {value = "default", enable = false, spinner = nil, image = "lightning.tex", desc = freqency_descriptions_ps4_exceptions, order = 12}
	GROUP["misc"].items["frograin"] = {value = "default", enable = false, spinner = nil, image = "frog_rain.tex", desc = freqency_descriptions_ps4_exceptions, order = 13} 
	GROUP["misc"].items["wildfires"] = {value = "default", enable = false, spinner = nil, image = "smoke.tex", desc = freqency_descriptions_ps4_exceptions, order = 14}
end

for area, items in pairs(GROUP) do
	for name, item in pairs(items.items) do
		if item.atlas == nil then
			item.atlas = "images/customization_porkland.xml"
		end
	end
end

local function GetGroupForItem(target)
	for area,items in pairs(GROUP) do
		for name,item in pairs(items.items) do
			if name == target then
				return area
			end
		end
	end
	return "misc"
end

return {GetGroupForItem=GetGroupForItem, GROUP=GROUP, preset_descriptions=preset_descriptions}
