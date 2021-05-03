local assets=
{
	Asset("ANIM", "anim/antsuit.zip"),
}

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "antsuit", "swap_body")
    inst.components.fueled:StartConsuming()
    owner:AddTag("has_antsuit")
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst.components.fueled:StopConsuming()
    owner:RemoveTag("has_antsuit")
end

local function onperish(inst)
	inst:Remove()
end

local function onupdate(inst)
    inst.components.armor:SetPercent(inst.components.fueled:GetPercent())
end

local function ontakedamage(inst, damage_amount, absorbed, leftover)
    inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/antsuit/hit")
	-- absorbed is the amount of durability that should be consumed
	-- so that's what should be consumed in the fuel
	local absorbedDamageInPercent = absorbed/TUNING.ARMORWOOD
	if inst.components.fueled then
		local percent = inst.components.fueled:GetPercent()
		local newPercent = percent - absorbedDamageInPercent
		inst.components.fueled:SetPercent(newPercent)
	end
end

local function fn(Sim)
	local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("antsuit")
    inst.AnimState:SetBuild("antsuit")
    inst.AnimState:PlayAnimation("anim")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages.xml"
    inst.components.inventoryitem.foleysound = "dontstarve_DLC003/common/crafted/antsuit/foley"
    
    inst:AddComponent("armor")
    inst.components.armor:InitCondition(TUNING.ARMORWOOD, TUNING.ARMORWOOD_ABSORPTION)
	inst.components.armor.ontakedamage = ontakedamage

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable.insulated = true
    
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    
    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "USAGE"
    inst.components.fueled:InitializeFuelLevel(TUNING.RAINCOAT_PERISHTIME)
    inst.components.fueled:SetDepletedFn(onperish)
    inst.components.fueled:SetUpdateFn(onupdate)
    
    return inst
end

return Prefab( "common/inventory/antsuit", fn, assets) 
