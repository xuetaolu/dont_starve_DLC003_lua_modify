local assets=
{
	Asset("ANIM", "anim/fish.zip"),
	Asset("ANIM", "anim/fish01.zip"),
    Asset("ANIM", "anim/fish2.zip"),
    Asset("ANIM", "anim/fish02.zip"),
    Asset("ANIM", "anim/coi.zip"),
    Asset("INV_IMAGE", "fishtropical_cooked"),
    Asset("INV_IMAGE", "coi"),
    Asset("INV_IMAGE", "coi_cooked"),
    Asset("MINIMAP_IMAGE", "fish2"),
}


local prefabs =
{
    "fish_cooked",
    "spoiled_food",
    "tropical_fish_cooked",
}

local function stopkicking(inst)
    inst.AnimState:PlayAnimation("dead")
end

local function makefish(bank_and_build, rodbuild, cooked_prod)

    local function commonfn()

        if bank_and_build == "fish" and SaveGameIndex and SaveGameIndex:IsModePorkland() then
            bank_and_build = "coi"
        end       
          
	    local inst = CreateEntity()
	    inst.entity:AddTransform()
        
        MakeInventoryPhysics(inst)
        MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.MEDIUM, TUNING.WINDBLOWN_SCALE_MAX.MEDIUM)
        
	    inst.entity:AddAnimState()

        inst.AnimState:SetBank(bank_and_build)
        inst.AnimState:SetBuild(bank_and_build)
        
        inst.build = rodbuild --This is used within SGwilson, sent from an event in fishingrod.lua
        
        inst:AddTag("meat")
		inst:AddTag("fishmeat")
        inst:AddTag("catfood")
        inst:AddTag("packimfood")

        inst:AddComponent("edible")
        inst.components.edible.ismeat = true
        inst.components.edible.foodtype = "MEAT"
        
        inst:AddComponent("stackable")
		inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

        inst:AddComponent("bait")

        
		inst:AddComponent("perishable")
		inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
		inst.components.perishable:StartPerishing()
		inst.components.perishable.onperishreplacement = "spoiled_food"
        
        
        inst:AddComponent("inspectable")
        
        inst:AddComponent("inventoryitem")
        
        inst:AddComponent("tradable")
        inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
        inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD
        inst.data = {}

        inst:AddComponent("appeasement")
        inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_TINY

        return inst
    end

    local function rawfn()
	    local inst = commonfn()
        inst.AnimState:PlayAnimation("idle", true)

        MakeInventoryFloatable(inst, "idle_water", "idle")

		inst.components.edible.healthvalue = TUNING.HEALING_TINY
		inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
		inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
        
        inst:AddComponent("cookable")
        inst.components.cookable.product = cooked_prod
        inst:AddComponent("dryable")
        inst.components.dryable:SetProduct("smallmeat_dried")
        inst.components.dryable:SetDryTime(TUNING.DRY_FAST)
        inst:DoTaskInTime(5, stopkicking)
        inst.components.inventoryitem:SetOnPickupFn(function(pickupguy) stopkicking(inst) end)
        inst.OnLoad = function() stopkicking(inst) end

        MakeInventoryFloatable(inst, "idle_water", "dead")
        
        return inst
    end

    local function cookedfn()
	    local inst = commonfn()
        inst.AnimState:PlayAnimation("cooked")

        MakeInventoryFloatable(inst, "idle_cooked_water", "cooked")
        
        inst.components.edible.foodstate = "COOKED"
		inst.components.edible.healthvalue = TUNING.HEALING_TINY
		inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
		inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)

        return inst
    end
    return rawfn, cookedfn
end

local function fish(name, build, rodbuild, cooked_prod)
    local raw, cooked = makefish(build, rodbuild, cooked_prod)
    return Prefab( "common/inventory/"..name, raw, assets, prefabs),
        Prefab( "common/inventory/"..name.."_cooked", cooked, assets)
end

local regularfish, cookedfish = fish("fish", "fish", "fish01", "fish_cooked")
local tropicalfish = fish("tropical_fish", "fish2", "fish02", "fish_raw_small_cooked") 
return regularfish, cookedfish, tropicalfish
