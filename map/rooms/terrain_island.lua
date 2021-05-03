AddRoom("Forest1", {
					colour={r=.5,g=0.0,b=.0,a=.10},
					value = GROUND.FOREST,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .3,
					                distributeprefabs=
					                {
					                    evergreen = 6,
					                    gravestone=0.01,
										wildborehouse=0.015,
										spiderden=0.04,
										grass=0.0025,
										sapling=0.15,
										rock1=0.008,
										rock2=0.008,
										evergreen_sparse=1.5,
										flower=0.05,
										pond=.001,
					                    green_mushroom = .025,
					                    red_mushroom = .025,
					                },
					            }
					})
AddRoom("Forest2", {
					colour={r=0,g=0.5,b=0,a=.10},
					value = GROUND.FOREST,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .6,
					                distributeprefabs=
					                {
					                    evergreen = 6,
					                    gravestone=0.01,
										wildborehouse=0.015,
										spiderden=0.02,
										grass=0.0025,
										sapling=0.15,
										berrybush=0.005,
										rock1=0.004,
										rock2=0.004,
										evergreen=1.5,
										flower=0.05,
										pond=.001,
					                    green_mushroom = .025,
					                    red_mushroom = .025,
					                },
					            }
					})
AddRoom("ForestSpiders", {
					colour={r=.80,g=0.34,b=.80,a=.50},
					value = GROUND.FOREST,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .2,
					                distributeprefabs=
					                {
					                    evergreen_sparse = 6,
					                    rock1 = 0.05,
					                    sapling = .05,
										spiderden = 1,
					                },
									prefabdata = {
										spiderden = function() if math.random() < 0.2 then
																	return { growable={stage=2}}
																else
																	return { growable={stage=1}}
																end
															end,
									},
					            }
					})
AddRoom("Forest4", {
					colour={r=0,g=.5,b=.5,a=.10},
					value = GROUND.FOREST,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = 0.01,
					                distributeprefabs=
					                {
					                    evergreen = 6
					                },
					            }
					})
