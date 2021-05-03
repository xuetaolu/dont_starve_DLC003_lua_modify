local assets=
{
	Asset("ANIM", "anim/swap_cannon_pirate.zip"),
}

local prefabs = 
{
    "woodlegs_cannonshot",
    "collapse_small",
}

local function onmounted(data, inst)
    data.driver.AnimState:OverrideSymbol("swap_lantern", "swap_cannon_pirate", "swap_cannon")
end 

local function ondismounted(data, inst) 
    data.driver.AnimState:ClearOverrideSymbol("swap_lantern")
end 

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_lantern", "swap_cannon_pirate", "swap_cannon")
    if owner.components.drivable and owner.components.drivable.driver then 
        owner.components.drivable.driver.AnimState:OverrideSymbol("swap_lantern", "swap_cannon_pirate", "swap_cannon")
    end 
    inst.equippedby = owner 
    inst:ListenForEvent("mounted", function(boat,data) onmounted(data, inst) end, owner)
    inst:ListenForEvent("dismounted", function(boat,data) ondismounted(data, inst) end, owner)
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_lantern")
    if owner.components.drivable and owner.components.drivable.driver then 
        owner.components.drivable.driver.AnimState:ClearOverrideSymbol("swap_lantern")
    end 
    inst.equippedby = nil 
    inst:RemoveEventCallback("mounted", onmounted, owner)
    inst:RemoveEventCallback("dismounted", ondismounted, owner)
    inst:Remove()
end

local function onfinished(inst)
     if inst.equippedby then 
        inst.equippedby.AnimState:ClearOverrideSymbol("swap_lantern")
        if inst.equippedby.components.drivable and inst.equippedby.components.drivable.driver then 
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
    inst.AnimState:SetBuild("swap_cannon_pirate")
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

    inst:AddTag("cannon")

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = function() 
        return inst.components.thrower:GetThrowPoint()
    end
    inst.components.reticule.ease = true

    inst:AddComponent("thrower")
    inst.components.thrower.throwable_prefab = "woodlegs_cannonshot"
    inst.components.thrower.onthrowfn = onthrowfn
    inst.components.thrower.canthrowatpointfn = canshootfn

    return inst
end

return Prefab( "common/inventory/woodlegs_boatcannon", fn, assets, prefabs)