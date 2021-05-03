
AddRoom("Magma", {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = GROUND.MAGMAFIELD,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = .25,
					                distributeprefabs=
					                {
					                    magmarock = 2, --nitre
					                    magmarock_gold = 1,
					                    rock1 = .75,
					                    rock2 = .25, --gold 
					     				rocks = 1.5,
					                    flint= 1.5, -- lowered from 3
					                    -- rock_ice = 1,
					                    --tallbirdnest= --2, --.1,
					                    spiderden=.1,
                                        sapling = 1.5,
					                },
					            }
					})

AddRoom("MagmaHome", {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = GROUND.MAGMAFIELD,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = .2,
					                distributeprefabs=
					                {
					                	magmarock_gold = 2,
					                	magmarock = 2,
					                    rock1 = .5, --nitre
					                    --rock2 = 2, --gold
					                    rock_flintless = 2, 
					                    rocks = 1, --was 0.5
					                    flint = 1, -- lowered from 3
					                    -- rock_ice = 1,
					                    --tallbirdnest= --2, --.1,
					                    spiderden=.1,
                                        sapling = 1.5,
					     
					                },

					                countprefabs =
					                {
					                	flint = 4
					                }
					            }
					})

AddRoom("MagmaHomeBoon", {  
					colour={r=.66,g=.66,b=.66,a=.50},
					value = GROUND.MAGMAFIELD,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = .2,
					                distributeprefabs=
					                {
					                	magmarock = 1,
					                	magmarock_gold = 1,
					                    --rock1 = 2, --nitre
					                    rock2 = 1, --gold
					                    rock_flintless = 2, 
					                    rocks = 0.8,
					                    flint = 1, -- lowered from 3
					                    -- rock_ice = 1,
					                    --tallbirdnest= --2, --.1,
					                    spiderden=.1,
                                        sapling = 1.5,
					                },

					                countprefabs =
					                {
					                	flint = 4
					                }
					            }
					})

AddRoom("BG_Magma", {  
					colour={r=.66,g=.66,b=.66,a=.50},
					value = GROUND.MAGMAFIELD,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = .2,
					                distributeprefabs=
					                {
										magmarock = 1,
										magmarock_gold = 1,
										flint = 0.5,
										rock1 = 1,
										rock2 = 1,
										rocks = 1,
										tallbirdnest = 0.08,
                                        sapling = 1.5,
					                    spiderden = .1,
					                },
					            }
					})
	-- No trees, lots of rocks, rare tallbird nest, very rare spiderden
	-- MR - Pasted in these 2 from Rocky, there is also Chessrocoky in the original.
--[[AddRoom("MagmaFOREDITING", {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = GROUND.DIRT,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {
					                    rock1 = 2,
					                    rock2 = 2,
					                    flint=0.5, -- MR Added
					                    --tallbirdnest= --10,--.1,
					                    spiderden=.01,
					                    
					                },
					            }
					}) ]]

AddRoom("GenericMagmaNoThreat", {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = GROUND.MAGMAFIELD,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = .25,
					                distributeprefabs =
					                {
					                    magmarock = 2,
					                    magmarock_gold = 1,
										rock1 = 0.5,
										rock2 = 0.3,
					                    --rock_ice = .75,
					                    rocks = 2,
					                    flint = 1.5,
                                        sapling = .05,
					                    blue_mushroom = .002,
					                    green_mushroom = .002,
					                    red_mushroom = .002,
                                        sapling = .5,
					                    spiderden=.1,
					                },
					            }
					})

AddRoom("MagmaVolcano", {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = GROUND.MAGMAFIELD,
					tags = {"ExitPiece"},
					contents =  {
					                distributepercent = .2,
					                distributeprefabs=
					                {
					                    magmarock = 1,
					                    magmarock_gold = 1,
					                    rock1 = 2,
					                    rock2 = 2,
					                    rocks = 1,
					                    flint= 1,
                                        sapling = .5,
					                    spiderden=.1,
					                },

					                countprefabs =
					                {
					                	volcano = 1
					                }
					            }
					})


AddRoom("MagmaSpiders", {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = GROUND.MAGMAFIELD,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = .2,
					                distributeprefabs=
					                {
					                    magmarock = 2,
					                    magmarock_gold = 1,
					                    rock1 = 2, --nitre
					                    rock2 = 2, --gold
					                    rock_flintless = 2, 
					                    rocks = 1,
					                    flint= 1, -- lowered from 3
					                    -- rock_ice = 1,
					                    tallbirdnest= .2, --.1,
					                    spiderden=1.5, --.5,
                                        sapling = .5,
					     
					                },
					            }
					})

AddRoom("MagmaGold", {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = GROUND.MAGMAFIELD, 
					contents =  {
									distributepercent = .3,
									distributeprefabs =
									{
										magmarock = 0.8,
										magmarock_gold = 1.2, --gold
										rock1 = 0.5,
										rock2 = 0.3,
										rock_flintless = .5,
										rocks = 1,
										flint = .5,
										goldnugget = .25,
					                    tallbirdnest= .2,
                                        sapling = .5,
					                    spiderden=.1,
									},
					            }
					})

AddRoom("MagmaGoldBoon", {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = GROUND.MAGMAFIELD, 
					contents =  {
									distributepercent = .25,
									distributeprefabs =
									{
										magmarock_gold = 1,
										rock1 = 0.5,
										rock2 = 0.3,
										rocks = 3,
										flint = 1,
										goldnugget = 1,
					                    tallbirdnest= .2,
                                        sapling = .5,
					                    spiderden=.1,
									},
					            }
					})

AddRoom("MagmaTallBird", {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = GROUND.MAGMAFIELD, 
					contents =  {
									distributepercent = .3,
									distributeprefabs =
									{
										magmarock = 1,
										magmarock_gold = 0.75,
										rock1 = 0.5,
										rock2 = 0.3,
										rocks = 1,
										rock_flintless = 1,
										tallbirdnest = .25,
                                        sapling = .5,
					                    spiderden=.1,
									},
					            }
					})

AddRoom("MagmaForest", {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = GROUND.MAGMAFIELD, 
					contents =  {
									distributepercent = .4,
									distributeprefabs =
									{
										magmarock = 1,
										magmarock_gold = 0.25,
										rock1 = 0.5,
										rock2 = 0.3,
										rocks = 2,
										rock_flintless = 1,
										jungletree = 5,
                                        sapling = 2,
					                    spiderden = .1,
									},

									--[[countprefabs =
					                {
					                	jungletree = math.random(8, 16),
					                },]]
					                prefabdata =
					                {
					                	jungletree = {burnt=true},
					            	}
					            }
					})