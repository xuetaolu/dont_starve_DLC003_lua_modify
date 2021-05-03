-- stickable as in getting poked by a stick

local Stickable = Class(function(self, inst)
	self.inst = inst
	self.canbesticked = true
	self.hasbeensticked = nil
	self.onpoked = nil
end)

function Stickable:CanBeSticked()
    return self.canbesticked
end

function Stickable:SetOnPokeCallback(onpoked)
	self.onpoked = onpoked
end

function Stickable:Stuck()
	self.canbesticked = nil
	self.hasbeensticked = true
end

function Stickable:UnStuck()
	self.canbesticked = true
	self.hasbeensticked = nil
end

function Stickable:PokedBy(worker, stick)
	if self.onpoked then
		self.onpoked(self.inst, worker, stick)
	end
	self:Stuck()
end

function Stickable:OnSave()
	local data = {}

	data.canbesticked = self.canbesticked
	data.hasbeensticked = self.hasbeensticked
	
	if next(data) then
		return data
	end
end

function Stickable:OnLoad(data)
	self.canbesticked = data.canbesticked
	self.hasbeensticked = data.hasbeensticked
end

return Stickable
