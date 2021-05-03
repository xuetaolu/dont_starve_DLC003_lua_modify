local assets=
{
    Asset("ANIM", "anim/shears.zip"),
    Asset("ANIM", "anim/swap_shears.zip"),
    Asset("INV_IMAGE", "shears"),
}

local function onfinished(inst)
    inst:Remove()
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_shears", "swap_shears")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function fn(Sim)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")
    
    anim:SetBank("shears")
    anim:SetBuild("shears")
    anim:PlayAnimation("idle")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SHEARS_DAMAGE)
    inst:AddTag("shears")

    ---------------------------------------------------------------
    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.SHEAR)
    ---------------------------------------------------------------
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SHEARS_USES)
    inst.components.finiteuses:SetUses(TUNING.SHEARS_USES)
    
    inst.components.finiteuses:SetOnFinished( onfinished )
    inst.components.finiteuses:SetConsumption(ACTIONS.SHEAR, 1)
    ---------------------------------------------------------------

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("equippable")

    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )

    --inst.components.inventoryitem:ChangeImageName("machete")

    return inst
end


return Prefab( "common/inventory/shears", fn, assets) 