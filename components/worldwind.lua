local easing = require("easing")

local MIN_TIME_TO_WIND_CHANGE = 16*TUNING.SEG_TIME
local MAX_TIME_TO_WIND_CHANGE = 16*TUNING.SEG_TIME

local WorldWind = Class(function(self, inst)

    self.inst = inst

	self.velocity = 1

	self.angle = math.random(0,360)

	self.timeToWindChange = 1

	self.windfx_spawn_rate = 0
	self.windfx_spawn_pre_sec = 16

	self.inst:StartUpdatingComponent(self)
end)

function WorldWind:Start()
	self.inst:StartUpdatingComponent(self)
end

function WorldWind:Stop()
	self.inst:StopUpdatingComponent(self)
end

function WorldWind:OnSave()
	return
	{
		angle = self.angle,
		timeToWindChange = self.timeToWindChange
	}
end

function WorldWind:OnLoad(data)
	if data then
		self.angle = data.angle or self.angle
		self.timeToWindChange = data.timeToWindChange or self.timeToWindChange
	end
end

function WorldWind:SetOverrideAngle(angle)
	self.overrideangle = angle
end

function WorldWind:GetWindAngle()
	return self.overrideangle or self.angle
end

function  WorldWind:GetWindVelocity()
	return self.velocity
end

function WorldWind:GetDebugString()
	return string.format("Angle: %4.4f, Veloc: %3.3f", self.angle, self.velocity)
end

function WorldWind:SpawnWindSwirl(x, y, z, speed, angle)
	local swirl = SpawnPrefab("windswirl")
	swirl.Transform:SetPosition(x, y, z)
	swirl.Transform:SetRotation(angle + 180)
	swirl.AnimState:SetMultColour(1, 1, 1, math.clamp(speed, 0.0, 1.0))
	--swirl.Physics:SetMotorVel(speed, 0, 0)
end

function WorldWind:OnUpdate(dt)
	if not self.inst then 
		self:Stop()
		return
	end

	self.timeToWindChange = self.timeToWindChange - dt

	if self.timeToWindChange <= 0 then
		self.angle = math.random(0,360)
		self.inst:PushEvent("windchange", {angle=self.angle, velocity=self.velocity})

		self.timeToWindChange = math.random(MIN_TIME_TO_WIND_CHANGE, MAX_TIME_TO_WIND_CHANGE)
	end

	local sm = GetSeasonManager()
	local windspeed = sm:GetHurricaneWindSpeed()
	if windspeed > 0.01 and (sm:IsHurricaneStorm() or (sm.IsWindy and sm:IsWindy()) ) then
		self.windfx_spawn_rate = self.windfx_spawn_rate + self.windfx_spawn_pre_sec * dt
		--print(string.format("wind %f, %4.2f, %4.f", sm:GetHurricaneWindSpeed(), self.windfx_spawn_rate, self:GetWindAngle()))
		if self.windfx_spawn_rate > 1.0 then
			local px, py, pz = GetPlayer().Transform:GetWorldPosition()
			local dx, dz = 16 * UnitRand(), 16 * UnitRand()
			local x, y, z = px + dx, py, pz + dz
			local angle = self:GetWindAngle()

			self:SpawnWindSwirl(x, y, z, windspeed, angle)
			self.windfx_spawn_rate = self.windfx_spawn_rate - 1.0
		end
	end
end

return WorldWind