AddRoom("BGChessRocky", {
					colour={r=.66,g=.66,b=.66,a=.50},
					value = GROUND.ROCKY,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
									countstaticlayouts = {
										["ChessSpot1"] = function() return math.random(0,3) end,
										["ChessSpot2"] = function() return math.random(0,3) end,
										["ChessSpot3"] = function() return math.random(0,3) end,
									},
					                distributepercent = .1,
					                distributeprefabs =
					                {
										flint = 0.5,
										rock1 = 1,
										rock2 = 1,
										tallbirdnest = 0.008,
					                },
					            }
					})

AddRoom("BGRocky", {
					colour={r=.66,g=.66,b=.66,a=.50},
					value = GROUND.ROCKY,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs =
					                {
										flint = 0.5,
										rock1 = 1,
										rock2 = 1,
										rock_ice=0.4, -- Was removed, needs to be changed if we have ROG installed or not
										tallbirdnest= 0.008,
					                },
					            }
					})
	-- No trees, lots of rocks, rare tallbird nest, very rare spiderden
AddRoom("Rocky", {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = GROUND.ROCKY,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs =
					                {
										rock1 = 0.5,
										rock2 = 0.3,
					                    rock_ice = 1, -- Was removed, needs to be changed if we have ROG installed or not
					                    tallbirdnest = .4, --was .1
					                    spiderden = .01,
					                    blue_mushroom = .02, --was .002
					                    goldnugget = 1,
					                },
					            }
					})


----------------------------------------------
-------------- Added with RoG ----------------
----------------------------------------------

AddRoom("RockyBuzzards", {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = GROUND.ROCKY,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs =
					                {
										rock1 = 0.5,
										rock2 = 0.3,
					                    buzzardspawner = .1, -- Was removed, needs to be changed if we have ROG installed or not
					                    blue_mushroom = .002,
					                },
					            }
					})

AddRoom("GenericRockyNoThreat", {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = GROUND.ROCKY,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs =
					                {
										rock1 = 0.5,
										rock2 = 0.3,
					                    rock_ice = .75, -- Was removed, needs to be changed if we have ROG installed or not
					                    rocks = 1,
					                    flint = 1,
					                    blue_mushroom = .002,
					                    green_mushroom = .002,
					                    red_mushroom = .002,
					                },
					            }
					})

AddRoom("MolesvilleRocky", { -- Replaced for MolesvilleRockyIsland in island.lua
					colour={r=.55,g=.75,b=.75,a=.50},
					value = GROUND.ROCKY, 
					contents =  {
									distributepercent = 0.1,
									distributeprefabs =
									{
										marsh_bush = 0.2,
										rock1 = 0.5,
										rock2 = 0.3,
										rock_ice = .3, -- Was removed, needs to be changed if we have ROG installed or not
										rocks = .5,
										flint = .1,
										grass = 0.1,
										molehill = 1, -- Was removed, needs to be changed if we have ROG installed or not
										
									},
					            }
					})

-----------------------------------------------------------------------------
-------- Added with Shipwrecked, only those should contain magmarocks -------
-----------------------------------------------------------------------------

AddRoom("MolesvilleRockyIsland", { -- Exists in island.lua
					colour={r=.55,g=.75,b=.75,a=.50},
					value = GROUND.ROCKY, 
					contents =  {
									distributepercent = 0.1,
									distributeprefabs =
									{
										marsh_bush = 0.2,
										magmarock = 1,
										magmarock_gold = 1,
										rock1 = 0.5,
										rock2 = 0.3,
										rock_ice = .3, -- Was removed, needs to be changed if we have ROG installed or not
										rocks = .5,
										flint = .1,
										grass = 0.1,
										--molehill = 1,
										
									},
					            }
					})



AddRoom("RockySpiders", {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = GROUND.ROCKY, 
					contents =  {
									distributepercent = 0.1,
									distributeprefabs =
									{
										marsh_bush = 0.2,
										magmarock = 1,
										magmarock_gold = 1,
										rock1 = 0.5,
										rock2 = 0.3,
										rocks = .5,
										flint = .1,
										grass = 0.1,
					                    spiderden=1, --.5,
									},
					            }
					})

AddRoom("RockyGold", {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = GROUND.ROCKY, 
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
									},
					            }
					})

AddRoom("RockyFlint", {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = GROUND.ROCKY, 
					contents =  {
									distributepercent = .1,
									distributeprefabs =
									{
										magmarock = 1,
										magmarock_gold = 0.8, --gold
										rock1 = 0.5,
										rock2 = 0.3,
										rocks = .5,
										flint = 1.2,
									},
					            }
					})

AddRoom("RockyTallBird", {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = GROUND.ROCKY, 
					contents =  {
									distributepercent = .1,
									distributeprefabs =
									{
										magmarock = 1,
										magmarock_gold = 1,
										rock1 = 0.5,
										rock2 = 0.3,
										rocks = 1,
										rock_flintless = 1,
										tallbirdnest= 1,
									},
					            }
					})

AddRoom("RockyBlueMushroom", {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = GROUND.ROCKY, 
					contents =  {
									distributepercent = .1,
									distributeprefabs =
									{
										magmarock = 1,
										magmarock_gold = 1,
										rock1 = 0.5,
										rock2 = 0.3,
										blue_mushroom= 1,
									},
					            }
					})

AddRoom("RockyGoldBoon", {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = GROUND.ROCKY, 
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
									},
					            }
					})


-- No trees, lots of rocks, rare tallbird nest, very rare spiderden
-- Shipwrecked version os Rocky (can be seen above)
AddRoom("RockyIsland", {
					colour={r=.55,g=.75,b=.75,a=.50},
					value = GROUND.ROCKY,
					tags = {"ExitPiece", "Chester_Eyebone"},
					contents =  {
					                distributepercent = .1,
					                distributeprefabs =
					                {
					                	magmarock = 1,
										magmarock_gold = 1,
										rock1 = 0.5,
										rock2 = 0.3,
					                    tallbirdnest = .4, --was .1
					                    spiderden = .01,
					                    blue_mushroom = .02, --was .002
					                    goldnugget = 1,
					                },
					            }
					})