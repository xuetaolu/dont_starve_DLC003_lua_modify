local assets =
{
	Asset("ANIM", "anim/tarlamp.zip"),
	Asset("ANIM", "anim/swap_tarlamp.zip"),
    Asset("ANIM", "anim/swap_tarlamp_boat.zip"),
}
 
local prefabs =
{
	"tarlampfire",
}    


-- TOGGLES // ON // OFF
local function cantoggleon(inst)
    return not inst.components.fueled:IsEmpty() and inst.components.equippable:IsEquipped()
end

local function toggleon(inst)
    inst.turnon(inst)
end

local function toggleoff(inst)
    inst.turnoff(inst)
end


local function setswapsymbol(inst, symbol)
    if inst.equippedby ~= nil then
        if inst.equippedby.components.drivable then
            inst.equippedby.AnimState:OverrideSymbol("swap_lantern", "swap_tarlamp_boat", symbol)
            if inst.equippedby.components.drivable.driver then
                inst.equippedby.components.drivable.driver.AnimState:OverrideSymbol("swap_lantern", "swap_tarlamp_boat", symbol)
            end
        else
            inst.equippedby.AnimState:OverrideSymbol("swap_object", "swap_tarlamp", symbol)
        end
    end
end

-- OFF // ON
local function turnoff(inst)

    if inst.components.fueled then
        inst.components.fueled:StopConsuming()
    end
    inst.Light:Enable(false)

    inst.SoundEmitter:KillSound("torch")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/lighter_off")        
    inst.components.burnable:Extinguish()


    if inst.equippedby then
        setswapsymbol(inst, "swap_lantern_off")
    else       
        if inst:GetIsOnWater() then
            inst.AnimState:PlayAnimation("idle_off_water")
        else
            inst.AnimState:PlayAnimation("idle_off")
        end
    end
end

local function turnon(inst)
    if inst.components.fueled then
        if not inst.components.fueled:IsEmpty() then        
            inst.components.fueled:StartConsuming()
        else
            return
        end
    end
    inst.Light:Enable(true)
    
    inst.components.burnable:Ignite()
    inst.SoundEmitter:PlaySound("dontstarve/wilson/torch_LP", "torch")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/lighter_on")
    inst.SoundEmitter:SetParameter( "torch", "intensity", 1 )


    if inst.equippedby then
        setswapsymbol(inst, "swap_lantern")      
    else
        if inst:GetIsOnWater() then
            inst.AnimState:PlayAnimation("idle_on_water")
        else
            inst.AnimState:PlayAnimation("idle_on")
        end
    end

end


-- MOUNT // DISMOUNT
local function onmounted(boat, data)
    local item = boat.components.container:GetItemInBoatSlot(BOATEQUIPSLOTS.BOAT_LAMP)
    local symbol = "swap_lantern_off"
    if item.components.machine.ison then
      symbol = "swap_lantern"
    end
    --setswapsymbol(item, symbol)    
    data.driver.AnimState:OverrideSymbol("swap_lantern", "swap_tarlamp_boat", symbol)
end

local function ondismounted(boat, data)
    local item = boat.components.container:GetItemInBoatSlot(BOATEQUIPSLOTS.BOAT_LAMP)    
    --turnoff(item)    
    data.driver.AnimState:ClearOverrideSymbol("swap_lantern")
end

-- EQUIP // UNEQIP
local function onequip(inst, owner, force, rowing) 
    if not owner.sg or not owner.sg:HasStateTag("rowing") or force then 
        inst.equippedby = owner
        if owner.components.drivable then
            inst:ListenForEvent("mounted", onmounted, owner)
            inst:ListenForEvent("dismounted", ondismounted, owner)
        else
            owner.AnimState:Show("ARM_carry") 
            owner.AnimState:Hide("ARM_normal")         
        end
        setswapsymbol(inst, "swap_lantern_off")
        if inst.wason or not rowing then
            inst.components.equippable:ToggleOn()
        end
    end
end

local function onunequip(inst,owner) 
    inst.equippedby = nil
    if owner.components.drivable then
        if owner.components.drivable.driver then
            owner.components.drivable.driver.AnimState:ClearOverrideSymbol("swap_lantern")
        end
        inst:RemoveEventCallback("mounted", onmounted, owner)
        inst:RemoveEventCallback("dismounted", ondismounted, owner)

        owner.AnimState:ClearOverrideSymbol("swap_lantern")
        if owner.components.drivable.driver then
            owner.components.drivable.driver.AnimState:ClearOverrideSymbol("swap_lantern")
        end
    else
        owner.AnimState:Hide("ARM_carry") 
        owner.AnimState:Show("ARM_normal")
        owner.components.combat.damage = owner.components.combat.defaultdamage
    end
    inst.wason = inst.components.fueled.consuming
    inst.components.equippable:ToggleOff()
end





local function onfueledupdate(inst)
    local rate = 1
    if GetSeasonManager():IsRaining() and not 
            (inst.components.inventoryitem and inst.components.inventoryitem.owner and 
            inst.components.inventoryitem.owner.components.moisture and inst.components.inventoryitem.owner.components.moisture.sheltered) then
        rate = rate + TUNING.TORCH_RAIN_RATE*GetSeasonManager():GetPrecipitationRate()
    end
    rate = rate + TUNING.TORCH_WIND_RATE * GetSeasonManager():GetHurricaneWindSpeed() 
    inst.components.fueled.rate = rate
end

local function depleted(inst)
    if not inst.equippedby then
        local ash = SpawnPrefab( "ash" )
        ash.Transform:SetPosition(inst:GetPosition():Get())        
    end
end

local function onRemove(inst)
    if inst.fire then
        inst.fire:Remove()
        inst.fire = nil
    end
end

local function ondropped(inst)
    inst.components.equippable:ToggleOff()
   inst.components.equippable:ToggleOn()
end

local function onpickup(inst)
    inst.components.equippable:ToggleOff()
end

local function onputininventory(inst)
    inst.components.equippable:ToggleOff()
end



local function OnLoad(inst,data)
    if not data then
        return
    end
    inst.wason = data.wason
   
end

local function OnSave(inst,data)
    data.wason = inst.wason
end
-- MAIN
local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()

    anim:SetBank("tarlamp")
    anim:SetBuild("tarlamp")
    anim:PlayAnimation("idle_off")
    MakeInventoryPhysics(inst)
    
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.LIGHTER_DAMAGE)
    inst.components.weapon:SetAttackCallback(
        function(attacker, target)
            if target.components.burnable then
                if math.random() < TUNING.LIGHTER_ATTACK_IGNITE_PERCENT*target.components.burnable.flammability then
                    target.components.burnable:Ignite()
                end
            end
        end
    )
    
    -----------------------------------
    inst:AddComponent("lighter")
    -----------------------------------
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem:SetOnPickupFn(onpickup)
    -----------------------------------
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnPocket( function(owner) turnoff(inst)  end)
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )

    inst.components.equippable.boatandcharacterequip = true
    inst.components.equippable.boatequipslot = BOATEQUIPSLOTS.BOAT_LAMP
    inst.components.equippable.togglable = true
    inst.components.equippable.toggledonfn = toggleon
    inst.components.equippable.toggledofffn = toggleoff
    inst.components.equippable.cantoggleonfn = cantoggleon

    inst.equippedby = nil

    -----------------------------------
    inst:AddComponent("inspectable")
    -----------------------------------
    
    inst:AddComponent("heater")
    inst.components.heater.equippedheat = 5
    -----------------------------------
    inst:AddComponent("machine")
    inst.components.machine.turnonfn = turnon
    inst.components.machine.turnofffn = turnoff
    inst.components.machine.cooldowntime = 0
    inst.components.machine.caninteractfn = function() return not inst.components.fueled:IsEmpty() and (inst.components.inventoryitem.owner == nil or inst.components.equippable.isequipped) end
    inst.components.machine.noswitchanim = true

    inst:AddComponent("burnable")
    inst.components.burnable.canlight = false
    inst.components.burnable.fxprefab = nil

    inst:AddComponent("fueled")
    inst.components.fueled:SetUpdateFn( onfueledupdate )
    inst.components.fueled:SetSectionCallback(
        function(section)
            if section == 0 then

                depleted(inst)
                turnoff(inst) 
                local owner = inst.components.inventoryitem.owner                                
                if owner then
                    owner:PushEvent("torchranout", {torch = inst})
                end
                inst:Remove()                
            end
        end)
    inst.components.fueled:InitializeFuelLevel(TUNING.TORCH_FUEL)

    inst.entity:AddLight()
    inst.Light:SetIntensity(.75)
    inst.Light:SetColour(197/255,197/255,50/255)
    inst.Light:SetFalloff( 0.5 )
    inst.Light:SetRadius( 2 )
    inst.Light:Enable(false)

    inst:ListenForEvent( "startrowing", function(inst,data) 
        --print("start rowing!!")
        onunequip(inst, data.owner)
        end, inst)  

    inst:ListenForEvent( "stoprowing", function(inst, data) 
        onequip(inst, data.owner, true, true)
        end, inst) 

    inst.turnon = turnon
    inst.turnoff = turnoff

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    inst.OnRemoveEntity = onRemove
    -- primes the torch so that when it's crafted it's like like other light sources
    inst.wason = true
    
    
    -----------------------------------
    return inst
end

return Prefab( "common/tarlamp", fn, assets, prefabs) 
