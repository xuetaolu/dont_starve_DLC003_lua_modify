
AddRoom("WaterAll", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.OCEAN_SHALLOW,
					contents =  {
						distributepercent = 0.009,
						distributeprefabs =
						{
							--seaweed_planted = 5,
							--mussel_farm = 5,
							--jellyfish_planted = 3,

						},

						countprefabs =
						{
				--			messagebottle = 10,
							messagebottleempty = 15
						},
					}})

AddRoom("WaterShallow", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.OCEAN_SHALLOW,
					contents =  {
						distributepercent = 0.02,
						distributeprefabs =
						{
							seaweed_planted = 3,
							mussel_farm = 4,
							lobsterhole = 1,
							ballphinhouse = .1,
							solofish = 1,
							jellyfish_spawner = 1,
							rainbowjellyfish_spawner = 0.25,
						},

						countstaticlayouts =
						{
							["AbandonedRaftBoon"] = 2,
							["WilburUnlock"] = 1,
						}
					}})

AddRoom("WaterMedium", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.OCEAN_MEDIUM,
					contents =  {
						distributepercent = 0.0090,
						distributeprefabs =
						{
							fishinhole = 4,
							jellyfish_spawner = 3,
							rainbowjellyfish_spawner = 1,
							solofish = 12,
							redbarrel = 1,
							seagullspawner = 3,
							stungray_spawner = 4,
							bioluminescence_spawner = 5,
							oceanfog = 1,
							tar_pool = 0.5,
						},
					}})

AddRoom("WaterDeep", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.OCEAN_DEEP,
					contents =  {
						distributepercent = 0.0013,
						distributeprefabs =
						{
							fishinhole = 5,
							solofish = 2,
							ballphin_spawner = 2,
							swordfish_spawner = 2,
							redbarrel = 1,
							bioluminescence_spawner = 3,
							oceanfog = 1
						},

						countprefabs =
						{
							luggagechest = 4,
							rawling = 1
						},

						prefabdata =
						{
							luggagechest = {joeluggage = true},
						},

						countstaticlayouts =
						{
							["AbandonedSailBoon"] = 2,
							["FeedingFrenzy"] = 1,
							["Volcano"] = 1
						},

						staticlayoutspawnfn =
						{
							["Volcano"] = function(x, y, ents)
								local width, height = WorldSim:GetWorldSize()
								local dist_from_edge = GetDistFromEdge(x, y, width, height)
								return 24 <= dist_from_edge and dist_from_edge <= 100 and GetDistToSpawnPoint(x, y, ents) >= 600
							end,
						}
					}})

AddRoom("WaterCoral", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.OCEAN_CORAL,
					contents =  {
		                countprefabs = {
		                    coral_brain_rock = math.random(3,5),
		                },
						distributepercent = 0.3,
						distributeprefabs =
						{
							fishinhole = .75,
							coralreef = 1,
							ballphinhouse = .1,
							seaweed_planted = .3,
							jellyfish_planted = .3,
							rainbowjellyfish_planted = 0.2,
							solofish = .3,
						},
						countstaticlayouts =
						{
							["OctopusKing"] = 1,
							["Wreck"] = 2,
						},
					}})

AddRoom("WaterMangrove", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.MANGROVE,
					contents =  {
						distributepercent = 0.3,
						distributeprefabs =
						{
							mangrovetree = 1,
							fishinhole = 1,
							grass_water = 1,
							seataro_planted = 0.5,
						},
					}})

AddRoom("WaterShipGraveyard", {
					colour={r=.5,g=0.6,b=.080,a=.10},
					value = GROUND.OCEAN_SHIPGRAVEYARD,
					contents =  {
		                countprefabs = {
		                },
						distributepercent = 0.1,
						distributeprefabs =
						{
							fishinhole = .3,
							waterygrave = .7,
							wreck = .4,
							seaweed_planted = .3,
							solofish = .03,
							shipgravefog = .3,
							--luggagechest = .01,
							swordfish_spawner = .12,
						},
						prefabdata =
						{
							wreck = {haunted = true}
						},
						prefabspawnfn =
						{
							shipgravefog = function(x, y, ents)
								return GetShortestDistToPrefab(x, y, ents, "shipgravefog") >= 16 * TILE_SCALE
							end
						},
						countstaticlayouts =
						{
							["Wreck"] = 2,
							["ShipgraveLuggage"] = math.random(4, 8)
						},
					}})
