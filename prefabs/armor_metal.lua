local assets=
{
	Asset("ANIM", "anim/armor_metalplate.zip"),
    --Asset("INV_IMAGE", "metalplatehat"),
}

local function OnBlocked(owner) 
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_armour") 
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "armor_metalplate", "swap_body")
    inst:ListenForEvent("blocked", OnBlocked, owner)
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst:RemoveEventCallback("blocked", OnBlocked, owner)
end

local function fn(Sim)
	local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("armor_metalplate")
    inst.AnimState:SetBuild("armor_metalplate")
    inst.AnimState:PlayAnimation("anim")
    
    inst:AddTag("metal")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.foleysound = "dontstarve_DLC003/movement/iron_armor/foley_player"
    
    inst:AddComponent("armor")
    inst.components.armor:InitCondition(TUNING.ARMORMETAL, TUNING.ARMORMETAL_ABSORPTION)
    
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable.walkspeedmult = TUNING.ARMORMETAL_SLOW
    
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    


    return inst
end

return Prefab( "common/inventory/armor_metalplate", fn, assets) 
