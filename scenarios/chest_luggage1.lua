local chestfunctions = require("scenarios/chestfunctions")

local items = 
{
	{
		item = "hawaiianshirt",
		initfn = function(inst)
			if inst.components.fueled then
				inst.components.fueled:SetPercent(GetRandomWithVariance(0.78, 0.1))
			end
		end
	},
	{
		item = "umbrella",
		initfn = function(inst)
			if inst.components.fueled then
				inst.components.fueled:SetPercent(GetRandomWithVariance(0.35, 0.1))
			end
		end
	},
	{
		item = "coconut",
		count = 2
	},
	{
		item = "trinket_13",
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
