local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"

local HealthBadge = Class(Badge, function(self, owner)
	Badge._ctor(self, "health", owner)

	self.sanityarrow = self.underNumber:AddChild(UIAnim())
	self.sanityarrow:GetAnimState():SetBank("sanity_arrow")
	self.sanityarrow:GetAnimState():SetBuild("sanity_arrow")
	self.sanityarrow:GetAnimState():PlayAnimation("neutral")
	self.sanityarrow:SetClickable(false)
	
	self.topperanim = self.underNumber:AddChild(UIAnim())
	self.topperanim:GetAnimState():SetBank("effigy_topper")
	self.topperanim:GetAnimState():SetBuild("effigy_topper")
	self.topperanim:GetAnimState():PlayAnimation("anim")
	self.topperanim:SetClickable(false)

	self.poisonanim = self.underNumber:AddChild(UIAnim())
    self.poisonanim:GetAnimState():SetBank("poison")
    self.poisonanim:GetAnimState():SetBuild("poison_meter_overlay")
    self.poisonanim:GetAnimState():PlayAnimation("deactivate")
    self.poisonanim:Hide()
    self.poisonanim:SetClickable(false)
	
	self:StartUpdating()
end)


function HealthBadge:SetPercent(val, max, penaltypercent)
	Badge.SetPercent(self, val, max)

	penaltypercent = penaltypercent or 0
	self.topperanim:GetAnimState():SetPercent("anim", penaltypercent)
end	

function HealthBadge:OnUpdate(dt)	
	local down = self.owner.components.temperature:IsOverheating() or self.owner.components.temperature:IsFreezing() or self.owner.components.hunger:IsStarving() or self.owner.components.health.takingfiredamage
	local poison = self.owner.components.poisonable:IsPoisoned()

	local anim = poison and "arrow_loop_decrease_more" or "neutral"
	anim = down and "arrow_loop_decrease_most" or anim

	if anim and self.arrowdir ~= anim then
		self.arrowdir = anim
		self.sanityarrow:GetAnimState():PlayAnimation(anim, true)
	end

	if self.poison ~= poison then
        self.poison = poison
        if poison then
            self.poisonanim:GetAnimState():PlayAnimation("activate")
            self.poisonanim:GetAnimState():PushAnimation("idle", true)
            self.poisonanim:Show()
        else
        	self.owner.SoundEmitter:PlaySound("dontstarve_DLC002/common/HUD_antivenom_use")
            self.poisonanim:GetAnimState():PlayAnimation("deactivate")
        end
    end
	
end

return HealthBadge