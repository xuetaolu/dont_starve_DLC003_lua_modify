local function MakePreparedFood(data)

	local assets=
	{
		Asset("ANIM", "anim/cook_pot_food.zip"),
		Asset("ANIM", "anim/cook_pot_food_2.zip"),
		Asset("ANIM", "anim/cook_pot_food_yotp.zip"),

		Asset("INV_IMAGE", "asparagussoup_yotp"),
		Asset("INV_IMAGE", "dragonpie_yotp"),
		Asset("INV_IMAGE", "feijoada_yotp"),
		Asset("INV_IMAGE", "frogglebunwich_yotp"),
		Asset("INV_IMAGE", "gummy_cake_yotp"),
		Asset("INV_IMAGE", "hardshell_tacos_yotp"),
		Asset("INV_IMAGE", "honeyham_yotp"),
		Asset("INV_IMAGE", "honeynuggets_yotp"),
		Asset("INV_IMAGE", "icedtea_yotp"),
		Asset("INV_IMAGE", "meatballs_yotp"),
		Asset("INV_IMAGE", "monsterlasagna_yotp"),
		Asset("INV_IMAGE", "nettlelosange_yotp"),
		Asset("INV_IMAGE", "perogies_yotp"),
		Asset("INV_IMAGE", "pumpkincookie_yotp"),
		Asset("INV_IMAGE", "ratatouille_yotp"),
		Asset("INV_IMAGE", "snakebonesoup_yotp"),
		Asset("INV_IMAGE", "spicyvegstinger_yotp"),
		Asset("INV_IMAGE", "steamedhamsandwich_yotp"),
		Asset("INV_IMAGE", "stuffedeggplant_yotp"),
		Asset("INV_IMAGE", "tea_yotp"),
		Asset("INV_IMAGE", "turkeydinner_yotp"),
		Asset("INV_IMAGE", "waffles_yotp"),

	}
	
	local prefabs = 
	{
		"spoiled_food",
	}


	local function replacementtest(data)
		if data.spoiled_product then
			return data.spoiled_product
		end
		return "spoiled_food"
	end
	
	local function fn(Sim)
		local inst = CreateEntity()
		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		MakeInventoryPhysics(inst)
		
		inst.AnimState:SetBuild("cook_pot_food")
		inst.AnimState:AddOverrideBuild("cook_pot_food_2")

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
		inst.components.edible.temperaturebump = data.temperaturebump or 0
		inst.components.edible.antihistamine = data.antihistamine or 0

		-- Year of the pig stuff
		inst.yotp_override = data.yotp

		if data.boost_surf then
			inst.components.edible.surferdelta = TUNING.HYDRO_FOOD_BONUS_SURF
			inst.components.edible.surferduration = TUNING.FOOD_SPEED_AVERAGE		
		end
		if data.boost_dry then
			inst.components.edible.autodrydelta = TUNING.HYDRO_FOOD_BONUS_DRY
			inst.components.edible.autodryduration = TUNING.FOOD_SPEED_AVERAGE
		end
		if data.boost_cool then
			inst.components.edible.autocooldelta = TUNING.HYDRO_FOOD_BONUS_COOL_RATE
		end		

		inst:AddComponent("inspectable")
		inst.wet_prefix = data.wet_prefix

		inst:AddComponent("inventoryitem")
		
		local function setfiesta(active)
			if active then
				inst.AnimState:AddOverrideBuild("cook_pot_food_yotp")
				inst.components.inventoryitem:ChangeImageName(data.name .. "_yotp")
			else
				inst.AnimState:ClearOverrideBuild("cook_pot_food_yotp")
				inst.components.inventoryitem:ChangeImageName(data.name)
			end
		end

		if inst.yotp_override then
			inst:ListenForEvent("beginfiesta", function() setfiesta(true) end, GetWorld())
			inst:ListenForEvent("endfiesta", function() setfiesta(false) end, GetWorld())

			if GetAporkalypse() and GetAporkalypse():GetFiestaActive() then
				setfiesta(true)
			end
		end

		inst:AddComponent("stackable")
		inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM


		inst:AddComponent("perishable")
		inst.components.perishable:SetPerishTime(data.perishtime or TUNING.PERISH_SLOW)
		inst.components.perishable:StartPerishing()
		inst.components.perishable.onperishreplacement = replacementtest(data)

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

	return Prefab( "common/inventory/"..data.name, fn, assets, prefabs)
end


local prefs = {}

local foods = require("preparedfoods")
for k,v in pairs(foods) do
	table.insert(prefs, MakePreparedFood(v))
end

return unpack(prefs) 

