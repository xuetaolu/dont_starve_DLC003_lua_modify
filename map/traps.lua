require("constants")
local StaticLayout = require("map/static_layout")

local Rare = {
	--["Dev Graveyard"] = StaticLayout.Get("map/static_layouts/dev_graveyard"),
}

--[[local Forest = {
	["Sleeping Spider"] = StaticLayout.Get("map/static_layouts/trap_sleepingspider"),
	["Chilled Base"] = StaticLayout.Get("map/static_layouts/trap_winter"),
}

local Deciduous = {
}

local Grasslands = {
	["Chilled Decid Base"] = StaticLayout.Get("map/static_layouts/trap_winter_deciduous"),
}

local Swamp = {
	["Rotted Base"] = StaticLayout.Get("map/static_layouts/trap_spoilfood"),
}

local Rocky = {
}

local Badlands = {
	["Hot Base"] = StaticLayout.Get("map/static_layouts/trap_summer"),
}

local Savanna = {
	["Beefalo Farm"] = StaticLayout.Get("map/static_layouts/beefalo_farm"),
}

local Any = {
	["Ice Hounds"] = StaticLayout.Get("map/static_layouts/trap_icestaff"),
	["Fire Hounds"] = StaticLayout.Get("map/static_layouts/trap_firestaff"),
}]]

local Jungle = {
	["PoisonVines"] = 
		{
			type = LAYOUT.STATIC,
			width = 8,
			height = 8,
			start_mask = PLACE_MASK.NORMAL,
			fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
			layout_position = LAYOUT_POSITION.CENTER,
			layout = {
					bush_vine =
					{
						{x=0.866,y=0.5,properties={["scenario"] = "vine_hideout"} },
						{x=0.866,y=-0.5,properties={["scenario"] = "vine_hideout"} },
						{x=0,y=-1,properties={["scenario"] = "vine_hideout"} },
						{x=-0.866,y=-0.5,properties={["scenario"] = "vine_hideout"} },
						{x=-0.866,y=0.5,properties={["scenario"] = "vine_hideout"} },
						{x=0,y=1,properties={["scenario"] = "vine_hideout"} }
					},
					item_area = {{x=0,y=0,width=0.4,height=0.4,properties={["scenario"] = "snake_ambush"} }}
				},
			areas = {
					item_area = {"venomgland", "venomgland", "venomgland"}
			},

			scale = 2
		},
}

local TidalMarsh = {
	["AirPollution"] =
		{
			type = LAYOUT.CIRCLE_EDGE,
			width = 8,
			height = 8,
			start_mask = PLACE_MASK.NORMAL,
			fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
			layout_position = LAYOUT_POSITION.CENTER,
			count = {
					poisonhole = 6,
				},
			layout = {
					item_area = {{x=0,y=0,width=0.4,height=0.4}}
				},
			areas = {
					item_area = {"spear_poison", "venomgland", "venomgland", "tentacle", "tentacle", "tentacle"}
				},

			scale = 3,
		},
}

local OceanDeep = {
	["FeedingFrenzy"] = 
		{
			type = LAYOUT.STATIC,
			water = true,
			layout = {
					cargoboat = { {x=0,y=0,properties={["scenario"] = "sharx_ambush"}} },
				},
			scale = 1,
		},
}

local AnyGround = {
	--["Airstrike"] = StaticLayout.Get("map/static_layouts/traps/airstrike"),
	["Airstrike"] =
		{
			type = LAYOUT.CIRCLE_EDGE,
			width = 8,
			height = 8,
			start_mask = PLACE_MASK.NORMAL,
			fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
			layout_position = LAYOUT_POSITION.CENTER,
			count = {
					obsidian = 6,
				},
			layout = {
					volcanostaff = { {x=0,y=0,properties={["scenario"] = "staff_erruption"} } },
				},

			scale = 2,
		},
}

local AnyWater = {
}

local SandboxModeTraps = {
	["Rare"] = Rare,
	["Shipwrecked_Any"] = AnyGround,
	[GROUND.JUNGLE] = Jungle,
	[GROUND.TIDALMARSH] = TidalMarsh,
	[GROUND.OCEAN_DEEP] = OceanDeep,
	--[GROUND.ROCKY] = Rocky,
	--[GROUND.SAVANNA] = Savanna,
	--[GROUND.GRASS] = Grasslands,
	--[GROUND.FOREST] = Forest,
	--[GROUND.MARSH] = Swamp,
	--[GROUND.DIRT] = Badlands,
}

local layouts = {}
for k,area in pairs(SandboxModeTraps) do
	if GetTableSize(area) >0 then
		for name, layout in pairs(area) do
			layouts[name] = layout
		end
	end
end

return {Sandbox = SandboxModeTraps, Layouts = layouts}
