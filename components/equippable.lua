local Equippable = Class(function(self, inst)
    self.inst = inst
    self.isequipped = false
    self.equipslot = EQUIPSLOTS.HANDS
    self.boatequipslot = nil 
    self.onequipfn = nil
    self.onunequipfn = nil
    self.onpocketfn = nil
    self.equipstack = false
    self.dapperness = 0
    self.dapperfn = nil
    self.insulated = false
    self.equippedmoisture = 0
    self.maxequippedmoisture = 0
    self.togglable = false 
    self.toggledon = false 
    self.toggledonfn = nil 
    self.toggledofffn = nil 
    self.cantoggleonfn = nil 
    self.cantoggleofffn = nil
    self.equipper = nil
end)

function Equippable:IsInsulated() -- from electricity, not temperature
    return self.insulated
end

function Equippable:SetOnEquip(fn)
    self.onequipfn = fn
end

function Equippable:SetOnPocket(fn)
    self.onpocketfn = fn
end

function Equippable:SetOnUnequip(fn)
    self.onunequipfn = fn
end

function Equippable:IsEquipped()
    return self.isequipped
end

function Equippable:Equip(owner, slot)
    slot = slot or self.equipslot
    self.isequipped = true
    self.equipper = owner
    
    if self.inst.components.burnable then
        self.inst.components.burnable:StopSmoldering()
    end

    if self.walkspeedmult and owner.components.locomotor and slot then
        --Note: sail speed bonuses are handled in the sail file.
        owner.components.locomotor:AddSpeedModifier_Mult("equipslot_"..slot, self.walkspeedmult)
    end

    if self.onequipfn then
        self.onequipfn(self.inst, owner, self.swapbuildoverride)
    end

    self.inst:PushEvent("equipped", {owner=owner, slot=slot})
    self.owner = owner
end

function Equippable:ToPocket(owner)
    if self.onpocketfn then
        self.onpocketfn(self.inst, owner)
    end
end

function Equippable:Unequip(owner, slot)
    slot = slot or self.equipslot
    self.isequipped = false
    
    if self.walkspeedmult and owner.components.locomotor and slot then
        owner.components.locomotor:RemoveSpeedModifier_Mult("equipslot_"..slot)
    end

    if self.onunequipfn then
        self.onunequipfn(self.inst, owner)
    end
    
    self.equipper = nil

    self.inst:PushEvent("unequipped", {owner=owner, slot=slot})
    self.owner = nil
end

-- function Equippable:GetWalkSpeedMult()
-- 	return self.walkspeedmult or 1.0
-- end

-- function Equippable:GetBoatSpeedMult()
--     return self.boatspeedmult or 1.0
-- end

function Equippable:IsPoisonBlocker()
    return self.poisonblocker or false
end

function Equippable:IsPoisonGasBlocker()
    return self.poisongasblocker or false
end

function Equippable:CollectInventoryActions(doer, actions)
    local canEquip = true 
    if self.boatequipslot and not self.boatandcharacterequip then --Can only be equipped on a boat 
        canEquip = false
    
        if doer.components.driver and doer.components.driver.vehicle and doer.components.driver.vehicle.components.container.hasboatequipslots
        and doer.components.driver.vehicle.components.container.enableboatequipslots then 
            canEquip = true 
        end 
    end 
    
    if not self:IsEquipped() and canEquip then
        table.insert(actions, ACTIONS.EQUIP)
    else
        if self.togglable and self:CanToggle() then 
            if self:IsToggledOn() then 
                table.insert(actions, ACTIONS.TOGGLEOFF)
            else 
                table.insert(actions, ACTIONS.TOGGLEON)
            end
        elseif self:IsEquipped() and not self.un_unequipable then
            table.insert(actions, ACTIONS.UNEQUIP)
        end 
    end
end

function Equippable:GetDapperness(owner)
    local dapperness = self.dapperness
    
    if self.dapperfn then
        dapperness = self.dapperfn(self.inst, owner)
    end

    local mm = GetWorld().components.moisturemanager
    
    if mm and mm:IsEntityWet(self.inst) then
        dapperness = dapperness + TUNING.WET_ITEM_DAPPERNESS
    end

    return dapperness
end

function Equippable:GetEquippedMoisture()
    return {moisture = self.equippedmoisture, max = self.maxequippedmoisture}
end

function Equippable:ToggleOn()
    self.toggledon = true 
    if self.toggledonfn then 
        self.toggledonfn(self.inst)        
    end 
    self.inst:PushEvent("turnedon")
end

function Equippable:ToggleOff()
    self.toggledon = false 
    if self.toggledofffn then 
        self.toggledofffn(self.inst)
    end     
    self.inst:PushEvent("turnedoff")
end  

function Equippable:IsToggledOn()    
    return self.toggledon 
end 

function Equippable:CanToggle()
    local canToggle = true 
    if self.toggledon and self.cantoggleofffn then 
        canToggle = self.cantoggleofffn(self.inst)
    elseif not self.toggledon and self.cantoggleonfn then 
        canToggle = self.cantoggleonfn(self.inst)
    end 
    return self.togglable and canToggle
end 

function Equippable:OnSave()
    local data = {}
    data.togglable = self.togglable
    data.toggledon = self.toggledon
    return data
end   


function Equippable:LoadPostPass(ents, data)
    if data and data.togglable then 
        self.togglable = data.togglable
        self.toggledon = data.toggledon
        if self.toggledon then 
            self:ToggleOn()
        else
            self:ToggleOff()
        end 

    end 
end   


return Equippable