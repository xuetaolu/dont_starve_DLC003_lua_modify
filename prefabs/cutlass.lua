local assets=
{
	Asset("ANIM", "anim/cutlass.zip"),
	Asset("ANIM", "anim/swap_cutlass.zip"),
}

local function onfinished(inst)
    inst:Remove()
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_cutlass", "swap_cutlass")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
end

local function onattack(inst, attacker, target)
    if target.prefab == "twister" then
        target.components.health:DoDelta(-TUNING.CUTLASS_BONUS_DAMAGE)
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    
    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")
    
    anim:SetBank("cutlass")
    anim:SetBuild("cutlass")
    anim:PlayAnimation("idle")
    
    inst:AddTag("sharp")
    inst:AddTag("cutlass")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.CUTLASS_DAMAGE)
    inst.components.weapon:SetOnAttack(onattack)
    
    -------
    
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.CUTLASS_USES)
    inst.components.finiteuses:SetUses(TUNING.CUTLASS_USES)
    
    inst.components.finiteuses:SetOnFinished( onfinished )

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    
    return inst
end

return Prefab( "common/inventory/cutlass", fn, assets) 
