-- Spawns water chess creatures at the location of past (water based) crimes.
local function trace(...)
	--print(GetTime(), "ChessNavy:", ...)
end

local function ondeath(inst, data)
	if data then
		local victim = data.inst
		local cause = data.cause
		local player_prefab = GetPlayer().prefab
		local crime_pos = victim:GetPosition()
		local on_water = GetMap():IsWater(GetMap():GetTileAtPoint(crime_pos:Get()))

		if on_water and cause == player_prefab then
			trace("Crime Detected at:", crime_pos)
			local navy = inst.components.chessnavy
			local spawn_point = navy:GetSpawnPointNear(crime_pos)
			if not spawn_point then
				navy:AddSpawnPoint(crime_pos)
			else
				trace("Already investigating crimes nearby at ", spawn_point:GetPosition())
			end
			navy:ReportCrime(victim)
		end
	end
end

local ChessNavy = Class(function(self, inst)
	self.inst = inst

	self.possible_spawn_points = {}
	self.min_spawn_dist_sq = 1600 -- 40 * 40

	self.attack_difficulty = self.difficulty.intro
	self.attack_frequency_fn = self.frequency.occasional
	self.spawn_timer = nil
	self.ready_to_spawn = false

	self.inst:ListenForEvent("entity_death", ondeath)
	self:Start()
end)

local _crime_modifier = 0.1
local _spawn_point_prefab = "chess_navy_spawner"

ChessNavy.difficulty =
{
	intro 	= {["knightboat"] = 1},
	light 	= {["knightboat"] = 2},
	med 	= {["knightboat"] = 3},
	heavy 	= {["knightboat"] = 3},
	crazy 	= {["knightboat"] = 3},
}

ChessNavy.frequency =
{
	rare = function() return TUNING.TOTAL_DAY_TIME * 15 + math.random() * TUNING.TOTAL_DAY_TIME * 5 end,
	occasional = function() return TUNING.TOTAL_DAY_TIME * 10 + math.random() * TUNING.TOTAL_DAY_TIME * 2.5 end,
	frequent = function() return TUNING.TOTAL_DAY_TIME * 7.5 + math.random() * TUNING.TOTAL_DAY_TIME * 1 end,
}

function ChessNavy:Start()
	local update_dt = 1
	self.chessnavy_updatetask = self.inst:DoPeriodicTask(update_dt, function() self:OnUpdate(update_dt) end)
end

function ChessNavy:Stop()
	if self.chessnavy_updatetask then
		self.chessnavy_updatetask:Cancel()
		self.chessnavy_updatetask = nil
	end
end

function ChessNavy:CalcEscalationLevel()
	local day = GetClock().numcycles
	
	if day < 20 then
		self.attack_frequency_fn = self.frequency.rare
		self.attack_difficulty = self.difficulty.intro
	elseif day < 30 then
		self.attack_frequency_fn = self.frequency.rare
		self.attack_difficulty = self.difficulty.light
	elseif day < 50 then
		self.attack_frequency_fn = self.frequency.occasional
		self.attack_difficulty = self.difficulty.med
	elseif day < 70 then
		self.attack_frequency_fn = self.frequency.occasional
		self.attack_difficulty = self.difficulty.heavy
	else
		self.attack_frequency_fn = self.frequency.frequent
		self.attack_difficulty = self.difficulty.crazy
	end
end

function ChessNavy:IsActive()
	return self.chessnavy_updatetask ~= nil
end

function ChessNavy:StartNewInvestigation()
	trace("Starting new investigation")
	self:RemoveAllSpawnPoints()
	self:CalcEscalationLevel()
	self.spawn_timer = self.attack_frequency_fn()
	self.ready_to_spawn = false
end

function ChessNavy:DeltaTimer(delta)
	if not self.spawn_timer then print("WARNING: No Spawn Timer in ChessNavy:DeltaTimer!") return end

	self.spawn_timer = self.spawn_timer + delta
	self.spawn_timer = math.max(self.spawn_timer, 0)

	if self.spawn_timer <= 0 and self:IsActive() then
		self:ActivateSpawnPoints()
	end
end

function ChessNavy:ReportCrime(victim)
	if victim and not victim:HasTag("chess") and victim.components.health then
		--Get max health of thing killed.
		local max_hp = victim.components.health:GetMaxHealth()
		self:DeltaTimer(-max_hp * _crime_modifier)
		trace("Got report of crime! Delta timer by ", -max_hp * _crime_modifier)
		trace("time until active: ",self.spawn_timer)
	end
end

function ChessNavy:GetSpawnPointNear(pt)
	for _,v in ipairs(self.possible_spawn_points) do
		if v:GetPosition():DistSq(pt) <= self.min_spawn_dist_sq then
			return v
		end
	end
end

function ChessNavy:AddSpawnPoint(pt)
	trace("Setting up a new investigation at ", pt)

	local spawn_point = SpawnPrefab(_spawn_point_prefab)
	spawn_point.Transform:SetPosition(pt:Get())

	self:TrackSpawnPoint(spawn_point)
end

function ChessNavy:TrackSpawnPoint(spawn_point)
	if spawn_point then
		trace("now tracking spawn point", spawn_point)
		table.insert(self.possible_spawn_points, spawn_point)
		self.inst:ListenForEvent("onentitywake", function() self:SpawnPointWake(spawn_point) end, spawn_point)
	end
end

function ChessNavy:DoSpawnAtPoint(spawn_point)
	trace("deploying troops to", spawn_point:GetPosition())
	
	local to_spawn = self:GetSpawnPrefabs()
	local pos = spawn_point:GetPosition()

	for _, prefab in ipairs(to_spawn) do
		local boat = SpawnPrefab(prefab)
		boat:RestartBrain()
		local offset = FindWaterOffset(pos, math.random() * 2 * PI, math.random(4, 10), 12)
		local spawn_point = pos + (offset or Vector3(0,0,0))
		boat.Transform:SetPosition(spawn_point:Get())
	end

	self:StartNewInvestigation()
end

function ChessNavy:SpawnPointWake(spawn_point)
	print("returned to scene of crime!", spawn_point:GetPosition())
	if self.ready_to_spawn and GetTime() > 1 --[[don't spawn on game load...]] then
		self:DoSpawnAtPoint(spawn_point)
	end
end

function ChessNavy:ActivateSpawnPoints()
	if not self.ready_to_spawn then
		trace("timer done! Spawn points are active.")
		self.ready_to_spawn = true
	end
end

function ChessNavy:RemoveAllSpawnPoints()
	trace("removing all active investigations")
	for _,v in ipairs(self.possible_spawn_points) do
		v:Remove()
	end
	self.possible_spawn_points = {}
end

function ChessNavy:GetSpawnPrefabs()
	self:CalcEscalationLevel()
	local to_spawn = {}
	local difficulty = self.attack_difficulty

	for k,v in pairs(difficulty) do
		for i = 1, v do
			table.insert(to_spawn, k)

			trace("Adding", k, "to spawns.")

		end
	end
	return to_spawn
end

function ChessNavy:OnUpdate(dt)
	if self.spawn_timer == nil then
		self:StartNewInvestigation()
	end

	self:DeltaTimer(-dt)
end

function ChessNavy:LongUpdate(dt)
	if self:IsActive() then
		self:OnUpdate(dt)
	end
end

function ChessNavy:OnSave()
	local data = {}
	local references = {}

	data.ready_to_spawn = self.ready_to_spawn
	data.spawn_timer = self.spawn_timer
	
	for _, spawn_point in ipairs(self.possible_spawn_points) do
		if not data.spawn_point_GUIDs then
			data.spawn_point_GUIDs = {spawn_point.GUID}
		else
			table.insert(data.spawn_point_GUIDs, spawn_point.GUID)
		end

		table.insert(references, spawn_point.GUID)
	end

	return data, references
end

function ChessNavy:OnLoad(data)
	if data then
		self.ready_to_spawn = data.ready_to_spawn
		self.spawn_timer = data.spawn_timer
	end
end

function ChessNavy:LoadPostPass(newents, data)
    if data.spawn_point_GUIDs then
        for _, GUID in pairs(data.spawn_point_GUIDs) do
            local spawn_point = newents[GUID]
            if spawn_point then
                spawn_point = spawn_point.entity
                self:TrackSpawnPoint(spawn_point)
            end
        end
    end
end

 function ChessNavy:GetDebugString()
	if self.spawn_timer and self.spawn_timer > 0 then
		return string.format("The navy arrives in %2.2f. %2.0f active investigations.", self.spawn_timer or 0, #self.possible_spawn_points)
	else
		return string.format("waiting for criminal to return to the scene of a crime...")
	end
end

return ChessNavy