
local FLOOD_GROW = 0
local FLOOD_SHRINK = 1

local FloodListener = Class(function(self, inst)
    self.inst = inst
    self.flood_state = FLOOD_GROW
    self.flood_timer = 0.0
    self.flood_period = TUNING.FLOODING_FLOOD_TIME
    self.waterlevel = 0.0 --0 is sea level
    self.waterlevelprev = 0.0
    --self.flood_rate = TUNING.FLOODING_FLOOD_RATE --0.25
    --self.dry_rate = TUNING.FLOODING_DRY_RATE --0.5
    self.waterlevelchangefn = nil
    self.waterlevelpeakfn = nil
    self.waterlevelzerofn = nil
    self.inst:StartUpdatingComponent(self)
end)

function FloodListener:OnUpdate( dt )
	local peakwater = 0.5 * TUNING.FLOODING_MAX_WATERLEVEL

	local check_waterlevel = function(flooding)
		if flooding.waterlevelchangefn and math.abs(flooding.waterlevel - flooding.waterlevelprev) > 1.0 then
			flooding.waterlevelchangefn(flooding.inst, flooding.waterlevel, flooding.waterlevelprev)
			flooding.waterlevelprev = flooding.waterlevel
		end
	end

	local get_drytime = function()
		local timeleft = TUNING.TOTAL_DAY_TIME * GetSeasonManager():GetDaysLeftInSeason()
		local min = math.max(timeleft, timeleft - TUNING.FLOODING_DRY_TIME_VARIANCE)
		local max = timeleft + TUNING.FLOODING_DRY_TIME_VARIANCE
		return GetRandomMinMax(min, max)
	end

	self.flood_timer = self.flood_timer + dt

	if self.flood_state == FLOOD_GROW then
		self.waterlevel = -peakwater * math.cos(PI * self.flood_timer / self.flood_period) + peakwater
		if self.flood_timer >= self.flood_period then
			self.flood_timer = 0.0
			self.flood_period = get_drytime()
			self.flood_state = FLOOD_SHRINK
			if self.waterlevelpeakfn then
				self.waterlevelpeakfn(self.inst, self.waterlevel)
			end
		else
			check_waterlevel(self)
		end
		--print(string.format("Flood grow: water %4.2f, (%4.2f/%4.2f)\n", self.waterlevel, self.flood_timer, self.flood_period))
	elseif self.flood_state == FLOOD_SHRINK then
		self.waterlevel = peakwater * math.cos(PI * self.flood_timer / self.flood_period) + peakwater
		if self.flood_timer >= self.flood_period then
			self.waterlevel = 0.0
			if self.waterlevelzerofn then
				self.waterlevelzerofn(self.inst)
			end
		else
			check_waterlevel(self)
		end
		--print(string.format("Flood shrink: water %4.2f, (%4.2f/%4.2f)\n", self.waterlevel, self.flood_timer, self.flood_period))
	end

	--Increase water level when raining and decrease when not raining
	--[[local sm = GetSeasonManager()
	if sm then
		if sm:IsRaining() then
			local precip_rate = 0.5 * sm:GetPrecipitationRate()
			self.waterlevel = self.waterlevel + self.flood_rate * precip_rate * dt
			self.waterlevel = math.min(TUNING.FLOODING_MAX_WATERLEVEL, self.waterlevel)
			--print(string.format("Waterlevel increasing %4.2f, rain %4.2f", self.waterlevel, precip_rate))
		else
			local temp_factor = math.max(0.5, sm:GetTemperature() / 50) --dry quicker in high temps
			local humid_factor = 1.0 - sm:GetPOP() -- humidity affecting evapouration
			self.waterlevel = self.waterlevel - self.dry_rate * temp_factor * humid_factor * dt
			self.waterlevel = math.max(0.0, self.waterlevel)
			--print(string.format("Waterlevel decreasing %4.2f, temp %4.2f, humid %4.2f", self.waterlevel, temp_factor, humid_factor))
		end

		if self.waterlevelchangefn and (self.waterlevel == 0.0 or math.abs(self.waterlevel - self.waterlevelprev) > 1.0) then
			self.waterlevelchangefn(self.inst, self.waterlevel, self.waterlevelprev)
			self.waterlevelprev = self.waterlevel
		end
	end]]--
end

function FloodListener:LongUpdate( dt )
	self:OnUpdate(dt)
end

function FloodListener:OnSave()
	return
	{
		flood_state = self.flood_state,
		flood_timer = self.flood_timer,
		flood_period = self.flood_period,
		--waterlevel = self.waterlevel,
		--flood_rate = self.flood_rate,
		--dry_rate = self.dry_rate
	}
end

function FloodListener:OnLoad(data)
	if data then
		self.flood_state = data.flood_state or self.flood_state
		self.flood_timer = data.flood_timer or self.flood_timer
		self.flood_period = data.flood_period or self.flood_period
		--self.waterlevel = data.waterlevel or self.waterlevel
		--self.waterlevelprev = self.waterlevel + 2
		--self.flood_rate = data.flood_rate or self.flood_rate
		--self.dry_rate = data.dry_rate or self.dry_rate
	end
end

return FloodListener