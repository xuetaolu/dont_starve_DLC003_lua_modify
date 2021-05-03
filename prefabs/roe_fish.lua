require "tuning"

local COMMON = 3
local UNCOMMON = 1
local RARE = .5


ROE_FISH = 
{

	tropical_fish = {
		seedweight =        COMMON,		
		sign = 				"buoy_sign_2",
	},
--[[
	fish2 = { -- Spotted Wanda
		seedweight =        COMMON,
		health =        	TUNING.HEALING_TINY,
		cooked_health = 	TUNING.HEALING_SMALL,
		hunger =        	TUNING.CALORIES_SMALL,
		cooked_hunger = 	TUNING.CALORIES_SMALL,
		perishtime =       	TUNING.PERISH_MED,
		cooked_perishtime = TUNING.PERISH_FAST,
		sanity =            0,
		cooked_sanity =     0,

		anim = 				"fish2",
		build = 			"fish2",		
		state = 			"idle",			

		cooked_anim = 		"fish_meat_small",
		cooked_build = 		"fish_meat_small",
		cooked_state = 		"cooked",
	},
]]
	fish3 = { -- purple grouper
		seedweight =        UNCOMMON,
		health =        	TUNING.HEALING_TINY,
		cooked_health = 	TUNING.HEALING_SMALL,
		hunger =        	TUNING.CALORIES_SMALL,
		cooked_hunger = 	TUNING.CALORIES_SMALL,
		perishtime =       	TUNING.PERISH_MED,
		cooked_perishtime = TUNING.PERISH_FAST,
		sanity =            0,
		cooked_sanity =     0,
		createPrefab =		true,
		sign = 				"buoy_sign_3",		

		anim = 				"fish3",
		build = 			"fish3",
		state = 			"idle",			

		cooked_anim = 		"fish3",
		cooked_build = 		"fish3",
		cooked_state = 		"cooked",

		boost_surf = 		true,
	},

	fish4 = { -- Pierrot fish
		seedweight =        UNCOMMON,
		health =        	TUNING.HEALING_TINY,
		cooked_health = 	TUNING.HEALING_SMALL,
		hunger =        	TUNING.CALORIES_SMALL,
		cooked_hunger = 	TUNING.CALORIES_SMALL,
		perishtime =       	TUNING.PERISH_MED,
		cooked_perishtime = TUNING.PERISH_FAST,
		sanity =            0,
		cooked_sanity =     0,
		createPrefab =		true,
		sign = 				"buoy_sign_4",

		anim = 				"fish4",
		build = 			"fish4",	
		state = 			"idle",		

		cooked_anim = 		"fish4",
		cooked_build = 		"fish4",
		cooked_state = 		"cooked",

		boost_dry = 		true,

	},
	
	fish5 = { -- Neon Quattro
		seedweight =        UNCOMMON,
		health =        	TUNING.HEALING_TINY,
		cooked_health = 	TUNING.HEALING_SMALL,
		hunger =        	TUNING.CALORIES_SMALL,
		cooked_hunger = 	TUNING.CALORIES_SMALL,
		perishtime =       	TUNING.PERISH_MED,
		cooked_perishtime = TUNING.PERISH_FAST,
		sanity =            0,
		cooked_sanity =     0,
		createPrefab =		true,
		sign = 				"buoy_sign_5",

		anim = 				"fish5",
		build = 			"fish5",		
		state = 			"idle",			

		cooked_anim = 		"fish5",
		cooked_build = 		"fish5",
		cooked_state = 		"cooked",

		boost_cool = 		true,
	}	
}


local function MakeFish(name, has_seeds)

	local assets=
	{
		Asset("ANIM", "anim/"..name..".zip"),
	}
	local assets_cooked=
	{
		Asset("ANIM", "anim/"..name..".zip"),
	}
	
	local assets_seeds =
	{
		Asset("ANIM", "anim/roe.zip"),
	}

	local prefabs =
	{
		name.."_cooked",
		"spoiled_food",
	}    
	
	
	if has_seeds then
		table.insert(prefabs, name.."_seeds")
	end

	local function fn_seeds()
		local inst = CreateEntity()
		inst.entity:AddTransform()
		inst.entity:AddAnimState()
	    
		MakeInventoryPhysics(inst)
		inst.AnimState:SetBank("seeds")
		inst.AnimState:SetBuild("seeds")
		inst.AnimState:SetRayTestOnBB(true)
	    
		inst:AddComponent("edible")
		inst.components.edible.foodtype = "SEEDS"

		inst:AddComponent("stackable")
		inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

		
		inst:AddComponent("tradable")
		inst:AddComponent("inspectable")
		inst:AddComponent("inventoryitem")
	    
		inst.AnimState:PlayAnimation("idle")
		inst.components.edible.healthvalue = TUNING.HEALING_TINY/2
		inst.components.edible.hungervalue = TUNING.CALORIES_TINY

		inst:AddComponent("perishable")
		inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERSLOW)
		inst.components.perishable:StartPerishing()
		inst.components.perishable.onperishreplacement = "spoiled_food"
		
	    
		inst:AddComponent("cookable")
		inst.components.cookable.product = "seeds_cooked"
	    
		inst:AddComponent("bait")
		inst:AddComponent("plantable")
		inst.components.plantable.growtime = TUNING.SEEDS_GROW_TIME
		inst.components.plantable.product = name
	    
		return inst
	end



	local function fn(Sim)
		local inst = CreateEntity()
		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		MakeInventoryPhysics(inst)
		
		inst.AnimState:SetBank(name)
		inst.AnimState:SetBuild(name)
		inst.AnimState:PlayAnimation("idle")

	   -- inst.build = rodbuild --This is used within SGwilson, sent from an event in fishingrod.lua
        
        inst:AddTag("meat")
		inst:AddTag("fishmeat")
        inst:AddTag("catfood")
        inst:AddTag("packimfood")       

		MakeInventoryFloatable(inst, "idle_water", "idle")	    

		inst:AddComponent("edible")
		inst.components.edible.healthvalue = ROE_FISH[name].health
		inst.components.edible.hungervalue = ROE_FISH[name].hunger
		inst.components.edible.sanityvalue = ROE_FISH[name].sanity or 0	
		inst.components.edible.ismeat = true	
		inst.components.edible.foodtype = "MEAT"

		if ROE_FISH[name].boost_surf then
			inst.components.edible.surferdelta = TUNING.HYDRO_FOOD_BONUS_SURF
			inst.components.edible.surferduration = TUNING.FOOD_SPEED_AVERAGE
		end

		if ROE_FISH[name].boost_dry then
			inst.components.edible.autodrydelta = TUNING.HYDRO_FOOD_BONUS_DRY
			inst.components.edible.autodryduration = TUNING.FOOD_SPEED_AVERAGE
		end
		
		if ROE_FISH[name].boost_cool then
			inst.components.edible.autocooldelta = TUNING.HYDRO_FOOD_BONUS_COOL_RATE
		end		

		inst:AddComponent("perishable")
		inst.components.perishable:SetPerishTime(ROE_FISH[name].perishtime)
		inst.components.perishable:StartPerishing()
		inst.components.perishable.onperishreplacement = "spoiled_food"
		
		inst:AddComponent("stackable")

		inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

		inst:AddComponent("inspectable")
		inst:AddComponent("inventoryitem")

		---------------------        

		inst:AddComponent("bait")
	    
		------------------------------------------------
		inst:AddComponent("tradable")
	    
		------------------------------------------------  
	    
		inst:AddComponent("cookable")
		inst.components.cookable.product = name.."_cooked"

		return inst
	end
	
	local function fn_cooked(Sim)
		local inst = CreateEntity()
		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		MakeInventoryPhysics(inst)
		
		inst.AnimState:SetBank(ROE_FISH[name].cooked_anim)
		inst.AnimState:SetBuild(ROE_FISH[name].cooked_build)
		inst.AnimState:PlayAnimation(ROE_FISH[name].cooked_state)

		MakeInventoryFloatable(inst, "cooked_water", "cooked")	    

		inst:AddTag("meat")
		inst:AddTag("fishmeat")
		inst:AddTag("catfood")
		inst:AddTag("packimfood")

		inst:AddComponent("edible")
		inst.components.edible.ismeat = true
		inst.components.edible.foodtype = "MEAT"
		inst.components.edible.foodstate = "COOKED"		
		inst.components.edible.healthvalue = ROE_FISH[name].cooked_health
		inst.components.edible.hungervalue = ROE_FISH[name].cooked_hunger
		inst.components.edible.sanityvalue = ROE_FISH[name].cooked_sanity or 0
		
		if ROE_FISH[name].boost_surf then
			inst.components.edible.surferdelta = TUNING.HYDRO_FOOD_BONUS_SURF
			inst.components.edible.surferduration = TUNING.FOOD_SPEED_AVERAGE
		end

		if ROE_FISH[name].boost_dry then
			inst.components.edible.autodrydelta = TUNING.HYDRO_FOOD_BONUS_DRY
			inst.components.edible.autodryduration = TUNING.FOOD_SPEED_AVERAGE
		end
		
		if ROE_FISH[name].boost_cool then
			inst.components.edible.autocooldelta = TUNING.HYDRO_FOOD_BONUS_COOL_RATE
		end	

		inst:AddComponent("stackable")
		inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

		inst:AddComponent("perishable")
		inst.components.perishable:SetPerishTime(ROE_FISH[name].cooked_perishtime)
		inst.components.perishable:StartPerishing()
		inst.components.perishable.onperishreplacement = "spoiled_food"
	    		
		inst:AddComponent("inspectable")
		inst:AddComponent("inventoryitem")
		--inst.components.inventoryitem:ChangeImageName("fishtropical_cooked")
		
		inst:AddComponent("tradable")
		inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
    	inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD		---------------------        

		inst:AddComponent("bait")
	    
		return inst
	end
	local base = Prefab( "common/inventory/"..name, fn, assets, prefabs)
	
	local cooked = Prefab( "common/inventory/"..name.."_cooked", fn_cooked, assets_cooked)
	local seeds = has_seeds and Prefab( "common/inventory/"..name.."_seeds", fn_seeds, assets_seeds) or nil
	return base, cooked, seeds  
end


local prefs = {}
for fishname,fishdata in pairs(ROE_FISH) do 
	if fishdata.createPrefab then 	
		local fish, cooked, seeds = MakeFish(fishname, fishname ~= "fish2" and fishname ~= "fish3" and fishname ~= "fish4" and fishname ~= "fish5")
		table.insert(prefs, fish)
		table.insert(prefs, cooked)
		if seeds then
		--	table.insert(prefs, seeds)
		end
	end
end

return unpack(prefs) 
