chestfunctions = require("scenarios/chestfunctions")

local function RandomDamage(item, min, max)
	if item then
		if item.components.armor then
			item.components.armor:SetCondition(math.random(min * item.components.armor.maxcondition, max * item.components.armor.maxcondition))
		end
		if item.components.finiteuses then
			item.components.finiteuses:SetUses(math.random(min * item.components.finiteuses.total, max * item.components.finiteuses.total))
			if item.components.finiteuses.current <= 0 and item.components.finiteuses.total >= 1 then
				item.components.finiteuses.current = 1
			end
		end
		if item.components.fueled then
			item.components.fueled.currentfuel = math.random(min * item.components.fueled.maxfuel, max * item.components.fueled.maxfuel)
		end
	end
end

local function OnCreate(inst, scenariorunner)

	local items = 
	{
		{
			--Body Items
			item = {"strawhat", "armorwood"},
			chance = 0.25,
			initfn = function(item) RandomDamage(item, 0.15, 0.55) end
		},
		{
			--Tool Items
			item = {"axe", "machete", "pickaxe", "shovel"},
			chance = 1.00,
			initfn = function(item) RandomDamage(item, 0.15, 0.65) end
		},
		{
			--Misc Items
			item = {"flint", "dubloon"},
			count = math.random(1, 3),
			chance = 0.5,
		},
		{
			item = {"coral", "seaweed"},
			count = math.random(3, 5),
			chance = 1.00,
		},
	}

	chestfunctions.AddChestItems(inst, items)
end

return 
{
	OnCreate = OnCreate
}