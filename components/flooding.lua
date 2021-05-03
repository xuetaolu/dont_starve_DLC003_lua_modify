
local Flooding = Class(function(self, inst)
    self.inst = inst
    --self.flood_per_sec = TUNING.FLOODING_SPAWN_PER_SEC --1.0/15.0
    --self.flood_spawn_timer = 1.0
    --self.flood_timer = 0.0
    self.inst:StartUpdatingComponent(self)
    self.maxTide = 0 
    self.maxTideMod = 1 --settings modifier
    self.maxFloodLevel = TUNING.MAX_FLOOD_LEVEL
    self.timeSinceFloodIncrease = 0 
    self.timeBetweenFloodIncreases = TUNING.SEG_TIME

    self.mode = "tides"

    self.inst:ListenForEvent("floodblockercreated", 
		function(it, data)
			--addFloodBlocker( data.blocker)
			local bx, by, bz = data.blocker.Transform:GetWorldPosition()
			GetWorld().Flooding:SetIsPositionBlocked(bx,0,bz, true, true)
		end, 
	GetWorld())

	--For when a sandbag or other floodblocker is removed 
	self.inst:ListenForEvent("floodblockerremoved", 
		function(it, data)
			--removeFloodBlocker(data.blocker)
			local bx, by, bz = data.blocker.Transform:GetWorldPosition()

			GetWorld().Flooding:SetIsPositionBlocked(bx,0,bz, false, false)

		end, 
	GetWorld())

	GetWorld().Flooding:SetSpawnerFrequency(TUNING.FLOOD_FREQUENCY)

end)

local heights = 
{
	["new"] = 0,
    ["quarter"] = 5,
    ["half"] = 7,
    ["threequarter"] = 8,
    ["full"] = 10,
}

local function GetIsFloodSeason()
	local sm = GetSeasonManager()
	if sm:IsGreenSeason() and sm:GetPercentSeason() > 0.25 then 
		return true 
	elseif sm:IsDrySeason() and sm:GetPercentSeason() < 0.25 then 
		return true 
	end 
	return false
end 

function Flooding:GetIsFloodSeason()
	return GetIsFloodSeason()
end

function Flooding:SwitchMode(mode)
	if mode ~= self.mode then 
		if mode == "flood" then 
			GetWorld().Flooding:ChangeToFloodMode()
		elseif mode == "tides" then 
			GetWorld().Flooding:ChangeToTideMode()
		end 
		self.mode = mode 
		self.inst:DoTaskInTime(1,function() self.inst:PushEvent("FloodModeChanged", self.mode) end)
	end 
end 

function Flooding:GetTideHeight()

	local nightLength = GetClock():GetNightTime()
	local duskLength = GetClock():GetDuskTime() 
	
	--Floods start at the beginning of evening and end at daybreak, in that time they interpolate to max height and back to zero 
	local timepassed = 0

	local time = GetClock():GetNormTime() 
	local tidePerc = 0 
	local startGrowTime = 1.0 - 3/16 
	local startShrinkTime = 0
	local endShrinkTime = 3/16 

	if time > startGrowTime then 
		self.maxTide = self.maxTideMod * heights[GetClock():GetMoonPhase()]--high tide depends on moon level, only set this in the day the flood starts as the moon phase might change when the day turns over  
		tidePerc = (time - startGrowTime)/(3/16)
	elseif time > startShrinkTime and time < endShrinkTime then 
		tidePerc = 1.0 - (time/(endShrinkTime - startShrinkTime))
	end 
	
	return self.maxTide * tidePerc
end 


local function GetSeasonPerc()
	local sm = GetSeasonManager()
	local length = sm:GetSeasonLength()
	local perc = sm:GetPercentSeason() --This value only changes each day, we want a more accurate percentage than that 
	perc = perc + GetClock():GetNormTime()/length
	return perc 
end 

function Flooding:OnUpdate( dt )
	
	if self.mode == "flood" then 
		local sm = GetSeasonManager()
		local maxFloodLevel = self.maxFloodLevel
		local currentLevel = GetWorld().Flooding:GetTargetDepth()
		self.timeSinceFloodIncrease = self.timeSinceFloodIncrease + dt
		if sm:IsGreenSeason() and sm:IsRaining() then
			local perc = GetSeasonPerc()
			perc = math.max(0, (perc - 0.25)/0.75) --Don't spawn floods in the first 1/4 of the season 
			local targetLevel = maxFloodLevel * perc
			if targetLevel > currentLevel  and self.timeSinceFloodIncrease > self.timeBetweenFloodIncreases then 
				currentLevel = currentLevel + 1 
				self.timeSinceFloodIncrease = 0 
			end 
			GetWorld().Flooding:SetTargetDepth(currentLevel)
		elseif sm:IsDrySeason() then 
			local perc = GetSeasonPerc()
			perc = math.min(1.0, (perc/0.15)) --Floods disapear in the first 25% of the season 
			local targetLevel = maxFloodLevel - maxFloodLevel * perc 
			targetLevel = math.max(targetLevel, 0)
			if(targetLevel < currentLevel) then 
				GetWorld().Flooding:SetTargetDepth(targetLevel)
			end
		elseif not sm:IsGreenSeason() then 
			GetWorld().Flooding:SetTargetDepth(0)
		end		
		if currentLevel == 0 and not GetIsFloodSeason() and self:GetTideHeight() == 0 then 
			self:SwitchMode("tides")
		end 
	elseif self.mode == "tides" then 
		local currentHeight = GetWorld().Flooding:GetTargetDepth()
		local newHeight = self:GetTideHeight()
		GetWorld().Flooding:SetTargetDepth(newHeight)

		if newHeight < currentHeight then 
			--Flood receding
		end 

		if newHeight == 0 and GetIsFloodSeason() then 
			self:SwitchMode("flood")
		end 
	end 
end

function Flooding:LongUpdate(dt)
	self:OnUpdate(dt)
end


function Flooding:OnSave()

	local nextmode,currentmode = GetWorld().Flooding:GetModeData()

	local data = {}
	if self.inst.Flooding then
		--data.flood = self.inst.Flooding:GetAsString()
		--data.flood_timer = self.flood_timer
		data.flooddepth = GetWorld().Flooding:GetTargetDepth() 
		data.string = GetWorld().Flooding:GetAsString() 
		data.mode = self.mode
		data.maxTide = self.maxTide
		data.maxTideMod = self.maxTideMod
		data.maxFloodLevel = self.maxFloodLevel
		data.floodFrequency = GetWorld().Flooding:GetSpawnerFrequency()
		data.timeSinceFloodIncrease = self.timeSinceFloodIncrease
		data.nextmode = nextmode
		data.currentmode = currentmode
	end
	return data
end

function Flooding:SetMode(data)
	
		if not data.nextmode or not data.currentmode then
			data.nextmode  = 1
			data.currentmode = 1
			if GetIsFloodSeason() then
				data.nextmode = 0
				data.currentmode = 0
			end
		end
		if data.nextmode and data.currentmode then
			GetWorld().Flooding:SetModeData(data.nextmode,data.currentmode)			
		end
end

function Flooding:OnLoad(data)

	if data ~= nil and self.inst.Flooding then
		--self.inst.Flooding:SetFromString(data.flood)
		--self.flood_timer = data.flood_timer
		if data.mode then 
			self.mode = data.mode		
		end 		
		if data.flooddepth then 
			GetWorld().Flooding:SetTargetDepth(data.flooddepth)
		end 
		if data.string then 
			GetWorld().Flooding:SetFromString(data.string)
		end 
		if data.maxTide then 
			self.maxTide = data.maxTide
		end 
		if data.maxTideMod then
			self.maxTideMod = data.maxTideMod
		end
		if data.maxFloodLevel then
			self.maxFloodLevel = data.maxFloodLevel
		end
		if data.floodFrequency then
			GetWorld().Flooding:SetSpawnerFrequency(data.floodFrequency)
		end
		if data.timeSinceFloodIncrease then 
			self.timeSinceFloodIncrease = data.timeSinceFloodIncrease
		end 

		GetWorld():DoTaskInTime(0,function() self:SetMode(data) end)
	end
end

function Flooding:SetFloodSettings(maxLevel, frequency)
	self.maxFloodLevel = math.min(maxLevel, TUNING.MAX_FLOOD_LEVEL)
	GetWorld().Flooding:SetSpawnerFrequency(frequency)
end

function Flooding:SetMaxTideModifier(mod)
	self.maxTideMod = mod
end

function Flooding:GetDebugString()
	local perc = GetSeasonPerc()
	local lvl = GetWorld().Flooding:GetTargetDepth()
	if self.mode == "flood" then
		return string.format("flood: %4.2f, lvl %d/%d, freq %f, %4.2f", perc, lvl, self.maxFloodLevel, GetWorld().Flooding:GetSpawnerFrequency(), self.timeSinceFloodIncrease)
	end
	return string.format("tides: %4.2f, lvl %d/%d, mod %d", perc, lvl, self.maxTide, self.maxTideMod)
end

--[[
function Flooding:BroadcastFloodChange()
	--print("BroadcastFloodChange")
	self.inst:PushEvent("floodChange")
end
]]
return Flooding

