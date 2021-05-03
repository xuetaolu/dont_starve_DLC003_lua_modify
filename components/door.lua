	-- Transition Execution
local TheLastActiveDoor = nil
local current_inst = nil -- The Door Executing The Transition
local current_doer = nil -- The Player That Initiated The Transition

local function PlayTransition(inst, doer)
	local interior_spawner = GetWorld().components.interiorspawner
	interior_spawner:PlayTransition(doer, inst)
end

----------------------------
-- Door Component Definition
local Door = Class(function(self, inst)
    self.inst = inst
	self.playTransition = PlayTransition
	self.destination = {target_x = 0, target_y = 0, target_z = 0, target_offset_x = 0, target_offset_y = 0, target_offset_z = 0}
	self.getverb = function() return STRINGS.ACTIONS.JUMPIN.ENTER end
end)

function Door:SetUnloadTransition()
	self.executePreviousRoomUnload = true
end

function Door:UpdateTargetOffset()
	local door_inst = GetWorld().components.interiorspawner:GetDoorInst(self.target_door_id)
	if door_inst then
		local x_offset = 0
		local z_offset = 0
		
		if door_inst.door_target_offset_x ~= nil then
			x_offset = door_inst.door_target_offset_x
		end
		if door_inst.door_target_offset_z ~= nil then
			z_offset = door_inst.door_target_offset_z
		end

		self:SetTargetOffset(x_offset, 0, z_offset)
	end
end

function Door:SetTargetOffset(x, y, z)
	local dest = self.destination
	dest.target_offset_x = x
	dest.target_offset_y = y
	dest.target_offset_z = z
end

function Door:SetTargetExterior(x, y, z)
	local dest = self.destination
	dest.target_x = x
	dest.target_y = y
	dest.target_z = z
	dest.interior = false
end

function Door:SetTargetInterior(x, y, z)
	local dest = self.destination
	dest.target_x = x
	dest.target_y = y
	dest.target_z = z
	dest.interior = true
end

function Door:CollectSceneActions(doer, actions)
	if not self.inst:HasTag("predoor") and not self.hidden then
		table.insert(actions, ACTIONS.USEDOOR)
	end
end

function Door:Activate(doer)
	if self.playTransition then
		self.inst:PushEvent("usedoor",{doer=doer})
		--[[
		if self.sound then
			self.inst.SoundEmitter:PlaySound(self.sound)
		end
		]]
		self.playTransition(self.inst, doer)
	else
		print("!!ERROR: Door without transition is not implemented")
	end
end

function Door:checkDisableDoor(setting, cause)
--	print("SETTING DOOR BLOCKAGE", setting, cause)
	if not self.disabledcauses then
		self.disabledcauses = {}
	end

	if cause then
		self.disabledcauses[cause] = setting
	end
	
	self.disabled = false

	for reason,setting in pairs(self.disabledcauses) do
		if setting then
			self.disabled = true
		end
	end
end

function Door:updateDoorVis()
	if not self.inst:IsInLimbo() then
		if self.hidden then
			self.inst:Hide()
			if self.inst.shadow then
				self.inst.shadow:Hide()
			end
		else
			self.inst:Show()
			if self.inst.shadow then
				self.inst.shadow:Show()
			end
		end
	end
end

function Door:sethidden(hidden)
	self.hidden = hidden
end


function Door:OnSave()

	local data = {}
	data.door_id = self.door_id
	data.target_door_id = self.target_door_id
	data.target_interior = self.target_interior
	data.interior_name =  self.interior_name

	if self.inst:HasTag("door_north") then
		data.door_north = true
	end
	if self.inst:HasTag("door_east") then
		data.door_east = true
	end
	if self.inst:HasTag("door_west") then
		data.door_west = true
	end
	if self.inst:HasTag("door_south") then
		data.door_south = true
	end	
	if self.getverb then
		data.getverb = true
	end
	if self.disabled then
		data.disabled = self.disabled
	end
	if self.hidden then
		data.hidden = self.hidden
	end
	if self.angle then
		data.angle = self.angle
	end	
	if self.disabledcauses then
		data.disabledcauses = self.disabledcauses
	end

	return data
end

function Door:OnLoad(data)

	if data.door_id then
		self.door_id = data.door_id
	end
	if data.target_door_id then
		self.target_door_id = data.target_door_id
	end
	if data.target_interior then
		self.target_interior = data.target_interior
	end
	if data.interior_name then
		self.interior_name = data.interior_name
	end	
	if data.getverb then
		local interior_spawner = GetWorld().components.interiorspawner
		self.getverb = interior_spawner.getverb
	end

	if data.disabled then
		self.disabled = data.disabled
	end
	if data.hidden then
		self.hidden = data.hidden
		self:updateDoorVis()
	end	
	if data.angle then
		self.angle = data.angle
	end	

	if data.door_north then
		self.inst:AddTag("door_north")
	end
	if data.door_east then
		self.inst:AddTag("door_east")
	end
	if data.door_west then
		self.inst:AddTag("door_west")
	end
	if data.door_south then
		self.inst:AddTag("door_south")
	end	
	if data.disabledcauses then
		self.disabledcauses = data.disabledcauses
	end
	self:checkDisableDoor()
end

function Door:LoadPostPass(newents, savedata)
	--TODO: Locate Position/Data Of Target Static Room
end

return Door

