local player = nil
local world = nil
local ceiling = nil
function GetPlayer()
    if not player then
        player = TheSim:FindFirstEntityWithTag("player")
    end
    return player
end
function GetWorld()
    if not world then
        world = TheSim:FindFirstEntityWithTag("ground")
    end
    return world
end
function GetCeiling()
    if not ceiling then
        ceiling = TheSim:FindFirstEntityWithTag("ceiling")
    end
    return ceiling
end

function GetWorldComponent(component)
    local world = GetWorld()
    if world and world.components then
        return world.components[component]
    end
end

function GetMap() if GetWorld() then return GetWorld().Map end end
function GetClock()           return GetWorldComponent("clock") end
function GetNightmareClock()  return GetWorldComponent("nightmareclock") end
function GetSeasonManager()   return GetWorldComponent("seasonmanager") end
function GetMoistureManager() return GetWorldComponent("moisturemanager") end
function GetVolcanoManager()  return GetWorldComponent("volcanomanager") end
function GetRainbowJellyMigrationManager() return GetWorldComponent("rainbowjellymigration") end
function GetAporkalypse()     return GetWorldComponent("aporkalypse") end
function GetInteriorSpawner() return GetWorldComponent("interiorspawner") end

function FindEntity(inst, radius, fn, musttags, canttags, mustoneoftags)
    if inst and inst:IsValid() then
		local x,y,z = inst.Transform:GetWorldPosition()

		--print ("FIND", inst, radius, musttags and #musttags or 0, canttags and #canttags or 0, mustoneoftags and #mustoneoftags or 0)
		local ents = TheSim:FindEntities(x,y,z, radius, musttags, canttags, mustoneoftags) -- or we could include a flag to the search?
		for k, v in pairs(ents) do
			if v ~= inst and v:IsValid() and v.entity:IsVisible() and (not fn or fn(v, inst)) then
				return v
			end
		end
	end
end

function GetRandomInstWithTag(tag, inst, radius)
    local trans = inst.Transform
    local tags = (type(tag)=="string" and {tag}) or tag
    local x,y,z = trans:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, radius, tags)
    if #ents > 0 then
        return ents[math.random(1,#ents)]
    else
        return nil
    end
end

function GetClosestInstWithTag(tag, inst, radius)
    local trans = inst.Transform
    local tags = {tag}
    local x,y,z = trans:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, radius, tags)
    for k,v in pairs(ents) do
        if v ~= inst then return v end
    end
end

function GetClosestWithName(inst, name, radius)
    local trans = inst.Transform
    local x,y,z = trans:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, radius)

    for k,v in pairs(ents) do
        --print (v.prefab, name)
        if v ~= inst and v.prefab == name then 
            return v 
        end
    end 
end

function DeleteCloseEntsWithTag(inst, tag, distance)
    local trans = inst.Transform
    local tags = {tag}
    local x,y,z = trans:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, distance, tags)
    --print("Found", GetTableSize(ents), "close",tag,"things")
    for k,v in pairs(ents) do
       -- print("\n Removing", v)
        v:Remove()
    end
end

function GetVisualTileType(ptx,pty,ptz)

    if GetWorld().Map then

        if(ptx == nil or ptz == nil) then
            print(debug.traceback())
        end
        assert(ptx ~= nil and ptz ~= nil, "trying to get tiletype for a nil position!")


        local tilecenter_x, tilecenter_y,tilecenter_z  = GetWorld().Map:GetTileCenterPoint(ptx,0,ptz)
        local tx, ty = GetWorld().Map:GetTileCoordsAtPoint(ptx, 0, ptz)
        local actual_tile = GetWorld().Map:GetTile(tx, ty)

        if actual_tile and tilecenter_x and tilecenter_z then
            local xpercent = (tilecenter_x - ptx)/TILE_SCALE + .5
            local ypercent = (tilecenter_z - ptz)/TILE_SCALE + .5

            local x_off = 0
            local y_off = 0

            local x_min = 0
            local x_max = 0
            local y_min = 0
            local y_max = 0

            if actual_tile == GROUND.IMPASSABLE or not GetWorld().Map:IsWater(actual_tile) then

                if xpercent < .25 then
                    x_max = 1

                elseif xpercent > .75 then
                    x_min = -1
                end

                if ypercent < .25 then
                    y_max = 1

                elseif ypercent > .75 then
                    y_min = -1
                end

                for x = x_min, x_max do
                    for y = y_min, y_max do
                        local tile = GetWorld().Map:GetTile(tx + x, ty + y)
                        -- this will return the largest of the two tile types. Slight caveat, water tiles should always be higher than land tiles
                        local higher = false
                        if GetWorld().Map:IsWater(tile) and GetWorld().Map:IsLand(actual_tile) then
                            higher = true
                        elseif GetWorld().Map:IsLand(tile) and GetWorld().Map:IsWater(actual_tile) then
							higher = false
                        else
                            higher = tile > actual_tile
                        end
                        if higher then 
                            actual_tile = tile
                            x_off = x
                            y_off = y
                        end
                    end
                end
            end

            return actual_tile, GetTileInfo(actual_tile)
        end
    end
    return GROUND.IMPASSABLE, GetTileInfo(GROUND.IMPASSABLE)

end


function fadeout(inst, time)

    local mult = 1
    local ticktime = GetTickTime()

    local r,g,b,a = inst.AnimState:GetMultColour()
    local delta = ticktime/time
    while mult > 0 do
        inst.AnimState:SetMultColour(r,g,b,mult)
        Yield()
        mult = mult - delta
    end
    inst.AnimState:SetMultColour(r,g,b,0)
    inst:PushEvent("fadecomplete")
end

function PlayFX(position, bank, build, anim, sound, sounddelay, tint, tintalpha)
	--[[
    local inst = CreateEntity()


    inst:AddTag("FX")
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.Transform:SetPosition(position.x,position.y,position.z)
    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation(anim)
    inst:ListenForEvent("animover", function(inst) inst:Remove() end)
    if sound then
		inst.entity:AddSoundEmitter()

		if sounddelay then
			inst:DoTaskInTime(sounddelay, function() inst.SoundEmitter:PlaySound(sound) end)
		else
			inst.SoundEmitter:PlaySound(sound)
		end
    end
    if tint then
		inst.AnimState:SetMultColour(tint.x,tint.y,tint.z,tintalpha or 1)
    end

    return inst
    --]]
    return nil
end



function AnimateUIScale(item, total_time, start_scale, end_scale)
    item:StartThread(
    function()
        local scale = 1
        local time_left = total_time
        local start_time = GetTime()
        local end_time = start_time + total_time
        local transform = item.UITransform
        while true do
            local t = GetTime()

            local percent = (t - start_time) / total_time
            if percent > 1 then
                transform:SetScale(end_scale, end_scale, end_scale)
                return
            end
            local scale = (1 - percent)*start_scale + percent*end_scale
            transform:SetScale(scale, scale, scale)
            Yield()
        end
    end)
end



function GetGroundTypeAtPosition(pt)
    local ground = GetWorld()
    local tile = GROUND.GRASS

    if ground and ground.Map then
        tile = ground.Map:GetTileAtPoint(pt.x,pt.y,pt.z)
    end
	return tile

end

-- Use this function to fan out a search for a point that meets a condition.
-- If your condition is basically "walkable ground" use FindWalkableOffset instead.
-- test_fn takes a parameter "offset" which is check_angle*radius.
function FindValidPositionByFan(start_angle, radius, attempts, test_fn)
	local theta = start_angle -- radians

	attempts = attempts or 8

	local attempt_angle = (2*PI)/attempts
	local tmp_angles = {}
	for i=0,attempts-1 do
		local a = i*attempt_angle
		if a > PI then
			a = a-(2*PI)
		end
		table.insert(tmp_angles, a)
	end

	-- Make the angles fan out from the original point
	local angles = {}
	for i=1,math.ceil(attempts/2) do
		table.insert(angles, tmp_angles[i])
		local other_end = #tmp_angles - (i-1)
		if other_end > i then
			table.insert(angles, tmp_angles[other_end])
		end
	end


    --print("FindValidPositionByFan")

	for i, attempt in ipairs(angles) do
		local check_angle = theta + attempt
		if check_angle > 2*PI then check_angle = check_angle - 2*PI end

		local offset = Vector3(radius * math.cos( check_angle ), 0, -radius * math.sin( check_angle ))

        --print(string.format("    %2.2f", check_angle/DEGREES))

		if test_fn(offset) then
			local deflected = i > 1
            --print(string.format("    OK on try %u", i))
			return offset, check_angle, deflected
		end
	end
end

-- This function fans out a search from a starting position/direction and looks for a walkable
-- position, and returns the valid offset, valid angle and whether the original angle was obstructed.
function FindWalkableOffset(position, start_angle, radius, attempts, check_los, ignore_walls)
	--print("FindWalkableOffset:")

    if ignore_walls == nil then
        ignore_walls = true
    end

	local test = function(offset)
		local run_point = position+offset
		local ground = GetWorld()
		local tile = GetVisualTileType(run_point.x, run_point.y, run_point.z) --ground.Map:GetTileAtPoint(run_point.x, run_point.y, run_point.z)
		if tile == GROUND.IMPASSABLE or tile == GROUND.OCEAN_SHORE or tile == GROUND.OCEAN_CORAL_SHORE or tile == GROUND.MANGROVE_SHORE or tile >= GROUND.UNDERGROUND then
			--print("\tfailed, unwalkable ground.")
			return false
		end
		if check_los and not ground.Pathfinder:IsClear(position.x, position.y, position.z,
		                                                 run_point.x, run_point.y, run_point.z,
		                                                 {ignorewalls = ignore_walls, ignorecreep = true}) then
			--print("\tfailed, no clear path.")
			return false
		end
		--print("\tpassed.")
		return true

	end

	return FindValidPositionByFan(start_angle, radius, attempts, test)
end

-- Only looks for ground, not water.
function FindGroundOffset(position, start_angle, radius, attempts, check_los, ignore_walls)
    --print("FindWalkableOffset:")

    if ignore_walls == nil then
        ignore_walls = true
    end

    local test = function(offset)
        local run_point = position+offset
        local ground = GetWorld()
        local tile = GetVisualTileType(run_point.x, run_point.y, run_point.z)
        if tile == GROUND.IMPASSABLE or tile == GROUND.OCEAN_SHORE or tile >= GROUND.UNDERGROUND or
        tile == GROUND.OCEAN_SHALLOW or tile == GROUND.OCEAN_MEDIUM or tile == GROUND.OCEAN_DEEP or
        tile == GROUND.OCEAN_CORAL or tile == GROUND.MANGROVE or tile == GROUND.OCEAN_CORAL_SHORE or
        tile == GROUND.MANGROVE_SHORE or tile == GROUND.OCEAN_SHIPGRAVEYARD or tile == GROUND.LILYPOND then
            --print("\tfailed, unwalkable ground.")
            return false
        end
        if check_los and not ground.Pathfinder:IsClear(position.x, position.y, position.z,
                                                         run_point.x, run_point.y, run_point.z,
                                                         {ignorewalls = ignore_walls, ignorecreep = true}) then
            --print("\tfailed, no clear path.")
            return false
        end
        --print("\tpassed.")
        return true

    end

    return FindValidPositionByFan(start_angle, radius, attempts, test)
end

-- looks for ground, when it finds a point, checks a radius around that point to make sure they're all ground as well
-- (pathfinding isn't granular enough, and chamfered corners can return the tiletype they belong to, but technically player will be outside it)
function FindValidExitPoint(position, start_angle, radius, attempts, subradius)
    --print("FindWalkableOffset:")
	local theta = start_angle -- radians

	attempts = attempts or 8

	local attempt_angle = (2*PI)/attempts
	local tmp_angles = {}
	for i=0,attempts-1 do
		local a = i*attempt_angle
		if a > PI then
			a = a-(2*PI)
		end
		table.insert(tmp_angles, a)
	end

	-- Make the angles fan out from the original point
	local angles = {}
	for i=1,math.ceil(attempts/2) do
		table.insert(angles, tmp_angles[i])
		local other_end = #tmp_angles - (i-1)
		if other_end > i then
			table.insert(angles, tmp_angles[other_end])
		end
	end

    local test = function(offset)
        local run_point = position+offset
        local ground = GetWorld()
        local tile = GetVisualTileType(run_point.x, run_point.y, run_point.z)
        if tile == GROUND.IMPASSABLE or tile == GROUND.OCEAN_SHORE or tile >= GROUND.UNDERGROUND or
        tile == GROUND.OCEAN_SHALLOW or tile == GROUND.OCEAN_MEDIUM or tile == GROUND.OCEAN_DEEP or
        tile == GROUND.OCEAN_CORAL or tile == GROUND.MANGROVE or tile == GROUND.OCEAN_CORAL_SHORE or
        tile == GROUND.MANGROVE_SHORE or tile == GROUND.OCEAN_SHIPGRAVEYARD or tile == GROUND.LILYPOND then
            --print("\tfailed, unwalkable ground.")
            return false
        end

		for i, attempt in ipairs(angles) do
			local check_angle = theta + attempt
			if check_angle > 2*PI then check_angle = check_angle - 2*PI end

			local offset = Vector3(subradius * math.cos( check_angle ), 0, -subradius * math.sin( check_angle ))

        	--print(string.format("    %2.2f", check_angle/DEGREES))
	        local subtest = run_point+offset

	        local tile = GetVisualTileType(subtest.x, subtest.y, subtest.z)
    	    if tile == GROUND.IMPASSABLE or tile == GROUND.OCEAN_SHORE or tile >= GROUND.UNDERGROUND or
		        tile == GROUND.OCEAN_SHALLOW or tile == GROUND.OCEAN_MEDIUM or tile == GROUND.OCEAN_DEEP or
		        tile == GROUND.OCEAN_CORAL or tile == GROUND.MANGROVE or tile == GROUND.OCEAN_CORAL_SHORE or
		        tile == GROUND.MANGROVE_SHORE or tile == GROUND.OCEAN_SHIPGRAVEYARD or tile == GROUND.LILYPOND then
        	    --print("\tfailed, unwalkable ground.")
	            return false
    	    end
		end

        return true

    end

    return FindValidPositionByFan(start_angle, radius, attempts, test)
end

-- Only looks for water, not ground.
function FindWaterOffset(position, start_angle, radius, attempts, check_los, ignore_walls)

    if ignore_walls == nil then
        ignore_walls = true
    end

    local test = function(offset)
        local run_point = position+offset
        local ground = GetWorld()
        local tile = GetVisualTileType(run_point.x, run_point.y, run_point.z)

        if tile ~= GROUND.OCEAN_SHALLOW and tile ~= GROUND.OCEAN_MEDIUM and tile ~= GROUND.OCEAN_DEEP and
        tile ~= GROUND.OCEAN_CORAL and tile ~= GROUND.MANGROVE and tile ~= GROUND.OCEAN_SHIPGRAVEYARD then
            return false
        end
        if check_los and not ground.Pathfinder:IsClear(position.x, position.y, position.z,
                                                         run_point.x, run_point.y, run_point.z,
                                                         {ignorewalls = ignore_walls, ignorecreep = true}) then
            return false
        end
        return true

    end

    return FindValidPositionByFan(start_angle, radius, attempts, test)
end




--[[ FROM DST ]]
local function _CanEntitySeeInStorm(inst)
    if inst.components.playervision ~= nil then
        --component available on clients as well,
        --but only accurate for your local player
        return inst.components.playervision:HasGoggleVision()
    end
    local inventory = inst.replica.inventory
    return inventory ~= nil and inventory:EquipHasTag("goggles")
end

function CanEntitySeeInStorm(inst)
    return inst ~= nil and inst:IsValid() and _CanEntitySeeInStorm(inst)
end

local function _GetEntitySandstormLevel(inst)
    --NOTE: GetSandstormLevel is available on players on server
    --      and clients, but only accurate for local players.
    --      stormwatcher is a server-side component.
    return (inst.GetSandstormLevel ~= nil and inst:GetSandstormLevel())
        or (inst.components.stormwatcher ~= nil and inst.components.stormwatcher.sandstormlevel)
        or 0
end

local function _CanEntitySeeInDark(inst)
    local inventory = inst.components.inventory
    return inventory ~= nil and inventory:EquipHasTag("nightvision")
end

function CanEntitySeePoint(inst, x, y, z)
    return inst ~= nil
        and inst:IsValid()
        and (TheSim:GetLightAtPoint(x, y, z) > TUNING.DARK_CUTOFF or
            _CanEntitySeeInDark(inst))
end

function CanEntitySeeTarget(inst, target)
    if target == nil or not target:IsValid() then
        return false
    end
    local x, y, z = target.Transform:GetWorldPosition()
    return CanEntitySeePoint(inst, x, y, z)
end
-- [[ END FROM DST]]


function CheckLOSFromPoint(pos, target_pos)
    local dist = target_pos:Dist(pos)
    local vec = (target_pos - pos):GetNormalized()

    local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, dist, {"blocker"})

    for k,v in pairs(ents) do
        local blocker_pos = v:GetPosition()
        local blocker_vec = (blocker_pos - pos):GetNormalized()
        local blocker_perp = Vector3(-blocker_vec.z, 0, blocker_vec.x)
        local blocker_radius = v.Physics:GetRadius()
        blocker_radius = math.max(0.75, blocker_radius)

        local blocker_edge1 = blocker_pos + Vector3(blocker_perp.x * blocker_radius, 0, blocker_perp.z * blocker_radius)
        local blocker_edge2 = blocker_pos - Vector3(blocker_perp.x * blocker_radius, 0, blocker_perp.z * blocker_radius)

        local blocker_vec1 = (blocker_edge1 - pos):GetNormalized()
        local blocker_vec2 = (blocker_edge2 - pos):GetNormalized()

        --[[
        print("Checking LoS With:", v)
        local colourstr = "00000"..v.GUID
        local r = tonumber(colourstr:sub(-6, -5), 16) / 255
        local g = tonumber(colourstr:sub(-4, -3), 16) / 255
        local b = tonumber(colourstr:sub(-2), 16) / 255
        --Note : world must have debugger component and be debug selected for this to display.
        GetWorld().components.debugger:SetAll(v.GUID.."_angle1", {x=pos.x, y=pos.z}, {x=pos.x + (blocker_vec1.x * dist*2), y= pos.z + (blocker_vec1.z * dist*2)}, {r=r,g=g,b=b,a=1})
        GetWorld().components.debugger:SetAll(v.GUID.."_angle2", {x=pos.x, y=pos.z}, {x=pos.x + (blocker_vec2.x * dist*2), y= pos.z + (blocker_vec2.z * dist*2)}, {r=r,g=g,b=b,a=1})
        --]]

        if isbetween(vec, blocker_vec1, blocker_vec2) then
            -- print(v, "blocks LoS.")
            -- print("-----------")
            return false
        end
    end
    -- print("Nothing blocked LoS.")
    -- print("-----------")

    return true
end

local inventoryItemAtlasLookup = {}

function GetInventoryItemAtlas(imagename)
	local atlas = inventoryItemAtlasLookup[imagename]
	if atlas then
		return atlas
	end
	local base_atlas = "images/inventoryimages.xml"
	atlas = TheSim:AtlasContains(base_atlas, imagename) and base_atlas or "images/inventoryimages_2.xml"
	inventoryItemAtlasLookup[imagename] = atlas
	return atlas
end

function ReplaceEntity(oldinst, newinst)
	-- if we're tracked by a childspawner, let it know
	local home = oldinst.components.homeseeker and oldinst.components.homeseeker:GetHome()
	if home then
     	home.components.childspawner:ReplaceChild(oldinst, newinst)
	end

	-- if we're in a despawned interior, update that interior
	-- To prevent a race condition while an interior is being spawned in, our interior is still set. 
	-- During ReturnToScene callbacks we are not in Limbo anymore so we won't be added to the interior object list instead of spawned
	if oldinst:IsInLimbo() then	
		local interiorID = oldinst.interior
		if interiorID then
			local spawner = GetInteriorSpawner()
			if spawner then
				print("Removing and re-adding to",interiorID)
				spawner:removeprefab(oldinst,interiorID)
				spawner:injectprefab(newinst,interiorID)
			end
		end
	end
end
