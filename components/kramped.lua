local Kramped = Class(function(self, inst)
    self.inst = inst

    self.actions = 0
    self.threshold = nil

    self.inst:ListenForEvent( "killed", function(inst,data) self:onkilledother(data.victim) end )
    self.timetodecay = TUNING.KRAMPUS_NAUGHTINESS_DECAY_PERIOD
    self.inst:StartUpdatingComponent(self)
end)

local SPAWN_DIST = 30

function Kramped:OnSave()
	local data ={
		threshold = self.threshold,
		actions = self.actions
	} 
	local refs = {}
	if self.krampustracking and #self.krampustracking > 0 then
		
		if self.krampeddestination.prefab then
			data.krampusdestination = self.krampeddestination.GUID
			table.insert(refs,self.krampeddestination.GUID)
		else
			data.krampusdestinationX = self.krampeddestination.x
			data.krampusdestinationZ = self.krampeddestination.z
		end				
	end
	return data,refs
end

function Kramped:onkilledother(victim)
	if victim and victim.prefab then
		if victim.prefab == "pigman" then
			if not victim.components.werebeast or not victim.components.werebeast:IsInWereState() then
				self:OnNaughtyAction(3)
			end
		elseif victim.prefab == "ballphin" then
			if victim.components.follower and victim.components.follower.previousleader == GetPlayer() then
				self:OnNaughtyAction(3)
			end
		elseif victim.prefab == "babybeefalo" then
			self:OnNaughtyAction(6)
		elseif victim.prefab == "teenbird" then
			self:OnNaughtyAction(2)
		elseif victim.prefab == "smallbird" then
			self:OnNaughtyAction(6)
		elseif victim.prefab == "beefalo" then
			self:OnNaughtyAction(4)
		elseif victim.prefab == "crow" then
			self:OnNaughtyAction(1)
		elseif victim.prefab == "robin" then
			self:OnNaughtyAction(2)
		elseif victim.prefab == "robin_winter" then
			self:OnNaughtyAction(2)
		elseif victim.prefab == "butterfly" then
			self:OnNaughtyAction(1)
		elseif victim.prefab == "rabbit" then
			self:OnNaughtyAction(1)
		elseif victim.prefab == "mole" then
			self:OnNaughtyAction(1)
		elseif victim.prefab == "tallbird" then
			self:OnNaughtyAction(2)
		elseif victim.prefab == "ballphin" then
			self:OnNaughtyAction(2)
		elseif victim.prefab == "bunnyman" then
			self:OnNaughtyAction(3)
		elseif victim.prefab == "penguin" then
			self:OnNaughtyAction(2)
		elseif victim.prefab == "glommer" then
			self:OnNaughtyAction(50) -- You've been bad!
		elseif victim.prefab == "catcoon" then
			self:OnNaughtyAction(5)
		elseif victim.prefab == "toucan" then
			self:OnNaughtyAction(1)
		elseif victim.prefab == "parrot" then
			self:OnNaughtyAction(2)
		elseif victim.prefab == "parrot_pirate" then
			self:OnNaughtyAction(6)
		elseif victim.prefab == "seagull" then
			self:OnNaughtyAction(1)
		elseif victim.prefab == "crab" then
			self:OnNaughtyAction(1)
		elseif victim.prefab == "solofish" then
			self:OnNaughtyAction(2)
		elseif victim.prefab == "swordfish" then
			self:OnNaughtyAction(4)
		elseif victim.prefab == "whale_white" then
			self:OnNaughtyAction(6)
		elseif victim.prefab == "whale_blue" then
			self:OnNaughtyAction(7)
		elseif victim.prefab == "jellyfish_planted" or victim.prefab == "rainbowjellyfish_planted" then
			self:OnNaughtyAction(1)
		elseif victim.prefab == "ox" then
			self:OnNaughtyAction(4)
		elseif victim.prefab == "lobster" then
			self:OnNaughtyAction(2)
		elseif victim.prefab == "primeape" then
			self:OnNaughtyAction(2)
		elseif victim.prefab == "doydoy" then
			self:OnNaughtyAction(GetWorld().components.doydoyspawner:GetInnocenceValue())
		elseif victim.prefab == "twister_seal" then
			self:OnNaughtyAction(50) --How could you?

		elseif victim.prefab == "glowfly" then
			self:OnNaughtyAction(1) 
		elseif victim.prefab == "pog" then
			self:OnNaughtyAction(2) 			
		elseif victim.prefab == "pangolden" then
			self:OnNaughtyAction(4) 						
		elseif victim.prefab == "kingfisher" then
			self:OnNaughtyAction(2) 
		elseif victim.prefab == "pigeon" then
			self:OnNaughtyAction(1) 			
		elseif victim.prefab == "dungbeetle" then
			self:OnNaughtyAction(3)
		elseif victim:HasTag("shopkeep") then
			self:OnNaughtyAction(6)	
		elseif victim.prefab == "piko" then
			self:OnNaughtyAction(1)	
		elseif victim.prefab == "piko_orange" then
			self:OnNaughtyAction(2)				
		elseif victim.prefab == "hippopotamoose" then
			self:OnNaughtyAction(4)		
		elseif victim.prefab == "mandrakeman" then
			self:OnNaughtyAction(3)
		elseif victim.prefab == "peagawk" then
			self:OnNaughtyAction(3)					
		--elseif victim.prefab == "frog_poison" then
		--	self:OnNaughtyAction(2)					
		end
	end
end

function Kramped:OnLoad(data)
	self.actions = data.actions or self.actions
	self.threshold = data.threshold or self.threshold
end

function Kramped:LoadPostPass(newents, data)
	if data.krampusdestination then
		print("KRAMPING AGAIN.")
		if data.krampusdestination then
			self.krampeddestination = newents[data.krampusdestination].entity			
		elseif data.krampusdestinationX then
			self.krampeddestination = {x=data.krampusdestinationX,y=0,z=data.krampusdestinationZ}
		end
		local ents = TheSim:FindEntities(0,0,0, 9001,{"krampus","krampingplayerinterior"})
		self:SendToDestination(ents,self.krampeddestination)		
	end
end

function Kramped:GetDebugString()
	if self.actions and self.threshold and self.timetodecay then
		return string.format("Actions: %d / %d, decay in %2.2f", self.actions, self.threshold, self.timetodecay)
	else
		return "Actions: 0"
	end
end


function Kramped:OnUpdate(dt)

	if self.actions > 0 then
		self.timetodecay = self.timetodecay - dt

		if self.timetodecay < 0 then
			self.timetodecay = TUNING.KRAMPUS_NAUGHTINESS_DECAY_PERIOD
			self.actions = self.actions - 1
		end
	end

	if self.shouldspawnkrampus then
		if not TheCamera.interior then
			for i=1,self.shouldspawnkrampus do
				self:MakeAKrampus()
			end
			self.shouldspawnkrampus = nil
		end
	end	
end



function Kramped:OnNaughtyAction(how_naughty)
	if TUNING.KRAMPUS_INCREASE_RAMP < 1 or TUNING.KRAMPUS_THRESHOLD_VARIANCE < 1 then return end

	if self.threshold == nil then
		self.threshold = TUNING.KRAMPUS_THRESHOLD + math.random(TUNING.KRAMPUS_THRESHOLD_VARIANCE)
	end

	self.actions = self.actions + (how_naughty or 1)
	self.timetodecay = TUNING.KRAMPUS_NAUGHTINESS_DECAY_PERIOD

	if self.actions >= self.threshold and self.threshold > 0 and not (self.inst.components.driver and self.inst.components.driver:GetIsDriving()) then --Don't spawn krampus when in a boat

		local day = GetClock().numcycles

		local num_krampii = 1
		self.threshold = TUNING.KRAMPUS_THRESHOLD + math.random(TUNING.KRAMPUS_THRESHOLD_VARIANCE)
		self.actions = 0

		if day > TUNING.KRAMPUS_INCREASE_LVL2 then
			num_krampii = num_krampii + 1 + math.random(TUNING.KRAMPUS_INCREASE_RAMP)
		elseif day > TUNING.KRAMPUS_INCREASE_LVL1 then
			num_krampii = num_krampii + math.random(TUNING.KRAMPUS_INCREASE_RAMP)
		end

		for k = 1, num_krampii do
			if not self.shouldspawnkrampus then
				self.shouldspawnkrampus = 0
			end
			self.shouldspawnkrampus = self.shouldspawnkrampus + 1
		end

	else
		self.inst:DoTaskInTime(1 + math.random()*2, function()

			local snd = CreateEntity()
			snd.entity:AddTransform()
			snd.entity:AddSoundEmitter()
			snd.persists = false
			local theta = math.random() * 2 * PI
			local radius = 15
			local offset = Vector3(self.inst.Transform:GetWorldPosition()) +  Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
			snd.Transform:SetPosition(offset.x,offset.y,offset.z)

			local left = self.threshold - self.actions
			if left < 5 then
				snd.SoundEmitter:PlaySound("dontstarve/creatures/krampus/beenbad_lvl3")
			elseif left < 15 then
				snd.SoundEmitter:PlaySound("dontstarve/creatures/krampus/beenbad_lvl2")
			elseif left < 20 then
				snd.SoundEmitter:PlaySound("dontstarve/creatures/krampus/beenbad_lvl1")
			end
			snd:Remove()
		end)
	end
end

function Kramped:GetSpawnPoint(pt)

    local theta = math.random() * 2 * PI
    local radius = SPAWN_DIST

	local offset = FindWalkableOffset(pt, theta, radius, 12, true)
	if offset then
		return pt+offset
	end
end

function Kramped:MakeAKrampus()
	local pt = Vector3(self.inst.Transform:GetWorldPosition())

	local spawn_pt = self:GetSpawnPoint(pt)

	if spawn_pt then

		local kramp = SpawnPrefab("krampus")
		if kramp then
			kramp.Physics:Teleport(spawn_pt:Get())
			kramp:FacePoint(pt)
		end
	end

	print("Make A Krampus")
end


function Kramped:SendToDestination(ents,destination)
	self.krampeddestination = destination
	local is = GetWorld().components.interiorspawner
	self.krampustracking={}
	if #ents > 0 then			
		for i, ent in ipairs(ents)do
			ent:AddTag("krampingplayerinterior")
			ent:RemoveFromScene()
				local task = self.inst:DoTaskInTime((math.random()*10)+2,function() 						
					ent:ReturnToScene()
					is:Teleport(ent, destination)	
					ent:RemoveTag("krampingplayerinterior")				
				end)								
			table.insert(self.krampustracking,task)	
		end
	end
end


function Kramped:TrackKrampusThroughInteriors(destination)
	
	if self.krampustracking then
		for i,kramps in ipairs(self.krampustracking) do
			kramps:Cancel()
			kramps = nil
		end
	end
	
	local ents = TheSim:FindEntities(0,0,0, 9001,{"krampus"})
	self:SendToDestination(ents,destination)	
end

return Kramped
