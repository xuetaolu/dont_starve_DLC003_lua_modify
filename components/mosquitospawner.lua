local MosquitoSpawner = Class(function(self, inst)
    self.inst = inst
    self.inst:StartUpdatingComponent(self)
    self.mosquitos = {}
    self.timetospawn = 60
    self.nexttimetospawn = 60
    self.mosquitocap = 3
    self.nummosquitos = 0
    self.followplayer = true
    self.prefab = "mosquito_poison"
end)



function MosquitoSpawner:GetSpawnPoint(spawnerinst)
	for i = 5, 20, 2 do 
		local rad = i
		local x,y,z = spawnerinst.Transform:GetWorldPosition()
		local mindistance = 10
		local pt = Vector3(x,y,z)

		local theta = 360 * math.random()
		local result_offset = FindValidPositionByFan(theta, rad, 10, function(offset)
			local ground = GetWorld()
	        local spawn_point = pt + offset
	      	if offset:Length() < mindistance then 
	      		return false 
	      	end 

		  	if not self.inst:IsPosSurroundedByLand(spawn_point.x, spawn_point.y, spawn_point.z, 3) then 
		  		return false
		  	end 
	      	
	      	if GetWorld().Flooding and GetWorld().Flooding:OnFlood(spawn_point.x, spawn_point.y, spawn_point.z) then
	      		return true 
	      	end 


			return false
		
	    end)
		if result_offset then 
			return pt + result_offset
		end 	
	end 
end

function MosquitoSpawner:StartTracking(inst)
    inst.persists = false
    --if not inst.components.homeseeker then
	 --   inst:AddComponent("homeseeker")
	--end

	self.mosquitos[inst] = function()
	    if self.mosquitos[inst] then
	        inst:Remove()
	    end
	end


	self.inst:ListenForEvent("entitysleep", self.mosquitos[inst], inst)
	self.nummosquitos = self.nummosquitos + 1

end

function MosquitoSpawner:StopTracking(inst)
    inst.persists = true
	inst:RemoveComponent("homeseeker")
	if self.mosquitos[inst] then
		self.inst:RemoveEventCallback("entitysleep", self.mosquitos[inst], inst)
		self.mosquitos[inst] = nil
		inst.tracker = nil 
		self.nummosquitos = self.nummosquitos - 1
	end
end

function MosquitoSpawner:OnUpdate( dt )
	local spawnerinst

    if self.followplayer then
    	spawnerinst = GetPlayer()
    else
    	spawnerinst = self.inst
    end

    local sm = GetSeasonManager()
    local perc = sm:GetPercentSeason() 
    local ismosquitoseason =  sm:IsGreenSeason() and perc > 0.5 
    
    if spawnerinst and ismosquitoseason then
		if self.timetospawn > 0 then
			self.timetospawn = self.timetospawn - dt
		end
	    
		if spawnerinst  and self.prefab then
			if self.timetospawn <= 0 then
				local spawn_point = self:GetSpawnPoint(spawnerinst)
				if spawn_point and self.nummosquitos < self.mosquitocap then
					local mosquito = SpawnPrefab(self.prefab)
					mosquito.Physics:Teleport(spawn_point.x,spawn_point.y,spawn_point.z)
					self:StartTracking(mosquito)
					--butterfly.components.homeseeker:SetHome(spawnFlower)
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

function MosquitoSpawner:GetDebugString()
	return "Next spawn: "..tostring(self.timetospawn)
end

function MosquitoSpawner:OnSave()
	return 
	{
		timetospawn = self.timetospawn,
		nexttimetospawn = self.nexttimetospawn,
    	mosquitocap = self.mosquitocap,
	}
end

function MosquitoSpawner:OnLoad(data)
	self.timetospawn = data.timetospawn or 10
	self.nexttimetospawn = data.nexttimetospawn or 10
	self.mosquitocap = data.mosquitocap or 4
	if self.mosquitocap <= 0 then
		self.inst:StopUpdatingComponent(self)
	end
end

function MosquitoSpawner:SpawnModeNever()
    self.nexttimetospawn = -1
    self.timetospawn = -1
    self.mosquitocap = 0
    self.inst:StopUpdatingComponent(self)
end

function MosquitoSpawner:SpawnModeHeavy()
    self.nexttimetospawn = 10
    self.timetospawn = 20
    self.mosquitocap = 6
end

function MosquitoSpawner:SpawnModeMed()
    self.nexttimetospawn = 30
    self.timetospawn = 30
    self.mosquitocap = 4
end

function MosquitoSpawner:SpawnModeLight()
    self.nexttimetospawn = 30
    self.timetospawn = 90
    self.mosquitocap = 2
end

return MosquitoSpawner
