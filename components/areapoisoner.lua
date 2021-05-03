local function DefaultPoisonAttackFn(inst, target)
	if target.components.poisonable then
		target.components.poisonable:Poison(true)
	end
end

local AreaPoisoner = Class(function(self, inst)
	self.inst = inst
	
	self.poisonrange = 0
	self.duration = 0
	self.onpoisonattackfn = DefaultPoisonAttackFn

	self.spreading = false
end)

--function AreaPoisoner:GetDebugString()
	--return string.format("%s", self.spreading and "SPREADING" or "NOT SPREADING")
--end

function AreaPoisoner:StartSpreading(duration)
	self.duration = duration or 0
	self.spreading = true
	if self.duration > 0 then
		self.start_time = GetTime()
	end
	
	self:DoPoison()
	if not self.task then
		self.task = self.inst:DoPeriodicTask(TUNING.AREA_POISONER_CHECK_INTERVAL, function() self:DoPoison() end)
	end
end

function AreaPoisoner:StopSpreading()
	self.spreading = false
	self.start_time = nil
	
	if self.task then
		self.task:Cancel()
		self.task = nil
	end
end

function AreaPoisoner:SetOnPoisonAttackFn(onpoisonattackfn)
	self.onpoisonattackfn = onpoisonattackfn
end

function AreaPoisoner:DoPoison(oneoff)
	if self.duration > 0 and GetTime() - self.start_time > self.duration then
		self:StopSpreading()
		return
	end

	if (self.spreading or oneoff) and self.poisonrange > 0 then
		-- in here we are targeting other entities and damaging them
		local pos = Vector3(self.inst.Transform:GetWorldPosition())
		local prop_range = self.poisonrange
		local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, prop_range, {"poisonable"})
		
		for k,v in pairs(ents) do
			if not v:IsInLimbo() then
				if v ~= self.inst and v.components.poisonable then
					if self.onpoisonattackfn then
						self.onpoisonattackfn(self.inst, v)
					end
				end
			end
		end
	end
end

function AreaPoisoner:OnSave()    
	return 
	{
		timeleft = self.start_time and self.duration - (GetTime() - self.start_time) or nil,
	}
end

function AreaPoisoner:OnLoad(data)
	if data.timeleft then
		self:StartSpreading(data.timeleft)
	end
end

return AreaPoisoner
