local assets=
{
	Asset("ANIM", "anim/swap_lantern_boat.zip"),
    Asset("INV_IMAGE", "boat_lantern_off"),
}



local function setswapsymbol(inst, symbol)
    if inst.equippedby ~= nil then 
        --print("setting swap to " .. symbol)
        inst.equippedby.AnimState:OverrideSymbol("swap_lantern", "swap_lantern_boat", symbol)
        if inst.equippedby.components.drivable.driver then 
            inst.equippedby.components.drivable.driver.AnimState:OverrideSymbol("swap_lantern", "swap_lantern_boat", symbol)
        end 
    end 
end 

local function turnon(inst)
   -- print("turning on!", inst.GUID)
    --print(debug.traceback())
    if not inst.components.fueled:IsEmpty() then
       
        if inst.components.fueled then
            inst.components.fueled:StartConsuming()        
        end
        inst.Light:Enable(true)
        setswapsymbol(inst, "swap_lantern")
    end
end

local function turnoff(inst)
   -- print("turning off!", inst.GUID)
    --print(debug.traceback())
    if inst.components.fueled then
        inst.components.fueled:StopConsuming()        
    end
    setswapsymbol(inst, "swap_lantern_off")
    inst.Light:Enable(false)
  
end

local function onmounted(boat, data)
    --inst is the boat 
    local item = boat.components.container:GetItemInBoatSlot(BOATEQUIPSLOTS.BOAT_LAMP)
    local isOn = item.components.equippable:IsToggledOn()

    local symbol = "swap_lantern"
    if not isOn then 
        symbol = "swap_lantern_off"
    end 

    data.driver.AnimState:OverrideSymbol("swap_lantern", "swap_lantern_boat", symbol)
    --turnon(inst)
end 

local function cantoggleon(inst)
    return not inst.components.fueled:IsEmpty() and inst.components.equippable:IsEquipped()
end

local function ondismounted(boat, data) 
   -- print("sail says dismounted!")
    data.driver.AnimState:ClearOverrideSymbol("swap_lantern")
    --turnoff(inst)
end 

local function toggleon(inst)
    inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/boatlantern_turnon")
    if not inst.SoundEmitter:PlayingSound("loop") then 
        inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/boatlantern_lp", "loop")
    end 
    inst.components.inventoryitem:ChangeImageName("boat_lantern")
    turnon(inst)
end

local function toggleoff(inst)
    inst.SoundEmitter:KillSound("loop")
    inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/boatlantern_turnoff")
    inst.components.inventoryitem:ChangeImageName("boat_lantern_off")
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
    --[[
    if cantoggleon(inst) then 
        inst.components.equippable:ToggleOn()
    else
        turnoff(inst)
    end 
    ]]
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_lantern")
    if owner.components.drivable.driver then 
        owner.components.drivable.driver.AnimState:ClearOverrideSymbol("swap_lantern")
    end 
    inst.equippedby = nil 
    inst:RemoveEventCallback("mounted", onmounted, owner)
    inst:RemoveEventCallback("dismounted", ondismounted, owner)
    --turnoff(inst)
    inst.components.equippable:ToggleOff()
end

local function nofuel(inst)
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
    if owner then
        owner:PushEvent("torchranout", {torch = inst})
    end
    inst.components.equippable:ToggleOff()
    --turnoff(inst)
end

local function takefuel(inst)
    if inst.components.equippable and inst.components.equippable:IsEquipped() then
        --turnon(inst)
    end
end



local function fuelupdate(inst)
    local fuelpercent = inst.components.fueled:GetPercent()
    inst.Light:SetIntensity(Lerp(0.4, 0.6, fuelpercent))
    inst.Light:SetRadius(Lerp(3, 5, fuelpercent))
    inst.Light:SetFalloff(.9)
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
    inst.AnimState:SetBuild("swap_lantern_boat")
    inst.AnimState:PlayAnimation("idle")
    inst.entity:AddSoundEmitter()
    
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
	--inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/grassarmour"
    inst.components.inventoryitem:ChangeImageName("boat_lantern_off")

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    inst.components.burnable:MakeDragonflyBait(3)


    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "CAVE" --For using fireflies as the fuel 
    inst.components.fueled:InitializeFuelLevel(TUNING.BOAT_LANTERN_LIGHTTIME)
    inst.components.fueled:SetDepletedFn(nofuel)
    inst.components.fueled:SetUpdateFn(fuelupdate)
    inst.components.fueled.ontakefuelfn = takefuel
    inst.components.fueled.accepting = true

    inst.entity:AddLight()
    inst.Light:SetColour(180/255, 195/255, 150/255)
    inst.Light:Enable(false)
    fuelupdate(inst)
        
    inst:AddComponent("equippable")
    inst.components.equippable.boatequipslot =BOATEQUIPSLOTS.BOAT_LAMP
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


return Prefab( "common/inventory/boat_lantern", fn, assets) 
