require "tuning"


local function MakeVegStats(seedweight, hunger, health, perish_time, sanity, cooked_hunger, cooked_health, cooked_perish_time, cooked_sanity)
	return {
		health = health,
		hunger = hunger,
		cooked_health = cooked_health,
		cooked_hunger = cooked_hunger,
		seed_weight = seedweight,
		perishtime = perish_time,
		cooked_perishtime = cooked_perish_time,
		sanity = sanity,
		cooked_sanity = cooked_sanity

	}
end

local COMMON = 3
local UNCOMMON = 1
local RARE = .5

VEGGIES =
{
	cave_banana = MakeVegStats(0,	TUNING.CALORIES_SMALL,	TUNING.HEALING_TINY,	TUNING.PERISH_MED, 0,
									TUNING.CALORIES_SMALL,	TUNING.HEALING_SMALL,	TUNING.PERISH_FAST, 0),

	carrot = MakeVegStats(COMMON,	TUNING.CALORIES_SMALL,	TUNING.HEALING_TINY,	TUNING.PERISH_MED, 0,
									TUNING.CALORIES_SMALL,	TUNING.HEALING_SMALL,	TUNING.PERISH_FAST, 0),

	corn = MakeVegStats(COMMON, TUNING.CALORIES_MED,	TUNING.HEALING_SMALL,	TUNING.PERISH_MED, 0,
								TUNING.CALORIES_SMALL,	TUNING.HEALING_SMALL,	TUNING.PERISH_SLOW, 0),

	radish = MakeVegStats(COMMON, TUNING.CALORIES_SMALL,	TUNING.HEALING_TINY,	TUNING.PERISH_SLOW, 0,
								TUNING.CALORIES_SMALL,	TUNING.HEALING_SMALL,	TUNING.PERISH_MED, 0),


	asparagus = MakeVegStats(COMMON, TUNING.CALORIES_SMALL,	TUNING.HEALING_SMALL,	TUNING.PERISH_FAST, 0,
								TUNING.CALORIES_MED,	TUNING.HEALING_SMALL,	TUNING.PERISH_SUPERFAST, 0),


	aloe = MakeVegStats(COMMON, TUNING.CALORIES_TINY,	TUNING.HEALING_MEDSMALL,	TUNING.PERISH_FAST, 0,
								TUNING.CALORIES_SMALL,	TUNING.HEALING_SMALL,	TUNING.PERISH_SUPERFAST, 0),

	pumpkin = MakeVegStats(UNCOMMON,	TUNING.CALORIES_LARGE,	TUNING.HEALING_SMALL,	TUNING.PERISH_MED, 0,
										TUNING.CALORIES_LARGE,	TUNING.HEALING_MEDSMALL,	TUNING.PERISH_FAST, 0),

	eggplant = MakeVegStats(UNCOMMON,	TUNING.CALORIES_MED,	TUNING.HEALING_MEDSMALL,	TUNING.PERISH_MED, 0,
										TUNING.CALORIES_MED,	TUNING.HEALING_MED,		TUNING.PERISH_FAST, 0),

	durian = MakeVegStats(RARE, TUNING.CALORIES_MED,	-TUNING.HEALING_SMALL,	TUNING.PERISH_MED, -TUNING.SANITY_TINY,
								TUNING.CALORIES_MED,	0,						TUNING.PERISH_FAST, -TUNING.SANITY_TINY),

	pomegranate = MakeVegStats(RARE,	TUNING.CALORIES_TINY,	TUNING.HEALING_SMALL,		TUNING.PERISH_FAST, 0,
										TUNING.CALORIES_SMALL,	TUNING.HEALING_MED,	TUNING.PERISH_SUPERFAST, 0),

	dragonfruit = MakeVegStats(RARE,	TUNING.CALORIES_TINY,	TUNING.HEALING_SMALL,		TUNING.PERISH_FAST, 0,
										TUNING.CALORIES_SMALL,	TUNING.HEALING_MED,	TUNING.PERISH_SUPERFAST, 0),

	berries = MakeVegStats(0,	TUNING.CALORIES_TINY,	0,	TUNING.PERISH_FAST, 0,
								TUNING.CALORIES_SMALL,	TUNING.HEALING_TINY,	TUNING.PERISH_SUPERFAST, 0),

	cactus_meat = MakeVegStats(0, TUNING.CALORIES_SMALL, -TUNING.HEALING_SMALL, TUNING.PERISH_MED, -TUNING.SANITY_TINY,
								  TUNING.CALORIES_SMALL, TUNING.HEALING_TINY, TUNING.PERISH_MED, TUNING.SANITY_MED),

	watermelon = MakeVegStats(UNCOMMON, TUNING.CALORIES_SMALL, TUNING.HEALING_SMALL, TUNING.PERISH_FAST, TUNING.SANITY_TINY,
							  TUNING.CALORIES_SMALL, TUNING.HEALING_TINY, TUNING.PERISH_SUPERFAST, TUNING.SANITY_TINY*1.5),

	coffeebeans = MakeVegStats(0,	TUNING.CALORIES_TINY,	0,	TUNING.PERISH_FAST, 0,
								TUNING.CALORIES_TINY,	0,	TUNING.PERISH_SLOW, -TUNING.SANITY_TINY),

	sweet_potato = MakeVegStats(COMMON,	TUNING.CALORIES_SMALL,	TUNING.HEALING_TINY,	TUNING.PERISH_MED, 0,
									TUNING.CALORIES_SMALL,	TUNING.HEALING_SMALL,	TUNING.PERISH_FAST, 0),
}

local notags = {'NOBLOCK', 'player', 'FX'}
local function test_deploy(inst, pt)
    if not GetPlayer():HasTag("plantkin") then
        return false
    end
    local tiletype = GetGroundTypeAtPosition(pt)
    local ground_OK = tiletype ~= GROUND.ROCKY and tiletype ~= GROUND.ROAD and tiletype ~= GROUND.IMPASSABLE and tiletype ~= GROUND.INTERIOR and
                        tiletype ~= GROUND.UNDERROCK and tiletype ~= GROUND.WOODFLOOR and tiletype ~= GROUND.MAGMAFIELD and 
                        tiletype ~= GROUND.CARPET and tiletype ~= GROUND.CHECKER and 
                        tiletype ~= GROUND.ASH and tiletype ~= GROUND.VOLCANO and tiletype ~= GROUND.VOLCANO_ROCK and tiletype ~= GROUND.BRICK_GLOW and
                        tiletype ~= GROUND.FOUNDATION and tiletype ~= GROUND.COBBLEROAD and 
                        tiletype < GROUND.UNDERGROUND
    
    local ground = GetWorld()
    if ground.Map:IsWater(tiletype) then 
        ground_OK = false 
    end 
    
    if ground_OK then
        local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 4, nil, notags) -- or we could include a flag to the search?
        local min_spacing = inst.components.deployable.min_spacing or 2

        for k, v in pairs(ents) do
            if v ~= inst and v:IsValid() and v.entity:IsVisible() and not v.components.placer and v.parent == nil then
                if distsq( Vector3(v.Transform:GetWorldPosition()), pt) < min_spacing*min_spacing then
                    return false
                end
            end
        end
        
        return true

    end
    return false
end

local function ondeploy(inst, pt, deployer)
   
    local prefab = nil
    if inst.components.plantable.product and type(inst.components.plantable.product) == "function" then
        prefab = inst.components.plantable.product(inst)
    else
        prefab = inst.components.plantable.product or inst.prefab
    end

    local plant1 = SpawnPrefab("plant_normal")
--    plant1.persists = false
    
    plant1.components.crop:StartGrowing(prefab, inst.components.plantable.growtime, plant1)
    plant1.Transform:SetPosition(pt.x,0,pt.z)
    inst.SoundEmitter:PlaySound("dontstarve/common/craftable/farm_basic")
    inst:Remove()

end

local function MakeVeggie(name, has_seeds, iswater)

	local assetname = name

	local assets=
	{
		Asset("ANIM", "anim/"..assetname..".zip"),
	}
	local assets_cooked=
	{
		Asset("ANIM", "anim/"..assetname..".zip"),
	}

	local assets_seeds =
	{
		Asset("ANIM", "anim/seeds.zip"),
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
		MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.LIGHT, TUNING.WINDBLOWN_SCALE_MAX.LIGHT)
		inst.AnimState:SetBank("seeds")
		inst.AnimState:SetBuild("seeds")
		inst.AnimState:SetRayTestOnBB(true)

		inst:AddComponent("edible")
		inst.components.edible.foodtype = "SEEDS"
		inst.components.edible.foodstate = "RAW"

		inst:AddComponent("stackable")
		inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

		inst:AddTag("plant")

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

	    inst:AddComponent("deployable")
	    --inst.components.deployable.test = function() return true end
	    inst.components.deployable.ondeploy = ondeploy
	    inst.components.deployable.test = test_deploy
	    inst.components.deployable.min_spacing = 2    		
	    inst.components.deployable.onlydeploybyplantkin = true

		return inst
	end

	local function fn(Sim)
		local inst = CreateEntity()
		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		MakeInventoryPhysics(inst)

		inst.AnimState:SetBank(assetname)
		inst.AnimState:SetBuild(assetname)
		inst.AnimState:PlayAnimation("idle")

		inst:AddComponent("edible")
		inst:AddComponent("perishable")

		inst.components.edible.healthvalue = VEGGIES[name].health
		inst.components.edible.hungervalue = VEGGIES[name].hunger
		inst.components.edible.sanityvalue = VEGGIES[name].sanity or 0
		inst.components.perishable:SetPerishTime(VEGGIES[name].perishtime)
	
		inst.components.edible.foodtype = "VEGGIE"
		inst.components.edible.foodstate = "RAW"

		inst.components.perishable:StartPerishing()
		inst.components.perishable.onperishreplacement = "spoiled_food"

		inst:AddComponent("stackable")


		local is_big = name == "pumpkin" or name == "eggplant" or name == "durian" or name == "watermelon"
		if not is_big then
			inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
		end

		local is_cooler = name == "watermelon"
		if is_cooler then
			inst.components.edible.temperaturedelta = TUNING.COLD_FOOD_BONUS_TEMP
    		inst.components.edible.temperatureduration = TUNING.FOOD_TEMP_BRIEF
		end

		local is_blown_in_hurricane = name == "carrot" or name == "berries"
		if is_blown_in_hurricane then
			MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.LIGHT, TUNING.WINDBLOWN_SCALE_MAX.LIGHT)
		end

		inst:AddComponent("inspectable")
		inst:AddComponent("inventoryitem")

	    MakeSmallBurnable(inst)
		MakeSmallPropagator(inst)

		MakeInventoryFloatable(inst, "idle_water", "idle")
		---------------------

		inst:AddComponent("bait")

		------------------------------------------------
		inst:AddComponent("tradable")

		------------------------------------------------

		inst:AddComponent("cookable")
		inst.components.cookable.product = name.."_cooked"

		local is_banana = name == "cave_banana"
		if is_banana then
			--inst.components.inventoryitem:ChangeImageName("bananas")
			inst:AddComponent("named")
			inst.components.named:SetName(STRINGS.NAMES["BANANA"])
		end

		return inst
	end

	local function fn_cooked(Sim)
		local inst = CreateEntity()
		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		MakeInventoryPhysics(inst)

		inst.AnimState:SetBank(assetname)
		inst.AnimState:SetBuild(assetname)
		inst.AnimState:PlayAnimation("cooked")


		inst:AddComponent("perishable")
		inst:AddComponent("edible")

		inst.components.perishable:SetPerishTime(VEGGIES[name].cooked_perishtime)
		inst.components.edible.healthvalue = VEGGIES[name].cooked_health
		inst.components.edible.hungervalue = VEGGIES[name].cooked_hunger
		inst.components.edible.sanityvalue = VEGGIES[name].cooked_sanity or 0

		inst.components.perishable:StartPerishing()
		inst.components.perishable.onperishreplacement = "spoiled_food"

		inst.components.edible.foodtype = "VEGGIE"
		inst.components.edible.foodstate = "COOKED"

		local is_caffeinated = name == "coffeebeans"
		if is_caffeinated then
			inst.components.edible.caffeinedelta = TUNING.CAFFEINE_FOOD_BONUS_SPEED
			inst.components.edible.caffeineduration = TUNING.FOOD_SPEED_AVERAGE
		end

		inst:AddComponent("stackable")
		inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

		inst:AddComponent("inspectable")

		local is_banana = name == "cave_banana"
		if is_banana then
			inst:AddComponent("named")
			--inst.components.inventoryitem:ChangeImageName("bananas_cooked")
			inst.components.named:SetName(STRINGS.NAMES["BANANA_COOKED"])
		end

		local is_blown_in_hurricane = name == "carrot" or name == "berries"
		if is_blown_in_hurricane then
			MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.LIGHT, TUNING.WINDBLOWN_SCALE_MAX.LIGHT)
		end

		inst:AddComponent("inventoryitem")

	    MakeSmallBurnable(inst)
		MakeSmallPropagator(inst)

		MakeInventoryFloatable(inst, "cooked_water", "cooked")
		---------------------

		inst:AddComponent("bait")

		------------------------------------------------
		inst:AddComponent("tradable")

		return inst
	end

	local base
	local cooked
	base = Prefab( "common/inventory/"..name, fn, assets, prefabs)
	cooked = Prefab( "common/inventory/"..name.."_cooked", fn_cooked, assets_cooked)
	local seeds = has_seeds and Prefab( "common/inventory/"..name.."_seeds", fn_seeds, assets_seeds) or nil
	local placer = has_seeds and MakePlacer( "common/inventory/"..name.."_seeds_placer", "plant_normal", "plant_normal", "placer" ) or nil
	return base, cooked, seeds, placer
end

local prefs = {}
for veggiename,veggiedata in pairs(VEGGIES) do
	local veg, cooked, seeds, placer = MakeVeggie(veggiename, veggiename ~= "coffeebeans" and veggiename ~= "berries" and veggiename ~= "cave_banana" and veggiename ~= "cactus_meat", false)
	table.insert(prefs, veg)
	table.insert(prefs, cooked)
	if seeds then
		table.insert(prefs, seeds)
	end
	if placer then
		table.insert(prefs, placer)
	end
end


return unpack(prefs)
