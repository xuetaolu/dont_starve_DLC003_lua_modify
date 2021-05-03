
AddRoom("BeachClear", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.BEACH,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = 0,
					                distributeprefabs =
					                {
					                },

					                countprefabs = {
										beachresurrector = 1,
									}

					            }
					})

AddRoom("BeachSand", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.BEACH,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = .25,
					                distributeprefabs =
					                {
                                       limpetrock = .05,
                                       crabhole = .2,
                                       palmtree = .3,
                                       rocks = .03, --trying
                                       rock1 = .1, --trying
                                       --rock2 = .2,
                                       beehive = .01, --was .05, 
                                       --flower = .04, --trying
                                       grass = .2, --trying
                                       sapling = .2, --trying
                                       --fireflies = .02, --trying
                                       --spiderden = .03, --trying
                                       flint = .05,
                                       sandhill = .6,
                                       seashell_beached = .02,
					                   wildborehouse = .005,
					                   crate = .02,
					                },

					                countprefabs = {
										beachresurrector = 1,
										spoiled_fish = 0.5,
									}

					            }
					})

AddRoom("BeachSandHome", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.BEACH,
					tags = {"ExitPiece"}, --, "Packim_Fishbone"
					contents =  {
					                distributepercent = .3, --upped from .05
					                distributeprefabs=
					                {
                                       seashell_beached=.25,
                                       limpetrock= .05, 
                                       crabhole = .1, --was 0.2
                                       palmtree = .3,
                                       rocks = .03, --trying
                                       rock1 = .05,
                                       rock_flintless = .1, --trying
                                       --beehive = .05, --trying
                                       --flower = .04, --trying
                                       grass = .5, --trying
                                       sapling = .2, --trying
                                       --fireflies = .02, --trying
                                       --spiderden = .03, --trying
                                       flint = .05,
                                       sandhill = .1, --was .6,
                                       crate = .025,
					                },

					                countprefabs =
					                {
					                	flint = 1,
					                	sapling = 1,
					                }

					            }
					})

AddRoom("BeachUnkept", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.BEACH,
					tags = {"ExitPiece"}, --, "Packim_Fishbone"
					contents =  {
					                distributepercent = .3, --lowered from .3
					                distributeprefabs=
					                {
                                        seashell_beached=0.125, 
                                        grass = .3, --down from 3
                                        sapling = .1, --lowered from 15
                                        --flower = 0.05,
                                        limpetrock =.02,
                                        crabhole = .015, --was .03
                                        palmtree = .1,
                                        rocks = .003,
                                        beehive = .003,
                                        flint = .02,
                                        sandhill = .05,
                                     	--rock2 = .01,
                                        dubloon = .001,
					            		wildborehouse = .005,
					                },

					                countprefabs = {
									
										beachresurrector = 1,
										spoiled_fish = 0.3,
									}

					            }
					})

AddRoom("BeachUnkeptDubloon", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.BEACH,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = .3, 
					                distributeprefabs=
					                {
                                        seashell_beached=0.025, 
                                        grass = .1, --was .3
                                        sapling = .05, --was .15
                                        --flower = 0.05,
                                        limpetrock =.02,
                                        --crabhole = .015, --was .03
                                        palmtree = .1,
                                        rocks = .003,
                                        --beehive = .003,
                                        flint = .01, --was .02,
                                        sandhill = .05,
                                     	--rock2 = .01,
                                        goldnugget = .007,
                                        dubloon = .01, -- this should be relatively high on this island
                                        skeleton = .025,
					                   wildborehouse = .005,
					                },

					                countprefabs = {
									
										beachresurrector = 1,
									}

					            }
					})

AddRoom("BeachGravel", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.BEACH,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = .3,
					                distributeprefabs=
					                {
					                	limpetrock = 0.01,
					                	rocks = 0.1,
					                	flint = 0.02,
					                    rock1 = 0.05,
					                 	--rock2 = 0.05,
					                    rock_flintless = 0.05,
					                    grass = .05,
					                    --flower = 0.05, --removed as it's used on NoFlower island
					                    sandhill = .05,
                                       seashell_beached = .025, 
					                   wildborehouse = .005,
					                },

					                countprefabs = {
									
										beachresurrector = 1,
									}

					            }
					})

--[[AddRoom("BeachSinglePalmTree", {
					colour={r=.66,g=.66,b=.66,a=.50},
					value = GROUND.BEACH,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countprefabs = {
										palmtree = 1, --one palm tree
										seashell_beached = 1, --one seashell
										--coconut = 1, --one coconut
										mandrake =0.05,
										beachresurrector = 1,
										sandhill = .05,
									}
					            }
					})
]]
AddRoom("BeachSinglePalmTreeHome", {
					colour={r=.66,g=.66,b=.66,a=.50},
					value = GROUND.BEACH,
					tags = {"ExitPiece"}, --, "Packim_Fishbone"
					contents =  {
									countprefabs = {
										palmtree = 1, --one palm tree
										seashell_beached = 1, --one seashell
										--coconut = 1, --one coconut
										raft = 1, 
										--mandrake =0.05,
										beachresurrector = 1,
										sandhill = .05,
									}
					            }
					})

AddRoom("DoydoyBeach", {
					colour={r=.66,g=.66,b=.66,a=.50},
					value = GROUND.BEACH,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									distributepercent = .3,
					                distributeprefabs=
					                {
					                   flower_evil = 0.5,
					                   fireflies = 1, -- results in an empty beach because these only show at night
					                   flower = .75,
					                   sandhill = .5,
					                },
									countprefabs = {
										doydoy = 1,
										palmtree = 1, --one palm tree
										seashell_beached = 1, --one seashell
										--coconut = 1, --one coconut
										--mandrake =0.05,
										beachresurrector = 1,
										sandhill = .05,
									}
					            }
					})

AddRoom("BeachWaspy", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.BEACH,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = .1, -- just copied this whole thing from EvilFlowerPatch in terrain_grass
					                distributeprefabs=
					                {
					                   flower_evil =0.05,
					                   --fireflies = .1, -- was 1, now .1 (results in an empty beach because these only show at night)
					                   wasphive = .005,
					                   sandhill = .05,
					                   limpetrock = 0.01,
                                       flint = .005,
                                       seashell_beached = .025, 
					                },

					                countprefabs = {
									
										beachresurrector = 1,
									}

					            }
					})

AddRoom("BeachPalmForest", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.BEACH,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = .3,
					                distributeprefabs=
					                {
					                   palmtree = .5,
					                   sandhill = .05,
					                   crabhole = .025,
					                   grass = .05,
					                   limpetrock = .015,
                                       flint = .005,
                                       seashell_beached = .025, 
					                   wildborehouse = .005,
					                },
								}
						})

AddRoom("BeachPiggy", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.BEACH,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = .2, -- just copied this whole thing from EvilFlowerPatch in terrain_grass
					                distributeprefabs=
					                {
					                   sapling = 0.25,
					                   grass = .5,
					                   palmtree = .1,
					                   wildborehouse = .05,
					                   limpetrock = 0.1,
					                   sandhill = .3,
                                       seashell_beached = .125, 
					                },

					                countprefabs = {
									
										beachresurrector = 1,
									},

					            }
					})

AddRoom("BeesBeach", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.BEACH,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = .3, --Up from .025
					                distributeprefabs=
					                {
                                       seashell_beached=0.025,
                                       limpetrock= .05, --reducing from .2 (everything is so low here)
                                       crabhole = .2,
                                       palmtree = .3,
                                       rocks = .03, --trying
                                       rock1 = .1, --trying
                                       beehive = .1, --was .5
                                       wasphive = .05,
                                       --flower = .04, --trying
                                       grass = .4, --trying
                                       sapling = .4, --trying
                                       --fireflies = .02, --trying
                                       --spiderden = .03, --trying
                                       flint = .05,
                                       sandhill = .4, --was .04
					                },

					                countprefabs = {
										beachresurrector = 1,
									}

					            }
					})

AddRoom("BeachCrabTown", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.BEACH,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = .25,
					                distributeprefabs=
					                {
                                       limpetrock = 0.005,
                                       crabhole = 1,
                                       sapling = .2,
                                       palmtree = .75,
                                       grass = .5,
                                       --flower=.1,
                                       seashell_beached=.01,
                                       rocks=.1,
                                       rock1=.2,
                                       --fireflies=.1,
                                       --spiderden=.001,
                                       flint=.01,
                                       sandhill=.3,
					                },

					            }
					})

AddRoom("BeachDunes", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.BEACH,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = .1, 
					                distributeprefabs=
					                {
                                       sandhill = 1.5,
                                       grass = 1,
                                       seashell_beached = .5,
                                       sapling = 1,
                                       rock1 = .5,
                                       limpetrock = 0.1,
					                   wildborehouse = .05,
					                },

					            }
					})

AddRoom("BeachGrassy", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.BEACH,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = .2, --was .1
					                distributeprefabs=
					                {
                                       grass = 1.5,
                                       limpetrock = .25,
                                       beehive = .1,
                                       sandhill = 1, 
                                       rock1 = .5,
                                       crabhole = .5,
                                       flint = .05,
                                       seashell_beached = .25, 
					                },

					            }
					})

AddRoom("BeachSappy", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.BEACH,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = .1, 
					                distributeprefabs=
					                {
                                       sapling = 1,
                                       crabhole = .5,
                                       palmtree = 1,
                                       limpetrock = 0.1,
                                       flint = .05,
                                       seashell_beached = .25, 
					                },

					            }
					})

AddRoom("BeachRocky", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.BEACH,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = .1, 
					                distributeprefabs=
					                {
                                       rock1 = 1,
                                       --rock2 = 1, removing to take gold vein rocks out of all beaches
                                       rocks = 1,
                                       rock_flintless = 1,
                                       grass = 2, 
                                       crabhole = 2,
                                       limpetrock = 0.01,
                                       flint = .05,
                                       seashell_beached = .25, 
					                   wildborehouse = .05,
					                },

					            }
					})

AddRoom("BeachLimpety", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.BEACH,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = .1, 
					                distributeprefabs=
					                {
                                       limpetrock = 1,
                                       rock1 = 1,
                                       grass = 1,
                                       seashell = 1,
                                       sapling = .5,
                                       flint = .05,
                                       seashell_beached = .25, 
					                   wildborehouse = .05,
					                },

					                countprefabs = {
									
										beachresurrector = 1,
										spoiled_fish = 0.8,
									}

					            }
					})

AddRoom("BeachSpider", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.BEACH,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = .2,
					                distributeprefabs=
					                {
                                       limpetrock = 0.01,
                                       spiderden = 1,
                                       palmtree = 1,
                                       grass = 1,
                                       rocks = 0.5,
                                       sapling = 0.2,
                                       flint = .05,
                                       seashell_beached = .25, 
					                   wildborehouse = .025,
					                },

					            }
					})

AddRoom("BeachNoFlowers", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.BEACH,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = .1, --Lowered a bit
					                distributeprefabs=
					                {
                                       seashell_beached=0.0025,
                                       limpetrock= .005, --reducing from .03 (everything is so low here)
                                       crabhole = .002,
                                       palmtree = .3,
                                       rocks = .003, --trying
                                       beehive = .005, --trying
                                       grass = .3, --trying
                                       sapling = .2, --trying
                                       --fireflies = .002, --trying
                                       flint = .05,
                                       sandhill =.055,
					                },

					            }
					})

AddRoom("BeachFlowers", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.BEACH,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = .5, --was .1
					                distributeprefabs =
					                {
                                       beehive = .1, --was .5
                                       flower = 2, --was 1
                                       palmtree = .3,
                                       rock1 = .1,
                                       grass = .2,
                                       sapling = .1,
                                       seashell_beached = .025, 
                                       limpetrock = 0.01,
                                       flint = .05,
					                },

					            }
					})

AddRoom("BeachNoLimpets", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.BEACH,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = .1, --Lowered a bit
					                distributeprefabs=
					                {
                                       seashell_beached = 0.0025,
                                       crabhole = .002,
                                       palmtree = .3,
                                       rocks = .003, --trying
                                       beehive = .0025, --trying
                                       --flower = 0.04, --trying
                                       grass = .3, --trying
                                       sapling = .2, --trying
                                       --fireflies = .002, --trying
                                       flint = .05,
                                       sandhill =.055,
					                   wildborehouse = .05,
					                },

					            }
					})

AddRoom("BeachNoCrabbits", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.BEACH,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = .1, --Lowered a bit
					                distributeprefabs=
					                {
                                       seashell_beached=0.0025,
                                       limpetrock = 0.01,
                                       palmtree = .3,
                                       rocks = .003, --trying
                                       beehive = .005, --trying
                                       --flower = 0.04, --trying
                                       grass = .3, --trying
                                       sapling = .2, --trying
                                       --fireflies = .002, --trying
                                       flint = .05,
                                       sandhill =.055,
					                },

					            }
					})

AddRoom("BeachPalmCasino", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.BEACH,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = .1, --Lowered a bit
					                distributeprefabs=
					                {
                                       seashell_beached=0.025,
                                       limpetrock = 0.01,
                                       palmtree = .3,
                                       rocks = .003, --trying
                                       beehive = .005, --trying
                                       --flower = 0.04, --trying
                                       grass = .3, --trying
                                       sapling = .2, --trying
                                       --fireflies = .002, --trying
                                       flint = .05,
                                       sandhill =.055,
					                },

					            }
					})

AddRoom("BeachShells", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.BEACH,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = .25, 
					                distributeprefabs =
					                {
                                       seashell_beached = 1.25, 
                                       limpetrock = .05, 
                                       crabhole = .2,
                                       palmtree = .3,
                                       rocks = .03,
                                       rock1 = .025, --was .1,
                                       --rock2 = .05, --was .2,
                                       beehive = .02,
                                       --flower = .04,
                                       grass = .3, --was .2,
                                       sapling = .2,
                                       --fireflies = .02,
                                       --spiderden = .03,
                                       flint = .25,
                                       sandhill = .1, --was .6,
					                   wildborehouse = .05,
					                },

					                countprefabs = {
										beachresurrector = 1,
									}

					            }
					})


AddRoom("BeachSkull", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.BEACH,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = .25,
					                distributeprefabs =
					                {
                                       limpetrock = .05,
                                       crabhole = .2,
                                       palmtree = .3,
                                       rocks = .03,
                                       rock1 = .1,
                                       beehive = .01,
                                       grass = .2,
                                       sapling = .2,
                                       flint = .05,
                                       sandhill = .6,
                                       seashell_beached = .02,
					                   wildborehouse = .005,
					                   crate = .02,
					                },

					                treasures =
					                {
					                	{name="DeadmansTreasure"}
					            	},

									--[[treasure_data =
									{
										[3600] = {name="DeadmansTreasure", stage=1}
									}]]

					            }
					})
