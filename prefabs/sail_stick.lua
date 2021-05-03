local assets = 
{
    Asset("ANIM", "anim/staffs.zip"),
    Asset("ANIM", "anim/swap_staffs.zip"), 
}

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_staffs", "windstaff")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    inst.components.fueled:StartConsuming()

    if SaveGameIndex:IsModeShipwrecked() and GetWorld().components.seasonmanager.hurricane_gust_state ~= 0 then
        inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/sail_stick")
    end

    owner.ramp_fn = function()
        inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/sail_stick")
    end

    owner:ListenForEvent("wind_rampup", owner.ramp_fn, GetWorld())

    owner.sail_stick_update = owner:DoPeriodicTask(FRAMES, function()
        GetWorld().components.worldwind:SetOverrideAngle(GetPlayer().Transform:GetRotation())
    end)
end

local function onunequip(inst, owner) 
    if owner.ramp_fn then
        owner:RemoveEventCallback("wind_rampup", owner.ramp_fn, GetWorld())
        owner.ramp_fn = nil
    end

    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    inst.components.fueled:StopConsuming()
    GetWorld().components.worldwind:SetOverrideAngle(nil)
    owner.sail_stick_update:Cancel()
    owner.sail_stick_update = nil
end

local function onfinished(inst)
    inst:Remove()
end

local function staff_fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "windstaff_water", "windstaff")

    inst.AnimState:SetBank("staffs")
    inst.AnimState:SetBuild("staffs")
    inst.AnimState:PlayAnimation("windstaff")

    inst:AddTag("nopunch")

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "USAGE"
    inst.components.fueled:InitializeFuelLevel(TUNING.SAILSTICK_PERISHTIME)
    inst.components.fueled:SetDepletedFn(onfinished)

    return inst
end

return Prefab("sail_stick", staff_fn, assets)