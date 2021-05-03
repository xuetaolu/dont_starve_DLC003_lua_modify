
local Mateable = Class(function(self, inst)
	self.inst = inst
	self.onmate = nil
	self.partnerGUID = nil
end)

function Mateable:OnSave()
	return 
	{
		partnerGUID = self.partnerGUID,
	}
end

function Mateable:OnLoad(data)
	self.partnerGUID = data.partnerGUID
	if self.partnerGUID then
		local world = GetWorld()
		if world and world.components.doydoyspawner then
			world.components.doydoyspawner:RequestMate(self.inst)
		end
	end
end

function Mateable:SetOnMateCallback(onmate)
	self.onmate = onmate
end

function Mateable:SetPartner(partner, partnerismommy)
	self.partnerGUID = partner.GUID

	if partnerismommy then
		self.inst:AddTag("daddy")
		self.inst:RemoveTag("mommy")
	else
		self.inst:AddTag("mommy")
		self.inst:RemoveTag("daddy")
	end

	self.inst:AddTag("mating")
end

function Mateable:RemovePartner()

	if self.inst:HasTag("daddy") then
		self.inst:RemoveTag("daddy")

		local mommy = self:GetPartner()

		if mommy then
			mommy.components.mateable:RemovePartner()
		end

	else
		self.inst:RemoveTag("mommy")
	end
	
	self.inst:RemoveTag("mating")
	self.partnerGUID = nil
end

function Mateable:GetPartner()
	return Ents[self.partnerGUID]
end


function Mateable:Mate()
	
	if self.onmate then
		self.onmate(self.inst, Ents[self.partnerGUID])
	end

	self:RemovePartner()
end

function Mateable:GetDebugString()
	return "Partner: "..tostring(self:GetPartner())..", "..tostring(self.partnerGUID)
end

return Mateable
