require("constants")
local StaticLayout = require("map/static_layout")

local function PickSomeWithProbs(items)
	local picked = {}
	for prefab, prob in pairs(items) do
		if prob >= 1.0 or math.random() < prob then
			table.insert(picked, prefab)
		end
	end
	return picked
end

local Any = {
------------------------------------------------------------------------------------------------------
--			Level 0
------------------------------------------------------------------------------------------------------

	["WoodBoon"] = StaticLayout.Get("map/static_layouts/small_boon", {
			areas = {
				item_area = function() return PickSome(1, {"shovel","axe"}) end,							
				resource_area = function() return PickSomeWithDups(math.random(3,5), {"log"}) end,
				},
		}),
	["RockBoon"] = StaticLayout.Get("map/static_layouts/small_boon", {
			areas = {
				item_area = function() return PickSome(1, {"pickaxe","pickaxe","pickaxe","pickaxe","pickaxe","pickaxe","rock1", "rock2","gunpowder"}) end,							
				resource_area = function() return PickSomeWithDups(math.random(3,5), {"rocks","rocks","rocks","rocks","flint"}) end,
				},
		}),
	["GrassBoon"] = StaticLayout.Get("map/static_layouts/small_boon", {
			areas = {
				item_area = function() return PickSome(1, {"torch", "trap"}) end,							
				resource_area = function() return PickSomeWithDups(math.random(3,5), {"grass"}) end,
				},
		}),
	["TwigsBoon"] = StaticLayout.Get("map/static_layouts/small_boon", {
			areas = {
				item_area = function() return  nil end,							
				resource_area = function() return PickSomeWithDups(math.random(3,5), {"twigs"}) end,
				},
		}),

------------------------------------------------------------------------------------------------------
--			Level 2
------------------------------------------------------------------------------------------------------

	["Level2WoodBoon"] = StaticLayout.Get("map/static_layouts/small_boon", {
			areas = {
				item_area = function() return PickSome(1, {"armorwood","axe"}) end,							
				resource_area = function() return PickSomeWithDups(math.random(3,5), {"boards"}) end,
				},
		}),
	["Level2RockBoon"] = StaticLayout.Get("map/static_layouts/small_boon", {
			areas = {
				item_area = function() return PickSome(1, {"pickaxe","pickaxe","pickaxe","pickaxe","pickaxe","pickaxe","rock1", "rock2","gunpowder"}) end,							
				resource_area = function() return PickSomeWithDups(math.random(3,5), {"cutstone"}) end,
				},
		}),
	["Level2GrassBoon"] = StaticLayout.Get("map/static_layouts/small_boon", {
			areas = {
				item_area = function() return PickSome(1, {"torch", "trap"}) end,							
				resource_area = function() return PickSomeWithDups(math.random(3,5), {"rope"}) end,
				},
		}),
	--[[["Level2TwigsBoon"] = StaticLayout.Get("map/static_layouts/small_boon", {
			areas = {
				item_area = function() return PickSome(1, {"armorgrass"}) end,							
				resource_area = function() return PickSomeWithDups(math.random(3,5), {"twigs"}) end,
				},
		}),]]
	--[[["MiscBoon"] = StaticLayout.Get("map/static_layouts/small_boon", {
			areas = {
				item_area = function() return PickSome(1, {"winterhat","tophat","bushhat","featherhat", "trunkvest_winter","trunkvest_summer", 
															"cane","sweatervest"}) end,							
				resource_area = function() return nil end,
				},
		}),]]
	["WeaponBoon"] = StaticLayout.Get("map/static_layouts/small_boon", {
			areas = {
				item_area = function() return PickSome(1, {"blowdart_sleep","blowdart_fire","blowdart_pipe","boomerang"}) end,							
				resource_area = function() return nil end,
				},
		}),
}

local Rare = {
------------------------------------------------------------------------------------------------------
--			Level 4
------------------------------------------------------------------------------------------------------

	--[[["Level4Boon"] = StaticLayout.Get("map/static_layouts/small_boon", {
			areas = {
				item_area = function() return PickSome(1, {"firestaff","icestaff", "armormarble","panflute","cane","hambat","nightsword","onemanband"}) end,							
				resource_area = function() return nil end,
				},
		}),]]
}


local Shipwrecked_Any = {
	--Shipwrecked
	["SeaFarerBoon"] = StaticLayout.Get("map/static_layouts/small_boon", {
			areas = {
				item_area = function() return PickSomeWithProbs({telescope=0.5,armor_lifejacket=1.0,captainhat=0.48}) end,
				resource_area = {} --function() return PickSomeWithDups(3, {"seaweed_planted"}) end,
				},
		}),

	["JungleHackerBoon"] = StaticLayout.Get("map/static_layouts/small_boon", {
			areas = {
				item_area = function() return PickSomeWithProbs({machete=0.4}) end,
				resource_area = {"bamboo", "bamboo", "bamboo", "vine", "vine", "snakeskin"},
				},
		}),

	["DrunkenPirateBoon"] = StaticLayout.Get("map/static_layouts/small_boon", {
			areas = {
				item_area = {"piratehat"},
				resource_area = function() return PickSomeWithDups(5, {"messagebottleempty"}) end,
				},
		}),
}


local Water = {
	["AbandonedRaftBoon"] = StaticLayout.Get("map/static_layouts/water_boon", {
			water = true,
			areas = {
				item_area = {"raft"},
				resource_area = {"spear_launcher"},
			}
		}),

	["AbandonedSailBoon"] = StaticLayout.Get("map/static_layouts/water_boon", {
			water = true,
			areas = {
				item_area = {"rowboat"},
				resource_area = function() return nil end,
				},
			initfn = function(layout)
				for i = 1, #layout.item_area, 1 do
					layout.item_area[i].properties.scenario = "derelict_sailboat"
				end
			end
		}),
}

local Boons = {
	["Any"] = Any,
	["Shipwrecked_Any"] = Shipwrecked_Any,
	["Rare"] = Rare,
	["Water"] = Water,

}

local layouts = {}
for k,area in pairs(Boons) do
	if GetTableSize(area) >0 then
		for name, layout in pairs(area) do
			layouts[name] = layout
		end
	end
end

return {Sandbox = Boons, Layouts = layouts}
