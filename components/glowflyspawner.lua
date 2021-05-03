local GlowflySpawner = Class(function(self, inst)
    self.inst = inst
    self.inst:StartUpdatingComponent(self)
    self.glowflys = {}
    self.timetospawn = 10
    self.nexttimetospawn = 10
    self.nexttimetospawnBase = 10
    self.glowflycap = 4

    self.nexttimetospawn_default = 10
    self.nexttimetospawnBase_default = 10
    self.glowflycap_default = 4

    self.nexttimetospawn_warm = 2
    self.nexttimetospawnBase_warm = 0
    self.glowflycap_warm = 10

    self.nexttimetospawn_cold = 50
    self.nexttimetospawnBase_cold = 50
    self.glowflycap_cold = 0

    self.numglowflys = 0
    self.followplayer = true
    self.prefab = "glowfly"
end)

function GlowflySpawner:Setglowfly(glowfly)
    self.prefab = glowfly
end

function GlowflySpawner:GetSpawnPoint(spawnerinst)
	local rad = 25
	local x,y,z = spawnerinst.Transform:GetWorldPosition()
	local nearby_ents = TheSim:FindEntities(x,y,z, rad, {'flower_rainforest'})
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

function GlowflySpawner:StartTracking(inst)
    inst.persists = false
    if not inst.components.homeseeker then
	    inst:AddComponent("homeseeker")
	end

	self.glowflys[inst] = function()
	    if self.glowflys[inst] then
	        inst:Remove()
	    end
	end

	self.inst:ListenForEvent("entitysleep", self.glowflys[inst], inst)
	
	self.numglowflys = self.numglowflys + 1
end

function GlowflySpawner:StopTracking(inst)
    inst.persists = true
	inst:RemoveComponent("homeseeker")
	if self.glowflys[inst] then
		self.inst:RemoveEventCallback("entitysleep", self.glowflys[inst], inst)
		self.glowflys[inst] = nil
		self.numglowflys = self.numglowflys - 1
	end
end

function GlowflySpawner:setBugCocoonTimer(inst)
	inst.setcocoontask(inst) --cocoon_task = inst:DoTaskInTime(math.random()*3, function() inst.begincocoonstage(inst) end ) --+ (math.random()*TUNING.SEG_TIME*2)
end


function GlowflySpawner:startCocoonTimer()
	print("END GLOWFLY EXPLOSION, START COCOONING")	
	self.nexttimetospawn = self.nexttimetospawn_cold 
	self.nexttimetospawnBase = self.nexttimetospawnBase_cold
	self.glowflycap = self.glowflycap_cold
	self.timetospawn = 0

	for glowfly,i in pairs(self.glowflys) do
		self:setBugCocoonTimer(glowfly)
	end

	GetWorld():PushEvent("spawncocoons")
	-- seed the map with many more cocoons. 

end

function GlowflySpawner:setglowflycocoontask(inst, time)
	inst.glowflycocoontask, inst.glowflycocoontaskinfo = inst:ResumeTask(time, function() self:startCocoonTimer() end)
end

function GlowflySpawner:setglowflyhatchtask(inst, time)
	inst.glowflyhatchtask, inst.glowflyhatchtaskinfo = inst:ResumeTask(time, function() GetWorld():PushEvent("glowflyhatch") end)
end


function GlowflySpawner:OnUpdate( dt )

	local spawnerinst
   -- local day = GetClock():IsDay()

    if self.followplayer then
    	spawnerinst = GetPlayer()
    else
    	spawnerinst = self.inst
    end

	local season_percent = GetWorld().components.seasonmanager:GetPercentSeason()

    if spawnerinst then
	--    print("GLOWFLY TIME",self.timetospawn, self.numglowflys,self.glowflycap)
		if self.timetospawn > 0 then
			self.timetospawn = self.timetospawn - dt			
		end

		if spawnerinst and self.prefab then			
			if self.timetospawn <= 0 then

				local spawnFlower = self:GetSpawnPoint(spawnerinst)

				if spawnFlower and self.numglowflys < self.glowflycap then
				--	print("SPAWN GLOWFLY"					
					local glowfly = SpawnPrefab(self.prefab)
					local spawn_point = Vector3(spawnFlower.Transform:GetWorldPosition() )
					glowfly.Physics:Teleport(spawn_point.x,spawn_point.y,spawn_point.z)
					glowfly.components.pollinator:Pollinate(spawnFlower)
					self:StartTracking(glowfly)
					glowfly.components.homeseeker:SetHome(spawnFlower)
					glowfly.OnBorn(glowfly)					
				end
				if self.followplayer then
					self.timetospawn = self.nexttimetospawnBase + math.random()*self.nexttimetospawn
				else
					self.timetospawn = math.random()
				end
			end
		end
	end

	
	if GetWorld().components.seasonmanager:IsTemperateSeason() and not self.nocycle then
		
		if season_percent > 0.3 and season_percent <= 0.8 then
			-- the glowgly pop grows starting at 30% season time to 80% season time where it reaches the max. 
			-- so basically it takes half the season to go from default to the humid season settings and reaches max 80% into the season.
			season_percent = season_percent + 0.2			
			local diff_percent =  1-math.sin(PI*season_percent)
			self.nexttimetospawn = math.floor(self.nexttimetospawn_default + ( diff_percent * (self.nexttimetospawn_warm - self.nexttimetospawn_default) )  )
			self.nexttimetospawnBase = math.floor(self.nexttimetospawnBase_default + ( diff_percent * (self.nexttimetospawnBase_warm - self.nexttimetospawnBase_default) )  )  
			self.glowflycap = math.floor(self.glowflycap_default + ( diff_percent * (self.glowflycap_warm - self.glowflycap_default) )  )  	
			self.timetospawn = math.min(self.timetospawn, self.nexttimetospawnBase+ math.random()*self.nexttimetospawn )

		elseif season_percent > 0.88 then

			if not self.inst.glowflycocoontask then

				--self.inst.glowflycocoontask, self.inst.glowflycocoontaskinfo = self.inst:ResumeTask(2* TUNING.SEG_TIME +   (math.random()*TUNING.SEG_TIME*2), function() self:startCocoonTimer() end)
				self:setglowflycocoontask(self.inst, 2* TUNING.SEG_TIME +   (math.random()*TUNING.SEG_TIME*2))	
			end			
		end
	else
		if GetWorld().components.seasonmanager:IsHumidSeason() and not self.nocycle  then 

	
			if not self.inst.glowflyhatchtask then
				--self.inst.glowflyhatchtask, self.inst.glowflyhatchtaskinfo = self.inst:ResumeTask(, function() GetWorld():PushEvent("glowflyhatch") end)
				self:setglowflyhatchtask(self.inst, 5)
			end
			if self.glowflycap ~= self.glowflycap_cold then
				print("END GLOWFLY EXPLOSION")
				self.nexttimetospawn = self.nexttimetospawn_cold 
				self.nexttimetospawnBase = self.nexttimetospawnBase_cold
				self.glowflycap = self.glowflycap_cold
				self.timetospawn = 0
			end
		elseif self.glowflycap ~= self.glowflycap_default then
			print("GLOWFLIES RETURN TO NORMAL")	
			self.nexttimetospawn =  self.nexttimetospawn_default
			self.nexttimetospawnBase =  self.nexttimetospawnBase_default
			self.glowflycap =  self.glowflycap_default					
		end
	end	

    
end

function GlowflySpawner:GetDebugString()
	return "Next spawn: "..tostring(self.timetospawn)
end

function GlowflySpawner:OnSave()
	local data ={
		timetospawn = self.timetospawn,
		nexttimetospawn = self.nexttimetospawn,
		nexttimetospawnBase =  self.nexttimetospawnBase,
    	glowflycap = self.glowflycap,    
    	nocycle = self.nocycle,	
	}

	if self.glowflycocoontask then
		data.glowflycocoontask = self.inst:TimeRemainingInTask(self.inst.glowflycocoontaskinfo)
	end

	if self.glowflyhatchtask then
		data.glowflyhatchtask = self.inst:TimeRemainingInTask(self.inst.glowflyhatchtaskinfo)
	end

	return data
end

function GlowflySpawner:OnLoad(data)
	self.nocycle = data.nocycle
	self.timetospawn = data.timetospawn or 10
	self.nexttimetospawn = data.nexttimetospawn or 10
	self.glowflycap = data.glowflycap or 4
	if data.glowflycocoontask then
		self:setglowflycocoontask(self.inst, data.glowflycocoontask)
	end
	if data.glowflyhatchtask then
		self:setglowflyhatchtask(self.inst, data.glowflyhatchtask)
	end
end

function GlowflySpawner:SpawnModeNever()
	self.timetospawn = -1
	self.nexttimetospawn = 10
    self.glowflycap = 0
    self.inst:StopUpdatingComponent(self)
end

function GlowflySpawner:SpawnModeVeryHeavy()
	self.timetospawn = 2
	self.nexttimetospawn = 0
    self.glowflycap = 10

    self.nexttimetospawn_default = 2
    self.nexttimetospawnBase_default = 0
    self.glowflycap_default = 10

    self.nexttimetospawn_warm = 2
    self.nexttimetospawnBase_warm = 0
    self.glowflycap_warm = 20   
end

function GlowflySpawner:SpawnModeHeavy()
	self.timetospawn = 5
	self.nexttimetospawn = 5
    self.glowflycap = 7

    self.nexttimetospawn_default = 5
    self.nexttimetospawnBase_default = 5
    self.glowflycap_default = 7

    self.nexttimetospawn_warm = 2
    self.nexttimetospawnBase_warm = 0
    self.glowflycap_warm = 14
end

function GlowflySpawner:SpawnModeMed()
	self.timetospawn = 10
	self.nexttimetospawn = 10
    self.glowflycap = 4

    self.nexttimetospawn_default = 10
    self.nexttimetospawnBase_default = 10
    self.glowflycap_default = 4

    self.nexttimetospawn_warm = 2
    self.nexttimetospawnBase_warm = 0
    self.glowflycap_warm = 10     
end

function GlowflySpawner:SpawnModeLight()
	self.timetospawn = 15
	self.nexttimetospawn = 15
    self.glowflycap = 2

    self.nexttimetospawn_default = 15
    self.nexttimetospawnBase_default = 15
    self.glowflycap_default = 2

    self.nexttimetospawn_warm = 5
    self.nexttimetospawnBase_warm = 2
    self.glowflycap_warm = 8     
end

return GlowflySpawner
