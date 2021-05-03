local WindProofer = Class(function(self, inst)
	self.inst = inst
	self.effectiveness = 1
end)

function WindProofer:GetEffectiveness()
	return self.effectiveness
end

function WindProofer:SetEffectiveness(val)
	self.effectiveness = val
end

return WindProofer