require "consolecommands"


----this gets called by the frontend code if a rawkey event has not been consumed by the current screen
handlers = {}

-- Add commonly used commands here. 
-- Hitting F2 will append them to the current console history 
-- Hit  SHIFT-CTRL-F2 to add the current console history to this list (list is not saved between reloads!)
local LOCAL_HISTORY={
                            "c_godmode(true)",
                            "c_spawn('nightmarebeak',10)",
                            "c_spawn('minotaur')",
                    }

function DoDebugKey(key, down)
	if handlers[key] then
		for k,v in ipairs(handlers[key]) do
			if v(down) then
				return true
			end
		end
	end
end


--use this to register debug key handlers from within this file
function AddGameDebugKey(key, fn, down)
	down = down or true
	handlers[key] = handlers[key] or {}
	table.insert( handlers[key], function(_down) if _down == down and inGamePlay then return fn() end end)
end

function AddGlobalDebugKey(key, fn, down)
	down = down or true
	handlers[key] = handlers[key] or {}
	table.insert( handlers[key], function(_down) if _down == down then return fn() end end)
end


-------------------------------------DEBUG KEYS


local currentlySelected
global("c_ent")
global("c_ang")

local function Spawn(prefab)
    --TheSim:LoadPrefabs({prefab})
    return SpawnPrefab(prefab)
end


local userName = TheSim:GetUsersName() 
--
-- Put your own username in here to enable "dprint"s to output to the log window 
if CHEATS_ENABLED and userName == "My Username" then
    global("CHEATS_KEEP_SAVE")
    global("CHEATS_ENABLE_DPRINT")
    global("DPRINT_USERNAME")
    global("c_ps")

    DPRINT_USERNAME = "My Username"
    CHEATS_KEEP_SAVE = true
    CHEATS_ENABLE_DPRINT = true
end

function InitDevDebugSession()
    --[[ To setup this function to be called when the game starts up edit stats.lua and patch the context:
                    function RecordSessionStartStats()
                        if not STATS_ENABLE then
                            return
                        end

                        if InitDevDebugSession then
                            InitDevDebugSession()
                        end
                     --- rest of function
    --]]
    -- Add calls that you want executed whenever a session starts
    -- Here, for example the minhealth is set so the player can't be killed
    -- and the autosave timeout is set to a huge value so that the autosave
    -- doesnt' overwrite my carefully constructed debugging setup
    dprint("DEVDEBUGSESSION")
    global( "TheFrontEnd" )
    local player = GetPlayer()

    c_setminhealth(5)
    TheFrontEnd.consoletext.closeonrun = true
    if player.components.autosaver then
        player.components.autosaver.timeout = 9999e99
    end
end

AddGlobalDebugKey(KEY_HOME, function()
    if not TheSim:IsDebugPaused() then
        print("Home key pressed PAUSING GAME")
        TheSim:ToggleDebugPause()
    end

    print("Home key pressed STEPPING")
	TheSim:Step()
	return true
end)

AddGlobalDebugKey(KEY_J, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
        local shadow = SpawnPrefab("tigersharkshadow")
        local pos = TheInput:GetWorldPosition()
        shadow.Transform:SetPosition(pos:Get())
        shadow:shrink()
    elseif TheInput:IsKeyDown(KEY_SHIFT) then
        local shadow = SpawnPrefab("tigersharkshadow")
        local pos = TheInput:GetWorldPosition()
        shadow.Transform:SetPosition(pos:Get())
        shadow:grow()
    end
end)

AddGlobalDebugKey(KEY_R, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
		TheSim:ResetErrorShown()
        StartNextInstance({reset_action = RESET_ACTION.LOAD_SLOT, save_slot=SaveGameIndex:GetCurrentSaveSlot()})
        if TheInput:IsKeyDown(KEY_SHIFT) then
            -- StartNextInstance({reset_action = RESET_ACTION.LOAD_SLOT, save_slot=SaveGameIndex:GetCurrentSaveSlot()})
        
        elseif TheInput:IsKeyDown(KEY_ALT) then
            -- SaveGameIndex:DeleteSlot(SaveGameIndex:GetCurrentSaveSlot(), function()
            --     StartNextInstance({reset_action = RESET_ACTION.LOAD_SLOT, save_slot=SaveGameIndex:GetCurrentSaveSlot()})
            -- end, true)
        else
            -- StartNextInstance()
        end
        return true
    
    elseif TheInput:IsKeyDown(KEY_SHIFT) then
        local ents = TheInput:GetAllEntitiesUnderMouse()
        if ents[1] and ents[1].prefab then ents[1]:Remove() end
        return true
    else
        c_repeatlastcommand()
        return true
    end
end)

AddGlobalDebugKey(KEY_Y, function()
    local mousepos = TheInput:GetWorldPosition()
    
    local ents = TheSim:FindEntities(mousepos.x,mousepos.y,mousepos.z, 2)
    for i,ent in ipairs(ents)do
        print(ent.prefab)
    end
end)

local toggle_off = true
AddGameDebugKey(KEY_F1, function()
    --Toggle colourcubes on and off
    if not toggle_off then
        GetWorld().components.colourcubemanager:SetOverrideColourCube(nil)
    else
        GetWorld().components.colourcubemanager:SetOverrideColourCube("images/colour_cubes/blank_cc.tex")
    end

    print("Toggle Colour Cubes: ", (toggle_off and "OFF") or "ON")

    toggle_off = not toggle_off
end)

AddGameDebugKey(KEY_F2, function()
    local tbl = {}
    local failsafe = 1000000
    
    while #tbl < 17 and failsafe > 1 do
        -- Profile.persistdata.device_caps_a = 0
        -- Profile.persistdata.device_caps_b = 1231
        TheSim:UpdateDeviceCaps(0,1231)
        local song = TheSim:GetBirdsong()
        if not table.contains(tbl, song) then
            table.insert(tbl, song)
        end
        failsafe = failsafe - 1
    end

    dumptable(tbl) 
end)


AddGameDebugKey(KEY_X, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
        local pt = Vector3(0, 0, 0)
        pt.x, pt.y, pt.z = TheInput:GetWorldPosition():Get()
        local tileAttempt = SpawnPrefab("test_interior_floor")
        local x, y, z = round(pt.x), round(pt.y), round(pt.z)
        tileAttempt.Transform:SetPosition(x+0.5,y ,z+0.5)
    elseif TheInput:IsKeyDown(KEY_SHIFT) then
		local pt = Vector3(0, 0, 0)
        pt.x, pt.y, pt.z = TheInput:GetWorldPosition():Get()
        local tileAttempt = SpawnPrefab("test_interior_pole")
        local x, y, z = round(pt.x), round(pt.y), round(pt.z)
        tileAttempt.Transform:SetPosition(x, y ,z)
    end
end)

AddGameDebugKey(KEY_V, function() 
    if TheInput:IsKeyDown(KEY_SHIFT) then
        
        local function onsaved()
            SetPause(false)
            StartNextInstance({reset_action=RESET_ACTION.LOAD_SLOT, save_slot = SaveGameIndex.current_slot}, true)
        end
        
        SaveGameIndex:SaveCurrent(function() SaveGameIndex:EnterWorld("volcano", onsaved) end, "descend")
    end
end)

AddGameDebugKey(KEY_F3, function()
    c_gonext"cave_entrance"   
end)

AddGameDebugKey(KEY_F4, function()
    if TheInput:IsKeyDown(KEY_SHIFT) then
        if GetSeasonManager():IsRaining() then
            GetSeasonManager():ForceStopPrecip()
        else
            GetSeasonManager():ForcePrecip()
        end
    else
        if GetSeasonManager():IsRaining() then
            GetSeasonManager():ForceStopPrecip()
        else
            GetSeasonManager():ForcePrecip()
        end
    end
    return true
end)

AddGameDebugKey(KEY_F5, function()
	if TheInput:IsKeyDown(KEY_SHIFT) then
		print("Running stress test")
  		scheduler:ExecutePeriodic(0.01, function() 
            local MainCharacter = GetPlayer()
            local ground = GetWorld()

            if MainCharacter then

                local x = math.random()*(350.0*4.0)-(350.0/2.0)*4.0
                local z = math.random()*(350.0*4.0)-(350.0/2.0)*4.0
                local tile = ground.Map:GetTileAtPoint(x,0, z)
                if tile ~= GROUND.IMPASSABLE and tile ~= GROUND.INVALID then
                    MainCharacter.Transform:SetPosition(x,0,z)
                end
                -- local locaton = GetRandomItem(locations)
                -- MainCharacter.Transform:SetPosition(locaton.x, 0, locaton.z) 
            end   
        end)
    else
		local pos = TheInput:GetWorldPosition()
		GetSeasonManager():DoLightningStrike(pos)
	end
	return true
end)


local NO_TAGS = {"FX", "NOCLICK", "DECOR","INLIMBO"}
local BASE_TAGS = {"structure"}

AddGameDebugKey(KEY_F7, function()
    if SaveGameIndex:GetCurrentMode() == "porkland" then
        print("RESERVED FOR FRAPS")
    else

        local numspots = 0
        local findbase = function()
            local pt = GetPlayer():GetPosition()
            local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 30, BASE_TAGS, NO_TAGS) 
            if #ents >= 3 then
                return pt
            end
        end

        local base_offsets = function()
            local positions = {}
            for i = 1, 100 do
                local s = i/32.0--(num/2) -- 32.0
                local a = math.sqrt(s*512.0)
                local b = math.sqrt(s)
                table.insert(positions, Vector3(math.sin(a)*b, 0, math.cos(a)*b))
            end
            return positions
        end

        local basepos = findbase()

        if basepos then
            print("Found a base! Now to find a good landing spot...")
            local offsets = base_offsets()
            local ground = GetWorld()
            for k,v in pairs(offsets) do
                local try_pos = basepos + (v * 30)

                --SpawnPrefab("carrot_planted").Transform:SetPosition(try_pos:Get())

                if not (ground.Map and ground.Map:GetTileAtPoint(try_pos.x, try_pos.y, try_pos.z) == GROUND.IMPASSABLE or ground.Map:GetTileAtPoint(try_pos.x, try_pos.y, try_pos.z) > GROUND.UNDERGROUND ) and 
                #TheSim:FindEntities(try_pos.x, try_pos.y, try_pos.z, 10) <= 0 then
                    numspots = numspots + 1
                    local pillar = SpawnPrefab("mooseegg")
                    --pillar.Transform:SetScale(0.1,0.1,0.1)
                    pillar.Transform:SetPosition(try_pos:Get())
                    --return
                end 

            end
        end
        
        print(numspots, " possible spots found")
    end
    return true
end)

---Spawn random items from the "items" table in a circles around me.

AddGameDebugKey(KEY_F8, function()
    --Spawns a lot of prefabs around you in rings.
    local items = {"rocks", "log", "cutgrass", "petals", "bamboo"} --Which items spawn. 
    local player = GetPlayer()
    local pt = Vector3(player.Transform:GetWorldPosition())
    local theta = math.random() * 2 * math.pi
    local numrings = 8 --How many rings of stuff you spawn
    local radius = 2 --Initial distance from player
    local radius_step_distance = 2 --How much the radius increases per ring.
    local itemdensity = 0.5 --(X items per unit)
    local ground = GetWorld()
    
    local finalRad = (radius + (radius_step_distance * numrings))
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, finalRad + 2)
    -- Walk the circle trying to find a valid spawn point
    for i = 1, numrings do
        local circ = 2*PI*radius
        local numitems = circ * itemdensity

        for i = 1, numitems do
            local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
            local wander_point = pt + offset
           
            if ground.Map and ground.Map:GetTileAtPoint(wander_point.x, wander_point.y, wander_point.z) ~= GROUND.IMPASSABLE then  
                local spawn = SpawnPrefab(GetRandomItem(items))
                spawn.Transform:SetPosition( wander_point.x, wander_point.y, wander_point.z )    
            end
            theta = theta - (2 * PI / numitems)
        end
        radius = radius + radius_step_distance
    end
    return true
end)

--For testing float/land animations 
AddGameDebugKey(KEY_F12, function()

    
    local ground = GetWorld()

    for t,node in ipairs(ground.topology.nodes)do
        if TheSim:WorldPointInPoly(mousepos.x, mousepos.z, node.poly) then
            local original_tile_type = ground.Map:GetTileAtPoint(node.cent[1], 0, node.cent[2])  
            print("IDX:",node.idx,original_tile_type,#node.neighbours)
            print(node.cent[1],node.cent[2])

        end
    end
    return true
end)


AddGameDebugKey(KEY_PAGEUP, function()
	if TheInput:IsKeyDown(KEY_SHIFT) then
		GetSeasonManager().moisture_limit = GetSeasonManager().moisture_limit + 100
	elseif TheInput:IsKeyDown(KEY_CTRL) then
		GetSeasonManager().atmo_moisture = GetSeasonManager().atmo_moisture + 100
	else
		GetWorld().components.seasonmanager:Advance()
	end
	
	return true
end)

AddGameDebugKey(KEY_PAGEDOWN, function()
	if TheInput:IsKeyDown(KEY_SHIFT) then
		GetSeasonManager().moisture_limit = math.max(0, GetSeasonManager().moisture_limit - 100)
	elseif TheInput:IsKeyDown(KEY_CTRL) then
		GetSeasonManager().atmo_moisture = math.max(0, GetSeasonManager().atmo_moisture - 100)
	else
		GetWorld().components.seasonmanager:Retreat()
	end
	return true
end)

--[[
AddGameDebugKey(KEY_O, function()
  	if TheInput:IsKeyDown(KEY_SHIFT) then
		print("Going normal...")
    	--GetClock():StartDusk()
    	--TheSim:SetAmbientColour(0.8,0.8,0.8)
  		-- Normal ruins (pretty, light, healthy)
		--GetCeiling().MapCeiling:AddSubstitue(GROUND.WALL_HUNESTONE,GROUND.WALL_HUNESTONE_GLOW)
		--GetCeiling().MapCeiling:AddSubstitue(GROUND.WALL_STONEEYE,GROUND.WALL_STONEEYE_GLOW)
		local retune = require("tuning_override")
	  	retune.OVERRIDES["ColourCube"].doit("ruins_light_cc")
	  	retune.OVERRIDES["areaambientdefault"].doit("cave")

	  	 GetWorld().components.ambientsoundmixer:SetSoundParam(1.0)
	  	--civruinsAMB (1.0)
	elseif TheInput:IsKeyDown(KEY_ALT) then
		print("Going evil...")
    	--GetClock():StartNight()
    	--TheSim:SetAmbientColour(0.0,0.0,0.0)
		--GetCeiling().MapCeiling:ClearSubstitues()
		-- Evil ruins (ugly, dark, unhealthy)
		local retune = require("tuning_override")
	  	retune.OVERRIDES["ColourCube"].doit("ruins_dark_cc")
	  	retune.OVERRIDES["areaambient"].doit("CIVRUINS")
	  	 GetWorld().components.ambientsoundmixer:SetSoundParam(2.0)
	  	--civruinsAMB (2.0)
	end
	
	return true
end)
]]


AddGameDebugKey(KEY_D, function()
    if TheInput:IsKeyDown(KEY_SHIFT) then

        --[[
        c_give("axe")
        c_give("pickaxe")
        c_give("hammer")
        c_give("backpack")
        c_give("oinc10",3)
        c_give("oinc",10)
        c_give("pithhat")
        c_give("meat",4)
        c_give("torch",2)
        c_give("minerhat")
        c_give("gunpowder",20)        
        c_give("blunderbuss")        
        c_give("gasmaskhat")    

        c_give("antmaskhat")        
        c_give("antsuit")
        c_give("machete")

        local MainCharacter = GetPlayer()
        MainCharacter.components.builder:GiveAllRecipes()
        MainCharacter:PushEvent("techlevelchange")
        ]]

        local pos = TheInput:GetWorldPosition()
        local ents = TheSim:FindEntities(pos.x,pos.y,pos.z, 8,{"interior_door"})        
        print("FOUND DOORS", #ents)
        if #ents > 0 then            

            SetDebugEntity(ents[math.random(1,#ents)])
        end
    end
    
    return true
end)

AddGameDebugKey(KEY_F9, function()
    local skipPlayer = TheInput:IsKeyDown(KEY_CTRL)
    LongUpdate(TUNING.SEG_TIME, skipPlayer)
	return true
end)

AddGameDebugKey(KEY_F10, function()
	if TheInput:IsKeyDown(KEY_CTRL) then
		if GetClock().override_timeLeftInEra == nil then
			GetClock().override_timeLeftInEra = TUNING.SEG_TIME
		else
			GetClock().override_timeLeftInEra = nil
		end
	end

   	GetClock():NextPhase()
   	return true
end)

AddGameDebugKey(KEY_F11, function()
    
	if GetNightmareClock() ~= nil then
		GetNightmareClock():NextPhase()
	end
	return true
end)

AddGameDebugKey(KEY_F1, function()
    local sm = GetWorld().components.seasonmanager
    if TheInput:IsKeyDown(KEY_SHIFT) then
        sm.atmo_moisture = 3000
        sm:StartPrecip()
    else
        sm.atmo_moisture = 0
        sm:StopPrecip()
    end
end)

local potatoparts_sw = { "teleportato_sw_ring", "teleportato_sw_box", "teleportato_sw_crank", "teleportato_sw_potato", "teleportato_sw_base", "adventure_portal" }
local potatoparts = { "teleportato_ring", "teleportato_box", "teleportato_crank", "teleportato_potato", "teleportato_base", "adventure_portal" }
local potatoindex = 1

AddGameDebugKey(KEY_1, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
		local parts = SaveGameIndex:IsModeShipwrecked() and potatoparts_sw or potatoparts
		local MainCharacter = GetPlayer()TheInput:GetWorldPosition():Get()
		local part = nil
		for k,v in pairs(Ents) do
			if v.prefab == parts[potatoindex] then
				part = v
				break
			end
		end
		potatoindex = ((potatoindex) % #parts)+1
        if MainCharacter and part then
            MainCharacter.Transform:SetPosition(part.Transform:GetWorldPosition())
        end
	    return true
    end
    
end)

AddGameDebugKey(KEY_3, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
        c_warp("shipwrecked_exit")
        c_warp("shipwrecked_entrance")
    end
end)

AddGameDebugKey(KEY_4, function()
    local x, y, z = TheInput:GetWorldPosition():Get()
    local function spawn(prefab, n)
        for i = 1, n, 1 do
            local p = SpawnPrefab(prefab)
            if p then
                p.Transform:SetPosition(x + 5 * (2.0 * math.random() - 1.0), y, z + 5 * (2.0 * math.random() - 1.0))
                --p:OnDrop()
            end
        end
    end
    --local map = GetWorld().Map
    --local w, h = map:GetSize()
    --local halfw, halfh = 0.5 * w * TILE_SCALE, 0.5 * h * TILE_SCALE
    --GetPlayer().Transform:SetPosition(halfw - (TUNING.MAPWRAPPER_WARN_RANGE * TILE_SCALE), 0, halfh - (TUNING.MAPWRAPPER_WARN_RANGE * TILE_SCALE))
    spawn("log", 2)
    spawn("coconut", 2)
    spawn("cutgrass", 2)
    spawn("seaweed", 5)
end)

AddGameDebugKey(KEY_5, function()
    local vm = GetWorld().components.volcanomanager
    local x, y, z = TheInput:GetWorldPosition():Get()
    vm:SpawnFireRain(x, y, z)
end)

AddGameDebugKey(KEY_6, function()
    local vm = GetWorld().components.volcanomanager
    local volcano = vm:GetClosestVolcano()
    local vx, vy, vz = volcano.Transform:GetWorldPosition()
    GetPlayer().Transform:SetPosition(vx + 10, vy, vz + 10)
end)

AddGameDebugKey(KEY_X, function()
    currentlySelected = TheInput:GetWorldEntityUnderMouse()
    if currentlySelected then
        c_ent = currentlySelected
        dprint(c_ent)
    end
    if TheInput:IsKeyDown(KEY_CTRL) and c_ent then
        dtable(c_ent,1)
    end
    return true
end)

AddGlobalDebugKey(KEY_LEFTBRACKET, function()
	TheSim:SetTimeScale(TheSim:GetTimeScale() - .25)
	return true
end)

AddGlobalDebugKey(KEY_RIGHTBRACKET, function()
	TheSim:SetTimeScale(TheSim:GetTimeScale() + .25)
	return true
end)

AddGameDebugKey(KEY_KP_PLUS, function()
    local MainCharacter = GetPlayer()
	if MainCharacter then
		if TheInput:IsKeyDown(KEY_CTRL) then
			if GetWorld().Flooding ~= nil then
				--MainCharacter.components.moisture:DoDelta(5)
				local depth = GetWorld().Flooding:GetTargetDepth()
				print("depth is ", depth)
				depth = depth + 1
				GetWorld().Flooding:SetTargetDepth(depth)
			end
		elseif MainCharacter then
			if TheInput:IsKeyDown(KEY_SHIFT) then
				MainCharacter.components.hunger:DoDelta(50)
			elseif TheInput:IsKeyDown(KEY_ALT) then
				MainCharacter.components.sanity:DoDelta(50)
			else
				MainCharacter.components.health:DoDelta(50, nil, "debug_key")
				c_sethunger(1)
				c_sethealth(1)
				c_setsanity(1)
				c_setboathealth(1)
			end
		end
	end
    
    return true
end)

AddGameDebugKey(KEY_KP_MINUS, function()
    local MainCharacter = GetPlayer()
    if MainCharacter then
        if TheInput:IsKeyDown(KEY_ALT) and TheInput:IsKeyDown(KEY_SHIFT) then
            if MainCharacter.components.driver and MainCharacter.components.driver.vehicle then
                MainCharacter.components.driver.vehicle.components.boathealth:DoDelta(-50, "combat")
            end
        elseif TheInput:IsKeyDown(KEY_CTRL) then
            --MainCharacter.components.moisture:DoDelta(-5)
			  if GetWorld().Flooding ~= nil then
				  local depth = GetWorld().Flooding:GetTargetDepth()
				  print("depth is ", depth)
				  depth = depth - 1
				  GetWorld().Flooding:SetTargetDepth(depth)
			  end
        elseif TheInput:IsKeyDown(KEY_SHIFT) then
			MainCharacter.components.hunger:DoDelta(-25)
		elseif TheInput:IsKeyDown(KEY_ALT) then
            MainCharacter.components.sanity:SetPercent(0)
		else
			MainCharacter.components.health:DoDelta(-25, nil, "debug_key")
		end
	end
	return true
end)

AddGameDebugKey(KEY_T, function()

    if TheInput:IsKeyDown(KEY_CTRL) then
        if c_sel() and c_sel().Transform and c_sel().sg then
            local x,y,z = c_sel().Transform:GetWorldPosition()
            c_sel().Transform:SetPosition(x,y+30,z)
            c_sel().sg:GoToState("glide")
        end
    else

    	-- Moving Teleport to just plain T as I am getting a sore hand from CTRL-T - Alia
        local MainCharacter = GetPlayer()
        if MainCharacter then
    	    MainCharacter.Transform:SetPosition(TheInput:GetWorldPosition():Get() )
        end   
    end
    return true

end)

AddGameDebugKey(KEY_G, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
        local MouseCharacter = TheInput:GetWorldEntityUnderMouse()
        if MouseCharacter then
            if MouseCharacter.components.growable then
                MouseCharacter.components.growable:DoGrowth()
            elseif MouseCharacter.components.fueled then
                MouseCharacter.components.fueled:SetPercent(1)
            elseif MouseCharacter.components.breeder then
                MouseCharacter.components.breeder:updatevolume(1)
            end
        end
    elseif TheInput:IsKeyDown(KEY_SHIFT) then
        c_supergodmode()
    else
		c_godmode()
    end
	return true
end)

AddGameDebugKey(KEY_K, function()
    if TheInput:IsKeyDown(KEY_CTRL) then
        local MouseCharacter = TheInput:GetWorldEntityUnderMouse()
        if MouseCharacter then
			if MouseCharacter.components.health and MouseCharacter ~= GetPlayer() then
				MouseCharacter.components.health:Kill()
			elseif MouseCharacter.Remove then
				MouseCharacter:Remove()
			end
        end
    end
    return true
end)

local DebugTextureVisible = false
local MapLerpVal = 0.0

AddGlobalDebugKey(KEY_SLASH, function()
    if TheInput:IsKeyDown(KEY_ALT) then
    	print("ToggleFrameProfiler")
		TheSim:ToggleFrameProfiler()
	else
		TheSim:ToggleDebugTexture()

		DebugTextureVisible = not DebugTextureVisible
		print("DebugTextureVisible",DebugTextureVisible)
	end
	return true
end)

AddGlobalDebugKey(KEY_EQUALS, function()
	if DebugTextureVisible then
		local val = 1
		if TheInput:IsKeyDown(KEY_ALT) then
			val = 10
		elseif TheInput:IsKeyDown(KEY_CTRL) then
			val = 100
		end
		TheSim:UpdateDebugTexture(val)
	else
		MapLerpVal = MapLerpVal + 0.1
		if GetMap() then
			GetMap():SetOverlayLerp( MapLerpVal )
		end
	end
	return true
end)

AddGameDebugKey(KEY_MINUS, function()
	if DebugTextureVisible then
		local val = 1
		if TheInput:IsKeyDown(KEY_ALT) then
			val = 10
		elseif TheInput:IsKeyDown(KEY_CTRL) then
			val = 100
		end
		TheSim:UpdateDebugTexture(-val)
	else
		MapLerpVal = MapLerpVal - 0.1 
		if GetMap() then
			GetMap():SetOverlayLerp( MapLerpVal )
		end
	end
	
	return true
end)

local enable_fog = true
local hide_revealed = false
AddGameDebugKey(KEY_M, function()
    local MainCharacter = GetPlayer()
    local map = TheSim:FindFirstEntityWithTag("minimap")
    if MainCharacter and map then
        if TheInput:IsKeyDown(KEY_CTRL) then
		    enable_fog = not enable_fog
		    map.MiniMap:EnableFogOfWar(enable_fog)
        elseif TheInput:IsKeyDown(KEY_SHIFT) then
            --hide_revealed = not hide_revealed
           --map.MiniMap:ClearRevealedAreas(hide_revealed)
		   map.MiniMap:SetRevealRadiusMultiplier(1000)
        end
    end
    return true
end)


AddGameDebugKey(KEY_S, function()
	if TheInput:IsKeyDown(KEY_CTRL) then
		GetPlayer().components.autosaver:DoSave()
		return true			
	end
end)

local function onhitground_haildrop(inst, onwater)
    if not onwater then
        if math.random() < TUNING.HURRICANE_HAIL_BREAK_CHANCE then
            inst.components.inventoryitem.canbepickedup = false
            inst.AnimState:PlayAnimation("break")
            inst:ListenForEvent("animover", function(inst) inst:Remove() end)
        else
            inst.components.blowinwind:Start()
            inst:RemoveEventCallback("onhitground", onhitground_haildrop)
            ChangeToInventoryPhysics(inst)
            --inst.Physics:SetCollisionCallback(nil)
        end
    end
end
 AddGameDebugKey(KEY_C, function()
      if TheInput:IsKeyDown(KEY_CTRL) then
        local is = GetWorld().components.interiorspawner
        for id, room in pairs(is.interiors)do
            print("------",id)
            
            if room.prefabs then
                print("prefabs")
                for i,ent in ipairs(room.prefabs)do
                    print(ent.name)                    
                end
            end

            if room.object_list then
                print("object_list")
                for i,ent in ipairs(room.object_list)do
                    print(ent.prefab)  
                end
            end

        end



         return true         
     end
 end)

AddGameDebugKey(KEY_A, function()
	if TheInput:IsKeyDown(KEY_CTRL) then
		local MainCharacter = GetPlayer()
		MainCharacter.components.builder:GiveAllRecipes()
		MainCharacter:PushEvent("techlevelchange")
		MainCharacter:PushEvent("techtreechange")
		return true
	end

    if TheInput:IsKeyDown(KEY_SHIFT) then
        local pos = TheInput:GetWorldPosition()
        local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 5, {"SELECT_ME"},{"INLIMBO"})
        if #ents >0 then
            for i, ent in ipairs(ents)do
                print("-------------")    
                dumptable(ent,1,1,1)        
            end
        else
            print("NO ENTS")
        end  
    end  
end)

AddGameDebugKey(KEY_KP_MULTIPLY, function()
	if TheInput:IsDebugToggleEnabled() then
		c_give("devtool")
		return true
	end
end)

AddGameDebugKey(KEY_BACKSLASH, function()
    if TheInput:IsDebugToggleEnabled() then
        c_give("devtool")
        return true
    end
end)


AddGameDebugKey(KEY_KP_DIVIDE, function()
	if TheInput:IsDebugToggleEnabled() then
		GetPlayer().components.inventory:DropEverything(false, true)
		return true
	end
end)
--[[

AddGameDebugKey(KEY_C, function()
    if userName ~= "David Forsey" then
        if TheInput:IsKeyDown(KEY_CTRL) then
            local IDENTITY_COLOURCUBE = "images/colour_cubes/identity_colourcube.tex"
            PostProcessor:SetColourCubeData( 0, IDENTITY_COLOURCUBE, IDENTITY_COLOURCUBE )
            PostProcessor:SetColourCubeLerp( 0, 0 )
        end
    else
        if not c_ent then return end

        global("c_ent_mood")
        local pos = c_ent.components.knownlocations.GetLocation and c_ent.components.knownlocations:GetLocation("rookery")
        if pos and TheInput:IsKeyDown(KEY_CTRL) then
            c_teleport(pos.x, pos.y, pos.z)
        elseif pos then
            c_teleport(pos.x, pos.y, pos.z, c_ent)
        end
    end
    
    return true
end)
]]
local wandertask = nil
AddGlobalDebugKey(KEY_P, function()
	if wandertask == nil then
		print("Beginning wander....")
		wandertask = GetPlayer():DoPeriodicTask(20, function(inst)
			local area = inst.components.area_aware.areas[math.random(#inst.components.area_aware.areas)]
			print("Wandering to "..area.idx)
			local pt = Vector3(area.cent[1], 0, area.cent[2])
			inst.components.playercontroller:DoAction( BufferedAction(inst, nil, ACTIONS.WALKTO, nil, pt))
		end, 0.5)
	else
		wandertask:Cancel()
		wandertask = nil
		print("Stopping wander")
	end
end)

AddGlobalDebugKey(KEY_PAUSE, function()
    print("Toggle pause")
	
    TheSim:ToggleDebugPause()
    TheSim:ToggleDebugCamera()
	
    if TheSim:IsDebugPaused() then
	    TheSim:SetDebugRenderEnabled(true)
	    if TheCamera.targetpos then
		    TheSim:SetDebugCameraTarget(TheCamera.targetpos.x, TheCamera.targetpos.y, TheCamera.targetpos.z)
	    end
		
	    if TheCamera.headingtarget then
		    TheSim:SetDebugCameraRotation(-TheCamera.headingtarget-90)	
	    end
    end
    return true
end)

AddGameDebugKey(KEY_H, function()
    if TheInput:IsKeyDown(KEY_LCTRL) then
        GetPlayer().HUD:Toggle()
    end

end)--]]

AddGameDebugKey(KEY_I, function()
	if TheInput:IsKeyDown(KEY_LCTRL) then
        GetWorld().components.whalehunter:StartCooldown(2)
        GetWorld().components.whalehunter.distance = 301
	end
end)

AddGameDebugKey(KEY_INSERT, function()
    if TheInput:IsDebugToggleEnabled() then
        if not TheSim:GetDebugRenderEnabled() then
            TheSim:SetDebugRenderEnabled(true)
        end
	    if TheInput:IsKeyDown(KEY_SHIFT) then
		    TheSim:ToggleDebugCamera()
	    else
			TheSim:SetDebugPhysicsRenderEnabled(not TheSim:GetDebugPhysicsRenderEnabled())
	    end
    end
    return true
end)

AddGameDebugKey(KEY_PERIOD, function()
    if TheInput:IsDebugToggleEnabled() then
        if not TheSim:GetDebugRenderEnabled() then
            TheSim:SetDebugRenderEnabled(true)
        end
        if TheInput:IsKeyDown(KEY_SHIFT) then
            TheSim:ToggleDebugCamera()
        else
            TheSim:SetDebugPhysicsRenderEnabled(not TheSim:GetDebugPhysicsRenderEnabled())
        end
    end
    return true
end)

AddGameDebugKey(KEY_B, function()
    local player = GetPlayer()
    local x,y,z = player.Transform:GetWorldPosition()

    if TheInput:IsKeyDown(KEY_CTRL) then
        local treasures = TheSim:FindEntities(x, y, z, 10000, {"buriedtreasure"}, {"linktreasure"})
        print("Found " .. #treasures .. " treasures")
        if treasures and type(treasures) == "table" and #treasures > 0 then
            for i = 1, #treasures, 1 do
                local bottle = SpawnPrefab("messagebottle")
                bottle.Transform:SetPosition(x, y, z)
                bottle.treasure = treasures[i]
                if bottle.treasure.debugname then
                    bottle.debugmsg = "It's a map to '" .. tostring(bottle.treasure.debugname) .. "'"
                end
                player.components.inventory:GiveItem(bottle)
            end
        end
    else
        --normal message bottle
        local bottle = SpawnPrefab("messagebottle")
        bottle.Transform:SetPosition(x, y, z)
        player.components.inventory:GiveItem(bottle)
    end
end)

AddGameDebugKey(KEY_C, function()
    print("DEBUG_ENTS:")
    local interiorSpawner = GetWorld().components.interiorspawner
	
	if interiorSpawner and TheCamera.interior then

	    local pt = interiorSpawner:getSpawnOrigin()

    	-- collect all the things in the "interior area" minus the interior_spawn_origin and the player
	    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 50, nil, {"INTERIOR_LIMBO"})
	    assert(ents ~= nil)
	    assert(#ents > 0)

	    print("ENTS LENGTH = "..#ents)
	    dumptable(ents, 1, 1, 1)
	    print("======================================================================================")

    	for i = #ents, 1, -1 do
        	if not ents[i] then
            	print("entry", i, "was null for some reason?!?")
	        end
    	    print("#### current length:", #ents, "i:", i, "prefab:", ents[i].prefab)
	        dumptable(ents[i], 1, 1, 1)
	    end
	    return ents
	else
		print("Not in interior")
	end
end)
-------------------------------------------MOUSE HANDLING


local function DebugRMB(x,y)
    dprint("MBHAND:CTRL=",TheInput:IsKeyDown(KEY_CTRL)," SHIFT=", TheInput:IsKeyDown(KEY_SHIFT))
    local MouseCharacter = TheInput:GetWorldEntityUnderMouse()
    local pos = TheInput:GetWorldPosition()

	global("c_ent")
	if TheInput:IsKeyDown(KEY_CTRL) and
		TheInput:IsKeyDown(KEY_SHIFT) then
		if c_ent and c_ent.prefab then
			local spawn = c_spawn(c_ent.prefab)
			if spawn then
				spawn.Transform:SetPosition(pos:Get())
			end
		end
   elseif TheInput:IsKeyDown(KEY_CTRL) then
        if MouseCharacter then
			if MouseCharacter.components.health and MouseCharacter ~= GetPlayer() and not MouseCharacter:HasTag("INTERIOR_LIMBO") then
				MouseCharacter.components.health:Kill()
			elseif MouseCharacter.Remove then
				MouseCharacter:Remove()
			end
        else
            local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 5,nil, {"INTERIOR_LIMBO"})
            for k,v in pairs(ents) do
                if v.components.health and v ~= GetPlayer() then
                    v.components.health:Kill()
                end
            end
        end
    elseif TheInput:IsKeyDown(KEY_ALT) then

        print(GetPlayer() and GetPlayer():GetAngleToPoint(pos))

    elseif TheInput:IsKeyDown(KEY_SHIFT) then
        if MouseCharacter then
            global("c_ent")
            c_ent = MouseCharacter
            SetDebugEntity(MouseCharacter)
            dprint("Selected: ",c_ent)
        else
            SetDebugEntity(GetWorld())
        end

    else
        --TheSim:SetDebugCameraTarget(x, y, TheCamera.targetpos.z)
    end
end

local function DebugLMB(x,y)
	if TheInput:IsKeyDown(KEY_ALT) then
		if GetWorld() and (GetWorld().Flooding ~= nil) then
			local pos = TheInput:GetWorldPosition()

		   -- local pt = Vector3(GetPlayer().entity:LocalToWorldSpace(offset,0,0))
			local center = Vector3(GetWorld().Flooding:GetTileCenterPoint(pos:Get()))
			pos.x = center.x
			pos.y = center.y
			pos.z = center.z

			GetWorld().Flooding:GetTileData(pos.x,pos.z)
		end
	end
	if TheSim:IsDebugPaused() or TheInput:IsKeyDown(KEY_SHIFT) then
		SetDebugEntity(TheInput:GetWorldEntityUnderMouse())
	end
end

function DoDebugMouse(button, down,x,y)
	if not down then return false end
	
	if button == MOUSEBUTTON_RIGHT then
		DebugRMB(x,y)
	elseif button == MOUSEBUTTON_LEFT then
		DebugLMB(x,y)	
	end
end
