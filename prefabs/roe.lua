require "prefabs/roe_fish"
local assets=
{
	Asset("ANIM", "anim/roe.zip"),
}

local prefabs =
{

}    

for k,v in pairs(ROE_FISH) do
    if v.createPrefab then
	   table.insert(prefabs, k)
    end
end

local function pickproduct(inst)
	
	local total_w = 0

	for k,v in pairs(ROE_FISH) do
		total_w = total_w + (v.seedweight or 1)
	end

	local rnd = math.random()*total_w
	for k,v in pairs(ROE_FISH) do        
		rnd = rnd - (v.seedweight or 1)
        if rnd <= 0 then
            return k
        end                
	end
	
	return "tropical_fish"
end


local function common()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    MakeInventoryPhysics(inst)
    

    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.LIGHT, TUNING.WINDBLOWN_SCALE_MAX.LIGHT)
    
    inst.AnimState:SetBank("roe")
    inst.AnimState:SetBuild("roe")
    inst.AnimState:SetRayTestOnBB(true)
    
    inst:AddComponent("edible")
    inst.components.edible.foodtype = "MEAT"
    inst:AddTag("spawnnosharx")

    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("tradable")

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"
    
    return inst
end

local function raw()
    local inst = common()
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("roe")
    MakeInventoryFloatable(inst, "idle_water", "idle")

    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY/2
    
    inst:AddComponent("cookable")
    inst.components.cookable.product = "roe_cooked"

	inst:AddComponent("bait")
    inst:AddComponent("seedable")

    inst.components.seedable.growtime = TUNING.SEEDS_GROW_TIME
    inst.components.seedable.product = pickproduct
    
    return inst
end

local function cooked()
    local inst = common()
    inst.AnimState:PlayAnimation("cooked")

    MakeInventoryFloatable(inst, "cooked_water", "cooked")
    inst.components.edible.healthvalue = 0
    inst.components.edible.foodstate = "COOKED"
    	
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY/2
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
    
    return inst
end

return Prefab( "shipwrecked/roe", raw, assets, prefabs),
       Prefab( "shipwrecked/roe_cooked", cooked, assets, prefabs)              
