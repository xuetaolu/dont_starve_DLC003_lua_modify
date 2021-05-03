local assets=
{
	Asset("ANIM", "anim/swap_chefpack.zip"),
	-- Asset("ANIM", "anim/ui_thatchpack_1x4.zip"),
	Asset("MINIMAP_IMAGE", "chefpack"),
}

local function onequip(inst, owner) 
	owner.AnimState:OverrideSymbol("swap_body", "swap_chefpack", "backpack")
	owner.AnimState:OverrideSymbol("swap_body", "swap_chefpack", "swap_body")
	owner.components.inventory:SetOverflow(inst)
	inst.components.container:Open(owner) 
end

local function onunequip(inst, owner) 
	owner.AnimState:ClearOverrideSymbol("swap_body")
	owner.AnimState:ClearOverrideSymbol("backpack")
	owner.components.inventory:SetOverflow(nil)
	inst.components.container:Close(owner)
end

local function onopen(inst)
	inst.SoundEmitter:PlaySound("dontstarve/wilson/backpack_open", "open")
end

local function onclose(inst)
	inst.SoundEmitter:PlaySound("dontstarve/wilson/backpack_close", "open")
end

local slotpos = {}

for y = 0, 3 do
	table.insert(slotpos, Vector3(-162, -y*75 + 114 ,0))
	table.insert(slotpos, Vector3(-162 +75, -y*75 + 114 ,0))
end

local function fn()
	local inst = CreateEntity()    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

	local minimap = inst.entity:AddMiniMapEntity()	
	minimap:SetIcon("chefpack.png")

	MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "anim")
	
	inst.AnimState:SetBank("chefpack")
	inst.AnimState:SetBuild("swap_chefpack")
	inst.AnimState:PlayAnimation("anim")

	inst:AddTag("backpack")
	inst:AddTag("fridge")
	inst:AddTag("nocool")

	inst:AddComponent("inspectable")
	
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.cangoincontainer = false
	inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/backpack"

	inst:AddComponent("equippable")
	inst.components.equippable.equipslot = EQUIPSLOTS.BODY
	inst.components.equippable:SetOnEquip( onequip )
	inst.components.equippable:SetOnUnequip( onunequip )
	
	inst:AddComponent("container")
    inst.components.container:SetNumSlots(#slotpos)
    inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetanimbank = "ui_backpack_2x4"
    inst.components.container.widgetanimbuild = "ui_backpack_2x4"
    inst.components.container.widgetpos = Vector3(-5,-70,0)
    inst.components.container.side_widget = true
    inst.components.container.type = "pack"
	inst.components.container.onopenfn = onopen
	inst.components.container.onclosefn = onclose

	MakeSmallBurnable(inst)
	MakeSmallPropagator(inst)

	inst.components.burnable:SetOnBurntFn(function()
		if inst.inventoryitemdata then inst.inventoryitemdata = nil end

		if inst.components.container then
			inst.components.container:DropEverything()
			inst.components.container:Close()
			inst:RemoveComponent("container")
		end
		
		local ash = SpawnPrefab("ash")
		ash.Transform:SetPosition(inst.Transform:GetWorldPosition())

		inst:Remove()
	end)

	return inst
end

return Prefab("spicepack", fn, assets)