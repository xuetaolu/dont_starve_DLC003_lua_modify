local easing = require("easing")

local Circler = Class(function(self, inst)

    self.inst = inst

	self.scale = 1
	self.speed = math.random(1, 3) 	
	self.circleTarget = nil

	self.minSpeed = 5
	self.maxSpeed = 7

	self.minDist = 8
	self.maxDist = 20

	self.minScale = 8
	self.maxScale = 12

	self.onaccelerate = nil
	self.numAccelerates = 0

	self.sineMod = math.random(20, 30) * 0.001
	self.sine = 0
end)

function Circler:Start()
	if not self.circleTarget then
		return
	end

	self.speed = math.random(self.minSpeed, self.maxSpeed) * 0.01
	self.distance = math.random(self.minDist, self.maxDist)
	self.angleRad = math.random() * 2 * PI
	self.offset = Vector3(self.distance * math.cos(self.angleRad), 0, -self.distance * math.sin(self.angleRad))
	self.facingAngle = (self.angleRad*180/PI)

	local tarPos = self.circleTarget:GetPosition()
	local pos = tarPos + self.offset

	self.direction = math.random() > 0.5 and (PI/2) or -(PI/2)
	self.facingAngle = math.atan2(pos.x - tarPos.x, pos.z - tarPos.z)
	self.facingAngle = (self.facingAngle + self.direction) * 180/PI

	if not self.track then
		self.inst.Transform:SetRotation(self.facingAngle)
		self.inst.Transform:SetPosition(pos:Get())
	end
	self.inst:StartUpdatingComponent(self)

end

function Circler:Stop()
	self.inst:StopUpdatingComponent(self)
end

function Circler:SetCircleTarget(tar)
	self.circleTarget = tar

end

function Circler:GetSpeed(dt)
	local speed = (self.speed * (2*PI)) * dt

	if self.direction > 0 then
		speed = speed * -1
	end

	return speed
end

function Circler:GetMinSpeed()
	return self.minSpeed * 0.01
end

function  Circler:GetMaxSpeed()
	return self.maxSpeed * 0.01
end

function Circler:GetMinScale()
	return self.minScale * 0.1
end

function  Circler:GetMaxScale()
	return self.maxScale * 0.1
end

function Circler:GetDebugString()
	return string.format("Sine: %4.4f, Speed: %3.3f/%3.3f", self.sine, self.speed, self:GetMaxSpeed())
end

local easing = require("easing")

function Circler:OnUpdate(dt)
	
	if not self.circleTarget or (self.dontfollowinterior and TheCamera.interior) then 
		self:Stop()
		return
	end

	self.sine = GetSineVal(self.sineMod, true, self.inst)

	self.speed = easing.inExpo(self.sine, self:GetMinSpeed(), self:GetMaxSpeed() - self:GetMinSpeed() , 1)

	self.speed = Lerp(self:GetMinSpeed() - 0.003, self:GetMaxSpeed() + 0.003, self.sine)

	self.speed = math.clamp(self.speed, self:GetMinSpeed(), self:GetMaxSpeed())	

	self.scale = Lerp(self:GetMaxScale(), self:GetMinScale(), (self.speed - self:GetMinSpeed())/(self:GetMaxSpeed() - self:GetMinSpeed()))
	self.inst.Transform:SetScale(self.scale, self.scale, self.scale)

	self.angleRad = self.angleRad + self:GetSpeed(dt)

	self.offset = Vector3(self.distance * math.cos(self.angleRad), 0, -self.distance * math.sin(self.angleRad))
	
	local tarPos = self.circleTarget:GetPosition()
	local pos = tarPos + self.offset

	self.facingAngle = math.atan2(pos.x - tarPos.x, pos.z - tarPos.z)
	self.facingAngle = (self.facingAngle + self.direction) * 180/PI
--[[
	if self.track then	

		local destpos = pos
		local mypos = Point(self.inst.Transform:GetWorldPosition())
		if destpos and mypos then
			if distsq(destpos, mypos) >= 0.15 then	--if you're almost at your target just stop.
				self.inst.components.locomotor:GoToPoint(destpos)
				self.inst.components.locomotor:WalkForward()

				local angle = self.inst:GetAngleToPoint(pos.x, pos.y, pos.z)
				self.inst.Transform:SetRotation( angle )
			else
				print(self.facingAngle)
				self.inst.Transform:SetRotation(self.facingAngle)
			--	self.inst.Transform:SetPosition(pos:Get())
			end
		end

	else]]
		self.inst.Transform:SetRotation(self.facingAngle)
		self.inst.Transform:SetPosition(pos:Get())
	--end
end

function Circler:OnEntitySleep()
	self:Stop()
end

function Circler:OnEntityWake()
	self:Start()
end

return Circler