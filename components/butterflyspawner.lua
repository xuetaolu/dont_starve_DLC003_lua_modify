local ButterflySpawner = Class(function(self, inst)
    self.inst = inst
    self.inst:StartUpdatingComponent(self)
    self.butterflys = {}
    self.timetospawn = 10
    self.nexttimetospawn = 10
    self.butterflycap = 4
    self.numbutterflys = 0
    self.followplayer = true
    self.prefab = "butterfly"
end)

function ButterflySpawner:SetButterfly(butterfly)
    self.prefab = butterfly
end

function ButterflySpawner:GetSpawnPoint(spawnerinst)
	local rad = 25
	local x,y,z = spawnerinst.Transform:GetWorldPosition()
	local nearby_ents = TheSim:FindEntities(x,y,z, rad, {'flower'})
	local mindistance = 36
	local validflowers = {}
	for k,flower in ipairs(nearby_ents) do
		if flower and
		spawnerinst:GetDistanceSqToInst(flower) > mindistance then
			table.insert(validflowers, flower)			
		end
	end

	if #validflowers > 0 then
		local f = validflowers[math.random(1, #validflowers)]
		return f
	else
		return nil
	end
end

function ButterflySpawner:StartTracking(inst)
    inst.persists = false
    if not inst.components.homeseeker then
	    inst:AddComponent("homeseeker")
	end

	self.butterflys[inst] = function()
	    if self.butterflys[inst] then
	        inst:Remove()
	    end
	end

	self.inst:ListenForEvent("entitysleep", self.butterflys[inst], inst)
	
	self.numbutterflys = self.numbutterflys + 1
end

function ButterflySpawner:StopTracking(inst)
    inst.persists = true
	inst:RemoveComponent("homeseeker")
	if self.butterflys[inst] then
		self.inst:RemoveEventCallback("entitysleep", self.butterflys[inst], inst)
		self.butterflys[inst] = nil
		self.numbutterflys = self.numbutterflys - 1
	end
end

function ButterflySpawner:OnUpdate( dt )
	local spawnerinst
    local day = GetClock():IsDay()

    if self.followplayer then
    	spawnerinst = GetPlayer()
    else
    	spawnerinst = self.inst
    end

    if spawnerinst then
	    
		if self.timetospawn > 0 then
			self.timetospawn = self.timetospawn - dt
		end
	    
	    local sm = GetSeasonManager()
		if spawnerinst and day and not (sm:IsWetSeason() or sm:IsWinter()) and self.prefab then
			if self.timetospawn <= 0 then
				local spawnFlower = self:GetSpawnPoint(spawnerinst)
				if spawnFlower and self.numbutterflys < self.butterflycap then
					local butterfly = SpawnPrefab(self.prefab)
					local spawn_point = Vector3(spawnFlower.Transform:GetWorldPosition() )
					butterfly.Physics:Teleport(spawn_point.x,spawn_point.y,spawn_point.z)
					butterfly.components.pollinator:Pollinate(spawnFlower)
					self:StartTracking(butterfly)
					butterfly.components.homeseeker:SetHome(spawnFlower)
				end
				if self.followplayer then

					self.timetospawn = self.nexttimetospawn + math.random()*self.nexttimetospawn
				else
					self.timetospawn = math.random()
				end
			end
		end
	end
    
end

function ButterflySpawner:GetDebugString()
	return "Next spawn: "..tostring(self.timetospawn)
end

function ButterflySpawner:OnSave()
	return 
	{
		timetospawn = self.timetospawn,
		nexttimetospawn = self.nexttimetospawn,
    	butterflycap = self.butterflycap,
	}
end

function ButterflySpawner:OnLoad(data)
	self.timetospawn = data.timetospawn or 10
	self.nexttimetospawn = data.nexttimetospawn or 10
	self.butterflycap = data.butterflycap or 4
	if self.butterflycap <= 0 then
		self.inst:StopUpdatingComponent(self)
	end
end

function ButterflySpawner:SpawnModeNever()
	self.timetospawn = -1
	self.nexttimetospawn = 10
    self.butterflycap = 0
    self.inst:StopUpdatingComponent(self)
end

function ButterflySpawner:SpawnModeVeryHeavy()
	self.timetospawn = 0.15
	self.nexttimetospawn = 0.15
    self.butterflycap = 20
end

function ButterflySpawner:SpawnModeHeavy()
	self.timetospawn = 10
	self.nexttimetospawn = 3
    self.butterflycap = 10
end

function ButterflySpawner:SpawnModeMed()
	self.timetospawn = 10
	self.nexttimetospawn = 6
    self.butterflycap = 7
end

function ButterflySpawner:SpawnModeLight()
	self.timetospawn = 10
	self.nexttimetospawn = 20
    self.butterflycap = 2
end

return ButterflySpawner
