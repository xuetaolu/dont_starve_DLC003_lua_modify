
AddRoom("BGGrassBurnt", {
					colour={r=.5,g=.8,b=.5,a=.50},
					value = GROUND.GRASS,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .275,
					                distributeprefabs=
					                {
										rock1=0.01,
										rock2=0.01,
										spiderden=0.001,
										beehive=0.003,
										flower=0.112,
										grass=0.2,
										smallmammal = {weight = 0.02, prefabs = {"rabbithole", "molehill"}},
										flint=0.05,
										sapling=0.2,
										evergreen=0.3,
					                },
									prefabdata={
										evergreen = {burnt=true},
									}
					            }
					})

-- Nothing to see here buddy... keep scrolling...
local tree_prefabs = {"evergreen"}
if rawget(_G, "GEN_PARAMETERS") ~= nil then
	local params = json.decode(GEN_PARAMETERS)
	if params.ROGEnabled or params.level_type == "shipwrecked" or params.level_type == "volcano" then
		tree_prefabs = {"evergreen", "deciduoustree"}
	end
end

AddRoom("BGGrass", {
					colour={r=.5,g=.8,b=.5,a=.50},
					value = GROUND.GRASS,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .275,
					                distributeprefabs=
					                {
										spiderden=0.001,
										beehive=0.003,
										flower=0.112,
										grass=0.4, --raised from.2
										smallmammal = {weight = 0.02, prefabs = {"rabbithole", "molehill"}},
										carrot_planted=0.05,
										flint=0.05,
										berrybush=0.05,
										sapling=0.2,
										tree = {weight = 0.3, prefabs = tree_prefabs},
										pond=.001, 
					                    blue_mushroom = .005,
					                    green_mushroom = .003,
					                    red_mushroom = .004,
					                },
					            }
					})
AddRoom("BGGrassIsland", {
					colour={r=.5,g=.8,b=.5,a=.50},
					value = GROUND.GRASS,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .275,
					                distributeprefabs=
					                {
										spiderden=0.001,
									--	beehive=0.003,
										flower=0.112,
										grass=0.4, --raised from.2
									--	smallmammal = {weight = 0.02, prefabs = {"rabbithole", "molehill"}},
										carrot_planted=0.05,
										flint=0.05,
										berrybush=0.05,
										sapling=0.2,
									--	tree = {weight = 0.3, prefabs = {"evergreen", "deciduoustree"}},
									--	pond=.001, cut until we change it
					                    blue_mushroom = .005,
					                    green_mushroom = .003,
					                    red_mushroom = .004,
					                },
					            }
					})


AddRoom("FlowerPatch", {
					colour={r=.5, g=1,b=.8,a=.50},
					value = GROUND.GRASS,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {
                                        fireflies = 1,
					                    flower=2,
					                    beehive=1,
					                },
					            }
					})
AddRoom("GrassyMoleColony", {
					colour={r=.5, g=1,b=.8,a=.50},
					value = GROUND.GRASS,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {
                                        flower = 1,
					                    molehill=2,
					                    rocks=.3,
					                    flint=.3,
					                },
					            }
					})
AddRoom("EvilFlowerPatch", {
					colour={r=.8,g=1,b=.4,a=.50},
					value = GROUND.GRASS,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs=
					                {
                                        fireflies = 1,
					                    flower_evil=2,
					                    wasphive=0.5,
					                },
					            }
					})
