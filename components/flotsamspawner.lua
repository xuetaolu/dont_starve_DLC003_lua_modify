--Spawns flotsam periodically based on the health of the boat.
--Requires entity to have "boat health" component to work!

local function onhealthchange(inst, data)
	local spawner = inst.components.flotsamspawner

	if data.oldpercent > spawner.start_threshold and
	data.percent <= spawner.start_threshold then
		spawner:StartUpdating()
	elseif data.oldpercent <= spawner.start_threshold and
	data.percent > spawner.start_threshold then
		spawner:StopUpdating()
	end
end

local function mounted(inst, data)
	local percent = inst.components.boathealth:GetPercent()

	if percent <= inst.components.flotsamspawner.start_threshold then
		inst.components.flotsamspawner:StartUpdating()
	end
end

local function dismounted(inst, data)
	inst.components.flotsamspawner:StopUpdating()	
end

local FlotsamSpawner = Class(function(self, inst)
	self.inst = inst

	self.updateperiod = 1
	self.start_threshold = 0.5

	--As health goes from start_threshold -> 0 the values used lerp from max -> min
	self.max_spawndist = 150
	self.min_spawndist = 20

	self.last_pos = nil
	self.distance_traveled = 0

	self.flotsamprefab = "flotsam"

	self.inst:ListenForEvent("mounted", mounted)
	self.inst:ListenForEvent("dismounted", dismounted)
	self.inst:ListenForEvent("boathealthchange", onhealthchange)
end)

function FlotsamSpawner:StartUpdating()

	if self.updatetask then
		print("Tried to start update task in FlotsamSpawner when it already has one!")
		return
	end

	self:Spawn()

	self.updatetask = self.inst:DoPeriodicTask(self.updateperiod, function() self:OnUpdate() end)

end

function FlotsamSpawner:StopUpdating()
	if not self.updatetask then return end

	self.updatetask:Cancel()
	self.updatetask = nil
end

function FlotsamSpawner:CanSpawnFlotsam()	

 	if not self.inst:GetIsOnWater() then
 		return false 
 	end
 	if self.inpocket then
 		return false
 	end
	return true
end

function FlotsamSpawner:Spawn()
	self.distance_traveled = 0

	if not self:CanSpawnFlotsam() then return end

	local debris = SpawnPrefab(self.flotsamprefab)
	debris.Transform:SetPosition(self.inst:GetPosition():Get())
	local angle = math.random(-180, 180)*DEGREES
    local sp = math.random()*4+2
    debris.Physics:SetVel(sp*math.cos(angle), 0, sp*math.sin(angle))
end

function FlotsamSpawner:OnUpdate()
		local new_pos = self.inst:GetPosition()

		local distance_delta = new_pos:Dist(self.last_pos or self.inst:GetPosition())

		self.distance_traveled = self.distance_traveled + distance_delta
		self.last_pos = new_pos

		local percent = self.inst.components.boathealth:GetPercent()
		percent = math.clamp(percent, 0, self.start_threshold)

		local t = percent/self.start_threshold

		local distThresh = Lerp(self.min_spawndist, self.max_spawndist, t)

		if self.distance_traveled >= distThresh then
			self:Spawn()
		end
end

function FlotsamSpawner:OnSave()
	local data = {}
	if self.inpocket then
		data.inpocket = true
	end
	return data
end

function FlotsamSpawner:OnLoad(data)
	if data then
		if data.inpocket == true then
			self.inpocket = true
		end
	end
end


return FlotsamSpawner
