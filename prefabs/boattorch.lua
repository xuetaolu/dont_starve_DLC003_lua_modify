local assets=
{
	Asset("ANIM", "anim/swap_torch_boat.zip"),
    Asset("INV_IMAGE", "boat_torch_off"),
}

local function setswapsymbol(inst, symbol)
    if inst.equippedby ~= nil then
        inst.equippedby.AnimState:OverrideSymbol("swap_lantern", "swap_torch_boat", symbol)
        if inst.equippedby.components.drivable.driver then
            inst.equippedby.components.drivable.driver.AnimState:OverrideSymbol("swap_lantern", "swap_torch_boat", symbol)
        end
    end
end

local function turnon(inst)
    if not inst.components.fueled:IsEmpty() then
        if inst.components.fueled then
            inst.components.fueled:StartConsuming()
        end
        inst.Light:Enable(true)
        setswapsymbol(inst, "swap_lantern")
    end
end

local function turnoff(inst)
    if inst.components.fueled then
        inst.components.fueled:StopConsuming()
    end
    setswapsymbol(inst, "swap_lantern_off")
    inst.Light:Enable(false)
end

local function onmounted(boat, data)
    local item = boat.components.container:GetItemInBoatSlot(BOATEQUIPSLOTS.BOAT_LAMP)
    local isOn = item.components.equippable:IsToggledOn()

    local symbol = "swap_lantern"
    if not isOn then
        symbol = "swap_lantern_off"
    end

    data.driver.AnimState:OverrideSymbol("swap_lantern", "swap_torch_boat", symbol)
end

local function cantoggleon(inst)
    return not inst.components.fueled:IsEmpty() and inst.components.equippable:IsEquipped()
end

local function ondismounted(boat, data)
    data.driver.AnimState:ClearOverrideSymbol("swap_lantern")
end

local function toggleon(inst)
    if not inst.SoundEmitter:PlayingSound("torch") then
        inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/boatlantern_lp", "torch")
    end

    inst.SoundEmitter:PlaySound("dontstarve/wilson/torch_swing")

    inst.components.inventoryitem:ChangeImageName("boat_torch")
    turnon(inst)
end

local function toggleoff(inst)
    inst.SoundEmitter:KillSound("loop")
    inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/boatlantern_turnoff")

    inst.SoundEmitter:KillSound("torch")
    inst.SoundEmitter:PlaySound("dontstarve/common/fireOut")

    inst.components.inventoryitem:ChangeImageName("boat_torch_off")
    turnoff(inst)
end

local function onequip(inst, owner)

    inst:ListenForEvent("mounted", onmounted, owner)
    inst:ListenForEvent("dismounted", ondismounted, owner)
    inst.equippedby = owner

    local isOn = inst.components.equippable:IsToggledOn()

    local symbol = "swap_lantern"
    if not isOn then
        symbol = "swap_lantern_off"
    end
    setswapsymbol(inst, symbol)
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_lantern")
    if owner.components.drivable.driver then
        owner.components.drivable.driver.AnimState:ClearOverrideSymbol("swap_lantern")
    end
    inst.equippedby = nil
    inst:RemoveEventCallback("mounted", onmounted, owner)
    inst:RemoveEventCallback("dismounted", ondismounted, owner)
    inst.components.equippable:ToggleOff()
end

local function nofuel(inst)
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    if owner then
        owner:PushEvent("torchranout", {torch = inst})
    end
    inst:Remove()
end

local function ondropped(inst)
    turnoff(inst)
end

local function returntointeriorscene(inst)
	if not inst.equippedby then
		turnoff(inst)
	end
end

local function fn(Sim)
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")

    inst.AnimState:SetBank("lantern_boat")
    inst.AnimState:SetBuild("swap_torch_boat")
    inst.AnimState:PlayAnimation("idle")
    inst.entity:AddSoundEmitter()

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem:ChangeImageName("boat_torch_off")

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "BURNABLE"
    inst.components.fueled:InitializeFuelLevel(TUNING.BOAT_TORCH_LIGHTTIME)
    inst.components.fueled:SetDepletedFn(nofuel)

    inst.entity:AddLight()
    inst.Light:SetIntensity(.75)
    inst.Light:SetColour(197/255,197/255,50/255)
    inst.Light:SetFalloff( 0.5 )
    inst.Light:SetRadius( 2 )
    inst.Light:Enable(false)

    inst:AddComponent("equippable")
    inst.components.equippable.boatequipslot = BOATEQUIPSLOTS.BOAT_LAMP
    inst.components.equippable.equipslot = nil
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.togglable = true
    inst.components.equippable.toggledonfn = toggleon
    inst.components.equippable.toggledofffn = toggleoff
    inst.components.equippable.cantoggleonfn = cantoggleon
    inst.equippedby = nil

	inst.returntointeriorscene = returntointeriorscene

    return inst
end


return Prefab("boat_torch", fn, assets)
