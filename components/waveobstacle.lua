local WaveObstacle = Class(function(self, inst)
    self.inst = inst
    self.oncollidefn = nil
    self.ondestroyfn = nil
    self.destroychance = 0.01
end)

function WaveObstacle:OnCollide(wave)
	if self.oncollidefn then
		self.oncollidefn(self.inst, wave)
	end
	if self.ondestroyfn and math.random() < self.destroychance then
		self.ondestroyfn(self.inst)
	end
end

function WaveObstacle:SetOnCollideFn(fn)
	self.oncollidefn = fn
end

function WaveObstacle:SetOnDestroyFn(fn)
	self.ondestroyfn = fn
end

function WaveObstacle:SetDestroyChance(chance)
	self.destroychance = chance
end


function WaveObstacle:GetDebugString()
    return "wave obstacle"
end



return WaveObstacle