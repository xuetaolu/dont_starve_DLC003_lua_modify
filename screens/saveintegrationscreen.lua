local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
require "os"

local NewIntegratedGameScreen = require "screens/newintegratedgamescreen"
require "fileutil"

local function HasDLC()
	return IsDLCInstalled(REIGN_OF_GIANTS) or IsDLCInstalled(CAPY_DLC)
end

-- Based on LoadGameScreen.lua
local SaveIntegrationScreen = Class(Screen, function(self, target_mode, portal_event, cancelcb)

	Screen._ctor(self, "SaveIntegrationScreen")
    self.profile = Profile
	self.cancelcb = cancelcb
    
    self.black = self:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
	self.black:SetTint(0,0,0,.75)
    
	self.scaleroot = self:AddChild(Widget("scaleroot"))
    self.scaleroot:SetVAnchor(ANCHOR_MIDDLE)
    self.scaleroot:SetHAnchor(ANCHOR_MIDDLE)
    self.scaleroot:SetPosition(0,0,0)
    self.scaleroot:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.root = self.scaleroot:AddChild(Widget("root"))
    self.root:SetScale(.9)
    self.bg = self.root:AddChild(Image("images/fepanels.xml", "panel_saveslots.tex"))

    self.current_slot = SaveGameIndex:GetCurrentSaveSlot()
	
    local menuitems = 
    {
		{text = STRINGS.UI.LOADGAMESCREEN.CANCEL, cb = function()
			EnableAllDLC()
			TheFrontEnd:PopScreen(self)
			if self.cancelcb then
				self.cancelcb()
			end
		end},
    }
    self.bmenu = self.root:AddChild(Menu(menuitems, 160, true))
    self.bmenu:SetPosition(0, -250, 0)
    if HasDLC() then
    	self.bmenu:SetScale(.8)
    else
    	self.bmenu:SetScale(.9)
    end

	if JapaneseOnPS4() then
        self.title = self.root:AddChild(Text(TITLEFONT, 60 * 0.8))
	else
        self.title = self.root:AddChild(Text(TITLEFONT, 60))
	end
    self.title:SetPosition( 0, 215, 0)
    self.title:SetRegionSize(250,70)
    self.title:SetString(STRINGS.UI.SAVEINTEGRATION.MERGE_TARGET)
    self.title:SetVAlign(ANCHOR_MIDDLE)
	
    if HasDLC() then
    	self.menu = self.root:AddChild(Menu(nil, -80, false))
    	self.menu:SetPosition( 0, 143, 0)
    else
    	self.menu = self.root:AddChild(Menu(nil, -98, false))
    	self.menu:SetPosition( 0, 135, 0)
    end
	
	self.default_focus = self.menu
	
	self.target_mode = target_mode
    self.portal_event = portal_event
end)

function SaveIntegrationScreen:OnBecomeActive()
    
	self:RefreshFiles()
	SaveIntegrationScreen._base.OnBecomeActive(self)
	if self.last_slotnum then
		self.menu.items[self.last_slotnum]:SetFocus()
	end
end


function SaveIntegrationScreen:OnControl(control, down)
    if Screen.OnControl(self, control, down) then return true end
    if not down and control == CONTROL_CANCEL then
        TheFrontEnd:PopScreen(self)
		if self.cancelcb then
			self.cancelcb()
		end
        return true
    end
end

function SaveIntegrationScreen:RefreshFiles()
	self.menu:Clear()

	for k = 1, NUM_SAVE_SLOTS do
		local tile = self:MakeSaveTile(k)
		if tile ~= nil then
			self.menu:AddCustomItem(tile)
		end
	end
	
	-- TODO: add a check in case there are no saves for us here
	self.menu.items[1]:SetFocusChangeDir(MOVE_UP, self.bmenu)
	self.bmenu:SetFocusChangeDir(MOVE_DOWN, self.menu.items[1])

	self.bmenu:SetFocusChangeDir(MOVE_UP, self.menu.items[#self.menu.items])
	self.menu.items[#self.menu.items]:SetFocusChangeDir(MOVE_DOWN, self.bmenu)
	

end

function SaveIntegrationScreen:MakeSaveTile(slotnum)
	
	local widget = Widget("savetile")
	widget.base = widget:AddChild(Widget("base"))
	
	local mode = SaveGameIndex:GetCurrentMode(slotnum)

	local day = SaveGameIndex:GetSlotDay(slotnum)
	local world = SaveGameIndex:GetSlotWorld(slotnum)
	local character = SaveGameIndex:GetSlotCharacter(slotnum)
	
	local DLC = SaveGameIndex:GetSlotDLC(slotnum)
	local RoG_DLC = (DLC ~= nil and DLC.REIGN_OF_GIANTS ~= nil) and DLC.REIGN_OF_GIANTS or false
	local Capy_DLC = (DLC ~= nil and DLC.CAPY_DLC ~= nil) and DLC.CAPY_DLC or false
	-- TODO: use this for setting the shield art below
	local Pork_DLC = (DLC ~= nil and DLC.PORKLAND_DLC ~= nil) and DLC.PORKLAND_DLC or false

    widget.bg = widget.base:AddChild(UIAnim())
    widget.bg:GetAnimState():SetBuild("savetile")
    widget.bg:GetAnimState():SetBank("savetile")
    widget.bg:GetAnimState():PlayAnimation("anim")
	
	widget.portraitbg = widget.base:AddChild(Image("images/saveslot_portraits.xml", "background.tex"))
	if HasDLC() then
		widget.portraitbg:SetScale(.60,.60,1)
		if JapaneseOnPS4() then
			widget.portraitbg:SetPosition(-120 + 20, 0, 0)
		else	
			widget.portraitbg:SetPosition(-120 + 40, 0, 0)
		end
	else
		widget.portraitbg:SetScale(.65,.65,1)
		if JapaneseOnPS4() then
			widget.portraitbg:SetPosition(-120 + 20, 2, 0)
		else	
			widget.portraitbg:SetPosition(-120 + 40, 2, 0)
		end
	end
	widget.portraitbg:SetClickable(false)	
	
	widget.portrait = widget.base:AddChild(Image())
	widget.portrait:SetClickable(false)	
	if character and mode and slotnum ~= self.current_slot then	
		local atlas = (table.contains(MODCHARACTERLIST, character) and "images/saveslot_portraits/"..character..".xml") or "images/saveslot_portraits.xml"
		widget.portrait:SetTexture(atlas, character..".tex")
	else
		widget.portraitbg:Hide()
	end

	if HasDLC() then
		widget.portrait:SetScale(.60,.60,1)
		if JapaneseOnPS4() then
			widget.portrait:SetPosition(-120 + 20, 0, 0)	
		else
			widget.portrait:SetPosition(-120 + 40, 0, 0)	
		end
	else
		widget.portrait:SetScale(.65,.65,1)
		if JapaneseOnPS4() then
			widget.portrait:SetPosition(-120 + 20, 2, 0)	
		else
			widget.portrait:SetPosition(-120 + 40, 2, 0)	
		end
	end
	
	
	if JapaneseOnPS4() then
    	widget.text = widget.base:AddChild(Text(TITLEFONT, 40 * 0.8))	-- KAJ
	else
    	widget.text = widget.base:AddChild(Text(TITLEFONT, 40))
	end
	if character and mode and (RoG_DLC or Capy_DLC) and slotnum ~= self.current_slot then
		local shield_icon = ""

		if RoG_DLC then
			shield_icon = "DLCicon.tex"
		elseif Capy_DLC then
			if SaveGameIndex:OwnsMode("survival", slotnum) then
				if SaveGameIndex:OwnsMode("shipwrecked", slotnum) then
					if SaveGameIndex:ROGEnabledOnSWSlot(slotnum) then
						--TODO: mixed shield with ROG
						shield_icon = "SWDLC_icon.tex"
					else
						-- TODO: mixed shield with Vanilla
						shield_icon = "SWBase_icon.tex"
					end
				else
					if SaveGameIndex:ROGEnabledOnSWSlot(slotnum) then
						shield_icon = "DLCicon.tex"
					-- else
					-- 	-- TODO: mixed shield with vanilla
					-- 	shield_icon = "SWBase_icon.tex"
					end
				end
			else
				shield_icon = "SWicon.tex"
			end
		end

		if shield_icon ~= "" then
			widget.dlcindicator = widget.base:AddChild(Image())
			widget.dlcindicator:SetClickable(false)
			widget.dlcindicator:SetTexture("images/ui.xml", shield_icon)
			widget.dlcindicator:SetScale(.5,.5,1)
			widget.dlcindicator:SetPosition(-142, 2, 0)
		end
	end

    widget.text = widget.base:AddChild(Text(TITLEFONT, 40))
    widget.text:SetPosition(40,0,0)
    widget.text:SetRegionSize(200 ,70)
    
    if not mode then
		widget.text:SetString(STRINGS.UI.SAVEINTEGRATION.EMPTY_SLOT)
		widget.text:SetPosition(0,0,0)
	elseif slotnum == self.current_slot then
		widget.text:SetString(STRINGS.UI.LOADGAMESCREEN.NEWWORLD)
		widget.text:SetPosition(0,0,0)
	elseif mode == "adventure" then
		widget.text:SetString(string.format("%s %d-%d",STRINGS.UI.LOADGAMESCREEN.ADVENTURE, world, day))
	elseif mode == "survival" then
		widget.text:SetString(string.format("%s %d-%d",STRINGS.UI.LOADGAMESCREEN.SURVIVAL, world, day))
	elseif mode == "cave" then
		local level = SaveGameIndex:GetCurrentCaveLevel(slotnum)
		widget.text:SetString(string.format("%s %d",STRINGS.UI.LOADGAMESCREEN.CAVE, level))
	elseif mode == "shipwrecked" then
		widget.text:SetString(string.format("%s %d-%d",STRINGS.UI.LOADGAMESCREEN.SHIPWRECKED, world, day))
	elseif mode == "porkland" then 
		widget.text:SetString(string.format("%s %d-%d",STRINGS.UI.LOADGAMESCREEN.PORKLAND, world, day))
	elseif mode == "volcano" then
		widget.text:SetString(string.format("%s %d-%d",STRINGS.UI.LOADGAMESCREEN.VOLCANO, world, day))
	else
    	--This should only happen if the user has run a mod that created a new type of game mode.
		widget.text:SetString(STRINGS.UI.LOADGAMESCREEN.MODDED)
	end
	
    widget.text:SetVAlign(ANCHOR_MIDDLE)

    if HasDLC() then
		widget.bg:SetScale(1,.8,1)
	else
		widget:SetScale(1,1,1)
	end
    
	local function GainFocus(self)
		Widget.OnGainFocus(self)
    	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover")
    	if HasDLC() then
    		widget.bg:SetScale(1.05,.87,1)
    	else
			widget:SetScale(1.1,1.1,1)
		end
		widget.bg:GetAnimState():PlayAnimation("over")
	end

	local function LoseFocus(self)
    	Widget.OnLoseFocus(self)
    	widget.base:SetPosition(0,0,0)
    	if HasDLC() then
    		widget.bg:SetScale(1,.8,1)
    	else
			widget:SetScale(1,1,1)
		end
		widget.bg:GetAnimState():PlayAnimation("anim")
	end

	local function Control(control, down, cb)
		if control == CONTROL_ACCEPT then
			if down then 
				widget.base:SetPosition(0,-5,0)
			else
				widget.base:SetPosition(0,0,0) 
				cb()
			end
			return true
		end
	end

	-- TODO: double check what's happening here
	if mode ~= self.target_mode or SaveGameIndex:OwnsMode(SaveGameIndex:GetCurrentMode(), slotnum) then 
		widget.portraitbg:SetTint(1,1,1,0.4)
		widget.portrait:SetTint(1,1,1,0.4)

		if widget.dlcindicator then
			widget.dlcindicator:SetTint(1,1,1,0.4)
		end

		if slotnum ~= self.current_slot then
			widget.text:SetAlpha(0.4)
			widget:SetScale(0.95, 0.95, 0.95)
		else
			local screen = self
			-- The widget needs to know these for the OnControl below
			widget.target_mode = self.target_mode
			widget.portal_event = self.portal_event
			
			widget.OnGainFocus = GainFocus
    		widget.OnLoseFocus = LoseFocus
		    
		    widget.OnControl = function(self, control, down)
				Control(control, down, function()
					TheFrontEnd:PushScreen(NewIntegratedGameScreen(self.target_mode, self.portal_event, slotnum))
				end)
			end
		end

		return widget
	end

	widget.OnGainFocus = GainFocus
    widget.OnLoseFocus = LoseFocus
        
    local screen = self
    widget.OnControl = function(self, control, down)
		return Control(control, down, function() screen:OnClickTile(slotnum) end )
	end

	return widget
end

function SaveIntegrationScreen:OnClickTile(slotnum)
	self.last_slotnum = slotnum
	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")	

	TheFrontEnd:PopScreen()
	
	TravelBetweenWorlds(self.target_mode, self.portal_event, 7.5, {"chester_eyebone", "packim_fishbone", "ro_bin_gizzard_stone", "roc_robin_egg"}, nil, slotnum)
end

function SaveIntegrationScreen:GetHelpText()
	local controller_id = TheInput:GetControllerID()
	return TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK
end


return SaveIntegrationScreen
