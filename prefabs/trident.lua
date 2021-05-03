local assets=
{
	Asset("ANIM", "anim/trident.zip"),
	Asset("ANIM", "anim/swap_trident.zip"),
}

local function onfinished(inst)
	inst:Remove()
end

local function onequip(inst, owner) 
	owner.AnimState:OverrideSymbol("swap_object", "swap_trident", "swap_trident")
	owner.AnimState:Show("ARM_carry") 
	owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner) 
	owner.AnimState:Hide("ARM_carry") 
	owner.AnimState:Show("ARM_normal") 
end
--[[]
local function onattack(inst, attacker, target)
	if attacker:HasTag("aquatic") then
		inst.components.weapon:SetDamage(TUNING.SPEAR_DAMAGE*3)
	else
		inst.components.weapon:SetDamage(TUNING.SPEAR_DAMAGE)
	end
end
]]

local function getDamage(inst)
	if inst.components.inventoryitem and inst.components.inventoryitem.owner then 
		if inst.components.inventoryitem.owner:HasTag("aquatic") then 
			return TUNING.SPEAR_DAMAGE*3
		end 
	end 
	return TUNING.SPEAR_DAMAGE
end 


local function commonfn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	
	MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "idle_water", "idle")
	
	anim:SetBank("trident")
	anim:SetBuild("trident")
	anim:PlayAnimation("idle")
	
	inst:AddTag("sharp")

	inst:AddComponent("weapon")
	--inst.components.weapon:SetOnAttack(onattack)
	inst.components.weapon:SetDamage(TUNING.SPEAR_DAMAGE)
	inst.components.weapon.getdamagefn = getDamage
	
	-------
	
	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(TUNING.SPEAR_USES)
	inst.components.finiteuses:SetUses(TUNING.SPEAR_USES)
	
	inst.components.finiteuses:SetOnFinished( onfinished )

	inst:AddComponent("inspectable")
	
	inst:AddComponent("inventoryitem")
	
	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip( onequip )
	inst.components.equippable:SetOnUnequip( onunequip )
	
	return inst
end

return Prefab( "common/inventory/trident", commonfn, assets)
