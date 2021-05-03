local assets=
{
	Asset("ANIM", "anim/armor_tarsuit.zip"),
}

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "armor_tarsuit", "swap_body")
    inst.components.fueled:StartConsuming()
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst.components.fueled:StopConsuming()
end

local function onperish(inst)
	inst:Remove()
end

local function fn(Sim)
	local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("armor_tarsuit")
    inst.AnimState:SetBuild("armor_tarsuit")
    inst.AnimState:PlayAnimation("anim")

    MakeInventoryFloatable(inst, "idle_water", "anim")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("waterproofer")
    inst.components.waterproofer.effectiveness = TUNING.WATERPROOFNESS_ABSOLUTE

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.foleysound = "dontstarve_DLC002/common/foley/blubber_suit"

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    
    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "USAGE"
    inst.components.fueled:InitializeFuelLevel(TUNING.TARSUIT_PERISHTIME)
    inst.components.fueled:SetDepletedFn(onperish)
    
    return inst
end

return Prefab( "common/inventory/tarsuit", fn, assets) 
