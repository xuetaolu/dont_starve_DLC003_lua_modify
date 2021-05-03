require "class"
local InvSlot = require "widgets/invslot"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local ImageButton = require "widgets/imagebutton"
local ItemTile = require "widgets/itemtile"
--local EquipSlot = require "widgets/equipslot"
local BoatEquipSlot = require "widgets/boatequipslot"
local BoatBadge = require "widgets/boatbadge"

local DOUBLECLICKTIME = .33
local HUD_ATLAS = "images/hud.xml"

local ContainerWidget = Class(Widget, function(self, owner)
    Widget._ctor(self, "Container")
    local scale = .6
    self:SetScale(scale,scale,scale)
    self.open = false
    self.inv = {}
    self.boatEquipInfo = {}
    self.boatEquip = {}
    self.owner = owner
    self:SetPosition(0, 0, 0)
    self.slotsperrow = 3
   	self.scalewithinventory = true
   

    self.bganim = self:AddChild(UIAnim())
	self.bgimage = self:AddChild(Image())
	self.boatbadge = self:AddChild(BoatBadge(owner))
	self.boatbadge:Hide()
    self.isopen = false
end)

function ContainerWidget:Open(container, doer, boatwidget)
    self:Close()
	self:StartUpdating()

	self.widgetinfo = container.components.container:GetWidgetInfo(boatwidget)

	if self.widgetinfo.widgetbgatlas and self.widgetinfo.widgetbgimage then
		self.bgimage:SetTexture( self.widgetinfo.widgetbgatlas, self.widgetinfo.widgetbgimage )
	end
    
    if self.widgetinfo.widgetanimbank then
		self.bganim:GetAnimState():SetBank(self.widgetinfo.widgetanimbank)
	end
    
    if self.widgetinfo.widgetanimbuild then
		self.bganim:GetAnimState():SetBuild(self.widgetinfo.widgetanimbuild)
    end
    
	self.bganim:SetScale(self.widgetinfo.hscale or 1,1)
    
    if self.widgetinfo.widgetpos then
    	-- print(self.widgetinfo.widgetpos)
		self:SetPosition(self.widgetinfo.widgetpos)
	end
	
	if self.widgetinfo.widgetbuttoninfo and not TheInput:ControllerAttached() then
		self.button = self:AddChild(ImageButton("images/ui.xml", "button_small.tex", "button_small_over.tex", "button_small_disabled.tex"))
	    self.button:SetPosition(self.widgetinfo.widgetbuttoninfo.position)
	    self.button:SetText(self.widgetinfo.widgetbuttoninfo.text)
	    self.button:SetOnClick( function() self.widgetinfo.widgetbuttoninfo.fn(container, doer) end )
	    self.button:SetFont(BUTTONFONT)
	    self.button:SetTextSize(35)
	    self.button.text:SetVAlign(ANCHOR_MIDDLE)
	    self.button.text:SetColour(0,0,0,1)
	    
		if self.widgetinfo.widgetbuttoninfo.validfn then
			if self.widgetinfo.widgetbuttoninfo.validfn(container, doer) then
				self.button:Enable()
			else
				self.button:Disable()
			end
		end
	end
	
	
    self.isopen = true
    self:Show()
    
	if self.bgimage.texture then
		self.bgimage:Show()
	else
		self.bganim:GetAnimState():PlayAnimation("open")
	end
	    
    self.onitemlosefn = function(inst, data) self:OnItemLose(data) end
    self.inst:ListenForEvent("itemlose", self.onitemlosefn, container)

    self.onitemgetfn = function(inst, data) self:OnItemGet(data) end
    self.inst:ListenForEvent("itemget", self.onitemgetfn, container)

   -- self.onitemunequipfn = function(inst, data) self:OnItemUnequip(data) end
    --self.inst:ListenForEvent("itemunequip", self.onitemunequipfn, container)

    --self.onitemequipfn = function(inst, data) self:OnItemEquip(data) end
    --self.inst:ListenForEvent("itemequip", self.onitemgetequipfn, container)


    self.onitemequipfn =  function(inst, data) self:OnItemEquip(data.item, data.eslot) end
    self.inst:ListenForEvent("equip", self.onitemequipfn, container)
  
  	self.onitemunequipfn =  function(inst, data) self:OnItemUnequip(data.item, data.eslot) end
    self.inst:ListenForEvent("unequip", self.onitemunequipfn, container)

	
	local num_slots = math.min( container.components.container:GetNumSlots(), #self.widgetinfo.widgetslotpos)
	
	local lastX = nil
	local lastY = 0

	local n = 1
	for k,v in ipairs(self.widgetinfo.widgetslotpos) do
	
		local slot = InvSlot(n,"images/hud.xml", "inv_slot.tex", self.owner, container.components.container)
		self.inv[n] = self:AddChild(slot)

		slot:SetPosition(v)
		if lastX == nil or v.x > lastX then 
			lastX = v.x
		end 
		lastY = v.y

		if not container.components.container.side_widget then
			slot.side_align_tip = container.components.container.side_align_tip - v.x
		end
		
		local obj = container.components.container:GetItemInSlot(n)
		if obj then
			local tile = ItemTile(obj)
			slot:SetTile(tile)
		end
		
		n = n + 1
	end
	
	if container.components.container.type == "boat" then

		self.boatbadge:SetPosition(self.widgetinfo.widgetboatbadgepos.x, self.widgetinfo.widgetboatbadgepos.y)
		self.boatbadge:Show()
		if container and container.components.boathealth then
			self.inst:ListenForEvent("boathealthchange", function(boat, data) self:BoatDelta(boat, data) end, container)
			self.boatbadge:SetPercent(container.components.boathealth:GetPercent(), container.components.boathealth.maxhealth)
		end

		if container.components.container.hasboatequipslots then 
			self:AddEquipSlot(BOATEQUIPSLOTS.BOAT_SAIL, HUD_ATLAS, "equip_slot_boat_utility.tex")
			self:AddEquipSlot(BOATEQUIPSLOTS.BOAT_LAMP, HUD_ATLAS, "equip_slot_boat_light.tex")
			lastX = self.widgetinfo.widgetequipslotroot.x
			lastY = self.widgetinfo.widgetequipslotroot.y
			local spacing = 80
			local eslot_order = {}
		 	for k, v in ipairs(self.boatEquipInfo) do
		        local slot = BoatEquipSlot(v.slot, v.atlas, v.image, self.owner)
		        self.boatEquip[v.slot] = self:AddChild(slot)
		        slot:SetPosition(lastX, lastY, 0)
		       	lastX = lastX - spacing
		        local obj = container.components.container:GetItemInBoatSlot(v.slot)
		        if obj then
					local tile = ItemTile(obj)
					slot:SetTile(tile)
				end
				if not container.components.container.enableboatequipslots then
					slot:Hide()
				end
		    end    
		end
		self.boatbadge:MoveToFront()
	end 

    self.container = container
    
end    

function ContainerWidget:BoatDelta(boat, data)
	if data.damage then
		self:Shake(0.25, 0.05, 5)
	end
	self.boatbadge:SetPercent(data.percent, data.maxhealth)

	if data.percent <= .25 then
		self.boatbadge:StartWarning()
	else
		self.boatbadge:StopWarning()
	end

	if self.prev_boat_pct and data.percent > self.prev_boat_pct then
		self.boatbadge:PulseGreen()
	--	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/health_up")
	elseif self.prev_boat_pct and data.damage and data.percent < self.prev_boat_pct then
	--	TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/health_down")
		self.boatbadge:PulseRed()
	end
	self.prev_boat_pct = data.percent
end

function ContainerWidget:AddEquipSlot(slot, atlas, image, sortkey)
	sortkey = sortkey or #self.boatEquipInfo
	table.insert(self.boatEquipInfo, {slot = slot, atlas = atlas, image = image, sortkey = sortkey})
	table.sort(self.boatEquipInfo, function(a,b) return a.sortkey < b.sortkey end)
end


function ContainerWidget:OnItemEquip(item, slot)
 	self.boatEquip[slot]:SetTile(ItemTile(item))
end 


function ContainerWidget:OnItemUnequip(item, slot)
	 if slot and self.boatEquip[slot] then
		self.boatEquip[slot]:SetTile(nil)
	end
end 

function ContainerWidget:OnItemGet(data)
    if data.slot and self.inv[data.slot] then
		local tile = ItemTile(data.item)
        self.inv[data.slot]:SetTile(tile)
        tile:Hide()

        if data.src_pos then
			local dest_pos = self.inv[data.slot]:GetWorldPosition()
			local inventoryitem = data.item.components.inventoryitem
			local im = Image(inventoryitem:GetAtlas(), inventoryitem:GetImage())
			im:MoveTo(data.src_pos, dest_pos, .3, function() tile:Show() im:Kill() end)
        else
			tile:Show() 
			--tile:ScaleTo(2, 1, .25)
        end
	end
	
	if self.button and self.container and self.widgetinfo.widgetbuttoninfo and self.widgetinfo.widgetbuttoninfo.validfn then
		if self.widgetinfo.widgetbuttoninfo.validfn(self.container) then
			self.button:Enable()
		else
			self.button:Disable()
		end
	end
end

function ContainerWidget:OnUpdate(dt)
	if self.isopen and self.owner and self.container then
		
		if not (self.container.components.inventoryitem and self.container.components.inventoryitem:IsHeldBy(self.owner)) then
			if self.container ~= GetPlayer().components.driver.vehicle then --if you're not driving...
				local distsq = self.owner:GetDistanceSqToInst(self.container)
				if distsq > 3*3 then
					self:Close()
				end
			end 
		end
	end
	
	--return self.should_close_widget ~= true
end

function ContainerWidget:OnItemLose(data)
	if data.slot then 
		local tileslot = self.inv[data.slot]
		if tileslot then
			tileslot:SetTile(nil)
		end
	elseif data.boatequipslot then 
		local tileslot = self.boatEquip[data.boatequipslot]
		if tileslot then
			tileslot:SetTile(nil)
		end
	end 
	
	if self.container and self.button and self.widgetinfo.widgetbuttoninfo and self.widgetinfo.widgetbuttoninfo.validfn then
		if self.widgetinfo.widgetbuttoninfo.validfn(self.container) then
			self.button:Enable()
		else
			self.button:Disable()
		end
	end
	
end


function ContainerWidget:Close()
    if self.isopen then
		self.isopen = false

		self:StopUpdating()

		if self.button then
			self.button:Kill()
			self.button = nil
		end
		
		if self.container then
			
			if self.container.components.container:IsOpen() then
				self.container.components.container:Close()
			end
			--self.inst:RemoveAllEventCallbacks()
			if self.onitemlosefn then
				self.inst:RemoveEventCallback("itemlose", self.onitemlosefn, self.container)
				self.onitemlosefn = nil
			end
			if self.onitemgetfn then
				self.inst:RemoveEventCallback("itemget", self.onitemgetfn, self.container)
				self.onitemgetfn = nil
			end
			if self.onitemequipfn then 
				self.inst:RemoveEventCallback("equip", self.onitemequipfn, self.container)
				self.onitemequipfn = nil 
			end 
			if self.onitemunequipfn then 
				self.inst:RemoveEventCallback("unequip", self.onitemunequipfn, self.container)
				self.onitemunequipfn = nil 
			end 
		end
		
	    
		for k,v in pairs(self.inv) do
--			self:RemoveChild(v)
			v:Kill()
		end
	    
		self.container = nil
		self.inv = {}
		if self.bgimage.texture then
			self.bgimage:Hide()
		else
			self.bganim:GetAnimState():PlayAnimation("close")
		end

		self.boatbadge:Hide()
		for i,v in pairs(self.boatEquip) do
			v:Kill()
		end
		
	    self.inst:DoTaskInTime(.3, function()self.should_close_widget = true  end)
		
	end
    --self:Hide()

end

return ContainerWidget
