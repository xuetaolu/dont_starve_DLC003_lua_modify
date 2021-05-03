local assets =
{
	Asset("ANIM", "anim/brain_coral.zip")
}

local prefabs = 
{
	"spoiled_food",
}

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.HEAVY, TUNING.WINDBLOWN_SCALE_MAX.HEAVY)

	inst.AnimState:SetBank("brain_coral")
	inst.AnimState:SetBuild("brain_coral")
	inst.AnimState:PlayAnimation("idle")

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")

    inst:AddComponent("edible")
    inst.components.edible.foodtype = "MEAT"
    inst.components.edible.healthvalue = -10
    inst.components.edible.sanityvalue = 50
    inst.components.edible.hungervalue = 10
	inst:AddTag("fishmeat")

    inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_ONE_DAY)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	return inst
end

return Prefab("coral_brain", fn, assets, prefabs)
