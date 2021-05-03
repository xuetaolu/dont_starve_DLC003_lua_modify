local assets=
{
    Asset("ANIM", "anim/obsidian.zip"),
}

--local function heatfn(inst, observer)
--    return 0.5 * inst.components.stackable:StackSize()
--end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.HEAVY, TUNING.WINDBLOWN_SCALE_MAX.HEAVY)
    MakeInventoryFloatable(inst, "idle_water", "idle")

    inst.components.floatable:SetOnHitWaterFn(function(inst)
        inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/obsidian_wetsizzles")
    end)

    inst.AnimState:SetRayTestOnBB(true);
    inst.AnimState:SetBank("obsidian")
    inst.AnimState:SetBuild("obsidian")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("edible")
    inst.components.edible.foodtype = "ELEMENTAL"

    --inst:AddComponent("tradable")


    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(0)
    inst.no_wet_prefix = true
    inst:AddComponent("inventoryitem")

    --inst:AddComponent("heater")
    --inst.components.heater.heatfn = heatfn
    --inst.components.heater.carriedheatfn = heatfn

    inst:AddComponent("appeasement")
    inst.components.appeasement.appeasementvalue = TUNING.WRATH_LARGE

    inst:AddComponent("bait")
    inst:AddTag("molebait")

    return inst
end

return Prefab( "common/shiprecked/obsidian", fn, assets)
