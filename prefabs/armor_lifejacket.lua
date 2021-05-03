local assets=
{
	Asset("ANIM", "anim/armor_lifejacket.zip"),
    Asset("INV_IMAGE", "armor_lifeJacket"),
}



local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "armor_lifejacket", "swap_body")
    --inst:ListenForEvent("blocked", OnBlocked, owner)
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
    --inst:RemoveEventCallback("blocked", OnBlocked, owner)
end

local function fn(Sim)
	local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "anim")
    
    inst.AnimState:SetBank("armor_lifejacket")
    inst.AnimState:SetBuild("armor_lifejacket")
    inst.AnimState:PlayAnimation("anim")
    
    --inst:AddTag("wood")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.keepondeath = true
    inst.components.inventoryitem.foleysound = "dontstarve_DLC002/common/foley/life_jacket"

    --inst:AddComponent("fuel")
   -- inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    --inst.components.burnable:MakeDragonflyBait(3)
    
    --inst:AddComponent("armor")
    --inst.components.armor:InitCondition(TUNING.ARMORWOOD, TUNING.ARMORWOOD_ABSORPTION)
    
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    
    return inst
end

return Prefab( "common/inventory/armor_lifejacket", fn, assets) 
