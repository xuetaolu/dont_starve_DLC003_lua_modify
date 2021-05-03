local assets =
{
	Asset("ANIM", "anim/armor_bramble.zip"),
}

local function OnBlocked(owner, data) 
--[[
	if (data.weapon == nil or (not data.weapon:HasTag("projectile") and data.weapon.projectile == nil))		
		and data.attacker and data.attacker.components.combat and data.stimuli ~= "thorns" and not data.attacker:HasTag("thorny")
		and (data.attacker.components.combat == nil or (data.attacker.components.combat.defaultdamage > 0)) then
	]]	
		local fx = SpawnPrefab("bramblefx")
		local x,y,z = owner.Transform:GetWorldPosition()
		fx.Transform:SetPosition(x,y,z)

		local ents = TheSim:FindEntities(x,y,z, 4,nil,{"INLIMBO"})
		if #ents > 0 then			
			for i,ent in pairs(ents)do
				if ent.components.combat and ent ~= owner then
					local src = owner
					if ent.components.follower and ent.components.follower.leader == owner then
						src = nil
					end
					ent.components.combat:GetAttacked(src, TUNING.ARMORBRAMBLE_DMG, nil, "thorns")
				end
			end
		end
		--data.attacker.components.combat:GetAttacked(owner, TUNING.ARMORBRAMBLE_DMG, nil, "thorns")
		owner.SoundEmitter:PlaySound("dontstarve_DLC002/common/armour/cactus")
	--end
end

local function onequip(inst, owner) 
	owner.AnimState:OverrideSymbol("swap_body", "armor_bramble", "swap_body")
	owner:AddTag("bramble_resistant")

	inst:ListenForEvent("blocked", OnBlocked, owner)
	inst:ListenForEvent("attacked", OnBlocked, owner)
end

local function onunequip(inst, owner) 
	owner.AnimState:ClearOverrideSymbol("swap_body")
	owner:RemoveTag("bramble_resistant")

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

	inst.AnimState:SetBank("armor_bramble")
	inst.AnimState:SetBuild("armor_bramble")
	inst.AnimState:PlayAnimation("anim")
	
	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.foleysound = "dontstarve_DLC002/common/foley/cactus_armour"
		
	inst:AddComponent("armor")
	inst.components.armor:InitCondition(TUNING.ARMORBRAMBLE, TUNING.ARMORBRAMBLE_ABSORPTION)
	
	inst:AddComponent("equippable")
	inst.components.equippable.equipslot = EQUIPSLOTS.BODY
	-- inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED
	
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)
	
	return inst
end

return Prefab( "common/inventory/armor_bramble", fn, assets) 
