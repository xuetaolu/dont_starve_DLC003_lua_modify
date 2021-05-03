local chestfunctions = require("scenarios/chestfunctions")

local items = 
{
	{
		item = "trinket_15",
	},
	{
		item = "snakeskinhat",
	},
	{
		item = "sewing_kit",
	},
	{
		item = "armor_lifejacket",
	},
}

local function OnCreate(inst, scenariorunner)
	chestfunctions.AddChestItems(inst, items)
end

local function OnDestroy(inst)
    chestfunctions.OnDestroy(inst)
end

return 
{
	OnCreate = OnCreate,
	OnDestroy = OnDestroy
}
