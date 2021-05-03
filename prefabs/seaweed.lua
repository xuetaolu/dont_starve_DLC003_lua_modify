local assets=
{
	Asset("ANIM", "anim/seaweed.zip"),
    Asset("ANIM", "anim/meat_rack_food.zip"),
}


local prefabs = 
{
    "seaweed_planted",
    "seaweed_cooked",
    "seaweed_dried",
}

local function ondropped(inst)
    --Get tile under my position and set animation accordingly 
    local pt = inst:GetPosition()
    local ground = GetWorld()
    local tile = GROUND.GRASS
    if ground and ground.Map then
        tile = ground.Map:GetTileAtPoint(pt.x, pt.y, pt.z)
    end

    local onWater = ground.Map:IsWater(tile)

    if onWater then 
        inst.AnimState:PlayAnimation("idle_water", true)
    else 
        inst.AnimState:PlayAnimation("idle", true)
    end 
end

local function onhitwater(inst)
    
    if inst.components.blowinwind == nil then
        return
    end

    inst.AnimState:PlayAnimation("idle_water", true)
    inst.components.blowinwind:SetMaxSpeedMult(TUNING.WINDBLOWN_SCALE_MAX.MEDIUM)
    inst.components.blowinwind:SetMinSpeedMult(TUNING.WINDBLOWN_SCALE_MIN.MEDIUM)
end

local function onhitland(inst)

    if inst.components.blowinwind == nil then
        return
    end

    inst.AnimState:PlayAnimation("idle", true)
    inst.components.blowinwind:SetMaxSpeedMult(TUNING.WINDBLOWN_SCALE_MAX.LIGHT)
    inst.components.blowinwind:SetMinSpeedMult(TUNING.WINDBLOWN_SCALE_MIN.LIGHT)
end

local function commonfn(Sim)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    inst.entity:AddSoundEmitter()
    
    inst.AnimState:SetRayTestOnBB(true);    
    inst.AnimState:SetBank("seaweed")
    inst.AnimState:SetBuild("seaweed")
    
    inst.AnimState:SetLayer( LAYER_BACKGROUND )
    inst.AnimState:SetSortOrder( 3 )

    inst:AddComponent("edible")
    inst.components.edible.foodtype = "VEGGIE"
    
    
    
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    
    inst:AddComponent("inspectable")
	inst:AddComponent("waterproofer")
    inst:AddComponent("inventoryitem")
    

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"


    --shine(inst)
    
    return inst
end

local function defaultfn(sim)

    local inst = commonfn(sim)
    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY
    inst.components.edible.sanityvalue = -TUNING.SANITY_SMALL
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    --inst.components.inventoryitem:SetOnDroppedFn(ondropped)

    inst:AddComponent("cookable")
    inst.components.cookable.product = "seaweed_cooked"

    inst:AddComponent("dryable")
    inst.components.dryable:SetProduct("seaweed_dried")
    inst.components.dryable:SetDryTime(TUNING.DRY_FAST)
    inst.AnimState:PlayAnimation("idle_water", true)

    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.MEDIUM, TUNING.WINDBLOWN_SCALE_MAX.MEDIUM)
    MakeInventoryFloatable(inst, "idle_water", "idle") -- < this replaces the symbols for the ripple, so you still need it.
    inst.components.floatable:SetOnHitWaterFn(onhitwater)
    inst.components.floatable:SetOnHitLandFn(onhitland)


    inst:AddComponent("fertilizer")
    inst.components.fertilizer.fertilizervalue = TUNING.POOP_FERTILIZE
    inst.components.fertilizer.soil_cycles = TUNING.POOP_SOILCYCLES
    inst.components.fertilizer.withered_cycles = TUNING.POOP_WITHEREDCYCLES
    inst.components.fertilizer.oceanic = true

    return inst
end 


local function cookedfn(sim)

    local inst = commonfn(sim)
    inst.components.edible.foodstate = "COOKED"
    inst.components.edible.healthvalue = TUNING.HEALING_SMALL
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY
    inst.components.edible.sanityvalue = 0--TUNING.SANITY_SMALL
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
    inst.AnimState:PlayAnimation("cooked", true)

    MakeInventoryFloatable(inst, "cooked_water", "cooked")

    return inst
end 

local function driedfn(sim)
    local inst = commonfn(sim)
    inst.components.edible.foodstate = "DRIED"
    inst.components.edible.healthvalue = TUNING.HEALING_SMALL
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.sanityvalue = 0--TUNING.SANITY_SMALL
    inst.components.perishable:SetPerishTime(TUNING.PERISH_PRESERVED)
    inst.AnimState:SetBank("meat_rack_food")
    inst.AnimState:SetBuild("meat_rack_food")
    inst.AnimState:PlayAnimation("idle_dried_seaweed", true)
    MakeInventoryFloatable(inst, "idle_dried_seaweed_water", "idle_dried_seaweed")
    
    return inst
end 

return Prefab( "common/inventory/seaweed", defaultfn, assets, prefabs), 
       Prefab( "common/inventory/seaweed_cooked", cookedfn, assets), 
       Prefab( "common/inventory/seaweed_dried", driedfn, assets)
