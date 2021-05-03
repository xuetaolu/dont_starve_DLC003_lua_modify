

local cultivated_contnets =  {
        distributepercent = 0.06,  ---0.1
        distributeprefabs=
        {
-- 			grass = 0.05,
--			flower = 0.3,
			rock1 = 0.01,
			teatree = 0.1,
--			peekhenspawner = 0.003,
        },  
        --[[
        countstaticlayouts={
        ["farm_grass_1"]=function() 
        		return math.random(1,2)			
		   end,
		["farm_flowers_1"]=function() 
        		return math.random(0,2)			
		   end,
		["farm_flowers_2"]=function() 
        		return math.random(0,1)			
		   end
		   },
		]]
    }

AddRoom("BG_cultivated_base", {
					colour={r=1.0,g=1.0,b=1.0,a=0.3},
					value = GROUND.FIELDS,
					tags = {"ExitPiece", "Cultivated"},
					contents = cultivated_contnets
					})


AddRoom("cultivated_base_1", {
					colour={r=1.0,g=1.0,b=1.0,a=0.3},
					value = GROUND.FIELDS,
					tags = {"ExitPiece", "Cultivated", "City1"},
					contents = cultivated_contnets
					})

AddRoom("cultivated_base_2", {
					colour={r=1.0,g=1.0,b=1.0,a=0.3},
					value = GROUND.FIELDS,
					tags = {"ExitPiece", "Cultivated", "City2"},
					contents =  cultivated_contnets
					})

AddRoom("piko_land", {
					colour={r=1.0,g=0.0,b=1.0,a=0.3},
					value = GROUND.FIELDS,
					tags = {"ExitPiece", "Cultivated"},
					contents =  {
					        distributepercent = 0.06, --0.1
					        distributeprefabs=
					        {
							--	grass = 0.05,
							--	flower = 0.3,
								rock1 = 0.01,
								teatree = 2.0,
					        },
					        countprefabs = 
			                {
			                	teatree_piko_nest_patch = 1
			            	},
					    }

					})