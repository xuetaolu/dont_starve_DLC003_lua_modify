local Badge = require "widgets/badge"
local UIAnim = require "widgets/uianim"

local BoatBadge = Class(Badge, function(self, owner)
	Badge._ctor(self, "boat_health", owner)

	self.boatarrow = self.underNumber:AddChild(UIAnim())
	self.boatarrow:GetAnimState():SetBank("sanity_arrow")
	self.boatarrow:GetAnimState():SetBuild("sanity_arrow")
	self.boatarrow:GetAnimState():PlayAnimation("neutral")
	self.boatarrow:SetClickable(false)

	self.num:SetSize(40)

	self:SetScale(1.3)
	
	self:StartUpdating()
end)

function BoatBadge:OnUpdate(dt)	
	-- local down = self.owner.components.temperature:IsOverheating() or self.owner.components.temperature:IsFreezing() or self.owner.components.hunger:IsStarving() or self.owner.components.health.takingfiredamage
	-- local poison = self.owner.components.poisonable:IsPoisoned()

	-- local anim = poison and "arrow_loop_decrease_more" or "neutral"
	-- anim = down and "arrow_loop_decrease_most" or anim

	local anim = "neutral"
	if anim and self.arrowdir ~= anim then
		self.arrowdir = anim
		self.boatarrow:GetAnimState():PlayAnimation(anim, true)
	end	
end

return BoatBadge