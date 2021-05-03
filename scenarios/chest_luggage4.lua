local chestfunctions = require("scenarios/chestfunctions")

local items = 
{
	{
		item = "goldnugget",
		count = 2
	},
	{
		item = "bedroll_straw",
	},
	{
		item = "bandage",
	},
	{
		item = "captainhat",
	},
	{
		item = "palmleaf_umbrella",
	},
	{
		item = "trinket_19",
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
