local easing = require("easing")

local SHELTERED_SHADE = .6
local EXPOSED_SHADE = 1
local TIME_TO_SHELTER = .2
local TIME_TO_EXPOSE = .1
local SHELTER_SPEED = (EXPOSED_SHADE - SHELTERED_SHADE) / TIME_TO_SHELTER
local EXPOSE_SPEED = (EXPOSED_SHADE - SHELTERED_SHADE) / TIME_TO_EXPOSE

local Moisture = Class(function(self, inst)
    self.inst = inst

    self.moistureclamp = {min = TUNING.MOISTURE_MIN_WETNESS, max = TUNING.MOISTURE_MAX_WETNESS}
    self.moisture = 0
    self.numSegs = 5
    self.baseDryingRate = 0

    self.maxDryingRate = 0.1
    self.minDryingRate = 0

    self.maxPlayerTempDrying = 5
    self.minPlayerTempDrying = 0

    self.maxMoistureRate = .75
    self.minMoistureRate = 0

    self.optimalDryingTemp = 50

    self.delta = 0

    self.sheltered = false
    self.new_sheltered = false
    self.prev_sheltered = false
    self.shelter_waterproofness = TUNING.WATERPROOFNESS_SMALLMED

	self.shade = EXPOSED_SHADE
	self.targetshade = EXPOSED_SHADE

	self.inst:StartUpdatingComponent(self)

end)

function Moisture:CheckForShelter()
	-- reset the shelter_waterproofness
	self.shelter_waterproofness = TUNING.WATERPROOFNESS_SMALLMED

	local x,y,z = self.inst.Transform:GetWorldPosition()
	
	local fog = GetSeasonManager().IsFoggy and GetSeasonManager():IsFoggy()
	local ents = {}
	if not fog then
		ents = TheSim:FindEntities(x,y,z, 3, {"shelter"}, {"FX", "NOCLICK", "DECOR", "INLIMBO", "stump", "burnt"})
	end

	if #ents > 0 then
		for _, v in ipairs(ents) do
			if v:HasTag("dryshelter") then
				self.shelter_waterproofness = TUNING.WATERPROOFNESS_ABSOLUTE
				break
			end
		end

		-- Check if have been sheltered before we set sheltered/prev_sheltered to true so that we are only doing the announce after having been under shelter for a couple updates
		if self.new_sheltered and self.prev_sheltered then
			self.sheltered = true
			self.targetshade = SHELTERED_SHADE
			self.inst:PushEvent("sheltered") -- Set sheltered to true in temperature
			if (not self.lastannouncetime or (GetTime() - self.lastannouncetime > TUNING.TOTAL_DAY_TIME)) and
				GetSeasonManager() and (GetSeasonManager():IsRaining() or GetSeasonManager():GetCurrentTemperature() >= TUNING.OVERHEAT_TEMP - 5) then
				self.inst.components.talker:Say(GetString(self.inst.prefab, "ANNOUNCE_SHELTER"))
				self.lastannouncetime = GetTime()
			end
		end
		if self.new_sheltered then self.prev_sheltered = true end -- Have we been sheltered for an update?
		self.new_sheltered = true
	elseif (self.inst:HasTag("under_leaf_canopy") or self.inst:HasTag("under_shadowcaster") )and not fog then
		local ents = TheSim:FindEntities(x,y,z, 3, {"exposure"})
		if #ents <= 0 then
			self.sheltered = true
			self.targetshade = SHELTERED_SHADE
			self.inst:PushEvent("sheltered")
		end			
	elseif TheCamera.interior then
		self.sheltered = true
		self.targetshade = SHELTERED_SHADE
		self.inst:PushEvent("sheltered")			
	else
		self.sheltered = false
		self.targetshade = EXPOSED_SHADE
		self.prev_sheltered = false
		self.new_sheltered = false
		self.inst:PushEvent("unsheltered")
	end

	local soundShouldPlay = GetSeasonManager() and GetSeasonManager():IsRaining() and self.sheltered
    if soundShouldPlay ~= self.inst.SoundEmitter:PlayingSound("treerainsound") then
        if soundShouldPlay then
		    self.inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/rain_on_tree", "treerainsound") 
			self.inst.SoundEmitter:SetParameter("treerainsound", "intensity", GetSeasonManager().precip_rate)
        else
		    self.inst.SoundEmitter:KillSound("treerainsound")
		end
    elseif soundShouldPlay and self.inst.SoundEmitter:PlayingSound("treerainsound") then
		self.inst.SoundEmitter:SetParameter("treerainsound", "intensity", GetSeasonManager().precip_rate)
    end
end

function Moisture:GetDebugString()

	local temp = self.inst.components.temperature
	local sm = GetWorld().components.seasonmanager
	local rate = self.baseDryingRate

	return string.format("\n\t\tMoisture Rate: %2.2f -- %2.2f\n\t\tDrying Rate: %2.2f\n\t\tMoisture: %2.2f\n\t\tCombinedRate: %2.2f\n\t\t %2.2f, %2.2f, %2.2f \n\t\tSheltered: %s shade: %f", 
		self:GetMoistureRate(), GetWorld().components.seasonmanager.precip_rate,
		self:GetDryingRate(), 
		self:GetMoisture(),
		self:GetMoistureRate() - self:GetDryingRate(),
		easing.linear(sm:GetCurrentTemperature(), self.minDryingRate, self.maxDryingRate, self.optimalDryingTemp),
		easing.inExpo(temp:GetCurrent(), self.minPlayerTempDrying, self.maxPlayerTempDrying, self.optimalDryingTemp),
		easing.inExpo(self:GetMoisture() , 0, 1, self.moistureclamp.max),
		tostring(self.sheltered), self.shade
		)
end

function Moisture:AnnounceMoisture(oldSegs, newSegs)
	if oldSegs < 1 and newSegs >= 1 then
		self.inst.components.talker:Say(GetString(self.inst.prefab, "ANNOUNCE_DAMP"))
	elseif oldSegs < 2 and newSegs >= 2 then
		self.inst.components.talker:Say(GetString(self.inst.prefab, "ANNOUNCE_WET"))
	elseif oldSegs < 3 and newSegs >= 3 then
		self.inst.components.talker:Say(GetString(self.inst.prefab, "ANNOUNCE_WETTER"))
	elseif oldSegs < 4 and newSegs >= 4 then
		self.inst.components.talker:Say(GetString(self.inst.prefab, "ANNOUNCE_SOAKED"))
	end
end

function Moisture:Soak(percent)
	local currentLevel = self:GetMoisture()
	local oldSegs = self:GetSegs()
	self:SetMoistureLevel(percent * self.moistureclamp.max)
	local newSegs = self:GetSegs()
	self:AnnounceMoisture(oldSegs, newSegs)
	self.inst:PushEvent("moisturechange", {old = currentLevel, new = self.moisture})
end

function Moisture:DoDelta(num)
	local currentLevel = self:GetMoisture()
	local oldSegs = self:GetSegs()
	self:SetMoistureLevel(self.moisture + num)
	local newSegs = self:GetSegs()
	self:AnnounceMoisture(oldSegs, newSegs)
	self.inst:PushEvent("moisturechange", {old = currentLevel, new = self.moisture})
end

function Moisture:SetMoistureLevel(num)
	self.moisture = math.clamp(num, self.moistureclamp.min, self.moistureclamp.max)
end

function Moisture:GetMoisture()
	return self.moisture
end

function Moisture:GetMoisturePercent()
	return self.moisture / self.moistureclamp.max
end

function Moisture:GetSegs()
	local perNotch = self.moistureclamp.max/self.numSegs
	local num = self.moisture/perNotch

	local full = math.ceil(num - 1)
	full = math.max(full, 0)
	local empty = num - full

	--Full is the number of full drops for UI, empty is the alpha value of the currently filling drop.
	--if num is 4.5 then full is 4 & empty is 0.5
	return full, empty
end

function Moisture:GetMoistureRate()
	local seasonmgr = GetSeasonManager()
	
	local rate = 0 
	if seasonmgr and seasonmgr:IsRaining() then
		local isInside = false
		local pt = self.inst:GetPosition()
    	local tile = GetWorld().Map:GetTileAtPoint(pt.x,pt.y,pt.z)
    	if tile == GROUND.INTERIOR then	
    		isInside = true
    	end
    	if not isInside then
			local precip = seasonmgr.precip_rate	
			if seasonmgr and seasonmgr:IsSpring() and seasonmgr.incaves then
				precip = precip * TUNING.CAVES_MOISTURE_MULT
			end
			rate = easing.inSine(precip, self.minMoistureRate, self.maxMoistureRate, 1)		
		end
	end
	local x,y,z = self.inst.Transform:GetWorldPosition()
	if self.inst:CheckIsInInterior() then
		rate = 0			
	end
	if self.inst.components.inventory:IsWaterproof() then
		rate = 0				
	elseif GetWorld().Flooding and GetWorld().Flooding:OnFlood(x, y, z) and not (self.inst.components.driver and self.inst.components.driver:GetIsDriving()) then
		rate = 1				
	elseif self.inst.components.driver and self.inst.components.driver.vehicle and self.inst.components.driver.vehicle.components.boathealth and self.inst.components.driver.vehicle.components.boathealth:IsLeaking() then
		rate = 1 - self.inst.components.inventory:GetWaterproofness()			
	else
		if self.sheltered then
			rate = rate * (1 - (self.inst.components.inventory:GetWaterproofness() + self.shelter_waterproofness))				
		else
			rate = rate * (1 - self.inst.components.inventory:GetWaterproofness())				
			-- fog is less wetness, but harder to combat
			if seasonmgr.IsFoggy and seasonmgr:IsFoggy() then
				rate = rate * 0.6 
			end
		end	
	end	

	if self.moisture_sources then
		for GUID,mrate in pairs( self.moisture_sources )do
			local ratechange = mrate * (math.max( 0,  1 - self.inst.components.inventory:GetWaterproofness() ) ) 			
			rate = rate + ratechange
		end
	end 
	
	return rate
end

function Moisture:GetEquippedMoistureRate()
	local rate = 0
	local max = 0

	if self.inst.components.inventory then
		rate, max = self.inst.components.inventory:GetEquippedMoistureRate()
	end

	-- If rate and max are nonzero (i.e. wearing a moisturizing equipment) and the drying rate is less than
	-- the moisture rate of the equipment AND we're at max moisture for the equipment, set the two rates equal.
	-- This will prevent the arrow flickering as well as hold the moisture steady at max level
	if rate ~= 0 and max ~= 0 and self.moisture >= max and self:GetDryingRate() <= rate then
		rate = self:GetDryingRate()
	end

	if math.abs(rate) <= 0.01 then rate = 0 end

	return rate
end

function Moisture:GetDryingRate()

	local temp = self.inst.components.temperature
	local sm = GetWorld().components.seasonmanager
	local rate = self.baseDryingRate

	local heaterPower = 0

	local x,y,z = self.inst:GetPosition():Get()
	local ZERO_DISTANCE = 10
	local ZERO_DISTSQ = ZERO_DISTANCE*ZERO_DISTANCE
	local ents = TheSim:FindEntities(x, y, z, ZERO_DISTANCE, {"HASHEATER"})

    for k,v in pairs(ents) do 
		if v.components.heater and not v.components.heater.iscooler and v ~= self.inst and not v:IsInLimbo() then
			local heat = v.components.heater:GetHeat(self.inst)
			local distsq = self.inst:GetDistanceSqToInst(v)

			-- This produces a gentle falloff from 1 to zero.
			local heatfactor = ((-1/ZERO_DISTSQ)*distsq) + 1
			local mm = GetWorld().components.moisturemanager
	        if mm and ((not mm:IsEntityDry(self.inst)) or (mm:IsWorldWet() and not GetPlayer().components.inventory:IsWaterproof())) then
	            heatfactor = heatfactor * TUNING.WET_HEAT_FACTOR_PENALTY
	        end

	        heaterPower = heaterPower + heatfactor
		end
    end

    heaterPower = math.clamp(heaterPower, 0, 1)

    if self:GetSegs() >= 3 then
		rate = rate + easing.linear(heaterPower, self.minPlayerTempDrying, 5, 1)
	else
		rate = rate + easing.linear(heaterPower, self.minPlayerTempDrying, 2, 1)
	end

	--Look @ player temp too

	rate = rate + easing.linear(sm:GetCurrentTemperature(), self.minDryingRate, self.maxDryingRate, self.optimalDryingTemp)
	rate = rate + easing.inExpo(self:GetMoisture() , 0, 1, self.moistureclamp.max)
	rate = math.clamp(rate, 0, self.maxDryingRate + self.maxPlayerTempDrying)


	-- Don't dry if it's raining (and oustide)
	if self:GetMoistureRate() > 0 then
		rate = 0
	end

	-- Don't dry on floods
	if GetWorld().Flooding and GetWorld().Flooding:OnFlood(x, y, z) and not (self.inst.components.driver and self.inst.components.driver:GetIsDriving()) then
		rate = 0
	end

    local x, y, z = GetPlayer().Transform:GetWorldPosition()

    local ents = TheSim:FindEntities(x, y, z, 30, {"blows_air"})
    local fanNearby = (#ents > 0)

    if fanNearby then
    	rate = rate + TUNING.HYDRO_BONUS_COOL_RATE
    end

	-- Look @ player locomotor
	local autodry = false
	if GetPlayer().components.locomotor then
		autodry = GetPlayer().components.locomotor:HasSpeedModifier("AUTODRY")
	end

	if autodry then
		rate = rate + TUNING.HYDRO_BONUS_COOL_RATE
	end

	return rate
end

function Moisture:GetDelta()
	return self.delta
end

function Moisture:OnUpdate(dt)
	self:CheckForShelter()

	local drying_rate = -self:GetDryingRate()
	local moisture_rate = self:GetMoistureRate() + self:GetEquippedMoistureRate()
	self.delta = (moisture_rate + drying_rate)
	
	self:DoDelta(self.delta * dt)

	if self.shade ~= self.targetshade then
		self.shade =
			self.shade > self.targetshade and
			math.max(SHELTERED_SHADE, self.shade - dt * SHELTER_SPEED) or
			math.min(EXPOSED_SHADE, self.shade + dt * EXPOSE_SPEED)
		self.inst.AnimState:OverrideShade(self.shade)
	end
end

function Moisture:LongUpdate(dt)
	self:OnUpdate(dt)
end

function Moisture:OnSave()
	local data = {}
	data.moisture = self.moisture
	return data
end

function Moisture:OnLoad(data)
	if data then
		self.moisture = data.moisture
	end
end

return Moisture
