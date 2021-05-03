local easing = require("easing")

local SUMMER_BLOOM_BASE = 0.08   -- base amount of bloom applied during the day
local SUMMER_BLOOM_TEMP_MODIFIER = 0.06 / TUNING.DAY_HEAT   -- amount that the daily temp. variation factors into the overall bloom
local SUMMER_BLOOM_TEMP_MODIFIER = 0.06 / TUNING.DAY_HEAT   -- amount that the daily temp. variation factors into the overall bloom
local SUMMER_BLOOM_PERIOD_MIN = 5 -- min length of the bloom fluctuation period
local SUMMER_BLOOM_PERIOD_MAX = 10 -- max length of the bloom fluctuation period

local HURRICANE_GUST_WAIT = 0
local HURRICANE_GUST_ACTIVE = 1
local HURRICANE_GUST_RAMPUP = 2
local HURRICANE_GUST_RAMPDOWN = 3

local function IsCaves() 
	return GetWorld():IsCave()
end

--[[
local FOG_STATE = {
	SETTING = 1,
	FOGGY = 2,
	LIFTING = 3,
	CLEAR = 4,
}
]]
local SeasonManager = Class(function(self, inst)
	self.inst = inst
	self.current_season = SEASONS.AUTUMN
	self.current_temperature = 10
	self.noise_time = 0	
	self.ground_snow_level = 0
	self.atmo_moisture = 0
	self.moisture_limit = TUNING.TOTAL_DAY_TIME +  math.random()*TUNING.TOTAL_DAY_TIME*3
	self.moisture_floor = 0
	self.precip = false
	self.precip_rate = 0
	self.peak_precip_intensity = 1
	self.preciptype = "rain"
	self.hail_rate = 0
	self.base_atmo_moisture_rate = 1
	self.wildfire_retry_time = TUNING.WILDFIRE_RETRY_TIME
	self.wither_delay = math.random(30,60)
	self.rejuvenate_delay = math.random(30,60)
	self.hurricane = false
	self.hurricane_rate = 0
	self.hurricane_peak_intensity = 1
	self.hurricane_timer = 0
	self.hurricane_duration = 0
	self.hurricane_wind = 0
	self.hurricane_gust_speed = 0.0
	self.hurricane_gust_timer = 0.0
	self.hurricane_gust_period = 0.0
	self.hurricane_gust_peak = 0.0
	self.hurricane_gust_state = HURRICANE_GUST_WAIT
	self.hurricanetease_start = 0
	self.hurricanetease_started = false
	self.windy = false
	self.fog_state = FOG_STATE.CLEAR	
	self.fog_time = 0
	self.fog_fadetime = 5
	self.fog_transition_time_max = 10

	self.autumnsegs = {day=8,  dusk=6,  night=2}
	self.wintersegs = {day=5,  dusk=5,  night=6}
	self.springsegs = {day=5,  dusk=8,  night=3}
	self.summersegs = {day=10, dusk=4,  night=2}
	
	self.mildsegs = {day=12, dusk=2,  night=2}
	self.wetsegs = {day=5,  dusk=5,  night=6}
	self.greensegs = {day=7, dusk=6,  night=3}
	self.drysegs = {day=10, dusk=4,  night=2}

	self.temperatesegs = {day=10, dusk=4,  night=2}
	self.humidsegs = {day=8,  dusk=5,  night=3}
	self.lushsegs = {day=8, dusk=4,  night=4}
	self.aporkalypse_segs = { day = 0, dusk = 0, night = 16 }

	self.seasonfns =
	{
		spring = self.StartSpring,
		autumn = self.StartAutumn,
		winter = self.StartWinter,
		summer = self.StartSummer,
		mild = self.StartMild,
		wet = self.StartWet,		
		green = self.StartGreen,
		dry = self.StartDry,

		temperate = self.StartTemperate,
		lush = self.StartLush,
		humid = self.StartHumid,
		aporkalypse = self.StartAporkalypse
	}

	self.segmod = {day = 1, dusk = 1, night = 1}

	self.nextlightningtime = 5
	self.lightningdelays = {min=nil, max=nil}
	self.lightningmode = "rain"

	self.seasonmode = "cycle"

	self.winterlength = TUNING.SEASON_LENGTH_HARSH_DEFAULT
	self.autumnlength = TUNING.SEASON_LENGTH_FRIENDLY_DEFAULT
	self.springlength = TUNING.SEASON_LENGTH_FRIENDLY_DEFAULT
	self.summerlength = TUNING.SEASON_LENGTH_HARSH_DEFAULT

	self.mildlength = TUNING.SEASON_LENGTH_FRIENDLY_DEFAULT
	self.wetlength = TUNING.SEASON_LENGTH_HARSH_DEFAULT
	self.greenlength = TUNING.SEASON_LENGTH_FRIENDLY_DEFAULT
	self.drylength = TUNING.SEASON_LENGTH_HARSH_DEFAULT

	self.temperatelength = TUNING.SEASON_LENGTH_FRIENDLY_DEFAULT/2
	self.humidlength = TUNING.SEASON_LENGTH_FRIENDLY_DEFAULT/2
	self.lushlength = TUNING.SEASON_LENGTH_FRIENDLY_DEFAULT/2
	self.aporkalypse_length = TUNING.SEASON_LENGTH_FRIENDLY_DEFAULT/2


	self.incaves = false
	self.ininterior = false	
	self.winterenabled = true
	self.autumnenabled = true
	self.springenabled = true
	self.summerenabled = true
	self.mildenabled = false
	self.wetenabled = false
	self.greenenabled = false
	self.dryenabled = false
	self.precipoutside = false
	self.hurricaneoutside = false

	self.temperateenabled = false
	self.lushenabled = false
	self.humidenabled = false
	self.aporkalypse_enabled = false

	self.percent_season = 0
	
	self.precipmode = "dynamic"
	self.windmode = "dynamic"

	local humidfreq = 50
	self.humiddsp =
	{
		["set_music/soundtrack"] = 1000,
						--["set_ambience"] = humidfreq,
		-- ["set_sfx/HUD"] = humidfreq,
		-- ["set_sfx/movement"] = humidfreq,
		["set_sfx/creature"] = humidfreq,
		["set_sfx/player"] = humidfreq,
		["set_sfx/sfx"] = humidfreq,
		-- ["set_sfx/voice"] = humidfreq,
	}
	
	local winterfreq = 5000
	self.winterdsp =
	{
		["set_music/soundtrack"] = 2000,
					--["set_ambience"] = winterfreq,
		--["set_sfx/HUD"] = winterfreq,
		["set_sfx/movement"] = winterfreq,
		["set_sfx/creature"] = winterfreq,
		["set_sfx/player"] = winterfreq,
		["set_sfx/sfx"] = winterfreq,
		["set_sfx/voice"] = winterfreq,
		--["set_sfx/set_ambience"] = winterfreq,
	}

	self.summerfreq = {100, 250, 500, 750, 1000}
	self.summerdsp =
	{
		["set_music/soundtrack"] = 500,
						-- ["set_ambience"] = self.summerfreq[1],
		-- ["set_sfx/HUD"] = self.summerfreq[1],
		["set_sfx/movement"] = self.summerfreq[1],
		["set_sfx/creature"] = self.summerfreq[1],
		["set_sfx/player"] = self.summerfreq[1],
		["set_sfx/sfx"] = self.summerfreq[1],
		--["set_sfx/voice"] = self.summerfreq[1],
		--["set_sfx/set_ambience"] = self.summerfreq[1],
	}

	if math.random() <= .5 then
		self:StartAutumn()
	else
		self:StartSpring(true)
	end
	self:Start()


	self.inst:ListenForEvent( "daycomplete", function() self:OnDayComplete() end )
	self.inst:ListenForEvent( "rainstart", function() self:OnRainStart() end )
	self.inst:ListenForEvent( "rainstop", function() self:OnRainStop() end )
	self:UpdateSegs()

	self.initialevent = false
	
	self.bloom_time_current = 0
	self.bloom_time_to_new_modifier = 0
	self.bloom_modifier = 0
	self.bloom_enabled = false

	self.season_change_task = nil
	
	self.inst:ListenForEvent( "daytime", function() self:OnDayTime() end )
	self.inst:ListenForEvent( "exitinterior", function(data) self:onExitInterior(data) end )
	self.inst:ListenForEvent( "enterinterior", function(data) self:onEnterInterior(data) end )
end)

function SeasonManager:onEnterInterior(data)
    self.ininterior = true

    self.precipoutside = self.precip
    if self.precipoutside then
    	self:StopPrecip()
    end

    self.hurricaneoutside = self:IsHurricaneStorm()
    if self.hurricaneoutside then
    	self:StopHurricaneStorm()
    end
end

function SeasonManager:onExitInterior(data)
    self.ininterior = false
    if self.precipoutside then
    	self:StartPrecip(true)
    end

    if self.hurricaneoutside then
    	self:StartHurricaneStorm()
    end
end

function SeasonManager:EnqueueSeasonChange()
	if self.season_change_task == nil then
		self.season_change_task = self.inst:DoTaskInTime(0, function()
			self.inst:PushEvent( "seasonChange", {season = self.current_season} )
			self.season_change_task = nil
		end)
	end
end

function SeasonManager:SetCaves()
	if IsCaves() then
		self.incaves = true
		if self.current_season == SEASONS.SPRING then
			self:StartCavesRain()
		else
			self:StopCavesRain()
		end
	else
		self:SetOverworld()
	end
end

function SeasonManager:SetOverworld()
	if IsCaves() then
		self:SetCaves()
	else
		self.incaves = false
		self:SetAppropriateDSP()
		--self.inst:PushEvent( "seasonChange", {season = self.current_season} )
	end
end

function SeasonManager:SetMoiustureMult(mult)
	self.base_atmo_moisture_rate = mult
end

function SeasonManager:EndlessWinter(autumnlength, winterrampup)
	self.seasonmode = "endlesswinter"
	self.endless_pre = autumnlength
	self.endless_ramp = winterrampup
	self.percent_season = .5
	self:UpdateSegs()
end

function SeasonManager:EndlessSpring(winterlength, springrampup)
	self.seasonmode = "endlessspring"
	self.endless_pre = winterlength
	self.endless_ramp = springrampup
	self.percent_season = .5
	self:UpdateSegs()
end

function SeasonManager:EndlessSummer(springlength, summerrampup)
	self.seasonmode = "endlesssummer"
	self.endless_pre = springlength
	self.endless_ramp = summerrampup
	self.percent_season = .5
	self:UpdateSegs()
end

function SeasonManager:EndlessAutumn(summerlength, autumnrampup)
	self.seasonmode = "endlessautumn"
	self.endless_pre = summerlength
	self.endless_ramp = autumnrampup
	self.percent_season = .5
	self:UpdateSegs()
end

function SeasonManager:AlwaysAutumn()
	self.seasonmode = "alwaysautumn"
	self.percent_season = .5
	self:StartAutumn()
	self:UpdateSegs()
end

function SeasonManager:AlwaysWinter()
	self.seasonmode = "alwayswinter"
	self.percent_season = .5
	self:StartWinter()
	self:UpdateSegs()
end

function SeasonManager:AlwaysSpring()
	self.seasonmode = "alwaysspring"
	self.percent_season = .5
	self:StartSpring()
	self:UpdateSegs()
end

function SeasonManager:AlwaysSummer()
	self.seasonmode = "alwayssummer"
	self.percent_season = .5
	self:StartSummer()
	self:UpdateSegs()
end

function SeasonManager:Cycle()
	self.seasonmode = "cycle"

	self.winterenabled = true
	self.autumnenabled = true
	self.springenabled = true
	self.summerenabled = true
	self.mildenabled = false
	self.wetenabled = false
	self.greenenabled = false
	self.dryenabled = false

	self.temperateenabled = false
	self.lushenabled = false
	self.humidenabled = false
	self.aporkalypse_enabled = false


	self:SetOverworld()
	self:StartAutumn()
	self:UpdateSegs()
end

function SeasonManager:Tropical()
	self.seasonmode = "tropical"
	--self.precipmode = "dynamic"
	--self.lightningmode = "precip"

	self.winterenabled = false
	self.autumnenabled = false
	self.springenabled = false
	self.summerenabled = false
	self.mildenabled = true
	self.wetenabled = true
	self.greenenabled = true
	self.dryenabled = true

	self.temperateenabled = false
	self.lushenabled = false
	self.humidenabled = false
	self.aporkalypse_enabled = false

	self:SetOverworld()
	--print("mild")
	self:StartMild()
	self:UpdateSegs()	
end

function SeasonManager:Plateau()
	print("PLATEAU")
	self.seasonmode = "plateau"

	self.winterenabled = false
	self.autumnenabled = false
	self.springenabled = false
	self.summerenabled = false
	self.mildenabled = false
	self.wetenabled = false
	self.greenenabled = false
	self.dryenabled = false

	self.temperateenabled = true
	self.lushenabled = true
	self.humidenabled = true
	self.aporkalypse_enabled = true

	self:SetOverworld()

	self:StartTemperate()
	self:UpdateSegs()
end

function SeasonManager:AlwaysWet()
	self.precipmode = "always"
end

function SeasonManager:AlwaysDry()
	self.precipmode = "never"
end

function SeasonManager:OverrideLightningDelays(min, max)
    self.lightningdelays.min = min
    self.lightningdelays.max = max
    if self.precip and self.preciptype == "rain" and min and max then
		self.nextlightningtime = GetRandomMinMax(min, max)
    end
end

function SeasonManager:DefaultLightningDelays()
    self.lightningdelays.min = nil
    self.lightningdelays.max = nil
end

function SeasonManager:LightningWhenRaining()
	self.lightningmode = "rain"
end

function SeasonManager:LightningWhenSnowing()
	self.lightningmode = "snow"
end

function SeasonManager:LightningWhenHurricane()
	self.lightningmode = "hurricane"
end

function SeasonManager:LightningWhenPrecipitating()
	self.lightningmode = "precip"
end

function SeasonManager:LightningAlways()
	self.lightningmode = "always"
end

function SeasonManager:LightningNever()
	self.lightningmode = "never"
end


function SeasonManager:OnRainStart()
	if self.seasonmode == "plateau" then
		self.inst.SoundEmitter:PlaySound("dontstarve_DLC002/rain/islandrainAMB", "rain")
	else
		self.inst.SoundEmitter:PlaySound("dontstarve/rain/rainAMB", "rain")
	end
end

function SeasonManager:OnRainStop()
	self.inst.SoundEmitter:KillSound("rain")
end


function SeasonManager:OnDayComplete()
	if self.seasonmode == "cycle" then
	
		if self:GetSeasonLength() > 0 then
			self.percent_season = self.percent_season + 1/self:GetSeasonLength()
		else
			self.percent_season = 1
		end
		
		if self.percent_season >= 1 then

			if self:IsAutumn() then
				self:StartWinter()
			elseif self:IsWinter() then
				self:StartSpring()
			elseif self:IsSpring() then
				self:StartSummer()
			else
				self:StartAutumn()
			end
		else
			self:UpdateSegs()		
		end
	elseif self.seasonmode == "tropical" then
		if self:GetSeasonLength() > 0 then
			self.percent_season = self.percent_season + 1/self:GetSeasonLength()
		else
			self.percent_season = 1
		end
		
		if self.percent_season >= 1 then
			if self:IsMildSeason() then
				self:StartWet()
			elseif self:IsWetSeason() then
				self:StartGreen()
			elseif self:IsGreenSeason() then
				self:StartDry()
			elseif self:IsDrySeason() then
				self:StartMild()
			else
				self:StartMild()
			end
		else
			self:UpdateSegs()		
		end
	elseif self.seasonmode == "plateau" then
		if self:GetSeasonLength() > 0 then
			self.percent_season = self.percent_season + 1/self:GetSeasonLength()
		else
			self.percent_season = 1
		end

		if self.percent_season >= 1 then
			if self:IsTemperateSeason() then
				self:StartHumid()				
			elseif self:IsHumidSeason() then
				self:StartLush()				
			elseif self:IsLushSeason() then
				self:StartTemperate()
			elseif self:IsAporkalypse() then
				GetAporkalypse():EndAporkalypse()
			else
				self:StartTemperate()
			end
		else
			self:UpdateSegs()		
		end		
	elseif self.seasonmode == "endlesswinter" then
		local day = self:GetDaysIntoSeason()
		if self:IsAutumn() and day >= self.endless_pre then
			self:StartWinter()
			day = 0
		end
		
		if self:IsWinter() then
			if day > self.endless_ramp then
				self.percent_season = .5
			else
				self.percent_season = .5 * (day / self.endless_ramp)
			end
		else
			self.percent_season = .5 + (day / self.endless_pre)*.5
		end
		self:UpdateSegs()
	elseif self.seasonmode == "endlessspring" then
		local day = self:GetDaysIntoSeason()
		if self:IsWinter() and day >= self.endless_pre then
			self:StartSpring()
			day = 0
		end
		
		if self:IsSpring() then
			if day > self.endless_ramp then
				self.percent_season = .5
			else
				self.percent_season = .5 * (day / self.endless_ramp)
			end
		else
			self.percent_season = .5 + (day / self.endless_pre)*.5
		end
		self:UpdateSegs()
	elseif self.seasonmode == "endlesssummer" then
		local day = self:GetDaysIntoSeason()
		if self:IsSpring() and day >= self.endless_pre then
			self:StartSummer()
			day = 0
		end
		
		if self:IsSummer() then
			if day > self.endless_ramp then
				self.percent_season = .5
			else
				self.percent_season = .5 * (day / self.endless_ramp)
			end
		else
			self.percent_season = .5 + (day / self.endless_pre)*.5
		end
		self:UpdateSegs()
	elseif self.seasonmode == "endlessautumn" then
		local day = self:GetDaysIntoSeason()
		if self:IsSummer() and day >= self.endless_pre then
			self:StartAutumn()
			day = 0
		end
		
		if self:IsAutumn() then
			if day > self.endless_ramp then
				self.percent_season = .5
			else
				self.percent_season = .5 * (day / self.endless_ramp)
			end
		else
			self.percent_season = .5 + (day / self.endless_pre)*.5
		end
		self:UpdateSegs()
	end
end

function SeasonManager:SetModifer(mod)
	self.segmod = mod
end

function SeasonManager:ModifySegs(segs)

	local importance = {"day", "night", "dusk"}
	table.sort(importance, function(a,b) return self.segmod[a] < self.segmod[b] end)

	for k,v in pairs(segs) do
		segs[k] = math.ceil(math.clamp(v * self.segmod[k], 0, 14))
	end

	-- for worlds set to only one time for the whole day
	for cat,time in pairs(self.segmod) do
		if time == 3 then
			segs[cat] = 16
			break
		end
	end	

	local total = segs.day + segs.dusk + segs.night

	-- for times when the one category that should be 0 is also supposed to take all the time. 
	if total == 0 then
		for i = 1, #importance do
			if self.segmod[importance[i]] > 0 then 
				segs[importance[i]] = 16
			end
		end		
	end	

	total = segs.day + segs.dusk + segs.night

	while total ~= 16 do
		for i = 1, #importance do
			total = segs.day + segs.dusk + segs.night
			if total == 16 then
				break
			elseif total > 16 and segs[importance[i]] > 1 then
				segs[importance[i]] = segs[importance[i]] - 1
			elseif total < 16  and segs[importance[i]] > 0 then
				segs[importance[i]] = segs[importance[i]] + 1
			end
		end
	end
	
	return segs
end

function SeasonManager:UpdateSegs()

	local p = math.sin(PI*self.percent_season)*.5
	local segs = {day = 0, dusk = 0, night = 0}

	local function get_season(seasonlist, currentseason)
		if seasonlist[currentseason] == nil then
			return currentseason
		end
		local season = seasonlist[currentseason]
		local i, n = 0, #seasonlist
		while i < n and seasonlist[season] and (self:GetSeasonLength(season) <= 0 or self:GetSeasonIsEnabled(season) == false) do
			season = seasonlist[season]
			i = i + 1
		end
		return season
	end
	
	if self.seasonmode == "cycle" then
		local nextSeason = { [SEASONS.SPRING] = SEASONS.SUMMER, [SEASONS.SUMMER] = SEASONS.AUTUMN, [SEASONS.AUTUMN] = SEASONS.WINTER, [SEASONS.WINTER] = SEASONS.SPRING }
		local prevSeason = { [SEASONS.SPRING] = SEASONS.WINTER, [SEASONS.SUMMER] = SEASONS.SPRING, [SEASONS.AUTUMN] = SEASONS.SUMMER, [SEASONS.WINTER] = SEASONS.AUTUMN }

		local nSeason = get_season(nextSeason, self.current_season) --nextSeason[self.current_season]
		local pSeason = get_season(prevSeason, self.current_season) --prevSeason[self.current_season]
		--[[while (self:GetSeasonLength(nSeason) <= 0 or self:GetSeasonIsEnabled(nSeason) == false) do
			nSeason = nextSeason[nSeason]
		end
		while (self:GetSeasonLength(pSeason) <= 0 or self:GetSeasonIsEnabled(pSeason) == false) do
			pSeason = prevSeason[pSeason]
		end]]
		segs.day, segs.night = self:GetDayNightSegs(self.current_season, pSeason, nSeason, self.percent_season, false)
	elseif self.seasonmode == "tropical" then
		local nextSeason = { [SEASONS.MILD] = SEASONS.WET, [SEASONS.WET] = SEASONS.GREEN, [SEASONS.GREEN] = SEASONS.DRY, [SEASONS.DRY] = SEASONS.MILD }
		local prevSeason = { [SEASONS.MILD] = SEASONS.DRY, [SEASONS.WET] = SEASONS.MILD, [SEASONS.GREEN] = SEASONS.WET, [SEASONS.DRY] = SEASONS.GREEN }

		local nSeason = get_season(nextSeason, self.current_season) --nextSeason[self.current_season]
		local pSeason = get_season(prevSeason, self.current_season) --prevSeason[self.current_season]
		--[[while (self:GetSeasonLength(nSeason) <= 0 or self:GetSeasonIsEnabled(nSeason) == false) do
			nSeason = nextSeason[nSeason]
		end
		while (self:GetSeasonLength(pSeason) <= 0 or self:GetSeasonIsEnabled(pSeason) == false) do
			pSeason = prevSeason[pSeason]
		end]]
		segs.day, segs.night = self:GetDayNightSegs(self.current_season, pSeason, nSeason, self.percent_season, false)
	elseif self.seasonmode == "plateau" then
		local nextSeason = { [SEASONS.TEMPERATE] = SEASONS.HUMID, [SEASONS.LUSH] = SEASONS.HUMID, [SEASONS.HUMID] = SEASONS.TEMPERATE }
		local prevSeason = { [SEASONS.TEMPERATE] = SEASONS.HUMID, [SEASONS.HUMID] = SEASONS.LUSH, [SEASONS.LUSH] = SEASONS.TEMPERATE }

		local nSeason = get_season(nextSeason, self.current_season) --nextSeason[self.current_season]
		local pSeason = get_season(prevSeason, self.current_season) --prevSeason[self.current_season]
		--[[while (self:GetSeasonLength(nSeason) <= 0 or self:GetSeasonIsEnabled(nSeason) == false) do
			nSeason = nextSeason[nSeason]
		end
		while (self:GetSeasonLength(pSeason) <= 0 or self:GetSeasonIsEnabled(pSeason) == false) do
			pSeason = prevSeason[pSeason]
		end]]
		segs.day, segs.night = self:GetDayNightSegs(self.current_season, pSeason, nSeason, self.percent_season, false)		
	elseif self.seasonmode == "endlesswinter" then
		segs = self.wintersegs
	elseif self.seasonmode == "endlessspring" then
		segs = self.springsegs
	elseif self.seasonmode == "endlesssummer" then
		segs = self.summersegs
	elseif self.seasonmode == "endlessautumn" then
		segs = self.autumnsegs
	else
		if self:IsWinter() then
			segs.day, segs.night = self.wintersegs.day, self.wintersegs.night
		elseif self:IsSpring() then
			segs.day, segs.night = self.springsegs.day, self.springsegs.night
		elseif self:IsSummer() then
			segs.day, segs.night = self.summersegs.day, self.summersegs.night
		else
			segs.day, segs.night = self.autumnsegs.day, self.autumnsegs.night
		end
	end
	
	segs.dusk = 16 - segs.day - segs.night

	self:ModifySegs(segs)

	local clock = GetClock()

	if self.aporkalypse_transition then

		local aporkalypse = GetAporkalypse()

		if aporkalypse and aporkalypse:IsActive() then

			clock:SetSegsMidEra(segs.day, segs.dusk, segs.night, "night")			
			clock.inst:PushEvent("nighttime", {day=clock.numcycles})
			clock.previous_phase = clock.phase
		else
			local phase = clock:GetPhaseByNormEraTime(clock:GetNormEraTime(), segs.day, segs.dusk, segs.night)
			clock:SetSegsMidEra(segs.day, segs.dusk, segs.night, phase, true)
			clock.inst:PushEvent(phase .. "time", {day=clock.numcycles})
		end

		self.aporkalypse_transition = false
	else
		clock:SetSegs(segs.day, segs.dusk, segs.night)
	end

end

function SeasonManager:GetDayNightSegs(currSeason, prevSeason, nextSeason, pct, endlessSeason)
	local seasonsegs =  {
			[SEASONS.WINTER] = { day = self.wintersegs.day, night = self.wintersegs.night },
			[SEASONS.SPRING] = { day = self.springsegs.day, night = self.springsegs.night },
			[SEASONS.SUMMER] = { day = self.summersegs.day, night = self.summersegs.night },
			[SEASONS.AUTUMN] = { day = self.autumnsegs.day, night = self.autumnsegs.night },

			[SEASONS.MILD] = { day = self.mildsegs.day, night = self.mildsegs.night },
			[SEASONS.WET] = { day = self.wetsegs.day, night = self.wetsegs.night },
			[SEASONS.GREEN] = { day = self.greensegs.day, night = self.greensegs.night },
			[SEASONS.DRY] = { day = self.drysegs.day, night = self.drysegs.night },

			[SEASONS.TEMPERATE] = { day = self.temperatesegs.day, night = self.temperatesegs.night },
			[SEASONS.HUMID] = { day = self.humidsegs.day, night = self.humidsegs.night },
			[SEASONS.LUSH] = { day = self.lushsegs.day, night = self.lushsegs.night },
			[SEASONS.APORKALYPSE] = { day = self.aporkalypse_segs.day, night = self.aporkalypse_segs.night }
		}

	local daysegs = 0
	local nightsegs = 0
	if endlessSeason then
		daysegs = math.floor(easing.linear(1-pct, seasonsegs[prevSeason].day, seasonsegs[currSeason].day-seasonsegs[prevSeason].day, 1) +.5)
		nightsegs = math.floor(easing.linear(1-pct, seasonsegs[prevSeason].night, seasonsegs[currSeason].night-seasonsegs[prevSeason].night, 1) +.5)
	else
		if pct == .5 then
			daysegs = seasonsegs[currSeason].day
			nightsegs = seasonsegs[currSeason].night
		elseif pct == 0 then
			daysegs = math.floor((seasonsegs[currSeason].day + seasonsegs[prevSeason].day) / 2)
			nightsegs = math.floor((seasonsegs[currSeason].night + seasonsegs[prevSeason].night) / 2)
		elseif pct == 1 then
			daysegs = math.floor((seasonsegs[currSeason].day + seasonsegs[nextSeason].day) / 2)
			nightsegs = math.floor((seasonsegs[currSeason].night + seasonsegs[nextSeason].night) / 2)
		elseif pct < .5 then
			local daysegsdelta = seasonsegs[prevSeason].day - seasonsegs[currSeason].day
			local nightsegsdelta = seasonsegs[prevSeason].night - seasonsegs[currSeason].night
			daysegs =   math.floor(.5 + (((.5-pct) *   daysegsdelta) + seasonsegs[currSeason].day))
			nightsegs = math.floor(.5 + (((.5-pct) * nightsegsdelta) + seasonsegs[currSeason].night))
		elseif pct > .5 then
			local daysegsdelta = seasonsegs[nextSeason].day - seasonsegs[currSeason].day
			local nightsegsdelta = seasonsegs[nextSeason].night - seasonsegs[currSeason].night
			daysegs =   math.floor(.5 + (((pct-.5) *   daysegsdelta) + seasonsegs[currSeason].day))
			nightsegs = math.floor(.5 + (((pct-.5) * nightsegsdelta) + seasonsegs[currSeason].night))
		end
	end
	return daysegs, nightsegs
end


function SeasonManager:SetSeasonLengths(autumn, winter, spring, summer)
	self.autumnlength = self.autumnenabled and autumn or 0
	self.winterlength = self.winterenabled and winter or 0
	self.springlength = self.springenabled and spring or 0
	self.summerlength = self.summerenabled and summer or 0
	local seasonsadvanced = 0
	while self:GetSeasonLength() == 0 and seasonsadvanced < 4 do
		self:Advance(true)
		seasonsadvanced = seasonsadvanced + 1
	end
	local per = self:GetPercentSeason()
	self:SetPercentSeason(per)
	self:UpdateSegs()
end

function SeasonManager:SetSeasonsEnabled(autumn, winter, spring, summer)
	self.autumnenabled = self.autumnlength > 0 and autumn or false
	self.winterenabled = self.winterlength > 0 and winter or false
	self.springenabled = self.springlength > 0 and spring or false
	self.summerenabled = self.summerlength > 0 and summer or false
	if not self.autumnenabled then self.autumnlength = 0 end
	if not self.winterenabled then self.winterlength = 0 end
	if not self.springenabled then self.springlength = 0 end
	if not self.summerenabled then self.summerlength = 0 end
	if not self.dryenabled then self.drylength = 0 end
	local seasonsadvanced = 0
	while self:GetSeasonLength() == 0 and seasonsadvanced < 4 do
		self:Advance(true)
		seasonsadvanced = seasonsadvanced + 1
	end
	local per = self:GetPercentSeason()
	self:SetPercentSeason(per)
	self:UpdateSegs()
end

function SeasonManager:SetAutumnLength(len)
	self.autumnlength = self.autumnenabled and len or 0
	if self.autumnlength <= 0 then self.autumnenabled = false end
	local seasonsadvanced = 0
	while self:GetSeasonLength() == 0 and seasonsadvanced < 4 do
		self:Advance(true)
		seasonsadvanced = seasonsadvanced + 1
	end
	local per = self:GetPercentSeason()
	self:SetPercentSeason(per)
	self:UpdateSegs()
end

function SeasonManager:SetWinterLength(len)
	self.winterlength = self.winterenabled and len or 0
	if self.winterlength <= 0 then self.winterenabled = false end
	local seasonsadvanced = 0
	while self:GetSeasonLength() == 0 and seasonsadvanced < 4 do
		self:Advance(true)
		seasonsadvanced = seasonsadvanced + 1
	end
	local per = self:GetPercentSeason()
	self:SetPercentSeason(per)
	self:UpdateSegs()
end

function SeasonManager:SetSpringLength(len)
	self.springlength = self.springenabled and len or 0
	if self.springlength <= 0 then self.springenabled = false end
	local seasonsadvanced = 0
	while self:GetSeasonLength() == 0 and seasonsadvanced < 4 do
		self:Advance(true)
		seasonsadvanced = seasonsadvanced + 1
	end
	local per = self:GetPercentSeason()
	self:SetPercentSeason(per)
	self:UpdateSegs()
end

function SeasonManager:SetSummerLength(len)
	self.summerlength = self.summerenabled and len or 0
	if self.summerlength <= 0 then self.summerenabled = false end
	local seasonsadvanced = 0
	while self:GetSeasonLength() == 0 and seasonsadvanced < 4 do
		self:Advance(true)
		seasonsadvanced = seasonsadvanced + 1
	end
	local per = self:GetPercentSeason()
	self:SetPercentSeason(per)
	self:UpdateSegs()
end

function SeasonManager:SetMildLength(Len)
	self.mildlength = Len
	self.mildenabled = Len > 0
end

function SeasonManager:SetWetLength(Len)
	self.wetlength = Len
	self.wetenabled = Len > 0
end

function SeasonManager:SetGreenLength(Len)
	self.greenlength = Len
	self.greenenabled = Len > 0
end

function SeasonManager:SetDryLength(Len)
	self.drylength = Len
	self.dryenabled = Len > 0
end


function SeasonManager:SetTemperateLength(Len)
	self.temperatelength = Len
	self.temperateenabled = Len > 0
end

function SeasonManager:SetLushLength(Len)
	self.lushlength = Len
	self.lushenabled = Len > 0
end

function SeasonManager:SetHumidLength(Len)
	self.humidlength = Len
	self.humidenabled = Len > 0
end

function SeasonManager:SetAporkalypseLength(Len)
	self.aporkalypse_length = Len
	self.aporkalypse_enabled = Len > 0
end

function SeasonManager:GetSeasonIsEnabled(season)
	local enabled = {
		[SEASONS.AUTUMN] = self.autumnenabled,
		[SEASONS.WINTER] = self.winterenabled,
		[SEASONS.SPRING] = self.springenabled,
		[SEASONS.SUMMER] = self.summerenabled,
		[SEASONS.MILD] = self.mildenabled, 
		[SEASONS.WET] = self.wetenabled,
		[SEASONS.GREEN] = self.greenenabled, 
		[SEASONS.DRY] = self.dryenabled,

		[SEASONS.TEMPERATE] = self.temperateenabled,
		[SEASONS.LUSH] = self.lushenabled, 
		[SEASONS.HUMID] = self.humidenabled
	}
	return enabled[season]
end

function SeasonManager:GetSeasonLength(season)
	local length = {
		[SEASONS.AUTUMN] = self.autumnlength, 
		[SEASONS.WINTER] = self.winterlength,
		[SEASONS.SPRING] = self.springlength, 
		[SEASONS.SUMMER] = self.summerlength,
		[SEASONS.MILD] = self.mildlength, 
		[SEASONS.WET] = self.wetlength,
		[SEASONS.GREEN] = self.greenlength, 
		[SEASONS.DRY] = self.drylength,

		[SEASONS.TEMPERATE] = self.temperatelength,
		[SEASONS.LUSH] = self.lushlength, 
		[SEASONS.HUMID] = self.humidlength,
		[SEASONS.APORKALYPSE] = self.aporkalypse_length,
	}
	if season then --Return the specified season's length
		return length[season] or 0
	else --If no season specified, return current season length
		return length[self.current_season] or 0
	end
end

function SeasonManager:SetSegs(autumn, winter, spring, summer, mild, wet, green, dry, temperate, lush, humid)
	self.autumnsegs = autumn or self.autumnsegs
	self.wintersegs = winter or self.wintersegs
	self.springsegs = spring or self.springsegs
	self.summersegs = summer or self.summersegs
	self.mildsegs = mild or self.mildsegs
	self.wetsegs = wet or self.wetsegs	
	self.greensegs = green or self.greensegs
	self.drysegs = dry or self.drysegs

	self.temperatesegs = temperate or self.temperatesegs
	self.lushsegs = lush or self.lushsegs
	self.humidsegs = humid or self.humidsegs

	self:UpdateSegs()
end


function SeasonManager:SetAppropriateDSP()
	if self:IsWinter() then
		self:ApplyWinterDSP(.5)
	elseif self:IsSummer() then
		self:ApplySummerDSP(.5)
		--
		--
	else
		self:ClearDSP(.5)
	end
end

function SeasonManager:ApplyHumidDSP(time_to_take)
	--[[
	self:ClearDSP(time_to_take, "high")

	for k,v in pairs(self.humiddsp) do
		TheMixer:SetLowPassFilter(k, v, time_to_take)
	end
	]]
end


function SeasonManager:ApplyWinterDSP(time_to_take)
	if USE_SEASON_DSP then
		self:ClearDSP(time_to_take, "high")

		for k,v in pairs(self.winterdsp) do
			TheMixer:SetLowPassFilter(k, v, time_to_take)
		end
	end
end

function SeasonManager:ApplySummerDSP(time_to_take, level)
	if USE_SEASON_DSP then
		self:ClearDSP(time_to_take, "low")
	
		local lvl = level or 1
		for i,j in pairs(self.summerdsp) do
			self.summerdsp[i] = self.summerfreq[lvl]
		end

		for k,v in pairs(self.summerdsp) do
			TheMixer:SetHighPassFilter(k, v, time_to_take)
		end
	end
end

function SeasonManager:ClearDSP(time_to_take, dsp)
	if dsp then
		if dsp == "low" then
			for k,v in pairs(self.winterdsp) do
				TheMixer:ClearLowPassFilter(k, time_to_take)
			end
		elseif dsp == "high" then
			for k,v in pairs(self.summerdsp) do
				TheMixer:ClearHighPassFilter(k, time_to_take)
			end
		end
	else
		for k,v in pairs(self.winterdsp) do
			TheMixer:ClearLowPassFilter(k, time_to_take)
		end
		for k,v in pairs(self.summerdsp) do
			TheMixer:ClearHighPassFilter(k, time_to_take)
		end
	end
end


function SeasonManager:GetCurrentTemperature()
	return self.current_temperature
end

function SeasonManager:GetDaysLeftInSeason()
	if self.seasonmode == "cycle" or self.seasonmode == "tropical" then
    	return (1-self.percent_season) * self:GetSeasonLength()
    elseif self.seasonmode == "endlesswinter" then
		if self:IsWinter() then
			return 10000
		else
			return self.endless_pre - GetClock():GetNumCycles()
		end
    elseif self.seasonmode == "endlessautumn" then
		if self:IsAutumn() then
			return 10000
		else
			return self.endless_pre - GetClock():GetNumCycles()
		end
    elseif self.seasonmode == "endlessspring" then
		if self:IsSpring() then
			return 10000
		else
			return self.endless_pre - GetClock():GetNumCycles()
		end
    elseif self.seasonmode == "endlesssummer" then
		if self:IsSummer() then
			return 10000
		else
			return self.endless_pre - GetClock():GetNumCycles()
		end
    else
    	return 10000
    end
end

function SeasonManager:GetDaysIntoSeason()
	if self.seasonmode == "cycle" or self.seasonmode == "tropical" then
	    return (self.percent_season) * self:GetSeasonLength()
	elseif self.seasonmode == "endlesswinter" then
		if self:IsWinter() then
			return GetClock():GetNumCycles() - self.endless_pre
		else
			return GetClock():GetNumCycles()
		end
	elseif self.seasonmode == "endlessautumn" then
		if self:IsAutumn() then
			return GetClock():GetNumCycles() - self.endless_pre
		else
			return GetClock():GetNumCycles()
		end
    elseif self.seasonmode == "endlessspring" then
		if self:IsSpring() then
			return GetClock():GetNumCycles() - self.endless_pre
		else
			return GetClock():GetNumCycles()
		end
    elseif self.seasonmode == "endlesssummer" then
		if self:IsSummer() then
			return GetClock():GetNumCycles() - self.endless_pre
		else
			return GetClock():GetNumCycles()
		end
    else
		return 10000
	end
end

function SeasonManager:OnSave()
    return 
    {
    	hurricaneoutside = self.hurricaneoutside,
    	precipoutside = self.precipoutside,
		noise_time = self.noise_time,
		percent_season = self.percent_season,
		current_season = self.current_season,
		seasonmode = self.seasonmode,
		ground_snow_level = self.ground_snow_level,
		atmo_moisture = self.atmo_moisture,
		moisture_limit = self.moisture_limit,
		precip = self.precip,
		precip_rate = self.precip_rate,
		preciptype = self.preciptype,
		hail_rate = self.hail_rate,
		moisture_floor = self.moisture_floor,
		peak_precip_intensity = self.peak_precip_intensity,
		lightningmode = self.lightningmode,
		nextlightningtime = self.nextlightningtime,
		autumnlength = self.autumnlength,
		winterlength = self.winterlength,
		springlength = self.springlength,
		summerlength = self.summerlength,
		mildlength = self.mildlength,
		wetlength = self.wetlength,
		greenlength = self.greenlength,
		drylength = self.drylength,

		temperatelength = self.temperatelength,
		lushlength = self.lushlength,
		humidlength = self.humidlength,
		aporkalypse_length = self.aporkalypse_length,

		autumnenabled = self.autumnenabled,
		winterenabled = self.winterenabled,
		springenabled = self.springenabled,
		summerenabled = self.summerenabled,
		mildenabled = self.mildenabled,
		wetenabled = self.wetenabled,
		greenenabled = self.greenenabled,
		dryenabled = self.dryenabled,

		temperateenabled = self.temperateenabled,
		lushenabled = self.lushenabled,
		humidenabled = self.humidenabled,
		aporkalypse_enabled = self.aporkalypse_enabled,

		event = self.initialevent,
		segmod = self.segmod,
		windmode = self.windmode,
		hurricane = self.hurricane,
		hurricane_timer = self.hurricane_timer,
		hurricane_duration = self.hurricane_duration,
		hurricanetease_start = self.hurricanetease_start,
		hurricanetease_started = self.hurricanetease_started,
		hurricane_disablehail = self.hurricane_disablehail,

		windy = self.windy,
		fog_state = self.fog_state,
		fog_time = self.fog_time,

		fogdisabled = self.fogdisabled,

	}
end


function SeasonManager:GetSeasonString()
	if self.current_season == SEASONS.AUTUMN then 
		return "autumn" 
	elseif self.current_season == SEASONS.SPRING then
		return "spring"	
	elseif self.current_season == SEASONS.SUMMER then
		return "summer"
	elseif self.current_season == SEASONS.MILD then
		return "mild"
	elseif self.current_season == SEASONS.WET then
		return "wet"
	elseif self.current_season == SEASONS.GREEN then
		return "green"
	elseif self.current_season == SEASONS.DRY then
		return "dry"
	elseif self.current_season == SEASONS.TEMPERATE then
		return "temperate"
	elseif self.current_season == SEASONS.LUSH then
		return "lush"
	elseif self.current_season == SEASONS.HUMID then
		return "humid"
	elseif self.current_season == SEASONS.APORKALYPSE then
		return "aporkalypse"
	else 
		return "winter" 
	end
end


function SeasonManager:GetDebugString()
	return string.format("%s %2.2f days, %2.2fC, moisture:%2.2f(%2.2f/%2.2f), precip_rate: %2.2f/%2.2f, ground_snow:%2.2f, lightning:%2.2f",
		self:GetSeasonString(), self:GetDaysLeftInSeason(), self.current_temperature, self.atmo_moisture, self.moisture_floor, self.moisture_limit, self.precip_rate, self.peak_precip_intensity, self.ground_snow_level, self.nextlightningtime)
end


function SeasonManager:OnLoad(data)

	self.hurricaneoutside = data.hurricaneoutside or self.hurricaneoutside
	self.precipoutside = data.precipoutside or self.precipoutside
	self.noise_time = data.noise_time or self.noise_time
	self.percent_season = data.percent_season or self.percent_season
	self.current_season = data.current_season or self.current_season
	self.seasonmode = data.seasonmode or self.seasonmode
	self.ground_snow_level = data.ground_snow_level or self.ground_snow_level
	self.atmo_moisture = data.atmo_moisture or self.atmo_moisture
	self.moisture_limit = data.moisture_limit or self.moisture_limit
	self.precip = data.precip or self.precip
	self.precip_rate = data.precip_rate or self.precip_rate
	self.preciptype = data.preciptype or self.preciptype
	self.hail_rate = data.hail_rate or self.hail_rate
	self.moisture_floor = data.moisture_floor or self.moisture_floor
	self.peak_precip_intensity = data.peak_precip_intensity or self.peak_precip_intensity
	self.lightningmode = data.lightningmode or self.lightningmode
	self.nextlightningtime = data.nextlightningtime or self.nextlightningtime
	self.autumnlength = data.autumnlength or self.autumnlength
	self.winterlength = data.winterlength or self.winterlength
	self.springlength = data.springlength or self.springlength
	self.summerlength = data.summerlength or self.summerlength
	self.mildlength = data.mildlength or self.mildlength
	self.wetlength = data.wetlength or self.wetlength
	self.greenlength = data.greenlength or self.greenlength
	self.drylength = data.drylength or self.drylength
	
	self.temperatelength = data.temperatelength or self.temperatelength
	self.lushlength = data.lushlength or self.lushlength
	self.humidlength = data.humidlength or self.humidlength
	self.aporkalypse_length = data.aporkalypse_length or self.aporkalypse_length

	self.autumnenabled = data.autumnenabled or self.autumnenabled
	self.winterenabled = data.winterenabled or self.winterenabled
	self.springenabled = data.springenabled or self.springenabled
	self.summerenabled = data.summerenabled or self.summerenabled
	self.mildenabled = data.mildenabled or self.mildenabled
	self.wetenabled = data.wetenabled or self.wetenabled
	self.greenenabled = data.greenenabled or self.greenenabled
	self.dryenabled = data.dryenabled or self.dryenabled

	self.temperateenabled = data.temperateenabled or self.temperateenabled
	self.lushenabled = data.lushenabled or self.lushenabled
	self.humidenabled = data.humidenabled or self.humidenabled
	self.aporkalypse_enabled = data.aporkalypse_enabled or self.aporkalypse_enabled

	self.segmod = data.segmod or self.segmod
	self.initialevent = data.event or true
	self.windmode = data.windmode or self.windmode

	self.hurricane = data.hurricane or self.hurricane
	self.hurricane_timer = data.hurricane_timer or self.hurricane_timer
	self.hurricane_duration = data.hurricane_duration or self.hurricane_duration
	self.hurricanetease_start = data.hurricanetease_start or self.hurricanetease_start
	self.hurricanetease_started = data.hurricanetease_started or self.hurricanetease_started
	self.hurricane_disablehail = data.hurricane_disablehail or self.hurricane_disablehail

	self.windy = data.windy or self.windy
	self.fog_state = data.fog_state or self.fog_state
	self.fog_time = data.fog_time or self.fog_time
	self.fogdisabled = data.fogdisabled or self.fogdisabled 

	-- Fixup for infinite summer rain bug, so use summer values
	if self.peak_precip_intensity <= 0 then
		self.peak_precip_intensity = math.random(1, 33)/100
	end
	
	self.inst:PushEvent("snowcoverchange", {snow = self.ground_snow_level})
	if self:IsWinter() then
		self:ApplyWinterDSP(0)
	elseif self:IsSummer() then
		self:ApplySummerDSP(0)
	else
		self:ClearDSP(0)
	end
	self:EnqueueSeasonChange()

	if self.precip and self.preciptype == "rain" then
		self.inst:PushEvent("rainstart")
	end

	if self.hurricane then
		self.inst:PushEvent("hurricanestart")
	end
	if self.windy then
		self.inst:PushEvent("windystart")
	end

	self:UpdateSegs()
	
	if GetClock():IsDay() then
	    self:OnDayTime()
	end
end

function SeasonManager:Start()
	self.inst:StartUpdatingComponent(self)
end


function SeasonManager:SetPercentSeason(per)
	self.percent_season = per
end

function SeasonManager:GetPercentSeason()
	
	if self.seasonmode == "cycle" or self.seasonmode == "endlesswinter" or self.seasonmode == "endlessspring"
	or self.seasonmode == "endlesssummer" or self.seasonmode == "endlessautumn" or self.seasonmode == "tropical"
	or self.seasonmode == "plateau" then
		return self.percent_season
    else
		return .5
	end
end


function SeasonManager:GetWeatherLightPercent()

	local dyn_range = .5
	
	if self:IsWinter() then 
		dyn_range = GetClock():IsDay() and .05 or 0
	elseif self:IsSpring() then
		dyn_range = GetClock():IsDay() and .4 or .25
	elseif self:IsSummer() then
		dyn_range = GetClock():IsDay() and .7 or .5
	elseif self:IsMildSeason() then
		dyn_range = GetClock():IsDay() and .05 or 0
	elseif self:IsWetSeason() then
		dyn_range = GetClock():IsDay() and .3 or .5
	elseif self:IsGreenSeason() then
		dyn_range = GetClock():IsDay() and .35 or .25
	elseif self:IsDrySeason() then
		dyn_range = GetClock():IsDay() and .05 or 0

	elseif self:IsTemperateSeason() then
		dyn_range = GetClock():IsDay() and .05 or 0
	elseif self:IsLushSeason() then
		dyn_range = GetClock():IsDay() and .05 or 0
	elseif self:IsHumidSeason() then
		dyn_range = GetClock():IsDay() and .05 or 0
	elseif self:IsAporkalypse() then
		dyn_range = GetClock():IsDay() and .05 or 0
	else
		dyn_range = GetClock():IsDay() and .4 or .25
	end
	
	if self.precipmode == "always" then
		return 1 - dyn_range
	elseif self.precipmode == "never" then
		return 1
	else
		local percent = 1 - math.min(1, math.max(0, (self.atmo_moisture - self.moisture_floor)/ (self.moisture_limit - self.moisture_floor)))

		if self.precip then
			percent = easing.inQuad(percent, 0, 1, 1)
		end


		return percent*dyn_range + (1-dyn_range)
	end
end

function SeasonManager:UpdateDynamicPrecip(dt)
	--print(self:GetDebugString())
	local percent_season = self:GetPercentSeason()
	local atmo_moisture_rate = self.base_atmo_moisture_rate
	if self:IsWinter() then
		--we really want it to snow in early winter, so that we can get an initial ground cover
		if self:GetDaysIntoSeason() > 1 and self:GetDaysIntoSeason() < 3 then
			atmo_moisture_rate = 50
		end
	elseif self:IsAutumn() then
		--it rains less in the middle of autumn
		local p = 1-math.sin(PI*percent_season)
		local min_autumn_rate = .25
		local max_autumn_rate = 1
		atmo_moisture_rate = (min_autumn_rate + p * (max_autumn_rate - min_autumn_rate)) * self.base_atmo_moisture_rate
	elseif self:IsSpring() then
		--we really want it to rain in early spring to show the season change
		--if self:GetDaysIntoSeason() > 1 and self:GetDaysIntoSeason() < 3 then

		--else
			--but it also rains a ton in the middle of spring
			local p = 1-math.sin(PI*percent_season)
			local min_spring_rate = 3
			local max_spring_rate = 3.75
			atmo_moisture_rate = (min_spring_rate + p * (max_spring_rate - min_spring_rate)) * self.base_atmo_moisture_rate
		--end
	elseif self:IsMildSeason() then
		--local p = 1-math.sin(PI*percent_season)
		--local min_summer_rate = .10
		--local max_summer_rate = .5
		--atmo_moisture_rate = (min_summer_rate + p * (max_summer_rate - min_summer_rate)) * self.base_atmo_moisture_rate
		atmo_moisture_rate = 0 --no rain during mild
	elseif self:IsWetSeason() then
		local p = 1-math.sin(PI*1.5*percent_season)
		local min_wet_rate = 3
		local max_wet_rate = 3.75
		atmo_moisture_rate = (min_wet_rate + p * (max_wet_rate - min_wet_rate)) * self.base_atmo_moisture_rate
	elseif self:IsGreenSeason() then
		local days_into_season = self:GetDaysIntoSeason()
		local rain_delay = 5
		if days_into_season <= rain_delay then
			atmo_moisture_rate = 0
		else
			local percent = (days_into_season - rain_delay) / (self:GetSeasonLength(SEASONS.GREEN) - rain_delay)
			local p = 1-math.sin(PI*percent)
			local min_green_rate = 3
			local max_green_rate = 3.75
			atmo_moisture_rate = (min_green_rate + p * (max_green_rate - min_green_rate)) * self.base_atmo_moisture_rate
		end
	elseif self:IsDrySeason() then
		atmo_moisture_rate = 0 --no rain during dry season

	elseif self:IsTemperateSeason() then
		local p = 1-math.sin(PI*percent_season)
		local min_temperate_rate = .25
		local max_temperate_rate = 1
		atmo_moisture_rate = (min_temperate_rate + p * (max_temperate_rate - min_temperate_rate)) * self.base_atmo_moisture_rate
	elseif self:IsHumidSeason() then
		local p = 1-math.sin(PI*1.5*percent_season)
		local min_humid_rate = 3
		local max_humid_rate = 3.75
		atmo_moisture_rate = (min_humid_rate + p * (max_humid_rate - min_humid_rate)) * self.base_atmo_moisture_rate
	elseif self:IsLushSeason() then
		atmo_moisture_rate = 0 --no rain during dry season
		--local p = 1-math.sin(PI*percent_season)
		--local min_lush_rate = .10
		--local max_lush_rate = 0.50
		--atmo_moisture_rate = (min_lush_rate + p * (max_lush_rate - min_lush_rate)) * self.base_atmo_moisture_rate

	else
		--it rains less in summer
		local p = 1-math.sin(PI*percent_season)
		local min_summer_rate = .10
		local max_summer_rate = .5
		atmo_moisture_rate = (min_summer_rate + p * (max_summer_rate - min_summer_rate)) * self.base_atmo_moisture_rate
	end
	
	local RATE_SCALE = 10
	--do delta atmo_moisture and toggle precip on or off 
	if self.precip then
		self.atmo_moisture = self.atmo_moisture - self.precip_rate*dt*RATE_SCALE
		if self.atmo_moisture < 0 then
			self.atmo_moisture = 0
		end

		if self.atmo_moisture < self.moisture_floor then
			self:StopPrecip()
		end

		local percent = math.max(0, math.min(1, (self.atmo_moisture - self.moisture_floor) / (self.moisture_limit - self.moisture_floor)))
		local min_rain = .1
		self.precip_rate = (min_rain + (1-min_rain)*math.sin(percent*PI))
		self.precip_rate = math.clamp(self.precip_rate, 0, self.peak_precip_intensity)	
	else
		self.atmo_moisture = math.min(self.moisture_limit, self.atmo_moisture + atmo_moisture_rate*dt)
		self.precip_rate = 0
		
		if self.atmo_moisture >= self.moisture_limit then
			self.atmo_moisture = self.moisture_limit
			self:StartPrecip()
		end
	end
	--print(string.format("UpdateDynamicPrecip (%s)\n  precip %4.2f/%4.2f\n  atmo %4.2f @ %4.2f (%4.2f)\n  moisture %4.2f - %4.2f\n  pop %4.2f\n", self:GetSeasonString(), self.precip_rate, self.peak_precip_intensity, self.atmo_moisture, atmo_moisture_rate, self.base_atmo_moisture_rate, self.moisture_floor, self.moisture_limit, self:GetPOP()))
end

function SeasonManager:UpdateFog(dt)
	
	local FOG_LEVEL = 900 -- 600

	if self.fog_state == FOG_STATE.FOGGY and not self.fullfog then
		GetPlayer():PushEvent("setfog")
		GetPlayer():PushEvent("startfoggrog")
		self.fullfog = true
	end

	-- manage the fog
	--print("atmo_moisture", self.atmo_moisture, self:IsHumidSeason(),self.fog_state )

	-- fog is created instead of rain during the humid season when it should rain and the atmo moisture is above a threshold

	if self.atmo_moisture > FOG_LEVEL and self:IsHumidSeason() and self.precip then

		if self.fog_state ~= FOG_STATE.FOGGY then
			-- set on course to foggy
			if self.fog_state ~= FOG_STATE.SETTING then
				self.fog_time = self.fog_transition_time_max
				self.fog_state = FOG_STATE.SETTING
			end
			if self.fog_state == FOG_STATE.SETTING then
				self.fog_time = self.fog_time - dt
				if self.fog_time < 5 then
					self:ApplyHumidDSP(5)
					GetPlayer():PushEvent("startfog")
				end
				if self.fog_time < 0 then
					self.fog_state = FOG_STATE.FOGGY
					self.fullfog = true
					GetPlayer():PushEvent("startfoggrog")

				end
			end
		end
	else
		if self.fog_state ~= FOG_STATE.CLEAR then
			if self.fog_state ~= FOG_STATE.LIFTING then
				self:ClearDSP(.5)
				self.fullfog = nil
				GetPlayer():PushEvent("stopfog")
				GetPlayer():PushEvent("stopfoggrog")
				self:OnRainStart()
				self.fog_time = self.fog_transition_time_max
				self.fog_state = FOG_STATE.LIFTING
			end
			if self.fog_state == FOG_STATE.LIFTING then
				self.fog_time = self.fog_time - dt
				if self.fog_time < 0 then
					self.fog_state = FOG_STATE.CLEAR
				end
			end
		end
	end
end

function SeasonManager:GetPeakIntensity()

	local min, max = 1, 100
	if self:IsWinter() then
		min = 10
		max = 80
	elseif self:IsSpring() then
		min = 50
		max = 100

		if self:GetDaysIntoSeason() < 5 then
			min = 33
			max = 66
		end

	elseif self:IsSummer() then
		min = 1
		max = 33
	elseif self:IsMildSeason() then
		min = 33
		max = 66
	elseif self:IsWetSeason() then
		min = 33
		max = 66
	elseif self:IsGreenSeason() then
		min = 100
		max = 200
	elseif self:IsDrySeason() then
		min = 5
		max = 15

	elseif self:IsLushSeason() then		
		min = 5
		max = 15
	elseif self:IsHumidSeason() then
		min = 100
		max = 200
	elseif self:IsTemperateSeason() then
		min = 10
		max = 66
		

	else
		min = 10
		max = 66
	end

	return math.random(min, max)/100
end

function SeasonManager:StartPrecip(continuation)
	if not self.precip then
		self.nextlightningtime = GetRandomMinMax(self.lightningdelays.min or 5, self.lightningdelays.max or 15)
		self.precip = true
		
		local season_floor_scale = 1
		if self:IsWinter() then
			season_floor_scale = 1			
		elseif self:IsSpring() then
			season_floor_scale = 0.25
		elseif self:IsSummer() then
			season_floor_scale = 1.5
		elseif self:IsMildSeason() then
			season_floor_scale = 1
		elseif self:IsWetSeason() then
			season_floor_scale = 0.5
		elseif self:IsGreenSeason() then
			season_floor_scale = 0.25
		elseif self:IsDrySeason() then
			season_floor_scale = 1

		elseif self:IsTemperateSeason() then
			season_floor_scale = 1
		elseif self:IsHumidSeason() then
			season_floor_scale = 0.5
		elseif self:IsLushSeason() then
			season_floor_scale = 1
		else
			season_floor_scale = 1			
		end

		if not continuation then
			self.moisture_floor = (.25 + math.random()*.5) * (self.atmo_moisture*season_floor_scale)
		end

		self.peak_precip_intensity = self:GetPeakIntensity()

		local snow_thresh = self:IsWinter() and 5 or -5

		if self.current_temperature < snow_thresh then
			self.preciptype = "snow"
			self.inst:PushEvent("snowstart")
		else

			self.preciptype = "rain"
			self.inst:PushEvent("rainstart")
		end
	end
end

function SeasonManager:StartCavesRain()
	if self.precipmode == "never" then return end
	
	self.precip = true
	
	self.precip_rate = 0.1
	self.peak_precip_intensity = 0.1
	if self.rain then
		self.rain:Remove()
		self.rain = nil
	end
	self.rain = SpawnPrefab( "rain" )
	self.rain.entity:SetParent( GetPlayer().entity )
	self.rain.Transform:SetPosition(0,0,0)
	self.rain.particles_per_tick = (5 + self.peak_precip_intensity * 25) * self.precip_rate
	self.rain.splashes_per_tick = 1 + 2*self.peak_precip_intensity * self.precip_rate
	self.preciptype = "rain"
	self.inst:PushEvent("rainstart")
end

function SeasonManager:StopCavesRain()
	if self.precip then--and self.incaves then

		if self.rain then
			self.rain.particles_per_tick = 0
			self.rain.splashes_per_tick = 0
		end
		self.precip = false
		self.precip_rate = 0
		
		if self.preciptype == "rain" then
			self.inst:PushEvent("rainstop")
		end
		
		if self:IsWinter() then
			self.moisture_limit = TUNING.TOTAL_DAY_TIME +  math.random()*TUNING.TOTAL_DAY_TIME*3
		elseif self:IsSpring() then
			self.moisture_limit = TUNING.TOTAL_DAY_TIME + math.random()* TUNING.TOTAL_DAY_TIME*3
		elseif self:IsSummer() then
			self.moisture_limit = TUNING.TOTAL_DAY_TIME*4 +  math.random()*TUNING.TOTAL_DAY_TIME*9
		else
			self.moisture_limit = TUNING.TOTAL_DAY_TIME*2 +  math.random()*TUNING.TOTAL_DAY_TIME*6
		end

		self.moisture_limit = math.max(self.moisture_limit, (self.atmo_moisture * 1.2))

	end
end

function SeasonManager:StopPrecip()
	if self.precip then

		if self.snow ~= nil then
			self.snow.particles_per_tick = 0
		end
		
		if self.rain ~= nil then
			self.rain.particles_per_tick = 0
			self.rain.splashes_per_tick = 0
		end

		if self.hail ~= nil then
			self.hail.particles_per_tick = 0
			self.hail.splashes_per_tick = 0
			self.hail.ice_per_tick = 0
			self.hail_rate = 0
		end
		
		self.precip = false
		
		if self.preciptype == "rain" then
			self.inst:PushEvent("rainstop")
		elseif  self.preciptype == "snow" then
			self.inst:PushEvent("snowstop")
		end
		
		if self:IsWinter() then
			self.moisture_limit = TUNING.TOTAL_DAY_TIME +  math.random()*TUNING.TOTAL_DAY_TIME*3
		elseif self:IsSpring() then
			self.moisture_limit = TUNING.TOTAL_DAY_TIME*2 + math.random()*TUNING.TOTAL_DAY_TIME*3.5
		elseif self:IsSummer() then
			self.moisture_limit = TUNING.TOTAL_DAY_TIME*4 +  math.random()*TUNING.TOTAL_DAY_TIME*9
		elseif self:IsMildSeason() then
			self.moisture_limit = TUNING.TOTAL_DAY_TIME*2 + math.random()*TUNING.TOTAL_DAY_TIME*3.5
		elseif self:IsWetSeason() then
			self.moisture_limit = TUNING.TOTAL_DAY_TIME*2 +  math.random()*TUNING.TOTAL_DAY_TIME*3.5
		elseif self:IsGreenSeason() then
			self.moisture_limit = TUNING.TOTAL_DAY_TIME*2 + math.random()*TUNING.TOTAL_DAY_TIME*3.5
		elseif self:IsDrySeason() then
			self.moisture_limit = TUNING.TOTAL_DAY_TIME +  math.random()*TUNING.TOTAL_DAY_TIME*3

		elseif self:IsTemperateSeason() then
			self.moisture_limit = TUNING.TOTAL_DAY_TIME*2 + math.random()*TUNING.TOTAL_DAY_TIME*3.5
		elseif self:IsLushSeason() then
			self.moisture_limit = TUNING.TOTAL_DAY_TIME*2 + math.random()*TUNING.TOTAL_DAY_TIME*3.5
		elseif self:IsHumidSeason() then
			self.moisture_limit = TUNING.TOTAL_DAY_TIME +  math.random()*TUNING.TOTAL_DAY_TIME*3

		else
			self.moisture_limit = TUNING.TOTAL_DAY_TIME*2 +  math.random()*TUNING.TOTAL_DAY_TIME*6
		end

		self.moisture_limit = math.max(self.moisture_limit, (self.atmo_moisture * 1.2))
	end
end

function SeasonManager:IsRaining()
	return self.precip and self.preciptype == "rain" and self.precip_rate > 0
end

function SeasonManager:IsHeavyRaining()
	return self.precip and self.preciptype == "rain" and self.precip_rate > 0.5
end

function SeasonManager:IsFoggy()
	return self.fullfog
end

function SeasonManager:IsHailing()
	return self.precip and self.hail_rate > 0.0
end

function SeasonManager:ForcePrecip()
	self.atmo_moisture = self.moisture_limit
end

function SeasonManager:ForceStopPrecip()
	self.atmo_moisture = 0
end

function SeasonManager:DoMediumLightning()
	GetClock():DoLightningLighting()
	self.inst:DoTaskInTime(.25+math.random()*.5, function() 


		local theta = math.random(0, 2*PI)
		local radius = 10


		local pos = Vector3(GetPlayer().Transform:GetWorldPosition()) +  Vector3(radius * math.cos( theta ), 0, radius * math.sin( theta ))
		local soundplayer = SpawnPrefab("soundplayer")
		soundplayer.PlaySound(pos, "dontstarve/rain/thunder_close")
		--inst.Transform:SetPosition(offset.x,offset.y,offset.z)
		--inst.SoundEmitter:PlaySound("dontstarve/rain/thunder_close")
	end )
end


function SeasonManager:DoLightningStrike(pos, ignoreRods, targetinst)
	if not self.ininterior then
		local player = GetPlayer()
		targetinst = targetinst or player

	    local rod = nil
		local target = nil

		-- Check if we should hit the player
	    if targetinst == player then
		    if player.components.playerlightningtarget 
            and math.random() <= player.components.playerlightningtarget:GetHitChance() then
	    	    target = player
				pos = Vector3(target.Transform:GetWorldPosition() ) 
            end
		else
		    -- targeting something else
	        if math.random() <= TUNING.LIGHTING_HITTARGET_CHANCE then
				target = targetinst
				pos = Vector3(target.Transform:GetWorldPosition() ) 
            end
	    end
		-- now check if there's a rod nearby
		if not ignoreRods then
		    local rods = TheSim:FindEntities(pos.x, pos.y, pos.z, 40, {"lightningrod"}, {"dead"})
		    for k,v in pairs(rods) do -- Find nearby lightning rods, prioritize battery-charging rods and closer rods
		    	print(v.prefab)
		        if not rod or (v.lightningpriority > rod.lightningpriority or distsq(pos, Vector3(v.Transform:GetWorldPosition())) < distsq(pos, Vector3(rod.Transform:GetWorldPosition()))) then
		            rod = v
		        end
		    end
		    if rod then
		        target = rod
				pos = Vector3(target.Transform:GetWorldPosition() ) 
		    end
		end

		local lightning = SpawnPrefab("lightning")
		lightning.Transform:SetPosition(pos:Get())

	    if rod then
	        rod:PushEvent("lightningstrike", {rod=rod})
	    else
	        if target and target.components.playerlightningtarget then
	        	player.components.playerlightningtarget:DoStrike()
	        end

	        local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 3, nil, {"FX", "NOCLICK", "DECOR", "INLIMBO"})
	        for k,v in pairs(ents) do 
			    if not v:IsInLimbo() then
					local protected = false
        			if v.components.inventory and v.components.inventory:IsInsulated() then
            			protected = true
        			end

			        if not protected and v.components.burnable and not v.components.fueled and not v.components.burnable.lightningimmune then
		        	    v.components.burnable:Ignite()
		    	    end
		        end
	        end
	    end
	else
		-- INDOORS, So just make a big boom outside.
		local theta = math.random(0, 2*PI)
		local radius = 10
		local pos = Vector3(GetPlayer().Transform:GetWorldPosition()) +  Vector3(radius * math.cos( theta ), 0, radius * math.sin( theta ))
		local soundplayer = SpawnPrefab("soundplayer")
		soundplayer.PlaySound(pos, "dontstarve/rain/thunder_close")
	end

end


function SeasonManager:GetPOP()
	if self.precip then 
		return 1
	end

	if self.precipmode == "dynamic" then
		return (self.atmo_moisture - self.moisture_floor) / (self.moisture_limit - self.moisture_floor)
	elseif self.precipmode == "always" then
		return 1
	elseif self.precipmode == "never" then
		return 0
	end

	return 0
end

function SeasonManager:BlowoutFire()
	local x, y, z = GetPlayer().Transform:GetWorldPosition()
	local fires = TheSim:FindEntities(x, y, z, 100, {"campfire"})
	print("Found " .. #fires .. " campfires")
	if fires and type(fires) == "table" and #fires > 0 then
		local fire = fires[math.random(1, #fires)]
		if fire and fire.components.burnable and fire.components.burnable:IsBurning() then
			print("Fire Extinguished!")
			fire.components.burnable:Extinguish()
		end
	end
end

local function OnGustStart(windspeed)
	local x, y, z = GetPlayer().Transform:GetWorldPosition()
	local gustables = TheSim:FindEntities(x, y, z, 100, {"gustable"})
	--print(string.format("Found %d gustable entities\n", #gustables))
	if gustables then
		for k, v in pairs(gustables) do
			if v.components.blowinwindgust then
				v.components.blowinwindgust:CallGustStartFn(windspeed)
			end
		end
	end
end

local function OnGustEnd(windspeed)
	local x, y, z = GetPlayer().Transform:GetWorldPosition()
	local gustables = TheSim:FindEntities(x, y, z, 100, {"gustable"})
	--print(string.format("Found %d gustable entities\n", #gustables))
	if gustables then
		for k, v in pairs(gustables) do
			if v.components.blowinwindgust then
				v.components.blowinwindgust:CallGustEndFn(windspeed)
			end
		end
	end
end

function SeasonManager:UpdateHurricaneWind(dt, percent, windstart, windend)
	TheSim:ProfilerPush("hurricanewind")
	if windstart <= percent and percent <= windend then
		self.hurricane_gust_timer = self.hurricane_gust_timer + dt
		
		if self.hurricane_gust_state == HURRICANE_GUST_WAIT then
			self.hurricane_gust_speed = 0
			if self.hurricane_gust_timer >= self.hurricane_gust_period then
				self.hurricane_gust_peak = GetRandomMinMax(TUNING.WIND_GUSTSPEED_PEAK_MIN, TUNING.WIND_GUSTSPEED_PEAK_MAX)
				self.hurricane_gust_timer = 0.0
				self.hurricane_gust_period = TUNING.WIND_GUSTRAMPUP_TIME
				self.hurricane_gust_state = HURRICANE_GUST_RAMPUP
				self.inst:PushEvent("wind_rampup")
				self.inst:PushEvent("windguststart")
			end

		elseif self.hurricane_gust_state == HURRICANE_GUST_RAMPUP then
			local peak = 0.5 * self.hurricane_gust_peak
			self.hurricane_gust_speed = -peak * math.cos(PI * self.hurricane_gust_timer / self.hurricane_gust_period) + peak
			if self.hurricane_gust_timer >= self.hurricane_gust_period then
				self.hurricane_gust_timer = 0.0
				self.hurricane_gust_period = GetRandomMinMax(TUNING.WIND_GUSTLENGTH_MIN, TUNING.WIND_GUSTLENGTH_MAX)
				self.hurricane_gust_state = HURRICANE_GUST_ACTIVE
			end

		elseif self.hurricane_gust_state == HURRICANE_GUST_ACTIVE then
			self.hurricane_gust_speed = self.hurricane_gust_peak
			if self.hurricane_gust_timer >= self.hurricane_gust_period then
				self.hurricane_gust_timer = 0.0
				self.hurricane_gust_period = TUNING.WIND_GUSTRAMPDOWN_TIME
				self.hurricane_gust_state = HURRICANE_GUST_RAMPDOWN
			end

		elseif self.hurricane_gust_state == HURRICANE_GUST_RAMPDOWN then
			local peak = 0.5 * self.hurricane_gust_peak
			self.hurricane_gust_speed = peak * math.cos(PI * self.hurricane_gust_timer / self.hurricane_gust_period) + peak
			if self.hurricane_gust_timer >= self.hurricane_gust_period then
				self.hurricane_gust_timer = 0.0
				self.hurricane_gust_period = GetRandomMinMax(TUNING.WIND_GUSTDELAY_MIN, TUNING.WIND_GUSTDELAY_MAX)
				if self:IsLushSeason() then
					self.hurricane_gust_period = GetRandomMinMax(TUNING.WIND_GUSTDELAY_MIN_LUSH, TUNING.WIND_GUSTDELAY_MAX_LUSH)
				end
				self.hurricane_gust_state = HURRICANE_GUST_WAIT
				self.inst:PushEvent("windgustend")
			end
		end
	else
		self.hurricane_gust_timer = 0.0
		self.hurricane_gust_speed = 0.0
	end
	TheSim:ProfilerPop()
end

function SeasonManager:UpdateDynamicHurricaneStorm(dt)
	TheSim:ProfilerPush("hurricane")
	if self.hurricane then
		self.hurricane_timer = self.hurricane_timer + dt

		local windstart = TUNING.HURRICANE_PERCENT_WIND_START
		local windend = TUNING.HURRICANE_PERCENT_WIND_END
		local rainstart = TUNING.HURRICANE_PERCENT_RAIN_START
		local rainend = TUNING.HURRICANE_PERCENT_RAIN_END
		local hailstart = TUNING.HURRICANE_PERCENT_HAIL_START
		local hailend = TUNING.HURRICANE_PERCENT_HAIL_END
		local lightningstart = TUNING.HURRICANE_PERCENT_LIGHTNING_START
		local lightningend = TUNING.HURRICANE_PERCENT_LIGHTNING_END
		local percent = self.hurricane_timer / self.hurricane_duration
		local windpercent = 0.0 --math.clamp((1.0 / (windend - windstart)) * (percent - windstart), 0.0, 1.0)
		local rainpercent = 0.0 --math.clamp((1.0 / (rainend - rainstart)) * (percent - rainstart), 0.0, 1.0)
		local hailpercent = 0.0 --math.clamp((1.0 / (hailend - hailstart)) * (percent - hailstart), 0.0, 1.0)
		local lightningprecent = 0.0 --math.clamp((1.0 / (lightningend - lightningstart)) * (percent - lightningstart), 0.0, 1.0)
		local lightningbase = 0.0 --0.4 * math.cos(2.0 * PI * lightningprecent) + 0.6

		if self.precipmode ~= "never" then
			rainpercent = math.clamp((1.0 / (rainend - rainstart)) * (percent - rainstart), 0.0, 1.0)
			if not self.hurricane_disablehail then
				hailpercent = math.clamp((1.0 / (hailend - hailstart)) * (percent - hailstart), 0.0, 1.0)			
			end
			self.precip_rate = TUNING.HURRICANE_RAIN_SCALE * math.sin(PI * rainpercent) + 0.1 * math.sin(8.0 * PI * rainpercent)
			self.hail_rate = TUNING.HURRICANE_HAIL_SCALE * math.sin(PI * hailpercent)
		end

		if GetWorld():IsVolcano() then
			self.hail_rate = 0
		end

		if self.windmode == "dynamic" then
			self.hurricane_wind = 0
			self:UpdateHurricaneWind(dt, percent, windstart, windend)
		end

		if self.lightningmode ~= "never" then
			lightningprecent = math.clamp((1.0 / (lightningend - lightningstart)) * (percent - lightningstart), 0.0, 1.0)
			lightningbase = 0.4 * math.cos(2.0 * PI * lightningprecent) + 0.6
			if lightningstart <= percent and percent <= lightningend then
				self.nextlightningtime = self.nextlightningtime - dt
				if self.nextlightningtime <= 0 then
					local min = self.lightningdelays.min or (2 * lightningbase + 2)
					local max = self.lightningdelays.max or (4 * lightningbase + 4)
					self.nextlightningtime = GetRandomMinMax(min, max)

					if self.precip_rate > 0.75 * TUNING.HURRICANE_RAIN_SCALE and math.random() < TUNING.HURRICANE_LIGHTNING_STRIKE_CHANCE then
						local pos = Vector3(GetPlayer().Transform:GetWorldPosition())
						local rad = math.random(2, 10)
						local angle = math.random(0, 2*PI)
						pos = pos + Vector3(rad*math.cos(angle), 0, rad*math.sin(angle))
						self:DoLightningStrike(pos)
					elseif self.precip_rate > 0.5 * TUNING.HURRICANE_RAIN_SCALE then
						self:DoMediumLightning()
					else
						GetPlayer().SoundEmitter:PlaySound("dontstarve/rain/thunder_far")
					end
				end
			end
		end

		--[[print(string.format("Hurricane:\n\t(%4.2f/%4.2f), %4.2f%%, rain %4.2f%%, hail %4.2f%%, wind %4.2f%%, light %4.2f%%\n\tRain %s, %4.2f, drop %4.2f, spash %4.2f\n\tHail %s, %4.2f, drop %4.2f, spash %4.2f, ice %4.2f\n\tWind %s, %4.2f, gust %4.2f (%4.2f/%4.2f)\n\tLightning %s, %4.2f (%4.2f to %4.2f)",
			self.hurricane_timer, self.hurricane_duration, percent, rainpercent, hailpercent, windpercent, lightningprecent,
			self.precipmode, self.precip_rate, self.rain.particles_per_tick, self.rain.splashes_per_tick,
			self.precipmode, self.hail_rate, self.hail.particles_per_tick, self.hail.splashes_per_tick, self.hail.ice_per_tick,
			self.windmode, self:GetHurricaneWindSpeed(), self.hurricane_gust_speed, self.hurricane_gust_timer, self.hurricane_gust_period,
			self.lightningmode, self.nextlightningtime, 2*lightningbase+2, 4*lightningbase+4))]]

		if (self.hurricane_timer >= self.hurricane_duration or self.precipmode == "never") and not self.huricane_seasonduration then
			self:StopHurricaneStorm()
		end		
	else
		self.hurricane_rate = 0

		--print(string.format("Hurricane:\n\tMoisture (%4.2f / %4.2f)\n", self.atmo_moisture, self.moisture_limit))
		
		if self.atmo_moisture >= self.moisture_limit or self.precipmode == "always" then
			self.atmo_moisture = self.moisture_limit
			self:StartHurricaneStorm()
		end 
	end
	TheSim:ProfilerPop()
end

function SeasonManager:UpdateHurricaneTease(dt)
	if self.hurricane then

		self.hurricane_timer = self.hurricane_timer + dt

		local windstart = TUNING.HURRICANE_PERCENT_WIND_START
		local windend = TUNING.HURRICANE_PERCENT_WIND_END
		local rainstart = TUNING.HURRICANE_PERCENT_RAIN_START
		local rainend = TUNING.HURRICANE_PERCENT_RAIN_END
		local percent = self.hurricane_timer / self.hurricane_duration
		local windpercent = math.clamp((1.0 / (windend - windstart)) * (percent - windstart), 0.0, 1.0)
		local rainpercent = math.clamp((1.0 / (rainend - rainstart)) * (percent - rainstart), 0.0, 1.0)

		self.hurricane_wind = 0
		self.precip_rate = 0.4 * math.sin(8 * PI * rainpercent - PI/2) + 0.4

		self:UpdateHurricaneWind(dt, percent, windstart, windend)

		--[[print(string.format("Hurricane:\n\t(%4.2f/%4.2f), %4.2f%%, tease %4.2f%%, rain %4.2f%%, wind %4.2f%%\n\tRain %4.2f, drop %4.2f, spash %4.2f\n\tWind %4.2f, gust %4.2f (%4.2f/%4.2f)",
			self.hurricane_timer, self.hurricane_duration, percent, self.hurricanetease_start, rainpercent, windpercent,
			self.precip_rate, self.rain.particles_per_tick, self.rain.splashes_per_tick,
			self:GetHurricaneWindSpeed(), self.hurricane_gust_speed, self.hurricane_gust_timer, self.hurricane_gust_period))]]

		if self.hurricane_timer >= self.hurricane_duration then
			self:StopHurricaneTease()
		end		
	else
		self.hurricane_rate = 0

		--print(string.format("Hurricane tease: %f / %f\n", self.hurricanetease_start, self:GetPercentSeason()))
		
		local seasonpercent = self:GetPercentSeason()
		if seasonpercent >= self.hurricanetease_start and not self.hurricanetease_started then
			self.atmo_moisture = self.moisture_limit
			self:StartHurricaneTease()
		end
	end
end

function SeasonManager:StartHurricaneStorm(duration_override, disablehail)
	if not self:IsHurricaneStorm() then
		self.hurricane = true
		
		self.atmo_moisture = self.moisture_limit
		--self.precipmode = "hurricane"
		--self.lightningmode = "hurricane"
		self:StartPrecip()
		--local season_floor_scale = 0.25
		--self.moisture_floor = (.25 + math.random()*.5) * (self.atmo_moisture*season_floor_scale)
		self.hurricane_disablehail = disablehail
		self.hurricane_peak_intensity = 100
		self.hurricane_rate = 0
		self.hurricane_timer = 0

		self.huricane_seasonduration = nil
		self.hurricane_duration = math.random(TUNING.HURRICANE_LENGTH_MIN, TUNING.HURRICANE_LENGTH_MAX)

		if duration_override == "season" then
			self.huricane_seasonduration = true		
		elseif duration_override then			
			self.hurricane_duration = duration_override 
		end

		if not self:IsWindy() then
			self.hurricane_wind = 0.0
			self.hurricane_gust_speed = 0.0
			self.hurricane_gust_timer = 0.0
			self.hurricane_gust_period = 0.0 --GetRandomWithVariance(10.0, 4.0)
			self.hurricane_gust_peak = 0.0 --GetRandomWithVariance(0.5, 0.25)
			self.hurricane_gust_state = HURRICANE_GUST_WAIT
		end
		--print("Hurricane: " .. self.hurricane_duration)

		self.inst:PushEvent("hurricanestart")
	end
end

function SeasonManager:StopHurricaneStorm()
	if self:IsHurricaneStorm() then
		--stop hurricane weather things
		self:StopPrecip()
		self.hurricane = false

		if not self:IsWindy() then
			self.hurricane_wind = 0.0
			self.hurricane_gust_speed = 0.0
			self.hurricane_gust_timer = 0.0
			self.hurricane_gust_period = 0.0
			self.hurricane_gust_peak = 0.0
			self.hurricane_gust_state = HURRICANE_GUST_WAIT
		end

		self.hurricane_disablehail = nil		
		self.atmo_moisture = 0.0
		--self.atmo_moisture = self.moisture_limit --let rain linger off
		--self.precipmode = "dynamic"
		--self.lightningmode = "precip"
		--self:DefaultLightningDelays()
		self.inst:PushEvent("hurricanestop")
	end
end

function SeasonManager:StartHurricaneTease(duration_override)
	self:StartHurricaneStorm()
	--self.lightningmode = "never"
	self.hurricane_duration = duration_override or TUNING.HURRICANE_TEASE_LENGTH
	self.hurricanetease_started = true
end

function SeasonManager:StopHurricaneTease()
	self:StopHurricaneStorm()
end

function SeasonManager:IsHurricaneStorm()
	return self.hurricane
end

function SeasonManager:GetHurricanePercent()
	return self.hurricane_timer / self.hurricane_duration
end

function SeasonManager:GetHurricaneWindSpeed()
	return self.hurricane_wind + self.hurricane_gust_speed
end

function SeasonManager:StartWind()
	if not self:IsWindy() then
		self.windy = true
		if not self:IsHurricaneStorm() then
			self.hurricane_wind = 0.0
			self.hurricane_gust_speed = 0.0
			self.hurricane_gust_timer = 0.0
			self.hurricane_gust_period = 0.0 --GetRandomWithVariance(10.0, 4.0)
			self.hurricane_gust_peak = 0.0 --GetRandomWithVariance(0.5, 0.25)
			self.hurricane_gust_state = HURRICANE_GUST_WAIT	
			self.inst:PushEvent("windstart")
		end
	end
end

function SeasonManager:StopWind()
	if self:IsWindy() then
		self.windy = false
		if not self:IsHurricaneStorm() then
			self.hurricane_wind = 0.0
			self.hurricane_gust_speed = 0.0
			self.hurricane_gust_timer = 0.0
			self.hurricane_gust_period = 0.0 --GetRandomWithVariance(10.0, 4.0)
			self.hurricane_gust_peak = 0.0 --GetRandomWithVariance(0.5, 0.25)
			self.hurricane_gust_state = HURRICANE_GUST_WAIT	
			self.inst:PushEvent("windstop")
		end
	end
end
	
function SeasonManager:IsWindy()
	return self.windy
end

function SeasonManager:UpdateDynamicWind(dt)
	local windstart = TUNING.HURRICANE_PERCENT_WIND_START
	local windend = TUNING.HURRICANE_PERCENT_WIND_END
	local seasonpercent = self:GetPercentSeason()
	if self.windmode == "dynamic" then
		self.hurricane_wind = 0
		self:UpdateHurricaneWind(dt, seasonpercent, windstart, windend)	
	end
end

function SeasonManager:OnUpdate( dt )	
	--print ("time to pass:", dt)

	if self.target_season then
		if self.current_season ~= self.target_season then
			local fn = self.seasonfns[self.target_season]
			fn(self)
		end

		if self.current_season == SEASONS.SPRING and self.incaves then
			self:StartCavesRain()
		elseif self.incaves then
			self:StopCavesRain()
		end
		self.target_season = nil
	end

	local pt = GetPlayer():GetPosition()
    local tile = GetWorld().Map:GetTileAtPoint(pt.x,pt.y,pt.z)
    self.ininterior = (tile == GROUND.INTERIOR)

	if self.target_percent then
		self.percent_season = self.target_percent
		self:UpdateSegs()
		self.target_percent = nil
	end

	--figure out our temperature (we still want temperature in caves, so outside the block)
	local min_temp = TUNING.MIN_SEASON_TEMP
	local max_temp = TUNING.MAX_SEASON_TEMP
	local summer_crossover_temp = TUNING.SUMMER_CROSSOVER_TEMP
	local winter_crossover_temp = TUNING.WINTER_CROSSOVER_TEMP
	local day_heat = TUNING.DAY_HEAT
	local night_cold = TUNING.NIGHT_COLD
	local dusk_cold = 0

	local season_temp = 0
	local percent_season = self:GetPercentSeason()
	
	if self.seasonmode == "plateau" then
		day_heat = TUNING.PLATEAU_DAY_TEMP
		night_cold = TUNING.PLATEAU_NIGHT_TEMP
		dusk_cold = 0
		if self.current_season == SEASONS.HUMID then
			local base_temp = TUNING.PLATEAU_HUMID_START_TEMP - ((TUNING.PLATEAU_HUMID_START_TEMP - TUNING.PLATEAU_TEMPERATE_START_TEMP) * percent_season)
			local dev_temp = (math.sin(PI*percent_season) * TUNING.PLATEAU_HUMID_DEVIATE_TEMP)

			season_temp = base_temp + dev_temp

			day_heat = 0
			dusk_cold = TUNING.PLATEAU_HUMID_DUSK_TEMP_INCREASE
			night_cold = TUNING.PLATEAU_HUMID_NIGHT_TEMP_INCREASE
			
		elseif self.current_season == SEASONS.LUSH then
			if self:GetPercentSeason() > 0.1 then
				if GetPlayer().components.hayfever and not GetPlayer().components.hayfever.enabled then
					GetPlayer().components.hayfever:Enable()
				end
			end

			local base_temp = TUNING.PLATEAU_LUSH_START_TEMP - ((TUNING.PLATEAU_LUSH_START_TEMP - TUNING.PLATEAU_HUMID_START_TEMP) * percent_season)
			local dev_temp =  (math.sin(PI*percent_season) * TUNING.PLATEAU_LUSH_DEVIATE_TEMP)
			
			season_temp = base_temp + dev_temp

--			print("LUSH TEMP",base_temp,dev_temp,season_temp)
			day_heat = TUNING.PLATEAU_LUSH_DAY_TEMP_INCREASE
			night_cold = TUNING.PLATEAU_LUSH_NIGHT_TEMP_INCREASE
			dusk_cold = TUNING.PLATEAU_LUSH_DUSK_TEMP_INCREASE
		else				
			season_temp = TUNING.PLATEAU_TEMPERATE_START_TEMP - ((TUNING.PLATEAU_TEMPERATE_START_TEMP - TUNING.PLATEAU_LUSH_START_TEMP) * percent_season) --Lerp(TUNING.PLATEAU_TEMPERATE_START_TEMP, TUNING.PLATEAU_LUSH_START_TEMP, percent_season)
			day_heat = TUNING.PLATEAU_DAY_TEMP
			night_cold = TUNING.PLATEAU_NIGHT_TEMP
		end

		if self.current_season ~= SEASONS.LUSH and self:GetPercentSeason() > 0.02 then
			if GetPlayer().components.hayfever and GetPlayer().components.hayfever.enabled then
				 GetPlayer().components.hayfever:Disable()
			end
		end		
		
--		print("SEASON TEMP =",season_temp, percent_season)
	elseif self.seasonmode == "tropical" then		

		if GetPlayer().components.hayfever.enabled then
			GetPlayer().components.hayfever:Disable()
		end

		--just do something mild until this is sorted
		local dry_crossover_temp = TUNING.TROPICAL_DRY_STARTEND_TEMP
		local wet_crossover_temp = TUNING.TROPICAL_WET_STARTEND_TEMP
		min_temp = TUNING.TROPICAL_WET_MID_TEMP
		max_temp = TUNING.TROPICAL_DRY_MID_TEMP
		day_heat = TUNING.TROPICAL_DAY_TEMP
		night_cold = TUNING.TROPICAL_NIGHT_TEMP

		if self.current_season == SEASONS.MILD then
			if GetClock():GetNumCycles() < 10 then
				season_temp = Lerp(TUNING.TROPICAL_MILD_START_TEMP, wet_crossover_temp, percent_season)
			else
				season_temp = Lerp(dry_crossover_temp, wet_crossover_temp, percent_season)
			end
		elseif self.current_season == SEASONS.WET then
			local hurricane_temp = 0
			local hurricane_wind_temp = 0
			if self:IsHurricaneStorm() then
				hurricane_temp = TUNING.TROPICAL_HURRICANE_TEMP * math.sin(PI * (self.hurricane_timer / self.hurricane_duration))
				hurricane_wind_temp = TUNING.TROPICAL_HURRICANE_WIND_TEMP * self:GetHurricaneWindSpeed()
			end
			season_temp = -math.sin(PI*percent_season)*(wet_crossover_temp - min_temp) + wet_crossover_temp + hurricane_temp + hurricane_wind_temp
		elseif self.current_season == SEASONS.GREEN then
			season_temp = Lerp(wet_crossover_temp, dry_crossover_temp, percent_season)
		else --SEASONS.DRY
			season_temp = math.sin(PI*percent_season)*(max_temp - dry_crossover_temp) + dry_crossover_temp
			if self:IsRaining() then
				season_temp = math.min(max_temp, season_temp + TUNING.TROPICAL_DRY_RAIN_TEMP)
			end
		end
	else
		if self.current_season == SEASONS.WINTER then
			season_temp = -math.sin(PI*percent_season)*(winter_crossover_temp- min_temp) + winter_crossover_temp
			if self.incaves then
				season_temp = math.max(min_temp, season_temp - TUNING.CAVES_TEMP)
			end
		elseif self.current_season == SEASONS.SPRING then

			if GetClock():GetNumCycles() < 10 then
				--Don't be super cold if you start in spring :)
				season_temp = Lerp(TUNING.SPRING_START_WINTER_CROSSOVER_TEMP, summer_crossover_temp, percent_season)
			else
				season_temp = Lerp(winter_crossover_temp, summer_crossover_temp, percent_season)
			end
			
		elseif self.current_season == SEASONS.SUMMER then
			season_temp = math.sin(PI*percent_season)*(max_temp - summer_crossover_temp) + summer_crossover_temp
			if self.incaves then
				season_temp = math.min(max_temp, season_temp + TUNING.CAVES_TEMP)
			elseif self.precip and self.preciptype == "rain" then
				season_temp = math.min(max_temp, season_temp + TUNING.SUMMER_RAIN_TEMP)
			end
		else
			if GetClock():GetNumCycles() < 10 then
				--Don't be super hot if you start in autumn :)
				season_temp = Lerp(TUNING.AUTUMN_START_SUMMER_CROSSOVER_TEMP, summer_crossover_temp, percent_season)
			else
				season_temp = Lerp(summer_crossover_temp, winter_crossover_temp, percent_season)
			end
		end
	end
		
	local time_temp = 0
	local normtime = GetClock():GetNormEraTime()
	local is_day = GetClock():IsDay()
	if is_day then
		time_temp = day_heat*math.sin(normtime*PI)
	elseif GetClock():IsDusk() then
		time_temp = dusk_cold*math.sin(normtime*PI)
	elseif GetClock():IsNight() then
		time_temp = night_cold*math.sin(normtime*PI)
	end
--	print("day effect",time_temp)
	
	local noise_scale = .025
	local noise_mag = 8
	local temperature_noise = (2*noise_mag)*perlin(0,0,self.noise_time*noise_scale) - noise_mag
	
	self.current_temperature = temperature_noise + season_temp + time_temp

--	print("FINAL TEMP", self.current_temperature, "TEMP-night day dev",time_temp,"temperature_noise",temperature_noise)

	--print(string.format("Temp: season %d + time %d + noise %d = %d", season_temp, time_temp, temperature_noise, self.current_temperature))
	
	self.noise_time = self.noise_time + dt

	-- A bunch of stuff specific to not being in the caves (precipitation + wildfires, mostly)
	if not self.incaves and not self.ininterior then
	    if self.precip and self.preciptype == "rain" then
	    	local precip_rate = self.precip_rate
	    	if GetPlayer() and GetPlayer().components.moisture and GetPlayer().components.moisture.sheltered then
	    		precip_rate = precip_rate - .4
	    	elseif GetPlayer() and GetPlayer().components.inventory 
	    	and GetPlayer().components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) 
	    	and GetPlayer().components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS):HasTag("umbrella") then
	    		precip_rate = precip_rate - .4
	    	end
	    	if precip_rate < 0 then precip_rate = 0 end
		    self.inst.SoundEmitter:SetParameter("rain", "intensity", precip_rate)
		    if (precip_rate % 0.1) < 0.001 then
		    	if GetWorld() and GetWorld().components.ambientsoundmixer then
		    		GetWorld().components.ambientsoundmixer:SetRainChanged()
		    	end
--		    	print("rain rain go away" .. " " .. self.precip_rate)
		    end
	    end
	    
		if self.lightningmode == "always"
		   or (self.precip and self.lightningmode == "precip")
		   or (self.precip and self.preciptype == self.lightningmode) then
			self.nextlightningtime = self.nextlightningtime - dt

			if self.nextlightningtime <= 0 and not self:IsHurricaneStorm() then

				local min = self.lightningdelays.min or easing.linear(self.precip_rate, 30, 10, 1)
				local max = self.lightningdelays.max or (min + easing.linear(self.precip_rate, 30, 10, 1) )
				self.nextlightningtime = GetRandomMinMax(min, max)

				--local isHurricane = self:IsHurricaneStorm() --hurricane does it's own lightning

				if self.precip_rate > 0.75 or self.lightningmode == "always" then
				--if (self.precip_rate > 0.75 and ((not isHurricane) or (isHurricane and math.random() < 0.01))) or self.lightningmode == "always" then
					local pos = Vector3(GetPlayer().Transform:GetWorldPosition())
					local rad = math.random(2, 10)
					local angle = math.random(0, 2*PI)
					pos = pos + Vector3(rad*math.cos(angle), 0, rad*math.sin(angle))
					self:DoLightningStrike(pos)
				elseif self.precip_rate > 0.5 then
					self:DoMediumLightning()
				else
					GetPlayer().SoundEmitter:PlaySound("dontstarve/rain/thunder_far")
				end
			end
		end

		if not self.snow then
			self.snow = SpawnPrefab( "snow" )
			self.snow.entity:SetParent( GetPlayer().entity )
			self.snow.particles_per_tick = 0
		end
		
		if not self.rain then
			self.rain = SpawnPrefab( "rain" )
			self.rain.entity:SetParent( GetPlayer().entity )
			self.rain.particles_per_tick = 0
			self.rain.splashes_per_tick = 0
		end

		if not self.hail then
			self.hail = SpawnPrefab( "hail" )
			self.hail.entity:SetParent( GetPlayer().entity )
			self.hail.particles_per_tick = 0
			self.hail.splashes_per_tick = 0
			self.hail.ice_per_tick = 0
		end
		
		if self.current_season == SEASONS.SUMMER or self.current_season == SEASONS.LUSH and not self.ininterior then			
			local particles = TUNING.POLLEN_PARTICLES

			if self.current_season == SEASONS.LUSH then
				particles = TUNING.PLATEAU_LUSH_POLLEN_PARTICLES
			end		
			if not self.pollen then
		 		self.pollen = SpawnPrefab( "pollen" )
		 		self.pollen.entity:SetParent( GetPlayer().entity )
		 	end
		 	if self.percent_season <= .2 then
		 		local ramp = self.percent_season / .2
		 		self.pollen.particles_per_tick = ramp * particles
		 	elseif self.percent_season >= .8 then
		 		local ramp = (1 - self.percent_season) / .2
		 		self.pollen.particles_per_tick = ramp * particles
		 	else
		 		self.pollen.particles_per_tick = particles
		 	end
		else
		 	if self.pollen then self.pollen:Remove() end
		end

		if self.current_season == SEASONS.WET or (self.current_season ~= SEASONS.MILD and self.hurricane) then
			self:UpdateDynamicHurricaneStorm(dt)
		elseif self.current_season == SEASONS.MILD then
			self:UpdateHurricaneTease(dt)
		end
		
		if self.current_season == SEASONS.LUSH then
			self:UpdateDynamicWind(dt)
		end

		if self.precipmode == "dynamic" and not self.hurricane then
			self:UpdateDynamicPrecip(dt)
		elseif self.precipmode == "always" then
			if not self.precip then
				self:StartPrecip()
			end
			self.precip_rate = .1+perlin(0,self.noise_time*.1,0)*.9
		elseif self.precipmode == "never" then
			if self.precip then
				self:StopPrecip()
			end
		end

		--update the precip particle effects, and switch between the precip types if appropriate
		if self.precip then
			local tick_time = TheSim:GetTickTime()
			if self.preciptype == "snow" then
				self.snow.particles_per_tick = 20 * self.precip_rate
				self.rain.particles_per_tick = 0
				self.rain.splashes_per_tick = 0
				self.hail.particles_per_tick = 0
				self.hail.splashes_per_tick = 0

				local stop_snow_thresh = self:IsWinter() and 10 or 0
				if self.current_temperature > stop_snow_thresh then
					self.preciptype = "rain"
					self.inst:PushEvent("rainstart")
					self.inst:PushEvent("snowstop")
				end
			else
				self.rain.particles_per_tick = (5 + self.peak_precip_intensity * 25) * self.precip_rate
				self.rain.splashes_per_tick = 8*self.peak_precip_intensity * self.precip_rate
				self.hail.particles_per_tick = (5 + self.peak_precip_intensity * 25) * self.hail_rate
				self.hail.splashes_per_tick = 16*self.peak_precip_intensity * self.hail_rate
				self.hail.ice_per_tick = 0.05 * self.hail_rate
				self.snow.particles_per_tick = 0

				local start_snow_thresh = self:IsWinter() and 2 or -8
				if self.current_temperature < start_snow_thresh and not self:IsTropical() and not self:IsPlateau() then
					self.preciptype = "snow"
					self.inst:PushEvent("rainstop")
					self.inst:PushEvent("snowstart")
				end
			end

			-- kill everything if it's supposed to be fog
			if self.fullfog then
				self.snow.particles_per_tick = 0
				self.rain.particles_per_tick = 0
				self.rain.splashes_per_tick = 0
				self.hail.particles_per_tick = 0
				self.hail.splashes_per_tick = 0
				
				self.inst:PushEvent("rainstop")
				self.inst:PushEvent("snowstop")
			end
		end

		if not self.fogdisabled then
			self:UpdateFog(dt)
		end

		local SNOW_ACCUM_RATE = 1/300
		local MIN_SNOW_MELT_RATE = 1/120
		local SNOW_MELT_RATE = 1/20

		--accumulate snow on the ground
		local last_ground_snow = self.ground_snow_level
		if self.precip and self.preciptype == "snow" then
			self.ground_snow_level = self.ground_snow_level + self.precip_rate*dt*SNOW_ACCUM_RATE
			if self.ground_snow_level > 1 then
				self.ground_snow_level = 1
			end
			
			if math.floor(last_ground_snow*100) ~= math.floor(self.ground_snow_level*100) then
				self.inst:PushEvent("snowcoverchange", {snow = self.ground_snow_level})	
			end
		end
		
		--make snow melt
		if self.ground_snow_level > 0 and self.current_temperature > 0 and not (self.precip and self.preciptype == "snow") then
			local percent = math.min(1, (self.current_temperature) / (20))
			local melt_rate = percent *SNOW_MELT_RATE + MIN_SNOW_MELT_RATE
			self.ground_snow_level = self.ground_snow_level - melt_rate*dt
			if self.ground_snow_level <= 0 then
				self.ground_snow_level = 0
			end
			
			if math.floor(last_ground_snow*100) ~= math.floor(self.ground_snow_level*100) then
				self.inst:PushEvent("snowcoverchange", {snow = self.ground_snow_level})	
			end
		end

		--GROUND OVERLAY HERE - SNOW AND RAIN PUDDLES
		if self.current_season == "winter" then
			GetWorld().Map:SetOverlayLerp( self.ground_snow_level * 3)
		elseif self.current_season == "spring" then
			GetWorld().Map:SetOverlayLerp( GetWorld().components.moisturemanager:GetWorldMoisture()/100 * 3)
		end

		if (last_ground_snow < SNOW_THRESH) ~= (self.ground_snow_level < SNOW_THRESH) then
			for k,v in pairs(Ents) do
				if v:HasTag("SnowCovered") then
					if self.ground_snow_level < SNOW_THRESH then
						v.AnimState:Hide("snow")
					else
						v.AnimState:Show("snow")
					end
				end
			end
		end

		if self.current_season == SEASONS.SUMMER then
		    -- If it's summer and hot enough, try to start a wildfire every so often (once per seg, currently)
			if self.current_temperature >= TUNING.WILDFIRE_THRESHOLD and not self:IsRaining() then
				if self.wildfire_retry_time > 0 then
					self.wildfire_retry_time = self.wildfire_retry_time - dt
					if self.wildfire_retry_time <= 0 then
						if math.random() <= TUNING.WILDFIRE_CHANCE then
							local x, y, z = GetPlayer().Transform:GetWorldPosition()
							local firestarters = TheSim:FindEntities(x, y, z, 25, {"wildfirestarter_highprio"}, {"protected", "burnt", "NOCLICK", "INLIMBO"})
							if #firestarters == 0 then
								firestarters = TheSim:FindEntities(x, y, z, 25, {"wildfirestarter"}, {"protected", "burnt", "NOCLICK", "INLIMBO"})
							end
							if #firestarters > 0 then
								local origin = firestarters[math.random(1, #firestarters)]
								local attempts = 0
								local foundvalidstarter = self:CheckValidWildfireStarter(origin)
								while attempts < #firestarters and not foundvalidstarter do
									origin = firestarters[math.random(1, #firestarters)]
									foundvalidstarter = self:CheckValidWildfireStarter(origin)
									attempts = attempts + 1
								end
								if self:CheckValidWildfireStarter(origin) then 
									origin.components.burnable:StartWildfire()
								end
							end
						end
					end
				else
					self.wildfire_retry_time = TUNING.WILDFIRE_RETRY_TIME
				end
			else
				self.wildfire_retry_time = TUNING.WILDFIRE_RETRY_TIME
			end
		end

		if self.current_season == SEASONS.SUMMER or self.current_season == SEASONS.DRY or self.current_season == SEASONS.LUSH then
	        -- apply intensity modulation effect to the screen (summer only)
            if self.bloom_enabled then
	            self.bloom_time_current = self.bloom_time_current + dt	
	            if self.bloom_time_to_new_modifier <= self.bloom_time_current then
	                if is_day then
	                    -- only start a new cycle is it's still daytime
	                    local new_period = math.random(SUMMER_BLOOM_PERIOD_MIN, SUMMER_BLOOM_PERIOD_MAX)
	                    self.bloom_modifier = 2.0 * math.pi / new_period
	                    self.bloom_time_to_new_modifier = new_period
	                    self.bloom_time_current = 0.0
	                else
	                    -- bloom is off during dusk and night
	                    self.bloom_enabled = false
	                    self.bloom_time_current = 0.0
	                    self.bloom_time_to_new_modifier = 0.0
	                    self.bloom_modifier = 0.0
	                end
	            end
        	    
	            -- This is essentially a sine wave [sin(x - pi/2) = 1 - cos(x)] with amplitude 0 - 1, shifted to the left so that the magnitude is zero at time zero
	            -- The result is multiplied to a combination of a base intensity value and a time-of-day temperature dependant value
	            -- Finally we add this to the original intensity (1.0) so that we're always increasing the total intensity
	            local modifier = 1.0 + (1.0 - 0.5 * math.cos( self.bloom_time_current * self.bloom_modifier ) ) * (SUMMER_BLOOM_BASE + SUMMER_BLOOM_TEMP_MODIFIER * time_temp)
	            PostProcessor:SetColourModifier(modifier)
            end					
		end
	else
		-- in cave or in in interior
		self.hurricane_gust_timer = 0.0
		self.hurricane_gust_speed = 0.0
	end

	if self.precip and self.ininterior then
		-- reset the art for the rain snow and hail if character is inside.
		if self.snow then		
			self.snow.particles_per_tick = 0
		end
		if self.rain then
			self.rain.particles_per_tick = 0
			self.rain.splashes_per_tick = 0
		end
		if self.hail then
			self.hail.particles_per_tick = 0
			self.hail.splashes_per_tick = 0
		end
	end

	--Lastly, wither any plants that need withering (caves and overworld)
	if (self.current_season == SEASONS.SUMMER or self.current_season == SEASONS.DRY) and self.current_temperature > TUNING.SW_MIN_PLANT_WITHER_TEMP then
		--Delay the wither message a bit so we're not sending this event every tick during summer
		if self.wither_delay <= 0 then
			self.inst:PushEvent("witherplants", {temp=self.current_temperature})
			self.wither_delay = math.random(30,60)
		else
			self.wither_delay = self.wither_delay - 1
		end
	--And rejuvenate any plants that need rejuvenating (caves and overworld)
	elseif self.current_season ~= SEASONS.SUMMER and self.current_season ~= SEASONS.DRY and self.current_temperature < TUNING.SW_MAX_PLANT_REJUVENATE_TEMP then
		--Delay the rejuvenate message a bit so we're not sending this event every tick during non-summer
		if self.rejuvenate_delay <= 0 then
			self.inst:PushEvent("rejuvenateplants", {temp=self.current_temperature})
			self.rejuvenate_delay = math.random(30,60)
		else
			self.rejuvenate_delay = self.rejuvenate_delay - 1
		end
	end
end

function SeasonManager:CheckValidWildfireStarter(obj)
	if obj and obj:IsValid() and obj.components.burnable and not obj:HasTag("fireimmune") then
		if obj.components.inventoryitem and obj.components.inventoryitem.owner then
			return false --Item in player's inventory
		end
		if not obj.components.pickable and not obj.components.crop and not obj.components.growable then
			return true --Non-plant
		end
		if obj.components.pickable and obj.components.pickable:IsWildfireStarter() then
			return true --Wild plants
		end
		if obj.components.crop and obj.components.crop:IsWithered() then
			return true --Farm/crop plant
		end
		if obj.components.workable and obj.components.workable:GetWorkAction() == ACTIONS.CHOP then
			return true --Tree
		end
	end
	return false
end

function SeasonManager:GetPrecipitationRate()
	return self.precip_rate
end

function SeasonManager:GetHailRate()
	return self.hail_rate
end

function SeasonManager:GetMoistureLimit()
	return self.moisture_limit
end

function SeasonManager:StartWinter()
	print("WINTER TIME")
	self.current_season = SEASONS.WINTER
	if self.seasonmode == "cycle" or self.seasonmode == "endlesswinter" or self.seasonmode == "endlessspring" then
		self.percent_season = 0
	else
		self.percent_season = .5
	end
	
	if self.winterlength > 0 then
		if not self.incaves and not self.ininterior then
			self:EnqueueSeasonChange()
			self:ApplyWinterDSP(5)
		end

		if self.incaves then
			self:StopCavesRain() --If we're in the caves and it's not spring, stop the light rain
		end

		self:UpdateSegs()

		if GetWorld() and GetWorld().components.ambientsoundmixer then
    		GetWorld().components.ambientsoundmixer:SetSeasonChanged()
    	end
	else
		self:Advance(true)
	end
end

function SeasonManager:StartSpring(first)
	print("SPRING TIME")
	self.current_season = SEASONS.SPRING
	if self.seasonmode == "cycle" or self.seasonmode == "endlessspring" or self.seasonmode == "endlesssummer" then
		self.percent_season = 0
	else
		self.percent_season = .5
	end

	if self.springlength > 0 then
		if self.incaves then
			self:StartCavesRain()
		else
			self:EnqueueSeasonChange()
			self:ClearDSP(5)
		end
		self:UpdateSegs()

		if not first and not self.incaves and not self.ininterior then
			self.atmo_moisture = 3000
			self.moisture_limit = 2999
		end

		if GetWorld() and GetWorld().components.ambientsoundmixer then
    		GetWorld().components.ambientsoundmixer:SetSeasonChanged()
    	end
	else
		self:Advance(true)
	end
end

function SeasonManager:StartSummer()
	print("SUMMER TIME")
	self.current_season = SEASONS.SUMMER
	if self.seasonmode == "cycle" or self.seasonmode == "endlesssummer" or self.seasonmode == "endlessautumn" then
		self.percent_season = 0
	else
		self.percent_season = .5
	end

	if self.summerlength > 0 then
		if not self.incaves and not self.ininterior then
			self:EnqueueSeasonChange()
			self:ApplySummerDSP(5)
		end

		if self.incaves then
			self:StopCavesRain() --If we're in the caves and it's not spring, stop the light rain
		end

		self:UpdateSegs()

		if GetWorld() and GetWorld().components.ambientsoundmixer then
    		GetWorld().components.ambientsoundmixer:SetSeasonChanged()
    	end
	else
		self:Advance(true)
	end
end

function SeasonManager:StartAutumn()
	print("AUTUMN TIME")
	self.current_season = SEASONS.AUTUMN
	if self.seasonmode == "cycle" or self.seasonmode == "endlessautumn" or self.seasonmode == "endlesswinter" then
		self.percent_season = 0
	else
		self.percent_season = .5
	end

	if self.autumnlength > 0 then
		if not self.incaves and not self.ininterior then
			self:EnqueueSeasonChange()
			self:ClearDSP(5)
		end

		if self.incaves then
			self:StopCavesRain() --If we're in the caves and it's not spring, stop the light rain
		end

		self:UpdateSegs()

		if GetWorld() and GetWorld().components.ambientsoundmixer then
    		GetWorld().components.ambientsoundmixer:SetSeasonChanged()
    	end
	else
		self:Advance(true)
	end
end

function SeasonManager:StartMild()
	print("MILD SEASON")
	self.current_season = SEASONS.MILD
	if self.seasonmode == "tropical" or self.seasonmode == "endlessmild" then
		self.percent_season = 0
	else
		self.percent_season = .5
	end

	if self.mildlength > 0 then
		self:EnqueueSeasonChange()
		self:StopHurricaneStorm()
		self:ApplySummerDSP(5)
		self:UpdateSegs()
		self.hurricanetease_start = math.random(6, 15) / 20
		self.hurricanetease_started = false

		if GetWorld() and GetWorld().components.ambientsoundmixer then
    		GetWorld().components.ambientsoundmixer:SetSeasonChanged()
    	end
	else
		self:Advance(true)
	end
end

function SeasonManager:StartWet()
	print("WET SEASON")
	self.current_season = SEASONS.WET
	if self.seasonmode == "tropical" or self.seasonmode == "endlesswet" then
		self.percent_season = 0
	else
		self.percent_season = .5
	end

	if self.wetlength > 0 then
		self:EnqueueSeasonChange()
		self:ApplySummerDSP(5)
		self:UpdateSegs()

		if GetWorld() and GetWorld().components.ambientsoundmixer then
    		GetWorld().components.ambientsoundmixer:SetSeasonChanged()
    	end
	else
		self:Advance(true)
	end
end

function SeasonManager:StartGreen()
	print("GREEN SEASON")
	self.current_season = SEASONS.GREEN
	if self.seasonmode == "tropical" or self.seasonmode == "endlessgreen" then
		self.percent_season = 0
	else
		self.percent_season = .5
	end

	if self.greenlength > 0 then
		self:EnqueueSeasonChange()
		self:StopHurricaneStorm()
		self:ApplySummerDSP(5)
		self:UpdateSegs()

		if GetWorld() and GetWorld().components.ambientsoundmixer then
    		GetWorld().components.ambientsoundmixer:SetSeasonChanged()
    	end
	else
		self:Advance(true)
	end
end

function SeasonManager:StartDry()
	print("DRY SEASON")
	self.current_season = SEASONS.DRY
	if self.seasonmode == "tropical" or self.seasonmode == "endlessdry" then
		self.percent_season = 0
	else
		self.percent_season = .5
	end

	if self.drylength > 0 then
		self:EnqueueSeasonChange()
		self:StopHurricaneStorm()
		self:ApplySummerDSP(5)
		self:UpdateSegs()

		if GetWorld() and GetWorld().components.ambientsoundmixer then
    		GetWorld().components.ambientsoundmixer:SetSeasonChanged()
    	end
	else
		self:Advance(true)
	end
end


-- PORKLAND WEATHER TYPES
function SeasonManager:StartTemperate()
	print("TEMPERATE SEASON")
	self.current_season = SEASONS.TEMPERATE
	if self.seasonmode == "plateau" or self.seasonmode == "endlesstemperate"  then
		self.percent_season = 0
	else
		self.percent_season = .5
	end

	if self.temperatelength > 0 then
		self:StopHurricaneStorm()
		self:StopWind()
		self:EnqueueSeasonChange()
		self:ClearDSP(5)
		self:UpdateSegs()
		self.hurricanetease_start = math.random(6, 15) / 20
		self.hurricanetease_started = false

		if GetWorld() and GetWorld().components.ambientsoundmixer then
    		GetWorld().components.ambientsoundmixer:SetSeasonChanged()
    	end
	else
		self:Advance(true)
	end
end
function SeasonManager:StartHumid()
	print("HUMID SEASON")
	self.current_season = SEASONS.HUMID
	if self.seasonmode == "plateau" or self.seasonmode == "endlesshumid" then
		self.percent_season = 0
	else
		self.percent_season = .5
	end
	
	if self.humidlength > 0 then
		self:StopHurricaneStorm()
		self:StopWind()
		self:EnqueueSeasonChange()
		self:UpdateSegs()

		if GetWorld() and GetWorld().components.ambientsoundmixer then
    		GetWorld().components.ambientsoundmixer:SetSeasonChanged()
    	end
	else
		self:Advance(true)
	end
end

function SeasonManager:StartLush(first)
	print("LUSH SEASON")
	self.current_season = SEASONS.LUSH
	if self.seasonmode == "plateau" or self.seasonmode == "endlesslush" then
		self.percent_season = 0
	else
		self.percent_season = .5
	end

	if self.lushlength > 0 then
		self:StopHurricaneStorm()
		self:StartWind()
		self:EnqueueSeasonChange()
		self:ClearDSP(5)

		self:UpdateSegs()

		-- not sure what this does yet.. do I Want it?
		--[[ 
		if not first and not self.incaves then
			self.atmo_moisture = 3000
			self.moisture_limit = 2999
		end
		]]

		if GetWorld() and GetWorld().components.ambientsoundmixer then
    		GetWorld().components.ambientsoundmixer:SetSeasonChanged()
    	end
	else
		self:Advance(true)
	end
end

function SeasonManager:StartAporkalypse(first)
	print("APORKALYPSE")
	self.aporkalypse_transition = true

	self.pre_aporkalypse_season = self.current_season
	self.pre_aporkalypse_percent = self.percent_season
	self.current_season = SEASONS.APORKALYPSE

	if self.seasonmode == "plateau" or self.seasonmode == "endlessaporkalypse" then
		self.percent_season = 0
	else
		self.percent_season = .5
	end

	if self.aporkalypse_length > 0 then
		self:StopHurricaneStorm()
		self:StartWind()
		self:EnqueueSeasonChange()
		self:ClearDSP(5)		
		self:UpdateSegs()
		
		if GetWorld() and GetWorld().components.ambientsoundmixer then
    		GetWorld().components.ambientsoundmixer:SetSeasonChanged()
    	end
	else
		self:ResumePreviousSeason()		
	end
end

function SeasonManager:ResumePreviousSeason()
	self.aporkalypse_transition = true
	if not self.pre_aporkalypse_season then
		self:StartTemperate()
	else
		self:SetSeason(self.pre_aporkalypse_season)
		self.percent_season = self.pre_aporkalypse_percent or 0
	end
end

function SeasonManager:IsTropical()
	return self.seasonmode == "tropical"
end

function SeasonManager:IsPlateau()
	return self.seasonmode == "plateau"
end

function SeasonManager:IsAutumn()
	return self.current_season == SEASONS.AUTUMN
end

function SeasonManager:IsWinter()
	return self.current_season == SEASONS.WINTER
end

function SeasonManager:IsSpring()
	return self.current_season == SEASONS.SPRING
end

function SeasonManager:IsSummer()
	return self.current_season == SEASONS.SUMMER
end

function SeasonManager:IsMildSeason()
	return self.current_season == SEASONS.MILD
end

function SeasonManager:IsWetSeason() -- aka hurricane
	return self.current_season == SEASONS.WET
end

function SeasonManager:IsGreenSeason() -- aka really rainy
	return self.current_season == SEASONS.GREEN
end

function SeasonManager:IsDrySeason() -- aka Volcano, aka Hot
	return self.current_season == SEASONS.DRY
end

function SeasonManager:IsTemperateSeason() 
	return self.current_season == SEASONS.TEMPERATE
end

function SeasonManager:IsLushSeason()
	return self.current_season == SEASONS.LUSH
end

function SeasonManager:IsHumidSeason() 
	return self.current_season == SEASONS.HUMID
end

function SeasonManager:IsAporkalypse()
	return self.current_season == SEASONS.APORKALYPSE
end

function SeasonManager:GetSnowPercent()
    return self.ground_snow_level
end

function SeasonManager:Advance(force)
	if self.seasonmode == "cycle" then
		self.percent_season = self.percent_season + 1/self:GetSeasonLength()
		
		if self.percent_season > 1 or force then
			self.percent_season = 0
			if self:IsWinter() then
				self:StartSpring()
			elseif self:IsSpring() then
				self:StartSummer()
			elseif self:IsSummer() then
				self:StartAutumn()
			else
				self:StartWinter()
			end
		end
		self:UpdateSegs()
	elseif self.seasonmode == "tropical" then
		self.percent_season = self.percent_season + 1/self:GetSeasonLength()
		
		if self.percent_season > 1 or force then
			self.percent_season = 0
			if self:IsMildSeason() then
				self:StartWet()
			elseif self:IsWetSeason() then
				self:StartGreen()
			elseif self:IsGreenSeason() then
				self:StartDry()
			elseif self:IsDrySeason() then
				self:StartMild()
			else
				self:StartMild()
			end
		end
		self:UpdateSegs()
	elseif self.seasonmode == "plateau" then
		self.percent_season = self.percent_season + 1/self:GetSeasonLength()
		
		if self.percent_season > 1 or force then
			self.percent_season = 0
			if self:IsTemperateSeason() then
				self:StartHumid()
			elseif self:IsHumidSeason() then
				self:StartLush()
			elseif self:IsAporkalypse() then
				GetAporkalypse():EndAporkalypse()
			else
				self:StartTemperate()
			end
		end
		self:UpdateSegs()
	end
end

function SeasonManager:GetTemperature()
	return self.current_temperature
end

function SeasonManager:Retreat(force)
	if self.seasonmode == "cycle" then
		
		self.percent_season = self.percent_season - 1/self:GetSeasonLength()
		if self.percent_season < 0 or force then
			self.percent_season = self:GetSeasonLength() > 0 and 1 - 1/self:GetSeasonLength() or 1
			if self:IsWinter() then
				self:StartAutumn()
			elseif self:IsAutumn() then
				self:StartSummer()
			elseif self:IsSummer() then
				self:StartSpring()
			else
				self:StartWinter()
			end
		end
		self:UpdateSegs()
	elseif self.seasonmode == "tropical" then
		self.percent_season = self.percent_season - 1/self:GetSeasonLength()
		if self.percent_season < 0 or force then
			self.percent_season = self:GetSeasonLength() > 0 and 1 - 1/self:GetSeasonLength() or 1
			if self:IsMildSeason() then
				self:StartDry()
			elseif self:IsDrySeason() then
				self:StartGreen()
			elseif self:IsGreenSeason() then
				self:StartWet()
			elseif self:IsWetSeason() then
				self:StartMild()
			else
				self:StartMild()
			end
		end
		self:UpdateSegs()
	elseif self.seasonmode == "plateau" then
		self.percent_season = self.percent_season - 1/self:GetSeasonLength()
		if self.percent_season < 0 or force then
			self.percent_season = self:GetSeasonLength() > 0 and 1 - 1/self:GetSeasonLength() or 1
			if self:IsTemperateSeason() then
				self:StartHumid()
			elseif self:IsLushSeason() then
				self:StartTemperate()
			elseif self:IsAporkalypse() then
				GetAporkalypse():EndAporkalypse()
			else
				self:StartLush()			
			end
		end
		self:UpdateSegs()		
	end
end

function SeasonManager:GetSeason()
	--print("RETURN SEASON",self.current_season)
	return self.current_season
end

function SeasonManager:SetSeason(season)
	if season == SEASONS.AUTUMN then
		self:StartAutumn()
	elseif season == SEASONS.WINTER then
		self:StartWinter()
	elseif season == SEASONS.SPRING then
		self:StartSpring()
	elseif season == SEASONS.SUMMER then
		self:StartSummer()
	elseif season == SEASONS.MILD then
		self:StartMild()
	elseif season == SEASONS.WET then
		self:StartWet()
	elseif season == SEASONS.GREEN then
		self:StartGreen()
	elseif season == SEASONS.DRY then
		self:StartDry()
	elseif season == SEASONS.TEMPERATE then
		self:StartTemperate()
	elseif season == SEASONS.LUSH then
		self:StartLush()
	elseif season == SEASONS.HUMID then
		self:StartHumid()
	elseif season == SEASONS.APORKALYPSE then
		self:StartAporkalypse()
	else
		print ("ERROR! UNKNOWN SEASON!")
	end
end

function SeasonManager:LongUpdate(dt)
	--print("SeasonManager:LongUpdate " .. dt)
	self:OnUpdate(dt)
end

function SeasonManager:OnDayTime()
    self.bloom_enabled = true
end

return SeasonManager