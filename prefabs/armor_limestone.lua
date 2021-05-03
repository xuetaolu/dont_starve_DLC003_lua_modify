local assets =
{
	Asset("ANIM", "anim/armor_limestone.zip"),
}

local function OnBlocked(owner) 
    owner.SoundEmitter:PlaySound("dontstarve_DLC002/common/armour/limestone")
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "armor_limestone", "swap_body")
    inst:ListenForEvent("blocked", OnBlocked, owner)
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst:RemoveEventCallback("blocked", OnBlocked, owner)
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "anim")
    
    inst.AnimState:SetBank("armor_limestone")
    inst.AnimState:SetBuild("armor_limestone")
    inst.AnimState:PlayAnimation("anim")
    
    inst:AddComponent("inspectable")  
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.foleysound = "dontstarve_DLC002/common/foley/limestone_suit"
    
    inst:AddComponent("armor")
    inst.components.armor:InitCondition(TUNING.ARMORLIMESTONE, TUNING.ARMORLIMESTONE_ABSORPTION)
    
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL
    inst.components.equippable.walkspeedmult = TUNING.ARMORLIMESTONE_SPEED_MULT
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    
    return inst
end

return Prefab( "common/inventory/armorlimestone", fn, assets) 
