local ontrawl = function(player, data)
	--If the player is on deep water then try to spawn kraken
	local krakener = player.components.krakener
	if krakener then
		local chance = krakener.spawn_chance
		if math.random() <= chance then
			local tiles = krakener.valid_tiles
			local tile = GetMap():GetTileAtPoint(player:GetPosition():Get())
			if table.contains(tiles, tile) then
				krakener:DoKrakenEvent()
			end
		end
	end
end

local Krakener = Class(function(self, inst)
	self.inst = inst

	self.kraken_prefab = "kraken"
	self.kraken = nil
	self.spawn_chance = 0.05
	self.spawn_chance_mod = 1.0
	self.respawn_time = TUNING.TOTAL_DAY_TIME * 20
	self.respawn_time_mod = 1.0
	self.respawn_timer = 0
	self.valid_tiles = {GROUND.OCEAN_DEEP, GROUND.OCEAN_SHIPGRAVEYARD}

	self.inst:ListenForEvent("trawlitem", ontrawl)
end)

function Krakener:DoKrakenEvent(force)
	local spawnpt = self:GetNearbySpawnPoint()
	if spawnpt and (self:CanSpawn() or force) then
		local kraken = self:SpawnKraken(spawnpt)
		self:TakeOwnership(kraken)
		GetPlayer().components.dynamicmusic:OnStartDanger()
	end
end

function Krakener:SpawnKraken(pt)
	local kraken = SpawnPrefab(self.kraken_prefab)
	kraken.Transform:SetPosition(pt:Get())
	kraken.sg:GoToState("spawn")
	--self:StartCooldown(self.respawn_time * self.respawn_time_mod)
	return kraken
end

function Krakener:DespawnKraken()
	if not self.kraken then
		return
	end

	local kraken = self.kraken

	self:Abandon(kraken)
	kraken:Remove()
end

function Krakener:TakeOwnership(kraken)
	self.kraken = kraken

	kraken.krakener_death_fn = function()
		self:Abandon(kraken)
		self:StartCooldown(self.respawn_time * self.respawn_time_mod)
	end

	kraken.krakener_sleep_fn = function()
		kraken.krakener_wake_fn = function()
			kraken:RemoveEventCallback("entitywake", kraken.krakener_wake_fn)
			kraken.kraken_remove_task:Cancel()
		end

		kraken:ListenForEvent("entitywake", kraken.krakener_wake_fn)

		kraken.kraken_remove_task = kraken:DoTaskInTime(1, function() 
			self:DespawnKraken() 
		end)
	end

	self.inst:ListenForEvent("death", kraken.krakener_death_fn, kraken)
	self.inst:ListenForEvent("entitysleep", kraken.krakener_sleep_fn, kraken)
end

function Krakener:Abandon(kraken)
	if kraken.krakener_death_fn then
		self.inst:RemoveEventCallback("death", kraken.krakener_death_fn, kraken)
		kraken.krakener_death_fn = nil
	end

	if kraken.krakener_sleep_fn then
		self.inst:RemoveEventCallback("entitysleep", kraken.krakener_sleep_fn, kraken)
		kraken.krakener_sleep_fn = nil
	end

	self.kraken = nil
end

function Krakener:CanSpawn(ignore_cooldown)
	return (self:TimeUntilCanSpawn() <= 0 or ignore_cooldown) and not self.kraken and self.spawn_chance_mod > 0.0
end

function Krakener:TimeUntilCanSpawn()
	return math.max(self.respawn_timer - GetTime(), 0)
end

function Krakener:StartCooldown(timeoverride)
	self.respawn_timer = (timeoverride or self.appearance_cooldown * self.respawn_time_mod) + GetTime()
end

function Krakener:GetNearbySpawnPoint()
	local offset = FindWaterOffset(self.inst:GetPosition(), math.random() * 2 * math.pi, 40, 12)
	return (offset and (self.inst:GetPosition() + offset)) or nil
end

function Krakener:OnSave()
	local data = {}
	local references = {}

	if self.kraken then
		data.kraken = self.kraken.GUID
		table.insert(references, self.kraken.GUID)
	end

	data.appearance_timer = self:TimeUntilCanSpawn()

	data.spawn_chance_mod = self.spawn_chance_mod
	data.respawn_time_mod = self.respawn_time_mod

	return data, references
end

function Krakener:OnLoad(data)
	if data and data.appearance_timer then
		self.spawn_chance_mod = data.spawn_chance_mod or self.spawn_chance_mod
		self.respawn_time_mod = data.respawn_time_mod or self.respawn_time_mod
		self:StartCooldown(data.appearance_timer)
	end
end

function Krakener:LoadPostPass(ents, data)
	if data.kraken then
		local kraken = ents[data.kraken]
		if kraken then
			kraken = kraken.entity
			self:TakeOwnership(kraken)
		end
	end
end

function Krakener:SetChanceModifier(chance)
	self.spawn_chance_mod = chance or 1.0
end

function Krakener:SetCooldownModifier(respawn)
	--self.cooldown_mod = appear or 1.0
	self.respawn_mod = respawn or 1.0
end

function Krakener:GetDebugString()
	local s = ""
	s = s..string.format("\n-- Can Spawn In: %2.2f", self:TimeUntilCanSpawn() or 0)
	s = s..string.format("\n-- Kraken: %s - %s", tostring(self.kraken) or "NONE", (self.kraken and self.kraken.components.health:GetDebugString()) or "NONE")
	return s
end

return Krakener