local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local MovieDialog = require "screens/moviedialog"

local MIN_GEN_TIME = 9.5

local PLAY_PRE_WORLDGEN_MOVIE = false
local MIN_GEN_TIME_WITH_MOVIE_AT_START = 3.0

local WorldGenScreen = Class(Screen, function(self, profile, cb, world_gen_options)
	Screen._ctor(self, "WorldGenScreen")
    self.profile = profile
	self.log = true

	self.bg = self:AddChild(Image("images/ui.xml", "bg_plain.tex"))

    self.bg:SetVRegPoint(ANCHOR_MIDDLE)
    self.bg:SetHRegPoint(ANCHOR_MIDDLE)
    self.bg:SetVAnchor(ANCHOR_MIDDLE)
    self.bg:SetHAnchor(ANCHOR_MIDDLE)
    self.bg:SetScaleMode(SCALEMODE_FILLSCREEN)

    self.center_root = self:AddChild(Widget("root"))
    self.center_root:SetVAnchor(ANCHOR_MIDDLE)
    self.center_root:SetHAnchor(ANCHOR_MIDDLE)
    self.center_root:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self.bottom_root = self:AddChild(Widget("root"))
    self.bottom_root:SetVAnchor(ANCHOR_BOTTOM)
    self.bottom_root:SetHAnchor(ANCHOR_MIDDLE)
    self.bottom_root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    
    self.worldanim = self.bottom_root:AddChild(UIAnim())
    
	local hand_scale = 1.5
    self.hand1 = self.bottom_root:AddChild(UIAnim())
    self.hand1:GetAnimState():SetBuild("creepy_hands")
    self.hand1:GetAnimState():SetBank("creepy_hands")
    self.hand1:GetAnimState():SetTime(math.random()*2)
    self.hand1:GetAnimState():PlayAnimation("idle", true)
    self.hand1:SetPosition(400, 0, 0)
    self.hand1:SetScale(hand_scale,hand_scale,hand_scale)

    self.hand2 = self.bottom_root:AddChild(UIAnim())
    self.hand2:GetAnimState():SetBuild("creepy_hands")
    self.hand2:GetAnimState():SetBank("creepy_hands")
    self.hand2:GetAnimState():PlayAnimation("idle", true)
    self.hand2:GetAnimState():SetTime(math.random()*2)
    self.hand2:SetPosition(-425, 0, 0)
	self.hand2:SetScale(-hand_scale,hand_scale,hand_scale)
    
    self.worldgentext = self.center_root:AddChild(Text(TITLEFONT, 100))
    self.worldgentext:SetPosition(0, 200, 0)
    

    local rog_enabled = false
    -- In case we are generating a world from SW and the player doesn't have ROG installed
	-- or disabled it when generating the world
	if world_gen_options.custom_options and world_gen_options.custom_options.ROGEnabled then
		rog_enabled = world_gen_options.custom_options.ROGEnabled
	end

    if world_gen_options.level_type == "cave" then
	    self.bg:SetTint(BGCOLOURS.PURPLE[1],BGCOLOURS.PURPLE[2],BGCOLOURS.PURPLE[3], 1)
		self.worldanim:GetAnimState():SetBuild("generating_cave")
		self.worldanim:GetAnimState():SetBank("generating_cave")
	    self.worldgentext:SetString(STRINGS.UI.WORLDGEN.CAVETITLE)

	elseif world_gen_options.level_type == "volcano" then
		self.bg:SetTint(60/255, 80/255, 85/255, 1)
		self.worldanim:GetAnimState():SetBuild("generating_volcano")
		self.worldanim:GetAnimState():SetBank("generating_volcano")
	    self.worldgentext:SetString(STRINGS.UI.WORLDGEN.VOLCANOTITLE)

	elseif world_gen_options.level_type == "survival" then
		if rog_enabled then
			self.bg:SetTint(BGCOLOURS.PURPLE[1],BGCOLOURS.PURPLE[2],BGCOLOURS.PURPLE[3], 1)
		else
			self.bg:SetTint(BGCOLOURS.RED[1],BGCOLOURS.RED[2],BGCOLOURS.RED[3], 1)
		end

		self.worldanim:GetAnimState():SetBuild("generating_world")
		self.worldanim:GetAnimState():SetBank("generating_world")
	    self.worldgentext:SetString(STRINGS.UI.WORLDGEN.TITLE)

	elseif world_gen_options.level_type == "shipwrecked" then
		self.bg:SetTint(BGCOLOURS.TEAL[1],BGCOLOURS.TEAL[2],BGCOLOURS.TEAL[3], 1)
		self.worldanim:GetAnimState():SetBuild("generating_shipwrecked")
		self.worldanim:GetAnimState():SetBank("generating_shipwrecked")
	    self.worldgentext:SetString(STRINGS.UI.WORLDGEN.SHIPWRECKEDTITLE)	    
	else
		self.bg:SetTint(BGCOLOURS.GREEN[1],BGCOLOURS.GREEN[2],BGCOLOURS.GREEN[3], 1)
		self.worldanim:GetAnimState():SetBuild("generating_hamlet")
		self.worldanim:GetAnimState():SetBank("generating_hamlet")
	    self.worldgentext:SetString(STRINGS.UI.WORLDGEN.PORKLANDTITTLE)
	end
	
    self.worldanim:GetAnimState():PlayAnimation("idle", true)

    self.flavourtext= self.center_root:AddChild(Text(UIFONT, 40))
    self.flavourtext:SetPosition(0, 100, 0)

	Settings.save_slot = Settings.save_slot or 1
	local gen_parameters = {}

	gen_parameters.level_type = world_gen_options.level_type
	if gen_parameters.level_type == nil then
		gen_parameters.level_type = "free"
	end
		
	gen_parameters.world_gen_choices = world_gen_options.custom_options
	if gen_parameters.world_gen_choices == nil then
		gen_parameters.world_gen_choices = {
			 		monsters = "default", animals = "default", resources = "default",
	    			unprepared = "default", 
	    			--prepared = "default", day = "default"
    			}
	end
	
	gen_parameters.current_level = world_gen_options.level_world

	if gen_parameters.level_type == "adventure" then
		if gen_parameters.current_level == nil or gen_parameters.current_level < 1 then
			gen_parameters.current_level = 1
		end

		gen_parameters.adventure_progress = world_gen_options.adventure_progress or 1
	end

	gen_parameters.profiledata = world_gen_options.profiledata
	if gen_parameters.profiledata == nil then
		gen_parameters.profiledata = { unlocked_characters = {} }
	end
	
	local DLCEnabledTable = {}
	for i,v in pairs(DLC_LIST) do
		DLCEnabledTable[i] = IsDLCEnabled( i )
	end
	gen_parameters.DLCEnabled = DLCEnabledTable

	-- In case we are generating a world from SW and the player doesn't have ROG installed
	-- or disabled it when generating the world
	gen_parameters.ROGEnabled = rog_enabled

	local moddata = {}
	moddata.index = KnownModIndex:CacheSaveData()

	self.genparam = json.encode(gen_parameters)
	self.modparam = json.encode(moddata)

    TheSim:GenerateNewWorld( self.genparam, self.modparam, function(worlddata) 
    		self.worlddata = worlddata
			self.done = true
		end)
		
	self.total_time = 0
	self.cb = cb
    TheFrontEnd:DoFadeIn(2)
    
	self.verbs = shuffleArray(STRINGS.UI.WORLDGEN.VERBS)

	if world_gen_options.level_type == "porkland" then
		self.nouns = shuffleArray(STRINGS.UI.WORLDGEN.NOUNS.PORKLAND)
	elseif world_gen_options.level_type == "shipwrecked" or world_gen_options.level_type == "volcano" then
		self.nouns = shuffleArray(STRINGS.UI.WORLDGEN.NOUNS.SHIPWRECKED)
	else
		self.nouns = shuffleArray(STRINGS.UI.WORLDGEN.NOUNS.BASE_GAME)
	end
	
    self.verbidx = 1
    self.nounidx = 1
    self:ChangeFlavourText()
    
    self:SetBackgroundSound(world_gen_options)

    if not PLAY_PRE_WORLDGEN_MOVIE then 
        TheFrontEnd:GetSound():PlaySound(self.backgroundSound, "worldgensound")
    end

end)

function WorldGenScreen:SetBackgroundSound(world_gen_options)
    if world_gen_options.level_type == "cave" then
    	self.backgroundSound = "dontstarve/HUD/caveGen"
	elseif world_gen_options.level_type == "survival" then
    	self.backgroundSound = "dontstarve/HUD/worldGen"    	
    elseif world_gen_options.level_type == "shipwrecked" then
    	self.backgroundSound = "dontstarve_DLC002/common/GenShipwrecked_LP"
    elseif world_gen_options.level_type == "volcano" then
        self.backgroundSound = "dontstarve_DLC002/common/GenShipwrecked_volcano_LP"        
    else
        self.backgroundSound = "dontstarve_DLC003/HUD/worldGen"
    end
end

function WorldGenScreen:OnLoseFocus()
	Screen.OnLoseFocus(self)
	TheFrontEnd:GetSound():KillSound("worldgensound")    
end

function WorldGenScreen:OnUpdate(dt)
	if PLAY_PRE_WORLDGEN_MOVIE then
		self.isPlaying = self.isPlaying or false
		if not self.isPlaying then
			local movieStartTime = TheSim:GetTick() * TheSim:GetTickTime()
			local moviename = PLATFORM == "PS4" and "movies/worldgen.mp4" or "movies/worldgen.ogv"
			TheFrontEnd:PushScreen( MovieDialog(moviename, function() 
									   SetPause(false)
									   TheFrontEnd:GetSound():PlaySound(self.backgroundSound,"FEMusic") 
									   local movieEndTime = TheSim:GetTick() * TheSim:GetTickTime()
									   local moviePlayTime = movieEndTime - movieStartTime
									   MIN_GEN_TIME = MIN_GEN_TIME - moviePlayTime
									   if MIN_GEN_TIME < MIN_GEN_TIME_WITH_MOVIE_AT_START then
									       MIN_GEN_TIME = MIN_GEN_TIME_WITH_MOVIE_AT_START
									   end
									end, true ) )

			self.isPlaying = true
		end
	end
	self.total_time = self.total_time + dt
	if self.done then
		if self.worlddata == "" then
			print ("RESTARTING GENERATION")
			self.done = false
			self.worldata = nil
			TheSim:GenerateNewWorld( self.genparam, self.modparam, function(worlddata) 
    				self.worlddata = worlddata
					self.done = true
				end)
			return
		end
		
	--	print("TESTING THIS STRING",self.worlddata)
		
		if string.match(self.worlddata,"^error") then
			self.done = false
			self.cb(self.worlddata)
		elseif self.total_time > MIN_GEN_TIME and self.cb then
			self.done = false
			
			TheFrontEnd:Fade(false, 1, function() 
				self.cb(self.worlddata)
				end)
		end
	end
end

function WorldGenScreen:ChangeFlavourText()

	
	self.flavourtext:SetString(self.verbs[self.verbidx] .. " " .. self.nouns[self.nounidx])

	self.verbidx = (self.verbidx == #self.verbs) and 1 or (self.verbidx + 1)
	self.nounidx = (self.nounidx == #self.nouns) and 1 or (self.nounidx + 1)

	local time = GetRandomWithVariance(2, 1)
	self.inst:DoTaskInTime(time, function() self:ChangeFlavourText() end)
end

return WorldGenScreen