local chestfunctions = require("scenarios/chestfunctions")

local items = 
{
	{
		item = "reflectivevest",
		initfn = function(inst)
			if inst.components.fueled then
				inst.components.fueled:SetPercent(GetRandomWithVariance(0.45, 0.1))
			end
		end
	},
	{
		item = "double_umbrellahat",
		initfn = function(inst)
			if inst.components.fueled then
				inst.components.fueled:SetPercent(GetRandomWithVariance(0.56, 0.1))
			end
		end
	},
	{
		item = "coconade",
		count = 2
	},
	{
		item = "trinket_14",
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
