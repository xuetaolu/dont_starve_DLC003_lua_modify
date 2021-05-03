local trace = function() end
--local trace = function(...) print(...) end

local HUNT_UPDATE = 2

local function IsWaterTileType(ground)
	return (ground == GROUND.OCEAN_MEDIUM or ground == GROUND.OCEAN_DEEP)
end

local WhaleHunter = Class(function(self, inst)
	self.inst = inst
	
	self.dirt_prefab = "whale_bubbles"
	self.track_prefab = "whale_track"
	self.beast_prefab = "whale_blue"
	self.alternate_beast_prefab = "whale_white"

	self.trackspawned = 0
	self.numtrackstospawn = 0

	-- self.inst:DoTaskInTime(0, function(inst) inst.components.whalehunter:StartCooldown() end)
end)

function WhaleHunter:OnSave()
	trace("WhaleHunter:OnSave")
	local time = GetTime()
	local data = {}
	local references = {}

	if self.lastkillpos then
		trace("       last kill", self.lastkillpos)
		data.lastkillpos = { x = self.lastkillpos.x, y = self.lastkillpos.y, z = self.lastkillpos.z }
	end

	if self.lastdirttime then
		data.timesincedirt = GetTime() - self.lastdirttime
	end

	if self.cooldowntask then
		-- we're cooling down
		data.cooldownremaining = math.max(1, self.cooldowntime - time)
		trace("   cooling down", data.cooldownremaining)
	else
		trace("   hunting")
		-- we're hunting

		if self.lastdirt then
			table.insert(references, self.lastdirt.GUID)
			data.lastdirtid = self.lastdirt.GUID
			trace("       has dirt", data.lastdirtid)
	
			data.numtrackstospawn = self.numtrackstospawn
			data.trackspawned = self.trackspawned
			data.direction = self.direction

			trace("       numtrackstospawn", data.numtrackstospawn)
			trace("       trackspawned", data.trackspawned)
			trace("       direction", data.direction)
		elseif self.huntedbeast then
			data.beastid = self.huntedbeast.GUID
			table.insert(references, self.huntedbeast.GUID)
			trace("       has beast", data.beastid)
		end
	end
	return data, references
end

function WhaleHunter:OnLoad(data)
	trace("WhaleHunter:OnLoad")

	if data.lastkillpos then
		self.lastkillpos = Point(data.lastkillpos.x, data.lastkillpos.y, data.lastkillpos.z)
		trace("   last kill", self.lastkillpos)
	end

	if data.timesincedirt then
		self.lastdirttime = -data.timesincedirt
	end

	if data.cooldownremaining then
		trace("   cooling down", data.cooldownremaining)
		self:StartCooldown(math.clamp(data.cooldownremaining, 1, TUNING.WHALEHUNT_COOLDOWN + TUNING.WHALEHUNT_COOLDOWNDEVIATION))
	else
		trace("   hunting")

		self:StopCooldown()

		-- continued in LoadPostPass
	end
end

function WhaleHunter:LoadPostPass(newents, data)
	trace("WhaleHunter:LoadPostPass")

	if not data.cooldownremaining then

		trace("   hunting")
		if data.lastdirtid then
			trace("       has dirt", data.lastdirtid)
			self.lastdirt = newents[data.lastdirtid] and newents[data.lastdirtid].entity

			--dumptable(self.lastdirt)

			if self.lastdirt then
				self.numtrackstospawn = data.numtrackstospawn or math.random(TUNING.WHALEHUNT_MIN_TRACKS, TUNING.WHALEHUNT_MAX_TRACKS)
				self.trackspawned = data.trackspawned or 0
				self.direction = data.direction -- nil ok

				trace("       numtrackstospawn", self.numtrackstospawn)
				trace("       trackspawned", self.trackspawned)
				trace("       direction", self.direction)
			end

			self:BeginHunt()
		elseif data.beastid then
			trace("       has beast", data.beastid)
			self.huntedbeast = newents[data.beastid] and newents[data.beastid].entity

			--dumptable(self.huntedbeast)

			if self.huntedbeast then
				self:StopCooldown()
				self.inst:ListenForEvent("death", function(inst, data) self:OnBeastDeath(self.huntedbeast) end, self.huntedbeast)
			else
				self:BeginHunt()
			end
		else
			self:BeginHunt()
		end
	end
	self.inst:DoTaskInTime(0, function(inst) inst.components.whalehunter:StartCooldown() end)
end

function WhaleHunter:RemoveDirt()
	trace("WhaleHunter:RemoveDirt")
	if self.lastdirt then
		trace("   removing old dirt")
		self.lastdirt:Remove()
		self.lastdirt = nil
	else
		trace("   nothing to remove")
	end
end

function WhaleHunter:StartDirt()
	trace("WhaleHunter:StartDirt")

	self:RemoveDirt()

	local pt = Vector3(GetPlayer().Transform:GetWorldPosition())

	self.numtrackstospawn = math.random(TUNING.WHALEHUNT_MIN_TRACKS, TUNING.WHALEHUNT_MAX_TRACKS)
	self.trackspawned = 0
	self.direction = self:GetNextSpawnAngle(pt, nil, TUNING.WHALEHUNT_SPAWN_DIST)
	if self.direction then
		trace(string.format("   first angle: %2.2f", self.direction/DEGREES))

		trace("    numtrackstospawn", self.numtrackstospawn)

		-- it's ok if this spawn fails, because we'll keep trying every HUNT_UPDATE
		if self:SpawnDirt() then
			trace("Suspicious dirt placed")
		end
	else
		trace("Failed to find suitable dirt placement point")
	end
end

function WhaleHunter:OnUpdate()
	trace("WhaleHunter:OnUpdate")

	if self.lastdirttime then
		if (GetTime() - self.lastdirttime) > (.75*TUNING.SEG_TIME) and self.huntedbeast == nil and self.trackspawned > 1 then
			self:ResetHunt(true) --Wash the tracks away but only if the player has seen at least 1 track
			return
		end
	end

	local mypos = Point(GetPlayer().Transform:GetWorldPosition())

	if not self.lastdirt then
		local distance = 0
		if not self.lastkillpos then
			self.lastkillpos = Point(GetPlayer().Transform:GetWorldPosition())
		end

		distance = math.sqrt( distsq( mypos, self.lastkillpos ) )
		self.distance = distance
		trace(string.format("    %2.2f", distance)) 

		if distance > TUNING.MIN_WHALEHUNT_DISTANCE then
			self:StartDirt()
		end
	else
		local distance = 0
		local dirtpos = Point(self.lastdirt.Transform:GetWorldPosition())

		distance = math.sqrt( distsq( mypos, dirtpos ) )
		self.distance = distance
		trace(string.format("    dirt %2.2f", distance))

		if distance > TUNING.MAX_DIRT_DISTANCE then
			self:StartDirt()
		end
	end
end

-- something went unrecoverably wrong, try again after a breif pause
function WhaleHunter:ResetHunt(springwash)
	trace("WhaleHunter:ResetHunt")

	trace("The Hunt was a dismal failure, please stand by...")

	self:StartCooldown(TUNING.WHALEHUNT_RESET_TIME)
	
	if springwash then
		GetPlayer():PushEvent("whalehuntlosttrail", {washedaway=true})
	else
		GetPlayer():PushEvent("whalehuntlosttrail", {washedaway=false})
	end

end

-- if anything fails during this step, it's basically unrecoverable, since we only have this one chance
-- to spawn whatever we need to spawn.  if that fails, we need to restart the whole process from the beginning
-- and hope we end up in a better place
function WhaleHunter:OnDirtInvestigated(pt)
	trace("WhaleHunter:OnDirtInvestigated")

	if self.numtrackstospawn and self.numtrackstospawn > 0 then
		if self:SpawnTrack(pt) then
			trace("    ", self.trackspawned, self.numtrackstospawn)
			if self.trackspawned < self.numtrackstospawn then
				if self:SpawnDirt() then
					self:HintDirection(pt)
					trace("...good job, you found a track!")
				else
					trace("SpawnDirt FAILED! RESETTING")
					self:ResetHunt()
				end
			elseif self.trackspawned == self.numtrackstospawn then
				if self:SpawnHuntedBeast() then
					trace("...you found the last track, now find the beast!")
					self:HintDirection(pt)
					GetPlayer():PushEvent("whalehuntbeastnearby")
					self:StopHunt()
				else
					trace("SpawnHuntedBeast FAILED! RESETTING")
					self:ResetHunt()
				end
			end
		else
			trace("SpawnTrack FAILED! RESETTING")
			self:ResetHunt()
		end
	end
end

function WhaleHunter:OnBeastDeath(spawned)
	trace("WhaleHunter:OnBeastDeath")
	self:StartCooldown()
	self.lastkillpos = Point(GetPlayer().Transform:GetWorldPosition())
end

function WhaleHunter:GetRunAngle(pt, angle, radius)
    local test = function(offset)
        local r_pt = pt+offset
        local ground = GetWorld()
        local tile = GetVisualTileType(r_pt.x, r_pt.y, r_pt.z)

        if tile ~= GROUND.OCEAN_MEDIUM and tile ~= GROUND.OCEAN_DEEP then
            return false
        end

        return true
    end

    local offset, result_angle = FindValidPositionByFan(angle, radius, 13, test)

	return result_angle
end

function WhaleHunter:GetNextSpawnAngle(pt, direction, radius)
	trace("WhaleHunter:GetNextSpawnAngle", tostring(pt), radius)

	local base_angle = direction or math.random() * 2 * PI
	local deviation = math.random(-TUNING.WHALEHUNT_TRACK_ANGLE_DEVIATION, TUNING.WHALEHUNT_TRACK_ANGLE_DEVIATION)*DEGREES

	local start_angle = base_angle + deviation
	trace(string.format("   original: %2.2f, deviation: %2.2f, starting angle: %2.2f", base_angle/DEGREES, deviation/DEGREES, start_angle/DEGREES))

	local angle = self:GetRunAngle(pt, start_angle, radius)
	trace(string.format("WhaleHunter:GetNextSpawnAngle RESULT %s", tostring(angle and angle/DEGREES)))

	return angle
end

function WhaleHunter:GetSpawnPoint(pt, radius)
	trace("WhaleHunter:GetSpawnPoint", tostring(pt), radius)

	local angle = self.direction

	if angle then
		local offset = Vector3(radius * math.cos( angle ), 0, -radius * math.sin( angle ))
		local spawn_point = pt + offset
		local tile = GetWorld().Map:GetTileAtPoint(spawn_point.x, spawn_point.y, spawn_point.z)
		trace(string.format("WhaleHunter:GetSpawnPoint RESULT %s, %2.2f", tostring(spawn_point), angle/DEGREES))
		if IsWaterTileType(tile) then
			return spawn_point
		end
	end
end

function WhaleHunter:GetAlternateBeastChance()
	local sm = GetSeasonManager()
	if sm:IsMildSeason() or sm:IsGreenSeason() then
		trace('no chance of white whale')
		return 0
	end

	local day = GetClock():GetNumCycles()
	local chance = Lerp(TUNING.WHALEHUNT_ALTERNATE_BEAST_CHANCE_MIN, TUNING.WHALEHUNT_ALTERNATE_BEAST_CHANCE_MAX, day/100)
	chance = math.clamp(chance, TUNING.WHALEHUNT_ALTERNATE_BEAST_CHANCE_MIN, TUNING.WHALEHUNT_ALTERNATE_BEAST_CHANCE_MAX)
	return chance
end

function WhaleHunter:SpawnHuntedBeast()
	trace("WhaleHunter:SpawnHuntedBeast")
	local pt = Vector3(GetPlayer().Transform:GetWorldPosition())
		
	local spawn_pt = self:GetSpawnPoint(pt, TUNING.WHALEHUNT_SPAWN_DIST)
	if spawn_pt then
		if math.random() > self:GetAlternateBeastChance() then
			self.huntedbeast = SpawnPrefab(self.beast_prefab)
		else
			self.huntedbeast = SpawnPrefab(self.alternate_beast_prefab)
		end
		if self.huntedbeast then
			self.huntedbeast.Physics:Teleport(spawn_pt:Get())
			self.inst:ListenForEvent("death", function(inst, data) self:OnBeastDeath(self.huntedbeast) end, self.huntedbeast)
			if self.huntedbeast.prefab == self.alternate_beast_prefab then
				self.huntedbeast.components.combat:SetTarget(GetPlayer())
			end
			return true
		end
	end
	trace("WhaleHunter:SpawnHuntedBeast FAILED")
	return false
end

function WhaleHunter:HintDirection(pt)
	--Spawn several bubbles in a line pointing towards the next track.
	local bubble_spawns = 4
	local dist_per_bubble = 5
	local seconds_per_spawn = 1.33

	local function SpawnBubble(num)
		local bubble = SpawnPrefab(self.track_prefab)
		local offset = Vector3((num * dist_per_bubble) * math.cos(self.direction), 0, -(num * dist_per_bubble) * math.sin(self.direction))
		bubble.Transform:SetPosition((pt + offset):Get())
	end

	for i = 0, bubble_spawns - 1 do
		self.inst:DoTaskInTime(i * seconds_per_spawn + 0.5, function() SpawnBubble(i) end)
	end
end

function WhaleHunter:SpawnDirt()
	trace("WhaleHunter:SpawnDirt")
	local pt = Vector3(GetPlayer().Transform:GetWorldPosition())

	local spawn_pt = self:GetSpawnPoint(pt, TUNING.WHALEHUNT_SPAWN_DIST)
	if spawn_pt then
		local spawned = SpawnPrefab(self.dirt_prefab)
		if spawned then
			self.lastdirttime = GetTime()
			spawned.Transform:SetPosition(spawn_pt:Get())
			self.lastdirt = spawned
			return true
		end
	end
	trace("WhaleHunter:SpawnDirt FAILED")
	return false
end

function WhaleHunter:SpawnTrack(spawn_pt)
	trace("WhaleHunter:SpawnTrack")

	if spawn_pt then
		local next_angle = self:GetNextSpawnAngle(spawn_pt, self.direction, TUNING.WHALEHUNT_SPAWN_DIST)
		if next_angle then
			self.direction = next_angle
			self.trackspawned = self.trackspawned + 1
			return true
		end
	end
	trace("WhaleHunter:SpawnTrack FAILED")
	return false
end

function WhaleHunter:StopHunt()
	trace("WhaleHunter:StopHunt")

	self:RemoveDirt()

	if self.hunttask then
		trace("   stopping")
		self.hunttask:Cancel()
		self.hunttask = nil
	else
		trace("   nothing to stop")
	end
end

function WhaleHunter:BeginHunt()
	trace("WhaleHunter:BeginHunt")

	self.hunttask = self.inst:DoPeriodicTask(HUNT_UPDATE, function() self:OnUpdate() end)
	if self.hunttask then
		trace("The Hunt Begins!")
	else
		trace("The Hunt ... failed to begin.")
	end

end

function WhaleHunter:OnCooldownEnd()
	trace("WhaleHunter:OnCooldownEnd")
	
	self:StopCooldown() -- clean up references
	self:StopHunt()

	self:BeginHunt()
end

function WhaleHunter:StopCooldown()
	trace("WhaleHunter:StopCooldown")
	if self.cooldowntask then
		trace("    stopping")
		self.cooldowntask:Cancel()
		self.cooldowntask = nil
		self.cooldowntime = nil
	else
		trace("    nothing to stop")
	end
end

function WhaleHunter:StartCooldown(cooldown)
	local cooldown = cooldown or math.random(TUNING.WHALEHUNT_COOLDOWN - TUNING.WHALEHUNT_COOLDOWNDEVIATION, TUNING.WHALEHUNT_COOLDOWN + TUNING.WHALEHUNT_COOLDOWNDEVIATION)
	trace("WhaleHunter:StartCooldown", cooldown)

	self:StopHunt()
	self:StopCooldown()

	if GetPlayer() and GetPlayer().components.health:IsDead() then
		return
	end

	if cooldown and cooldown > 0 then
		--trace("The Hunt begins in", cooldown)
		self.lastdirttime = nil
		self.cooldowntask = self.inst:DoTaskInTime(cooldown, function() self:OnCooldownEnd() end)
		self.cooldowntime = GetTime() + cooldown
	end
end

function WhaleHunter:LongUpdate(dt)
	if self.cooldowntask and self.cooldowntime then
		self.cooldowntask:Cancel()
		self.cooldowntask = nil
		self.cooldowntime = self.cooldowntime - dt
		self.cooldowntask = self.inst:DoTaskInTime(self.cooldowntime - GetTime(), function() self:OnCooldownEnd() end)
	end
end

function WhaleHunter:GetDebugString()
	local str = ""
	
	str = str.." Cooldown: ".. (self.cooldowntime and string.format("%2.2f", math.max(1, self.cooldowntime - GetTime())) or "-")
	if not self.lastdirt then
		str = str.." No last dirt."
		str = str.." Distance: ".. (self.distance and string.format("%2.2f", self.distance) or "-")
		str = str.."/"..tostring(TUNING.MIN_WHALEHUNT_DISTANCE)
	else
		str = str.." Dirt"
		str = str.." Distance: ".. (self.distance and string.format("%2.2f", self.distance) or "-")
		str = str.."/"..tostring(TUNING.MAX_DIRT_DISTANCE)
	end
	return str
end


return WhaleHunter
