local assets=
{
	Asset("ANIM", "anim/swap_cannon.zip"),
}

local prefabs = 
{
    "cannonshot",
    "collapse_small",
}

local function onmounted(boat, data)
    data.driver.AnimState:OverrideSymbol("swap_lantern", "swap_cannon", "swap_cannon")
end 

local function ondismounted(boat, data) 
    data.driver.AnimState:ClearOverrideSymbol("swap_lantern")
end 

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_lantern", "swap_cannon", "swap_cannon")
    if owner.components.drivable.driver then 
        owner.components.drivable.driver.AnimState:OverrideSymbol("swap_lantern", "swap_cannon", "swap_cannon")
    end 
    inst.equippedby = owner 
    inst:ListenForEvent("mounted", onmounted, owner)
    inst:ListenForEvent("dismounted", ondismounted, owner)
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_lantern")
    if owner.components.drivable.driver then 
        owner.components.drivable.driver.AnimState:ClearOverrideSymbol("swap_lantern")
    end 
    inst.equippedby = nil 
    inst:RemoveEventCallback("mounted", onmounted, owner)
    inst:RemoveEventCallback("dismounted", ondismounted, owner)
end

local function onfinished(inst)
     if inst.equippedby then 
        inst.equippedby.AnimState:ClearOverrideSymbol("swap_lantern")
        if inst.equippedby.components.drivable.driver then 
           inst.equippedby.components.drivable.driver.AnimState:ClearOverrideSymbol("swap_lantern")
        end 
    end 
    inst:Remove()
end

local function onthrowfn(inst)
    if inst.components.finiteuses then
        inst.components.finiteuses:Use()
    end
end

local function canshootfn(inst, pt)
    return inst.components.equippable:IsEquipped()
end

local function fn(Sim)

    --NOTE!! Most of the logic for this happens in cannonshot.lua

	local inst = CreateEntity()
    inst.entity:AddTransform()
	inst.entity:AddAnimState()

    inst.AnimState:SetBank("cannon")
    inst.AnimState:SetBuild("swap_cannon")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable.boatequipslot = BOATEQUIPSLOTS.BOAT_LAMP
    inst.components.equippable.equipslot = nil
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.BOATCANNON_AMMO_COUNT)
    inst.components.finiteuses:SetUses(TUNING.BOATCANNON_AMMO_COUNT)
    inst.components.finiteuses:SetOnFinished( onfinished)

    inst:AddTag("cannon")

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = function() 
        return inst.components.thrower:GetThrowPoint()
    end
    inst.components.reticule.ease = true

    inst:AddComponent("thrower")
    inst.components.thrower.throwable_prefab = "cannonshot"
    inst.components.thrower.onthrowfn = onthrowfn
    inst.components.thrower.canthrowatpointfn = canshootfn

    return inst
end

return Prefab( "common/inventory/boatcannon", fn, assets, prefabs)