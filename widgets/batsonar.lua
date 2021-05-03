local Widget = require "widgets/widget"
local UIAnim = require "widgets/uianim"

local BatSonar = Class(Widget, function(self, owner)
    self.owner = owner
    Widget._ctor(self, "BatSonar")
    self:SetClickable(false)

    self.bg2 = self:AddChild(Image("images/fx5.xml", "fog_over.tex"))
    self.bg2:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg2:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg2:SetVAnchor(ANCHOR_MIDDLE)
    self.bg2:SetHAnchor(ANCHOR_MIDDLE)
    self.bg2:SetScaleMode(SCALEMODE_FILLSCREEN)

    self.alpha = 0
    self.alphagoal = 0
    self.transitiontime = 2.0
    self.transitiontimeIN = 0.2
    self.transitiontimeOUT = 5
    self.transitiontimeREST = 1    
    self.time = self.transitiontimeIN
    self.currentstate = "out"
    self:Hide()
end)

function BatSonar:StartSonar()
    print("START")
    if not self.active then
    self.time = self.transitiontimeIN
        self.alphagoal = 1
        self.active = true
        self:StartUpdating()
        self:Show()
    end
end


function BatSonar:SetSonar(off)
    if off and self.active then
            self.time = 0
            self.alphagoal = 0
            self.active = false
            self.alpha = 0
            self:StopUpdating()
            self:Hide()
    else
        if not self.active then
            self.time = 0
            self.alphagoal = 1
            self.active = true
            self.alpha = 1
            self:StartUpdating()
            self:Show()
        end
    end
end

function BatSonar:StopSonar()
    if self.active then
        self.time = self.transitiontime
        self.alphagoal = 0
        self.active = false
        self:StopUpdating()
        self:Hide()
    end
end

function BatSonar:UpdateAlpha(dt)

    if self.time > 0 then
        self.time = math.max(0, self.time - dt)
    else
        if self.currentstate == "out" then


            GetPlayer().SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/batmask/sonar")
            local ring = SpawnPrefab("groundpoundring_fx")
            ring.Transform:SetScale(2,2,2)
            ring.Transform:SetPosition(GetPlayer().Transform:GetWorldPosition())    
            
            GetPlayer():DoTaskInTime(0.1, function()
                    if self.active then
                        local ring2 = SpawnPrefab("groundpoundring_fx")
                        ring2.Transform:SetScale(2,2,2)
                        ring2.Transform:SetPosition(GetPlayer().Transform:GetWorldPosition())
                    end
                end)

            self.currentstate = "in"
            self.alphagoal = 0
            self.time = self.transitiontimeIN
        elseif self.currentstate == "in" then
            self.currentstate = "out"
            self.alphagoal = 1
            self.time = self.transitiontimeOUT
        end                
    end

    local mapping = 0
    if self.currentstate == "out" then
        mapping = Remap(self.time, self.transitiontimeOUT, 0, 0, 1)
    else
        mapping = Remap(self.time, self.transitiontimeIN, 0, 1, 0)
    end
    self.alpha = mapping --math.sin(PI * mapping)
   -- if self.alpha > self.alphagoal then
    --    self.alpha = 0.0
    -- end
end

function BatSonar:OnUpdate(dt)
    if not IsPaused() then
        local equippeditem = GetPlayer().components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
        local wearingbathat = equippeditem and (equippeditem.prefab == "bathat")

        if wearingbathat then
            self:UpdateAlpha(dt)
        end

        local color = GetClock().currentColour
        local x = math.min(color.x * 1.5, 1)
        local y = math.min(color.y * 1.5, 1)
        local z = math.min(color.z * 1.5, 1)

        self.bg2:SetTint(0, 0, 0, self.alpha)
    end
end

return BatSonar
