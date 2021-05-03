local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"


local UIClock = Class(Widget, function(self)
    Widget._ctor(self, "Clock")
    --self:SetHAnchor(ANCHOR_RIGHT)
    --self:SetVAnchor(ANCHOR_TOP)

    self.DAY_COLOUR = Vector3(254/255,212/255,86/255)
    self.DUSK_COLOUR = Vector3(165/255,91/255,82/255)
    self.DARKEN_PERCENT = .75


    self.base_scale = 1
    
    self:SetScale(self.base_scale,self.base_scale,self.base_scale)
    self:SetPosition(0,0,0)

    self.moonanim = self:AddChild(UIAnim())
    --self.moonanim:SetScale(.4,.4,.4)
    self.moonanim:GetAnimState():SetBank("moon_phases_clock")
    self.moonanim:GetAnimState():SetBuild("moon_phases_clock")
    self.moonanim:GetAnimState():PlayAnimation("hidden")
    
    
    self.anim = self:AddChild(UIAnim())
    local sc = 1
    self.anim:SetScale(sc,sc,sc)
    self.anim:GetAnimState():SetBank("clock01")
    self.anim:GetAnimState():SetBuild("clock_transitions")
    self.anim:GetAnimState():PlayAnimation("idle_day",true)
    
    
    
    self.face = self:AddChild(Image("images/hud.xml", "clock_NIGHT.tex"))
    self.segs = {}
	local segscale = .4
    local numsegs = 16
    for i = 1, numsegs do
		local seg = self:AddChild(Image("images/hud.xml", "clock_wedge.tex"))
        seg:SetScale(segscale,segscale,segscale)
        seg:SetHRegPoint(ANCHOR_LEFT)
        seg:SetVRegPoint(ANCHOR_BOTTOM)
        seg:SetRotation((i-1)*(360/numsegs))
        seg:SetClickable(false)
        table.insert(self.segs, seg)
    end
    

    
    self.rim = self:AddChild(Image("images/hud.xml", "clock_rim.tex"))
    self.hands = self:AddChild(Image("images/hud.xml", "clock_hand.tex"))

    self.text_upper = self:AddChild(Text(BODYTEXTFONT, 33/self.base_scale))
    self.text_upper:SetPosition(5, 15/self.base_scale, 0)
    self.text_lower = self:AddChild(Text(BODYTEXTFONT, 33/self.base_scale))
    self.text_lower:SetPosition(5, -15/self.base_scale, 0)
    self.hovertext_upper = self:AddChild(Text(BODYTEXTFONT, 33/self.base_scale))
    self.hovertext_upper:SetPosition(5, 15/self.base_scale, 0)
    self.hovertext_lower = self:AddChild(Text(BODYTEXTFONT, 33/self.base_scale))
    self.hovertext_lower:SetPosition(5, -15/self.base_scale, 0)
	self.hovertext_upper:Hide()
	self.hovertext_lower:Hide()

    self.rim:SetClickable(false)
    self.hands:SetClickable(false)
    self.face:SetClickable(false)
    
    local ground = GetWorld()   
    self.world_num = SaveGameIndex:GetSlotWorld()
    
    self.inst:ListenForEvent( "clocktick", function(inst, data) 
    				self:SetTime(data.normalizedtime, data.phase) 
    			end, GetWorld())


	self:UpdateDayString()
	self:AnimateDayString(true)

    self.inst:ListenForEvent( "daycomplete", function() self:UpdateDayString() end, GetWorld())

	self.inst:ListenForEvent( "daytime", function(inst, data) 
        self:UpdateDayString()
        self.anim:GetAnimState():PlayAnimation("trans_night_day") 
        self.anim:GetAnimState():PushAnimation("idle_day", true) 
        self.moonanim:GetAnimState():PlayAnimation("trans_in") 
        
    end, GetWorld())
	
	  
	self.inst:ListenForEvent( "nighttime", function(inst, data) 
		
        self.anim:GetAnimState():PlayAnimation("trans_dusk_night") 
        self.anim:GetAnimState():PushAnimation("idle_night", true) 
        self:ShowMoon()

    end, GetWorld())
    
	self.inst:ListenForEvent( "dusktime", function(inst, data) 
        self.anim:GetAnimState():PlayAnimation("trans_day_dusk")
    end, GetWorld())
    
	self.inst:ListenForEvent( "daysegschanged", function(inst, data) 
        self:RecalcSegs()
    end, GetWorld())

	self.inst:ListenForEvent( "pause", function(inst)
		self:AnimateDayString(true)
	end, GetWorld())
    
    
	self.inst:ListenForEvent("beginaporkalypse", function(inst) self:ShowMoon() end, GetWorld())

    self.old_t = 0 
    self:RecalcSegs()
    
    if GetClock():IsNight() then
		self:ShowMoon()
    end
end)

local WORLD_IN_TIME = 15
local WORLD_OUT_TIME = 30

local function DoAnimation(inst)
	local self = inst.widget
	if self.animstep < WORLD_IN_TIME then
		local t = self.animstep / WORLD_IN_TIME
		self.text_upper:SetColour(1, 1, 1, Lerp(0, 1, t))
		self.text_lower:SetPosition(5, Lerp(0, -15/self.base_scale, t))
	elseif self.animstep < (180-WORLD_OUT_TIME) then
		self.text_upper:SetColour(1, 1, 1, 1)
		self.text_lower:SetPosition(5, -15/self.base_scale)
	elseif self.animstep < 180 then
		local t = (180-self.animstep) / WORLD_OUT_TIME
		self.text_upper:SetColour(1, 1, 1, Lerp(0, 1, t))
		self.text_lower:SetPosition(5, Lerp(0, -15/self.base_scale, t))
	else
		self.animstep = 0
		self.animate_task:Cancel()
		return
	end

	self.animstep = self.animstep + 1
end

function UIClock:AnimateDayString(partial)
	if self.animate_task ~= nil then
		self.animate_task:Cancel()
	end

	self.animstep = (partial and WORLD_IN_TIME)
					or (self.animstep and math.min(self.animstep, WORLD_IN_TIME))
					or 0
	DoAnimation(self.inst)
	self.animate_task = self.inst:DoPeriodicTask(0, DoAnimation)
end

local modeclockstrings = {
	survival = "SURVIVAL",
	cave = "SURVIVAL",
	adventure = "ADVENTURE",
	shipwrecked = "SHIPWRECKED",
	volcano = "SHIPWRECKED",
}

function UIClock:UpdateDayString()
	local modekey = modeclockstrings[SaveGameIndex:GetCurrentMode()]
	local modestr = modekey ~= nil and STRINGS.UI.LOADGAMESCREEN[modekey] or STRINGS.UI.HUD.WORLD
	local clock_str_upper = string.format("%s %s", modestr, tostring(self.world_num or 1))
	self.text_upper:SetString(clock_str_upper)
	self.text_upper:SetScale(0.8,0.8)
	local clock_str_lower = string.format("%s %s", STRINGS.UI.HUD.CLOCKDAY, tostring(GetClock().numcycles+1))
	self.text_lower:SetString(clock_str_lower)

	self:AnimateDayString()

	--local characterkey = GetPlayer().prefab
	--local characterstr = STRINGS.CHARACTER_NAMES[characterkey] or STRINGS.UI.HUD.CHARACTER
	--local hover_str_upper = string.format("%s", characterstr)
	--self.hovertext_upper:SetString(hover_str_upper)
	--local w,h = self.hovertext_upper:GetRegionSize()
	--local maxwidth = 160
	--if w > maxwidth then
		--self.hovertext_upper:SetPosition(5 - (w - maxwidth)/2, 15/self.base_scale, 0)
	--else
		--self.hovertext_upper:SetPosition(5, 15/self.base_scale, 0)
	--end
	--local hover_str_lower = string.format("%s %s", STRINGS.UI.HUD.CLOCKDAY, tostring(GetClock().numcycles+1))
	--self.hovertext_lower:SetString(hover_str_lower)
end

function UIClock:OnGainFocus()
	UIClock._base.OnGainFocus(self)
	--self.text_upper:Hide()
	--self.text_lower:Hide()
	--self.hovertext_upper:Show()
	--self.hovertext_lower:Show()
	self:AnimateDayString()
	return true
end

function UIClock:OnLoseFocus()
	UIClock._base.OnLoseFocus(self)
	--self.text_upper:Show()
	--self.text_lower:Show()
	--self.hovertext_upper:Hide()
	--self.hovertext_lower:Hide()
	--self:AnimateDayString(true)
	return true
end


function UIClock:ShowMoon()
    local mp = GetClock():GetMoonPhase()
    local moon_syms = 
    {
        full="moon_full",
        quarter="moon_quarter",
        new="moon_new",
        threequarter="moon_three_quarter",
        half="moon_half",
    }

    local override_with = "moon_phases"
    local aporkalypse = GetAporkalypse()
    if aporkalypse and aporkalypse:IsActive() then
    	override_with = "moon_aporkalypse_phases"
    end

    self.moonanim:GetAnimState():OverrideSymbol("swap_moon", override_with, moon_syms[mp] or "moon_full")        
    self.moonanim:GetAnimState():PlayAnimation("trans_out") 
    self.moonanim:GetAnimState():PushAnimation("idle", true) 
end

function UIClock:RecalcSegs()
    
    local dark = true
    for k,seg in pairs(self.segs) do
        
        local color = nil
        
        local daysegs = GetClock():GetDaySegs()
        local dusksegs = GetClock():GetDuskSegs()
        
        if k > daysegs + dusksegs then
			seg:Hide()
		else
	        seg:Show()
			
			if k <= daysegs then
				color = self.DAY_COLOUR 
			else
				color = self.DUSK_COLOUR
			end
	        
			if dark then
				color = color * self.DARKEN_PERCENT
			end
			seg:SetTint(color.x, color.y, color.z, 1)
			dark = not dark
		end
    end
    
end


function UIClock:SetTime(t, phase)

    if phase == "day" then
        local segs = 16
        if math.floor(t * segs) > 0 and math.floor(t * segs) ~= math.floor(self.old_t * segs) then
            self.anim:GetAnimState():PlayAnimation("pulse_day") 
            self.anim:GetAnimState():PushAnimation("idle_day", true)            
        end
    end
    
    self.hands:SetRotation(t*360)
    
    
    self.old_t = t
end


return UIClock
