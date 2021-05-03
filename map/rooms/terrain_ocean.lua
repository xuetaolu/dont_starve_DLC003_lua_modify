
AddRoom("OceanShallow", {
					colour={r=0.0,g=0.0,b=.280,a=.50},
					value = GROUND.OCEAN_SHALLOW,
					type = "water",
					contents =  {
					                distributepercent = 0.005,
					                distributeprefabs =
					                {
					                	--tar_pool = 1,
					                },
					            }
					})

AddRoom("OceanShallowSeaweedBed", {
					colour={r=0.0,g=0.0,b=.280,a=.50},
					value = GROUND.OCEAN_SHALLOW,
					type = "water",
					contents =  {
					                distributepercent = 0.075,
					                distributeprefabs =
					                {
					                	seaweed_planted = 0.5,
					                	mussel_farm = 0.5,
					                	--tar_pool = 0.0025,
					                },
					            }
					})

AddRoom("OceanShallowReef", {
					colour={r=0.0,g=0.0,b=.280,a=.50},
					value = GROUND.OCEAN_SHALLOW,
					type = "water",
					contents =  {
					                distributepercent = 0.05, --was 0.1
					                distributeprefabs =
					                {
					                	coralreef = 1,
					                	--tar_pool = 0.0025,
					                },
					            }
					})

AddRoom("OceanMedium", {
					colour={r=0.0,g=0.0,b=.180,a=.30},
					value = GROUND.OCEAN_MEDIUM,
					type = "water",
					contents =  {
					                distributepercent = 0.0005,
					                distributeprefabs =
					                {
					                	redbarrel = 1,
					                },
					                
					            }
					})

AddRoom("OceanMediumSeaweedBed", {
					colour={r=0.0,g=0.0,b=.180,a=.30},
					value = GROUND.OCEAN_MEDIUM,
					type = "water",
					contents =  {
					                distributepercent = 0.05,
					                distributeprefabs =
					                {
					                	seaweed_planted = 1,
					               -- 	tar_pool = 0.0025,
					                },

					                --[[countprefab =
					                {
					                	oceanspawner_seaweed = 1
					            	},

					            	prefabdata =
					            	{
					            		oceanspawner_seaweed =
					            		{
					            			range = 10,
					            			density = math.random(8, 24),
					            			basetime = math.random(2, 4) * TUNING.SEG_TIME,
					            			randtime = TUNING.SEG_TIME,
					            		}
					            	}]]
					            }
					})

AddRoom("OceanMediumShoal", {
					colour={r=0.0,g=0.0,b=.180,a=.30},
					value = GROUND.OCEAN_MEDIUM,
					type = "water",
					contents =  {
					                distributepercent = 0.025,
					                distributeprefabs =
					                {
					                	fishinhole = 1,
					                	seaweed_planted = .5,
					                --	tar_pool = 0.0025,
					                },
					            }
					})

AddRoom("OceanDeep", {
					colour={r=0.0,g=0.0,b=.080,a=.10},
					value = GROUND.OCEAN_DEEP,
					type = "water",
					contents =  {
					                distributepercent = 0.0005,
					                distributeprefabs =
					                {
					                	redbarrel = 1,
					                },
					            }
					})

AddRoom("OceanCoral", {
					colour={r=0.0,g=0.0,b=.280,a=.50},
					value = GROUND.OCEAN_CORAL,
					type = "water",
					contents =  {
					                distributepercent = 0.05,
					                distributeprefabs =
					                {
					                	coralreef = .1,
					                	fishinhole = 1,
					                	seaweed_planted = 10,
					                	solofish = 1,
					                },
					            }
					})