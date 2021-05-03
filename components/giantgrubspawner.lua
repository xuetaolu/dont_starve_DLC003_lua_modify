local GIANT_GRUB_NAME = "giantgrub"
local MAX_GIANT_GRUB_NUM = 12
local ANTHILL_DUNGEON_NAME = "ANTHILL1"

local GiantGrubSpawner = Class(function(self, inst)
    self.inst = inst
    self.diffmod = 1
    self.inst:StartUpdatingComponent(self)
    self.timeToSpawn = self:GetSpawnTime()
    self.disabled = false
end)


function GiantGrubSpawner:OnSave()	
	local refs = {}
	local data = {}

	data.timeToSpawn = self.timeToSpawn
	data.disabled = self.disabled
	return data, refs
end 

function GiantGrubSpawner:OnLoad(data)
	if data.timeToSpawn then 
		self.timeToSpawn = data.timeToSpawn
	end
	if data.disabled then
		self.disabled = data.disabled
	end
end

function GiantGrubSpawner:LoadPostPass(ents, data)
end

function GiantGrubSpawner:SetDiffMod(diff)
	self.diffmod = diff
end

function GiantGrubSpawner:GetSpawnTime()	
	local time = TUNING.TOTAL_DAY_TIME * math.random()
	if self.diffmod then
		time = time/  self.diffmod
	end
	return time
end

function GiantGrubSpawner:LongUpdate(dt)
end

function GiantGrubSpawner:GetSpawnOffsetX()
    return (math.random() * 7) - (7 / 2)
end

function GiantGrubSpawner:GetSpawnOffsetZ()
    return (math.random() * 13) - (13 / 2)
end

function GiantGrubSpawner:OnUpdate(dt)
	if self.disabled then
		self.inst:StopUpdatingComponent(self)
	else
		self.timeToSpawn = self.timeToSpawn - dt

		if self.timeToSpawn <= 0 then
			local interiorSpawner = GetWorld().components.interiorspawner
			local currentInterior = interiorSpawner.current_interior
			local maxGrubsNotYetReached = interiorSpawner:CountPrefabs(GIANT_GRUB_NAME) < MAX_GIANT_GRUB_NUM

			if currentInterior and (currentInterior.dungeon_name == ANTHILL_DUNGEON_NAME) and maxGrubsNotYetReached then
				local giantGrub = SpawnPrefab(GIANT_GRUB_NAME)
				local spawnPosition = interiorSpawner:getSpawnOrigin()

				spawnPosition.x = spawnPosition.x + self:GetSpawnOffsetX()
				spawnPosition.z = spawnPosition.z + self:GetSpawnOffsetZ()

				giantGrub.Transform:SetPosition(spawnPosition.x, spawnPosition.y, spawnPosition.z)
				giantGrub.sg:GoToState("walk")
				self.timeToSpawn = self:GetSpawnTime()
			end
		end
	end
end

return GiantGrubSpawner
