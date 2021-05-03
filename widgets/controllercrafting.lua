require "class"

local TileBG = require "widgets/tilebg"
local InventorySlot = require "widgets/invslot"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local TabGroup = require "widgets/tabgroup"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local CraftSlot = require "widgets/craftslot"
local Crafting = require "widgets/crafting"
local RecipePopup = require "widgets/recipepopup"


require "widgets/widgetutil"

local REPEAT_TIME = .15
local POPUPOFFSET = Vector3(-300,-360,0)

local ControllerCrafting = Class(Crafting, function(self, level)
    Crafting._ctor(self, 10)
	self:SetOrientation(true)

    level = level or 0
    self.level = level

	self.tabidx = nil
	self.selected_recipe_by_tab_idx = {}
	self.repeat_time = REPEAT_TIME

	local sc = .75
	self:SetScale(sc,sc,sc)
	self.in_pos = Vector3(550, 250-level*100, 0)
	self.out_pos = Vector3(-2000, 250-level*100, 0)
	--[[self.in_pos = Vector3(-200, -160, 0)
	self.out_pos = Vector3(-2000, -160, 0)
	--]]

	if self.level == 0 then
		self.groupname = self:AddChild(Text(TITLEFONT, 100))
		--self.groupname:SetPosition(-400,90,0)
		self.groupname:SetPosition(-410+150 + 150 + 15,115,0)
		self.groupname:SetHAlign(ANCHOR_LEFT)
		self.groupname:SetRegionSize(400+300+300, 120)
	end
	
	--self.groupimg1 = self:AddChild(Image())
	--self.groupimg1:SetPosition(-200, 90, 0)
	--self.groupimg2 = self:AddChild(Image())
	--self.groupimg2:SetPosition(200, 90, 0)

	self.recipepopup = self:AddChild(RecipePopup(true))
	self.recipepopup:Hide()
	
	self.recipepopup:SetScale(1.25,1.25,1.25)
	
	self.inst:ListenForEvent("builditem", function() self:Refresh() end, self.owner)
	self.inst:ListenForEvent("unlockrecipe", function() self:Refresh() end, self.owner)

	local controller_id = TheInput:GetControllerID()
	local s = TheInput:GetLocalizedControl(controller_id, CONTROL_CONTROLLER_ALTACTION) .. " " .. STRINGS.UI.HUD.CLOSE
	self.back = self:AddChild(Text(TALKINGFONT, 35))
	self.back:SetString(s)
	self.back:SetPosition(640,-60,0)

end)



function ControllerCrafting:GetTabs()
	local crafttabs = GetPlayer().HUD.controls and GetPlayer().HUD.controls.crafttabs --this is fugly, but...
	return crafttabs
end

function ControllerCrafting:Close(fn)
	local tabs = self:GetTabs() 
	tabs:HideSubTab_Controller(self.level)
	ControllerCrafting._base.Close(self, fn)
	TheFrontEnd:LockFocus(false)
	self:StopUpdating()
end

function ControllerCrafting:Open(fn)
	ControllerCrafting._base.Open(self, fn)
	self:StartUpdating()

	self.control_held = TheInput:IsControlPressed(CONTROL_OPEN_CRAFTING)
	self.control_held_time = 0
	self.accept_down = TheInput:IsControlPressed(CONTROL_PRIMARY)
	
	if self.oldslot then
		self.oldslot:SetScale(1,1,1)
		self.oldslot = nil
	end
	
	if not self:OpenRecipeTab(self.tabidx) then
		self:OpenRecipeTab_Index(1)
	end

	self.craftslots:Open(1)
	if not self:SelectRecipe(self.selected_recipe_by_tab_idx[self.tabidx]) then
		self:SelectRecipe()
	end
	self:SetFocus()
	TheFrontEnd:LockFocus(true)
	
end

function ControllerCrafting:SelectRecipe(recipe)
	
	if not recipe then
		recipe = self.valid_recipes[1]
	end

	if recipe then
		for k,v in ipairs(self.valid_recipes) do
			if recipe == v then
				
				--scroll the list to get our item into view
				local slot_idx = k - self.idx
				if slot_idx <= 1 then
					self.idx = k - 2
				elseif slot_idx >= self.num_slots then
					self.idx = self.idx+slot_idx-self.num_slots+1
				end
				
				self.selected_recipe_by_tab_idx[self.tabidx] = recipe
				self:UpdateRecipes()
				self.craftslots:CloseAll()
				
				self.craftslots:LockOpen(k - self.idx)

				local slot = self.craftslots.slots[k - self.idx]
				if slot then
					if recipe.subcategory then
						self.recipepopup:Hide()
						local tabs = self:GetTabs() 
						tabs:SetGroupName(self.level+1, recipe.name)
						self.craftslots:Highlight(recipe.subcategory)
					else				
						if self.recipepopup.shown then
							self.recipepopup:SetRecipe(recipe, self.owner)
							self.recipepopup:MoveTo(self.recipepopup:GetPosition(), slot:GetPosition() + POPUPOFFSET, .2)
						else
							self.recipepopup:Show()
							self.recipepopup:SetPosition(slot:GetPosition() + POPUPOFFSET)
						end
						local tabs = self:GetTabs() 
						tabs:SetGroupName(self.level+1, nil)
					end
				end

				if slot and slot ~= self.oldslot then
					if self.oldslot then
						self.oldslot:ScaleTo(1.4,1,.1)
					end
					slot:ScaleTo(1,1.4,.2)
					self.oldslot = slot
				else
					-- CloseAll defocuses them
					slot:SetScale(1.4)
				end
				return true
			end
		end
	end
end

function ControllerCrafting:SelectNextRecipe()
	local old_recipe = self.selected_recipe_by_tab_idx[self.tabidx]

	local last_recipe = nil
	for k,v in ipairs(self.valid_recipes) do
		if last_recipe == self.selected_recipe_by_tab_idx[self.tabidx] then
			self:SelectRecipe(v)
			return old_recipe ~= v
		end
		last_recipe = v
	end
end

function ControllerCrafting:SelectPrevRecipe()
	local old_recipe = self.selected_recipe_by_tab_idx[self.tabidx]

	local last_recipe = self.valid_recipes[1]
	for k,v in ipairs(self.valid_recipes) do
		if self.selected_recipe_by_tab_idx[self.tabidx] == v then
			self:SelectRecipe(last_recipe)
			return last_recipe ~= old_recipe
		end
		last_recipe = v
	end
end

function ControllerCrafting:GetTabIndex(tabfilter)
	local tabs = self:GetTabs() 
	local index = tabs:GetTabIndex(tabfilter)
	return index
end

function ControllerCrafting:OpenRecipeTab(tabfilter)
	if tabfilter then
		local index = self:GetTabIndex(tabfilter)
		local tabs = self:GetTabs() 
		local tab = tabs and tabs:OpenTab(index)
		self.tabidx = tabfilter
		local tabname = STRINGS.TABS[tabfilter.str]
		if self.groupname then
			self.groupname:SetString(tabname)
		end
		-- Hacky, but subsequent levels would be driven by the categories being clicked
		if self.level == 0 then
		tabs:SetGroupName(self.level, tabfilter.str)		
		end
		local crafttabs = GetPlayer().HUD.controls and GetPlayer().HUD.controls.crafttabs
		local multitab_crafting_stations = crafttabs.multitab_crafting_stations
		self:SetFilter( 
			function(recipe)
                local rec = GetRecipe(recipe)
				if tabfilter.str == "CRAFTINGSTATIONS" then
					return rec and rec.tab == tabfilter and multitab_crafting_stations[rec.name]
				else
					return rec and rec.tab == tabfilter
				end
			end)
		if not self:SelectRecipe(self.selected_recipe_by_tab_idx[self.tabidx]) then
			self:SelectRecipe()
		end
		return tabfilter
	end
end

function ControllerCrafting:OpenRecipeTab_Index(idx)
	local tabs = self:GetTabs() 
	local tab = tabs and tabs:OpenTab(idx)
	if tab then
		return self:OpenRecipeTab(tab.filter)
	end
end

function ControllerCrafting:Refresh()
	self.recipepopup:Refresh()
	self.craftslots:Refresh()
end

function ControllerCrafting:OnControl(control, down)
	if not self.open then return end

	if not down and (control == CONTROL_ACCEPT or control == CONTROL_ACTION) then
		if self.accept_down then
			self.accept_down = false --this was held down when we were opened, so we want to ignore it
		else
			local recipe = self.selected_recipe_by_tab_idx[self.tabidx]
			if recipe.subcategory then
				local crafttabs = self.parent
				crafttabs:OpenSubTab_Controller(self.level, recipe.subcategory)
			else
				if not DoRecipeClick(self.owner, recipe, true) then 
					self.owner.HUD:CloseControllerCrafting()
				end
			
				if not self.control_held then
					self.owner.HUD:CloseControllerCrafting()
				end
			end
		end
        
        return true
	end


	local tabs = self:GetTabs() 
	local activeLevel = tabs:GetControllerLevel()
	if not down and control == CONTROL_CANCEL and activeLevel ~= 0 then
		self:Close()
		return true
	end
	
	if not down and control == CONTROL_OPEN_CRAFTING and self.control_held and self.control_held_time > 1 then
		self.owner.HUD:CloseControllerCrafting()
		return true
	end
	
end

function ControllerCrafting:GetNextTab()
	local idx = self:GetTabs():GetNextIdx()
	local tabs = self:GetTabs() 
	local tab = tabs and tabs:GetTab(idx)
	return tab
end

function ControllerCrafting:GetPrevTab()
	local idx = self:GetTabs():GetPrevIdx()
	local tabs = self:GetTabs() 
	local tab = tabs and tabs:GetTab(idx)
	return tab
end

function ControllerCrafting:TabForIndex(idx)
	local tabs = self:GetTabs() 
	local tab = tabs and tabs:GetTab(idx)
	return tab
end


function ControllerCrafting:OnUpdate(dt)
	if GetPlayer().HUD ~= TheFrontEnd:GetActiveScreen() then return end
	if not GetPlayer().HUD.shown then return end
	if not self.open then return end

	local tabs = self:GetTabs() 
	local activeLevel = tabs:GetControllerLevel()
--print("activeLevel:",activeLevel)
	if self.level ~= activeLevel then 
		self.back:Hide()
		return 
	end 
	
	if TheInput:ControllerAttached() then
		self.back:Show()
	else
		self.back:Hide()
	end

	if self.control_held then
		self.control_held = TheInput:IsControlPressed(CONTROL_OPEN_CRAFTING)
		self.control_held_time = self.control_held_time + dt
	end
	
	if self.repeat_time > 0 then
		self.repeat_time = self.repeat_time - dt
	end

	if self.repeat_time <= 0 then
		if TheInput:IsControlPressed(CONTROL_MOVE_LEFT) then
			if self:SelectPrevRecipe() then
				TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
			end
		elseif TheInput:IsControlPressed(CONTROL_MOVE_RIGHT) then
			if self:SelectNextRecipe() then
				TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
			end
		elseif TheInput:IsControlPressed(CONTROL_MOVE_UP) then
			if self.level == 0 then
				local tab = self:GetPrevTab()
				if tab and self.tabidx ~= tab.filter and self:OpenRecipeTab(tab.filter) then
					TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/craft_up")
				end
			end
		elseif TheInput:IsControlPressed(CONTROL_MOVE_DOWN) then
			if self.level == 0 then
				local tab= self:GetNextTab()
				if tab and self.tabidx ~= tab.filter and self:OpenRecipeTab(tab.filter) then
					TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/craft_down")
				end
			end
		else
			self.repeat_time = 0
			return
		end
		self.repeat_time = REPEAT_TIME
	end	
end

return ControllerCrafting