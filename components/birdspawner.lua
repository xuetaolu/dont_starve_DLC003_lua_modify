local BirdSpawner = Class(function(self, inst)
    self.inst = inst
    self.inst:StartUpdatingComponent(self)
    self.birds = {}
    self.timetospawn = 0
    self.timetospawn_seagull = 0
    self.birdcap = 4
    self.spawntime = TUNING.BIRD_SPAWN_DELAY
    self.seagulspawn = true

	self.birdtypes = {}

	if SaveGameIndex:IsModeShipwrecked() then
		self.birdtypes = {
			--[GROUND.IMPASSABLE] = {bird = ""},
			--[GROUND.ROAD] = {"crow"},
			[GROUND.ROCKY] = {"toucan"},
			--[GROUND.DIRT] = {"crow"},
			[GROUND.SAVANNA] = {"parrot","toucan"},
			[GROUND.GRASS] = {"parrot"},
			[GROUND.FOREST] = {"toucan","parrot"},
			[GROUND.MARSH] = {"toucan"},
			[GROUND.BEACH]	= {"toucan"},
			[GROUND.JUNGLE]	= {"parrot"},
			[GROUND.SNAKESKIN]	= {"toucan","parrot"},
			[GROUND.MANGROVE_SHORE]	= {"seagull_water"},
			[GROUND.OCEAN_SHALLOW]	= {"seagull_water"},
			[GROUND.OCEAN_CORAL]	= {"seagull_water"},
			[GROUND.OCEAN_CORAL_SHORE]	= {"seagull_water"},
			[GROUND.OCEAN_MEDIUM]	= {"seagull_water"},
			[GROUND.OCEAN_DEEP]	= {"seagull_water"},
			[GROUND.OCEAN_SHIPGRAVEYARD]	= {"seagull_water"},
			[GROUND.INTERIOR] = {},
		}
	else
		-- Note: in winter, 'robin' is replaced with 'robin_winter' automatically
		self.birdtypes = {
			[GROUND.ROCKY] = {"crow"},
			[GROUND.DIRT] = {"crow"},
			[GROUND.SAVANNA] = {"robin","crow"},
			[GROUND.GRASS] = {"robin"},
			[GROUND.FOREST] = {"robin","crow"},
			[GROUND.MARSH] = {"crow"},

			[GROUND.RAINFOREST]	= {"toucan","kingfisher","parrot_blue"},
			[GROUND.DEEPRAINFOREST]	= {"parrot_blue","kingfisher"},
			[GROUND.GASJUNGLE]	= {"parrot_blue"},			
			[GROUND.FOUNDATION] = {"pigeon","pigeon_swarm","pigeon_swarm","crow"},
			[GROUND.FIELDS] = {"robin","crow"},
			[GROUND.SUBURB] = {"robin","crow","pigeon"},
			[GROUND.PLAINS] = {"robin","crow","kingfisher"},
			[GROUND.PAINTED] =  {"kingfisher","crow"},
			[GROUND.BATTLEGROUND] = {},
			[GROUND.INTERIOR] = {},
			[GROUND.LILYPOND] = {},
		}
	end

end)

function BirdSpawner:GetDebugString()
    return string.format("Birds: %d/%d", GetTableSize(self.birds), self.birdcap)
end

function BirdSpawner:SetSpawnTimes(times)
    self.spawntime = times
end

function BirdSpawner:SetMaxBirds(max)
    self.birdcap = max
end

function BirdSpawner:StartTracking(inst)
    inst.persists = false

    self.birds[inst] = function()
    	--[[
			Delayed the remove on "entitysleep" here. It was causing an issue when picking
			up a bird that was being tracked.

			When adding something to your inventory the "entitysleep" event [which removes the bird]
			fires before the "enterlimbo" event [which stops tracking the bird].

			This caused the bird to be deleted before we could stop tracking it.
    	--]]

		inst.bs_entity_wake_fn = function()
			self.inst:RemoveEventCallback("entitywake", inst.bs_entity_wake_fn, inst)
			inst.bs_sleep_remove_task:Cancel()
		end

		self.inst:ListenForEvent("entitywake", inst.bs_entity_wake_fn, inst)

    	inst.bs_sleep_remove_task = inst:DoTaskInTime(1, function()
		    if self.birds[inst] then
		        inst:Remove()
		    end
	    end)
	end

	self.inst:ListenForEvent("entitysleep", self.birds[inst], inst)
end

function BirdSpawner:StopTracking(inst)
    inst.persists = true
    if self.birds[inst] then
		self.inst:RemoveEventCallback("entitysleep", self.birds[inst], inst)

		if inst.bs_entity_wake_fn then
			inst.bs_entity_wake_fn()
		end

		self.birds[inst] = nil
    end
end

function BirdSpawner:IsLandableTileType(ground)
	return not (ground == GROUND.IMPASSABLE or ground == 255 or ground == GROUND.OCEAN_SHORE)
end

function BirdSpawner:IsWaterTileType(ground)
	return (ground == GROUND.OCEAN_SHALLOW or ground == GROUND.OCEAN_MEDIUM or ground == GROUND.OCEAN_DEEP or ground == GROUND.OCEAN_SHORE or ground == GROUND.OCEAN_CORAL or ground == GROUND.MANGROVE or ground == GROUND.OCEAN_CORAL_SHORE or ground == GROUND.MANGROVE_SHORE or ground == GROUND.OCEAN_SHIPGRAVEYARD)
end

function BirdSpawner:GetSpawnPoint(pt)

    local theta = math.random() * 2 * PI
    local radius = 6+math.random()*6

	-- we have to special case this one because birds can't land on creep (or floods)
	local result_offset = FindValidPositionByFan(theta, radius, 12, function(offset)

        local ground = GetWorld()
        local spawn_point = pt + offset
        local tile = self.inst:GetCurrentTileType(spawn_point.x, spawn_point.y, spawn_point.z)

        if not (ground.Map and ground.Map:GetTileAtPoint(spawn_point.x, spawn_point.y, spawn_point.z) == GROUND.IMPASSABLE)
           and not ground.GroundCreep:OnCreep(spawn_point.x, spawn_point.y, spawn_point.z)
           and not (ground.Flooding and ground.Flooding:OnFlood(spawn_point.x, spawn_point.y, spawn_point.z))
           and self:IsLandableTileType(tile) then
           	if self.inst:IsPosSurroundedByLand(spawn_point.x, spawn_point.y, spawn_point.z, 3) or
                self.inst:IsPosSurroundedByWater(spawn_point.x, spawn_point.y, spawn_point.z, 3) then
            	return true
            end
        end

		return false
    end)


	if result_offset then
		local spawn_point = pt + result_offset
		return spawn_point
	end
end


function BirdSpawner:GetAquaticSpawnPoint(pt)

    local theta = math.random() * 2 * PI
    local radius = 6+math.random()*6

	-- we have to special case this one because birds can't land on creep (or floods)
	local result_offset = FindValidPositionByFan(theta, radius, 12, function(offset)
		local ground = GetWorld()
        local spawn_point = pt + offset
        local tile = self.inst:GetCurrentTileType(spawn_point.x, spawn_point.y, spawn_point.z)
        if not (ground.Map and ground.Map:GetTileAtPoint(spawn_point.x, spawn_point.y, spawn_point.z) == GROUND.IMPASSABLE)
           and not ground.GroundCreep:OnCreep(spawn_point.x, spawn_point.y, spawn_point.z)
           and not (ground.Flooding and ground.Flooding:OnFlood(spawn_point.x, spawn_point.y, spawn_point.z))
           and self:IsWaterTileType(tile) then
           	if self.inst:IsPosSurroundedByWater(spawn_point.x, spawn_point.y, spawn_point.z, 3) then
            	return true
            end
        end
		return false
    end)

	if result_offset then
		local spawn_point = pt + result_offset
		return spawn_point
	end
end


function BirdSpawner:PickBird(spawn_point)

    local ground = GetWorld()
    if ground and ground.Map then
        local tile = ground.Map:GetTileAtPoint(spawn_point.x, spawn_point.y, spawn_point.z)

		if GetWorld().components.seasonmanager:IsWetSeason() then
			if tile == GROUND.BEACH and self.seagulspawn then
				return "seagull"
			else
				return nil
			end
		end

		local default_bird = "crow"
		if SaveGameIndex:IsModeShipwrecked() then
			default_bird = nil
		end

		if self.birdtypes[tile] then
			local bird = GetRandomItem(self.birdtypes[tile])

			if bird == "parrot" and math.random() < TUNING.PARROT_PIRATE_CHANCE then
				bird = "parrot_pirate"
			end

			if ground.components.seasonmanager:IsWinter() and bird == "robin" then
				bird = "robin_winter"
			end

			if tile == GROUND.INTERIOR then
				bird = nil
			end

			return bird
		else		
			return default_bird
		end

    end
end

function BirdSpawner:DangerNearby(pt)
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 8, {"scarytoprey"})
    return next(ents) ~= nil
end


function BirdSpawner:SpawnAquaticBird(spawn_point, ignore_bait)
	local prefab = "seagull_water"
	local bird = SpawnPrefab(prefab)
	 if math.random() < .5 then
	    bird.Transform:SetRotation(180)
    end

    if bird:HasTag("bird") then
        spawn_point.y = 15
    end
    if bird.components.eater and not ignore_bait then
        local bait = TheSim:FindEntities(spawn_point.x, 0, spawn_point.z, 15, nil,  {"falling", "FX", "NOCLICK", "DECOR", "INLIMBO", "hydrofarm"})
        for k,v in pairs(bait) do
	        if bird.components.eater:CanEat(v)
	           and v.components.bait
	           and not (v.components.inventoryitem and v.components.inventoryitem:IsHeld())
	           and not self:DangerNearby(Vector3(v.Transform:GetWorldPosition() ) ) then
		        local target_pos = Vector3(v.Transform:GetWorldPosition() )
		        spawn_point = Vector3(target_pos.x, spawn_point.y, target_pos.z)
		        bird.bufferedaction = BufferedAction(bird, v, ACTIONS.EAT)
		        break
	        elseif v.components.trap
	               and v.components.trap.isset
	               and (not v.components.trap.targettag or bird:HasTag(v.components.trap.targettag) )
	               and not v.components.trap.issprung
	               and math.random() < TUNING.BIRD_TRAP_CHANCE
				   and not self:DangerNearby(Vector3(v.Transform:GetWorldPosition() ) ) then
		        local target_pos = Vector3(v.Transform:GetWorldPosition() )
		        spawn_point = Vector3(target_pos.x, spawn_point.y, target_pos.z)
		        break
	        end
        end
    end
    bird.Physics:Teleport(spawn_point.x,spawn_point.y,spawn_point.z)
    return bird

end

function BirdSpawner:SpawnBird(spawn_point, ignore_bait, bird_name)
    local prefab = self:PickBird(spawn_point)

    if bird_name and prefab and (bird_name ~= prefab) then
    	return
    end

	if prefab then
	    local bird = SpawnPrefab(prefab)
	    if math.random() < .5 then
		    bird.Transform:SetRotation(180)
	    end

	    if bird:HasTag("bird") then
	        spawn_point.y = 15
	    end
	    --see if there's bait nearby that we might spawn into
	    if bird.components.eater and not ignore_bait then
	        local bait = TheSim:FindEntities(spawn_point.x, 0, spawn_point.z, 15, nil, {"falling", "FX", "NOCLICK", "DECOR", "INLIMBO", "hydrofarm"})
	        for k,v in pairs(bait) do
	        	if prefab == "seagull"
	        	   and bird.components.eater:CanEat(v)
		           and not (v.components.inventoryitem and v.components.inventoryitem:IsHeld()) then
		            local target_pos = Vector3(v.Transform:GetWorldPosition() )
					local prefab_at_target = self:PickBird(target_pos)
					if prefab == prefab_at_target then
				        spawn_point = Vector3(target_pos.x, spawn_point.y, target_pos.z)
				        bird.bufferedaction = BufferedAction(bird, v, ACTIONS.EAT)
					end
			        break

			    elseif prefab == "seagull"
	        	   and v.components.pickable
	        	   and v.components.pickable.product == "limpets"
	        	   and v.components.pickable.canbepicked then
		            local target_pos = Vector3(v.Transform:GetWorldPosition() )
		            local angle = math.random(0,360)
        			local offset = FindWalkableOffset(target_pos, angle*DEGREES, math.random()+0.5, 4, false, false)

					local prefab_at_target = self:PickBird(target_pos + offset)
					if prefab == prefab_at_target then
				        spawn_point = Vector3(target_pos.x, spawn_point.y, target_pos.z) + offset
						bird.bufferedaction = BufferedAction(bird, v, ACTIONS.PICK)
					end
			        
			        break

		        elseif bird.components.eater:CanEat(v)
		           and v.components.bait
		           and not (v.components.inventoryitem and v.components.inventoryitem:IsHeld())
		           and not self:DangerNearby(Vector3(v.Transform:GetWorldPosition() ) ) then
			        local target_pos = Vector3(v.Transform:GetWorldPosition() )

					local prefab_at_target = self:PickBird(target_pos)
					if prefab == prefab_at_target then
				        spawn_point = Vector3(target_pos.x, spawn_point.y, target_pos.z)
						bird.bufferedaction = BufferedAction(bird, v, ACTIONS.EAT)
					end

			        break

		        elseif v.components.trap
		               and v.components.trap.isset
		               and (not v.components.trap.targettag or bird:HasTag(v.components.trap.targettag) )
		               and not v.components.trap.issprung
		               and math.random() < TUNING.BIRD_TRAP_CHANCE
					   and not self:DangerNearby(Vector3(v.Transform:GetWorldPosition() ) ) then
			        local target_pos = Vector3(v.Transform:GetWorldPosition())
					local prefab_at_target = self:PickBird(target_pos)
					if prefab == prefab_at_target then
				        spawn_point = Vector3(target_pos.x, spawn_point.y, target_pos.z)
					end

			        break
		        end
	        end
	    end

	    bird.Physics:Teleport(spawn_point.x,spawn_point.y,spawn_point.z)
	    return bird
	end
end

function BirdSpawner:OnUpdate( dt )

	local maincharacter = GetPlayer()
    local night = GetClock():IsNight()
	local vm = GetVolcanoManager()

	if maincharacter and not night and (vm == nil or not vm:IsErupting()) then

		if self.timetospawn > 0 then
			if GetSeasonManager():IsRaining() then
				self.timetospawn = self.timetospawn - dt*TUNING.BIRD_RAIN_FACTOR
			else
				self.timetospawn = self.timetospawn - dt
			end
		end

		if self.timetospawn <= 0 and GetTableSize(self.birds) < self.birdcap then

			
            local char_pos = Vector3(maincharacter.Transform:GetWorldPosition())
			local spawn_point = self:GetSpawnPoint(char_pos)
			if spawn_point then

				if not maincharacter:GetIsOnWater() or math.random() < 0.4 then
	                local bird = self:SpawnBird(spawn_point)
	                if bird then
	                    self:StartTracking(bird)
					end
				end
				if self.spawntime and self.spawntime.min and self.spawntime.max then
			    	self.timetospawn = GetRandomMinMax(self.spawntime.min, self.spawntime.max)
				end
			end

		end

		if GetWorld().components.seasonmanager:IsWetSeason() then
			if self.timetospawn_seagull > 0 then
				self.timetospawn_seagull = self.timetospawn_seagull - dt
			end

			if self.timetospawn_seagull <= 0 and GetTableSize(self.birds) < self.birdcap then
	            local char_pos = Vector3(maincharacter.Transform:GetWorldPosition())
				local spawn_point = self:GetSpawnPoint(char_pos)
				if spawn_point then
	                local bird = self:SpawnBird(spawn_point, nil, "seagull")
	                if bird then
	                    self:StartTracking(bird)
					end
					if self.spawntime and self.spawntime.min and self.spawntime.max then
					    self.timetospawn_seagull = GetRandomMinMax(self.spawntime.min/2, self.spawntime.max/2)
					end
				end
			end
		end
	end
end

function BirdSpawner:OnSave()
	return
	{
		timetospawn = self.timetospawn,
    	birdcap = self.birdcap,
	}
end

function BirdSpawner:OnLoad(data)
	self.timetospawn = data.timetospawn or 10
	self.birdcap = data.birdcap or 4
	if self.birdcap <= 0 then
		self.inst:StopUpdatingComponent(self)
	end
end

function BirdSpawner:SeagulSpawnModeNever()
	self.seagulspawn = false
end

function BirdSpawner:SpawnModeNever()
	self.timetospawn = -1
    self.birdcap = 0
    self.inst:StopUpdatingComponent(self)
end

function BirdSpawner:SpawnModeHeavy()
	self.timetospawn = 3
    self.birdcap = 10
end

function BirdSpawner:SpawnModeMed()
	self.timetospawn = 6
    self.birdcap = 7
end

function BirdSpawner:SpawnModeLight()
	self.timetospawn = 20
    self.birdcap = 2
end

return BirdSpawner
