local assets =
{
    Asset("INV_IMAGE", "werewilbafur"),
}

local function onequip(inst, owner)
	owner:AddTag("venting")
end

local function onunequip(inst, owner)
	owner:RemoveTag("venting")
end

local function makefn(slot)
	local function fn(Sim)
		local inst = CreateEntity()
		inst.entity:AddTransform()
		
	    inst:AddComponent("inspectable")

	    inst:AddComponent("inventoryitem")

	    inst:AddTag("werepigfur")
	    inst:AddTag("venting")
	    inst:AddTag("notslippery")
	    inst:AddTag("cantdrop")	    

	    inst.persists = false 
	    inst:AddComponent("equippable")
	    inst.components.equippable.un_unequipable = true
	    inst.components.equippable.equipslot = slot
		inst.components.inventoryitem:ChangeImageName("werewilbafur")

		inst.components.equippable:SetOnEquip( onequip )
		inst.components.equippable:SetOnUnequip( onunequip )

	    return inst
	end
	return fn
end

local function makefur(name, slot)
    return Prefab("common/inventory/"..name, makefn(slot), assets)
end

return makefur("werewilbafur_head", EQUIPSLOTS.HEAD),
		makefur("werewilbafur_hands", EQUIPSLOTS.HANDS),
		makefur("werewilbafur_body", EQUIPSLOTS.BODY)


