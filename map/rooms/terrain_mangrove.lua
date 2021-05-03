
AddRoom("Mangrove", {
					colour={r=0.0,g=0.0,b=.280,a=.50},
					value = GROUND.MANGROVE,
					type = "water",
					contents =  {
					                distributepercent = 0.3,
					                distributeprefabs=
					                {
					                	mangrovetree = 2,
					                	fishinhole = 1,
					                	grass_water = 2,
					           --     	ox = 0.1,
					                },
					            }
					})


AddRoom("BG_Mangrove", {
					colour={r=.8,g=.8,b=.2,a=.50},
					value = GROUND.MANGROVE,
					type = "water",
					tags = {"ExitPiece", "Packim_Fishbone"},
					contents =  {
					                distributepercent = .3,--.1,
					                distributeprefabs=
					                {
										ox = .1, 
										grass_water = 6,
										mangrovetree = 2,
										fishinhole = 0.5,
										reeds = 2,
					                },
					            }
					})
	-- Very few Trees, very few rocks, rabbit holes, some ox, some grass

	-- Rabbit holes, Ox herds if bigger
AddRoom("BareMangrove", {					colour={r=.5,g=.5,b=.45,a=.50},
					value = GROUND.MANGROVE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					type = "water",
					contents =  {
					                distributepercent = .3,--.1,
					                distributeprefabs=
					                {
					                    grass_water = .8,
					                    mangrovetree = 0.25,
					                    ox = 0.1, --was .2
					                    fishinhole = 0.01,
										reeds = .1,
					                },
					            }
					})

AddRoom("NoOxMangrove", {
					colour={r=.8,g=.4,b=.4,a=.50},
					value = GROUND.MANGROVE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					type = "water",
					contents =  {
					                distributepercent = .3,
					                distributeprefabs=
					                {
					                    grass_water = .4,
					                    fishinhole = 0.05,
					                    mangrovetree = 0.3,
					                },
					            }
					})

AddRoom("MangroveOxBoon", {
					colour={r=.8,g=.4,b=.4,a=.50},
					value = GROUND.MANGROVE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					type = "water",
					contents =  {
					                distributepercent = .3, --was .1,
					                distributeprefabs=
					                {
					                    mangrovetree = 2,
					                	fishinhole = 1,
					                	grass_water = 2,
					                	ox = .5,
					                },
					            }
					})

AddRoom("MangroveWetlands", {
					colour={r=.8,g=.4,b=.4,a=.50},
					value = GROUND.MANGROVE,
					tags = {"ExitPiece", "Packim_Fishbone"},
					type = "water",
					contents =  {
					                distributepercent = .2,
					                distributeprefabs=
					                {
					                    mangrovetree = 2,
					                	fishinhole = 2,
					                	grass_water = 2,
					                	ox = 0.75, 
										reeds = .1,
					                },
					            }
					})