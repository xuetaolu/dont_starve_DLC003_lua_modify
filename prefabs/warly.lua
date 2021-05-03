
local MakePlayerCharacter = require "prefabs/player_common"


local assets = 
{
	Asset("ANIM", "anim/warly.zip"),
}

local prefabs = 
{
	"spicepack",
	"portablecookpot_item",
}

local start_inv = 
{
	"spicepack",
	"portablecookpot_item",
}
     
local guaranteed_inv = 
{
	{equipped = "portablecookpot_item",placed = "portablecookpot"}
}


local specialtyfoods =
{
	-- coffee = 
	-- {
	-- 	test = function(cooker, names, tags) return names.coffeebeans_cooked and (names.coffeebeans_cooked == 4 or (names.coffeebeans_cooked == 3 and (tags.dairy or tags.sweetener)))	end,
	-- 	priority = 30,
	-- 	foodtype = "VEGGIE",
	-- 	health = TUNING.HEALING_SMALL,
	-- 	hunger = TUNING.CALORIES_TINY,
	-- 	perishtime = TUNING.PERISH_MED,
	-- 	sanity = -TUNING.SANITY_TINY,
	-- 	caffeinedelta = TUNING.CAFFEINE_FOOD_BONUS_SPEED,
	-- 	caffeineduration = TUNING.FOOD_SPEED_LONG,
	-- 	cooktime = 0.5,
	-- },

	sweetpotatosouffle =
	{
		test = function(cooker, names, tags) return (names.sweet_potato and names.sweet_potato == 2) and tags.egg and tags.egg >= 2 end,
		priority = 30,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_MED,
		cooktime = 2,
	},

	monstertartare =
	{
		test = function(cooker, names, tags) return tags.monster and tags.monster >= 2 and tags.egg and tags.veggie end,
		priority = 30,
		foodtype = "MEAT",
		health = TUNING.HEALING_SMALL,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_SMALL,
		cooktime = 2,
	},

	freshfruitcrepes =
	{
		test = function(cooker, names, tags) return tags.fruit and tags.fruit >= 1.5 and names.butter and names.honey end,
		priority = 30,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_HUGE,
		hunger = TUNING.CALORIES_SUPERHUGE,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_MED,
		cooktime = 2,
	},

	musselbouillabaise =
	{
		test = function(cooker, names, tags) return (names.mussel and names.mussel == 2) and tags.veggie and tags.veggie >= 2 end,
		priority = 30,
		foodtype = "MEAT",
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_MED,
		cooktime = 2,
	},

}

local function MakeSpeciallyPreparedFood(data)

	local foodassets=
	{
		Asset("ANIM", "anim/cook_pot_food.zip"),
		Asset("INV_IMAGE", data.name),
	}

	local foodprefabsdeps = 
	{
		"spoiled_food",
	}
	
	local function fn(Sim)
		local inst = CreateEntity()
		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		MakeInventoryPhysics(inst)
		
		inst.AnimState:SetBuild("cook_pot_food")
		inst.AnimState:SetBank("food")
		inst.AnimState:PlayAnimation(data.name, false)
	    
	    inst:AddTag("preparedfood")

		inst:AddComponent("edible")
		inst.components.edible.healthvalue = data.health
		inst.components.edible.hungervalue = data.hunger
		inst.components.edible.foodtype = data.foodtype or "GENERIC"
		inst.components.edible.foodstate = data.foodstate or "PREPARED"
		inst.components.edible.sanityvalue = data.sanity or 0
		inst.components.edible.temperaturedelta = data.temperature or 0
		inst.components.edible.temperatureduration = data.temperatureduration or 0
		inst.components.edible.naughtyvalue = data.naughtiness or 0
		inst.components.edible.caffeinedelta = data.caffeinedelta or 0
		inst.components.edible.caffeineduration = data.caffeineduration or 0

		inst:AddComponent("inspectable")
		inst.wet_prefix = data.wet_prefix

		inst:AddComponent("inventoryitem")
		
		inst:AddComponent("stackable")
		inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM


		inst:AddComponent("perishable")
		inst.components.perishable:SetPerishTime(data.perishtime or TUNING.PERISH_SLOW)
		inst.components.perishable:StartPerishing()
		inst.components.perishable.onperishreplacement = "spoiled_food"

		if data.tags then
			for i,v in pairs(data.tags) do
				inst:AddTag(v)
			end
		end
		
	    
        MakeSmallBurnable(inst)
		MakeSmallPropagator(inst)
		MakeInventoryFloatable(inst, data.name.."_water", data.name)
		---------------------        

		inst:AddComponent("bait")
	    
		------------------------------------------------
		inst:AddComponent("tradable")
	    
		------------------------------------------------  
	    
		return inst
	end

	return Prefab( "common/inventory/"..data.name, fn, foodassets, foodprefabsdeps)
end

-- clean up foods
for k,v in pairs(specialtyfoods) do
	v.name = k
	v.weight = v.weight or 1
	v.priority = v.priority or 0
end

for k,recipe in pairs(specialtyfoods) do
	AddCookerRecipe("portablecookpot", recipe)
end

local foodprefabs = {}

for k,v in pairs(specialtyfoods) do
	table.insert(foodprefabs, MakeSpeciallyPreparedFood(v))
	table.insert(assets, Asset("INV_IMAGE", k))
end

local function refresh_consumed_foods(inst)
	local to_remove = {}
	for k,v in pairs(inst.consumed_foods) do
		if GetTime() >= v.time_of_reset then
			table.insert(to_remove, k)
		end
	end

	for k,v in pairs(to_remove) do
		inst.consumed_foods[v] = nil
	end
end

local function getmultfn(inst, food, original_value)
	local mult = 1

	if food.components.edible then
		if food.components.edible.foodstate == "PREPARED" then
			mult = TUNING.WARLY_MULT_PREPARED
		elseif food.components.edible.foodstate == "COOKED" then
			mult = TUNING.WARLY_MULT_COOKED
		elseif food.components.edible.foodstate == "DRIED" then
			mult = TUNING.WARLY_MULT_DRIED
		elseif food.components.edible.foodstate == "RAW" then
			mult = TUNING.WARLY_MULT_RAW
		end
	end

	if inst.inst.consumed_foods[food.prefab] then
		local penalty_stage = inst.inst.consumed_foods[food.prefab].count
		penalty_stage = math.clamp(penalty_stage, 1, 5)
		mult = mult * TUNING.WARLY_MULT_SAME_OLD[penalty_stage]
	end
	
	if original_value < 0 then 
		mult = 1 + (1 - mult)
	end

	return mult
end

local function oneat(inst, data)
	local food = data and data.food

	refresh_consumed_foods(inst)

	if food and food.components.edible 
	and food.components.perishable 
	and food.components.perishable:IsFresh() 
	and not food:HasTag("monstermeat") then
		local foodtype = food.components.edible.foodstate
		if specialtyfoods[food.prefab] then
			foodtype = "TASTY"
		end

		if food.prefab == "wetgoop" then
			inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_EAT", "PAINFUL"))
		else
			if inst.consumed_foods[food.prefab] then
				local penalty_stage = inst.consumed_foods[food.prefab].count
				penalty_stage = math.clamp(penalty_stage, 1, 5)
				inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_EAT", "SAME_OLD_"..penalty_stage))
			else
				inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_EAT", string.upper(foodtype)))
			end
		end
	end

	if inst.consumed_foods[food.prefab] then
		inst.consumed_foods[food.prefab].count = inst.consumed_foods[food.prefab].count + 1
		inst.consumed_foods[food.prefab].time_of_reset = GetTime() + (TUNING.WARLY_SAME_OLD_COOLDOWN)
	else
		inst.consumed_foods[food.prefab] = {count = 1, time_of_reset = GetTime() + (TUNING.WARLY_SAME_OLD_COOLDOWN)}
	end
end

local function OnSave(inst, data)
	local consumed_foods = {}
	for k,v in pairs(inst.consumed_foods) do
		consumed_foods[k] = {}
		consumed_foods[k].count = v.count
		consumed_foods[k].time_of_reset = v.time_of_reset - GetTime()
	end
	data.consumed_foods = consumed_foods
end

local function OnLoad(inst, data)
	if data and data.consumed_foods then
		inst.consumed_foods = data.consumed_foods
	end
end

local function OnLongUpdate(inst, dt)
	for k,v in pairs(inst.consumed_foods) do
		v.time_of_reset = v.time_of_reset - dt
	end
	refresh_consumed_foods(inst)
end

local fn = function(inst)
	inst.components.hunger:SetMax(TUNING.WARLY_HUNGER)

	inst.soundsname = "warly"
	inst.talker_path_override = "dontstarve_DLC002/characters/"

	local portablecookpot_recipe = Recipe("spicepack", {Ingredient("fabric", 1), Ingredient("rope", 1)}, RECIPETABS.SURVIVAL, TECH.NONE, RECIPE_GAME_TYPE.COMMON)
	portablecookpot_recipe.sortkey = 1

	inst.components.eater.getsanitymultfn = getmultfn
	inst.components.eater.gethungermultfn = getmultfn
	inst.components.eater.gethealthmultfn = getmultfn

	inst.components.hunger:AddBurnRateModifier("warly", TUNING.WARLY_HUNGER_RATE_MODIFIER)

	inst:ListenForEvent("oneatsomething", oneat)
	inst.components.inventory:GuaranteeItems(guaranteed_inv)

	inst.consumed_foods = {}

	inst.OnSave = OnSave
	inst.OnLoad = OnLoad
	inst.OnLongUpdate = OnLongUpdate
end


return MakePlayerCharacter("warly", prefabs, assets, fn, start_inv),
	unpack(foodprefabs)
