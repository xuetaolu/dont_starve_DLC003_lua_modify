
local STATE_WAIT = 0
local STATE_WARN = 1
local STATE_MOVETOEDGE = 2
local STATE_MOVEFROMEDGE = 3
local STATE_MOVEEXTRA = 4

local MapWrapper = Class(function(self, inst)
	self.inst = inst
	self.state = STATE_WAIT

	self.edgefog = SpawnPrefab("edgefog")

	self.inst:StartUpdatingComponent(self)
end)

function MapWrapper:GetDistanceFromEdge(x, y, z)
	local map = GetWorld().Map
	local w, h = map:GetSize()
	local halfw, halfh = 0.5 * w * TILE_SCALE, 0.5 * h * TILE_SCALE
	local distx = math.min(x - -halfw, halfw - x)
	local distz = math.min(z - -halfh, halfh - z)
	assert(distx >= 0)
	assert(distz >= 0)
	local dist = math.min(distx, distz)
	return dist
end

local function printcoords(msg, x, y, z)
	if z then
		local tx, ty = GetWorld().Map:GetTileCoordsAtPoint(x, y, z)
		print(string.format("%s (%f, %f) (%f, %f, %f)", msg, tx, ty, x, y, z))
	else
		local w, h = GetWorld().Map:GetSize()
		local cx = (x - w/2.0) * TILE_SCALE
		local cz = (y - h/2.0) * TILE_SCALE
		print(string.format("%s (%f, %f) (%f, %f, %f)", msg, x, y, cx, 0, cz))
	end
end

local function line_intersect(x1, y1, x2, y2, x3, y3, x4, y4)
	-- from http://paulbourke.net/geometry/pointlineplane/
	local denom = (y4 - y3) * (x2 - x1) - (x4 - x3) * (y2 - y1)
	if denom == 0 then
		return nil, nil --parallel
	end
	local ua = ((x4 - x3) * (y1 - y3) - (y4 - y3) * (x1 - x3)) / denom
	local ub = ((x2 - x1) * (y1 - y3) - (y2 - y1) * (x1 - x3)) / denom
	if not (0 <= ua and ua <= 1 and 0 <= ub and ub <= 1) then
		return nil, nil --outside segments
	end
	--printcoords("intersect", x1 + ua * (x2 - x1), 0, y1 + ua * (y2 - y1))
	return x1 + ua * (x2 - x1), y1 + ua * (y2 - y1)
end

local function get_dest(inst, x1, y1, z1, rads, prints)
	local map = GetWorld().Map
	local w, h = map:GetSize()

	local dist = (TUNING.MAPWRAPPER_TELEPORT_RANGE + 2*TUNING.MAPWRAPPER_WARN_RANGE) * TILE_SCALE
	local x2, y2 = x1 + dist * math.cos(rads), z1 - dist * math.sin(rads)

	local width = (w - 2)*TILE_SCALE
	local height = (h - 2)*TILE_SCALE
	local right, top = width/2.0, height/2.0
	local left, bottom = -right, -top

	--printcoords("start", x1, y1, z1)
	--printcoords("proj", x2, 0, y2)

	local fx, fy
	local sx, sy
	fx, fy = line_intersect(x1, z1, x2, y2, left, top, right, top)
	if fx and fy then
		sx, sy = line_intersect(x1, z1, x2, y2, left, top, left, top + height)
		if sx and sy then
			--printcoords("dest tl", sx + width, 0, sy - height)
			return sx + width, 0, sy - height --top left
		end
		sx, sy = line_intersect(x1, z1, x2, y2, right, top, right, top + height)
		if sx and sy then
			--printcoords("dest tr", sx - width, 0, sy - height)
			return sx - width, 0, sy - height --top right
		end
		--printcoords("dest t", fx, 0, fy - height)
		return fx, 0, fy - height
	end

	fx, fy = line_intersect(x1, z1, x2, y2, left, bottom, right, bottom)
	if fx and fy then
		sx, sy = line_intersect(x1, z1, x2, y2, left, bottom, left, bottom - height)
		if sx and sy then
			--printcoords("dest bl", sx + left, 0, sy + height)
			return sx + left, 0, sy + height --bottom left
		end
		sx, sy = line_intersect(x1, z1, x2, y2, right, bottom, right, bottom - height)
		if sx and sy then
			--printcoords("dest br", sx - width, 0, sy + height)
			return sx - width, 0, sy + height --bottom right
		end
		--printcoords("dest b", fx, 0, fy + height)
		return fx, 0, fy + height
	end

	fx, fy = line_intersect(x1, z1, x2, y2, left, top, left, bottom)
	if fx and fy then
		sx, sy = line_intersect(x1, z1, x2, y2, left, top, left - width, top)
		if sx and sy then
			--printcoords("dest lt", sx + width, 0, sy - height)
			return sx + width, 0, sy - height --left top
		end
		sx, sy = line_intersect(x1, z1, x2, y2, left, bottom, left - width, bottom)
		if sx and sy then
			--printcoords("dest lb", sx + width, 0, sy + height)
			return sx, 0, sy + height --left bottom
		end
		--printcoords("dest l", fx + width, 0, fy)
		return fx + width, 0, fy
	end

	fx, fy = line_intersect(x1, z1, x2, y2, right, top, right, bottom)
	if fx and fy then
		sx, sy = line_intersect(x1, z1, x2, y2, right, top, right + width, top)
		if sx and sy then
			--printcoords("dest rt", sx - width, 0, sy - height)
			return sx - width, 0, sy - height --right top
		end
		sx, sy = line_intersect(x1, z1, x2, y2, right, bottom, right + width, bottom)
		if sx and sy then
			--printcoords("dest rb", sx - width, 0, sy + height)
			return sx - width, 0, sy + height --right bottom
		end
		--printcoords("dest r", fx - width, 0, fy)
		return fx - width, 0, fy
	end

	--print("no intersect?")
	return x1, y1, z1
end

local function get_angle(inst, x, y, z)
	local map = GetWorld().Map
	local w, h = map:GetSize()
	local halfw, halfh = 0.5 * w * TILE_SCALE, 0.5 * h * TILE_SCALE
	
	local dx, dz, dist = -halfw, z, x - -halfw
	if halfw - x < dist then
		dx, dz, dist = halfw, z, halfw - x
	end
	if z - -halfh < dist then
		dx, dz, dist = x, -halfh, z - -halfh
	end
	if halfh - z < dist then
		dx, dz, dist = x, halfh, halfh - z
	end

	local angle = -math.atan2(dz - z, dx - x)
	print("get_angle", dist, angle, angle / DEGREES, angle * DEGREES)
	return angle / DEGREES
end

local function get_angle2(x, y, z, rads)
	local map = GetWorld().Map
	local w, h = map:GetSize()
	local halfw, halfh = 0.5 * w * TILE_SCALE, 0.5 * h * TILE_SCALE
	
	--find closest edge
	--[[local dist = x - -halfw
	local x3, z3, x4, z4 = -halfw, halfh, -halfw, -halfh
	if halfw - x < dist then
		--dx, dz, dist = halfw, z, halfw - x
		x3, z3, x4, z4 = halfw, halfh, halfw, -halfh
	end
	if z - -halfh < dist then
		--dx, dz, dist = x, -halfh, z - -halfh
		x3, z3, x4, z4 = halfw, -halfh, -halfw, -halfh
	end
	if halfh - z < dist then
		--dx, dz, dist = x, halfh, halfh - z
		x3, z3, x4, z4 = halfw, halfh, -halfw, halfh
	end

	print("get_angle2 pos", x, z)
	print("get_angle2 edge", x3, z3, x4, z4)]]

	local function line_intersect_dist(x, y, x2, y2, x3, y3, x4, y4)
		local ix, iy = line_intersect(x, y, x2, y2, x3, y3, x4, y4)
		local d = 10000
		if ix and iy then
			ix, iy = ix - x, iy - y
			d = math.sqrt((ix*ix) + (iy*iy))
			--print("get_angle2 ray", d, x2, y2, ix + x, iy + y)
		end
		return d
	end

	local edges = {}
	table.insert(edges, {x3 = halfw, z3 = -halfh, x4 = halfw, z4 = halfh})
	table.insert(edges, {x3 = -halfw, z3 = -halfh, x4 = -halfw, z4 = halfh})
	table.insert(edges, {x3 = -halfw, z3 = halfh, x4 = halfw, z4 = halfh})
	table.insert(edges, {x3 = -halfw, z3 = -halfh, x4 = halfw, z4 = -halfh})

	--send a ray in 4 directions
	local dirs = {}
	local len = 2 * TUNING.MAPWRAPPER_WARN_RANGE * TILE_SCALE
	local dx, dz = len * math.cos(rads), len * math.sin(rads)
	--print("get_angle2 sincos", dx, dz, rads / DEGREES)
	table.insert(dirs, {x = dx, z = dz, rads = rads})
	table.insert(dirs, {x = - dz, z = dx, rads = rads + PI/2})
	table.insert(dirs, {x = - dx, z = - dz, rads = rads + PI})
	table.insert(dirs, {x = dz, z = - dx, rads = rads + 3*PI/2})
	--[[for i, v in ipairs(dirs) do
		print(string.format("get_angle2 dirs (%f,%f) deg=%f atan=%f", v.x, v.z, v.rads/DEGREES, math.atan2(v.z, v.x) / DEGREES))
	end]]

	local idx = 1
	local d = 10000
	for i = 1, #dirs, 1 do
		for j = 1, #edges, 1 do
			local newd = line_intersect_dist(x, z, x + dirs[i].x, z + dirs[i].z, edges[j].x3, edges[j].z3, edges[j].x4, edges[j].z4)
			--print("get_angle2", i, j, newd, dirs[i].rads / DEGREES, dirs[i].x, dirs[i].z)
			if newd < d and math.abs(newd - d) > 1.0 then
				d = newd
				idx = i
			end
		end
	end

	--print("get_angle2 return", dirs[idx].rads / DEGREES, math.atan2(dirs[idx].z, dirs[idx].x) / DEGREES)
	return dirs[idx].rads / DEGREES --math.atan2(dirs[idx].z, dirs[idx].x) / DEGREES
end

function MapWrapper:OnUpdate( dt )
	local map = GetWorld().Map
	local w, h = map:GetSize()
	local x, y, z = self.inst.Transform:GetLocalPosition()
	local tx, ty = map:GetTileCoordsAtPoint(x, y, z)

	local is_inrange = function(range)
		return (tx < range) or (w - tx < range) or (ty < range) or (h - ty < range)
	end

    local tile, tileinfo = self.inst:GetCurrentTileType(x, y, z)

	if tile == GROUND.INTERIOR then
		return
	end

	--if self.state ~= STATE_WAIT then print(string.format("%d (%d, %d) - (%d, %d)\n\t(%4.2f, %4.2f, %4.2f)\n", self.state, tx, ty, w, h, x, y, z)) end
	--local angle = self.inst.Transform:GetRotation()
	--print("angle", angle, angle * DEGREES)

	if self.state == STATE_WAIT then
		if is_inrange(TUNING.MAPWRAPPER_WARN_RANGE) then
			self.inst.components.talker:Say(GetString(self.inst.prefab, "ANNOUNCE_MAPWRAP_WARN"))
			self.state = STATE_WARN
		end

	elseif self.state == STATE_WARN then
		if not is_inrange(TUNING.MAPWRAPPER_WARN_RANGE) then
			self.state = STATE_WAIT
		elseif is_inrange(TUNING.MAPWRAPPER_LOSECONTROL_RANGE) then
			print("lose control", TUNING.MAPWRAPPER_LOSECONTROL_RANGE, self.inst.Transform:GetRotation())
			self.inst.components.talker:Say(GetString(self.inst.prefab, "ANNOUNCE_MAPWRAP_LOSECONTROL"))
			self.inst.components.health:SetInvincible(true)
			if TUNING.DO_SEA_DAMAGE_TO_BOAT and (self.inst.components.driver and self.inst.components.driver.vehicle and self.inst.components.driver.vehicle.components.boathealth) then
				self.inst.components.driver.vehicle.components.boathealth:SetInvincible(true)
			end


			--print("lose control get_angle2", -self.inst.Transform:GetRotation()*DEGREES, -self.inst.Transform:GetRotation())
			--local angle = get_angle2(x, y, z, -self.inst.Transform:GetRotation()*DEGREES)
			local angle = 0 
			local xDist = math.min(tx, math.abs(tx - w))
			local zDist = math.min(ty, math.abs(ty - h))
			
			if xDist < zDist then --horizontal (x)
				if x < 0 then 
					angle = 180
					self.warpdir = "left"
				else 
					angle = 0 
					self.warpdir = "right"
				end 
			else --vertical (z)
				if z < 0 then 
					angle = 90 
					self.warpdir = "down"
				else 
					angle = -90
					self.warpdir = "up"
				end 
			end 
			
			--self.inst.Transform:SetRotation(angle)
			--self.inst.components.locomotor:RunInDirection(angle)
			self.inst.components.locomotor:Stop(true)
			self.inst.components.locomotor:EnableGroundSpeedMultiplier(false)
			self.inst.components.playercontroller:Enable(false)
			self.inst.Transform:SetRotation(angle)
			self.inst.Physics:SetMotorVelOverride(TUNING.WILSON_RUN_SPEED, 0, 0)
			--self.inst.Physics:SetCollides(false)
			GetPlayer().HUD:Hide()
			TheFrontEnd:Fade(false, 6, nil, 1)
			self.state = STATE_MOVETOEDGE
		end

	elseif self.state == STATE_MOVETOEDGE then
		--print("move to egde", x, y, z, self.inst.Transform:GetRotation())
		--self.inst.components.locomotor:WalkForward()
		self.inst.Physics:SetMotorVelOverride(TUNING.WILSON_RUN_SPEED, 0, 0)
		if is_inrange(TUNING.MAPWRAPPER_TELEPORT_RANGE) then
			--print(string.format("run_test(%f, %f, %f, %f)", x, y, z, self.inst.Transform:GetRotation()))
			--local dx, dy, dz = get_dest(self.inst, x, y, z, self.inst.Transform:GetRotation() * DEGREES, true)
			local width = (w - 2)*TILE_SCALE
			local height = (h - 2)*TILE_SCALE
			local right, top = width/2.0, height/2.0
			local left, bottom = -right, -top

			local dx, dy, dz = x, y, z  

			if self.warpdir == "left" then 
				dx = right 
				dz = math.min(dz, top - (TUNING.MAPWRAPPER_GAINCONTROL_RANGE * 4 + 4))
				dz = math.max(dz, bottom + (TUNING.MAPWRAPPER_GAINCONTROL_RANGE * 4 + 4))
			elseif self.warpdir == "right" then 
				dx = left 
				dz = math.min(dz, top - (TUNING.MAPWRAPPER_GAINCONTROL_RANGE * 4 + 4))
				dz = math.max(dz, bottom + (TUNING.MAPWRAPPER_GAINCONTROL_RANGE * 4+ 4))
			elseif self.warpdir == "up" then 
				dz = bottom
				dx = math.min(dx, right - (TUNING.MAPWRAPPER_GAINCONTROL_RANGE*4 + 4))
				dx = math.max(dx, left + (TUNING.MAPWRAPPER_GAINCONTROL_RANGE*4 + 4))
			elseif self.warpdir == "down" then 
				dz = top
				dx = math.min(dx, right - (TUNING.MAPWRAPPER_GAINCONTROL_RANGE*4 + 4))
				dx = math.max(dx, left + (TUNING.MAPWRAPPER_GAINCONTROL_RANGE*4 + 4))
			end 

			print("teleport", dx, dy, dz, self.inst.Transform:GetRotation())
			self.inst.Transform:SetPosition(dx, dy, dz)
			if self.inst.components.driver and self.inst.components.driver.vehicle then 
				self.inst.components.driver.vehicle.Transform:SetPosition(dx, dy, dz)
			end 
			self.state = STATE_MOVEFROMEDGE
			self.inst:DoTaskInTime(2, function()
				TheFrontEnd:Fade(true, 6)
			end)
		end

	elseif self.state == STATE_MOVEFROMEDGE then
		--self.inst.components.locomotor:WalkForward()
		self.inst.Physics:SetMotorVelOverride(TUNING.WILSON_RUN_SPEED, 0, 0)

		if not is_inrange(TUNING.MAPWRAPPER_GAINCONTROL_RANGE) then
			print("gain control")
			GetPlayer().HUD:Show()
			if self.inst.components.sanity then
				self.inst.components.sanity:DoDelta(-TUNING.SANITY_MED)
			end
			self.inst.components.talker:Say(GetString(self.inst.prefab, "ANNOUNCE_MAPWRAP_RETURN"))
			--self.inst.components.locomotor:Clear()
			--self.inst.components.locomotor:StopMoving()
			self.inst.Physics:Stop()
			self.inst.components.locomotor:Stop()
			self.inst.components.locomotor:EnableGroundSpeedMultiplier(true)
			self.inst.components.health:SetInvincible(false)
			if TUNING.DO_SEA_DAMAGE_TO_BOAT and (self.inst.components.driver and self.inst.components.driver.vehicle and self.inst.components.driver.vehicle.components.boathealth) then
				self.inst.components.driver.vehicle.components.boathealth:SetInvincible(false)
			end
			self.inst.components.playercontroller:Enable(true)
			--self.inst.Physics:SetCollides(true)
			self.state = STATE_WARN
		end

	--[[elseif self.state == STATE_MOVEEXTRA then
		self.inst.components.locomotor:WalkForward()
		if not is_inrange(TUNING.MAPWRAPPER_GAINCONTROL_RANGE + 2) or self.inst.components.playercontroller:WalkButtonDown() then
			print("move extra")
			self.inst.components.locomotor:Clear()
			self.inst.components.locomotor:StopMoving()
			self.state = STATE_WARN
		end]]
	end
end

return MapWrapper