local assets=
{
	Asset("ANIM", "anim/swap_pirate_booty_bag.zip"),
}

local function SpawnDubloon(inst, owner)
    local dubloon = SpawnPrefab("dubloon")
    local pt = Vector3(inst.Transform:GetWorldPosition()) + Vector3(0,2,0)

    dubloon.Transform:SetPosition(pt:Get())
    local angle = owner.Transform:GetRotation()*(PI/180)
    local sp = (math.random()+1) * -1
    dubloon.Physics:SetVel(sp*math.cos(angle), math.random()*2+8, -sp*math.sin(angle))
    dubloon.components.inventoryitem:OnStartFalling()
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "swap_pirate_booty_bag", "backpack")
	owner.AnimState:OverrideSymbol("swap_body", "swap_pirate_booty_bag", "swap_body")
    owner.components.inventory:SetOverflow(inst)
    inst.components.container:Open(owner)
    inst.dubloon_task = inst:DoPeriodicTask(TUNING.TOTAL_DAY_TIME, function() SpawnDubloon(inst, owner) end)
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
	owner.AnimState:ClearOverrideSymbol("backpack")
    owner.components.inventory:SetOverflow(nil)
    inst.components.container:Close(owner)
    inst.dubloon_task:Cancel()
    inst.dubloon_task = nil
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

local function fn(Sim)
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("pirate_booty_bag")
    inst.AnimState:SetBuild("swap_pirate_booty_bag")
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("backpack")

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("piratepack.png")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.cangoincontainer = false
    inst.components.inventoryitem.foleysound = "dontstarve_DLC002/common/foley/pirate_booty_pack"

    MakeInventoryFloatable(inst, "idle_water", "anim")

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

return Prefab( "common/inventory/piratepack", fn, assets)
