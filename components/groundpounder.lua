local GroundPounder = Class(function(self, inst)
    self.inst = inst

    self.numRings = 4
    self.ringDelay = 0.2
    self.initialRadius = 1
    self.radiusStepDistance = 4
    self.pointDensity = .25
    self.damageRings = 2
    self.destructionRings = 3
    self.noTags = {"FX", "NOCLICK", "DECOR", "INLIMBO", "groundpoundimmune"}
    self.destroyer = false
    self.burner = false
    self.groundpoundfx = "groundpound_fx"
    self.groundpoundringfx = "groundpoundring_fx"
    self.groundpounddamagemult = 1
    self.onfinished = nil
    self.ring_fx_scale = 1
end)

function GroundPounder:GetPoints(pt)
	local points = {}
	local radius = self.initialRadius

	for i = 1, self.numRings do
		local circ = 2*PI*radius
		local theta = math.random()*circ
		
		local numPoints = circ * self.pointDensity
		for p = 1, numPoints do

			if not points[i] then
				points[i] = {}
			end

			local offset = Vector3(radius * math.cos(theta), 0, -radius * math.sin(theta))
			local point = pt + offset

			table.insert(points[i], point)

			theta = theta - (2*PI/numPoints)
		end
		
		radius = radius + self.radiusStepDistance

	end
	return points
end

function GroundPounder:DestroyPoints(points, breakobjects, dodamage)
	local getEnts = breakobjects or dodamage

	for k,v in pairs(points) do

		local ents = nil
		if getEnts then
			ents = TheSim:FindEntities(v.x, v.y, v.z, 3, nil, self.noTags)
		end
		if ents and breakobjects then
		    -- first check to see if there's crops here, we want to work their farm
		    for k2,v2 in pairs(ents) do
		        if v2 and self.burner and v2.components.burnable and not v2:HasTag("fire") and not v2:HasTag("burnt") then
		        	v2.components.burnable:Ignite()
		        end
		    	-- Don't net any insects when we do work
		        if v2 and self.destroyer and v2.components.workable and v2.components.workable.workleft > 0 and v2.components.workable.action ~= ACTIONS.NET then
	        	    v2.components.workable:Destroy(self.inst)
			end
		        if v2 and self.destroyer and v2.components.crop then
			    	print("Has Crop:",v2)
	        	    v2.components.crop:ForceHarvest()
				end
		    end
		end
		if ents and dodamage then
		    for k2,v2 in pairs(ents) do
		    	if not self.ignoreEnts then 
		    		self.ignoreEnts = {}
		    	end 
		    	if not self.ignoreEnts[v2.GUID] then --If this entity hasn't already been hurt by this groundpound

			        if v2 and v2.components.health and not v2.components.health:IsDead() and 
			        self.inst.components.combat:CanTarget(v2) then
			            self.inst.components.combat:DoAttack(v2, nil, nil, nil, self.groundpounddamagemult)
			        end
			        self.ignoreEnts[v2.GUID] = true --Keep track of which entities have been hit 
			    end 
		    end
		end

		local map = GetMap()
		if map then
			local ground = map:GetTileAtPoint(v.x, 0, v.z)

			if ground == GROUND.IMPASSABLE or map:IsWater(ground) then
				--Maybe do some water fx here?
			else
				if self.groundpoundfx then 
					SpawnPrefab(self.groundpoundfx).Transform:SetPosition(v.x, 0, v.z)
				end 
			end
		end
		
	end
end

function GroundPounder:GroundPound(pt)
	local pt = pt or self.inst:GetPosition()
	local ground = GetMap():GetTileAtPoint(pt.x, 0, pt.z)

	if self.groundpoundringfx and not GetMap():IsWater(ground) then 
		local ring = SpawnPrefab(self.groundpoundringfx)
		ring.Transform:SetScale(self.ring_fx_scale, self.ring_fx_scale, self.ring_fx_scale)
		ring.Transform:SetPosition(pt:Get())
	end 
	local points = self:GetPoints(pt)
	local delay = 0
	self.ignoreEnts = nil 
	for i = 1, self.numRings do
		self.inst:DoTaskInTime(delay, function() 
			self:DestroyPoints(points[i], i <= self.destructionRings, i <= self.damageRings)
			if i == self.numRings and self.onfinished then
				self.onfinished(self.inst)
			end
		end)

		delay = delay + self.ringDelay
	end
end

return GroundPounder
