
AddRoom("SampleRoom", { --Name to use in the 'room_choices' list
					--Used for debug stuff
					colour={r=.5,g=0.6,b=.080,a=.10},

					--Tile type to use. GROUND (tile types) are in constants.lua
					--Shipwrecked types: GROUND.JUNGLE, GROUND.BEACH, GROUND.SWAMP,
					--GROUND.OCEAN_SHALLOW, GROUND.OCEAN_MEDIUM, GROUND.OCEAN_DEEP
					value = GROUND.JUNGLE,

					tags = {"ExitPiece", "Packim_Fishbone"},

					--Room (biome) contents
					contents =  {
									--How densely items are placed on the biome 0 (few prefabs) to 1 (most prefabs)
					                distributepercent = 0.3,

					                --The prefabs to place on the biome. Higher number means more of that prefab.
					                --A precentage is determined by adding the values here.
					                --Look at the 'common_prefabs' table in prefabs/world.lua a lot are there
					                --prefabs/shipwrecked.lua too
					                distributeprefabs =
					                {
                                        fireflies = 0.2,
					                    palmtree = 1,
					                    jungletree = 6,
					                    rock1 = 0.05,
					                    flint = 0.05,
					                    grass = .07, -- was .05
					                    sapling = .8,
					                    berrybush2 = .05, -- was.03
					                    berrybush2_snake = 0.01,
					                    red_mushroom = .03,
					                    green_mushroom = .02,
					                    blue_mushroom = .02,
					                    flower = 0.75,
					                    primeapebarrel = .05,
					                },
					            }
					})

AddRoom("JungleClearing", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts={["MushroomRingLarge"]=function()  
																				if math.random(0,1000) > 985 then 
																					return 1 
																				end
																				return 0 
																			   end},

					                distributepercent = .2, --was .1
					                distributeprefabs =
					                {
                                        fireflies = 0.2,
					                    --palmtree = .05,
					                    jungletree = 1,
					                    rock1 = 0.03,
					                    rock1 = 0.03,
					                    flint = 0.03,
					                    grass = .03, --was .05
					                    --sapling = .8,
					                    --berrybush=.03,
					                    red_mushroom = .03,
					                    green_mushroom = .02,
					                    blue_mushroom = .02,
					                    flower = 0.75,
					                    bambootree = .5,
					                    wasphive = 0.125, --was 0.5
					                    spiderden = 0.2,
					                    --wildborehouse = 0.25,
					                },
					            }
					})

AddRoom("Jungle", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts=
									{
										["LivingJungleTree"]= function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end	
									},
					                distributepercent = 0.35, --was 0.2
					                distributeprefabs =
					                {
                                        fireflies = 0.2,
					                    --palmtree = 0.5, --lowered this from 6
					                    jungletree = 4,
					                    rock1 = 0.05, --was .01
					                    rock2 = 0.1, --was .05
					                    flint = 0.1, --was 0.03,
					                    --grass = .01, --was .05
					                    --sapling = .8,
					                    berrybush2 = .09, -- was .0003
					                    berrybush2_snake = 0.01,
					                    red_mushroom = .03,
					                    green_mushroom = .02,
					                    blue_mushroom = .02,
					                    flower = 1, --was 0.75,
					                    bambootree = 1,
					                    bush_vine = .2, -- was 1
					                	snakeden = 0.01, -- was 0.1
					                    primeapebarrel = .1, --was .05,
					                    spiderden = .05, --was .01,
					                    --wildborehouse = 0.25,
					                },
					            }
					})

AddRoom("JungleSparse", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts=
									{
										["LivingJungleTree"]= function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end	
									},
					                distributepercent = 0.25,
					                distributeprefabs =
					                {
                                        fireflies = 0.2,
                                        --palmtree = .05,
					                    jungletree = 2, --.6,
					                    rock1 = 0.05,
					                    rock2 = 0.05,
					                    rocks = .3,
					                    flint = .1, --dropped
					                    --sapling = .8,
					                    berrybush2 = .05, --was .03
					                    berrybush2_snake = 0.01,
					            		--grass = 1,
					                    red_mushroom = .03,
					                    green_mushroom = .02,
					                    blue_mushroom = .02,
					                    flower = .5, --was 0.75
					                    bambootree = 1,
					                	bush_vine = .2, -- was 1
					                	snakeden = 0.01, -- was 0.1
					                	spiderden = 0.05,
					                	--wildborehouse = 0.25,
					                },
					            }
					})

AddRoom("JungleSparseHome", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece"}, --, "Packim_Fishbone"
					contents =  {
									countstaticlayouts=
									{
										["LivingJungleTree"]= function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end	
									},
					                distributepercent = 0.3, -- upped from 0.15
					                distributeprefabs =
					                {
                                        fireflies = 0.2,
                                        --palmtree = .05,
					                    jungletree = .6,
					                    rock_flintless = 0.05,
					                    -- rock2 = 0.05, --gold rock
					                    flint = .1, --dropped
					                    --grass = .6, --raised from 05 
					                    --sapling = .8,
					                    berrybush2 = .05, --was .03
					                    berrybush2_snake = 0.01,
					                    red_mushroom = .03,
					                    green_mushroom = .02,
					                    blue_mushroom = .02,
					                    flower = 2, --was 0.75,
					                    bambootree = 1,
					                    bush_vine = 1,
					                    snakeden = 0.1,
					                    spiderden = .01,
					                    --wildborehouse = 0.25,
					                },
					            }
					})

AddRoom("JungleDense", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts=
									{
										["LivingJungleTree"]= function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end	
									},
					                distributepercent = 0.4,
					                distributeprefabs =
					                {
                                        fireflies = 0.02, --was 0.2,
         			                    --palmtree = 0.05,
					                    jungletree = 3, --was 4,
					                    rock1 = 0.05,
 				                        rock2 = 0.1, --was .05
					                    --grass = 1, --was .05
					                    --sapling = .8,
					                    berrybush2 = .05,
					                    berrybush2_snake = 0.01,
					                    red_mushroom = .03,
					                    green_mushroom = .02,
					                    blue_mushroom = .02,
					                    flower = 0.75,
					                    bambootree = 1,
					                    flint = 0.1,
					                    spiderden = .1, --was .01
					                    bush_vine = 1,
					                    snakeden = 0.1,
					                    --wildborehouse = 0.03, --was 0.015,
					                    primeapebarrel = .05,
					                },
					            }
					})

AddRoom("JungleDenseHome", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece"}, --, "Packim_Fishbone"
					contents =  {
									countstaticlayouts=
									{
										["LivingJungleTree"]= function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end	
									},
					                distributepercent = 0.3, --lowered from 0.4
					                distributeprefabs =
					                {
                                        fireflies = 0.2,
         			                    --palmtree = 0.05,
					                    jungletree = 4,
					                    rock1 = 0.05,
 				                        --rock2 = 0.05, --gold rock
					                    --grass = 1, --was .05
					                    --sapling = .8,
					                    berrybush2 = .1, --was .05,
					                    berrybush2_snake = 0.03, --was 0.01,
					                    red_mushroom = .03,
					                    green_mushroom = .02,
					                    blue_mushroom = .02,
					                    flower = 0.75,
					                    bambootree = 1,
					                    flint = 0.1,
					                    spiderden = .01,
					                    bush_vine = 1,
					                    snakeden = 0.1,
					                    --wildborehouse = 0.03, --was 0.015,
					                    --primeapebarrel=.05,
					                },
					            }
					})

AddRoom("JungleDenseMed", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts=
									{
										["LivingJungleTree"]= function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end	
									},
					                distributepercent = 0.4, ---was 0.75
					                distributeprefabs =
					                {
                                        fireflies = 0.2,
                                        --palmtree = 0.05,
					                    jungletree = 2, --lowered from 6
					                    rock1 = 0.05,
					                    rock2 = 0.05,
					                    --grass = .02, --was .05
					                    --sapling = .8,
					                    berrybush2 = .06, --was .03,
					                    berrybush2_snake = .02, --was .01,
					                    red_mushroom = .03,
					                    green_mushroom = .02,
					                    blue_mushroom = .02,
					                    flower = 0.75,
					                    bambootree = 1,
					                    spiderden = .05, --was .01,
					                    bush_vine = 1,
					                    snakeden = 0.1,
					                    --wildborehouse = 0.03, --was 0.015,
					                },
					            }
					})

AddRoom("JungleDenseBerries", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts=
									{
										["LivingJungleTree"]= function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end	
									},
									countstaticlayouts={["BerryBushBunch"]=1}, --adds 1 per room
					                distributepercent = 0.35,
					                distributeprefabs =
					                {
                                        fireflies = 0.2,
                                        --palmtree = 0.05,
					                    jungletree = 4, --was 6
					                    rock1 = 0.05,
					                    rock2 = 0.05,
					                    --grass = .02, --was .05
					                    --sapling = .8,
					                    berrybush2 = .6, --was .03
					                    berrybush2_snake = .03, --was .01,
					                    red_mushroom = .03,
					                    green_mushroom = .02,
					                    blue_mushroom = .02,
					                    flower = 0.75,
					                    bambootree = 1,
					                    spiderden =.05, --was .01
					                    bush_vine = 1,
					                    snakeden = 0.1,
					                    --wildborehouse = 0.15, --was 0.015,
					                },
					            }
					})

AddRoom("JungleDenseMedHome", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece"}, --, "Packim_Fishbone"
					contents =  {
									countstaticlayouts=
									{
										["LivingJungleTree"]= function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end	
									},
					                distributepercent = 0.5, --was 0.75
					                distributeprefabs =
					                {
                                        fireflies = 0.2,
                                        --palmtree = 0.05,
					                    jungletree = 2, --was 6
					                    rock_flintless = 0.05,
					                    --rock2 = 0.05, --gold rock
					                    --grass = .8, --was .05
					                    --sapling = .8,
					                    berrybush2 = .06, --was .03,
					                    berrybush2_snake = .02, --was .01,
					                    red_mushroom = .03,
					                    green_mushroom = .02,
					                    blue_mushroom = .02,
					                    flower = 0.75,
					                    bambootree = 1, -- was 1
					                    spiderden = .05, --was .01
					                    bush_vine = 0.8, -- was 1
					                    snakeden = 0.1,
					                    --wildborehouse = 0.015,
					                },
					            }
					})

AddRoom("JungleDenseVery", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts=
									{
										["LivingJungleTree"]= function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end	
									},
					                distributepercent = .75, -- lowered from 1.0
					                distributeprefabs =
					                {
                                        fireflies = 0.2,
             		                    --palmtree = 0.05,
					                    jungletree = 1, --lowered from 6
					                    rock2 = 0.05,
					                    flint = 0.05,
					                    --grass = .02, --was .05
					                    --sapling = .8,
					                    berrybush2 = .05, --was .01,
					                    berrybush2_snake = .05, --was .01,
					                    red_mushroom = .03,
					                    green_mushroom = .02,
					                    blue_mushroom = .02,
					                    flower = 0.75,
					                    bambootree = 1,
					                    spiderden = .05,
					                    bush_vine = 1,
					                    snakeden = 0.1,
					                    --wildborehouse = 0.015,
					                    primeapebarrel = .125, --was .05,
					                },
					            }
					})

AddRoom("JunglePigs", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts=
									{
										["LivingJungleTree"]= function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end	
									},
									--countstaticlayouts={["DefaultPigking"]=1}, --adds 1 per room
					                distributepercent = 0.3,
					                distributeprefabs =
					                {
                                        fireflies = 0.2,
             		                    --palmtree = 0.05,
					                    jungletree = 3,
					                    rock1 = 0.05,
					                    flint = 0.05,
					                    --grass = .025,
					                    --sapling = .8,
					                    berrybush2 = .05, --was .01,
					                    berrybush2_snake = .05, --was .01,
					                    red_mushroom = .06,
					                    green_mushroom = .04,
					                    blue_mushroom = .04,
					                    flower = 0.75,
					                    bambootree = 1,
					                    spiderden = .05,
					                    bush_vine = 1,
					                    snakeden = 0.1,
					                    wildborehouse = 0.9, --was .015 and also was 2.15??
					                    --primeapebarrel=.05,
					                },
					            }
					})

AddRoom("JunglePigGuards", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts={["pigguard_berries_easy"]=1}, --adds 1 per room
					                distributepercent = 0.3,
					                distributeprefabs =
					                {
                                        fireflies = 0.2,
             		                    --palmtree = 0.05,
					                    jungletree = 3,
					                    rock1 = 0.05,
					                    flint = 0.05,
					                    --grass = .025,
					                    --sapling = .8,
					                    berrybush2 = .05, --was .01,
					                    berrybush2_snake = .05, --was .01,
					                    red_mushroom = .06,
					                    green_mushroom = .04,
					                    blue_mushroom = .04,
					                    flower = 0.75,
					                    bambootree = 1,
					                    spiderden = .05,
					                    bush_vine = 1,
					                    snakeden = 0.1,
					                    --primeapebarrel=.05,
					                },
					            }
					})

--[[AddRoom("JungleFroggy", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = 0.3,
					                distributeprefabs =
					                {
                                        fireflies = 0.2,
             		                    --palmtree = 0.05,
					                    jungletree = 3,
					                    rock1 = 0.05,
					                    flint = 0.05,
					                    --grass = .025,
					                    --sapling = .8,
					                    berrybush2 = .05, --was .01,
					                    berrybush2_snake = .05, --was .01,
					                    red_mushroom = .06,
					                    green_mushroom = .04,
					                    blue_mushroom = .04,
					                    flower = 0.75,
					                    bambootree = 1,
					                    spiderden = .01, --was .001
					                    bush_vine = 1,
					                    snakeden = 0.1,
					                    pond = 1, --frog pond
					                },
					            }
					})
]]
AddRoom("JungleBees", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts=
									{
										["LivingJungleTree"]= function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end	
									},
					                distributepercent = 0.3,
					                distributeprefabs =
					                {
					                    beehive = 0.5, 
					                    fireflies = 0.2,
             		                    --palmtree = 0.05,
					                    jungletree = 4,
					                    rock1 = 0.05,
					                    flint = 0.05,
					                    --grass = .025,
					                    --sapling = .8,
					                    berrybush2 = .05, --was .01,
					                    berrybush2_snake = .05, --was .01,
					                    red_mushroom = .06,
					                    green_mushroom = .04,
					                    blue_mushroom = .04,
					                    flower = 0.75,
					                    bambootree = 1,
					                    spiderden = .01, --was .001
					                    bush_vine = 1,
					                    snakeden = 0.1,
					                    -- pond = 1, --frog pond
					                },
					            }
					})

AddRoom("JungleFlower", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts=
									{
										["LivingJungleTree"]= function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end	
									},
					                distributepercent = .5, --was 0.35
					                distributeprefabs =
					                {
                                        fireflies = 0.2,
             		                    --palmtree = 0.05,
					                    jungletree = 2, --was 3
					                    rock1 = 0.05,
					                    --flint=0.05,
					                    --grass = .025,
					                    --sapling = .4,
					                    berrybush2 = .05, --was .01,
					                    berrybush2_snake = .05, --was .01,
					                    red_mushroom = .06,
					                    green_mushroom = .04,
					                    blue_mushroom = .04,
					                    flower = 10,
					                    bambootree = 0.5,
					                    spiderden = .05, --was .001
					                    bush_vine = 1,
					                    snakeden = 0.1,
					                    --pond = 1, --frog pond
					                },
					                countprefabs =
					                {
					                	butterfly_areaspawner = 6,
					            	},
					            }
					})

AddRoom("JungleSpidersDense", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts=
									{
										["LivingJungleTree"]= function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end	
									},
					                distributepercent = 0.5, --lowered from .5
					                distributeprefabs =
					                {
                                        fireflies = 0.2,
         			                    --palmtree = 0.05,
					                    jungletree = 4,
					                    rock1 = 0.05,
 				                        rock2 = 0.05,
					                    --grass = 1, --was .05
					                    --sapling = .8,
					                    berrybush2 = .1, --was .05,
					                    berrybush2_snake = .05, --was 0.01,
					                    red_mushroom = .03,
					                    green_mushroom = .02,
					                    blue_mushroom = .02,
					                    flower = 0.75,
					                    bambootree = 1,
					                    flint = 0.1,
					                    spiderden = .5,
					                    bush_vine = 1,
					                    snakeden = 0.1,
					                    --wildborehouse = 0.015,
					                    primeapebarrel = .15, --was .05,
					                },
					            }
					})

AddRoom("JungleSpiderCity", {
					colour={r=.30,g=.20,b=.50,a=.50},
					value = GROUND.JUNGLE,
					contents =  {
									countstaticlayouts=
									{
										["LivingJungleTree"]= function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end	
									},
					                countprefabs = {
                                        goldnugget = function() return 3 + math.random(3) end,
					                },
									distributepercent = 0.3,
					                distributeprefabs = {
					                    jungletree = 3,
					                    spiderden = 0.3,
					                },
									prefabdata = {
										spiderden = function() if math.random() < 0.2 then
																	return { growable={stage=3}}
																else
																	return { growable={stage=2}}
																end
															end,
									},
					            }
					})

-- THIS IS DAN --  -- THIS IS DAN --  -- THIS IS DAN --  -- THIS IS DAN --  -- THIS IS DAN --  -- THIS IS DAN --  -- THIS IS DAN --  -- THIS IS DAN --  -- THIS IS DAN --  -- THIS IS DAN --
AddRoom("JungleBamboozled", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts=
									{
										["LivingJungleTree"]= function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end	
									},
					                distributepercent = .75, --was .5, 
					                distributeprefabs =
					                {
                                        fireflies = 0.2,
             		                    --palmtree = 0.05,
					                    jungletree = .09, 
					                    rock1 = 0.05,
					                    -- flint=0.05,
					                    --grass = .025,
					                    --sapling = .04,
					                    berrybush2 = .05, --was .01,
					                    berrybush2_snake = .05, --was .01,
					                    red_mushroom = .06,
					                    green_mushroom = .04,
					                    blue_mushroom = .04,
					                    flower = 0.1,
					                    bambootree = 1, --was .5,
					                    spiderden = .05, --was .001,
					                    bush_vine = .04,
					                    snakeden = 0.1,
					                    
					                },

									
					            }
					})

AddRoom("JungleMonkeyHell", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts=
									{
										["LivingJungleTree"]= function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end	
									},
					                distributepercent = .3, --was .5
					                distributeprefabs =
					                {
                                        fireflies = 0.2,
             		                    --palmtree = 0.3,
					                    jungletree = 2, --was .4, 
					                    rock1 = 0.125, --was 0.5,
					                    rock2 = 0.125, --was 0.5,
					                    primeapebarrel = .2, --was .8,
					                    skeleton = .1,
					                    flint = 0.5,
					                    --grass = .75,
					                    --sapling = .4,
					                    berrybush2 = .1,
					                    berrybush2_snake = .01,
					                    red_mushroom = .06,
					                    green_mushroom = .04,
					                    blue_mushroom = .04,
					                    flower = .01,
					                    bambootree = 0.5,
					                    spiderden =.01,
					                    bush_vine = .04,
					                    snakeden = 0.01,
					                    
					                },
					            }
					})

AddRoom("JungleCritterCrunch", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts=
									{
										["LivingJungleTree"]= function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end	
									},
					                distributepercent = .25,
					                distributeprefabs =
					                {
                                        fireflies = 3,
             		                    --palmtree = 0.05,
					                    jungletree = 3, --was 3
					                    rock1 = 0.05,
					                    --flint=0.05,
					                    --grass = .025,
					                    --sapling = .4,
					                    berrybush2 = .05, --was .01,
					                    berrybush2_snake = .05, --was .01,
					                    red_mushroom = .06,
					                    green_mushroom = .04,
					                    blue_mushroom = .04,
					                    flower = 2,
					                    bambootree = 1,
					                    spiderden = 1,
					                    bush_vine = 0.2,
					                    snakeden = 0.1,
					                    beehive = 1.5, --was 3,
					                    wasphive = 2,

					                },
					            }
					})

AddRoom("JungleDenseCritterCrunch", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts=
									{
										["LivingJungleTree"]= function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end	
									},
					                distributepercent = 0.5, --was 0.75
					                distributeprefabs =
					                {
                                        fireflies = 2,
                                        --palmtree = 0.05,
					                    jungletree = 6,
					                    rock_flintless = 0.05,
					                    --rock2 = 0.05, --gold rock
					                    --grass = .05,
					                    --sapling = .8,
					                    berrybush2 = .75, --was 0.3
					                    berrybush2_snake = .02, --was .01,
					                    red_mushroom = .03,
					                    green_mushroom = .02,
					                    blue_mushroom = .02,
					                    flower = 1.5,
					                    bambootree = 1, --was 1
					                    spiderden = .05, --was .5,
					                    bush_vine = 0.8, --was 1
					                    snakeden = 0.1,
					                    --wildborehouse = 0.03, --was 0.015,
					                    beehive = .01, --was 2,
					                },
					            }
					})


AddRoom("JungleFrogSanctuary", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts=
									{
										["LivingJungleTree"]= function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end	
									},
					                distributepercent = 0.35,
					                distributeprefabs =
					                {
                                        fireflies = 1,
             		                    --palmtree = 0.5,
					                    jungletree = 1, --was 3
					                    rock1 = 0.05,
					                    --flint=0.05,
					                    --grass = .3,
					                    --sapling = .4,
					                    berrybush2 = .05, --was .01,
					                    berrybush2_snake = .05, --was .01,
					                    red_mushroom = .06,
					                    green_mushroom = .04,
					                    blue_mushroom = .04,
					                    flower = 1,
					                    bambootree = 0.5,
					                    spiderden = .05, --was .001
					                    bush_vine = 0.6,
					                    snakeden = 0.1,
					                    pond = 4, --was 6


					                },
					            }
					})

AddRoom("JungleShroomin", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts=
									{
										["LivingJungleTree"]= function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end	
									},
					                distributepercent = .5, --was 0.35
					                distributeprefabs =
					                {
                                        fireflies = 0.2,
             		                    --palmtree = .5,
					                    jungletree = 3,
					                    rock1 = 0.05,
					                    --flint=0.05,
					                    --grass = 1, --was .4,
					                    --sapling = .3,
					                    berrybush2 = .05, --was .01,
					                    berrybush2_snake = .05, --was .01,
					                    red_mushroom = 3,
					                    green_mushroom = 3,
					                    blue_mushroom = 2,
					                    flower = 0.7,
					                    bambootree = 0.5,
					                    spiderden =.05, --was .001
					                    bush_vine = .5,
					                    snakeden = 0.1,
					                    
					                },
					            }
					})

AddRoom("JungleRockyDrop", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts=
									{
										["LivingJungleTree"]= function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end	
									},
					                distributepercent = .35,
					                distributeprefabs =
					                {
                                        fireflies = 0.2,
             		                    --palmtree = 0.05,
					                    jungletree = 6,
					                    rock1 = 1, --was 3
					                    rock2 = .5, --was 2
					                    rock_flintless = 2,
					                    rocks = 3, 
					                    --flint = 0.05,
					                    --grass = .025,
					                    --sapling = .4,
					                    berrybush2 = .05, --was .01,
					                    berrybush2_snake = .05, --was .01,
					                    red_mushroom = .06,
					                    green_mushroom = .04,
					                    blue_mushroom = .04,
					                    flower = .9,
					                    bambootree = 0.5,
					                    spiderden = .05, --was .001
					                    bush_vine = 1,
					                    snakeden = 0.1,
					                },
					            }
					})

AddRoom("JungleEyeplant", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts=
									{
										["LivingJungleTree"]= function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end	
									},
					                distributepercent = .5, --was 0.35
					                distributeprefabs =
					                {
                                        fireflies = 0.2,
             		                    --palmtree = 0.05,
					                    jungletree = 2, --was 3
					                    --rock1 = 0.05,
					                    --flint = 0.05,
					                    --grass = .025,
					                    --sapling = .4,
					                    berrybush2 = .05, --was .01,
					                    berrybush2_snake = .05, --was .01,
					                    red_mushroom = .06,
					                    green_mushroom = .04,
					                    blue_mushroom = .04,
					                    flower = 1,
					                    bambootree = 0.5,
					                    spiderden = .25, --was .001
					                    bush_vine = 1,
					                    snakeden = 0.1,
					                    --wildborehouse = .5, --just added
					                    eyeplant = 4,
					                },

					                countprefabs =
					                {
					                	lureplant = 2,
					            	},
					            }
					})

AddRoom("JungleGrassy", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts=
									{
										["LivingJungleTree"]= function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end	
									},
					                distributepercent = .5, --was 0.35
					                distributeprefabs =
					                {
                                        fireflies = 0.2,
             		                    --palmtree = 0.05,
					                    jungletree = 2, --was 3
					                    rock1 = 0.05,
					                    --flint=0.05,
					                    --grass = 5,
					                    --sapling = .4,
					                    berrybush2 = .05, --was .01,
					                    berrybush2_snake = .05, --was .01,
					                    red_mushroom = .06,
					                    green_mushroom = .04,
					                    blue_mushroom = .04,
					                    flower = .2,
					                    bambootree = 0.5,
					                    spiderden = .05, --was .001
					                    bush_vine = 1,
					                    snakeden = 0.1,
					                },
					            }
					})

AddRoom("JungleSappy", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts=
									{
										["LivingJungleTree"]= function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end	
									},
					                distributepercent = .5, --was 0.35
					                distributeprefabs =
					                {
                                        fireflies = 0.2,
             		                    --palmtree = 0.05,
					                    jungletree = 1.5, --was 3
					                    rock1 = 0.05,
					                    --flint = 0.05,
					                    --grass = .025,
					                    sapling = 6,
					                    berrybush2 = .05, --was .01,
					                    berrybush2_snake = .05, --was .01,
					                    red_mushroom = .06,
					                    green_mushroom = .04,
					                    blue_mushroom = .04,
					                    flower = .3,
					                    bambootree = 0.5,
					                    spiderden = .001,
					                    bush_vine = 0.3,
					                    snakeden = 0.1,
					                },
					            }
					})

AddRoom("JungleEvilFlowers", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts=
									{
										["LivingJungleTree"]= function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end	
									},
					                distributepercent = .5, --was 0.35
					                distributeprefabs =
					                {
                                        fireflies = 0.2,
             		                    --palmtree = 0.05,
					                    jungletree = 2, --was 3
					                    rock1 = 0.05,
					                    --flint = 0.05,
					                    --grass = .025,
					                    --sapling = .4,
					                    berrybush2 = .05, --was .01,
					                    berrybush2_snake = .05, --was .01,
					                    red_mushroom = .06,
					                    green_mushroom = .04,
					                    blue_mushroom = .04,
					                    flower = .9,
					                    bambootree = 0.5,
					                    spiderden = .05, --was .001
					                    bush_vine = 1,
					                    snakeden = 0.1,
					                    flower_evil = 10,
					                    wasphive = 0.25, --just added
					                },
					             
					            }
					})

AddRoom("JungleParrotSanctuary", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts=
									{
										["LivingJungleTree"]= function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end	
									},
					                distributepercent = 0.9,
					                distributeprefabs =
					                {
         			                    --palmtree = 0.05,
					                    jungletree = .5,
					                    rock1 = 0.5,
 				                        rock2 = 0.5,
 				                        rocks = 0.4,
					                    --grass = 0.5, --was .05
					                    --sapling  = 8,
					                    berrybush2 = .1, --was .05,
					                    berrybush2_snake = .05, --was .01,
					                    red_mushroom = 0.05,
					                    green_mushroom = 0.03,
					                    blue_mushroom = 0.02,
					                    flower = 0.2,
					                    bambootree = 0.5,
					                    flint = 0.001,
					                    spiderden = 0.5,
					                    bush_vine = 0.9,
					                    snakeden = 0.1,
					                    --wildborehouse = 0.05, --was 0.005,
					                    primeapebarrel = 0.05,
					                    fireflies = 0.02,
					                },
					                
					            }
					})

--[[AddRoom("JungleNoGrass", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = 0.2,
					                distributeprefabs =
					                {
         			                    --palmtree = 0.05,
					                    jungletree = .5,
					                    rock1 = 0.5,
 				                        rock2 = 0.5,
 				                        rocks = 0.4,
					                    --sapling = .8,
					                    berrybush2 = .1, --was .05,
					                    berrybush2_snake = .05, --was .01,
					                    red_mushroom = 0.05,
					                    green_mushroom = 0.03,
					                    blue_mushroom = 0.02,
					                    flower = 0.2,
					                    bambootree = 0.5,
					                    flint = 0.001,
					                    spiderden = 0.5,
					                    bush_vine = 0.9,
					                    snakeden = 0.1,
					                    --wildborehouse = 0.025, --was 0.005,
					                    primeapebarrel = .15, --was .05,
					                    pond = 0.05,
					                    fireflies = 0.02,
					                },
					                
					            }
					})  ]]

AddRoom("JungleNoBerry", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts=
									{
										["LivingJungleTree"]= function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end	
									},
					                distributepercent = 0.3,
					                distributeprefabs =
					                {
         			                    --palmtree = 0.05,
					                    jungletree = 5, --was .5,
					                    rock1 = 0.5,
 				                        rock2 = 0.5,
 				                        rocks = 0.4,
					                    --grass = 0.6, --was .05
					                    --sapling = .8,
					                    red_mushroom = 0.05,
					                    green_mushroom = 0.03,
					                    blue_mushroom = 0.02,
					                    flower = 0.2,
					                    bambootree = 3, --was 0.5,
					                    flint = 0.001,
					                    spiderden = 0.5,
					                    bush_vine = 0.9,
					                    snakeden = 0.1,
					                    --wildborehouse = 0.05, --was 0.005,
					                    primeapebarrel = 0.05,
					                    fireflies = 0.02,
					                },
					                
					            }
					})

AddRoom("JungleNoRock", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts=
									{
										["LivingJungleTree"]= function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end	
									},
					                distributepercent = 0.2,
					                distributeprefabs =
					                {
         			                    --palmtree = 0.05,
					                    jungletree = 5,
					                    --grass = 0.6, --was .05
					                    --sapling = .8,
					                    berrybush2 = .05,
					                    berrybush2_snake = 0.01,
					                    red_mushroom = 0.05,
					                    green_mushroom = 0.03,
					                    blue_mushroom = 0.02,
					                    flower = 0.2,
					                    bambootree = 0.5,
					                    flint = 0.001,
					                    spiderden = 0.5,
					                    bush_vine = 0.9,
					                    snakeden = 0.1,
					                    --wildborehouse = 0.005,
					                    primeapebarrel = .25, --was .05,
					                    fireflies = 0.02,
					                },
					                
					            }
					})

AddRoom("JungleNoMushroom", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {

									countstaticlayouts=
									{
										["LivingJungleTree"]= function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end	
									},
					                distributepercent = 0.4, --was 0.2
					                distributeprefabs =
					                {
         			                    --palmtree = 0.05,
					                    jungletree = 5,
					                    rock1 = 0.05,
 				                        rock2 = 0.05,
 				                        rocks = 0.04,
					                    --grass = 0.6, --was .05
					                    --sapling = .8,
					                    berrybush2 = .1, --was .05,
					                    berrybush2_snake = .05, --was .01,
					                    flower = 0.2,
					                    bambootree = 0.5,
					                    flint = 0.001,
					                    spiderden = 0.5,
					                    bush_vine = 0.9,
					                    snakeden = 0.1,
					                    --wildborehouse = 0.05, --was 0.005,
					                    primeapebarrel = .15, --was .05,
					                    fireflies = 0.02,
					                },
					                
					            }
					})

AddRoom("JungleNoFlowers", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {

									countstaticlayouts=
									{
										["LivingJungleTree"]= function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end	
									},

					                distributepercent = 0.2,
					                distributeprefabs =
					                {
         			                    --palmtree = 0.05,
					                    jungletree = 5,
					                    rock1 = 0.05,
 				                        rock2 = 0.05,
 				                        rocks = 0.04,
					                    --grass = 0.6, --was .05
					                    --sapling = .8,
					                    berrybush2 = .1, --was .05,
					                    berrybush2_snake = .05, --was .01,
					                    red_mushroom = 0.05,
					                    green_mushroom = 0.03,
					                    blue_mushroom = 0.02,
					                    bambootree = 0.5,
					                    flint = 0.001,
					                    spiderden = 0.5,
					                    bush_vine = 0.9,
					                    snakeden = 0.1,
					                    --wildborehouse = 0.25,
					                    primeapebarrel = .15, --was .05,
					                    --pond = 0.05,
					                    fireflies = 0.02,
					                },
					                
					            }
					})



AddRoom("JungleMorePalms", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts=
									{
										["LivingJungleTree"]= function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end	
									},
					                distributepercent = .5,
					                distributeprefabs =
					                {
         			                    --palmtree = 3,
					                    jungletree = .3,
					                    rock1 = 0.05,
 				                        rock2 = 0.05,
 				                        rocks = 0.04,
					                    --grass = 0.6, --was .05
					                    --sapling = .8,
					                    berrybush2 = .1, --was .05,
					                    berrybush2_snake = .05, --was .01,
					                    red_mushroom = 0.05,
					                    green_mushroom = 0.03,
					                    blue_mushroom = 0.02,
					                    flower = 0.6,
					                    bambootree = 0.5,
					                    flint = 0.001,
					                    spiderden = 0.5,
					                    bush_vine = 0.9,
					                    snakeden = 0.1,
					                    --wildborehouse = 0.005,
					                    primeapebarrel = .15, --was .05,
					                    fireflies = 0.02,
					                },
					                
					            }
					})

AddRoom("JungleSkeleton", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.JUNGLE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts=
									{
										["LivingJungleTree"]= function() return (math.random() > TUNING.LIVINGJUNGLETREE_CHANCE and 1) or 0 end	
									},
					                distributepercent = .5, --was 0.35
					                distributeprefabs =
					                {
                                        fireflies = 0.2,
             		                    --palmtree = 0.05,
					                    jungletree = 1.5, --was 3
					                    rock1 = 0.05,
					                    --flint = 0.05,
					                    --grass = .025,
					                    --sapling = .4,
					                    berrybush2 = .05, --was .01,
					                    berrybush2_snake = .05, --was .01,
					                    red_mushroom = .06,
					                    green_mushroom = .04,
					                    blue_mushroom = .04,
					                    flower = .9,
					                    bambootree = 0.5,
					                    spiderden =.05, --was .001
					                    bush_vine = 1,
					                    snakeden = 0.1,
					                    flower_evil = .001,
					                    skeleton = 1.25,
					                },
					            }
					})

AddRoom("SW_Graveyard", {
					colour={r=.010,g=.010,b=.10,a=.50},
					value = GROUND.JUNGLE,
					tags = {"Town"},
					contents =  {
									distributepercent = .3,
					                distributeprefabs=
					                {
                                        grass = .1, --down from 3
                                        sapling = .1, --lowered from 15
                                        flower_evil = 0.05,
                                        rocks = .03,
                                        beehive = .0003,
                                        flint = .02,
					                },

					                countprefabs= {
					                    jungletree = 3,
                                        goldnugget = function() return math.random(5) end,
					                    gravestone = function () return 4 + math.random(4) end,
					                    mound = function () return 4 + math.random(4) end
					                }
					            }
					})
