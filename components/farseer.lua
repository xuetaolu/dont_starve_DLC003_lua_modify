local FarSeer = Class(function(self, inst)
	self.inst = inst
	self.adders = {base = 1}
	self.multipliers = {base = 1}
	self.totalbonus = 1
	
end)

function FarSeer:ReCalculateBonus()

	local addtotal = 0
	local multotal = 1
	for k, v in pairs(self.adders) do
		-- print(k, v)
		addtotal = addtotal + v
	end
	for k, v in pairs(self.multipliers) do
		multotal = multotal * v
	end
	local total = addtotal * multotal
	-- print("FarSeer bonus", total)
	GetWorld().minimap.MiniMap:SetRevealRadiusMultiplier(total)
	
	self.totalbonus = total
end

function FarSeer:GetTotalBonus()
	return self.totalbonus
end

function FarSeer:AddBonus(label, addbonus, mulbonus)
	self.adders[label] = addbonus-1
	self.multipliers[label] = mulbonus or 1
	self:ReCalculateBonus()
end

function FarSeer:RemoveBonus(label)
	self.adders[label] = nil
	self.multipliers[label] = nil
	self:ReCalculateBonus()
end

function FarSeer:OnSave()
	return  { adders = self.adders, multipliers = self.multipliers }
end

function FarSeer:OnLoad(data)
	if data.adders then
		self.adders = data.adders
	end
	if data.multipliers then
		self.multipliers = data.multipliers
	end
end

function FarSeer:GetDebugString()
	return string.format("totalbonus: %f", self.totalbonus)
end


return FarSeer
