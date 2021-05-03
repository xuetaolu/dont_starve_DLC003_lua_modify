local Autofixer = Class(function(self, inst)
	self.inst = inst
	self.turnonfn = nil
	self.turnofffn = nil
	self.on = false
	self.caninteractfn = nil
	self.users={}
	self.locked = false
end)

function Autofixer:OnSave()
	local data = {}	
	data.on = self.on
	data.locked = self.locked
	return data
end

function Autofixer:OnLoad(data)
	if data then
		self.on = data.on
		self.locked = data.locked
		if self:IsOn() then self:TurnOn() else self:TurnOff() end
	end
end

function Autofixer:TurnOn(user)	
	if not self.locked and not self.on and (not self.inst.components.fueled or not self.inst.components.fueled:IsEmpty() )  then
		self.on = true
		if self.startFixingFn then
			self.startFixingFn(self.inst,user)
			table.insert(self.users,user)
		end

		if self.onturnon then
			self.onturnon(self.inst)
		end
		
	end
end

function Autofixer:CanInteract()
	if self.caninteractfn then
		return self.caninteractfn(self.inst)
	else
		return true
	end
end

function Autofixer:TurnOff()
	if self.on then
		self.on = false
		if self.stopFixingFn then
			for i,user in ipairs(self.users)do
				self.stopFixingFn(self.inst,user)
			end
			self.users = {}
		end

		if self.onturnoff then
			self.onturnoff(self.inst)
		end
		
	end
end

function Autofixer:IsOn()
	return self.on
end

function Autofixer:CollectSceneActions(doer, actions, right)
	if right and not self.oncooldown and self:CanInteract() then
		if not self.auto_on_off then
			if self:IsOn() then
				table.insert(actions, ACTIONS.TURNOFF)
			else
				table.insert(actions, ACTIONS.TURNON)
			end	
		end		

	end
end

function Autofixer:CollectInventoryActions(doer, actions, right)
	if right and not self.oncooldown and self:CanInteract() then
		if not self.auto_on_off then
			if self:IsOn() then
				table.insert(actions, ACTIONS.TURNOFF)
			else
				table.insert(actions, ACTIONS.TURNON)
			end	
		end		
	end
end
return Autofixer