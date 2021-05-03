
local meadow_fairy_rings =
{
	["MushroomRingLarge"] = function() if math.random(1, 1000) > 985 then return 1 end return 0 end,
	["MushroomRingMedium"] = function() if math.random(1, 1000) > 985 then return 1 end return 0 end,
	["MushroomRingSmall"] = function() if math.random(1, 1000) > 985 then return 1 end return 0 end
}

AddRoom("NoOxMeadow", {
					colour={r=.8,g=.4,b=.4,a=.50},
					value = GROUND.MEADOW,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts = meadow_fairy_rings,
					                distributepercent = .4,--.1, --lowered from .2
					                distributeprefabs=
					                {
					                    flint = 0.01,
					                    grass = .4,
					                    -- ox = 0.05,
					                    sweet_potato_planted = 0.05,
					                    beehive = 0.003,
					                    rocks = 0.003,
					                    rock_flintless = 0.01, 
					                    flower = .25,
					                },
					            }
					})

AddRoom("MeadowOxBoon", {
					colour={r=.8,g=.4,b=.4,a=.50},
					value = GROUND.MEADOW,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts = meadow_fairy_rings,
					                distributepercent = .4, --was .1,
					                distributeprefabs=
					                {
					                    ox = .5, --was 1,
					                    grass = 1,
					                    flower = .5,
					                    beehive = 0.1,
					                },
					            }
					})

AddRoom("MeadowFlowery", {
					colour={r=.8,g=.4,b=.4,a=.50},
					value = GROUND.MEADOW,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts = meadow_fairy_rings,
					                distributepercent = .5,--.1, --lowered from .2
					                distributeprefabs=
					                {
					                    flower = .5,
					                    beehive = .05,  --was .4
					                    grass = .4,
					                    rocks = .05,
					                    mandrake = 0.005, 
					                },
					            }
					})

AddRoom("MeadowBees", {
					colour={r=.8,g=.4,b=.4,a=.50},
					value = GROUND.MEADOW,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts = meadow_fairy_rings,
					                distributepercent = .4,--.1, --lowered from .2
					                distributeprefabs=
					                {
					                    flint = 0.05, --was .01
					                    grass = 3, --was .4,
					                    --ox = 3,
					                    sweet_potato_planted = 0.1, --was .05,
					                    rock_flintless = 0.01,
					                    flower = 0.15,
					                    beehive = 0.5, -- lowered from 1
					                },
					            }
					})

AddRoom("MeadowCarroty", {
					colour={r=.8,g=.4,b=.4,a=.50},
					value = GROUND.MEADOW,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
									countstaticlayouts = meadow_fairy_rings,
					                distributepercent = .35, --was .1
					                distributeprefabs=
					                { 
					                    sweet_potato_planted = 1, 
					                    grass = 1.5,
					                    rocks = .2,
					                    flower = .5,
					                },
					            }
					})

--[[AddRoom("MeadowWetlands", {
					colour={r=.8,g=.4,b=.4,a=.50},
					value = GROUND.MEADOW,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = .2,
					                distributeprefabs=
					                {
					                    --pond = 1,
					                    pond_mos = .8,
					                    grass = .5,
					                    flower = .3,
					                    sapling = .2,
					                    sweet_potato_planted = .1,  
					                },
					            }
					})
]]
AddRoom("MeadowSappy", {
					colour={r=.8,g=.4,b=.4,a=.50},
					value = GROUND.MEADOW,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = .3,
					                distributeprefabs=
					                {
					                    grass = 3,
					                    --sapling = 1,
					                    flower = .5,
					                    beehive = .1, --was 1,
					                    sweet_potato_planted = 0.3,
					                    wasphive = 0.01, --was 0.001
					                },    
					            }
					})

AddRoom("MeadowSpider", {
					colour={r=.8,g=.4,b=.4,a=.50},
					value = GROUND.MEADOW,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = .4, --was .2
					                distributeprefabs =
					                {
					                    spiderden = .5,
					                    grass = 1,
					                    --sapling = .8,
					                    ox = .5,
					                    flower = .5,
					                },
					            }
					})

AddRoom("MeadowRocky", {
					colour={r=.8,g=.4,b=.4,a=.50},
					value = GROUND.MEADOW,
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {

					                distributepercent = .4, --was .1,
					                distributeprefabs =
					                {
					                    rock_flintless = 1,
					                    rocks = 1,
					                    rock1 = 1,
					                    rock2 = 1,
					                    grass = 4, --was 2
					                    flower = 1,
					                },
					            }
					})

AddRoom("MeadowMandrake", {
					colour={r=.8,g=.4,b=.4,a=.50},
					value = GROUND.MEADOW,
					contents =  {
					                distributepercent = .3,
					                distributeprefabs=
					                {
					                    grass = .8,
					                    --sapling = .8,
					                    sweet_potato_planted = 0.05,
					                    rocks = 0.003,
					                    rock_flintless = 0.01, 
					                    flower = .25,
					                },
					                countprefabs =
					                {
					                	mandrake = math.random(1, 3)
					            	}
					            }
					})