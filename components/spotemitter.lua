local SpotEmitter = Class(function(self, inst)
	self.inst = inst
	self.ents = {}
	self.maxents = 100
	self.onempty = nil
	self.onupdate = nil
end)

function SpotEmitter:OnEntitySleep()
	self:Stop()
end

function SpotEmitter:OnEntityWake()
	if self.onupdate then
		self:Start()
	end
end

function SpotEmitter:Start()
	self.inst:StartUpdatingComponent(self)
end

function SpotEmitter:Stop()
	self.inst:StopUpdatingComponent(self)
end

function SpotEmitter:OnUpdate(dt)
	if self.onupdate then
		self.onupdate(self.inst, dt)
	else
		self:Stop()
	end
end

function SpotEmitter:UpdatePos()
	local hx, hy, hz = 0, 0, 0
	local ents = 0
	for k,v in pairs(self.ents) do
		if v then
			local wx, wy, wz = v.Transform:GetWorldPosition()
			hx, hy, hz = hx + wx, hy + wy, hz + wz
			ents = ents + 1
		end
	end

	if ents > 0 then
		self.inst.Transform:SetPosition(hx / ents, hy / ents, hz / ents)
	end
end


function SpotEmitter:OnEntityRemoved(ent)
	ent.spotemitter = nil 
	ent:RemoveEventCallback("onremove",  ent.spotemitteronremovecallback)
end 

function SpotEmitter:Add(ent)
	if not self:IsFull() then
		--print("join emitter")
		ent.spotemitter = self
		
		ent.spotemitteronremovecallback = function(inst) 
			if inst.spotemitter then  
				inst.spotemitter:Remove(inst) 
			end  
		end 
		
		ent:ListenForEvent("onremove", ent.spotemitteronremovecallback)

		self.ents[ent.GUID] = ent
		self:UpdatePos()
	end
end

function SpotEmitter:Remove(ent)
	if self.ents[ent.GUID] then
		--print("leave emitter")
		self:OnEntityRemoved(self.ents[ent.GUID])
		self.ents[ent.GUID] = nil
		if self.onempty and GetTableSize(self.ents) == 0 then
			self.onempty(self.inst)
		else
			self:UpdatePos()
		end
	end
end

function SpotEmitter:RemoveAll()
	for k,v in pairs(self.ents) do
		--v.spotemitter = nil
		self:OnEntityRemoved(v)
	end
	self.ents = {}
end

function SpotEmitter:SetMax(max)
	self.maxents = max or 100
end

function SpotEmitter:SetOnUpdateFn(fn)
	self.onupdate = fn
end

function SpotEmitter:SetOnEmptyFn(fn)
	self.onempty = fn
end

function SpotEmitter:IsFull()
	return GetTableSize(self.ents) >= self.maxents
end

return SpotEmitter