local Heater = Class(function(self, inst)
    self.inst = inst
    self.show_heat = false

    self.heat = 0
    self.maxheat = nil
    self.minheat = nil
    self.heatfn = nil

	self.equippedheat = 0
	self.maxequippedheat = nil
	self.minequippedheat = nil
	self.equippedheatfn = nil

	self.carriedheat = 0
	self.maxcarriedheat = nil
	self.mincarriedheat = nil
	self.carriedheatfn = nil

	self.iscooler = false
	self.inst.entity:AddTag("HASHEATER")
end)

function Heater:GetHeat(observer)
	local heat = self.heat
	
	if self.heatfn then
		heat = self.heatfn(self.inst, observer)
	end

	if self.minheat and self.maxheat then
		heat = math.clamp(heat, self.minheat, self.maxheat)
	end

	return heat
end

function Heater:GetEquippedHeat(observer)
	local heat = self.equippedheat
	
	if self.equippedheatfn then
		heat = self.equippedheatfn(self.inst, observer)
	end

	if self.minequippedheat and self.maxequippedheat then
		heat = math.clamp(heat, self.minequippedheat, self.maxequippedheat)
	end

	return heat
end

function Heater:GetCarriedHeat(observer)
	local heat = self.carriedheat

	if self.carriedheatfn then
		heat = self.carriedheatfn(self.inst, observer)
	end

	if self.mincarriedheat and self.maxcarriedheat then
		heat = math.clamp(heat, self.mincarriedheat, self.maxcarriedheat)
	end

	return heat
end

function Heater:GetDebugString()
	return string.format("Heat %2.2f, Equipped Heat %2.2f, Carried Heat %2.2f", self:GetHeat(GetPlayer()), self:GetEquippedHeat(GetPlayer()), self:GetCarriedHeat(GetPlayer()))
end

return Heater
