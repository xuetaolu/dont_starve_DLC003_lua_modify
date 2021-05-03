local DoydoySpawner = Class(function(self, inst)
	self.inst = inst
	self.inst:StartUpdatingComponent(self)
	self.doydoys = {}
	self.timetospawn = 1
	self.doydoycap = TUNING.DOYDOY_MAX_POPULATION
	self.numdoydoys = 0
	self.mommy = nil
	self.daddy = nil
end)



local function IsNestEmpty(nest)
	-- print("doydoybrain IsNestEmpty")
	
	return nest.canspawndoydoy and (not nest.components.pickable or not nest.components.pickable:CanBePicked())
end

local function AddMember(inst, member)
	-- print("doydoy herd AddMember", inst, member)
	
end

local nomatingtags = {
	"baby", "teen", "mating", "doydoynest", "insprungtrap",
}

local function CanMate(doy)

	if not GetClock():IsDay() then
		return false
	end

	if doy:IsAsleep() then
		return false
	end

	for _, tag in pairs(nomatingtags) do
		if doy:HasTag(tag) then
			return false
		end
	end

	if doy.components.inventoryitem:IsHeld() then
		return false
	end

	if doy.components.sleeper:IsAsleep() then
		return false
	end

	return true
end

function DoydoySpawner:TryToSpawn()
	-- print("DoydoySpawner:TryToSpawn", self.numdoydoys, "/", self.doydoycap)

	if self.numdoydoys < 2 or self.numdoydoys >= self.doydoycap then
		return false
	end

	local mommy
	local daddy

	-- find a new mother
	for k, _ in pairs(self.doydoys) do
		if CanMate(k) then
			local pt = k:GetPosition()
			local daddys = TheSim:FindEntities(pt.x, pt.y, pt.z, TUNING.DOYDOY_MATING_RANGE, {"doydoy"}, nomatingtags) 
			if #daddys > 1 then

				for _, d in pairs(daddys) do
					if d ~= k and not d.components.inventoryitem:IsHeld() then
						daddy = d
						break
					end
				end

				if daddy then
					mommy = k
					
					daddy.components.mateable:SetPartner(mommy, true)
					mommy.components.mateable:SetPartner(daddy, false)
				end

				break
			end
		end
	end

	if not mommy then
		-- print("DoydoySpawner:TryToSpawn no mommy found")
		return
	end

	if not mommy.sg then
		-- print("DoydoySpawner:TryToSpawn no mommy.sg")
		return
	end

	-- print("DoydoySpawner:TryToSpawn parents found!")
	self.timetospawn = TUNING.DOYDOY_SPAWN_TIMER + (math.random()*TUNING.DOYDOY_SPAWN_VARIANCE)
end

function DoydoySpawner:RequestMate(doy)
	if not self.mommy then
		self.mommy = doy
		return
	end

	if not self.daddy then
		self.daddy = doy

		-- ready to mate these 2?
		self.daddy.components.mateable:SetPartner(self.mommy, true)
		self.mommy.components.mateable:SetPartner(self.daddy, false)

		self.daddy = nil
		self.mommy = nil
	end
end

function DoydoySpawner:OnSave()
	return 
	{
		timetospawn = self.timetospawn,
		doydoycap = self.doydoycap,
	}
end

function DoydoySpawner:OnLoad(data)
	self.timetospawn = data.timetospawn or 10
	self.doydoycap = data.doydoycap or 4
	if self.doydoycap <= 0 then
		self.inst:StopUpdatingComponent(self)
	end
end

function DoydoySpawner:LongUpdate(dt)
	if self.timetospawn > 0 then
		self.timetospawn = self.timetospawn - dt
	end
end

function DoydoySpawner:StartTracking(inst)
	-- assert(self.doydoys[inst] == nil)

	self.doydoys[inst] = function()
		if self.doydoys[inst] then
			inst:Remove()
		end
	end

	self.numdoydoys = self.numdoydoys + 1
end

function DoydoySpawner:StopTracking(inst)
	-- assert(inst.prefab == "doydoy" or inst.prefab == "doydoybaby" or inst.prefab == "doydoynest")
	-- assert(type(self.doydoys[inst]) == "function")

	self.doydoys[inst] = nil
	self.numdoydoys = self.numdoydoys - 1
end

function DoydoySpawner:IsTracking(inst)
	return type(self.doydoys[inst]) == "function"
end

function DoydoySpawner:OnUpdate( dt )
	if self.timetospawn > 0 then
		self.timetospawn = self.timetospawn - dt
	end
	
	if GetClock():IsDay() then
		if self.timetospawn <= 0 then
			self:TryToSpawn()
		end
	end
end

function DoydoySpawner:GetInnocenceValue()
	if self.numdoydoys <= 2 then
		return TUNING.DOYDOY_INNOCENCE_REALLY_BAD
	elseif self.numdoydoys <= 4 then
		return TUNING.DOYDOY_INNOCENCE_BAD
	elseif self.numdoydoys <= 10 then
		return TUNING.DOYDOY_INNOCENCE_LITTLE_BAD
	else
		return TUNING.DOYDOY_INNOCENCE_OK
	end
end

function DoydoySpawner:GetDebugString()
	return "Next spawn: "..tostring(self.timetospawn)
end

function DoydoySpawner:SpawnModeNever()
	self.timetospawn = -1
	self.doydoycap = 0
	self.inst:StopUpdatingComponent(self)
end

function DoydoySpawner:SpawnModeHeavy()
	self.timetospawn = TUNING.DOYDOY_SPAWN_TIMER / 2
	self.doydoycap = TUNING.DOYDOY_MAX_POPULATION * 2
end

function DoydoySpawner:SpawnModeMed()
	self.timetospawn = TUNING.DOYDOY_SPAWN_TIMER
	self.doydoycap = TUNING.DOYDOY_MAX_POPULATION
end

function DoydoySpawner:SpawnModeLight()
	self.timetospawn = TUNING.DOYDOY_SPAWN_TIMER * 2
	self.doydoycap = TUNING.DOYDOY_MAX_POPULATION / 2
end

return DoydoySpawner
