local easing = require "easing"

local wave_to_season = {
	["winter"] = SEASONS.WINTER,
	["spring"] = SEASONS.SPRING,
	["summer"] = SEASONS.SUMMER,
	["autumn"] = SEASONS.AUTUMN,
	["mild"] = SEASONS.MILD,
	["wet"] = SEASONS.WET,
	["green"] = SEASONS.GREEN,
	["dry"] = SEASONS.DRY,
	["temperate"] = SEASONS.TEMPERATE,
	["lush"] = SEASONS.LUSH,
	["humid"] = SEASONS.HUMID	
}
local season_to_wave = {
	[SEASONS.WINTER] = "winter",
	[SEASONS.SPRING] = "spring",
	[SEASONS.SUMMER] = "summer",
	[SEASONS.AUTUMN] = "autumn",
	[SEASONS.MILD] = "mild",
	[SEASONS.WET] = "wet",
	[SEASONS.GREEN] = "green",
	[SEASONS.DRY] = "dry",
	[SEASONS.TEMPERATE] = "temparate",
	[SEASONS.LUSH] = "lush",
	[SEASONS.HUMID] = "humid"	
}
local wave_sound = { 
	["autumn"] = "dontstarve/ocean/waves",
	["winter"] = "dontstarve/winter/winterwaves",
	["spring"] = "dontstarve/ocean/waves",--"dontstarve_DLC001/spring/springwaves",
	["summer"] = "dontstarve_DLC001/summer/summerwaves",
	["mild"] = "dontstarve/ocean/waves",
	["wet"] = "dontstarve_DLC001/summer/summerwaves",
	["green"] = "dontstarve_DLC001/summer/summerwaves",
	["dry"] = "dontstarve_DLC001/summer/summerwaves",
	["temperate"] = "dontstarve/ocean/waves",
	["lush"] = "dontstarve_DLC001/summer/summerwaves",
	["humid"] = "dontstarve/winter/winterwaves",
}

local half_tiles = 5

local AmbientSoundMixer = Class(function(self, inst)
    self.inst = inst
    
    self.playing_waves = false
    self.num_waves = 0
    self.wave_volume = 0
    self.current_wave = "autumn"
    
    self.playing_wind = false
    self.wind_intensity = 0

	self.ambient_vol = 1
	self.daynightparam = 1.0
	self.playing_sounds = {}
	self.override = {}

	self.rainchange = false
	self.seasonchange = false
	
	self.ambient_sounds =
	{
		--[GROUND.IMPASSABLE] = {sound = "dontstarve/ocean/waves"},
		[GROUND.ROAD] = {sound="dontstarve/rocky/rockyAMB", wintersound="dontstarve/winter/winterrockyAMB", springsound="dontstarve/rocky/rockyAMB", summersound="dontstarve_DLC001/summer/summerrockyAMB", rainsound="dontstarve/rain/rainrockyAMB"},
		[GROUND.ROCKY] = {sound="dontstarve/rocky/rockyAMB", wintersound="dontstarve/winter/winterrockyAMB", springsound="dontstarve/rocky/rockyAMB", summersound="dontstarve_DLC001/summer/summerrockyAMB", rainsound="dontstarve/rain/rainrockyAMB", mildsound="dontstarve_DLC002/mild/rockyAMB", wetsound="dontstarve_DLC002/wet/rockyAMB", greensound="dontstarve_DLC002/green/rockyAMB", drysound="dontstarve_DLC002/dry/rockyAMB", hurricanesound="dontstarve_DLC002/hurricane/rockyAMB", dormantsound="dontstarve_DLC002/volcano_amb/volano_alt", activesound="dontstarve_DLC002/volcano_amb/volano_alt"},
		[GROUND.DIRT] = {sound="dontstarve/badland/badlandAMB", wintersound="dontstarve/winter/winterbadlandAMB", springsound="dontstarve/badland/badlandAMB", summersound="dontstarve_DLC001/summer/summerbadlandAMB", rainsound="dontstarve/rain/rainbadlandAMB"},
		[GROUND.WOODFLOOR] = {sound="dontstarve/rocky/rockyAMB", wintersound="dontstarve/winter/winterrockyAMB", springsound="dontstarve/rocky/rockyAMB", summersound="dontstarve_DLC001/summer/summerrockyAMB", rainsound="dontstarve/rain/rainrockyAMB"},
		[GROUND.SAVANNA] = {sound="dontstarve/grassland/grasslandAMB", wintersound="dontstarve/winter/wintergrasslandAMB", springsound="dontstarve/grassland/grasslandAMB", summersound="dontstarve_DLC001/summer/summergrasslandAMB", rainsound="dontstarve/rain/raingrasslandAMB", mildsound="dontstarve_DLC002/mild/grasslandAMB", wetsound="dontstarve_DLC002/wet/grasslandAMB", greensound="dontstarve_DLC002/green/grasslandAMB", drysound="dontstarve_DLC002/dry/grasslandAMB", hurricanesound="dontstarve_DLC002/hurricane/grasslandAMB"},
		[GROUND.GRASS] = {sound="dontstarve/meadow/meadowAMB", wintersound="dontstarve/winter/wintermeadowAMB", springsound="dontstarve/meadow/meadowAMB", summersound="dontstarve_DLC001/summer/summermeadowAMB", rainsound="dontstarve/rain/rainmeadowAMB"},
		[GROUND.FOREST] = {sound="dontstarve/forest/forestAMB", wintersound="dontstarve/winter/winterforestAMB", springsound="dontstarve/forest/forestAMB", summersound="dontstarve_DLC001/summer/summerforestAMB", rainsound="dontstarve/rain/rainforestAMB"},
		[GROUND.MARSH] = {sound="dontstarve/marsh/marshAMB", wintersound="dontstarve/winter/wintermarshAMB", springsound="dontstarve/marsh/marshAMB", summersound="dontstarve_DLC001/summer/summermarshAMB", rainsound="dontstarve/rain/rainmarshAMB"},
		[GROUND.DECIDUOUS] = {sound="dontstarve/forest/forestAMB", wintersound="dontstarve/winter/winterforestAMB", springsound="dontstarve/forest/forestAMB", summersound="dontstarve_DLC001/summer/summerforestAMB", rainsound="dontstarve/rain/rainforestAMB"},
		[GROUND.DESERT_DIRT] = {sound="dontstarve/badland/badlandAMB", wintersound="dontstarve/winter/winterbadlandAMB", springsound="dontstarve/badland/badlandAMB", summersound="dontstarve_DLC001/summer/summerbadlandAMB", rainsound="dontstarve/rain/rainbadlandAMB"},
		[GROUND.CHECKER] = {sound="dontstarve/chess/chessAMB", wintersound="dontstarve/winter/winterchessAMB", springsound="dontstarve/chess/chessAMB", summersound="dontstarve_DLC001/summer/summerchessAMB", rainsound="dontstarve/rain/rainchessAMB"},
		[GROUND.CAVE] = {sound="dontstarve/cave/caveAMB"},
		
		[GROUND.FUNGUS] = {sound="dontstarve/cave/fungusforestAMB"},
		[GROUND.FUNGUSRED] = {sound="dontstarve/cave/fungusforestAMB"},
		[GROUND.FUNGUSGREEN] = {sound="dontstarve/cave/fungusforestAMB"},
		
		[GROUND.SINKHOLE] = {sound="dontstarve/cave/litcaveAMB"},
		[GROUND.UNDERROCK] = {sound="dontstarve/cave/caveAMB"},
		[GROUND.MUD] = {sound="dontstarve/cave/fungusforestAMB"},
		[GROUND.UNDERGROUND] = {sound="dontstarve/cave/caveAMB"},
		[GROUND.BRICK] = {sound="dontstarve/cave/ruinsAMB"},
		[GROUND.BRICK_GLOW] = {sound="dontstarve/cave/ruinsAMB", dormantsound="dontstarve_DLC002/volcano_amb/volano_alt", activesound="dontstarve_DLC002/volcano_amb/volano_alt"},
		[GROUND.TILES] = {sound="dontstarve/cave/civruinsAMB"},
		[GROUND.TILES_GLOW] = {sound="dontstarve/cave/civruinsAMB"},
		[GROUND.TRIM] = {sound="dontstarve/cave/ruinsAMB"},
		[GROUND.TRIM_GLOW] = {sound="dontstarve/cave/ruinsAMB"},
		["ABYSS"] = {sound="dontstarve/cave/pitAMB"},
		["VOID"] = {sound="dontstarve/chess/void", wintersound="dontstarve/chess/void", springsound="dontstarve/chess/void", summersound="dontstarve/chess/void", rainsound="dontstarve/chess/void"},
		["CIVRUINS"] = {sound="dontstarve/cave/civruinsAMB"},

		--shipwrecked
		[GROUND.JUNGLE] = {sound="dontstarve_DLC002/mild/jungleAMB", mildsound="dontstarve_DLC002/mild/jungleAMB", wetsound="dontstarve_DLC002/wet/jungleAMB", greensound="dontstarve_DLC002/green/jungleAMB", drysound="dontstarve_DLC002/dry/jungleAMB", rainsound="dontstarve_DLC002/rain/jungleAMB", hurricanesound="dontstarve_DLC002/hurricane/jungleAMB"},
		[GROUND.BEACH] = {sound="dontstarve_DLC002/mild/beachAMB", mildsound="dontstarve_DLC002/mild/beachAMB", wetsound="dontstarve_DLC002/wet/beachAMB", greensound="dontstarve_DLC002/green/beachAMB", drysound="dontstarve_DLC002/dry/beachAMB", rainsound="dontstarve_DLC002/rain/beachAMB", hurricanesound="dontstarve_DLC002/hurricane/beachAMB"},
		[GROUND.SWAMP] = {sound="dontstarve_DLC002/mild/marshAMB", mildsound="dontstarve_DLC002/mild/marshAMB", wetsound="dontstarve_DLC002/wet/marshAMB", greensound="dontstarve_DLC002/green/marshAMB", drysound="dontstarve_DLC002/dry/marshAMB", rainsound="dontstarve_DLC002/rain/marshAMB", hurricanesound="dontstarve_DLC002/hurricane/marshAMB"},
		[GROUND.MAGMAFIELD] = {sound="dontstarve/rocky/rockyAMB", mildsound="dontstarve_DLC002/mild/rockyAMB", wetsound="dontstarve_DLC002/wet/rockyAMB", greensound="dontstarve_DLC002/green/rockyAMB", drysound="dontstarve_DLC002/dry/rockyAMB", rainsound="dontstarve/rain/rainrockyAMB", hurricanesound="dontstarve_DLC002/hurricane/rockyAMB"},
		[GROUND.TIDALMARSH] = {sound="dontstarve_DLC002/mild/marshAMB", mildsound="dontstarve_DLC002/mild/marshAMB", wetsound="dontstarve_DLC002/wet/marshAMB", greensound="dontstarve_DLC002/green/marshAMB", drysound="dontstarve_DLC002/dry/marshAMB", rainsound="dontstarve_DLC002/rain/marshAMB", hurricanesound="dontstarve_DLC002/hurricane/marshAMB"},
		[GROUND.MEADOW] = {sound="dontstarve/grassland/grasslandAMB", wintersound="dontstarve/winter/wintergrasslandAMB", springsound="dontstarve/grassland/grasslandAMB", summersound="dontstarve_DLC001/summer/summergrasslandAMB", rainsound="dontstarve/rain/raingrasslandAMB", mildsound="dontstarve_DLC002/mild/grasslandAMB", wetsound="dontstarve_DLC002/wet/grasslandAMB", greensound="dontstarve_DLC002/green/grasslandAMB", drysound="dontstarve_DLC002/dry/grasslandAMB", hurricanesound="dontstarve_DLC002/hurricane/grasslandAMB"},
		[GROUND.OCEAN_SHALLOW] = {sound="dontstarve_DLC002/mild/ocean_shallow", mildsound="dontstarve_DLC002/mild/ocean_shallow", wetsound="dontstarve_DLC002/wet/ocean_shallowAMB", greensound="dontstarve_DLC002/green/ocean_shallowAMB", drysound="dontstarve_DLC002/dry/ocean_shallow", rainsound="dontstarve_DLC002/rain/ocean_shallowAMB", hurricanesound="dontstarve_DLC002/hurricane/ocean_shallowAMB"},
		[GROUND.OCEAN_MEDIUM] = {sound="dontstarve_DLC002/mild/ocean_shallow", mildsound="dontstarve_DLC002/mild/ocean_shallow", wetsound="dontstarve_DLC002/wet/ocean_shallowAMB", greensound="dontstarve_DLC002/green/ocean_shallowAMB", drysound="dontstarve_DLC002/dry/ocean_shallow", rainsound="dontstarve_DLC002/rain/ocean_shallowAMB", hurricanesound="dontstarve_DLC002/hurricane/ocean_shallowAMB"},
		[GROUND.OCEAN_DEEP] = {sound="dontstarve_DLC002/mild/ocean_deep", mildsound="dontstarve_DLC002/mild/ocean_deep", wetsound="dontstarve_DLC002/wet/ocean_deepAMB", greensound="dontstarve_DLC002/green/ocean_deepAMB", drysound="dontstarve_DLC002/dry/ocean_deep", rainsound="dontstarve_DLC002/rain/ocean_deepAMB", hurricanesound="dontstarve_DLC002/hurricane/ocean_deepAMB"},
		[GROUND.OCEAN_SHIPGRAVEYARD] = {sound="dontstarve_DLC002/mild/ocean_deep", mildsound="dontstarve_DLC002/mild/ocean_deep", wetsound="dontstarve_DLC002/wet/ocean_deepAMB", greensound="dontstarve_DLC002/green/ocean_deepAMB", drysound="dontstarve_DLC002/dry/ocean_deep", rainsound="dontstarve_DLC002/rain/ocean_deepAMB", hurricanesound="dontstarve_DLC002/hurricane/ocean_deepAMB"},
		[GROUND.OCEAN_SHORE] = {sound="dontstarve_DLC002/mild/waves", mildsound="dontstarve_DLC002/mild/waves", wetsound="dontstarve_DLC002/wet/waves", greensound="dontstarve_DLC002/green/waves", drysound="dontstarve_DLC002/dry/waves", rainsound="dontstarve_DLC002/rain/waves", hurricanesound="dontstarve_DLC002/hurricane/waves"},
		[GROUND.OCEAN_CORAL] = {sound="dontstarve_DLC002/mild/coral_reef", mildsound="dontstarve_DLC002/mild/coral_reef", wetsound="dontstarve_DLC002/wet/coral_reef", greensound="dontstarve_DLC002/green/coral_reef", drysound="dontstarve_DLC002/dry/coral_reef", rainsound="dontstarve_DLC002/rain/coral_reef", hurricanesound="dontstarve_DLC002/hurricane/coral_reef"},
		[GROUND.MANGROVE] = {sound="dontstarve_DLC002/mild/mangrove", mildsound="dontstarve_DLC002/mild/mangrove", wetsound="dontstarve_DLC002/wet/mangrove", greensound="dontstarve_DLC002/green/mangrove", drysound="dontstarve_DLC002/dry/mangrove", rainsound="dontstarve_DLC002/rain/mangrove", hurricanesound="dontstarve_DLC002/hurricane/mangrove"},
		[GROUND.VOLCANO] = {sound="dontstarve_DLC002/volcano_amb/ground_ash", dormantsound="dontstarve_DLC002/volcano_amb/volano_dormant", activesound="dontstarve_DLC002/volcano_amb/volano_active"},
		[GROUND.VOLCANO_ROCK] = {sound="dontstarve_DLC002/volcano_amb/ground_ash", dormantsound="dontstarve_DLC002/volcano_amb/volano_dormant", activesound="dontstarve_DLC002/volcano_amb/volano_active"},
		[GROUND.VOLCANO_LAVA] = {dormantsound="dontstarve_DLC002/volcano_amb/lava", activesound="dontstarve_DLC002/volcano_amb/lava"},
		[GROUND.ASH] = {sound="dontstarve_DLC002/volcano_amb/ground_ash", dormantsound="dontstarve_DLC002/volcano_amb/volano_dormant", activesound="dontstarve_DLC002/volcano_amb/volano_active"},
	}

	for k,v in pairs(self.ambient_sounds) do
		if v.sound and not self.playing_sounds[v.sound] then
			self.playing_sounds[v.sound] = {sound = v.sound, volume = 0, playing= false}
		end
		if v.wintersound and not self.playing_sounds[v.wintersound] then
			self.playing_sounds[v.wintersound] = {sound = v.wintersound, volume = 0, playing= false}
		end
		if v.springsound and not self.playing_sounds[v.springsound] then
			self.playing_sounds[v.springsound] = {sound = v.springsound, volume = 0, playing= false}
		end
		if v.summersound and not self.playing_sounds[v.summersound] then
			self.playing_sounds[v.summersound] = {sound = v.summersound, volume = 0, playing= false}
		end
		if v.rainsound and not self.playing_sounds[v.rainsound] then
			self.playing_sounds[v.rainsound] = {sound = v.rainsound, volume = 0, playing= false}
		end

		if v.mildsound and not self.playing_sounds[v.mildsound] then
			self.playing_sounds[v.mildsound] = {sound = v.mildsound, volume = 0, playing= false}
		end
		if v.wetsound and not self.playing_sounds[v.wetsound] then
			self.playing_sounds[v.wetsound] = {sound = v.wetsound, volume = 0, playing= false}
		end
		if v.greensound and not self.playing_sounds[v.greensound] then
			self.playing_sounds[v.greensound] = {sound = v.greensound, volume = 0, playing= false}
		end
		if v.drysound and not self.playing_sounds[v.drysound] then
			self.playing_sounds[v.drysound] = {sound = v.drysound, volume = 0, playing= false}
		end
		if v.hurricanesound and not self.playing_sounds[v.hurricanesound] then
			self.playing_sounds[v.hurricanesound] = {sound = v.hurricanesound, volume = 0, playing= false}
		end
		if v.activesound and not self.playing_sounds[v.activesound] then
			self.playing_sounds[v.activesound] = {sound = v.activesound, volume = 0, playing= false}
		end
		if v.dormantsound and not self.playing_sounds[v.dormantsound] then
			self.playing_sounds[v.dormantsound] = {sound = v.dormantsound, volume = 0, playing= false}
		end
	end

    TheSim:SetReverbPreset("default")
    
    self.inst:ListenForEvent( "dusktime", function(it, data) 
			self:SetSoundParam(1.5)
        end, GetWorld())      

    self.inst:ListenForEvent( "daytime", function(it, data) 
			self:SetSoundParam(1.0)
        end, GetWorld())      

    self.inst:ListenForEvent( "nighttime", function(it, data) 
			self:SetSoundParam(2.0)
        end, GetWorld())      


    self.inst:ListenForEvent( "warnstart", function(it, data) 
			self:SetSoundParam(1.5)
        end, GetWorld())      

    self.inst:ListenForEvent( "calmstart", function(it, data) 
			self:SetSoundParam(1.0)
        end, GetWorld())      

    self.inst:ListenForEvent( "nightmarestart", function(it, data) 
			self:SetSoundParam(2.0)
        end, GetWorld())  

    self.inst:ListenForEvent( "dawnstart", function(it, data) 
		self:SetSoundParam(1.5)
    end, GetWorld())        


	self.inst:StartUpdatingComponent(self)
	
	self.inst.SoundEmitter:PlaySound( "dontstarve/sanity/sanity", "SANITY")
    
end)

function AmbientSoundMixer:SetOverride(src, target)
	self.override[src] = target
end

function AmbientSoundMixer:OnUpdate(dt)
	self:UpdateAmbientGeoMix()
	self:UpdateAmbientTimeMix(dt)	
	self:UpdateAmbientVolumes()
end

function AmbientSoundMixer:GetDebugString()
	local str = {}
	
	table.insert(str, "AMBIENT SOUNDS:\n")
	table.insert(str, string.format("atten=%2.2f, day=%2.2f, waves=%2.2f\n", self.ambient_vol, self.daynightparam, self.wave_volume))
	
	for k,v in pairs(self.playing_sounds) do
		local vol = v.volume
		if vol > 0 then
			table.insert(str, string.format("\t%s = %2.2f\n", v.sound, vol))
		end
	end
	return table.concat(str, "")
	
end



function AmbientSoundMixer:SetSoundParam(val)
	self.daynightparam = val
	for k,v in pairs(self.playing_sounds) do
		
		if v.playing then
			self.inst.SoundEmitter:SetParameter( v.sound, "daytime", val )
		end
	end
	
end

function AmbientSoundMixer:UpdateAmbientVolumes()
	local sm = GetSeasonManager()
	local season = sm:GetSeason()
	
	local player = GetPlayer()
	local sanity_level = 1
	if player.components.sanity ~= nil then
		sanity_level = player.components.sanity:GetPercent()
	end

	self.inst.SoundEmitter:SetParameter( "SANITY", "sanity", 1-sanity_level )
	

	for k,v in pairs(self.playing_sounds) do
		local vol = self.ambient_vol * v.volume
		
		if vol > 0 ~= v.playing then
			if vol > 0 then
				self.inst.SoundEmitter:PlaySound( v.sound, v.sound)
				self.inst.SoundEmitter:SetParameter( v.sound, "daytime", self.daynightparam )
			else
				self.inst.SoundEmitter:KillSound(v.sound)
			end
			v.playing = vol > 0
		end
		
		if v.playing then
			self.inst.SoundEmitter:SetVolume(v.sound, vol)
		end
	end
	
	if self.num_waves > 0 then
		
		if self.playing_waves and season ~= wave_to_season[self.current_wave] then
			self.inst.SoundEmitter:KillSound("waves")
			self.playing_waves = false
		end
		
		if not self.playing_waves then
			self.current_wave = season_to_wave[season]
			self.inst.SoundEmitter:PlaySound(wave_sound[self.current_wave], "waves")
			self.playing_waves = true
		end
		
		self.wave_volume = math.max(0, math.min(1, self.num_waves / ((half_tiles*half_tiles*4)*.667)))
		self.inst.SoundEmitter:SetVolume("waves", self.wave_volume)
	else
		self.wave_volume = 0
		if self.playing_waves then
			self.inst.SoundEmitter:KillSound("waves")
			self.playing_waves = false
		end
	end

	if sm:GetHurricaneWindSpeed() > 0 then
		
		if not self.playing_wind then
			
			self.inst.SoundEmitter:PlaySound("dontstarve_DLC002/rain/islandwindAMB", "wind")
			self.playing_wind = true
		end
		
		if self.playing_wind then 
			self.wind_intensity = GetSeasonManager():GetHurricaneWindSpeed()
			if self.wind_intensity > 1 then
				self.wind_intensity = 1
			end
			self.inst.SoundEmitter:SetParameter("wind", "intensity", self.wind_intensity)
		end 
		-- self.wave_volume = math.max(0, math.min(1, self.num_waves / ((half_tiles*half_tiles*4)*.667)))
		-- self.inst.SoundEmitter:SetVolume("waves", self.wave_volume)
	else
		self.wind_intensity = 0
		if self.playing_wind then
			self.inst.SoundEmitter:KillSound("wind")
			self.playing_wind = false
		end
	end

	if sm:IsGreenSeason() and sm:IsRaining() then
		if not self.inst.SoundEmitter:PlayingSound("islandrain") then
			self.inst.SoundEmitter:PlaySound("dontstarve_DLC002/rain/islandrainAMB", "islandrain")
		end
		if self.inst.SoundEmitter:PlayingSound("islandrain") then
			local intensity = math.min(sm:GetPrecipitationRate(), 1.0)
			self.inst.SoundEmitter:SetParameter("islandrain", "intensity", intensity)
		end
	else
		if self.inst.SoundEmitter:PlayingSound("islandrain") then
			self.inst.SoundEmitter:KillSound("islandrain")
		end
	end

	if sm:IsWetSeason() and sm:IsHailing() then
		if not self.inst.SoundEmitter:PlayingSound("hail") then
			self.inst.SoundEmitter:PlaySound("dontstarve_DLC002/rain/islandhailAMB", "hail")
		end
		if self.inst.SoundEmitter:PlayingSound("hail") then
			local intensity = math.min(sm:GetHailRate(), 1.0)
			self.inst.SoundEmitter:SetParameter("hail", "intensity", intensity)
		end
	else
		if self.inst.SoundEmitter:PlayingSound("hail") then
			self.inst.SoundEmitter:KillSound("hail")
		end
	end
end


function AmbientSoundMixer:UpdateAmbientTimeMix(dt)
    --night/dusk ambient is attenuated in the light
    local player = nil
    local atten_vol = 1
    local fade_in_speed = 1/20
    
    local lowlight = .2
    local highlight = .9
    local lowvol = .5
    
	local player = GetPlayer()
	if player and player.LightWatcher then
		local isnight = not GetClock():IsDay()
		
		if isnight then
            local lightval = player.LightWatcher:GetLightValue()
            
            if lightval > highlight then
                atten_vol = lowvol
            elseif lightval < lowlight then
                self.ambient_vol = 1
            else
                self.ambient_vol = easing.outCubic( lightval - lowlight, 1, lowvol-1, highlight - lowlight) 
            end
            
        else
            if self.ambient_vol < 1 then
                self.ambient_vol = math.min(1, self.ambient_vol + fade_in_speed*dt)
            end
        end
    end
end

function AmbientSoundMixer:SetRainChanged()
	self.rainchange = true
end

function AmbientSoundMixer:SetSeasonChanged()
	self.seasonchange = true
end

--update the ambient mix based upon the player's surroundings
function AmbientSoundMixer:UpdateAmbientGeoMix()
	local season = GetSeasonManager():GetSeason()
	local MAX_AMB = 3
	local player = GetPlayer()
	local ground = GetWorld()
	if player and ground then
		local position = Vector3(player.Transform:GetWorldPosition())
		
		--only update if we've actually walked somewhere new
		if (self.lastpos and self.lastpos:DistSq(position) < 16) and not self.rainchange and not self.seasonchange then
			return
		end
		self.lastpos = position
		if self.rainchange then self.rainchange = false end
		if self.seasonchange then self.seasonchange = false end
				
		local x, y = ground.Map:GetTileCoordsAtPoint(position.x, position.y, position.z)
		
		local sound_mix = {}
		
		
		local num_waves = 0

		local isvolcanoerupting = false
		if GetVolcanoManager() ~= nil then
			isvolcanoerupting = GetVolcanoManager():IsFireRaining()
		end

		local ishurricane = GetSeasonManager():IsHurricaneStorm()
		local isheavyrain = GetSeasonManager():IsHeavyRaining()
		local isvolcano = GetWorld():IsVolcano()

		for xx = -half_tiles, half_tiles do
			for yy = -half_tiles, half_tiles do
				local tile = ground.Map:GetTile(x + xx, y +yy)
				-- HACK HACK HACK	
				if self.override[tile] ~= nil then
					tile = self.override[tile]
				end
				
				if tile and tile == GROUND.IMPASSABLE then
					num_waves = num_waves + 1
				elseif tile and self.ambient_sounds[tile] then
					local sound = nil

					if isvolcano and isvolcanoerupting and self.ambient_sounds[tile].activesound then
						sound = self.ambient_sounds[tile].activesound
					elseif isvolcano and self.ambient_sounds[tile].dormantsound then
						sound = self.ambient_sounds[tile].dormantsound
					elseif ishurricane and self.ambient_sounds[tile].hurricanesound then
						sound = self.ambient_sounds[tile].hurricanesound
					elseif isheavyrain and self.ambient_sounds[tile].rainsound then
						sound = self.ambient_sounds[tile].rainsound
					elseif season == SEASONS.WINTER and self.ambient_sounds[tile].wintersound then
						sound = self.ambient_sounds[tile].wintersound
					elseif season == SEASONS.SPRING and self.ambient_sounds[tile].springsound then
						sound = self.ambient_sounds[tile].springsound
					elseif season == SEASONS.SUMMER and self.ambient_sounds[tile].summersound then
						sound = self.ambient_sounds[tile].summersound
					elseif season == SEASONS.MILD and self.ambient_sounds[tile].mildsound then
						sound = self.ambient_sounds[tile].mildsound
					elseif season == SEASONS.WET and self.ambient_sounds[tile].wetsound then
						sound = self.ambient_sounds[tile].wetsound
					elseif season == SEASONS.GREEN and self.ambient_sounds[tile].greensound then
						sound = self.ambient_sounds[tile].greensound
					elseif season == SEASONS.DRY and self.ambient_sounds[tile].drysound then
						sound = self.ambient_sounds[tile].drysound
					elseif season == SEASONS.TEMPERATE and self.ambient_sounds[tile].mildsound then
						sound = self.ambient_sounds[tile].mildsound
					elseif season == SEASONS.LUSH and self.ambient_sounds[tile].summersound then
						sound = self.ambient_sounds[tile].summersound
					elseif season == SEASONS.HUMID and self.ambient_sounds[tile].wintersound then
						sound = self.ambient_sounds[tile].wintersound						
					else
						sound = self.ambient_sounds[tile].sound
					end

					if sound then
						if sound_mix[sound] then
							sound_mix[sound].count = sound_mix[sound].count + 1
						else
							sound_mix[sound] = {count = 1}
						end
					end
				end
			end
		end

		
		self.num_waves = num_waves
		if GetWorld():HasTag("cave") or GetWorld():HasTag("volcano") then self.num_waves = 0 end
		
		local sorted_mix = {}
		for k,v in pairs(sound_mix) do
			table.insert(sorted_mix, {sound=k, count=v.count})
		end
		
		table.sort(sorted_mix, function(a,b) return a.count > b.count end)
		
		local total = 0
		for k,v in ipairs(sorted_mix) do
			if k <= MAX_AMB then
				total = total + v.count
				sound_mix[v.sound].play = true
			else
				break
			end
		end
		
		for k,v in pairs(self.playing_sounds) do
			local sound_rec = sound_mix[v.sound]
			if sound_rec and sound_rec.play then
				v.volume = sound_rec.count/total
			else
				v.volume = 0
			end
		end
	end
end

function AmbientSoundMixer:SetReverbPreset(reverb)
	if not self.reverboverride then
		TheSim:SetReverbPreset(reverb)
	end		
	self.oldreverb = reverb
end

function AmbientSoundMixer:SetReverbOveride(reverb)
	self.reverboverride = reverb
	TheSim:SetReverbPreset(reverb)
end

function AmbientSoundMixer:ClearReverbOveride()
	self.reverboverride = nil	
	if self.oldreverb then
		TheSim:SetReverbPreset(self.oldreverb)
	else
		TheSim:SetReverbPreset("default")
	end
end

return AmbientSoundMixer
