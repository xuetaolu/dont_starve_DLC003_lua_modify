local assets=
{
	Asset("ANIM", "anim/mussel.zip"),
}

local prefabs =
{
	"mussel_cooked",
	"spoiled_food",
}


local function common()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("mussel")
	inst.AnimState:SetBuild("mussel")
	inst.AnimState:SetRayTestOnBB(true)

	inst:AddComponent("edible")
	inst.components.edible.foodtype = "MEAT"

	inst:AddComponent("appeasement")
    inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_SMALL

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
    inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD
    
	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")
	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	inst:AddTag("packimfood")
	inst:AddTag("fishmeat")

	return inst
end

local function raw()
	local inst = common()
	inst.no_wet_prefix = true
	inst.AnimState:PlayAnimation("idle")
	inst.components.edible.healthvalue = 0
	inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
	inst.components.edible.sanityvalue = -TUNING.SANITY_SMALL

	inst:AddComponent("cookable")
	inst.components.cookable.product = "mussel_cooked"

	inst:AddTag("aquatic")
	inst:AddComponent("bait")

	return inst
end

local function cooked()
	local inst = common()
	inst.AnimState:PlayAnimation("cooked")
	inst.components.edible.foodstate = "COOKED"
	inst.components.edible.healthvalue = TUNING.HEALING_TINY
	inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
	inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
	return inst
end

return Prefab( "common/inventory/mussel", raw, assets, prefabs),
	   Prefab("common/inventory/mussel_cooked", cooked, assets)
