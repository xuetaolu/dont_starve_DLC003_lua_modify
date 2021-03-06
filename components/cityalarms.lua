
STATUS = {
	CALM = 1,
	ALARMED = 2,
}

local PIG_SIGHT_RANGE = TUNING.CITY_PIG_GUARD_TARGET_DIST
local PIG_CITY_LIMITS = 30
local TOWER_SIGHT_RANGE = 30


local Cityalarms = Class(function(self, inst)	
    self.inst = inst

   	self.cities = {}
end)

DEBUG = true

local function debugprint(string)
	if DEBUG == true then
		print(string)
	end
end

local function spawnGuardPigFromOffscreen(inst, city, threat)
	local player = GetPlayer()	
	local tries = 0
	local placed = false
	local SCREENDIST = 35
	local pos = Vector3(threat.Transform:GetWorldPosition())

	while tries < 50 and placed == false do
    	
    	local start_angle = math.random()*2*PI
		local offset = FindWalkableOffset(pos, start_angle, SCREENDIST, 8, false)
		if offset == nil then
		    -- well it's gotta go somewhere!
		    pos = pos + Vector3(SCREENDIST*math.cos(start_angle), 0, SCREENDIST*math.sin(start_angle))
		else
		    pos = pos + offset
		end

		if player:GetDistanceSqToPoint(pos) >= SCREENDIST*SCREENDIST then
			placed = true			
		end
		tries = tries +1 
	end

	if placed then
		local prefab = "pigman_royalguard"
		if city == 2 then
			prefab = "pigman_royalguard_2"
		end

		inst:DoTaskInTime(0,function() 
			local guard = SpawnPrefab(prefab)
			if guard.Physics then
			    guard.Physics:Teleport(pos:Get())
			else
			    guard.Transform:SetPosition(pos:Get())
			end	
			guard.components.citypossession.cityID = city	
			guard.components.knownlocations:RememberLocation("home", pos )
			guard:PushEvent("attacked", {attacker = threat, damage = 0, weapon = nil})		
		end)	
	end
end

local function spawnGuardPigFromTower(inst, city, tower,threat)
	local guard = SpawnPrefab(tower.components.spawner:GetChildName())
	local rad = 0.5
    if tower.Physics then
        local prad = tower.Physics:GetRadius() or 0
        rad = rad + prad
    end
    
    if guard.Physics then
        local prad = guard.Physics:GetRadius() or 0
        rad = rad + prad
    end
    
    local pos = Vector3(tower.Transform:GetWorldPosition())
    local start_angle = math.random()*2*PI

    local offset = FindWalkableOffset(pos, start_angle, rad, 8, false)
    if offset == nil then
        -- well it's gotta go somewhere!
        pos = pos + Vector3(rad*math.cos(start_angle), 0, rad*math.sin(start_angle))
    else
        pos = pos + offset
    end
    if guard.Physics then
        guard.Physics:Teleport(pos:Get() )
    else
        guard.Transform:SetPosition(pos:Get())
    end
	tower.onvacate(tower)	
    if guard.components.knownlocations then
        guard.components.knownlocations:RememberLocation("home", Vector3(tower.Transform:GetWorldPosition()))
    end	
	guard.components.citypossession.cityID = city	
	guard:PushEvent("attacked", {attacker = threat, damage = 0, weapon = nil})
end


function Cityalarms:OnSave()
	local data = {}
	data.cities = {}
	
	local refs = {}
	
	for c,city in ipairs(self.cities)do
		data.cities[c] = {}
		data.cities[c].threats = {}
		for i,threat in ipairs(city.threats)do
			table.insert(data.cities[c].threats,threat.GUID)
			table.insert(refs,threat.GUID)
		end
		data.cities[c].guards = city.guards
		data.cities[c].min_guard_response = city.min_guard_response
		data.cities[c].guard_ready_time = TUNING.SEG_TIME * 2
		data.cities[c].status = city.status

		if self.cities[c].watch_threat_task then
			data.cities[c].watch_threat_task = true
		end
	end	
	return data, refs
end

function Cityalarms:OnLoad(data)	
	self.cities = {}
	for c,city in ipairs(data.cities)do
		self.cities[c] = {}
		self.cities[c].guards = city.guards
		self.cities[c].min_guard_response = city.min_guard_response
		self.cities[c].guard_ready_time = city.guard_ready_time
		self.cities[c].status = city.status
		self.cities[c].threats = {}		
	end
end

function Cityalarms:LoadPostPass(newents, data)
	for c,city in ipairs(self.cities)do
		for i,threat in ipairs(data.cities[c].threats)do
			local child =  newents[threat]
			if child then
				table.insert(self.cities[c].threats, child.entity )
			end
		end
	end
end

function Cityalarms:ReleaseGuards(city, threat)
	local x,y,z = threat.Transform:GetWorldPosition()

	for i=1,self.cities[city].guards,1 do
		debugprint("GUARDS",self.cities[city].guards)

		-- GRAB GUARD PIGS IN RANGE
		local guards = TheSim:FindEntities(x,y,z, 30, {"guard"})      
		local guard_assigned = false 

		for i,guard in ipairs(guards) do
			if guard.components.combat.target == nil and not guard:HasTag("alarmed_picked") then				
				guard:AddTag("alarmed_picked")
				guard:DoTaskInTime(math.random()*1,function()
					guard:RemoveTag("alarmed_picked")
					guard:PushEvent("attacked", {attacker = threat, damage = 0, weapon = nil})
				end)
				guard_assigned = true
				break		
			end			
		end  

		-- FIND A TOWER TO SPAWN PIGS IN RANGE
		if not guard_assigned then
			local towers = TheSim:FindEntities(x,y,z, 30, {"guard_tower"})
			local tower = nil
			local dist = 999999

			if #towers > 0 then				
				for i,testtower in ipairs(towers)do
					if testtower:GetDistanceSqToInst(threat) < dist then
						tower = testtower
						dist = testtower:GetDistanceSqToInst(threat)
					end
				end
			end		

			if tower then		
				self.inst:DoTaskInTime(math.random()*1,function()
 					spawnGuardPigFromTower(self.inst, city, tower,threat)				
 				end)
 				guard_assigned = true	
 			else
 				spawnGuardPigFromOffscreen(self.inst, city, threat)
 				guard_assigned = true	
			end		
		end

		if guard_assigned then
			self.cities[city].guards = self.cities[city].guards -1
		end
	end
end

function Cityalarms:ReadyGuard(city)
	debugprint("READYING GUARDS")
	if self.cities[city].guards < self.cities[city].min_guard_response then 	
		self.cities[city].guards = self.cities[city].guards + 1
		debugprint("guards +1")
 	end
 	if self.cities[city].guards >= self.cities[city].min_guard_response and self.cities[city].status == STATUS.ALAMED then
 		self:ReleaseGuards(city,self.cities[city].threats[#self.cities[city].threats])
 	end
 	if self.cities[city].task then
 		self.cities[city].task:Cancel()
 		self.cities[city].task = nil
 	end
 	self.cities[city].task = self.inst:DoTaskInTime(self.cities[city].guard_ready_time, function() self:ReadyGuard(city) end)
end

function Cityalarms:isThreat(target)

	for c,city in ipairs(self.cities)do
		for i,threat in ipairs(city.threats)do

			if target == threat then				
				return true
			end
		end
	end
	return false
end

function Cityalarms:ChangeStatus(city, alarmed, threat, ignore_royal_status)

	print("&&&&&&&&&&&&&&&&&&&&", threat.prefab)

	if threat.components.combat then
		while threat.components.combat.proxy do
			threat = threat.components.combat.proxy
		end
	end

	if city then 
		if alarmed and threat:IsValid() and (not threat:HasTag("pigroyalty") or ignore_royal_status)then
			local x,y,z = threat.Transform:GetWorldPosition()

			local range = PIG_SIGHT_RANGE

			if threat:HasTag("sneaky") then
				range = TUNING.SNEAK_SIGHTDISTANCE
			end

			local playmusic = false
			local pigs = TheSim:FindEntities(x,y,z, range, {"city_pig"})     				
			for i,pig in ipairs(pigs)do
				--debugprint("Target",pig.components.combat.target)
				if pig.components.combat.target == nil then	
					print("ALERTING FROM WITNESS")				
					pig:DoTaskInTime(math.random()*1,function()
						pig:PushEvent("attacked", {attacker = threat, damage = 0, weapon = nil})
					end)			
					playmusic = true
				end
			end 

			local tower_range = TOWER_SIGHT_RANGE

			if threat:HasTag("sneaky") then
				tower_range = TUNING.SNEAK_SIGHTDISTANCE
			end

			local towers = TheSim:FindEntities(x,y,z, tower_range, {"guard_tower"})     				
			for i,tower in ipairs(towers)do								
				tower.callguards(tower,threat)
				playmusic = true
			end 

			if threat == GetPlayer() and playmusic then
				GetPlayer().components.dynamicmusic:OnStartDanger()			
			end
		end
	end
end

function Cityalarms:AddCity(idx)
	local citydata = 
	{
		guards = 3,
		min_guard_response = 3,
		guard_ready_time = TUNING.SEG_TIME * 2,
		status = STATUS.CALM,
		threats = {},	
	}

	self.cities[idx] = citydata
	--self.cities[idx].task = self.inst:DoTaskInTime(self.cities[idx].guard_ready_time, function() self:ReadyGuard(idx) end)
end

function Cityalarms:OnUpdate(dt)
end


function Cityalarms:LongUpdate(dt)
	for c,city in ipairs(self.cities)do		
		for i=1,math.floor(dt/self.cities[c].guard_ready_time),1 do
			self:ReadyGuard(c)
		end
		local newtime = dt%self.cities[c].guard_ready_time
		if self.cities[c].task then
			self.cities[c].task:Cancel()
			self.cities[c].task = nil
		end
	--	self.cities[c].task = self.inst:DoTaskInTime(self.cities[c].guard_ready_time, function() self:ReadyGuard(c) end)
	end
end


return Cityalarms


