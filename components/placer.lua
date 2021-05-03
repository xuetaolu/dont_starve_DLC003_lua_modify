local Placer = Class(function(self, inst)
    self.inst = inst
	self.can_build = false
	self.radius = 1
	self.selected_pos = nil
	self.inst:AddTag("NOCLICK")
	self.linked = {}

	self.onupdatetransform = nil
end)

function Placer:SetBuilder(builder, recipe, invobject)
	self.builder = builder
	self.recipe = recipe
	self.invobject = invobject
	self.inst:StartUpdatingComponent(self)	
end

function Placer:LinkEntity(ent)
    table.insert(self.linked, ent)
end

function Placer:GetDeployAction()
	if self.invobject then
		self.selected_pos = self.inst:GetPosition()
		if self.invobject:HasTag("boat") then
			local action = BufferedAction(self.builder, nil, ACTIONS.LAUNCH, self.invobject, self.selected_pos)
			table.insert(action.onsuccess, function() self.selected_pos = nil end)
			return action
		else
			
			local action = BufferedAction(self.builder, nil, ACTIONS.DEPLOY, self.invobject, self.selected_pos)
			if self.invobject.components.deployable and self.invobject.components.deployable.deploydistance then 
				action.distance = self.invobject.components.deployable.deploydistance
			end 
			table.insert(action.onsuccess, function() self.selected_pos = nil end)
			return action
		end
	end
end

function Placer:getOffset()
	local offset = 1
	if self.recipe then 
		if self.recipe.distance then 
			offset = self.recipe.distance - 1
			offset = math.max(offset, 1)
		end 
	elseif self.invobject then 
		if self.invobject.components.deployable and self.invobject.components.deployable.deploydistance then 
			offset = self.invobject.components.deployable.deploydistance
		end 
	end 	
	return offset
end

local function findFloodGridNum(num)
	-- the flood grid is is the center of a 2x2 tile pattern. So 1,3,5,7..
    if math.mod(num, 2) == 0 then
        num = num +1
    end
    return num
end

function Placer:SetModifyFn(fn)
	self.modifyfn = fn
end

function Placer:OnUpdate(dt)
	if not TheInput:ControllerAttached() then
		local pt = self.selected_pos or Input:GetWorldPosition()
		if self.snap_to_tile and GetWorld().Map then
			pt = Vector3(GetWorld().Map:GetTileCenterPoint(pt:Get()))
		elseif self.snap_to_meters then
			pt = Vector3(math.floor(pt.x)+.5, 0, math.floor(pt.z)+.5)
		elseif self.snap_to_flood then			
			pt.x = findFloodGridNum(math.floor(pt.x))
			pt.z = findFloodGridNum(math.floor(pt.z))	
		end
		self.inst.Transform:SetPosition(pt:Get())	
	else

		local offset = self:getOffset()

		if self.snap_to_tile and GetWorld().Map then
			--Using an offset in this causes a bug in the terraformer functionality while using a controller.
			local pt = Vector3(GetPlayer().entity:LocalToWorldSpace(0, 0, 0))
			pt = Vector3(GetWorld().Map:GetTileCenterPoint(pt:Get()))
			self.inst.Transform:SetPosition(pt:Get())
		elseif self.snap_to_meters then
			local pt = Vector3(GetPlayer().entity:LocalToWorldSpace(offset, 0, 0))
			pt = Vector3(math.floor(pt.x)+.5, 0, math.floor(pt.z)+.5)
			self.inst.Transform:SetPosition(pt:Get())
		elseif self.snap_to_flood then 
			local pt = Vector3(GetPlayer().entity:LocalToWorldSpace(offset, 0, 0))
			pt.x = findFloodGridNum(math.floor(pt.x))	
			pt.z = findFloodGridNum(math.floor(pt.z))
			self.inst.Transform:SetPosition(pt:Get())
		elseif self.onground then
        --V2C: this will keep ground orientation accurate and smooth,
        --     but unfortunately position will be choppy compared to parenting
        	self.inst.Transform:SetPosition(ThePlayer.entity:LocalToWorldSpace(1, 0, 0))
		else
			if self.inst.parent == nil then
				GetPlayer():AddChild(self.inst)
				self.inst.Transform:SetPosition(offset, 0, 0)
			end
		end
	end
	
	if self.fixedcameraoffset then
       	local rot = TheCamera:GetHeading()
        self.inst.Transform:SetRotation(-rot+self.fixedcameraoffset) -- rotate against the camera
        for i, v in ipairs(self.linked) do
            v.Transform:SetRotation(rot)
        end         
    end
	
	self.can_build = true

	if self.placeTestFn then
		local inputPt = Input:GetWorldPosition()

		if TheInput:ControllerAttached() then
			local offset = self:getOffset()
			inputPt =  Vector3(GetPlayer().entity:LocalToWorldSpace(offset, 0, 0))
		end

		local pt = self.selected_pos or inputPt	
	
		self.can_build = self.placeTestFn(self.inst, pt)
		self.targetPos = self.inst:GetPosition()
	end

	if self.testfn and self.can_build then
		self.can_build = self.testfn(Vector3(self.inst.Transform:GetWorldPosition()))	
	end

	local pt = self.selected_pos or Input:GetWorldPosition()
	local ground = GetWorld()
    local tile = GROUND.GRASS
    if ground and ground.Map then
        tile = ground.Map:GetTileAtPoint(pt:Get())
    end

    local onground = not ground.Map:IsWater(tile)

	if (not self.can_build and self.hide_on_invalid) or (self.hide_on_ground and onground) or ( self.invobject and self.invobject.components.deployable.onlydeploybyplantkin and not GetPlayer():HasTag("plantkin") ) then
		self.inst:Hide()
	else
		self.inst:Show()
		local color = self.can_build and Vector3(.25, .75, .25) or Vector3(.75, .25, .25)		
		self.inst.AnimState:SetAddColour(color.x, color.y, color.z, 1)
	end
--[[
    if self.can_build then
        if self.mouse_blocked then
            self.inst:Hide()
            for i, v in ipairs(self.linked) do
                v:Hide()
            end
        else
            self.inst.AnimState:SetAddColour(.25, .75, .25, 1)
            self.inst:Show()
            for i, v in ipairs(self.linked) do
                v.AnimState:SetAddColour(.25, .75, .25, 1)
                v:Show()
            end
        end
    else
        if self.oncannotbuild ~= nil then
            self.oncannotbuild(self.inst, self.mouse_blocked)
            return
        end

        if self.mouse_blocked then
            self.inst:Hide()
            for i, v in ipairs(self.linked) do
                v:Hide()
            end
        else
            self.inst.AnimState:SetAddColour(.75, .25, .25, 1)
            self.inst:Show()
            for i, v in ipairs(self.linked) do
                v.AnimState:SetAddColour(.75, .25, .25, 1)
                v:Show()
            end
        end
    end
    ]]
end

return Placer
