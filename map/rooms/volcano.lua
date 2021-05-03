
AddRoom("Volcano", {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = GROUND.VOLCANO,
					tags = {"ExitPiece"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {
					                    magmarock = .5,
					                    magmarock_gold = .5,
					                    rock_obsidian = .5,
					                    rock_charcoal = .5,
					                    volcano_shrub = .5,
					                    --rocks = 1,
					                    --goldnugget = 0.05,
					                    obsidian = 0.02,
					                    charcoal = 0.04,
					                    skeleton = 0.1,
					                    --elephantcactus = 0.3,
					                    --coffeebush = 0.25,
					                    dragoonden = .05,
					                },

					                countprefabs =
					                {
					                	--palmtree = math.random(8, 16),
					                	volcanofog = math.random(1, 2)
					                },

					                prefabdata =
					                {
					                	magmarock = {regen=true},
					                	magmarock_gold = {regen=true}
					            	}
					            }
					})

AddRoom("VolcanoRock", {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = GROUND.VOLCANO,
					tags = {"ExitPiece"},
					contents =  {
					                distributepercent = .15,
					                distributeprefabs=
					                {
					                    magmarock = .5,
					                    magmarock_gold = .5,
					                    flint= .5,
					                    obsidian = .02,
					                    --rocks = 1,
					                    charcoal = 0.04,
					                    skeleton = 0.25,
					                    --elephantcactus = 0.3,

					                    --coffeebush = 0.25,
					                    --dragoonden = .2,
					                },

					                countprefabs =
					                {
					                	--palmtree = math.random(8, 16),
					                	volcanofog = math.random(1, 2)
					                },
					                prefabdata =
					                {
					                	--palmtree = {burnt=true},
					                	--coffeebush = {makebarren=true}
					            	}
					            }
					})

AddRoom("VolcanoAsh", {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = GROUND.ASH,
					tags = {"ExitPiece"},
					contents =  {
									countstaticlayouts={["CoffeeBushBunch"]=1}, --adds 1 per room
					                distributepercent = .15,
					                distributeprefabs=
					                {
					                    --rocks = 1,
					                    charcoal = 0.04,
					                    skeleton = 0.25,
					                    elephantcactus = 0.3,
					                    coffeebush = .5,
					                    --dragoonden = .2,
					                },

					                countprefabs =
					                {
					                	--palmtree = math.random(4, 8),
					                	volcanofog = math.random(1, 2)
					                },
					            }
					})

AddRoom("VolcanoObsidian", { 
					colour={r=.55,g=.75,b=.75,a=.50},
					value = GROUND.VOLCANO,
					tags = {"ExitPiece"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {
					                    magmarock = 1,
					                    magmarock_gold = 1,
					                    charcoal = 0.04,
					                    skeleton = 0.25,
					                },

					                countprefabs =
					                {
					                	volcanofog = math.random(1, 2)
					                },
					            }
					})

AddRoom("VolcanoStart", {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = GROUND.VOLCANO_NOISE,
					tags = {"ExitPiece"},
					custom_tiles = {
						GeneratorFunction = VolcanoNoise.GeneratorFunction,
						data = {}
					},
					contents =  {
									countstaticlayouts=
									{
										["VolcanoStart"] = 1
									},
					                distributepercent = .1,
					                distributeprefabs=
					                {
					                    magmarock = .5,
					                    magmarock_gold = .5,
					                    rock_obsidian = .5,
					                    rock_charcoal = .5,
					                    volcano_shrub = .5,
					                    charcoal = 0.04,
					                    skeleton = 0.1,
					                },

					                countprefabs =
					                {
					                	volcanofog = math.random(1, 2)
					                },

					                prefabdata =
					                {
					                	magmarock = {regen=true},
					                	magmarock_gold = {regen=true}
					            	}
					            }
					})

AddRoom("VolcanoNoise", {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = GROUND.VOLCANO_NOISE,
					tags = {"ExitPiece"},
					custom_tiles = {
						GeneratorFunction = VolcanoNoise.GeneratorFunction,
						data = {}
					},
					contents =  {
									countstaticlayouts=
									{
										["CoffeeBushBunch"] = function()
											if math.random() < 0.25 then
												return 1
											else
												return 0
											end
										end
									},
					                distributepercent = .1,
					                distributeprefabs=
					                {
					                    magmarock = .5,
					                    magmarock_gold = .5,
					                    rock_obsidian = .5,
					                    rock_charcoal = .5,
					                    volcano_shrub = .5,
					                    charcoal = 0.04,
					                    skeleton = 0.1,
					                    dragoonden = .05,
					                    elephantcactus = 1,
					                    coffeebush = 1,
					                },

					                countprefabs =
					                {
					                	volcanofog = math.random(1, 2)
					                },

					                prefabdata =
					                {
					                	magmarock = {regen=true},
					                	magmarock_gold = {regen=true}
					            	}
					            }
					})

AddRoom("VolcanoObsidianBench", {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = GROUND.VOLCANO,
					tags = {"ExitPiece"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {
					                    magmarock = 1,
					                    magmarock_gold = 1,
					                    obsidian = .2,
					                    charcoal = 0.04,
					                    skeleton = 0.5,
					                },
					                countprefabs = 
					                {
					                	volcanofog = math.random(1, 2)
					                },
					            	countstaticlayouts = {
										["ObsidianWorkbench"] = 1,
									},
					                prefabdata =
					                {
					                	magmarock = {regen=true},
					                	magmarock_gold = {regen=true}
					            	}
					            }
					})

AddRoom("VolcanoAltar", {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = GROUND.VOLCANO,
					tags = {"ExitPiece"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {
					                    magmarock = 1,
					                    charcoal = 0.04,
					                    skeleton = 0.5
					                },

					                countprefabs=
					                {
					                	volcanofog = math.random(1, 2)
					            	},

					            	countstaticlayouts = {
										["VolcanoAltar"] = 1,
									},

					                prefabdata =
					                {
					                	magmarock = {regen=true},
					                	magmarock_gold = {regen=true}
					            	}
					            }
					})


AddRoom("VolcanoCage", {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = GROUND.VOLCANO,
					tags = {"ExitPiece"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {
					                    magmarock = 1,
					                    charcoal = 0.04,
					                    skeleton = 0.5,
					                    dragoonden = .2,
					                    coffeebush = 0.25,
					                },

					            	countstaticlayouts = {
										["WoodlegsUnlock"] = 1,
									},

					                countprefabs=
					                {
					                	volcanofog = math.random(1, 2)
					                },
					            }
					})

AddRoom("VolcanoLava", {
					colour={r=1.0,g=0.55,b=0,a=.50},
					value = GROUND.VOLCANO_LAVA,
					type = "blank",
					tags = {},
					contents =  {
					                distributepercent = 0,
					                distributeprefabs = {},
					            }
					})
