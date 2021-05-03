local assets =
{
    Asset("ANIM", "anim/armor_weevole.zip"),
}

local prefabs =
{
	"weevole_carapace",
}

local function OnBlocked(owner) 
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_armour")
end

local function onequip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_body", "armor_weevole", "swap_body")
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

    inst.AnimState:SetBank("armor_weevole")
    inst.AnimState:SetBuild("armor_weevole")
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("wood")
    inst:AddTag("vented")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/logarmour"

    inst:AddComponent("armor")
    inst.components.armor:InitCondition(TUNING.ARMOR_WEEVOLE_DURABILITY, TUNING.ARMOR_WEEVOLE_ABSORPTION)

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY

    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    return inst
end

return Prefab("armor_weevole", fn, assets)
