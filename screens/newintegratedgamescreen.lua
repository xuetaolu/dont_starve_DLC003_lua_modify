local Screen = require "widgets/screen"
local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local Spinner = require "widgets/spinner"
local Menu = require "widgets/menu"
local Text = require "widgets/text"
local Image = require "widgets/image"
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
require "os"

-- TODO: require the customizationscreen for RoG instead of SW
local CustomizationScreen = require "screens/customizationscreen"
local BigPopupDialogScreen = require "screens/bigpopupdialog"

local REIGN_OF_GIANTS_DIFFICULTY_WARNING_XP_THRESHOLD = 20*32 --20 xp per day, 32 days

local NewIntegratedGameScreen = Class(Screen, function(self, target_mode, portal_event, slotnum, add_blackscreen, cancelcb)
	Screen._ctor(self, "NewIntegratedGameScreen")

	if add_blackscreen then
		self.black = self:AddChild(Image("images/global.xml", "square.tex"))
	    self.black:SetVRegPoint(ANCHOR_MIDDLE)
	    self.black:SetHRegPoint(ANCHOR_MIDDLE)
	    self.black:SetVAnchor(ANCHOR_MIDDLE)
	    self.black:SetHAnchor(ANCHOR_MIDDLE)
	    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
		self.black:SetTint(0,0,0,.75)
	end

    self.profile = Profile
    self.saveslot = slotnum
    self.character = SaveGameIndex:GetSlotCharacter(slotnum) or "wilson"
	self.cancelcb = cancelcb

   	self.scaleroot = self:AddChild(Widget("scaleroot"))
    self.scaleroot:SetVAnchor(ANCHOR_MIDDLE)
    self.scaleroot:SetHAnchor(ANCHOR_MIDDLE)
    self.scaleroot:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.root = self.scaleroot:AddChild(Widget("root"))
    self.root:SetScale(.9)

    self.bg = self.root:AddChild(Image("images/fepanels.xml", "panel_saveslots.tex"))

    self.title = self.root:AddChild(Text(TITLEFONT, 60))
    self.title:SetPosition( 75, 135, 0)
    self.title:SetRegionSize(250,60)
    self.title:SetHAlign(ANCHOR_LEFT)
	self.title:SetString(STRINGS.UI.NEWGAMESCREEN.TITLE)

	self.portraitbg = self.root:AddChild(Image("images/saveslot_portraits.xml", "background.tex"))
	self.portraitbg:SetPosition(-120, 135, 0)	
	self.portraitbg:SetClickable(false)	

	self.portrait = self.root:AddChild(Image())
	self.portrait:SetClickable(false)		
	local atlas = (table.contains(MODCHARACTERLIST, self.character) and "images/saveslot_portraits/"..self.character..".xml") or "images/saveslot_portraits.xml"
	self.portrait:SetTexture(atlas, self.character..".tex")
	self.portrait:SetPosition(-120, 135, 0)
  
  	local menu_ypos = 30
  	local menuitems = {}
  	if IsDLCInstalled(REIGN_OF_GIANTS) then
		local dlc_buttons = {}

		if target_mode == "survival" then 
			table.insert(dlc_buttons, self:MakeReignOfGiantsButton())
		else
			self.dlcindicator = self.root:AddChild(Image())
			self.dlcindicator:SetClickable(false)
			self.dlcindicator:SetPosition(0, 55, 0)
			self.dlcindicator:SetScale(0.85)
			menu_ypos = -45
			if target_mode == "shipwrecked" then
				self.dlcindicator:SetTexture("images/ui.xml", "SWicon.tex")
			else
				self.dlcindicator:SetTexture("images/ui.xml", "HAMicon.tex")
			end
		end

		table.insert(menuitems, {text = STRINGS.UI.NEWGAMESCREEN.START, cb = function() self:Start() end, offset = Vector3(0,10,0)})

		local xOffset = #dlc_buttons == 2 and -80 or 0
		local yOffset = #dlc_buttons == 2 and 5 or 0
		local yIncrement = #dlc_buttons == 2 and 70 or 0

		for i = 1, #dlc_buttons do
			table.insert(menuitems, {widget = dlc_buttons[i], offset = Vector3(xOffset, yOffset, 0)})
			xOffset = xOffset * -1
			yOffset = yOffset + yIncrement
		end

		table.insert(menuitems, {text = STRINGS.UI.NEWGAMESCREEN.CUSTOMIZE, cb = function() self:Customize() end, offset = Vector3(0, yIncrement, 0)})
		table.insert(menuitems, {text = STRINGS.UI.NEWGAMESCREEN.CANCEL, cb = function()
			TheFrontEnd:PopScreen(self)
			if self.cancelcb then
				self.cancelcb()
			end
		end, offset = Vector3(0, yIncrement, 0)})
  	else

  		if target_mode ~= "survival" then
  			self.dlcindicator = self.root:AddChild(Image())
			self.dlcindicator:SetClickable(false)
			self.dlcindicator:SetPosition(0, 55, 0)
			self.dlcindicator:SetScale(0.85)
			menu_ypos = -45

			if target_mode == "shipwrecked" then
				self.dlcindicator:SetTexture("images/ui.xml", "SWicon.tex")
			else
				self.dlcindicator:SetTexture("images/ui.xml", "HAMicon.tex")
			end
  		end

  		menuitems = 
	    {
			{text = STRINGS.UI.NEWGAMESCREEN.START, cb = function() self:Start() end, offset = Vector3(0,10,0)},
			{text = STRINGS.UI.NEWGAMESCREEN.CUSTOMIZE, cb = function() self:Customize() end},
			{text = STRINGS.UI.NEWGAMESCREEN.CANCEL, cb = function()
				TheFrontEnd:PopScreen(self)
				if self.cancelcb then
					self.cancelcb()
				end
			end},
	    }
  	end

    self.menu = self.root:AddChild(Menu(menuitems, -70))
	self.menu:SetPosition(0, menu_ypos, 0)

	self.default_focus = self.menu
	
	self.target_mode = target_mode
	self.portal_event = portal_event
    
end)

function NewIntegratedGameScreen:OnGainFocus()
	NewIntegratedGameScreen._base.OnGainFocus(self)
	self.menu:SetFocus()
end

function NewIntegratedGameScreen:OnControl(control, down)
    if Screen.OnControl(self, control, down) then return true end
    if not down and control == CONTROL_CANCEL then
        TheFrontEnd:PopScreen(self)
        return true
    end
end

function NewIntegratedGameScreen:SetSavedCustomOptions(options)
	if self.savedcustomoptions == nil then
		self.savedcustomoptions = {}
	end

	local currentdlc = MAIN_GAME
	local dlcs = {CAPY_DLC, REIGN_OF_GIANTS, MAIN_GAME}
	for _, dlc in ipairs(dlcs) do
		if IsDLCInstalled(dlc) and IsDLCEnabled(dlc) then
			currentdlc = dlc
		end
	end
	self.savedcustomoptions[currentdlc] = options
end

function NewIntegratedGameScreen:GetSavedCustomOptions()
	if self.savedcustomoptions == nil then
		self.savedcustomoptions = {}
	end

	local currentdlc = MAIN_GAME
	local dlcs = {CAPY_DLC, REIGN_OF_GIANTS, MAIN_GAME}
	for _, dlc in ipairs(dlcs) do
		if IsDLCInstalled(dlc) and IsDLCEnabled(dlc) then
			currentdlc = dlc
		end
	end
	return self.savedcustomoptions[currentdlc]
end

function NewIntegratedGameScreen:Customize( )
	
	local function onSet(options, dlc)
		TheFrontEnd:PopScreen()
		if options then
			self:SetSavedCustomOptions(options)
			self.customoptions = options
		end
	end

	self.customoptions = self:GetSavedCustomOptions()

	--[[if self.prevworldcustom ~= self.RoG and IsDLCInstalled(REIGN_OF_GIANTS) then
		local prev = self.prevcustomoptions
		self.prevcustomoptions = self.customoptions
		self.customoptions = prev
		package.loaded["map/customise"] = nil
	end

	self.prevworldcustom = self.RoG]]

	-- Clean up the preset setting since we're going back to customization screen, not to worldgen
	if self.customoptions and self.customoptions.actualpreset then
		self.customoptions.preset = self.customoptions.actualpreset
		self.customoptions.actualpreset = nil
	end
	-- Clean up the tweak table since we're going back to customization screen, not to worldgen
	if self.customoptions and self.customoptions.faketweak and self.customoptions.tweak and #self.customoptions.faketweak > 0 then
		for i,v in pairs(self.customoptions.faketweak) do
			for m,n in pairs(self.customoptions.tweak) do
				for j,k in pairs(n) do
					if v == j then -- Found the fake tweak setting, now remove it from the table
						self.customoptions.tweak[m][j] = nil
						break
					end
				end
			end
		end
	end

	if self.target_mode == "survival" and self.RoG then
		TheFrontEnd:PushScreen(CustomizationScreen(Profile, onSet, self.customoptions, self.RoG, true, "REIGN_OF_GIANTS"))
	elseif self.target_mode == "shipwrecked" then
		TheFrontEnd:PushScreen(CustomizationScreen(Profile, onSet, self.customoptions, self.RoG, true, "CAPY_DLC"))
	elseif self.target_mode == "porkland" then
		TheFrontEnd:PushScreen(CustomizationScreen(Profile, onSet, self.customoptions, self.RoG, true, "PORKLAND_DLC"))
	else
		TheFrontEnd:PushScreen(CustomizationScreen(Profile, onSet, self.customoptions, self.RoG, true, "MAIN_GAME"))
	end

end


function NewIntegratedGameScreen:Start()

	local function GetEnabledDLCs()
		local dlc = {REIGN_OF_GIANTS = self.RoG, CAPY_DLC = self.CapyDLC}
		return dlc
	end

	local function CleanupTweakTable()
		-- Clean up the tweak table since we don't want "default" overrides
		if self.customoptions and self.customoptions.faketweak and self.customoptions.tweak and #self.customoptions.faketweak > 0 then
			for i,v in pairs(self.customoptions.faketweak) do
				for m,n in pairs(self.customoptions.tweak) do
					for j,k in pairs(n) do
						if v == j and k == "default" then -- Found the fake tweak setting for "default", now remove it from the table
							self.customoptions.tweak[m][j] = nil
							break
						end
					end
				end
			end
		end
	end

	local xp = Profile:GetXP()
	if IsDLCInstalled(REIGN_OF_GIANTS) and self.RoG and xp <= REIGN_OF_GIANTS_DIFFICULTY_WARNING_XP_THRESHOLD and not Profile:HaveWarnedDifficultyRoG() then
		TheFrontEnd:PushScreen(BigPopupDialogScreen(STRINGS.UI.NEWGAMESCREEN.ROG_WARNING_TITLE, STRINGS.UI.NEWGAMESCREEN.ROG_WARNING_BODY, 
			{{text=STRINGS.UI.NEWGAMESCREEN.YES, 
				cb = function() 
					Profile:SetHaveWarnedDifficultyRoG()
					TheFrontEnd:PopScreen()
					self:Start()
				end},
			{text=STRINGS.UI.NEWGAMESCREEN.NO, 
				cb = function() 
					TheFrontEnd:PopScreen() 
				end}  
			})
		)
	else
		TheFrontEnd:PopScreen()
		TheFrontEnd:PopScreen()
		TheFrontEnd:PopScreen()

		self.customoptions = self:GetSavedCustomOptions() or {}
		if self.RoG == true then
			self.customoptions.ROGEnabled = true
		end
		CleanupTweakTable()
		self.root:Disable()

		TravelBetweenWorlds(self.target_mode, self.portal_event, 7.5, {"chester_eyebone", "packim_fishbone", "ro_bin_gizzard_stone", "roc_robin_egg"}, self.customoptions)
	end
end


function NewIntegratedGameScreen:GetHelpText()
	local controller_id = TheInput:GetControllerID()
	return TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK
end

function NewIntegratedGameScreen:MakeReignOfGiantsButton()
	self.RoG = IsDLCInstalled(REIGN_OF_GIANTS)
	--self.prevworldcustom = true

	self.RoGbutton = self:AddChild(Widget("option"))
	self.RoGbutton.image = self.RoGbutton:AddChild(Image("images/ui.xml", "DLCicontoggle.tex"))
	self.RoGbutton.image:SetPosition(25,0,0)
	self.RoGbutton.image:SetTint(1,1,1,.3)

	self.RoGbutton.checkbox = self.RoGbutton:AddChild(Image("images/ui.xml", "button_checkbox1.tex"))
	self.RoGbutton.checkbox:SetPosition(-35,0,0)
	self.RoGbutton.checkbox:SetScale(0.5,0.5,0.5)
	self.RoGbutton.checkbox:SetTint(1.0,0.5,0.5,1)

	self.RoGbutton.bg = self.RoGbutton:AddChild(UIAnim())
	self.RoGbutton.bg:GetAnimState():SetBuild("savetile_small")
	self.RoGbutton.bg:GetAnimState():SetBank("savetile_small")
	self.RoGbutton.bg:GetAnimState():PlayAnimation("anim")
	self.RoGbutton.bg:SetPosition(-75,0,0)
	self.RoGbutton.bg:SetScale(1.12,1,1)

	self.RoGbutton.OnGainFocus = function()
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover")
			self.RoGbutton:SetScale(1.1,1.1,1)
			self.RoGbutton.bg:GetAnimState():PlayAnimation("over")
		end

	self.RoGbutton.OnLoseFocus = function()
			self.RoGbutton:SetScale(1,1,1)
			self.RoGbutton.bg:GetAnimState():PlayAnimation("anim")
		end

	self.RoGbutton.OnControl = function(_, control, down) 
		if Widget.OnControl(self.RoGbutton, control, down) then return true end
		if control == CONTROL_ACCEPT and not down then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
			self.RoG = not self.RoG
			if self.RoG then
				self.RoGbutton.enable()
			else
				self.RoGbutton.disable()
			end
			return true
		end
	end

	self.RoGbutton.enable = function()
		self.RoG = true
		self.RoGbutton.checkbox:SetTint(1,1,1,1)
		self.RoGbutton.image:SetTint(1,1,1,1)
		if self.characterreverted == true and self.prevcharacter ~= nil then --Switch back to DLC character if possible
			self.character = self.prevcharacter
			self.prevcharacter = nil
			self.characterreverted = false
			local atlas = (table.contains(MODCHARACTERLIST, self.character) and "images/saveslot_portraits/"..self.character..".xml") or "images/saveslot_portraits.xml"
			self.portrait:SetTexture(atlas, self.character..".tex")
		end
		self.RoGbutton.checkbox:SetTexture("images/ui.xml", "button_checkbox2.tex")
		EnableDLC(REIGN_OF_GIANTS)
	end 

	self.RoGbutton.disable = function()
		self.RoG = false
		self.RoGbutton.checkbox:SetTint(1.0,0.5,0.5,1)
		self.RoGbutton.image:SetTint(1,1,1,.3)
		if self.character == "wathgrithr" or self.character == "webber" then --Switch to Wilson if currently have DLC char selected
			self.characterreverted = true
			self.prevcharacter = self.character
			self.character = "wilson"
			local atlas = (table.contains(MODCHARACTERLIST, self.character) and "images/saveslot_portraits/"..self.character..".xml") or "images/saveslot_portraits.xml"
			self.portrait:SetTexture(atlas, self.character..".tex")
		end
		self.RoGbutton.checkbox:SetTexture("images/ui.xml", "button_checkbox1.tex")
		DisableDLC(REIGN_OF_GIANTS)
	end
	

	self.RoGbutton.GetHelpText = function()
		local controller_id = TheInput:GetControllerID()
		local t = {}
	    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.HELP.TOGGLE)	
		return table.concat(t, "  ")
	end

	self.RoGbutton.enable()

	return self.RoGbutton
end

return NewIntegratedGameScreen
