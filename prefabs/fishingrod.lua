local assets=
{
	Asset("ANIM", "anim/fishingrod.zip"),
	Asset("ANIM", "anim/swap_fishingrod.zip"),
}

local function onfinished(inst)
    inst:Remove()
end
    

local function onequip (inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_fishingrod", "swap_fishingrod")
    owner.AnimState:OverrideSymbol("fishingline", "swap_fishingrod", "fishingline")
    owner.AnimState:OverrideSymbol("FX_fishing", "swap_fishingrod", "FX_fishing")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal")
    owner.AnimState:ClearOverrideSymbol("fishingline")
    owner.AnimState:ClearOverrideSymbol("FX_fishing")
end

local function onfished(inst)
    if inst.components.finiteuses then
        inst.components.finiteuses:Use(1)
    end
end


local function common(Sim)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")
    
    anim:SetBank("fishingrod")
    anim:SetBuild("fishingrod")
    anim:PlayAnimation("idle")
    
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.FISHINGROD_DAMAGE)
    inst.components.weapon.attackwear = 4
    -----
    inst:AddComponent("fishingrod")

      -------
    inst:AddComponent("finiteuses")
    
    inst.components.finiteuses:SetOnFinished(onfinished)
    inst:ListenForEvent("fishingcollect", onfished)
    inst:ListenForEvent("retrievecollect", onfished)

    ---------
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("equippable")
    
    
    inst.components.equippable:SetOnUnequip( onunequip )

    return inst

end 
    
local function fishingrod(Sim)
	local inst = common(Sim)	
    inst.components.fishingrod:SetWaitTimes(TUNING.FISHINGROD_MIN_WAIT_TIME, TUNING.FISHINGROD_MAX_WAIT_TIME)
    inst.components.fishingrod:SetStrainTimes(0, 5)

    inst.components.fishingrod.basenibbletime = TUNING.FISHING_ROD_BASE_NIBBLE_TIME
    inst.components.fishingrod.nibbletimevariance = TUNING.FISHING_ROD_NIBBLE_TIME_VARIANCE
    inst.components.fishingrod.nibblestealchance = TUNING.FISHING_ROD_STEAL_CHANCE

    inst.components.finiteuses:SetMaxUses(TUNING.FISHINGROD_USES)
    inst.components.finiteuses:SetUses(TUNING.FISHINGROD_USES)

    inst.components.equippable:SetOnEquip( onequip )

    return inst
end


return Prefab( "common/inventory/fishingrod", fishingrod, assets)

