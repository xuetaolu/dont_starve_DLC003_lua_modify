
local Hounded = Class(function(self, inst)
    self.inst = inst
	self.warning = false
	self.timetoattack = 200
	self.warnduration = 30
	self.timetonextwarningsound = 0
	self.houndstorelease = 0
	self.timetonexthound = 0
	self.announcewarningsoundinterval = 4
	self.inst:StartUpdatingComponent(self)
	self.warnmode = nil

	self.attackdelayfn = self.attack_delays.occasional
	self.attacksizefn = self.attack_levels.light.numhounds
	self.warndurationfn = self.attack_levels.light.warnduration
	self.spawnmode = "escalating"
	
	self:PlanNextHoundAttack()
end)

Hounded.attack_levels=
{
	intro={warnduration= function() return 120 end, numhounds = function() return 2 end},
	light={warnduration= function() return 60 end, numhounds = function() return 2 + math.random(2) end},
	med={warnduration= function() return 45 end, numhounds = function() return 3 + math.random(3) end},
	heavy={warnduration= function() return 30 end, numhounds = function() return 4 + math.random(3) end},
	crazy={warnduration= function() return 30 end, numhounds = function() return 6 + math.random(4) end},
}

Hounded.attack_delays=
{
	rare = function() return TUNING.TOTAL_DAY_TIME * 6 + math.random() * TUNING.TOTAL_DAY_TIME * 7 end,
	occasional = function() return TUNING.TOTAL_DAY_TIME * 4 + math.random() * TUNING.TOTAL_DAY_TIME * 7 end,
	frequent = function() return TUNING.TOTAL_DAY_TIME * 3 + math.random() * TUNING.TOTAL_DAY_TIME * 5 end,
}
local HOUND_SPAWN_DIST = 30

local function getHoundPrefab(inst)
	local sm = GetSeasonManager()
	local ambibious = false
	local prefab = "hound"	

    if sm:IsTropical() then
        prefab = "crocodog"       
        ambibious = true
    end

	local special_hound_chance = inst:GetSpecialHoundChance()
	if sm:IsTropical() then
		if math.random() < special_hound_chance then	
			if GetWorld().components.flooding and GetWorld().components.flooding.mode == "flood" then
				prefab = "watercrocodog"				
				ambibious = true
			elseif sm:IsDrySeason() then
				prefab = "poisoncrocodog"
				ambibious = true
			end			
		end
	else
		if GetSeasonManager() and GetSeasonManager():IsSummer() then
			special_hound_chance = special_hound_chance * 1.5
		end
		if math.random() < special_hound_chance then
		    if sm:IsWinter() or sm:IsSpring() then
		        prefab = "icehound"
		    else
			    prefab = "firehound"
			end
		end
	end
	return prefab, ambibious
end

local function SpawnHoundPrefab(inst)
	local prefab = getHoundPrefab(inst)
	return SpawnPrefab(prefab)
end


local function SpawnSharxPrefab(inst)
	return SpawnPrefab("sharx")
end 

function Hounded:SummonSharx()
	local pt = Vector3(GetPlayer().Transform:GetWorldPosition())
		
	local spawn_pt = self:GetWaterHoundSpawnPoint(pt)

	if spawn_pt then
		local sharx = SpawnSharxPrefab(self)
		if sharx then
			sharx.Physics:Teleport(spawn_pt:Get())
			sharx:FacePoint(pt)
			sharx.components.combat:SuggestTarget(GetPlayer())
		end
	end
end 

function Hounded:SummonHound()
	if self.spawnmode == "never" then
		self:SummonSharx()
	else
		local pt = Vector3(GetPlayer().Transform:GetWorldPosition())
			
		local spawn_pt = self:GetHoundSpawnPoint(pt)

		if spawn_pt then
			local hound = SpawnHoundPrefab(self)
			if hound then
				hound.Physics:Teleport(spawn_pt:Get())
				hound:FacePoint(pt)
				hound.components.combat:SuggestTarget(GetPlayer())
			end
		end
	end
end 

function Hounded:SpawnModeEscalating()
	self.spawnmode = "escalating"
	self:PlanNextHoundAttack()
end

function Hounded:SpawnModeNever()
	self.spawnmode = "never"
	self:PlanNextHoundAttack()
end

function Hounded:SpawnModeHeavy()
	self.spawnmode = "constant"
	self.attackdelayfn = self.attack_delays.frequent
	self.attacksizefn = self.attack_levels.heavy.numhounds
	self.warndurationfn = self.attack_levels.heavy.warnduration
	self:PlanNextHoundAttack()
end

function Hounded:SpawnModeMed()
	self.spawnmode = "constant"
	self.attackdelayfn = self.attack_delays.occasional
	self.attacksizefn = self.attack_levels.med.numhounds
	self.warndurationfn = self.attack_levels.med.warnduration
	self:PlanNextHoundAttack()
end

function Hounded:SpawnModeLight()
	self.spawnmode = "constant"
	self.attackdelayfn = self.attack_delays.rare
	self.attacksizefn = self.attack_levels.light.numhounds
	self.warndurationfn = self.attack_levels.light.warnduration
	self:PlanNextHoundAttack()
end


function Hounded:OnSave()
	if not self.noserial then
		return 
		{
			spawnmode = self.spawnmode,
			warning = self.warning,
			timetoattack = self.timetoattack,
			warnduration = self.warnduration,
			houndstorelease = self.houndstorelease,
			timetonexthound = self.timetonexthound
		}
	end
	self.noserial = false
end

function Hounded:OnLoad(data)
	self.spawnmode = data.spawnmode or "escalating"
	self.warning = data.warning or false
	self.timetoattack = data.timetoattack or 200
	self.warnduration = data.warnduration or 30
	if self.warnduration <= 0 or self.timetoattack <= 0 then self.warning = false end
	self.houndstorelease = data.houndstorelease or 0
	self.timetonexthound = data.timetonexthound or 0
end


function Hounded:OnProgress()
	self.noserial = true
end


function Hounded:GetDebugString()
	if self.timetoattack > 0 then
		return string.format("%s %d hounds are coming in %2.2f", self.warning and "WARNING" or "WAITING",   self.houndstorelease, self.timetoattack)
	else
		return string.format("ATTACKING %d hounds left. Next in %2.2f", self.houndstorelease, self.timetonexthound)
	end
end

function Hounded:OnUpdate(dt)
	if self.spawnmode == "never" then
		return
	end
    
	self.timetoattack = self.timetoattack - dt
	if self.timetoattack <= 0 and not TheCamera.interior then
		self.timetonexthound = self.timetonexthound - dt	
		self.warning = false	
		
		if self.timetonexthound < 0 then
			
			self:ReleaseHound()
			
			local day = GetClock().numcycles
			if day < 20 then
				self.timetonexthound = 3 + math.random()*5
			elseif day < 60 then
				self.timetonexthound = 2 + math.random()*3
			elseif day < 100 then
				self.timetonexthound = .5 + math.random()*3
			else
				self.timetonexthound = .5 + math.random()*1
			end
		end
		
		if self.houndstorelease <= 0 then
			self:PlanNextHoundAttack()
		end
	else
		if not self.warning and self.timetoattack < self.warnduration then
			self.warning = true
			self.warnmode = nil 
			self.timetonextwarningsound = 0
		end
	end
	
	if self.warning then
		self.timetonextwarningsound	= self.timetonextwarningsound - dt
		if self.warnmode == nil then 
			--init warn mode based on player position (land/sea)
			if GetPlayer():HasTag("aquatic") then 
				self.warnmode = "water"
			else 
				self.warnmode = "land"
			end 
		end 

		if self.timetonextwarningsound <= 0 then
		
			self.announcewarningsoundinterval = self.announcewarningsoundinterval - 1
			if self.announcewarningsoundinterval <= 0 then
				self.announcewarningsoundinterval = 10 + math.random(5)
					if self.warnmode == "land" then 
						GetPlayer().components.talker:Say(GetString(GetPlayer().prefab, "ANNOUNCE_HOUNDS"))
					elseif self.warnmode == "water" then 
						GetPlayer().components.talker:Say(GetString(GetPlayer().prefab, "ANNOUNCE_HOUNDS"))
					end 
			end
		
			local inst = CreateEntity()
			inst.entity:AddTransform()
			inst.entity:AddSoundEmitter()
			inst.persists = false
			local theta = math.random() * 2 * PI

			local radius = 30
			
			if self.timetoattack < 30 then
				self.timetonextwarningsound = .3 + math.random(1)
				radius = HOUND_SPAWN_DIST
			elseif self.timetoattack < 60 then
				self.timetonextwarningsound = 2 + math.random(1)
				radius = HOUND_SPAWN_DIST + 10
			elseif self.timetoattack < 90 then
				self.timetonextwarningsound = 4 + math.random(2)
				radius = HOUND_SPAWN_DIST + 20
			else
				self.timetonextwarningsound = 5 + math.random(4)
				radius = HOUND_SPAWN_DIST + 30
			end

			local offset = Vector3(GetPlayer().Transform:GetWorldPosition()) +  Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
			
			inst.Transform:SetPosition(offset.x,offset.y,offset.z)

			if GetSeasonManager():IsTropical() then
				inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/crocodog/distant")			
			else
				inst.SoundEmitter:PlaySound("dontstarve/creatures/hound/distant")
			end

			inst:DoTaskInTime(1.5, function() inst:Remove() end)
			
		end
	end
end


function Hounded:DeferAttack()
	--print("deferring hound attack!!!!")
	self.warning = false 
	self.timetoattack = TUNING.TOTAL_DAY_TIME/8
end 

function Hounded:CalcEscalationLevel()
	local day = GetClock().numcycles
	
	if day < 10 then
		self.attackdelayfn = self.attack_delays.rare
		self.attacksizefn = self.attack_levels.intro.numhounds
		self.warndurationfn = self.attack_levels.intro.warnduration
	elseif day < 25 then
		self.attackdelayfn = self.attack_delays.rare
		self.attacksizefn = self.attack_levels.light.numhounds
		self.warndurationfn = self.attack_levels.light.warnduration
	elseif day < 50 then
		self.attackdelayfn = self.attack_delays.occasional
		self.attacksizefn = self.attack_levels.med.numhounds
		self.warndurationfn = self.attack_levels.med.warnduration
	elseif day < 100 then
		self.attackdelayfn = self.attack_delays.occasional
		self.attacksizefn = self.attack_levels.heavy.numhounds
		self.warndurationfn = self.attack_levels.heavy.warnduration
	else
		self.attackdelayfn = self.attack_delays.frequent
		self.attacksizefn = self.attack_levels.crazy.numhounds
		self.warndurationfn = self.attack_levels.crazy.warnduration
	end
	
end

function Hounded:PlanNextHoundAttack()
	
	if self.spawnmode == "escalating" then
		self:CalcEscalationLevel()
	end
	
	if self.spawnmode ~= "never" then
		self.timetoattack = self.attackdelayfn()
		self.houndstorelease = self.attacksizefn()
		self.warnduration = self.warndurationfn()
	end
end


function Hounded:GetSpawnPoint(pt)
	if GetPlayer():HasTag("aquatic") then 
		return 
	end 

    local theta = math.random() * 2 * PI
    local radius = HOUND_SPAWN_DIST

	local offset = FindWalkableOffset(pt, theta, radius, 12, true)
	if offset then
		local pos = pt+offset

		local ground = GetWorld()
	    local tile = GROUND.GRASS
	    if ground and ground.Map then
	        tile = self.inst:GetCurrentTileType(pos:Get())
	    end

	    local onWater = ground.Map:IsWater(tile)
	    if not onWater then 
	    	return pos
	    end 
	end
end

function Hounded:GetSpecialHoundChance()
	local day = GetClock():GetNumCycles()
	local chance = 0
	for k,v in ipairs(TUNING.HOUND_SPECIAL_CHANCE) do
	    if day > v.minday then
	        chance = v.chance
	    elseif day <= v.minday then
	        return chance
	    end
	end
	
	return chance
end

function Hounded:GetHoundSpawnPoint(pt)
	local prefab, amphibious = getHoundPrefab(self)
	if amphibious then
		print("SPAWNING AMPHIBIOUS")
	    local theta = math.random() * 2 * PI
	    local radius = HOUND_SPAWN_DIST
	    local pos = pt + Vector3(math.cos(theta) * radius, 0, math.sin(theta) * radius)
	    
	    return pos		
	else
		print("SPAWNING REGULAR LAND CRIITER")
	    local theta = math.random() * 2 * PI
	    local radius = HOUND_SPAWN_DIST

		local offset = FindWalkableOffset(pt, theta, radius, 12, true)
		if offset then
			return pt+offset
		end
	end
end 

function Hounded:GetWaterHoundSpawnPoint(pt)

    local theta = math.random() * 2 * PI
    local radius = HOUND_SPAWN_DIST
   
	local wateroffset =	FindWaterOffset(pt, theta, radius, 36, false)

	if wateroffset then
 		local pos = pt + wateroffset
    	return pos
	end

end 

function Hounded:ReleaseHound(dt)
	local pt = Vector3(GetPlayer().Transform:GetWorldPosition())
	local spawn_pt = self:GetHoundSpawnPoint(pt)

	if spawn_pt then
		self.houndstorelease = self.houndstorelease - 1
		local hound = SpawnHoundPrefab(self)
		if hound then
			hound.Physics:Teleport(spawn_pt:Get())
			hound:FacePoint(pt)
			hound.components.combat:SuggestTarget(GetPlayer())
		end
	end
    
end 

function Hounded:LongUpdate(dt)
	--I don't think we want to make hounds accumulate here...
	
	--don't actually spawn lots and lots of hounds all at once... just make the next hound attack queue up for next real update
	if self.spawnmode == "never" then
		return
	end
	
	if self.timetoattack > 30 then
		self.timetoattack = math.max(30, self.timetoattack - dt)
	end

end


return Hounded


