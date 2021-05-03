
local function OnAttacked(inst, data)
	-- print("BallphinFriend OnAttacked", data.attacker and data.attacker.prefab)
	if (math.random() < TUNING.BALLPHIN_FRIEND_CHANCE) and data.attacker and data.attacker.prefab == "crocodog" then
		local ballphinfriend = inst.components.ballphinfriend
		if ballphinfriend then
			ballphinfriend:HelpAgainst(data.attacker)
		end
	end
end

local BallphinFriend = Class(function(self, inst)
	self.inst = inst

	self.minDist = 30
	self.maxDist = 32

	self.timetospawn_variation = TUNING.FLOWER_SPAWN_TIME_VARIATION
	self.timetospawn = TUNING.FLOWER_SPAWN_TIME
	self.active = true
	
	self.spawntimer = self:GetSpawnTime()

	self.inst:ListenForEvent("boatattacked", OnAttacked)
	-- self.inst:ListenForEvent("boatattacked", function(inst, data) return self.boatover:Flash() end, self.owner)
	-- self.inst:ListenForEvent("rainstart", function() self:Enable(true) end)
	-- self.inst:ListenForEvent("rainstop", function() self:Enable(false) end)
end)

function BallphinFriend:GetSpawnTime()
	return self.timetospawn + (math.random() * self.timetospawn_variation)
end

function BallphinFriend:GetSpawnPoint(player)
	local pt = player:GetPosition()
	local theta = math.random() * 2 * PI
	local radius = math.random(self.minDist, self.maxDist)
	local steps = 8
	local ground = GetWorld()
	local validpos = {}
	for i = 1, steps do
		local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
		local try_pos = pt + offset
		if player:GetIsOnWater(try_pos:Get()) and #TheSim:FindEntities(try_pos.x, try_pos.y, try_pos.z, 1, nil, {"falling", "FX", "NOCLICK", "DECOR", "INLIMBO"}) <= 0 then
			table.insert(validpos, try_pos)
		end
		theta = theta - (2 * PI / steps)
	end
	if #validpos > 0 then
		local num = math.random(#validpos)
		return validpos[num]
	else
		return nil
	end
end

function BallphinFriend:SpawnBallphin(pt)
	local ballphin = SpawnPrefab("ballphin")
	ballphin.Transform:SetPosition(pt:Get())
	return ballphin
end

function BallphinFriend:HelpAgainst(attacker)
	print("BallphinFriend:HelpAgainst", attacker)
	local player = GetPlayer()
	local pt

	for i = 1, math.random(1, 4) do
		pt = self:GetSpawnPoint(player)
		
		if pt then
			local ballphin = self:SpawnBallphin(pt)
			if ballphin then
				ballphin:AddTag("ballphinfriend")
				ballphin.components.combat:SuggestTarget(attacker)
			end
		end
	end
end

function BallphinFriend:GetDebugString()
	return "Next spawn: "..tostring(self.spawntimer)
end

function BallphinFriend:OnSave()
	local data = {}
		data.spawntimer = self.spawntimer
		data.timetospawn = self.timetospawn
		data.timetospawn_variation = self.timetospawn_variation
		data.active = self.active
	return data
end

function BallphinFriend:OnLoad(data)
	if data then
		self.spawntimer = data.spawntimer
		self.timetospawn = data.timetospawn or TUNING.FLOWER_SPAWN_TIME
		self.timetospawn_variation = data.timetospawn_variation or TUNING.FLOWER_SPAWN_TIME_VARIATION
		self.active = data.active or true
		if not self.active then
			self.inst:StopUpdatingComponent(self)
		end
	end
end


return BallphinFriend
