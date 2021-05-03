local assets=
{
	Asset("ANIM", "anim/mystery_meat.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")

    inst:AddTag("kittenchow")

    inst.components.floatable:SetOnHitLandFn(function(inst)
        inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/mysterymeat_impactland")
    end)

    anim:SetBank("mysterymeat")
    anim:SetBuild("mystery_meat")
    anim:PlayAnimation("idle")

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("appeasement")
    inst.components.appeasement.appeasementvalue = TUNING.WRATH_SMALL

    inst:AddComponent("edible")
    inst.components.edible.healthvalue = TUNING.SPOILED_HEALTH
    inst.components.edible.hungervalue = TUNING.SPOILED_HUNGER
    inst.components.edible.foodtype = "MEAT"

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

    return inst
end

return Prefab( "common/mysterymeat", fn, assets)
