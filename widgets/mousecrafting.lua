require "class"

local TileBG = require "widgets/tilebg"
local InventorySlot = require "widgets/invslot"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local TabGroup = require "widgets/tabgroup"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local CraftSlot = require "widgets/craftslot"
local Crafting = require "widgets/crafting"

require "widgets/widgetutil"

--local MouseCrafting = Class(Crafting, function(self, level)
local MouseCrafting = Class(Crafting, function(self, level)
    Crafting._ctor(self, 7)
    level = level or 0
    self.level = level
    self:SetOrientation(false)
    local w = 145
    self.in_pos  = Vector3((level+1)*145, 0, 0)
    self.out_pos = Vector3((level+0)*145, 0, 0)
    self.craftslots:EnablePopups()
end)

return MouseCrafting