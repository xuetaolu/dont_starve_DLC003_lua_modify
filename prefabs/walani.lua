local MakePlayerCharacter = require "prefabs/player_common"


local assets = 
{
	Asset("ANIM", "anim/walani.zip"),
	Asset("ANIM", "anim/walani_paddle.zip"),
}

local prefabs = 
{
	"surfboard_item",
}

local start_inv = 
{
	"surfboard_item",
}

local fn = function(inst)
	inst.components.health:SetMaxHealth(TUNING.WALANI_HEALTH)
	inst.components.hunger:SetMax(TUNING.WALANI_HUNGER)
	inst.components.sanity:SetMax(TUNING.WALANI_SANITY)

	inst.soundsname = "walani"
	inst.talker_path_override = "dontstarve_DLC002/characters/"

	local surfboard_recipe = Recipe("surfboard_item", {Ingredient("boards", 1), Ingredient("seashell", 2)}, RECIPETABS.NAUTICAL, TECH.NONE,  {RECIPE_GAME_TYPE.SHIPWRECKED,RECIPE_GAME_TYPE.PORKLAND})
	surfboard_recipe.sortkey = 1

	inst.components.moisture.baseDryingRate = 0.2
	inst.components.sanity:AddRateModifier("walani", TUNING.WALANI_SANITY_RATE_MODIFIER)
	inst.components.sanity.wetnessImmune = true 
	inst.components.hunger:AddBurnRateModifier("walani", TUNING.WALANI_HUNGER_RATE_MODIFIER)

end

return MakePlayerCharacter("walani", prefabs, assets, fn, start_inv)
