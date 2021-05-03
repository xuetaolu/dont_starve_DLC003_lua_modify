require "prefabs/veggies"
local assets=
{
	Asset("ANIM", "anim/seeds.zip"),
    Asset("ANIM", "anim/plant_normal.zip"),
}

local prefabs =
{
    "seeds_cooked",
    "spoiled_food",
}    

for k,v in pairs(VEGGIES) do
	table.insert(prefabs, k)
end

local function pickproduct(inst)
	
	local total_w = 0
	for k,v in pairs(VEGGIES) do
		total_w = total_w + (v.seed_weight or 1)
	end
	
	local rnd = math.random()*total_w
	for k,v in pairs(VEGGIES) do
		rnd = rnd - (v.seed_weight or 1)
		if rnd <= 0 then
			return k
		end
	end
	
	return "carrot"
end

local function common()
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

    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("tradable")

    inst:AddComponent("inspectable")

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    
    inst:AddComponent("inventoryitem")
    
	inst:AddComponent("perishable")

	inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERSLOW)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"
    
    return inst
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

local function raw()
    local inst = common()
    inst.AnimState:PlayAnimation("idle")
    inst.entity:AddSoundEmitter()

    MakeInventoryFloatable(inst, "idle_water", "idle")

    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY/2

    inst:AddComponent("cookable")
    inst.components.cookable.product = "seeds_cooked"

	inst:AddComponent("bait")
    inst:AddComponent("plantable")
    inst.components.plantable.growtime = TUNING.SEEDS_GROW_TIME
    inst.components.plantable.product = pickproduct 

    inst:AddTag("plant")
    inst:AddComponent("deployable")
    inst.components.deployable.userrequiredtags = {"plantkin"}
    inst.components.deployable.ondeploy = ondeploy
    inst.components.deployable.test = test_deploy
    inst.components.deployable.min_spacing = 2    
    inst.components.deployable.onlydeploybyplantkin = true


    return inst
end

local function cooked()
    local inst = common()
    inst.AnimState:PlayAnimation("cooked")

    MakeInventoryFloatable(inst, "idle_cooked_water", "cooked")

    inst.components.edible.foodstate = "COOKED"
	inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY/2
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)

    return inst
end

return Prefab( "common/inventory/seeds", raw, assets, prefabs),
       Prefab("common/inventory/seeds_cooked", cooked, assets),
       MakePlacer( "common/seeds_placer", "plant_normal", "plant_normal", "placer" )
