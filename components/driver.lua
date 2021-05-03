local Driver = Class(function(self, inst)
    self.inst = inst
    self.driving = false
    self.lastvehicle = nil
    self.cachedrunspeed = nil
    self.mountdata = nil
    self.combined = false 
    self.durabilitymultiplier = 1
    self.cachedRadius = nil
    self.warningthresholds = 
    {
    	{percent = 0.5, string = "ANNOUNCE_BOAT_DAMAGED"},
    	{percent = 0.3, string = "ANNOUNCE_BOAT_SINKING"},
    	{percent = 0.1, string = "ANNOUNCE_BOAT_SINKING_IMMINENT"},
	}
end)

-- Only used to take care of some merging things 
-- if the character was on a boat when the merge happens
function Driver:OnSave()
	local data = {}
	local refs = {}

	data.driving = self.driving 

	if self.vehicle then 
		table.insert(refs, self.vehicle.GUID)
		data.vehicle = self.vehicle.GUID
		data.vehicle_prefab = self.vehicle.prefab
	end
    if self.lastvehicle then
		table.insert(refs, self.lastvehicle.GUID)
		data.lastvehicle = self.lastvehicle.GUID
		data.lastvehicle_prefab = self.lastvehicle.prefab
    end
	return data, refs
end   

function Driver:LoadPostPass(ents, data)
	if data.lastvehicle and ents[data.lastvehicle] then
		self.lastvehicle = ents[data.lastvehicle].entity
	end
end

function Driver:OnLoad(data)
	
end  

  
 function Driver:OnUpdate(dt) --Set my entity's position and rotation to be the same as the drivable entity's 
    
	 -- debug print added by gjans 2016-09-20
	 -- most likely the vehicle is being Remove'd from some other place and
	 -- OnDismount is not being called
	if self.vehicle ~= nil and not self.vehicle:IsValid() then
		print("!!!! ACK! We have an invalid vehicle!")
		return
	end

    if self.vehicle ~= nil and self.vehicle:IsValid() then 
    	local myPos = self.inst:GetPosition()
        --local pos = self.vehicle:GetPosition()
		
		local CameraRight = TheCamera:GetRightVec()
        local CameraDown = TheCamera:GetDownVec()
        
        local displacement = CameraRight:Cross(CameraDown) * 0.2

        local pos = myPos - displacement --Move the player slightly closer to the camera so they draw on top of the boat
 	
       	self.vehicle.Transform:SetPosition(pos.x , pos.y, pos.z)

       	if self.vehicle.components.boathealth then 
       		self.vehicle.components.boathealth.depletionmultiplier = 1.0/self.durabilitymultiplier
       	end 
     	if (self.combined == true ) and self.vehicle.components.drivable then 
       		self.vehicle.Transform:SetRotation(self.inst.Transform:GetRotation())
       	end 
    end
end

function Driver:OnDismount(death, pos, boat_to_boat)
	self.driving = false
	self.inst:StopUpdatingComponent(self)
	if(self.mountdata) then 
		local x, y, z = self.inst.Transform:GetWorldPosition()
    	local mount = SpawnSaveRecord(self.mountdata, {})
    	mount.Physics:Teleport(x, y, z)
		if mount.components.drivable then
	    	mount.Transform:SetRotation(self.inst.Transform:GetRotation())
		end
	end 

	if self.vehicle.onboatdelta then
		self.inst:RemoveEventCallback("boathealthchange", self.vehicle.onboatdelta, self.vehicle)
		self.vehicle.onboatdelta = nil
	end

	self:SplitFromVehicle()
	
	if self.vehicle.components.container then 
		self.vehicle.components.container:Close(self.inst)
	end

	if self.inst.components.farseer then
		self.inst.components.farseer:RemoveBonus("boat")
	end

	if self.inst:HasTag("pirate") and self.vehicle.components.drivable then
		self.vehicle.components.drivable.sanitydrain = self.cachedsanitydrain
		self.cachedsanitydrain = nil
	end

	if self.vehicle.components.drivable then 
	    self.inst.AnimState:ClearOverrideBuild(self.vehicle.components.drivable.overridebuild)
	elseif self.vehicle.components.searchable then
		self.inst.AnimState:ClearOverrideBuild(self.vehicle.components.searchable.overridebuild)
	end

    self.inst.components.locomotor.directdrive = false
    self.inst.components.locomotor.hasmomentum = false

    self.inst.components.locomotor:RemoveSpeedModifier_Additive("DRIVER")

 	local position = self.inst:GetPosition()
    MakeCharacterPhysics(self.inst, 75, self.cachedRadius)
    self.inst.Physics:SetActive(true)
    self.inst.Transform:SetPosition(position.x, position.y, position.z) --Calling set active can change the position, make sure we're where we want to me 

    self.cachedrunspeed = nil
    self.inst:SetStateGraph(self.landstategraph)
	self.inst:RemoveTag("aquatic")
	self.inst:PushEvent("dismountboat", {boat = self.vehicle})

	if(self.onStopDriving) then
		self.onStopDriving(self.inst)
	end

	if self.vehicle.components.drivable then
		self.vehicle.components.drivable:OnDismounted(self.inst)
	elseif self.vehicle.components.searchable then
		self.vehicle.components.searchable:OnDismounted(self.inst)
	end

    self.lastvehicle = self.vehicle
	self.vehicle = nil

	if self.inst.components.leader then 
		self.inst.components.leader:HibernateWaterFollowers(true)
		self.inst.components.leader:HibernateLandFollowers(false)
	end 

	if pos then
		self.inst.sg:GoToState("jumpoffboatstart", pos)
	elseif boat_to_boat then
		self.inst.sg:GoToState("jumponboatstart")
	end
end

function Driver:OnMount(vehicle)
	self.driving = true 
	self.vehicle = vehicle

	if self.inst:HasTag("pirate") then
		self.cachedsanitydrain = vehicle.components.drivable.sanitydrain
		vehicle.components.drivable.sanitydrain = 0
	end

	self.inst:StartUpdatingComponent(self)

	self.inst.AnimState:AddOverrideBuild(self.vehicle.components.drivable.overridebuild)
	self.inst.AnimState:OverrideSymbol("flotsam", self.vehicle.components.drivable.flotsambuild, "flotsam")

	self.inst:SetStateGraph(self.boatingstategraph)
	self.inst:AddTag("aquatic")
	self.inst.sg:GoToState("jumpboatland")
	--self.inst:PushEvent("landboat")
	--Snap the player to the vehicle position
	local vehiclePos = vehicle:GetPosition()
	self.inst.Transform:SetPosition(vehiclePos.x , vehiclePos.y, vehiclePos.z)
	
	self.inst.components.locomotor:AddSpeedModifier_Additive("DRIVER", vehicle.components.drivable.runspeed)
	

	self.inst.components.locomotor.hasmomentum = true
	self.inst.components.locomotor.bargle = true --for debugging 

	self.cachedRadius = self.inst.Physics:GetRadius() 

	local position = self.inst:GetPosition()
	MakeCharacterPhysics(self.inst, 75, 1)
	self.inst.Physics:SetActive(true)

	--Listen for boat taking damage, talk if it is!
	vehicle.onboatdelta = function(boat, data)
		if data then
			local old = data.oldpercent
			local new = data.percent
			local message = nil
			for _, threshold in ipairs(self.warningthresholds) do
				if old > threshold.percent and new <= threshold.percent then
					message = threshold.string
				end
			end

			if message then
				self.inst:PushEvent("boat_damaged", {message = message})
			end
		end
	end
	self.inst:ListenForEvent("boathealthchange", vehicle.onboatdelta, vehicle)

	if vehicle.components.boathealth then
		local percent = vehicle.components.boathealth:GetPercent()
		vehicle.onboatdelta(vehicle, {oldpercent = 1, percent = percent})
	end

	if self.inst.components.farseer and vehicle.components.drivable and vehicle.components.drivable.maprevealbonus then
		self.inst.components.farseer:AddBonus("boat", vehicle.components.drivable.maprevealbonus)
	end

	if vehicle.components.container then
		if vehicle.components.container:IsOpen() then
			vehicle.components.container:Close()
		end
		self.inst:DoTaskInTime(0.1, function() vehicle.components.container:Open(self.inst) end) --Not sure why but when loading a game where you're in a boat this doesn't work unless it's delayed
	end 

	if self.inst.components.leader then 
		self.inst.components.leader:HibernateLandFollowers(true)
		self.inst.components.leader:HibernateWaterFollowers(false)
	end 

	self.inst:PushEvent("mountboat", {boat = self.vehicle})
	if(self.onStartDriving) then 
		self.onStartDriving(self.inst)
	end
	self:CombineWithVehicle()
	return true
end


function Driver:OnSearch(vehicle)

	self.driving = true 
	self.vehicle = vehicle

	self.inst:StartUpdatingComponent(self)

    self.inst.AnimState:AddOverrideBuild(self.vehicle.components.searchable.overridebuild)

	self.inst:SetStateGraph(self.boatingstategraph)
	self.inst:AddTag("aquatic")
	self.inst.sg:GoToState("jumpboatland")

	--Snap the player to the vehicle position
	local vehiclePos = vehicle:GetPosition()
	self.inst.Transform:SetPosition(vehiclePos.x , vehiclePos.y, vehiclePos.z)

	self.inst.components.locomotor.hasmomentum = false
	self.inst.components.locomotor.bargle = true --for debugging 

	self.cachedRadius = self.inst.Physics:GetRadius() 

	local position = self.inst:GetPosition()
	MakeCharacterPhysics(self.inst, 75, 1)
	self.inst.Physics:SetActive(true)

	if vehicle.components.container then
		if vehicle.components.container:IsOpen() then
			vehicle.components.container:Close()
		end
		self.inst:DoTaskInTime(0.1, function() vehicle.components.container:Open(self.inst) end) --Not sure why but when loading a game where you're in a boat this doesn't work unless it's delayed
	end 

	if self.inst.components.leader then 
		self.inst.components.leader:HibernateLandFollowers(true)
		self.inst.components.leader:HibernateWaterFollowers(false)
	end 

	self.inst:PushEvent("mountboat", {boat = self.vehicle})
	self:CombineWithSearchable()

	return true
end

function Driver:GetIsDriving()
	return self.vehicle ~= nil
end 

function Driver:GetIsSailing()
	if self.vehicle and self.vehicle.components.drivable then 
		return self.vehicle.components.drivable:GetIsSailEquipped()
	end 
end 

function Driver:CombineWithVehicle()
	self.combined = true 
	self.vehicle:Hide()
end 

function Driver:CombineWithSearchable()
	self.combined = true
	self.inst:Hide()
end

function Driver:SplitFromVehicle()
	self.combined = false 
	self.vehicle:Show()
	self.inst:Show()
end 


return Driver
