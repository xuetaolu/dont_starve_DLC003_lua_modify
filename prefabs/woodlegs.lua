
local MakePlayerCharacter = require "prefabs/player_common"


local assets = 
{
	Asset("ANIM", "anim/woodlegs.zip"),
	Asset("ANIM", "anim/beard_woodlegs.zip"),
}

local prefabs = 
{
	"woodlegshat",
	"telescope",
	"woodlegssail",
	"woodlegs_boatcannon",
	"woodlegs_cannonshot",
}

local start_inv = 
{
	"woodlegshat",
	"telescope",
	"boatcannon",
	"boards",
	"boards",
	"boards",
	"boards",
	"dubloon",
	"dubloon",
	"dubloon",
	"dubloon",
}

local function sanityfn(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	
	local ground = GetWorld()
	local tile = GROUND.GRASS
	if ground and ground.Map then
		tile = ground.Map:GetTileAtPoint(x, y, z)
	end

	local onWater = ground.Map:IsWater(tile)

	local delta = 0
	if not onWater then
		delta = TUNING.WOODLEGS_WATER_SANITY
	end
	
	return delta
end

local function FindTreasure(inst)
	if inst.uncovered_treasure then
		return 
	end

	inst.uncovered_treasure = true

	local x,y,z = inst:GetPosition():Get()
	local treasures = TheSim:FindEntities(x, y, z, 10000, {"buriedtreasure"}, {"linktreasure"})
	if treasures and type(treasures) == "table" and #treasures > 0 then
		for i = 1, math.ceil(#treasures * 0.25) do
			treasures[i]:Reveal(treasures[i])
			treasures[i]:RevealFog(treasures[i])
		end
	end

	local bottles = TheSim:FindEntities(x, y, z, 10000, {"messagebottle"})
	if bottles and type(bottles) == "table" and #bottles > 0 then
		for i = 1, #bottles, 1 do
			if bottles[i].treasure and bottles[i].treasure:IsRevealed() then
				local x, y, z = bottles[i].Transform:GetWorldPosition()
				local bottle = SpawnPrefab("messagebottleempty")
				bottle.Transform:SetPosition(x, y, z)
				bottles[i]:Remove()
			end
		end
	end
end

local function OnSave(inst, data)
	data.uncovered_treasure = inst.uncovered_treasure
end

local function OnLoad(inst, data)
	inst.uncovered_treasure = (data and data.uncovered_treasure) or false
end

local fn = function(inst)
	inst.soundsname = "woodlegs"
	inst.talker_path_override = "dontstarve_DLC002/characters/"
	inst.footstep_path_override = "dontstarve_DLC002/movement/woodleg/"

	inst:AddTag("pirate")

	inst.components.sanity:SetMax(TUNING.WILLOW_SANITY)
	inst.components.sanity.custom_rate_fn = sanityfn

	inst.AnimState:OverrideSymbol('beard', 'beard_woodlegs', 'beard_short')

	local hat_recipe = Recipe("woodlegshat", {Ingredient("fabric", 3), Ingredient("boneshard", 4), Ingredient("dubloon", 10)}, RECIPETABS.NAUTICAL, TECH.NONE, {RECIPE_GAME_TYPE.SHIPWRECKED,RECIPE_GAME_TYPE.PORKLAND})
	local boat_recipe = Recipe("woodlegsboat", {Ingredient("boatcannon", 1), Ingredient("boards", 4), Ingredient("dubloon", 4)}, RECIPETABS.NAUTICAL, TECH.NONE, {RECIPE_GAME_TYPE.SHIPWRECKED,RECIPE_GAME_TYPE.PORKLAND}, "woodlegsboat_placer", nil, nil, nil, true, 4)
	hat_recipe.sortkey = 1
	boat_recipe.sortkey = 2
	
	inst.uncovered_treasure = false

	inst.OnLoad = OnLoad
	inst.OnSave = OnSave

	inst:DoTaskInTime(0.5, FindTreasure)

end


return MakePlayerCharacter("woodlegs", prefabs, assets, fn, start_inv)
