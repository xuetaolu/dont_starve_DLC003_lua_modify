require "prefabs/veggies"
local assets =
{
    jellybug = { Asset("ANIM", "anim/jellybug.zip"), },
    slugbug = { Asset("ANIM", "anim/slugbug.zip"), },

    jellybug_cooked = { Asset("ANIM", "anim/jellybug_cooked.zip"), },
    slugbug_cooked = { Asset("ANIM", "anim/slugbug_cooked.zip"), },
}

local prefabs =
{
    jellybug =
    {
        "jellybug_cooked",
        "spoiled_food",
    },

    slugbug =
    {
        "slugbug_cooked",
        "spoiled_food",
    }
}

local function common(bank, build, foodtype)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    MakeInventoryPhysics(inst)
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.LIGHT, TUNING.WINDBLOWN_SCALE_MAX.LIGHT)
    
    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:SetRayTestOnBB(true)
    
    inst:AddComponent("edible")
    inst.components.edible.foodtype = foodtype

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

    inst:AddTag("monstermeat")

    return inst
end

local function jellybug_raw()
    local inst = common("jellybug", "jellybug", "VEGGIE")
    inst.AnimState:PlayAnimation("idle", true)

    MakeInventoryFloatable(inst, "idle_water", "idle")

    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY
    inst.components.edible.sanityvalue = -TUNING.SANITY_SMALL

    inst:AddComponent("bait")

    inst:AddTag("frogbait")        
    
    inst:AddComponent("cookable")
    inst.components.cookable.product = "jellybug_cooked"

	inst:AddComponent("bait")

    return inst
end

local function jellybug_cooked()
    local inst = common("jellybug_cooked", "jellybug_cooked", "VEGGIE")
    inst.AnimState:PlayAnimation("cooked", true)

    MakeInventoryFloatable(inst, "idle_cooked_water", "cooked")

    inst.components.edible.foodstate = "COOKED"
	inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.sanityvalue = -TUNING.SANITY_TINY
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)

    return inst
end

local function slugbug_raw()
    local inst = common("slugbug", "slugbug", "MEAT")
    inst.AnimState:PlayAnimation("idle", true)

    MakeInventoryFloatable(inst, "idle_water", "idle")

    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY
    inst.components.edible.sanityvalue = -TUNING.SANITY_SMALL

    inst:AddComponent("cookable")
    inst.components.cookable.product = "slugbug_cooked"

    inst:AddComponent("bait")

    return inst
end

local function slugbug_cooked()
    local inst = common("slugbug_cooked", "slugbug_cooked", "MEAT")
    inst.AnimState:PlayAnimation("cooked", true)

    MakeInventoryFloatable(inst, "idle_cooked_water", "cooked")

    inst.components.edible.foodstate = "COOKED"
    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.sanityvalue = -TUNING.SANITY_TINY
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)

    return inst
end

return Prefab("common/inventory/jellybug", jellybug_raw, assets.jellybug, prefabs.jellybug),
       Prefab("common/inventory/jellybug_cooked", jellybug_cooked, assets.jellybug_cooked),
       Prefab("common/inventory/slugbug", slugbug_raw, assets.slugbug, prefabs.slugbug),
       Prefab("common/inventory/slugbug_cooked", slugbug_cooked, assets.slugbug_cooked)