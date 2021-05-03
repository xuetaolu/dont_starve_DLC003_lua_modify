chestfunctions = require("scenarios/chestfunctions")

local function OnCreate(inst, scenariorunner)

	local items = 
	{
		{
			--The Quacken Beak
			item = "quackenbeak",
			chance = 1.00
		},
		{
			--Body Items
			item = {"armorruins", "armorobsidian"},
			chance = 1.00,
			initfn = function(item) if item.components.armor then item.components.armor:SetCondition(math.random(item.components.armor.maxcondition * 0.75, item.components.armor.maxcondition)) end end
		},
		{
			--Body Items
			item = "ruinshat",
			chance = 1.00,
			initfn = function(item) if item.components.armor then item.components.armor:SetCondition(math.random(item.components.armor.maxcondition * 0.75, item.components.armor.maxcondition)) end end
		},
		{
			--Weapon Items
			item = {"volcanostaff", "cane"},
			chance = 1.00,
			initfn = function(item) if item.components.finiteuses then item.components.finiteuses:SetUses(math.random(item.components.finiteuses.total * 0.75, item.components.finiteuses.total)) end end
		},
		{
			--Misc Items
			item = {"blueprint", "tunacan"},
			chance = 1.00,
		},
		{
			item = {"obsidian", "dubloon"},
			count = math.random(7, 14),
			chance = 1.00,
		},
		{
			item = {"coral", "seaweed"},
			count = math.random(7, 10),
			chance = 1.00,
		},
	}

	chestfunctions.AddChestItems(inst, items)
end

return 
{
	OnCreate = OnCreate
}