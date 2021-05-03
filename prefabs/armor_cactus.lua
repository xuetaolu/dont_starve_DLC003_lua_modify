local assets =
{
	Asset("ANIM", "anim/armor_cactus.zip"),
}

local function OnBlocked(owner, data) 
	
	if (data.weapon == nil or (not data.weapon:HasTag("projectile") and data.weapon.projectile == nil))
		and data.attacker and data.attacker.components.combat and data.stimuli ~= "thorns" and not data.attacker:HasTag("thorny")
		and (data.attacker.components.combat == nil or (data.attacker.components.combat.defaultdamage > 0)) then
		
		data.attacker.components.combat:GetAttacked(owner, TUNING.ARMORCACTUS_DMG, nil, "thorns")
		owner.SoundEmitter:PlaySound("dontstarve_DLC002/common/armour/cactus")
	end
end

local function onequip(inst, owner) 
	owner.AnimState:OverrideSymbol("swap_body", "armor_cactus", "swap_body")
	owner:AddTag("armorcactus")

	inst:ListenForEvent("blocked", OnBlocked, owner)
	inst:ListenForEvent("attacked", OnBlocked, owner)
end

local function onunequip(inst, owner) 
	owner.AnimState:ClearOverrideSymbol("swap_body")
	owner:RemoveTag("armorcactus")

	inst:RemoveEventCallback("blocked", OnBlocked, owner)
	inst:RemoveEventCallback("attacked", OnBlocked, owner)
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()
	inst.entity:AddAnimState()
	MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "idle_water", "anim")

	inst.AnimState:SetBank("armor_cactus")
	inst.AnimState:SetBuild("armor_cactus")
	inst.AnimState:PlayAnimation("anim")
	
	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.foleysound = "dontstarve_DLC002/common/foley/cactus_armour"
		
	inst:AddComponent("armor")
	inst.components.armor:InitCondition(TUNING.ARMORCACTUS, TUNING.ARMORCACTUS_ABSORPTION)
	
	inst:AddComponent("equippable")
	inst.components.equippable.equipslot = EQUIPSLOTS.BODY
	-- inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED
	
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)
	
	return inst
end

return Prefab( "common/inventory/armorcactus", fn, assets) 
