
AddRoom("Graveyard", {
					colour={r=.010,g=.010,b=.10,a=.50},
					value = GROUND.FOREST,
					tags = {"Town"},
					contents =  {
					                countprefabs= {
					                    evergreen = 3,
                                        goldnugget = function() return math.random(5) end,
					                    gravestone = function () return 4 + math.random(4) end,
					                    mound = function () return 4 + math.random(4) end
					                }
					            }
					})


-- AddRoom("Graveyard", {
-- 					colour={r=.010,g=.010,b=.10,a=.50},
-- 					value = GROUND.JUNGLE,
-- 					tags = {"Town"},
-- 					contents =  {
-- 									distributepercent = .3,
-- 					                distributeprefabs=
-- 					                {
--                                         grass = .1, --down from 3
--                                         sapling = .1, --lowered from 15
--                                         flower_evil = 0.05,
--                                         rocks = .03,
--                                         beehive = .0003,
--                                         flint = .02,
-- 					                },

-- 					                countprefabs= {
-- 					                    jungletree = 3,
--                                         goldnugget = function() return math.random(5) end,
-- 					                    gravestone = function () return 4 + math.random(4) end,
-- 					                    mound = function () return 4 + math.random(4) end
-- 					                }
-- 					            }
-- 					})
