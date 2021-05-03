
AddRoom("TidalMarsh", {
					colour={r=0,g=.5,b=.5,a=.10},
					value = GROUND.TIDALMARSH,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts =
									{
										["TidalpoolMedium"] = function() return math.random(0, 6) end,
										["TidalpoolLarge"] = function() return math.random(0, 3) end,
									},

					                distributepercent = 0.3,
					                distributeprefabs =
					                {
					                    jungletree = .05,
					                    marsh_bush = .05,
					                    tidalpool = 1,
					                    reeds =  4,
					                    spiderden = .01,
					                    green_mushroom = 2.02,
					                    mermhouse = 0.1, --was 0.04
					                    mermhouse_fisher = 0.05,
					                    poisonhole = 2,
					                    seaweed_planted = 0.5,
					                    fishinhole = .1,
					                    flupspawner = 1,
					                    flup = 3,
					                },
					            }
					})

AddRoom("TidalMermMarsh", {
					colour={r=0,g=.5,b=.5,a=.10},
					value = GROUND.TIDALMARSH,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts =
									{
										["TidalpoolMedium"] = function() return math.random(0, 6) end,
										["TidalpoolLarge"] = function() return math.random(0, 3) end,
									},

					                distributepercent = 0.3,
					                distributeprefabs =
					                {
					                    jungletree = .05,
					                    marsh_bush = .05,
					                    tidalpool = 1,
					                    reeds =  2,
					                    spiderden=.01,
					                    green_mushroom = 2.02,
					                    mermhouse = 0.8,
					                    mermhouse_fisher = 0.4,
					                    poisonhole = 1,
					                    seaweed_planted = 0.5,
					                    fishinhole = .1,
					                    flupspawner_sparse = 1,
					                    flup = 1,
					                },
					            }
					})


--[[AddRoom("TidalFrogMarsh", {
					colour={r=0,g=.5,b=.5,a=.10},
					value = GROUND.TIDALMARSH,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = 0.3,
					                distributeprefabs =
					                {
					                    jungletree = .05,
					                    marsh_bush = .05,
					                    tidalpool = 1,
					                    reeds =  3,
					                    spiderden=.01,
					                    green_mushroom = 2.02,
					                    mermhouse = 0.004,
					                    mermhouse_fisher = 0.02,
					                    poisonhole = 1,
					                    seaweed_planted = 0.5,
					                    fishinhole = .1,
					                    flupspawner = 1,
					                    flup = 1,
					                },
					            }
					})
]]
AddRoom("ToxicTidalMarsh", {
					colour={r=0,g=.5,b=.5,a=.10},
					value = GROUND.TIDALMARSH,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts =
									{
										["TidalpoolMedium"] = function() return math.random(0, 6) end,
										["TidalpoolLarge"] = function() return math.random(0, 3) end,
									},

					                distributepercent = 0.3,
					                distributeprefabs =
					                {
					                    jungletree = .05,
					                    marsh_bush = .05,
					                    tidalpool = 1,
					                    reeds = 2, --was 4
					                    spiderden = .01,
					                    green_mushroom = 2.02,
					                    mermhouse = 0.1, --was 0.04
					                    mermhouse_fisher = 0.05,
					                    poisonhole = 3, --was 2
					                    seaweed_planted = 0.5,
					                    fishinhole = .1,
					                    flupspawner_dense = 1,
					                    flup = 2,
					                },
					            }
					})