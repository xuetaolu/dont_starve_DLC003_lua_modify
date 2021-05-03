
local VolcanoMeter = Class(function(self, inst)
	self.inst = inst
	self.targetseg = 0
	self.curseg = 0
	self.maxseg = 1
	self.updatemeterfn = nil
	self.updatedonefn = nil
end)

function VolcanoMeter:GetDebugString()
	return string.format("VolcanoMeter cur %d, target %d, max %d, perc %4.2f", self.curseg, self.targetseg, self.maxseg, 1.0 - (self.curseg / self.maxseg))
end

function VolcanoMeter:Start()
	self.inst:StartUpdatingComponent(self)
end

function VolcanoMeter:Stop()
	self.inst:StopUpdatingComponent(self)
end

function VolcanoMeter:UpdateMeter()
	local perc = math.clamp(1.0 - (self.curseg / self.maxseg), 0.0, 1.0)
	if self.updatemeterfn then
		self.updatemeterfn(self.inst, perc)
	end
end

function VolcanoMeter:UpdateDone()
	if self.updatedonefn then
		self.updatedonefn(self.inst)
	end
	self:Stop()
end

function VolcanoMeter:OnUpdate(dt)
	local segs_per_sec = 2
	if self.curseg < self.targetseg then
		self.curseg = self.curseg + segs_per_sec * dt
		if self.curseg >= self.targetseg then
			self.curseg = self.targetseg
			self:UpdateDone()
		end
		self:UpdateMeter()
	elseif self.curseg > self.targetseg then
		self.curseg = self.curseg - segs_per_sec * dt
		if self.curseg <= self.targetseg then
			self.curseg = self.targetseg
			self:UpdateDone()
		end
		self:UpdateMeter()
	end
end

function VolcanoMeter:SetSeg(seg)
	self.targetseg = seg
	self:Start()
end

return VolcanoMeter