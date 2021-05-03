local easing = require("easing")


--Note to self, colour cube assets are loaded in the shipwrecked prefab 


local ColourCubeManager = Class(function(self, inst)
	self.inst = inst

	self.OnTransitionFinished = nil

	self.IDENTITY_COLOURCUBE = "images/colour_cubes/identity_colourcube.tex"

	self.INSANITY_CCS =
	{
		DAY = "images/colour_cubes/insane_day_cc.tex",
		DUSK = "images/colour_cubes/insane_dusk_cc.tex",
		NIGHT = "images/colour_cubes/insane_night_cc.tex",
		FULL_MOON = "images/colour_cubes/insane_night_cc.tex",
	}

	self.SEASON_CCS = {
		[SEASONS.AUTUMN] = {	DAY = "images/colour_cubes/day05_cc.tex",
								DUSK = "images/colour_cubes/dusk03_cc.tex",
								NIGHT = "images/colour_cubes/night03_cc.tex",
								FULL_MOON = "images/colour_cubes/purple_moon_cc.tex"
						   },
		[SEASONS.WINTER] = {	DAY = "images/colour_cubes/snow_cc.tex",
								DUSK = "images/colour_cubes/snowdusk_cc.tex",
								NIGHT = "images/colour_cubes/night04_cc.tex",
								FULL_MOON = "images/colour_cubes/purple_moon_cc.tex"
							},
		[SEASONS.SPRING] = {	DAY = "images/colour_cubes/spring_day_cc.tex",
								DUSK = "images/colour_cubes/spring_dusk_cc.tex",
								NIGHT = "images/colour_cubes/spring_dusk_cc.tex",--"images/colour_cubes/spring_night_cc.tex",
								FULL_MOON = "images/colour_cubes/purple_moon_cc.tex"
						   },
	    [SEASONS.SUMMER] = {	DAY = "images/colour_cubes/summer_day_cc.tex",
								DUSK = "images/colour_cubes/summer_dusk_cc.tex",
								NIGHT = "images/colour_cubes/summer_night_cc.tex",
								FULL_MOON = "images/colour_cubes/purple_moon_cc.tex"
						   },
		[SEASONS.CAVES] = {		DAY = "images/colour_cubes/caves_default.tex",
								DUSK = "images/colour_cubes/caves_default.tex",
								NIGHT = "images/colour_cubes/caves_default.tex",
								FULL_MOON = "images/colour_cubes/purple_moon_cc.tex"
							},
	    [SEASONS.MILD] = {		DAY = "images/colour_cubes/sw_mild_day_cc.tex",
								DUSK = "images/colour_cubes/SW_mild_dusk_cc.tex",
								NIGHT = "images/colour_cubes/SW_mild_dusk_cc.tex",
								FULL_MOON = "images/colour_cubes/purple_moon_cc.tex"
						   },
	    [SEASONS.WET] = {		DAY = "images/colour_cubes/sw_wet_day_cc.tex",
								DUSK = "images/colour_cubes/sw_wet_dusk_cc.tex",
								NIGHT = "images/colour_cubes/sw_wet_dusk_cc.tex",
								FULL_MOON = "images/colour_cubes/purple_moon_cc.tex"
						   },
	    [SEASONS.GREEN] = {		DAY = "images/colour_cubes/sw_green_day_cc.tex",
								DUSK = "images/colour_cubes/sw_green_dusk_cc.tex",
								NIGHT = "images/colour_cubes/sw_green_dusk_cc.tex",
								FULL_MOON = "images/colour_cubes/purple_moon_cc.tex"
						   },
	    [SEASONS.DRY] = {		DAY = "images/colour_cubes/sw_dry_day_cc.tex",
								DUSK = "images/colour_cubes/sw_dry_dusk_cc.tex",
								NIGHT = "images/colour_cubes/sw_dry_dusk_cc.tex",
								FULL_MOON = "images/colour_cubes/purple_moon_cc.tex"
						   },

		--PORKLAND SEASONS

		[SEASONS.TEMPERATE] = {	
								DAY = "images/colour_cubes/pork_temperate_day_cc.tex",
								DUSK = "images/colour_cubes/pork_temperate_dusk_cc.tex",
								NIGHT = "images/colour_cubes/pork_temperate_night_cc.tex",
								FULL_MOON = "images/colour_cubes/pork_temperate_fullmoon_cc.tex",
						   },
	    [SEASONS.HUMID] = {		
	    						DAY = "images/colour_cubes/pork_cold_day_cc.tex",
								DUSK = "images/colour_cubes/pork_cold_dusk_cc.tex",
								NIGHT = "images/colour_cubes/pork_cold_dusk_cc.tex",
								FULL_MOON = "images/colour_cubes/pork_cold_fullmoon_cc.tex",
						   },
	    [SEASONS.LUSH] = {		
	    						DAY = "images/colour_cubes/pork_lush_day_test.tex",
								DUSK = "images/colour_cubes/pork_lush_dusk_test.tex",
								NIGHT = "images/colour_cubes/pork_lush_dusk_test.tex",
								FULL_MOON = "images/colour_cubes/pork_warm_fullmoon_cc.tex",	
							},					
		[SEASONS.APORKALYPSE] = {
								DAY = "images/colour_cubes/pork_cold_bloodmoon_cc.tex",
								DUSK = "images/colour_cubes/pork_cold_bloodmoon_cc.tex",
								NIGHT = "images/colour_cubes/pork_cold_bloodmoon_cc.tex",
								FULL_MOON = "images/colour_cubes/pork_cold_bloodmoon_cc.tex",
							},
	}

	self.CC_OVERRIDE_TILES = {}
--	self.CC_OVERRIDE_TILES[GROUND.DEEPRAINFOREST] = "JUNGLE"
--  self.CC_OVERRIDE_TILES[GROUND.GASJUNGLE] = "JUNGLE"

	self.NIGHTMARE_CCS = 
	{
		CALM = "images/colour_cubes/ruins_dark_cc.tex",
		WARN = "images/colour_cubes/ruins_dim_cc.tex",
		NIGHTMARE = "images/colour_cubes/ruins_light_cc.tex",
		DAWN = "images/colour_cubes/ruins_dim_cc.tex",
		FULL_MOON = "images/colour_cubes/ruins_dark_cc.tex"
	}

	self.VOLCANO_CCS =
	{
		DORMANT = "images/colour_cubes/sw_volcano_cc.tex",
		ACTIVE = "images/colour_cubes/sw_volcano_active_cc.tex"
	}

	local cc, insanity_cc = self:GetDestColourCubes()
	self.current_cc = 
	{
		[0] = cc,
		[1] = insanity_cc,
	}

	PostProcessor:SetColourCubeData( 0, cc, cc )
	PostProcessor:SetColourCubeData( 1, insanity_cc, insanity_cc )

	self.transition_time_left = nil
	self.total_transition_time = 1

	--self.inst:ListenForEvent("changearea", function() self:StartBlend(4) end, GetWorld())
	self.inst:ListenForEvent("daytime", function() self:StartBlend(4) end, GetWorld())
	self.inst:ListenForEvent("dusktime", function() self:StartBlend(6) end, GetWorld())
	self.inst:ListenForEvent("nighttime", function() self:StartBlend(8) end, GetWorld())
	self.inst:ListenForEvent("seasonChange", function() self:StartBlend(10) end, GetWorld())
	self.inst:ListenForEvent("phasechange", function(inst, data) self:StartBlend(TUNING.TRANSITIONTIME[string.upper(data.newphase)]) end, GetWorld()) --nightmare events

	self.inst:StartUpdatingComponent(self)
end)

function ColourCubeManager:StartBlend(time_to_take)
--	print("WORLD EXISTED ",GetWorld().components.seasonmanager:GetSeason())
	if self.override then
		return
	end
	self.total_transition_time = time_to_take
	self.transition_time_left = time_to_take

	--print("Starting blend",self.total_transition_time,self.transition_time_left)
	local old_cc = self.current_cc[0]
	local old_sanity_cc = self.current_cc[1]
	self.current_cc[0], self.current_cc[1] = self:GetDestColourCubes()

	PostProcessor:SetColourCubeData( 0, old_cc, self.current_cc[0] )
	PostProcessor:SetColourCubeLerp( 0, 0 )
	PostProcessor:SetColourCubeData( 1, old_sanity_cc, self.current_cc[1] )
	--print ("Channel 0:", old_cc, self.current_cc[0])
	--print ("Channel 1:", old_sanity_cc, self.current_cc[1])
	--print ("start lerp", time_to_take)
end

function ColourCubeManager:GetDestColourCubes()
	local world = GetWorld()
	local season_idx = SEASONS.AUTUMN

	if world and world.components.seasonmanager then		
		season_idx = world.components.seasonmanager:GetSeason()
		if world.components.seasonmanager.incaves then
			season_idx = SEASONS.CAVES	
		end
	end
	
	local time_idx = "DAY"
	if world and world.components.clock and not world.components.nightmareclock then
		if world.components.clock:IsDusk() then
			time_idx = "DUSK"
		elseif world.components.clock:IsNight() then
			if world.components.clock:GetMoonPhase() == "full" and not world:IsCave() then
				time_idx = "FULL_MOON"
			else
				time_idx = "NIGHT"
			end
		end
	end

	local player = GetPlayer()

	local area_idx = ""
	if player and player.components.area_aware and player.components.area_aware.tile then
		local tile = player.components.area_aware.tile
		if self.CC_OVERRIDE_TILES[tile] then
			area_idx =  self.CC_OVERRIDE_TILES[tile] .."_"
		end
	end

	local nightmare_idx = "CALM"
	if world and world.components.nightmareclock then
		if world.components.nightmareclock:IsWarn() then
			nightmare_idx = "WARN"
		elseif world.components.nightmareclock:IsNightmare() then
			nightmare_idx = "NIGHTMARE"
		elseif world.components.nightmareclock:IsDawn() then
			nightmare_idx = "DAWN"
		end
	end	

	-- It seems that in very rare cases (some combination of custom worldgen settings) season_idx is somehow becoming invalid and causing a crash indexing a field that doesn't exist
	--local cc = self.SEASON_CCS[ season_idx ][time_idx]
	local cc_season = self.SEASON_CCS[ season_idx ] or self.SEASON_CCS[ SEASONS.AUTUMN ]
	local cc = cc_season[time_idx]
	
	if world ~= nil and world:IsCave() and world.topology ~= nil and world.topology.level_number == 2 then
		--We're in the ruins, use the nightmare colour cubes
		cc = self.NIGHTMARE_CCS[nightmare_idx]
	end

	if world and world:IsVolcano() then
		if GetVolcanoManager():IsActive() then
			cc = self.VOLCANO_CCS.ACTIVE
		else
			cc = self.VOLCANO_CCS.DORMANT
		end
	end

	if self.interior then
		cc = self.interior
	end

	local insanity_cc = self.INSANITY_CCS[time_idx]

	return cc, insanity_cc
end

function ColourCubeManager:SetInteriorColourCube(cc)
	self.interior = cc
	self:StartBlend(0)
end

function ColourCubeManager:SetOverrideColourCube(cc, blendtime)
	if cc then
		if blendtime then
			self.total_transition_time = blendtime
			self.transition_time_left = blendtime

			local old_cc = self.override or self.current_cc[0]
			local old_sanity_cc = self.override or self.current_cc[1]

			PostProcessor:SetColourCubeData( 0, old_cc, cc )
			PostProcessor:SetColourCubeLerp( 0, 0 )
			PostProcessor:SetColourCubeData( 1, old_sanity_cc, cc )
		else
			PostProcessor:SetColourCubeData( 0, cc, cc )
			PostProcessor:SetColourCubeData( 1, cc, cc )
		end
	else
		if blendtime then
			self.total_transition_time = blendtime
			self.transition_time_left = blendtime

			local old_cc = self.override or self.current_cc[0]
			local old_sanity_cc = self.override or self.current_cc[1]

			self.current_cc[0], self.current_cc[1] = self:GetDestColourCubes()
			PostProcessor:SetColourCubeData( 0, old_cc, self.current_cc[0] )
			PostProcessor:SetColourCubeLerp( 0, 0 )
			PostProcessor:SetColourCubeData( 1, old_sanity_cc, self.current_cc[1] )
		else
			self.current_cc[0], self.current_cc[1] = self:GetDestColourCubes()
			PostProcessor:SetColourCubeData( 0, self.current_cc[0], self.current_cc[0] )
			PostProcessor:SetColourCubeData( 1, self.current_cc[1], self.current_cc[1] )
		end
	end

	self.override = cc
end

function ColourCubeManager:OnUpdate(dt)
	if self.transition_time_left then
		self.transition_time_left = self.transition_time_left - dt
		local t = 0

		if self.transition_time_left <= 0 then
			self.transition_time_left = nil
			t = 1
		else
			t = 1 - self.transition_time_left / self.total_transition_time
		end

		PostProcessor:SetColourCubeLerp( 0, t )
	end

	if GetPlayer() and GetPlayer().components.sanity then
		local san = 1 - easing.outQuad(GetPlayer().components.sanity:GetPercent(), 0, 1, 1) 
		PostProcessor:SetColourCubeLerp( 1, san )
	end
end

function ColourCubeManager:TransitionTimeLeft()
	return self.transition_time_left
end

return ColourCubeManager