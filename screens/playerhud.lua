local Screen = require "widgets/screen"
local ContainerWidget = require("widgets/containerwidget")
local Controls = require("widgets/controls")
local UIAnim = require "widgets/uianim"
local Widget = require "widgets/widget"
local IceOver = require "widgets/iceover"
local FireOver = require "widgets/fireover"
local BloodOver = require "widgets/bloodover"
local BeefBloodOver = require "widgets/beefbloodover"
local HeatOver = require "widgets/heatover"
local PoisonOver = require "widgets/poisonover"
local BoatOver = require "widgets/boatover"
--local SandOver = require "widgets/sandover"
--local SandDustOver = require "widgets/sanddustover"
local BatSonar = require "widgets/batsonar"
local FogOver = require "widgets/fogover"
local PollenOver = require "widgets/pollenover"
local VisorOver = require "widgets/visorover"

local LivingArtifactOver = require "widgets/livingartifactover"

local easing = require("easing")

local ConsoleScreen = require "screens/consolescreen"
local MapScreen = require "screens/mapscreen"
local PauseScreen = require "screens/pausescreen"

local Text = require "widgets/text"

local PlayerHud = Class(Screen, function(self)
	Screen._ctor(self, "HUD")
    
    self.overlayroot = self:AddChild(Widget("overlays"))

    self.under_root = self:AddChild(Widget("under_root"))
    self.root = self:AddChild(Widget("root"))
end)

function PlayerHud:CreateOverlays(owner)
	
	self.overlayroot:KillAllChildren()

    self.vig = self.overlayroot:AddChild(UIAnim())
    self.vig:GetAnimState():SetBuild("vig")
    self.vig:GetAnimState():SetBank("vig")
    self.vig:GetAnimState():PlayAnimation("basic", true)

    self.vig:SetHAnchor(ANCHOR_MIDDLE)
    self.vig:SetVAnchor(ANCHOR_MIDDLE)
    self.vig:SetScaleMode(SCALEMODE_FIXEDSCREEN_NONDYNAMIC)

    self.vig:SetClickable(false)
    
    self.leavesTop = self.overlayroot:AddChild(UIAnim())
    self.leavesTop:SetClickable(false)
    self.leavesTop:SetHAnchor(ANCHOR_MIDDLE)
    self.leavesTop:SetVAnchor(ANCHOR_TOP)
    self.leavesTop:GetAnimState():SetBank("leaves_canopy2")
    self.leavesTop:GetAnimState():SetBuild("leaves_canopy2")
    self.leavesTop:GetAnimState():PlayAnimation("idle", true)
    self.leavesTop:GetAnimState():SetMultColour(1,1,1,1)   
    self.leavesTop:SetScaleMode(SCALEMODE_FIXEDSCREEN_NONDYNAMIC)    
	self.leavesTop:GetAnimState():SetEffectParams( 0.784, 0.784, 0.784, 1)    
	self.leavesTop:Hide()


    --self.sanddustover = self.storm_overlays:AddChild(SandDustOver(owner))
    --self.sandover = self.overlayroot:AddChild(SandOver(owner, self.sanddustover))
    self.batview = self.overlayroot:AddChild(BatSonar(owner))
    self.fogover = self.overlayroot:AddChild(FogOver(owner))
    self.pollenover = self.overlayroot:AddChild(PollenOver(owner))
    self.bloodover = self.overlayroot:AddChild(BloodOver(owner))
    self.beefbloodover = self.overlayroot:AddChild(BeefBloodOver(owner))    
    self.boatover = self.overlayroot:AddChild(BoatOver(owner))
    self.poisonover = self.overlayroot:AddChild(PoisonOver(owner))
	self.visorover = self.overlayroot:AddChild(VisorOver(owner)) 
	self.livingartifactover = self.overlayroot:AddChild(LivingArtifactOver(owner))   
    self.iceover = self.overlayroot:AddChild(IceOver(owner))
    self.fireover = self.overlayroot:AddChild(FireOver(owner))
    self.heatover = self.overlayroot:AddChild(HeatOver(owner))
    self.iceover:Hide()
    self.fireover:Hide()
    self.heatover:Hide()
    self.batview:Hide()
    self.fogover:Hide()
	self.pollenover:Hide()

    self.clouds = self.overlayroot:AddChild(UIAnim())
    self.clouds:SetClickable(false)
    self.clouds:SetHAnchor(ANCHOR_MIDDLE)
    self.clouds:SetVAnchor(ANCHOR_MIDDLE)
    self.clouds:GetAnimState():SetBank("clouds_ol")
    self.clouds:GetAnimState():SetBuild("clouds_ol")
    self.clouds:GetAnimState():PlayAnimation("idle", true)
    self.clouds:GetAnimState():SetMultColour(1,1,1,0)
    self.clouds:SetScaleMode(SCALEMODE_FIXEDSCREEN_NONDYNAMIC)    
    self.clouds:Hide()


    self.leaves = self.overlayroot:AddChild(UIAnim())
    self.leaves:SetClickable(false)
    self.leaves:SetHAnchor(ANCHOR_MIDDLE)
    self.leaves:SetVAnchor(ANCHOR_MIDDLE)
    self.leaves:GetAnimState():SetBank("leaves_canopy")
    self.leaves:GetAnimState():SetBuild("leaves_canopy")
    self.leaves:GetAnimState():PlayAnimation("idle", true)
    self.leaves:GetAnimState():SetMultColour(1,1,1,1)
    self.leaves:Hide()

    --[[self.oceanfog = self.overlayroot:AddChild(UIAnim())
    self.oceanfog:SetClickable(false)
    self.oceanfog:SetHAnchor(ANCHOR_MIDDLE)
    self.oceanfog:SetVAnchor(ANCHOR_MIDDLE)
    self.oceanfog:GetAnimState():SetBank("clouds_ol")
    self.oceanfog:GetAnimState():SetBuild("clouds_ol")
    self.oceanfog:GetAnimState():PlayAnimation("idle", true)
    self.oceanfog:GetAnimState():SetMultColour(1,1,1,0)
    self.oceanfog:Hide()]]

    self.smoke = self.overlayroot:AddChild(UIAnim())
    self.smoke:SetClickable(false)
    self.smoke:SetHAnchor(ANCHOR_MIDDLE)
    self.smoke:SetVAnchor(ANCHOR_MIDDLE)
    self.smoke:GetAnimState():SetBank("clouds_ol")
    self.smoke:GetAnimState():SetBuild("clouds_ol")
    self.smoke:GetAnimState():PlayAnimation("idle", true)
    self.smoke:GetAnimState():SetMultColour(1,1,1,0)
    self.smoke:Hide()
    
	if EARLYACCESS_ON == true then
	    self.watermark = self.overlayroot:AddChild(Text(UIFONT, 25))
		self.watermark:SetPosition(0,-30)
		self.watermark:SetRegionSize( 400, 44 )
		self.watermark:SetHAnchor(ANCHOR_MIDDLE)
		self.watermark:SetVAnchor(ANCHOR_TOP)
		self.watermark:SetString(STRINGS.UI.WATERMARK.PRERELEASE)
	end

end

function PlayerHud:OnLoseFocus()
	Screen.OnLoseFocus(self)
	TheInput:EnableMouse(true)

	--[[
	if self:IsControllerCraftingOpen() then
		self:CloseControllerCrafting()
	end

	if self:IsControllerInventoryOpen() then
		self:CloseControllerInventory()
	end
	--]]

	local is_controller_attached = TheInput:ControllerAttached()
	if is_controller_attached then
		self.owner.components.inventory:ReturnActiveItem()
	end
	self.controls.hover:Hide()
end

function PlayerHud:OnGainFocus()
	Screen.OnGainFocus(self)
	local controller = TheInput:ControllerAttached()
	if controller then
		TheInput:EnableMouse(false)
	else
		TheInput:EnableMouse(true)
	end
	
	if self.controls then
		self.controls:SetHUDSize()
		if controller then
			self.controls.hover:Hide()
		else
			self.controls.hover:Show()
		end
	end
	
	if not TheInput:ControllerAttached() then
		if self:IsControllerCraftingOpen() then
			self:CloseControllerCrafting()
		end

		if self:IsControllerInventoryOpen() then
			self:CloseControllerInventory()
		end
	end

end
	
function PlayerHud:Toggle()
	self.shown = not self.shown
	if self.shown then
		self.root:Show()
	else
		self.root:Hide()
	end
end

function PlayerHud:Hide()
	self.shown = false
	self.root:Hide()
end

function PlayerHud:Show()
	self.shown = true
	self.root:Show()
end

function PlayerHud:OpenBoat(boat, riding)
	if boat then
		local boatwidget = nil
		if riding then
			self.controls.inv.boatwidget = self.controls.inv.root:AddChild(ContainerWidget(self.owner))
			boatwidget = self.controls.inv.boatwidget
			boatwidget:SetScale(1)
			boatwidget.scalewithinventory = false
			boatwidget:MoveToBack()
			self.controls.inv:Rebuild()
		else
			boatwidget = self.controls.containerroot:AddChild(ContainerWidget(self.owner))
		end

		boatwidget:Open(boat, self.owner, not riding)

		for k,v in pairs(self.controls.containers) do
			if v.container then
				if v.parent == boatwidget.parent or k == boat then
					v:Close()
				end
			else
				self.controls.containers[k] = nil
			end
		end
	    
		self.controls.containers[boat] = boatwidget
	end
end

function PlayerHud:CloseContainer(container)
    for k,v in pairs(self.controls.containers) do
		if v.container == container then
			v:Close()
		end
    end
end

function PlayerHud:GetOpenContainerWidgets()
	return self.controls.containers
end


function PlayerHud:GetFirstOpenContainerWidget()
	local k,v = next(self.controls.containers)
	return v
end

function PlayerHud:OpenContainer(container, side)

	if side and TheInput:ControllerAttached() then
		return
	end

	if container then
		local containerwidget = nil
		if side then
			containerwidget = self.controls.containerroot_side:AddChild(ContainerWidget(self.owner))
		else
			containerwidget = self.controls.containerroot:AddChild(ContainerWidget(self.owner))
		end
		containerwidget:Open(container, self.owner)
	    
		for k,v in pairs(self.controls.containers) do
			if v.container then
		
				if TheInput:ControllerAttached() then	
					if v.container.prefab == container.prefab or v.parent == containerwidget.parent then
						v:Close()
					end
				else
					if v.container.prefab == container.prefab or v.container.components.container.type == container.components.container.type then
						v:Close()
					end
				end
			else
				self.controls.containers[k] = nil
			end
		end
	    
		self.controls.containers[container] = containerwidget
	end
end

function PlayerHud:GoSane()
    self.vig:GetAnimState():PlayAnimation("basic", true)
end

function PlayerHud:GoInsane()
    self.vig:GetAnimState():PlayAnimation("insane", true)
end

function PlayerHud:SetMainCharacter(maincharacter)
    if maincharacter then
		maincharacter.HUD = self
		self.owner = maincharacter

		self:CreateOverlays(self.owner)
		self.controls = self.root:AddChild(Controls(self.owner))

		self.inst:ListenForEvent("badaura", function(inst, data) return self.bloodover:Flash() end, self.owner)
		self.inst:ListenForEvent("attacked", function(inst, data) if not self.owner:HasTag("ironlord") and not data.redirected then return self.bloodover:Flash() end end, self.owner)
		self.inst:ListenForEvent("consumehealthcost", function(inst, data) return self.bloodover:Flash() end, self.owner)		
		self.inst:ListenForEvent("startstarving", function(inst, data) self.bloodover:UpdateState() end, self.owner)
		self.inst:ListenForEvent("stopstarving", function(inst, data) self.bloodover:UpdateState() end, self.owner)
		self.inst:ListenForEvent("startfreezing", function(inst, data) self.bloodover:UpdateState() end, self.owner)
		self.inst:ListenForEvent("stopfreezing", function(inst, data) self.bloodover:UpdateState() end, self.owner)
		self.inst:ListenForEvent("startoverheating", function(inst, data) self.bloodover:UpdateState() end, self.owner)
		self.inst:ListenForEvent("stopoverheating", function(inst, data) self.bloodover:UpdateState() end, self.owner)
		self.inst:ListenForEvent("gosane", function(inst, data) self:GoSane() end, self.owner)
		self.inst:ListenForEvent("goinsane", function(inst, data) self:GoInsane() end, self.owner)
		
		self.inst:ListenForEvent("poisondamage", function(inst, data) return self.poisonover:Flash() end, self.owner)
		self.inst:ListenForEvent("boatattacked", function(inst, data) return self.boatover:Flash() end, self.owner)

		self.inst:ListenForEvent("startfog", function(inst, data) return self.fogover:StartFog() end, self.owner)
		self.inst:ListenForEvent("stopfog", function(inst, data) return self.fogover:StopFog() end, self.owner)
		self.inst:ListenForEvent("setfog", function(inst, data) return self.fogover:SetFog() end, self.owner)
		
		self.inst:ListenForEvent("livingartifactoveron", function(inst, data) self.livingartifactover:UpdateState(data) print("EQUIP") end, self.owner)
		self.inst:ListenForEvent("livingartifactoveroff", function(inst, data) self.livingartifactover:UpdateState(data) print("UNEQUIP") end, self.owner)
		self.inst:ListenForEvent("livingartifactoverpulse", function(inst, data) self.livingartifactover:Flash(data) end, self.owner)
		
		self.inst:ListenForEvent("sanity_stun", function(inst, data) self:GoInsane() end, self.owner)		
		self.inst:ListenForEvent("sanity_stun_over", function(inst, data) 			
			if GetPlayer().components.sanity:IsSane() then
				self:GoSane()
			end
		end, self.owner)

		self.inst:ListenForEvent("updatepollen", function(inst, data) return self.pollenover:UpdateState(data.sneezetime) end, self.owner)

		self.inst:ListenForEvent("unequip", function(inst, data) self.visorover:UpdateState(data) end, self.owner)
		self.inst:ListenForEvent("equip", function(inst, data) self.visorover:UpdateState(data) end, self.owner)
		self.visorover:UpdateState()	-- it may already be equipped
		

		if not self.owner.components.sanity:IsSane() then
			self:GoInsane()
		end
		self.controls.crafttabs:UpdateRecipes()
		
		local bp = maincharacter.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
		if bp and bp.components.container then
			bp.components.container:Close()
			bp.components.container:Open(maincharacter)
		end
	end
end

function PlayerHud:OnUpdate(dt)
	self:UpdateClouds(dt)
	--self:UpdateOceanFog(dt)
	self:UpdateSmoke(dt)
	self:UpdateLeaves(dt)


	if Profile and self.vig then
		if RENDER_QUALITY.LOW == Profile:GetRenderQuality() or TheConfig:IsEnabled("hide_vignette") then
			self.vig:Hide()
		else
			self.vig:Show()
		end
	end
end

function PlayerHud:HideControllerCrafting()
	self.controls.crafttabs:MoveTo(self.controls.crafttabs:GetPosition(), Vector3(-200, 0, 0), .25)
end

function PlayerHud:ShowControllerCrafting()
	self.controls.crafttabs:MoveTo(self.controls.crafttabs:GetPosition(), Vector3(0, 0, 0), .25)
end


function PlayerHud:OpenControllerInventory()
	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/craft_open")
	TheFrontEnd:StopTrackingMouse()
	self:CloseControllerCrafting()
	self:HideControllerCrafting()
	self.controls.inv:OpenControllerInventory()
	self.controls:ShowStatusNumbers()

	self.owner.components.playercontroller:OnUpdate(0)
end

function PlayerHud:CloseControllerInventory()
	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/craft_close")
	self.controls:HideStatusNumbers()
	self:ShowControllerCrafting()
	self.controls.inv:CloseControllerInventory()
end

function PlayerHud:IsControllerInventoryOpen()
	return self.controls and self.controls.inv.open
end

function PlayerHud:IsCraftingOpen()
    return self.controls ~= nil and self.controls.crafttabs:IsCraftingOpen()
end

function PlayerHud:OpenControllerCrafting()
	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/craft_open")
	TheFrontEnd:StopTrackingMouse()
	self:CloseControllerInventory()
	self.controls.inv:Disable()
	self.controls.crafttabs:OpenControllerCrafting()
	self.owner.components.locomotor:Stop()
	--self.owner.components.playercontroller.draggingonground = false
	--self.owner.components.playercontroller.startdragtime = nil
end

function PlayerHud:CloseControllerCrafting()
	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/craft_close")
	self.controls.crafttabs:CloseControllerCrafting()	
	self.controls.inv:Enable()
end

function PlayerHud:IsControllerCraftingOpen()
	return self.controls and self.controls.crafttabs.controllercraftingopen
end


function PlayerHud:OnControl(control, down)
	if PlayerHud._base.OnControl(self, control, down) then return true end
	if not self.shown then return end


	if not down and control == CONTROL_PAUSE then
		TheFrontEnd:PushScreen(PauseScreen())
		return true
	end

	local blockHUDInput = (self.owner:HasTag("beaver") or self.owner:HasTag("ironlord"))

	if not down and control == CONTROL_MAP then
		
		
		if not blockHUDInput then
			self.controls:ToggleMap()			
			return true
		end
	end
	
	if not down and control == CONTROL_CANCEL then
		if self:IsControllerCraftingOpen() then
			if self.controls.crafttabs:GetControllerLevel() == 0 then
				self:CloseControllerCrafting()
			end
		end

		if self:IsControllerInventoryOpen() then
			self:CloseControllerInventory()
		end
	end

	
	if down and control == CONTROL_OPEN_CRAFTING then
		if self:IsControllerCraftingOpen() then
			self:CloseControllerCrafting()
		elseif not blockHUDInput then
			self:OpenControllerCrafting()
		end
	end

	if down and control == CONTROL_OPEN_INVENTORY then
		if self:IsControllerInventoryOpen() then
			self:CloseControllerInventory()
		elseif not blockHUDInput then
			self:OpenControllerInventory()
		end
	end
	
	if not blockHUDInput then
		--inventory hotkeys
		if down and control >= CONTROL_INV_1 and control <= CONTROL_INV_10 then
			local num = (control - CONTROL_INV_1) + 1
			local item = self.owner.components.inventory:GetItemInSlot(num)
			self.owner.components.inventory:UseItemFromInvTile(item)
			return true
		end
	end
end

function PlayerHud:OnRawKey( key, down )
	if PlayerHud._base.OnRawKey(self, key, down) then return true end
end

function PlayerHud:SetLeavesTopColorMult(r, g, b)
	self.leavestopmultiplytarget = {r=r, g=g, b=b}
end

function PlayerHud:UpdateLeaves(dt)

	local wasup = false
	if self.leavestop_intensity and self.leavestop_intensity > 0 then
		wasup = true
	end

	if not self.leavestopmultiplytarget then
		self.leavestopmultiplytarget = {r=1, g=1, b=1}
		self.leavestopmultiplycurrent = {r=1, g=1, b=1}		
	end

	if GetClock and GetClock() and GetClock():IsDusk() then
		self:SetLeavesTopColorMult(0.6, 0.6, 0.6)		
	elseif  GetClock and GetClock() and GetClock():IsNight() then
		self:SetLeavesTopColorMult(0.1, 0.1, 0.1)
	else
		self:SetLeavesTopColorMult(1, 1, 1)
	end	

	if self.leavesTop then
		if self.leavestopmultiplycurrent ~= self.leavestopmultiplytarget then
			if self.leavestopmultiplycurrent.r > self.leavestopmultiplytarget.r then
				self.leavestopmultiplycurrent.r = math.max(self.leavestopmultiplytarget.r, self.leavestopmultiplycurrent.r - (1*dt) )
				self.leavestopmultiplycurrent.g = math.max(self.leavestopmultiplytarget.g, self.leavestopmultiplycurrent.g - (1*dt) )
				self.leavestopmultiplycurrent.b = math.max(self.leavestopmultiplytarget.b, self.leavestopmultiplycurrent.b - (1*dt) )			
			else
				self.leavestopmultiplycurrent.r = math.min(self.leavestopmultiplytarget.r, self.leavestopmultiplycurrent.r + (1*dt) )
				self.leavestopmultiplycurrent.g = math.min(self.leavestopmultiplytarget.g, self.leavestopmultiplycurrent.g + (1*dt) )
				self.leavestopmultiplycurrent.b = math.min(self.leavestopmultiplytarget.b, self.leavestopmultiplycurrent.b + (1*dt) )
			end
			self.leavesTop:GetAnimState():SetMultColour(self.leavestopmultiplycurrent.r,self.leavestopmultiplycurrent.g,self.leavestopmultiplycurrent.b,1)
		end
		
	    if not self.leavestop_intensity then
	    	self.leavestop_intensity = 0
	    end	 

	    local player = GetPlayer()	  
	    self.under_leaves = false 

	    local pos = GetPlayer():GetPosition()
	    local ground = GetWorld()
	    local tile = ground.Map:GetTileAtPoint(pos.x, 0, pos.z)
	    for i,tiletype in ipairs(IS_CANOPY_TILE)do
	    	if tiletype == tile then
	    		self.under_leaves = true
	    	end
	    end

	 	if self.under_leaves then
			self.leavestop_intensity = math.min(1,self.leavestop_intensity+(1/30) )
		else			
		 	self.leavestop_intensity = math.max(0,self.leavestop_intensity-(1/30) )
		end	

	    if self.leavestop_intensity == 0 then
	    	if wasup then
	    		GetPlayer():PushEvent("canopyout")
	    	end

	    	self.leavesTop:Hide()
	    else
	    	self.leavesTop:Show()

			if self.leavestop_intensity == 1 then
		    	if not self.leavesfullyin then
		    		self.leavesTop:GetAnimState():PlayAnimation("idle", true)	
		    		self.leavesfullyin = true
		    		GetPlayer():PushEvent("canopyin")
		    	else	
			    	if GetPlayer().sg:HasStateTag("moving") then
			    		if not self.leavesmoving then
			    			self.leavesmoving = true
			    			self.leavesTop:GetAnimState():PlayAnimation("run_pre")	
			    			self.leavesTop:GetAnimState():PushAnimation("run_loop", true)					    					    	
			    		end
			    	else
			    		if self.leavesmoving then
			    			self.leavesmoving = nil
			    			self.leavesTop:GetAnimState():PlayAnimation("run_pst")	
			    			self.leavesTop:GetAnimState():PushAnimation("idle", true)	
			    			self.leaves_olddir = nil
			    		end
			    	end
		    	end
		    else
		    	self.leavesfullyin = nil
		    	self.leavesmoving = nil
		    	self.leavesTop:GetAnimState():SetPercent("zoom_in", self.leavestop_intensity)
			end	    	
	    end	    	    	
    end
end

function PlayerHud:UpdateClouds(dt)
	local player = GetPlayer()
	local equippeditem = player.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
	local wearingbathat = (equippeditem and (equippeditem.prefab == "bathat"))

	if not GetWorld():IsCave() then
	    --this is kind of a weird place to do all of this, but the anim *is* a hud asset...
	    local timeSinceZoom = TheCamera:GetTimeSinceZoom() or 1

	    if self.leaves then
		    self.under_leaves = player:HasTag("under_leaf_canopy")		    
    	end

    	local sm = GetWorld().components.seasonmanager

    	if sm.fog_state and sm.fog_state ~= FOG_STATE.CLEAR and self.clouds then
    	-- manage the clouds fx during foggy wether

			self.clouds_on = true
		    self.clouds:Show()
		    self.clouds_level = 0

            if not self.owner.SoundEmitter:PlayingSound("windsound") then
				self.owner.SoundEmitter:PlaySound("dontstarve/common/clouds", "windsound")    		
			end
        	local intensityMax= 0.2

        	local intensity = 0
        	local time = math.max(math.min(sm.fog_time, sm.fog_transition_time_max), 0)

        	if sm.fog_state == FOG_STATE.SETTING then
				intensity = Remap(time, sm.fog_transition_time_max, 0, 0, intensityMax)
        	elseif sm.fog_state == FOG_STATE.FOGGY then				
				intensity = intensityMax		
        	elseif sm.fog_state == FOG_STATE.LIFTING then
				intensity = Remap(time, sm.fog_transition_time_max, 0, intensityMax, 0)
        	end

				    	if wearingbathat then
				    		intensity= intensity*0.3		    
				    	end		

				    	if equippeditem and equippeditem:HasTag("clearclouds") then
				    		intensity = 0
				    	end

        	self.clouds:GetAnimState():SetMultColour(1, 1, 1, intensity )
        	self.clouds_level = intensity

        	self.owner.SoundEmitter:SetVolume("windsound", intensity)
        	self.wasfoggy = true



		    if TheCamera.interior then
		        self.clouds:Hide()	
		    else
		        self.clouds:Show()
		    end

    	else
    		if self.clouds then
    		--if self.wasfoggy then
				self.clouds_on = false
			    self.clouds:Hide()
			    self.clouds_level = 0
    	--		self.wasfoggy = nil
    		--end
    		end
		    if (TheCamera and TheCamera.distance and not TheCamera.dollyzoom and TheCamera:IsControllable() and timeSinceZoom < 1)  then --last two conditions are to keep clouds away from the volcano auto-zoom

		        local dist_percent = (TheCamera.distance - TheCamera.mindist) / (TheCamera.maxdist - TheCamera.mindist)
		        local cutoff = .6
		        if dist_percent > cutoff then

		        	if not self.atmosphere_layer_on then
		        		self.atmosphere_layer_on = true
						TheCamera.should_push_down = true
						TheMixer:PushMix("high")
					end

		        	if self.under_leaves then
		        		if not self.leaves_on then
		                	self.leaves_on = true
		                	self.leaves:Show()
		                	self.leaves_level = 0
			                --self.owner.SoundEmitter:PlaySound("dontstarve/common/clouds", "windsound")
		            	end	        		
		        	else
		        		if not self.clouds_on then
		                	self.clouds_on = true
		                	self.clouds:Show()
		                	self.clouds_level = 0
		                	
		                	if not self.owner.SoundEmitter:PlayingSound("windsound") then
			                	self.owner.SoundEmitter:PlaySound("dontstarve/common/clouds", "windsound")
			            	end
		            	end
		        	end

		            local p = easing.outCubic(dist_percent-cutoff, 0, 1, 1 - cutoff)
		           
		            if self.under_leaves then					

		            	local intensity = p

		            	if self.clouds_level and self.clouds_level > 0 then
		            		intensity = math.min(self.leaves_level + 0.05, p)	           		
		            	end

		            	--self.leaves:GetAnimState():SetMultColour(1,1,1, intensity )

						self.leaves:GetAnimState():SetPercent("zoom_out", intensity)

		            	self.leaves_level = intensity	     

		            elseif self.leaves_level and self.leaves_level > 0 then
		            	self.leaves_level = math.max(0, self.leaves_level - 0.06) 

		            	self.leaves:GetAnimState():SetPercent("zoom_out", self.leaves_level)
						--self.leaves:GetAnimState():SetMultColour(1,1,1, self.leaves_level)					
		            end

		            if not self.under_leaves  then

		            	local intensity = p
		            	--[[
		            	if self.fogover.foggy then
		            		intensity = 0.1
		            	end
						]]
	            		if self.leaves_level and self.leaves_level > 0 then
		            		intensity = math.min(self.clouds_level + 0.05, p)
		            	end

		            	self.clouds:GetAnimState():SetMultColour(1, 1, 1, intensity)
		            	self.clouds_level = intensity

		            	self.owner.SoundEmitter:SetVolume("windsound", intensity)

					elseif self.clouds_level and self.clouds_level > 0 then
		            	self.clouds_level = math.max(0,self.clouds_level - 0.06)             	
						self.clouds:GetAnimState():SetMultColour(1, 1, 1, self.clouds_level)
		            end	           
		            
		        else
					if self.atmosphere_layer_on then
						self.atmosphere_layer_on = false
		        		TheCamera.should_push_down = false
						TheMixer:PopMix("high")
					end            
		        end


	            if not self.atmosphere_layer_on or (self.clouds_level and self.clouds_level == 0) then			
	                self.clouds_on = false
	                self.clouds:Hide()

	                self.owner.SoundEmitter:KillSound("windsound")
	            end

	            if not self.atmosphere_layer_on or (self.leaves_level and self.leaves_level == 0)  then				
	                self.leaves_on = false
	                self.leaves:Hide()
	            --    self.owner.SoundEmitter:KillSound("windsound")
	            end		        
		    end	 
		end
	end
end

function PlayerHud:UpdateOceanFog(dt)
	local mapwrapper = GetPlayer().components.mapwrapper
	if mapwrapper and self.oceanfog then
		local x, y, z = GetPlayer().Transform:GetLocalPosition()
		local dist = mapwrapper:GetDistanceFromEdge(x, y, z)
		local distMax = TUNING.MAPWRAPPER_WARN_RANGE * TILE_SCALE
		local distMin = TUNING.MAPWRAPPER_LOSECONTROL_RANGE * TILE_SCALE

		if dist < distMax then
			local p = 1 - easing.outCubic(dist - distMin, 0, 1, distMax - distMin)

			self.oceanfog:Show()
			self.oceanfog:GetAnimState():SetMultColour(1, 1, 1, p)
		else
			self.oceanfog:Hide()
		end
	end
end

function PlayerHud:UpdateSmoke(dt)
	local vm = GetWorld().components.volcanomanager
	if self.smoke and vm then
		local rate = vm:GetSmokeRate()
		if rate > 0.0 then
			local g = 0.5
			local a = math.sin(PI*rate)
			self.smoke:Show()
			self.smoke:GetAnimState():SetMultColour(g, g, g, a)
			--[[local x, y, z = GetPlayer().Transform:GetLocalPosition()
			local dist = vm:GetDistanceFromVolcano(x, y, z)
			local distMax = 250 * TILE_SCALE
			local distMin = 25 * TILE_SCALE

			--print(string.format("%f < %f\n", dist, distMax))
			if dist < distMax then
				local p = 1 - easing.outCubic(dist - distMin, 0, 1, distMax - distMin)
				local g = easing.inOutSine(dist - distMin, 0.25, 0.5, distMax - distMin)
				--print(string.format("(%f, %f)\n", g, p))

				self.smoke:Show()
				self.smoke:GetAnimState():SetMultColour(g, g, g, p)
			else
				self.smoke:Hide()
			end]]
		else
			self.smoke:Hide()
		end
	end
end

return PlayerHud


