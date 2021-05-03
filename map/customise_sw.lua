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

-- local season_mode_descriptions = {
-- 	{ text = STRINGS.UI.SANDBOXMENU.ALLSEASONS, data = "default" },

-- 	{ text = STRINGS.UI.SANDBOXMENU.CLASSIC, data = "classic" },
-- 	{ text = STRINGS.UI.SANDBOXMENU.DLC, data = "dlc" },
-- 	{ text = STRINGS.UI.SANDBOXMENU.EXTREMETEMPS, data = "extreme" },
-- 	{ text = STRINGS.UI.SANDBOXMENU.STATICTEMPS, data = "static" },	

-- 	{ text = STRINGS.UI.SANDBOXMENU.SLIDEALL.." "..STRINGS.UI.SANDBOXMENU.AUTUMN, data = "onlyautumn" },
-- 	{ text = STRINGS.UI.SANDBOXMENU.SLIDEALL.." "..STRINGS.UI.SANDBOXMENU.WINTER, data = "onlywinter" },
-- 	{ text = STRINGS.UI.SANDBOXMENU.SLIDEALL.." "..STRINGS.UI.SANDBOXMENU.SPRING, data = "onlyspring" },
-- 	{ text = STRINGS.UI.SANDBOXMENU.SLIDEALL.." "..STRINGS.UI.SANDBOXMENU.SUMMER, data = "onlysummer" },

-- 	{ text = STRINGS.UI.SANDBOXMENU.EXCLUDE.." "..STRINGS.UI.SANDBOXMENU.AUTUMN, data = "noautumn" },
-- 	{ text = STRINGS.UI.SANDBOXMENU.EXCLUDE.." "..STRINGS.UI.SANDBOXMENU.WINTER, data = "nowinter" },
-- 	{ text = STRINGS.UI.SANDBOXMENU.EXCLUDE.." "..STRINGS.UI.SANDBOXMENU.SPRING, data = "nospring" },
-- 	{ text = STRINGS.UI.SANDBOXMENU.EXCLUDE.." "..STRINGS.UI.SANDBOXMENU.SUMMER, data = "nosummer" },	
-- }

local season_start_descriptions = {
	--{ text = STRINGS.UI.SANDBOXMENU.DEFAULT, data = "default"},-- 	image = "season_start_autumn.tex" },
	{ text = STRINGS.UI.SANDBOXMENU.MILD, data = "mild"},-- 	image = "season_start_autumn.tex" },
	{ text = STRINGS.UI.SANDBOXMENU.WET, data = "wet"},-- 	image = "season_start_winter.tex" },
	{ text = STRINGS.UI.SANDBOXMENU.GREEN, data = "green"},-- 	image = "season_start_spring.tex" },
	{ text = STRINGS.UI.SANDBOXMENU.DRY, data = "dry"},-- 	image = "season_start_summer.tex" },
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
		{ text = STRINGS.UI.SANDBOXMENU.SLIDESHUGE, data = "huge"},-- 		image = "world_size_huge.tex"},	--800x800
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
							["spiders"] = {value = "default", enable = false, spinner = nil, image = "spiders.tex", order = 1},
							["crocodog"] = {value = "default", enable = false, spinner = nil, image = "crocodog.tex", order = 2},
							["merm"] = {value = "default", enable = false, spinner = nil, image = "merms.tex", order = 3},
							["lureplants"] = {value = "default", enable = false, spinner = nil, image = "lureplant.tex", order = 4},
							["treeguard"] = {value = "default", enable = false, spinner = nil, image = "palmguard.tex", order = 5},
							["krampus"] = {value = "default", enable = false, spinner = nil, image = "krampus.tex", order = 6},

							["twister"] = {value = "default", enable = false, spinner = nil, image = "twister.tex", order = 7},
							["tigershark"] = {value = "default", enable = false, spinner = nil, image = "tigershark.tex", order = 8},
							["kraken"] = {value = "default", enable = false, spinner = nil, image = "kraken.tex", order = 9},
							["flup"] = {value = "default", enable = false, spinner = nil, image = "flups.tex", order = 10},
							["mosquito"] = {value = "default", enable = false, spinner = nil, image = "mosquitos.tex", order = 11},
							["swordfish"] = {value = "default", enable = false, spinner = nil, image = "swordfish.tex", order = 12},
							["stungray"] = {value = "default", enable = false, spinner = nil, image = "stinkrays.tex", order = 13},
						}
					},
	["animals"] =  	{	-- These guys live and let live
						order= 4,
						text = STRINGS.UI.SANDBOXMENU.CHOICEANIMALS, 
						desc = freqency_descriptions,
						enable = false,
						items={
							["butterfly"] = {value = "default", enable = false, spinner = nil, image = "butterfly.tex", order = 1},
							["birds"] = {value = "default", enable = false, spinner = nil, image = "birds.tex", order = 2},
							["wildbores"] = {value = "default", enable = false, spinner = nil, image = "wildbores.tex", order = 3},
							["bees"] = {value = "default", enable = false, spinner = nil, image = "beehive.tex", order = 4},
							["angrybees"] = {value = "default", enable = false, spinner = nil, image = "wasphive.tex", order = 5},
							["tallbirds"] = {value = "default", enable = false, spinner = nil, image = "tallbirds.tex", order = 6},

							["whalehunt"] = {value = "default", enable = false, spinner = nil, image = "whales.tex", order = 7},
							["crabhole"] = {value = "default", enable = false, spinner = nil, image = "crabbits.tex", order = 8},
							["ox"] = {value = "default", enable = false, spinner = nil, image = "ox.tex", order = 9},
							--["beefaloheat"] = {value = "default", enable = false, spinner = nil, image = "beefaloheat.tex", order = 12}, --being used for ox
							["solofish"] = {value = "default", enable = false, spinner = nil, image = "dogfish.tex", order = 10},
							["doydoy"] = {value = "default", enable = false, spinner = nil, image = "doydoy.tex", desc = yesno_descriptions, order = 11},
							["jellyfish"] = {value = "default", enable = false, spinner = nil, image = "jellyfish.tex", order = 12},
							["lobster"] = {value = "default", enable = false, spinner = nil, image = "lobsters.tex", order = 13},
							["seagull"] = {value = "default", enable = false, spinner = nil, image = "seagulls.tex", order = 14},
							["ballphin"] = {value = "default", enable = false, spinner = nil, image = "ballphins.tex", order = 15},
							["primeape"] = {value = "default", enable = false, spinner = nil, image = "monkeys.tex", order = 16},
						}
					},
	["resources"] = {
						order= 2,
						text = STRINGS.UI.SANDBOXMENU.CHOICERESOURCES, 
						desc = freqency_descriptions,
						enable = false,
						items={
							["flowers"] = {value = "default", enable = false, spinner = nil, image = "flowers.tex", order = 1},
							["grass"] = {value = "default", enable = false, spinner = nil, image = "grass.tex", order = 2},
							["sapling"] = {value = "default", enable = false, spinner = nil, image = "sapling.tex", order = 3},
							["reeds"] = {value = "default", enable = false, spinner = nil, image = "reeds.tex", order = 4},
							["trees"] = {value = "default", enable = false, spinner = nil, image = "trees.tex", order = 5},
							["flint"] = {value = "default", enable = false, spinner = nil, image = "flint.tex", order = 6},
							["rock"] = {value = "default", enable = false, spinner = nil, image = "rock.tex", order = 7},

							["fishinhole"] = {value = "default", enable = false, spinner = nil, image = "shoals.tex", order = 8},
							["seashell"] = {value = "default", enable = false, spinner = nil, image = "seashell.tex", order = 9},
							["bush_vine"] = {value = "default", enable = false, spinner = nil, image = "vines.tex", order = 10},
							["seaweed"] = {value = "default", enable = false, spinner = nil, image = "seaweed.tex", order = 11},
							["sandhill"] = {value = "default", enable = false, spinner = nil, image = "sand.tex", order = 12},
							["crate"] = {value = "default", enable = false, spinner = nil, image = "crates.tex", order = 13},
							["bioluminescence"] = {value = "default", enable = false, spinner = nil, image = "bioluminescence.tex", order = 14},
							["coral"] = {value = "default", enable = false, spinner = nil, image = "coral.tex", order = 15},
							["coral_brain_rock"] = {value = "default", enable = false, spinner = nil, image = "braincoral.tex", order = 16},
							["bamboo"] = {value = "default", enable = false, spinner = nil, image = "bamboo.tex", order = 17},
							["tidalpool"] = {value = "default", enable = false, spinner = nil, image = "tidalpools.tex", order = 18},
							["poisonhole"] = {value = "default", enable = false, spinner = nil, image = "poisonhole.tex", order = 19},
							--["obsidian"] = {value = "default", enable = false, spinner = nil, image = "obsidian.tex", order = 13},
						}
					},
	["unprepared"] ={
						order= 3,
						text = STRINGS.UI.SANDBOXMENU.CHOICEFOOD, 
						desc = freqency_descriptions,
						enable = true,
						items={
							["sweet_potato"] = {value = "default", enable = true, spinner = nil, image = "sweetpotatos.tex", order = 2}, 
							["berrybush"] = {value = "default", enable = true, spinner = nil, image = "berrybush.tex", order = 1}, 
							["mushroom"] = {value = "default", enable = false, spinner = nil, image = "mushrooms.tex", order = 3}, 

							["limpets"] = {value = "default", enable = false, spinner = nil, image = "limpets.tex", order = 4},
							["mussel_farm"] = {value = "default", enable = false, spinner = nil, image = "mussels.tex", order = 5},
						}
					},
	["misc"] =		{
						order= 1,
						text = STRINGS.UI.SANDBOXMENU.CHOICEMISC, 
						desc = nil,
						enable = true,
						items={
							["world_size"] = {value = "default", enable = false, spinner = nil, image = "world_size.tex", desc = size_descriptions, order = 1},
							["mild_season"] = {value = "default", enable = true, spinner = nil, image = "mild.tex", desc = season_length_descriptions, order = 2},
							["wet_season"] = {value = "default", enable = true, spinner = nil, image = "hurricane.tex", desc = season_length_descriptions, order = 3},
							["green_season"] = {value = "default", enable = true, spinner = nil, image = "monsoon.tex", desc = season_length_descriptions, order = 4},
							["dry_season"] = {value = "default", enable = true, spinner = nil, image = "dry.tex", desc = season_length_descriptions, order = 5},
							["season_start"] = {value = "mild", enable = false, spinner = nil, image = "season_start.tex", desc = season_start_descriptions, order = 6},
							["day"] = {value = "default", enable = false, spinner = nil, image = "day.tex", desc = day_descriptions, order = 7},
							["weather"] = {value = "default", enable = false, spinner = nil, image = "rain.tex", desc = freqency_descriptions, order = 8},
							["lightning"] = {value = "default", enable = false, spinner = nil, image = "lightning.tex", desc = freqency_descriptions, order = 9},
							["touchstone"] = {value = "default", enable = false, spinner = nil, image = "resurrection.tex", desc = freqency_descriptions, order = 10},
							["boons"] = {value = "default", enable = false, spinner = nil, image = "skeletons.tex", desc = freqency_descriptions, order = 11},

							["volcano"] = {value = "default", enable = false, spinner = nil, image = "volcano.tex", desc = yesno_descriptions, order = 12},
							["dragoonegg"] = {value = "default", enable = false, spinner = nil, image = "dragooneggs.tex", desc = freqency_descriptions, order = 13},
							["tides"] = {value = "default", enable = false, spinner = nil, image = "tides.tex", desc = yesno_descriptions, order = 14},
							["floods"] = {value = "default", enable = false, spinner = nil, image = "floods.tex", desc = freqency_descriptions, order = 15},
							["oceanwaves"] = {value = "default", enable = false, spinner = nil, image = "waves.tex", desc = rate_descriptions, order = 16},
							["poison"] = {value = "default", enable = false, spinner = nil, image = "poison.tex", desc = yesno_descriptions, order = 17},
							--["bermudatriangle"] = {value = "default", enable = false, spinner = nil, image = "bermudatriangle.tex", desc = freqency_descriptions, order = 12},
						}
					},
}

-- Fixup for frequency spinners that are _actually_ frequency (not density)
if PLATFORM == "PS4" then
	-- GROUP["monsters"].items["lureplants"] = {value = "default", enable = false, spinner = nil, image = "lureplant.tex", desc = freqency_descriptions_ps4_exceptions, order = 7} 
	-- GROUP["monsters"].items["hounds"] = {value = "default", enable = false, spinner = nil, image = "hounds.tex", desc = freqency_descriptions_ps4_exceptions, order = 2}
	GROUP["monsters"].items["treeguard"] = {value = "default", enable = false, spinner = nil, image = "treeguard.tex", desc = freqency_descriptions_ps4_exceptions, order = 9}
	--GROUP["monsters"].items["liefs"] = {value = "default", enable = false, spinner = nil, image = "liefs.tex", desc = freqency_descriptions_ps4_exceptions, order = 9}
	GROUP["monsters"].items["krampus"] = {value = "default", enable = false, spinner = nil, image = "krampus.tex", desc = freqency_descriptions_ps4_exceptions, order = 11}
	GROUP["monsters"].items["deerclops"] = {value = "default", enable = false, spinner = nil, image = "deerclops.tex", desc = freqency_descriptions_ps4_exceptions, order = 13}
	GROUP["monsters"].items["bearger"] = {value = "default", enable = false, spinner = nil, image = "bearger.tex", desc = freqency_descriptions_ps4_exceptions, order = 12}
	GROUP["monsters"].items["goosemoose"] = {value = "default", enable = false, spinner = nil, image = "goosemoose.tex", desc = freqency_descriptions_ps4_exceptions, order = 14}
	GROUP["monsters"].items["dragonfly"] = {value = "default", enable = false, spinner = nil, image = "dragonfly.tex", desc = freqency_descriptions_ps4_exceptions, order = 15}
	GROUP["monsters"].items["deciduousmonster"] = {value = "default", enable = false, spinner = nil, image = "deciduouspoison.tex", desc = freqency_descriptions_ps4_exceptions, order = 10}

	-- GROUP["animals"].items["beefaloheat"] = {value = "default", enable = false, spinner = nil, image = "beefaloheat.tex", desc = freqency_descriptions_ps4_exceptions, order = 12}
	GROUP["animals"].items["hunt"] = {value = "default", enable = false, spinner = nil, image = "tracks.tex", desc = freqency_descriptions_ps4_exceptions, order = 13}
	GROUP["animals"].items["warg"] = {value = "default", enable = false, spinner = nil, image = "warg.tex", desc = freqency_descriptions_ps4_exceptions, order = 14}
	-- GROUP["animals"].items["birds"] = {value = "default", enable = false, spinner = nil, image = "birds.tex", desc = freqency_descriptions_ps4_exceptions, order = 5}
	-- GROUP["animals"].items["perd"] = {value = "default", enable = false, spinner = nil, image = "perd.tex", desc = freqency_descriptions_ps4_exceptions, order = 8}
	-- GROUP["animals"].items["butterfly"] = {value = "default", enable = false, spinner = nil, image = "butterfly.tex", desc = freqency_descriptions_ps4_exceptions, order = 4}
	-- GROUP["animals"].items["penguins"] = {value = "default", enable = false, spinner = nil, image = "pengull.tex", desc = freqency_descriptions_ps4_exceptions, order = 15}

	-- GROUP["resources"].items["flowers"] = {value = "default", enable = false, spinner = nil, image = "flowers.tex", desc = freqency_descriptions_ps4_exceptions, order = 1}

	GROUP["misc"].items["weather"] = {value = "default", enable = false, spinner = nil, image = "rain.tex", desc = freqency_descriptions_ps4_exceptions, order = 11}
	GROUP["misc"].items["lightning"] = {value = "default", enable = false, spinner = nil, image = "lightning.tex", desc = freqency_descriptions_ps4_exceptions, order = 12}
	GROUP["misc"].items["frograin"] = {value = "default", enable = false, spinner = nil, image = "frog_rain.tex", desc = freqency_descriptions_ps4_exceptions, order = 13} 
	GROUP["misc"].items["wildfires"] = {value = "default", enable = false, spinner = nil, image = "smoke.tex", desc = freqency_descriptions_ps4_exceptions, order = 14}
end

for area, items in pairs(GROUP) do
	for name, item in pairs(items.items) do
		if item.atlas == nil then
			item.atlas = "images/customization_shipwrecked.xml"
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
