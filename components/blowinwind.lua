local easing = require("easing")

local SPEED_VAR_PERIOD = 5
local SPEED_VAR_PERIOD_VARIANCE = 2

local BlowInWind = Class(function(self, inst)

    self.inst = inst

	self.maxSpeedMult = 1.5
	self.minSpeedMult = .5
	self.averageSpeed = (TUNING.WILSON_RUN_SPEED + TUNING.WILSON_WALK_SPEED)/2
	self.speed = 0

	self.windAngle = 0
	self.windVector = Vector3(0,0,0)

	self.currentAngle = 0
	self.currentVector = Vector3(0,0,0)

	self.velocity = Vector3(0,0,0)

	self.speedVarTime = 0
	self.speedVarPeriod = GetRandomWithVariance(SPEED_VAR_PERIOD, SPEED_VAR_PERIOD_VARIANCE)

	self.soundParameter = nil
	self.soundName = nil

	self.spawnPeriod = 1.0
	self.timeSinceSpawn = self.spawnPeriod

	-- self.sineMod = math.random(20, 30) * 0.001
	-- self.sine = 0

	self.inst:ListenForEvent("hitland", function(it, data)
		self:Start()
	end)
	self.inst:ListenForEvent("ondropped", function(it, data)
		self:Start()
	end)
	self.inst:ListenForEvent("onpickup", function(it, data)
		self:Stop()
	end)
end)

function BlowInWind:OnRemoveEntity()
	self:Stop()
end

function BlowInWind:OnEntitySleep()
	self:Stop()
end

function BlowInWind:OnEntityWake()
	self:Start(self.windAngle, self.velocMult)
end

function BlowInWind:Start(ang, vel)
	if self.inst:HasTag("falling") or (self.inst.components.inventoryitem and self.inst.components.inventoryitem:IsHeld()) then
		return
	end

	if ang then
		self.windAngle = ang
		self.windVector = Vector3(math.cos(ang), 0, math.sin(ang)):GetNormalized()
		self.currentAngle = ang
		self.currentVector = Vector3(math.cos(ang), 0, math.sin(ang)):GetNormalized()
		self.inst.Transform:SetRotation(self.currentAngle)
	end
	if vel then self.velocMult = vel end
	if self.inst.SoundEmitter and self.soundPath and self.soundName then
		self.inst.SoundEmitter:PlaySound(self.soundPath, self.soundName)
	end
	self.inst:StartUpdatingComponent(self)

	self.checkLandTime = math.random()
end

function BlowInWind:Stop()
	self.velocity = Vector3(0,0,0)
	self.speed = 0.0
	self.inst.Physics:Stop()
	
	if self.inst.SoundEmitter and self.soundName then self.inst.SoundEmitter:KillSound(self.soundName) end
	self.inst:StopUpdatingComponent(self)
end

function BlowInWind:ChangeDirection(ang, vel)
	if ang then 
		self.windAngle = ang
		self.windVector = Vector3(math.cos(ang), 0, math.sin(ang)):GetNormalized()
	end
	--if vel then self.velocMult = vel end
end

function BlowInWind:SetMaxSpeedMult(spd)
	if spd then self.maxSpeedMult = spd end
end

function BlowInWind:SetMinSpeedMult(spd)
	if spd then self.minSpeedMult = spd end
end

function BlowInWind:SetAverageSpeed(spd)
	if spd then self.averageSpeed = spd end
end

function BlowInWind:GetSpeed()
	return self.speed
end

function  BlowInWind:GetVelocity()
	return self.velocity
end

--function BlowInWind:GetDebugString()
	--return string.format("Sine: %4.4f, Speed: %3.3f/%3.3f", self.sine, self.speed, self:GetMaxSpeed())
--end

function BlowInWind:SpawnWindTrail(dt)
    --if self.lastWake then  --Hacky way to fix the animation facing the wrong direction for one frame
        --self.lastWake:Show()
        --self.lastWake = nil 
    --end 

    self.timeSinceSpawn = self.timeSinceSpawn + dt
    if self.timeSinceSpawn > self.spawnPeriod and math.random() < 0.8 then 
        local wake = SpawnPrefab( "windtrail")
        local x, y, z = self.inst.Transform:GetWorldPosition()
        wake.Transform:SetPosition( x, y, z )
        wake.Transform:SetRotation(self.inst.Transform:GetRotation())
        --self.lastWake = wake
        --wake:Hide() --Hide for a frame, hacky fix 
        self.timeSinceSpawn = 0
    end
end

function BlowInWind:OnUpdate(dt)

	if not self.inst then 
		self:Stop()
		return
	end

	if self.inst:HasTag("falling") or (self.inst.components.inventoryitem and self.inst.components.inventoryitem:IsHeld()) then
		--self:Stop()
		return	
	end

	self.checkLandTime = self.checkLandTime - dt
	if self.checkLandTime < 0 then
		self.checkLandTime = 1 -- don't care about time accumulation
	    if self.inst.components.inventoryitem then
			self.inst.components.inventoryitem:OnHitGround(0)
		end
	end

	local sm = GetSeasonManager()
	if sm:IsHurricaneStorm() or (sm.IsWindy and sm:IsWindy()) then
		local windspeed = sm:GetHurricaneWindSpeed()
		local windangle = GetWorld().components.worldwind:GetWindAngle() * DEGREES
		self.velocity = Vector3(windspeed * math.cos(windangle), 0.0, windspeed * math.sin(windangle))
	else
		if not SaveGameIndex:IsModeShipwrecked() and not SaveGameIndex:IsModePorkland() then
			self.velocity = self.velocity + (self.windVector * dt)
		else
			self.velocity = Vector3(0,0,0)
			return
		end
	end

	-- unbait from traps
	if self.inst.components.bait and self.inst.components.bait.trap then
		self.inst.components.bait.trap:RemoveBait()
	end

	if self.velocity:Length() > 1 then
		self.velocity = self.velocity:GetNormalized()
	end

	-- Map velocity magnitudes to a useful range of walkspeeds
	local curr_speed = self.averageSpeed
	local player = GetPlayer()
	if player and player.components.locomotor then
		curr_speed = (player.components.locomotor:GetRunSpeed() + TUNING.WILSON_WALK_SPEED) / 2
	end
	self.speed = Remap(self.velocity:Length(), 0, 1, 0, curr_speed) --maybe only if changing dir??

	-- Do some variation on the speed if velocity is a reasonable amount
	if self.velocity:Length() >= .5 then
		self.speedVarTime = self.speedVarTime + dt
		if self.speedVarTime > SPEED_VAR_PERIOD then 
			self.speedVarTime = 0
			self.speedVarPeriod = GetRandomWithVariance(SPEED_VAR_PERIOD, SPEED_VAR_PERIOD_VARIANCE)
		end
		local speedvar = math.sin(2*PI*(self.speedVarTime / self.speedVarPeriod))
		local mult = Remap(speedvar, -1, 1, self.minSpeedMult, self.maxSpeedMult)
		self.speed = self.speed * mult
	end

	-- Change the sound parameter if there is one
	if self.soundName and self.soundParameter and self.inst.SoundEmitter then
		-- Might just be able to use self.velocity:Length() here?
		self.soundspeed = Remap(self.speed, 0, curr_speed*self.maxSpeedMult, 0, 1)
		self.inst.SoundEmitter:SetParameter(self.soundName, self.soundParameter, self.soundspeed)
	end

	-- Walk!	
	self.currentAngle = math.atan2(self.velocity.z, self.velocity.x)/DEGREES
	self.inst.Transform:SetRotation(self.currentAngle)

	self.inst.Physics:SetMotorVel(self.speed,0,0)


	if self.speed > 3.0 then
		self:SpawnWindTrail(dt)
	end

	if self.inst:GetIsOnWater() then
		if self.inst.components.burnable and self.inst.components.burnable:IsBurning() then
  			self.inst.components.burnable:Extinguish() --Do this before anything that required the inventory item component, it gets removed when something is lit on fire and re-added when it's extinguished 
  		end
		if self.inst.components.inventoryitem then
			self.inst.components.inventoryitem:OnHitWater()
		end
		if self.inst.components.floatable ~= nil then
			local vx, vy, vz = self.inst.Physics:GetMotorVel()
			self.inst.Physics:SetMotorVel(0.5 * vx, 0, 0)
			self.inst:DoTaskInTime(1.0, function(inst)
				self.inst.Physics:SetMotorVel(0, 0, 0)
				if self.inst.components.inventoryitem then 
					self.inst.components.inventoryitem:OnHitWater()
				end
			end)
		end
		
	elseif self.inst:GetIsOnTileType(GROUND.VOLCANO_LAVA) then
		self.inst:DoTaskInTime(1.0, function(inst)
			self.inst.Physics:SetMotorVel(0, 0, 0)
			if self.inst.components.inventoryitem then
				self.inst.components.inventoryitem:OnHitLava()
			else
				self.inst:Remove()
			end
		end)

	elseif GetWorld():IsVolcano() and self.inst:GetIsOnTileType(GROUND.IMPASSABLE) then
		self.inst:DoTaskInTime(0.2, function(inst)
			self.inst.Physics:SetMotorVel(0, 0, 0)
			if self.inst.components.inventoryitem then
				self.inst.components.inventoryitem:OnHitCloud()
			else
				self.inst:Remove()
			end
		end)
	end
end

return BlowInWind
