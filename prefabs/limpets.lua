local assets=
{
	Asset("ANIM", "anim/limpets.zip"),
}


local prefabs =
{
	"limpets_cooked",
}    

local function commonfn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.AnimState:SetBank("limpets")
    inst.AnimState:SetBuild("limpets")
    
    MakeInventoryPhysics(inst)
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.LIGHT, TUNING.WINDBLOWN_SCALE_MAX.LIGHT)
    
    inst:AddTag("smallmeat")
	inst:AddTag("fishmeat")
    inst:AddTag("packimfood")
    inst:AddComponent("edible")
    inst.components.edible.foodtype = "MEAT"
    inst.components.edible.forcequickeat = true
    

    inst:AddComponent("appeasement")
    inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_TINY
    
	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("bait")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("tradable")
    inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD


    return inst
end

local function defaultfn()
	local inst = commonfn()
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "idle_water", "idle")
    
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.edible.sanityvalue = -TUNING.SANITY_SMALL
    
    
    inst:AddComponent("cookable")
    inst.components.cookable.product = "limpets_cooked"
    --inst:AddComponent("dryable")
    --inst.components.dryable:SetProduct("smallmeat_dried")
    --inst.components.dryable:SetDryTime(TUNING.DRY_FAST)
	return inst
end

local function cookedfn()
	local inst = commonfn()
    inst.AnimState:PlayAnimation("cooked")

    MakeInventoryFloatable(inst, "cooked_water", "cooked")

    inst.components.edible.foodstate = "COOKED"
    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
    
	return inst
end

return Prefab("common/inventory/limpets", defaultfn, assets, prefabs),
		Prefab("common/inventory/limpets_cooked", cookedfn, assets) 
