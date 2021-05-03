local ItemSlot = require "widgets/itemslot"

local BoatEquipSlot = Class(ItemSlot, function(self, equipslot, atlas, bgim, owner)
    ItemSlot._ctor(self, atlas, bgim, owner)
    self.owner = owner
    self.equipslot = equipslot
    self.highlight = false

    self.inst:ListenForEvent("newactiveitem", function(inst, data)
        if data.item and data.item.components.equippable and data.item.components.equippable.boatequipslot and data.item.components.equippable.boatequipslot == self.equipslot then
            self:ScaleTo(1, 1.3, .125)
            self.highlight = true
        elseif self.highlight then
            self.highlight = false
            self:ScaleTo(1.3, 1, .125)
        end
    end, self.owner)
end)

function BoatEquipSlot:Click()
    self:OnControl(CONTROL_ACCEPT, true)
end

function BoatEquipSlot:OnControl(control, down)
    if down then
        if control == CONTROL_ACCEPT then

            local active_item = GetPlayer().components.inventory:GetActiveItem()
            if active_item and active_item.components.equippable and active_item.components.equippable.boatequipslot == self.equipslot then
               -- GetPlayer().components.inventory:Equip(active_item, true)
                self.parent.container.components.container:Equip(active_item, true)
                GetPlayer().SoundEmitter:PlaySound("dontstarve/wilson/equip_item")
            elseif self.tile and not active_item then
                --self.owner.components.inventory:SelectActiveItemFromEquipSlot(self.equipslot)
                local item = self.parent.container.components.container:Unequip(self.equipslot)
                self.owner.components.inventory:GiveActiveItem(item)
            end

            return true
        elseif control == CONTROL_SECONDARY and self.tile and self.tile.item then
            GetPlayer().components.inventory:UseItemFromInvTile(self.tile.item)
            return true
        end
    end
end

return BoatEquipSlot