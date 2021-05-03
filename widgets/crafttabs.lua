require "class"

local TileBG = require "widgets/tilebg"
local InventorySlot = require "widgets/invslot"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local Widget = require "widgets/widget"
local TabGroup = require "widgets/tabgroup"
local UIAnim = require "widgets/uianim"
local Text = require "widgets/text"
local MouseCrafting = require "widgets/mousecrafting"
local ControllerCrafting = require "widgets/controllercrafting"

local base_scale = .75
local selected_scale = .9
local HINT_UPDATE_INTERVAL = 2.0 -- once per second
local SCROLL_REPEAT_TIME = .15
local MOUSE_SCROLL_REPEAT_TIME = 0

local tab_bg = 
{
    normal = "tab_normal.tex",
    selected = "tab_selected.tex",
    highlight = "tab_highlight.tex",
    bufferedhighlight = "tab_place.tex",
    overlay = "tab_researchable.tex",
}


local CraftTabs = Class(Widget, function(self, owner, top_root)

    Widget._ctor(self, "CraftTabs")
    self.owner = GetPlayer()    
	self.owner = owner

	self.craft_idx_by_tab = {}

    self:SetPosition(0, 0, 0)

    self.craftsubtabs = {}
    for i=4,1,-1 do
        self.craftsubtabs[i] = self:AddChild(MouseCrafting(i))
    end

    self.crafting_controller = self:AddChild(ControllerCrafting())
	self.crafting_controller:Hide()

    self.craftsubtabs_controller = {}
    for i=4,1,-1 do
        self.craftsubtabs_controller[i] = self:AddChild(ControllerCrafting(i))
		self.craftsubtabs_controller[i]:Hide()
    end
	self.controller_level_active = 0
  
    self.crafting = self:AddChild(MouseCrafting())
    self.crafting:Hide()
    self.bg = self:AddChild(Image("images/hud.xml", "craft_bg.tex"))      

    self.bg_cover = self:AddChild(Image("images/hud.xml", "craft_bg_cover.tex"))
    self.bg_cover:SetPosition(-38, 0, 0)
    self.bg_cover:SetClickable(false)

    self.tabs = self:AddChild(TabGroup())
    self.tabs:SetPosition(-16, 0, 0)

    self.tabs.onopen         = function() self.owner.SoundEmitter:PlaySound("dontstarve/HUD/craft_open") end
    self.tabs.onchange       = function() self.owner.SoundEmitter:PlaySound("dontstarve/HUD/craft_open") end
    self.tabs.onclose        = function() self.owner.SoundEmitter:PlaySound("dontstarve/HUD/craft_close") end
    self.tabs.onhighlight    = function() self.owner.SoundEmitter:PlaySound("dontstarve/HUD/recipe_ready") return .2 end
    self.tabs.onalthighlight = function() end
    self.tabs.onoverlay      = function() self.owner.SoundEmitter:PlaySound("dontstarve/HUD/research_available") return .2 end

    local is_shipwrecked = SaveGameIndex:IsModeShipwrecked()
    local is_porkland = SaveGameIndex:IsModePorkland()

    local tabnames = {}
    local numtabslots = 1 --reserver 1 slot for crafting station tabs

    for k, v in pairs(RECIPETABS) do    

    	local passed = true
    	if     ((not is_shipwrecked and not is_porkland) and v.str == "NAUTICAL") 
			then
    		passed = false	
    	end
    	if passed then
    		table.insert(tabnames, v)

            if not v.crafting_station then
                numtabslots = numtabslots + 1
            end            
    	end
    end

    for k, v in pairs(owner.components.builder.custom_tabs) do
        table.insert(tabnames, v)
        if not v.crafting_station then
            numtabslots = numtabslots + 1
        end
    end

    table.sort(tabnames, function(a, b) return a.sort < b.sort end)

    self.tab_order = {}

    self.tabs.spacing = 750/numtabslots

    self.tabbyfilter = {}
    local was_crafting_station = nil
    for k, v in ipairs(tabnames) do

        local tab = self.tabs:AddTab(

        	STRINGS.TABS[v.str],
        	resolvefilepath("images/hud.xml"),
        	v.icon_atlas or resolvefilepath("images/hud.xml"),
        	v.icon,
        	tab_bg.normal,
        	tab_bg.selected,
        	tab_bg.highlight,
        	tab_bg.bufferedhighlight,
        	tab_bg.overlay,
            nil,
            function() --select fn
                if not self.controllercraftingopen then
					local multitab_crafting_stations = self.multitab_crafting_stations
	                self.crafting:SetFilter( 
	                    function(recipe)
	                        local rec = GetRecipe(recipe)
							if v.str == "CRAFTINGSTATIONS" then
		                        return rec and rec.tab == v and multitab_crafting_stations[rec.name]
							else
		                        return rec and rec.tab == v
							end
	                    end)

					self.crafting:Open()
                end
            end, 

            function() --deselect fn
            		self.craft_idx_by_tab[k] = self.crafting.idx
                	self.crafting:Close()
            end,
            was_crafting_station and v.crafting_station
        )
        was_crafting_station = v.crafting_station
        tab.filter = v
        tab.icon = v.icon
        tab.icon_atlas = v.icon_atlas or resolvefilepath("images/hud.xml")
        tab.tabname = STRINGS.TABS[v.str]       
        self.tabbyfilter[v] = tab

        table.insert(self.tab_order, tab)
    end

	-- find the multitab
	for i,v in pairs(self.tabbyfilter) do
		if i.str == "CRAFTINGSTATIONS" then
			self.multitab = v
		end
	end


    self.inst:ListenForEvent("techtreechange", 
			function(inst, data) 
				self:UpdateRecipes() 
				self:Close()
			end, 
			self.owner)
    self.inst:ListenForEvent("bufferbuild", 
			function(inst, data) 
				self:UpdateRecipes() 
			end, 
			self.owner)
    self.inst:ListenForEvent("itemget", function(inst, data) self:UpdateRecipes() end, self.owner)
    self.inst:ListenForEvent("containergotitem", function(inst, data) self:UpdateRecipes() end, self.owner)
    self.inst:ListenForEvent("itemlose", function(inst, data) self:UpdateRecipes() end, self.owner)
    self.inst:ListenForEvent("stacksizechange", function(inst, data) self:UpdateRecipes() end, self.owner)
    self.inst:ListenForEvent("unlockrecipe", function(inst, data) self:UpdateRecipes() end, self.owner)
    self:DoUpdateRecipes()
    self:SetScale(base_scale, base_scale, base_scale)
    self:StartUpdating()

	self.openhint = self:AddChild(Text(UIFONT, 40))
	self.openhint:SetPosition(10+150, 430, 0)
	self.openhint:SetRegionSize(300, 45, 0)
	self.openhint:SetHAlign(ANCHOR_LEFT)

    self.hint_update_check = HINT_UPDATE_INTERVAL    

	self:SetShouldShowTabFn("CITY", function()
									    return not TheCamera.interior
									end)
	self:SetShouldShowTabFn("HOME", function()
									    local interiorSpawner = GetWorld().components.interiorspawner
										return interiorSpawner and interiorSpawner.current_interior and interiorSpawner.current_interior.playerroom
									end)

end)

function CraftTabs:GetTab(idx)
	return self.tabs:GetTab(idx)
end

function CraftTabs:SetShouldShowTabFn(name, fn)
	self.shouldShowTabFns = self.shouldShowTabFns or {}
	self.shouldShowTabFns[name] = fn
end

function CraftTabs:ShouldShowTab(name)
	if self.shouldShowTabFns and self.shouldShowTabFns[name] then
		return self.shouldShowTabFns[name]()
	end
	return true
end

function CraftTabs:OpenSubTab(level, category)
	assert(self.craftsubtabs[level+1])

	self:HideSubTab(level + 1)

	local crafttab = self.craftsubtabs[level+1]
	crafttab:SetFilter( 
	                    function(recipe)
	                        local rec = GetRecipe(recipe)
	                        return rec and rec.tab == category
	                    end)
	crafttab:Open()
	self.owner.SoundEmitter:PlaySound("dontstarve/HUD/craft_open")
	if level == 0 then
		self.crafting.opensub = true
	else
		-- tell our parent they opened a subtab
		self.craftsubtabs[level].opensub = true
	end
end

function CraftTabs:OpenSubTab_Controller(level, category)
	assert(self.craftsubtabs[level+1])

	self:HideSubTab_Controller(level + 1)

	local crafttab = self.craftsubtabs_controller[level+1]
	crafttab.tabidx = category
	self.owner.SoundEmitter:PlaySound("dontstarve/HUD/craft_open")
	if level == 0 then
		self.crafting_controller.opensub_controller = true
	else
		self.craftsubtabs_controller[level].opensub_controller = true
	end
    self.controller_level_active = level+1
	crafttab:Open()
end

function CraftTabs:GetControllerLevel()
	return self.controller_level_active
end

function CraftTabs:HideSubTab(level)
	local crafttab
	if level == 0 then
		crafttab = self.crafting
	else
		crafttab = self.craftsubtabs[level]
	end
    if crafttab then
		if crafttab.opensub then
			self:HideSubTab(crafttab.level+1)
		end
		crafttab:Hide()
	end
end

function CraftTabs:HideSubTab_Controller(level)
	local workLevel = level
	local crafttab
	if workLevel == 0 then
		crafttab = self.crafting_controller
	else
		crafttab = self.craftsubtabs_controller[workLevel]
	end
    if crafttab then
		if crafttab.opensub_controller then
			self:HideSubTab_Controller(workLevel+1)

		end
		crafttab:Hide()

		crafttab.opensub_controller = nil
		-- this is also called on the root craft tab, don't want it to go -1 do
		local newLevel = math.max(0,crafttab.level - 1)
		self.controller_level_active = newLevel
		-- reset the focus
		local newActiveTab = (newLevel == 0 ) and self.crafting_controller or self.craftsubtabs_controller[newLevel]
		newActiveTab:SetFocus()

		self:SetGroupName()
	end
end

function CraftTabs:SetGroupName(level, str)		
	self.levelnames = self.levelnames or {}
	if level then
		self.levelnames[level] = str
	end

	local function LookUp(str)
		return str and (STRINGS.TABS[string.upper(str)] or "NOT FOUND("..str..")") or nil
	end

	local name = LookUp(self.levelnames[0])
	for i=1,self.controller_level_active+1 do
		if self.levelnames[i] then
			if #name > 0 then
				name = name .. " - "
			end
			name = name..LookUp(self.levelnames[i])
		end
	end
	self.crafting_controller.groupname:SetString(name)
end

function CraftTabs:GetTabIndex(tabfilter)
	local tabs = self.tabs.tabs
	for i,v in pairs(tabs) do
		if v.filter == tabfilter then	
			return i
		end			
	end
end

function CraftTabs:Close()
	self.crafting:Close()
	self.crafting_controller:Close()

	self.tabs:DeselectAll()
	self.controllercraftingopen = false
end

function CraftTabs:CloseControllerCrafting()
	if self.controllercraftingopen then
		self:ScaleTo(selected_scale, base_scale, .15)
		--self.blackoverlay:Hide()
		self.controllercraftingopen = false
		self.tabs:DeselectAll()
		self.crafting_controller:Close()
	end
end

function CraftTabs:OpenControllerCrafting()
	--self.parent:AddChild(self.controllercrafting)
	
	if not self.controllercraftingopen then
		self:ScaleTo(base_scale, selected_scale, .15)
		--self.blackoverlay:Show()
		self.controllercraftingopen = true
		self.crafting:Close()
		-- force an update on the recipes so we know valid tabs
		self:UpdateRecipes()
		self:DoUpdateRecipes()

		
		if self.crafting_controller.tabidx then
			local activeCategory = self.crafting_controller.tabidx.str
			local activeIndex = self.crafting_controller.tabidx.sort

			-- Is the active category still active?
			local shown = false
			for i,v in pairs(self.tabs.shown) do
				if i.filter.str == activeCategory then
					shown = v
				end
			end
			if not shown then
				local activeTab
				-- do we have another tab at that index that is shown?
				for tab,shown in pairs(self.tabs.shown) do
					if (tab.filter.sort == activeIndex) and shown then
						activeTab = tab.filter
						break
					end
				end
				-- if we found an alternative select that, otherwise resign to the first
				if activeTab then
					self.crafting_controller.tabidx = activeTab
				else
					-- revert to the active tab with the lowest sortkey
					local lowestTab
					local lowestIndex = 9999
					for tab,shown in pairs(self.tabs.shown) do
						print(tab.filter.str)
						if shown and tab.filter.sort < lowestIndex then
							lowestIndex = tab.filter.sort
							lowestTab = tab.filter
						end
					end
					if lowestTab then
						self.crafting_controller.tabidx = lowestTab
					end
				end
			end
		end
		self.crafting_controller:Open()	
	end
end

function CraftTabs:OnUpdate(dt)
	self.hint_update_check = self.hint_update_check - dt
	if 0 > self.hint_update_check then
	   	if not TheInput:ControllerAttached() then
			self.openhint:Hide()
		else
			self.openhint:Show()
		    self.openhint:SetString(TheInput:GetLocalizedControl(TheInput:GetControllerID(), CONTROL_OPEN_CRAFTING))
		end
	    self.hint_update_check = HINT_UPDATE_INTERVAL
	end

	if self.crafting.open then
		local x = TheInput:GetScreenPosition().x
		local w, h = TheSim:GetScreenSize()
		if x > w*.44 then
			self.crafting:Close()
			self.tabs:DeselectAll()
		end
	end

	if self.needtoupdate then
		self:DoUpdateRecipes()
	end
end

function CraftTabs:OpenTab(idx)
	return self.tabs:OpenTab(idx)
end


function CraftTabs:GetCurrentIdx()
	return self.tabs:GetCurrentIdx()
end

function CraftTabs:GetIndex(tabfilter)
	return self.tabs:GetIndex(tabfilter)
end

function CraftTabs:GetNextIdx()
	return self.tabs:GetNextIdx()
end

function CraftTabs:GetPrevIdx()
	return self.tabs:GetPrevIdx()
end


function CraftTabs:UpdateRecipes()
    self.needtoupdate = true
end

function CraftTabs:HandleMultiCraftingStationTabs(valid_tabs)
	-- if there's more than one tab at an index replace it with a multitab that has all these tabs
	local tabcounts = {}
	local multitab 
	for i,v in pairs(self.tabbyfilter) do
		if v ~= self.multitab then
			local isValid = valid_tabs[v]
			if isValid then
				local index = i.sort
				tabcounts[index] = tabcounts[index] or {}
				table.insert(tabcounts[index],{i,v})
			end
		end
	end

	-- do we have to create the multitab?
	for i,v in pairs(tabcounts) do
		if #v > 1 then
			-- show the multitab, hide the subtabs	
			if self.multitab then

				-- hide the specific subtabs
				for i,v in pairs(v) do   
					valid_tabs[v[2]] = false
				end
				-- show the multitab
				valid_tabs[self.multitab] = true

				-- and add them to the multitab
				self.multitab_crafting_stations = {}

				-- sort these guys, recipes are shown in the order they're added (or re-added)
			    table.sort(v, function(a, b) 
									local tabname_a = a[1].str
									local tabname_b = b[1].str
									local tabdef_a = RECIPETABS[tabname_a]
									local tabdef_b = RECIPETABS[tabname_b]
									return tabdef_a.priority < tabdef_b.priority 
								end)
				
				local highlighted = false
				local alternatehighlighted = false
				local overlayshow = false

				for i,v in pairs(v) do
					-- Create RecipeCategories for these guys, and add tehm to the multitab
					local tabdef = v[1]
					local actualTab = v[2]

					local name = tabdef.str
					local tabname = name
					local imagename = actualTab.icon
					-- strip off the .tex if it exists
					if imagename:endsWith(".tex") then
						imagename = imagename:left(-4)
					end
					local tooltip = STRINGS.TABS[string.upper(name)]
					local category = RecipeCategory(tabname, RECIPETABS[name], RECIPETABS.CRAFTINGSTATIONS, TECH.NONE, RECIPE_GAME_TYPE.COMMON, imagename, tooltip)
					category.atlas = actualTab.atlas
					category.imageScale = 0.5
					category.imageNudge = -6
					category.skipCategoryCheck = true -- to prevent some expensive work that is not needed on these guys

					self.multitab_crafting_stations[tabname] = true
					-- does this one have an alt-highlight?
					category.alternatehighlighted = actualTab.alternatehighlighted
					alternatehighlighted = alternatehighlighted or actualTab.alternatehighlighted
					-- or a highlight? (takes precedence)
					category.highlighted = actualTab.highlighted
					highlighted = highlighted or actualTab.highlighted
					-- an overlay?
					category.overlayshow = actualTab.overlayshow
					overlayshow = overlayshow or actualTab.overlayshow
				end
				-- handle ourselves as well
				if highlighted or alternatehighlighted then
					if highlighted then
						self.multitab:Highlight(1)
					else
						self.multitab:UnHighlight(true)
						self.multitab:AlternateHighlight(1)
					end
				else
					self.multitab:UnHighlight()
				end
				if overlayshow then
					self.multitab:Overlay()
				else
					self.multitab:HideOverlay()
				end
				-- force a refresh of the known recipes
				local recipes = GetAllRecipes(true)
			end
		end
	end
	
        --self.tabbyfilter[v] = tab
end


function CraftTabs:HandleTabHighlight(tabs_to_highlight, tabs_to_alt_highlight, tabs_to_overlay, valid_tabs)
	-- multitab has its own handling so it shouldn't be handled here
	valid_tabs[self.multitab] = false

	for tab,valid in pairs(valid_tabs) do
		local v = tabs_to_highlight[tab]

		if valid then
			if v > 0 and (not self.tabs_to_highlight or v ~= self.tabs_to_highlight[tab]) then
				tab:Highlight(v)
			end
		else
			-- invalid tabs should be dehighlighted so that they highlight again when they become available
			if tab ~= self.multitab then 
				tab:UnHighlight(true)
				tabs_to_highlight[tab] = 0
			end
		end
	end

	for k, v in pairs(tabs_to_alt_highlight) do
		if v > 0 and tabs_to_highlight[k] <= 0 then
			if valid_tabs[k] then
				k:UnHighlight(true)
				k:AlternateHighlight(v)
			end
		end 
	end

	for k, v in pairs(tabs_to_highlight) do
		for m,n in pairs(tabs_to_alt_highlight) do
			if k == m then
				if v <= 0 and n <= 0 then
					if valid_tabs[k] then
						k:UnHighlight()
					end
				end
			end
		end
	end

	for k, v in pairs(tabs_to_overlay) do    
		if v > 0 then
			k:Overlay()
		else
			k:HideOverlay()
		end
	end    
end

function CraftTabs:DoUpdateRecipes()
	if self.needtoupdate then

		self.needtoupdate = false	
		local tabs_to_highlight = {}
		local tabs_to_alt_highlight = {}
		local tabs_to_overlay = {}
		local valid_tabs = {}

		for k, v in pairs(self.tabbyfilter) do
			tabs_to_highlight[v] = 0
			tabs_to_alt_highlight[v] = 0
			tabs_to_overlay[v] = 0
			valid_tabs[v] = false
		end

		if self.owner.components.builder then
			local current_research_level = self.owner.components.builder.accessible_tech_trees or NO_TECH

			local recipes = GetAllRecipes(true)
			for k, rec in pairs(recipes) do


				local recTab = rec.tab

				if rec.tab and rec.tab.isReno then
					recTab = RECIPETABS.HOME
				end

				local shouldShow = self:ShouldShowTab(recTab and recTab.str)

				if self.tabbyfilter[recTab] ~= nil and shouldShow then --and recTab ~= RECIPETABS.HOME then -- and not self.owner.components.builder:ShouldHideTab(recTab) then
					local tab = self.tabbyfilter[recTab]
					local has_researched = self.owner.components.builder:KnowsRecipe(rec.name)

					local can_see = has_researched or CanPrototypeRecipe(rec.level, current_research_level)

					local can_build = self.owner.components.builder:CanBuild(rec.name)
					local buffered_build = self.owner.components.builder:IsBuildBuffered(rec.name)
					local can_research = false                    

					can_research = not has_researched and can_build and CanPrototypeRecipe(rec.level, current_research_level)
					-- categories will never get researched so would always stay highlighted as newly researchable
					if rec:is_a(RecipeCategory) then
						can_build = false
						can_research = false
					end

		            valid_tabs[tab] = valid_tabs[tab] or can_see

		            if buffered_build and has_researched then
						if tab then
							tabs_to_alt_highlight[tab] = 1 + (tabs_to_alt_highlight[tab] or 0)
						end
		            end

					-- nounlock recipes don't need to be researched, but has_researched will be false (or they'll be visible without their crafting station)
					if can_build and (has_researched or rec.nounlock) then
						if tab then
							tabs_to_alt_highlight[tab] = 0 -- Highlight takes precedence
							tabs_to_highlight[tab] = 1 + (tabs_to_highlight[tab] or 0)
						end
					end
					-- nounlock recipes should never show the overlay
					if can_research and not rec.nounlock then
						if tab then
							tabs_to_overlay[tab] = 1 + (tabs_to_overlay[tab] or 0)
						end
					end
				end
			end
		end

   		self:HandleTabHighlight(tabs_to_highlight, tabs_to_alt_highlight, tabs_to_overlay, valid_tabs)

		self:HandleMultiCraftingStationTabs(valid_tabs)

		local to_select = nil
		local current_open = nil

		for k, v in pairs(valid_tabs) do            

            --dumptable(valid_tabs, 1, 1, 1)

			if v then
				self.tabs:ShowTab(k)
			else
				self.tabs:HideTab(k)
			end
		end

		if self.crafting and self.crafting.shown then
			self.crafting:UpdateRecipes()
		end

		self:RefreshTabs()


		self.tabs_to_highlight = tabs_to_highlight

	end
end

function CraftTabs:RefreshTabs()
	if TheInput:ControllerAttached() then
		self.crafting_controller:Refresh()
	    for _,tab in ipairs(self.craftsubtabs_controller) do
			if tab.open then
	    	    tab:Refresh()
			end
	    end
	else
		self.crafting:Refresh()
	    for _,tab in ipairs(self.craftsubtabs) do
			if tab.open then
	    	    tab:Refresh()
			end
	    end
	end
end

function CraftTabs:IsCraftingOpen()
    return self.crafting.open or self.controllercraftingopen
end

function CraftTabs:OnControl(control, down)
    if CraftTabs._base.OnControl(self, control, down) then return true end

    if down and self.focus then
        if control == CONTROL_SCROLLBACK then        	
            if self.controllercraftingopen and TheInput:GetControlIsMouseWheel(control) then -- added TheInput:GetControlIsMouseWheel(control) to this check as the LEFT TRIGGER on a control should not scroll through the menus
                if self.crafting_controller.repeat_time <= 0 then
                    local idx = self.tabs:GetPrevIdx()
                    if self.crafting_controller.tabidx ~= idx and self.crafting_controller:OpenRecipeTab_Index(idx) then
                        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/craft_up")
                    end
                    self.crafting_controller.repeat_time =
                        TheInput:GetControlIsMouseWheel(control)
                        and MOUSE_SCROLL_REPEAT_TIME
                        or SCROLL_REPEAT_TIME
                end
            elseif self.crafting.open then
                local idx = self.tabs:GetPrevIdx()
                if self.tabs:GetCurrentIdx() ~= idx and self:OpenTab(idx) then
                    TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/craft_open")
                end
            else
                local idx = self.tabs:GetLastIdx()
                if idx ~= nil and self:OpenTab(idx) then
                    TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/craft_open")
                end
            end
            return true
        elseif control == CONTROL_SCROLLFWD then
            if self.controllercraftingopen and TheInput:GetControlIsMouseWheel(control) then -- added TheInput:GetControlIsMouseWheel(control) to this check as the LEFT TRIGGER on a control should not scroll through the menus
                if self.crafting_controller.repeat_time <= 0 then
                    local idx = self.tabs:GetNextIdx()
                    if self.crafting_controller.tabidx ~= idx and self.crafting_controller:OpenRecipeTab_Index(idx) then
                        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/craft_down")
                    end
                    self.crafting_controller.repeat_time =
                        TheInput:GetControlIsMouseWheel(control)
                        and MOUSE_SCROLL_REPEAT_TIME
                        or SCROLL_REPEAT_TIME
                end
            elseif self.crafting.open then
                local idx = self.tabs:GetNextIdx()
                if self.tabs:GetCurrentIdx() ~= idx and self:OpenTab(idx) then
                    TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/craft_open")
                end
            else
                local idx = self.tabs:GetFirstIdx()
                if idx ~= nil and self:OpenTab(idx) then
                    TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/craft_open")
                end
            end
            return true
        end
    end
end

return CraftTabs
