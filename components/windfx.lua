local WindFx = Class(function(self, inst)
	self.inst = inst
	self.inst:StartUpdatingComponent(self)
end)

function WindFx:OnUpdate(dt)
	local speed = math.clamp(GetSeasonManager():GetHurricaneWindSpeed(), 0.0, 1.0)
	self.inst.AnimState:SetMultColour(1, 1, 1, speed)
	if speed < 0.01 then
		self.inst:Remove()
	end
end

return WindFx