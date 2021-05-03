require("class")

local BehaviourTrees = {}
local StateGraphs = {}
local Components = {}

StopUpdatingComponents = {}

local function LoadComponent(name)
    
    if Components[name] == nil then
        Components[name] = require("components/"..name)
    end
    return Components[name]
end

local function LoadStateGraph(name)

    if StateGraphs[name] == nil then
        local fn = require("stategraphs/"..name)
        assert(fn, "could not load stategraph "..name)
        StateGraphs[name] = fn
    end
    
    local sg = StateGraphs[name]
    
    assert(sg, "stategraph "..name.." is not valid")
    return sg
end

EntityScript = Class(function(self, entity)
    self.entity = entity
    self.components = {}
    self.GUID = entity:GetGUID()
    self.spawntime = GetTime()
    self.persists = true
    self.inlimbo = false
    self.name = nil
    
    self.data = nil
    self.listeners = nil
    self.updatecomponents = nil
    self.inherentactions = nil
    self.event_listeners = nil
    self.event_listening = nil
    self.pendingtasks = nil
    self.children = nil
    self.age = 0
    self.ininterior = nil
end)

function EntityScript:GetSaveRecord()
    local record = 
    {
        prefab = self.prefab,
        --id = self.GUID,
        --age = math.floor(self:GetTimeAlive()*10)/10
    }
    
    if self.Transform then
        local x, y, z = self.Transform:GetWorldPosition()
        
        --Qnan hunting
        x = x ~= x and 0 or x
        y = y ~= y and 0 or y
        z = z ~= z and 0 or z

        record.x = x and math.floor(x*1000)/1000 or 0
        record.z = z and math.floor(z*1000)/1000 or 0
        --y is often 0 in our game, so be selective.
        if y ~= 0 then
            record.y = y and math.floor(y*1000)/1000 or 0
        end
    end
    
    local references = nil
    record.data, references = self:GetPersistData()
    
    return record, references
end


function EntityScript:Hide()
    self.entity:Hide(false)
end

function EntityScript:Show()
    self.entity:Show(false)
end

function EntityScript:IsInLimbo()
    return self.inlimbo
end

function EntityScript:RemoveFromScene(frominterior)
    self.entity:AddTag("INLIMBO")
    self.inlimbo = true
	self.entity:Hide()

	self:StopBrain()

	if self.sg then
	    self.sg:Stop()
	end

	if self.Physics then
        self.Physics:SetActive(false)
    end

    if self.Light and self.Light:GetDisableOnSceneRemoval() then
        self.Light:Enable(false)
    end

    if self.AnimState then
        self.AnimState:Pause()
    end

    if self.DynamicShadow then
        self.DynamicShadow:Enable(false)
    end

    if self.MiniMapEntity and not frominterior then
        self.MiniMapEntity:SetEnabled(false)
    end


    self:PushEvent("enterlimbo")
end

function EntityScript:CheckIsInInterior()
    --assert(self.ininterior)
    return self.ininterior
end

function EntityScript:UpdateIsInInterior()
    if self.Transform then     
        local pt = self:GetPosition()
        local tile = GetWorld().Map:GetTileAtPoint(pt.x,pt.y,pt.z)
        if tile == GROUND.INTERIOR then
            self.ininterior = true
        else
            self.ininterior = false
        end
    else 
        print("THIS ENTITY DID NOT HAVE A TRANSFORM..YET",self.prefab)
    end
end

function EntityScript:ReturnToScene()
    self.entity:RemoveTag("INLIMBO")
    self.inlimbo = false
	self.entity:Show()
    if self.Physics then
        self.Physics:SetActive(true)
	end
    if self.Light then
        self.Light:Enable(true)
    end
    if self.AnimState then
        self.AnimState:Resume()
    end
    if self.DynamicShadow then
        self.DynamicShadow:Enable(true)
    end
    if self.MiniMapEntity then
        self.MiniMapEntity:SetEnabled(true)
    end
    
    self:RestartBrain()
    
	if self.sg then
	    self.sg:Start()
	end
    self:PushEvent("exitlimbo")
    self:DoTaskInTime(0, function() self:UpdateIsInInterior() end)
end


function EntityScript:OnProgress()
	for k,v in pairs(self.components) do
		if v.OnProgress then
			v:OnProgress()
		end
	end
end

function EntityScript:__tostring()
    return string.format("%d - %s%s", self.GUID, self.prefab or "", self.inlimbo and "(LIMBO)" or "")
end

function EntityScript:AddInherentAction(act)
    if not self.inherentactions then
		self.inherentactions = {}
    end
    self.inherentactions[act] = true
end

function EntityScript:RemoveInherentAction(act)
    if self.inherentactions then
		self.inherentactions[act] = nil
	end
end

function EntityScript:GetTimeAlive()
    return GetTime() - self.spawntime + self.age
end


function EntityScript:StartUpdatingComponent(cmp)
    if not self.updatecomponents then
        self.updatecomponents = {}
        NewUpdatingEnts[self.GUID] = self
        num_updating_ents = num_updating_ents + 1
    end
    
    --If you were told to stop this frame just don't stop
    StopUpdatingComponents[cmp] = nil
    
    local cmpname = nil
    for k,v in pairs(self.components) do
        if v == cmp then
            cmpname = k
            break
        end
    end
    
    self.updatecomponents[cmp] = cmpname or "component"
end

function EntityScript:StopUpdatingComponent(cmp)   
    if self.updatecomponents then   
        StopUpdatingComponents[cmp] = self
    end
end

function EntityScript:StopUpdatingComponent_Deferred(cmp)
    if self.updatecomponents then
        self.updatecomponents[cmp] = nil

        local num = 0
        for k,v in pairs(self.updatecomponents) do
            num = num + 1
            break
        end
        
        if num == 0 then
            self.updatecomponents = nil
            UpdatingEnts[self.GUID] = nil
            NewUpdatingEnts[self.GUID] = nil
            num_updating_ents = num_updating_ents - 1
        end
    end
end

function EntityScript:StartWallUpdatingComponent(cmp)
    
    if not self.wallupdatecomponents then
        self.wallupdatecomponents = {}
        NewWallUpdatingEnts[self.GUID] = self
    end

	local cmpname = nil
	for k,v in pairs(self.components) do
		if v == cmp then
			cmpname = k
			break
		end
	end

    self.wallupdatecomponents[cmp] = cmpname or "component"
end

function EntityScript:StopWallUpdatingComponent(cmp)
    
    if self.wallupdatecomponents then
        self.wallupdatecomponents[cmp] = nil

        local num = 0
        for k,v in pairs(self.wallupdatecomponents) do
            num = num + 1
            break
        end
        
        if num == 0 then
            self.wallupdatecomponents = nil
            WallUpdatingEnts[self.GUID] = nil
            NewWallUpdatingEnts[self.GUID] = nil
        end
    end
end


function EntityScript:GetComponentName(cmp)
	for k,v in pairs(self.components) do
		if v == cmp then
			return k
		end
	end
	return "component"
end

function EntityScript:AddTag(tag)
    self.entity:AddTag(tag)
end

function EntityScript:RemoveTag(tag)
    self.entity:RemoveTag(tag)
end

function EntityScript:HasTag(tag)
    return self.entity:HasTag(tag)
end

function EntityScript:AddComponent(name)
    -- assert(self.components[name] == nil, "component "..name.." already exists in prefab!")
    if self.components[name] then
        print("component "..name.." already exists in prefab!")
    end
    local cmp = LoadComponent(name)
    assert(cmp, "component ".. name .. " does not exist!")
    
    local loadedcmp = cmp(self)
    self.components[name] = loadedcmp
    local postinitfns = ModManager:GetPostInitFns("ComponentPostInit", name)

    for k,fn in ipairs(postinitfns) do
        fn(loadedcmp,self)
    end
end

function EntityScript:RemoveComponent(name)
    local cmp = self.components[name]
    if cmp then
		self:StopUpdatingComponent(cmp)
		self:StopWallUpdatingComponent(cmp)
        self.components[name] = nil
        if cmp.OnRemoveFromEntity then
            cmp:OnRemoveFromEntity()
        end
    end
end

function EntityScript:AddComponentAtRuntime(name)
    if self.components[name] then
        print("component "..name.." already exists! -- AddComponentAtRuntime")
        return
    end
    
    self:AddComponent(name)
    if not self.RuntimeComponents then
        self.RuntimeComponents = {}
    end
    self.RuntimeComponents[name] = name

end

function EntityScript:RemoveComponentAtRuntime(name)
    if not self.RuntimeComponents[name] then
        print("Tried to remove a component using 'RemoveComponentAtRuntime' that wasn't added using 'AddComponentAtRuntime'! Aborting!")
        return
    end
    self:RemoveComponent(name)
    self.RuntimeComponents[name] = nil
end

nearsightednames = nil

local nearsighted_key_blacklist =
{
        NIL = true,
        DARKNESS = true,
        CHARLIE = true,
        HUNGER = true,
        COLD = true,
        HOT = true,
        SHENANIGANS = true,
        RESURRECTION_PENALTY = true,
        DROWNING = true,
        BURNT = true,
        UNKNOWN = true,

		WARBUCKS = true,
		DEVTOOL = true,
}

local function testvisionfn(k,v)
	if v == "" or type(v) == "table" or string.find(v, "%%") or string.find(v, "%{") or nearsighted_key_blacklist[k] then
		return false
	end
	return true
end

function EntityScript:Teleport(EntityOrPosition, instant)
	local px,py,pz = self.Transform:GetWorldPosition()
	print("originating point:",px,py,pz)

	-- is the entity in an interior
	-- is the destination in an interior
	-- special case - are we the player? then we may need a transition
	local loctarget
	local t_loc
	if EntityOrPosition:is_a(Vector3) then
		t_loc = EntityOrPosition
	else
		loctarget = EntityOrPosition
        t_loc = loctarget:GetPosition()
	end

	local sourceInterior = self.interior
	if not sourceInterior then
	    local tile = GetWorld().Map:GetTileAtPoint(px,py,pz)
		local sourceInInterior = (tile == GROUND.INTERIOR)
		-- if the object is in an interior but doesn't have an interior set then it must be in the current interior
		if sourceInInterior then
		   	local interiorSpawner = GetWorld().components.interiorspawner
			sourceInterior = interiorSpawner.current_interior and interiorSpawner.current_interior.unique_name
		end
	end

	local destInterior = loctarget and loctarget.interior
	if not destInterior then
	    local tile = GetWorld().Map:GetTileAtPoint(t_loc.x,t_loc.y,t_loc.z)
		local destInInterior = (tile == GROUND.INTERIOR)
		-- if the object is in an interior but doesn't have an interior set then it must be in the current interior
		-- technically for a point (rather than an entity) this logic would not work, but then we'd have no way to discern the interior either
		if destInInterior then
		   	local interiorSpawner = GetWorld().components.interiorspawner
			destInterior = interiorSpawner.current_interior.unique_name
		end
	end


	if self == GetPlayer() then
	    local snapcam = true
    	if loctarget then
        	if TheCamera.interior or loctarget.interior then
            	local interiorSpawner = GetWorld().components.interiorspawner
	            interiorSpawner:PlayTransition(GetPlayer(), nil, destInterior, loctarget, true)   
    	        snapcam = false
	        end
			-- re-grab the position, the target may have come out of interior storage
			t_loc = loctarget:GetPosition()
	    else
    	    -- we may have to transition outside if we're currently inside
        	if TheCamera.interior and t_loc then
            	local interiorSpawner = GetWorld().components.interiorspawner
	            interiorSpawner:PlayTransition(GetPlayer(), nil, nil, t_loc, true)   
    	        snapcam = false
	        end
	    end

	    self.Transform:SetPosition(t_loc.x, 0, t_loc.z)

	    if snapcam then
    	    TheCamera:Snap()
			if not instant then
	        	TheFrontEnd:DoFadeIn(1)
		        Sleep(1)
			end
    	end
	else
	   	local interiorSpawner = GetWorld().components.interiorspawner
	    self.Transform:SetPosition(t_loc.x, 0, t_loc.z)
		if sourceInterior then
			-- remove us from the source room
			if interiorSpawner.current_interior and sourceInterior == interiorSpawner.current_interior.unique_name then
				-- nothing to do. The object is moved
			else
				interiorSpawner:removeprefab(self,sourceInterior)
				interiorSpawner:ReturnItemToScene(self)
			end
		end
		if destInterior then
			-- add us to the dest room
		   	if interiorSpawner.current_interior and destInterior == interiorSpawner.current_interior.unique_name then
				-- nothing to do, we're moved
			else
				interiorSpawner:injectprefab(self,destInterior)
			end
		end
	end
end

function EntityScript:GetDisplayName()
    --local name = self.name
    if GetPlayer().components.vision and not GetPlayer().components.vision.focused and not GetPlayer().components.vision:testsight(self) then        
        if not self.nearsightedname then
			nearsightednames = nearsightednames or reduce(STRINGS.NAMES, testvisionfn)
            self.nearsightedname = GetRandomItem(nearsightednames)
        end
        return self.nearsightedname
    end    

	local name = (self.displaynamefn ~= nil and self:displaynamefn()) or (self.nameoverride and STRINGS.NAMES[string.upper(self.nameoverride)]) or self.name
--[[
    if self.displaynamefn then
        name = (self.displaynamefn(self))
    end
]]
    local wet =  self:GetIsWet()
    local flooded = self.components.floodable and self.components.floodable.flooded
    if flooded then 
        return ConstructAdjectivedName(self, name, STRINGS.FLOODEDITEM)
    end 
    local withered = self.components.pickable and self.components.pickable:IsWithered()
    if not withered then 
        withered = self.components.crop and self.components.crop:IsWithered() 
    end
    local smoldering = self.components.burnable and self.components.burnable:IsSmoldering()
    if smoldering then
        return ConstructAdjectivedName(self, name, STRINGS.SMOLDERINGITEM)
    elseif withered then
        return ConstructAdjectivedName(self, name, STRINGS.WITHEREDITEM)
    elseif (wet or self.always_wet) and not self.no_wet_prefix then
        if self.wet_prefix then
            return ConstructAdjectivedName(self, name, self.wet_prefix)
        elseif self.components.edible and GetPlayer() and GetPlayer().components.eater and GetPlayer().components.eater:CanEat(self) then
            return ConstructAdjectivedName(self, name, STRINGS.WET_PREFIX.FOOD)
        elseif self.components.equippable and (self.components.equippable.equipslot == EQUIPSLOTS.HEAD or self.components.equippable.equipslot == EQUIPSLOTS.BODY) then
            return ConstructAdjectivedName(self, name, STRINGS.WET_PREFIX.CLOTHING)
        elseif self.components.equippable and self.components.equippable.equipslot == EQUIPSLOTS.HANDS then
            return ConstructAdjectivedName(self, name, STRINGS.WET_PREFIX.TOOL)
        elseif self.components.fuel then
            return ConstructAdjectivedName(self, name, STRINGS.WET_PREFIX.FUEL)
        else
            return ConstructAdjectivedName(self, name, STRINGS.WET_PREFIX.GENERIC)
        end
    elseif self.components.mystery and self:HasTag("mystery") then
        return ConstructAdjectivedName(self, name, STRINGS.MYSTERIOUS)
    else
        return name
    end
end

function EntityScript:GetIsFlooded()
    if self:IsValid() and self.Transform then 
        local x, y, z = self.Transform:GetWorldPosition()
        if x and y and z and GetWorld().Flooding and GetWorld().Flooding:OnFlood(x, y, z) then
            return true
        end 
    end 
end 

function EntityScript:GetIsWet()
    return GetWorld().components.moisturemanager:IsEntityWet(self) and not self:CheckIsInInterior()
end

function EntityScript:GetInheritedMoisture()
    local targetMoisture = 0
    if self.components.moisturelistener then
        targetMoisture = self.components.moisturelistener:GetMoisture()
    elseif self.components.moisture then
        targetMoisture = self.components.moisture:GetMoisture()
    elseif self:GetIsFlooded() then 
        targetMoisture = math.max(GetWorld().components.moisturemanager:GetWorldMoisture(), TUNING.MOISTURE_FLOOD_WETNESS)
    else
        targetMoisture = GetWorld().components.moisturemanager:GetWorldMoisture()
    end
    return targetMoisture
end 

function EntityScript:ApplyInheritedMoisture(other)
    local targetMoisture = self:GetInheritedMoisture()
            
    other.targetMoisture = targetMoisture
    other:DoTaskInTime(2*FRAMES, function()
        if other.components.moisturelistener then 
            other.components.moisturelistener.moisture = other.targetMoisture
            other.targetMoisture = nil
            other.components.moisturelistener:DoUpdate()
        end
    end)
end 

function EntityScript:SetPrefabName(name)
    self.prefab = name
    self.entity:SetPrefabName(name)
    self.name = self.name or (STRINGS.NAMES[string.upper(self.prefab)] or "MISSING NAME")
end

function EntityScript:SetPrefabNameOverride(nameoverride)
    --Changes what description and name will show for the prefab without actually overriding the prefab itself.
    --nameoverride should be the prefab that you wish to use for name and description. (IE: "spiderhole_rock" uses "spiderhole")
    self.nameoverride = nameoverride
end
            
function EntityScript:SpawnChild(name)
    if self.prefabs then
		assert(self.prefabs, "no prefabs registered for this entity ".. name)
		local prefab = self.prefabs[name]
		assert(prefab, "Could not spawn unknown child type "..name)
		local inst = SpawnPrefab(prefab)
		assert(inst, "Could not spawn prefab "..name.." "..prefab)
	    self:AddChild(inst)
	    return inst
	else
		local inst = SpawnPrefab(name)
	    self:AddChild(inst)
	    return inst
	end
end

function EntityScript:RemoveChild(child)
    child.parent = nil
    if self.children then
		self.children[child] = nil
	end		
    child.entity:SetParent(nil)
end

function EntityScript:AddChild(child)
    if child.parent then
        child.parent:RemoveChild(child)
    end

    child.parent = self
    if not self.children then
		self.children = {}
    end
    
    self.children[child] = true
    child.entity:SetParent(self.entity)
end

function EntityScript:HasChildPrefab(child_prefab)
    if self.children then
        for k,child in pairs(self.children) do
            if k.prefab == child_prefab then
                return true
            end
        end
    end

    return false
end

function EntityScript:GetGrandParent()
	local parent = self.parent
	while parent and parent.parent do
		parent = parent.parent
	end
	return parent
end

function EntityScript:GetBrainString()
	local str = {}
    
    if self.brain then
        table.insert(str, "BRAIN:\n")
        table.insert(str, tostring(self.brain))
        table.insert(str, "--------\n")
    end
    
	return table.concat(str, "")
end

function EntityScript:GetDebugString()
    local str = {}
    
    table.insert(str, tostring(self))
    table.insert(str, string.format(" age %2.2f %s", self:GetTimeAlive(), self:IsAsleep() and "<ASLEEP>" or ""))
    table.insert(str, "\n")
 
    if self.entity:GetDebugString() then
        table.insert(str, self.entity:GetDebugString())
    end 
    
    table.insert(str, "Buffered Action: "..tostring(self.bufferedaction).."\n")

    if self.debugstringfn then
		table.insert(str, self.debugstringfn(self))
    end

    if self.sg then
        table.insert(str, "SG:"..tostring(self.sg).."\n-----------\n")
    end
    
    table.insert(str, "\n IsInInterior: "..tostring(self.ininterior).."\n")


    ----[[
	local cmpkeys = {}
    for k,v in pairs(self.components) do
		table.insert(cmpkeys, k)
	end
	table.sort(cmpkeys)
	for i,k in ipairs(cmpkeys) do
        if self.components[k].GetDebugString then
            table.insert(str, k..": "..tostring(self.components[k]:GetDebugString()).."\n")
        end
    end
    --]]

    --[[if self.brain then
        table.insert(str, "-------\nBRAIN:\n")
        table.insert(str, tostring(self.brain))
        table.insert(str, "--------\n")
    end
    --]]
    
    
    --[[
    if self.event_listening or self.event_listeners then
        table.insert(str, "-------\n")
    end
    if self.event_listening then
        table.insert(str, "Listening for Events:\n")
        for event, sources in pairs(self.event_listening) do
            table.insert(str, string.format("\t%s%s: ", event, GetTableSize(sources) > 1 and string.format("(%u)", GetTableSize(sources)) or "") )
            
            local max_list = 5 -- this can be a very long list
            local n = 0
            for source, fns in pairs(sources) do
                table.insert(str, string.format("%s%s%s", n > 0 and ", " or "", tostring(source), #fns > 1 and string.format("(%u)", #fns) or ""))
                n = n + 1
                if n >= max_list then 
                    break 
                end
            end
            table.insert(str, "\n")
        end
    end
    
    if self.event_listeners then
        table.insert(str, "Broadcasting Events:\n")
        for event, listeners in pairs(self.event_listeners) do
            table.insert(str, string.format("\t%s%s: ", event, GetTableSize(listeners) > 1 and string.format("(%u)", GetTableSize(listeners)) or "") )
            local max_list = 5 -- this can be a very long list
            local n = 0
            for listener, fns in pairs(listeners) do
                table.insert(str, string.format("%s%s%s", n > 0 and ", " or "", tostring(listener), #fns > 1 and string.format("(%u)", #fns) or ""))
                n = n + 1
                if n >= max_list then 
                    break 
                end
            end
            table.insert(str, "\n")
        end
    end
    
    --]]
    --[[
    if self.pendingtasks then
        table.insert(str, "-------\nPending tasks:\n")
        for id,task in pairs(self.pendingtasks) do
            if task then
                table.insert(str, tostring(id)..": "..task.name.. " " ..task.tick)
            end
        end
    end
    --]]
    return table.concat(str, "")
end

function EntityScript:KillTasks()
    KillThreadsWithID(self.GUID)
end


function EntityScript:StartThread( fn )
    local thread = StartThread(fn, self.GUID)
    return thread
end

function EntityScript:RunScript(name)
    local fn = LoadScript(name)
    fn(self)
end

function EntityScript:RestartBrain()
	self:StopBrain()
	if self.brainfn then
		--if type(self.brainfn) ~= "table" then print(self, self.brainfn) end
		self.brain = self.brainfn()
		if self.brain then
	        self.brain.inst = self
			self.brain:Start()
		end
	end
end

function EntityScript:StopBrain(brainfn)
    if self.brain then
        self.brain:Stop()
    end
	self.brain = nil
end


function EntityScript:SetBrain(brainfn)
	self.brainfn = brainfn
	if self.brain then
		self:RestartBrain()
	end
end


function EntityScript:SetStateGraph(name)
	if self.sg then
		SGManager:RemoveInstance(self.sg)
	end
    local sg = LoadStateGraph(name)
    assert(sg)
    if sg then
        self.sg = StateGraphInstance(sg, self)
        SGManager:AddInstance(self.sg)
        self.sg:GoToState(self.sg.sg.defaultstate)
        return self.sg
    end
end

function EntityScript:ClearStateGraph()
	if self.sg then
		SGManager:RemoveInstance(self.sg)
		self.sg = nil
	end
end

local function AddListener(t, event, inst, fn)
    local listeners = t[event]
    if not listeners then
        listeners = {}
        t[event] = listeners
    end
    
    local listener_fns = listeners[inst]
    if not listener_fns then
        listener_fns = {}
        listeners[inst] = listener_fns
    end
    
    --source.event_listeners[event][self][1]

    table.insert(listener_fns, fn)
end

function EntityScript:ListenForEvent(event, fn, source)
    --print ("Listen for event", self, event, source)
    source = source or self
    
    if not source.event_listeners then
		source.event_listeners = {}
	end

    AddListener(source.event_listeners, event, self, fn)


    if not self.event_listening then
		self.event_listening = {}
    end
	
    AddListener(self.event_listening, event, source, fn)

end

local function RemoveListener(t, event, inst, fn)
    if t then
        local listeners = t[event]
        if listeners then
            local listener_fns = listeners[inst]
            if listener_fns then
                RemoveByValue(listener_fns, fn)
                if next(listener_fns) == nil then
                    listeners[inst] = nil
                end
            end
            if next(listeners) == nil then
                t[event] = nil
            end
        end
    end
end


function EntityScript:RemoveEventCallback(event, fn, source)
    assert(type(fn) == "function") -- signature change, fn is new parameter and is required

    source = source or self

    RemoveListener(source.event_listeners, event, self, fn)
    RemoveListener(self.event_listening, event, source, fn)

end

function EntityScript:RemoveAllEventCallbacks()
    
    --self.event_listening[event][source][1]

    --tell others that we are no longer listening for them
    if self.event_listening then
		for event, sources  in pairs(self.event_listening) do
            for source, fns in pairs(sources) do
                if source.event_listeners then
                    local listeners = source.event_listeners[event]
                    if listeners then
                        listeners[self] = nil
                    end
                end
            end
		end
		self.event_listening = nil
	end    
    
    --tell others who are listening to us to stop
    if self.event_listeners then
		for event, listeners in pairs(self.event_listeners) do
			for listener, fns in pairs(listeners) do
				if listener.event_listening then
                    local sources = listener.event_listening[event]
                    if sources then
                        sources[self] = nil
                    end
				end
			end
		end
	    self.event_listeners = nil
	end
end

function EntityScript:PushEvent(event, data)
	if self.event_listeners then
		local listeners = self.event_listeners[event]
		if listeners then
			for entity, fns in pairs(listeners) do
				for i,fn in ipairs(fns) do
					fn(self, data)
				end
			end
		end
	end
	    
    if self.sg then
        if self.sg:IsListeningForEvent(event) then
            if SGManager:OnPushEvent(self.sg) then
				self.sg:PushEvent(event, data)
			end
        end
    end
    
    if self.brain then
        self.brain:PushEvent(event, data)
    end
end

function EntityScript:GetPosition()
    return Point(self.Transform:GetWorldPosition())
end

function EntityScript:GetRotation()
   return self.Transform:GetRotation()
end

function EntityScript:GetIsOnWater(x, y, z)
    if not x then
        x, y, z = self.Transform:GetWorldPosition()
    end

    --local pt = self:GetPosition()
    local ground = GetWorld()
    --[[local tile = GROUND.GRASS
    if ground and ground.Map then
        tile = ground.Map:GetTileAtPoint(pt.x, pt.y, pt.z)
    end]]

    if not x or not y or not z then
        -- not in the world
        return false
    else
        local tile, tileinfo = self:GetCurrentTileType(x, y, z)
        return ground.Map:IsWater(tile)
    end
end

function EntityScript:GetIsOnLand(x, y, z)
    if not x then
        x, y, z = self.Transform:GetWorldPosition()
    end

    local ground = GetWorld()
    local tile, tileinfo = self:GetCurrentTileType(x, y, z)
    return ground.Map:IsLand(tile)
end

function EntityScript:GetIsInInterior(x, y, z)
    if not x then
        x, y, z = self.Transform:GetWorldPosition()
    end

    local ground = GetWorld()
    local tile, tileinfo = self:GetCurrentTileType(x, y, z)
    return (tile == GROUND.INTERIOR)
end

function EntityScript:GetIsOnLandOutside(x, y, z)
    if not x then
        x, y, z = self.Transform:GetWorldPosition()
    end

    local ground = GetWorld()
    local tile, tileinfo = self:GetCurrentTileType(x, y, z)
	--print("TILE:",tile)
	--print("ground.Map:IsLand(tile)",ground.Map:IsLand(tile))
	--print("returning",ground.Map:IsLand(tile) and not (tile == GROUND.INTERIOR))
    return ground.Map:IsLand(tile) and not (tile == GROUND.INTERIOR)
end

function EntityScript:GetIsOnTileType(tileType)
    local pt = self:GetPosition()
    local ground = GetWorld()
    return ground and ground.Map and ground.Map:GetTileAtPoint(pt.x, pt.y, pt.z) == tileType
end

function EntityScript:IsPosSurroundedByWater(x, y, z, radius)
    local ground = GetWorld()

    for i = -radius, radius, 1 do
        if not  ground.Map:IsWater(ground.Map:GetTileAtPoint(x - radius, y, z + i)) or not  ground.Map:IsWater(ground.Map:GetTileAtPoint(x + radius, y, z + i)) then
            return false
        end
    end
    for i = -(radius - 1), radius - 1, 1 do
        if not  ground.Map:IsWater(ground.Map:GetTileAtPoint(x + i, y, z -radius)) or not  ground.Map:IsWater(ground.Map:GetTileAtPoint(x + i, y, z + radius)) then
            return false
        end
    end
    return true
end


function EntityScript:IsPosSurroundedByLand(x, y, z, radius)
    local ground = GetWorld()

    for i = -radius, radius, 1 do
        if  ground.Map:IsWater(ground.Map:GetTileAtPoint(x - radius, y, z + i)) or ground.Map:IsWater(ground.Map:GetTileAtPoint(x + radius, y, z + i)) then
            return false
        end
    end
    for i = -(radius - 1), radius - 1, 1 do
        if ground.Map:IsWater(ground.Map:GetTileAtPoint(x + i, y, z -radius)) or ground.Map:IsWater(ground.Map:GetTileAtPoint(x + i, y, z + radius)) then
            return false
        end
    end
    return true
end

function EntityScript:IsPosSurroundedByTileType(x, y, z, radius, tiletype)
    local ground = GetWorld()

    for i = -radius, radius, 1 do
        if ground.Map:GetTileAtPoint(x - radius, y, z + i) ~= tiletype or ground.Map:GetTileAtPoint(x + radius, y, z + i) ~= tiletype then
            return false
        end
    end
    for i = -(radius - 1), radius - 1, 1 do
        if ground.Map:GetTileAtPoint(x + i, y, z -radius) ~= tiletype or ground.Map:GetTileAtPoint(x + i, y, z + radius) ~= tiletype then
            return false
        end
    end
    return true
end


function EntityScript:GetAngleToPoint(x, y, z)
	if not x then
		return 0
	end

    if x and not y and not z then
        x, y, z = x:Get()
    end    

    local px, py, pz = self.Transform:GetWorldPosition()
    local dz = pz - z
    local dx = x - px
    local angle = math.atan2(dz, dx) / DEGREES
    return angle
end

function EntityScript:ForceFacePoint(x, y, z)

    if not x then
		return 
	end

    if x and not y and not z then
        x, y, z = x:Get()
    end

    local angle = self:GetAngleToPoint(x, y, z)
    self.Transform:SetRotation(angle)
end

function EntityScript:FacePoint(x, y, z)
    if self.sg and self.sg:HasStateTag("busy") then
        return
    end
    
    if not x then
		return 
	end

    if x and not y and not z then
        x, y, z = x:Get()
    end

    local angle = self:GetAngleToPoint(x, y, z)
    self.Transform:SetRotation(angle)
end

-- consider using IsNear if you're checking if something is inside/outside a certain horizontal distance
function EntityScript:GetDistanceSqToInst(inst)
    local p1x, p1y, p1z = self.Transform:GetWorldPosition()
    local p2x, p2y, p2z = inst.Transform:GetWorldPosition()
        
    assert(p1x and p1z, "Something is wrong: self.Transform:GetWorldPosition() stale component reference?")
    assert(p2x and p2z, "Something is wrong: inst.Transform:GetWorldPosition() stale component reference?")
    
    return distsq(p1x, p1z, p2x, p2z)
end

-- excludes vertical distance
function EntityScript:GetHorzDistanceSqToInst(inst)
    local pos1 = self:GetPosition()
    pos1.y = 0
    local pos2 = inst:GetPosition()
    pos2.y = 0

    return distsq(pos1, pos2)
end

function EntityScript:IsNear(otherinst, dist)
    return otherinst and self:GetHorzDistanceSqToInst(otherinst) < dist*dist
end

function EntityScript:GetDistanceSqToPoint(point)
    local pos2 = Point(self.Transform:GetWorldPosition())
    return distsq(point, pos2)
end

function EntityScript:FaceAwayFromPoint(dest, force)
    if not force and (self.sg and self.sg:HasStateTag("busy")) then
        return
    end
    
    local pos = Point(self.Transform:GetWorldPosition())
    local dz = pos.z - dest.z
    local dx = dest.x - pos.x
    local angle = math.atan2(dz, dx) / DEGREES + 180
    self.Transform:SetRotation(angle)
end

function EntityScript:IsAsleep()
    return not self.entity:IsAwake()
end

function EntityScript:CancelAllPendingTasks()
    if self.pendingtasks then
		for k,v in pairs(self.pendingtasks) do
	        k:Cancel()
	    end
	    self.pendingtasks = nil
	end
end

local function task_finish(task, success, inst)
	--print ("TASK DONE", task, success, inst)
	if inst and inst.pendingtasks and inst.pendingtasks[task] then
		inst.pendingtasks[task] = nil
	else
		print ("   NOT FOUND")
	end
end

function EntityScript:DoPeriodicTask(time, fn, initialdelay, ...)
	--print ("DO PERIODIC", time, self)
    local per = scheduler:ExecutePeriodic(time, fn, nil, initialdelay, self.GUID, self, ...)

    if not self.pendingtasks then
		self.pendingtasks = {}
    end
    
    self.pendingtasks[per] = true
    per.onfinish = task_finish --function() if self.pendingtasks then self.pendingtasks[per] = nil end end
    return per
end

function EntityScript:DoTaskInTime(time, fn, ...)
   --print ("DO TASK IN TIME", time, self)
   -- assert(self:IsValid())
    if not self.pendingtasks then
		self.pendingtasks = {}
    end
    
    local per = scheduler:ExecuteInTime(time, fn, self.GUID, self, ...)
    self.pendingtasks[per] = true
    per.onfinish = task_finish -- function() if self and self.pendingtasks then self.pendingtasks[per] = nil end end
    return per
end

function EntityScript:GetTaskInfo(time)
    local taskinfo = {}
    taskinfo.start = GetTime()
    taskinfo.time = time
    return taskinfo
end

function EntityScript:TimeRemainingInTask(taskinfo)
    local timeleft = (taskinfo.start + taskinfo.time) - GetTime()
    if timeleft < 1 then timeleft = 1 end
    return timeleft
end

function EntityScript:ResumeTask(time, fn, ...)
    local task = self:DoTaskInTime(time, fn, ...)
    local taskinfo = self:GetTaskInfo(time)

    return task, taskinfo
end

function EntityScript:ClearBufferedAction()
    if self.bufferedaction then
        self.bufferedaction:Fail()
        self.bufferedaction = nil
    end
end

function EntityScript:InterruptBufferedAction()
	self:ClearBufferedAction()
end

-- local ACTIONS_DICT = {}
local _init_ACTIONS_DICT_flag = false
local function init_ACTIONS_DICT()
    if not _init_ACTIONS_DICT_flag then
        _init_ACTIONS_DICT_flag = true
        for k,v in pairs(ACTIONS ) do
            v.__name = k
        end
    end
end

function EntityScript:PushBufferedAction(bufferedaction)
    init_ACTIONS_DICT()

    if self == GetPlayer() then
        -- print(GetTime() .. " PushBufferedAction " .. (bufferedaction.action and bufferedaction.action.__name or "?"))
        -- print (debugstack())
    end

	local dupe = bufferedaction and self.bufferedaction
	            and bufferedaction.target == self.bufferedaction.target
	            and bufferedaction.action == bufferedaction.action
	            and bufferedaction.inv_obj == bufferedaction.inv_obj
	            and not (self.sg and self.sg:HasStateTag("idle"))
	            
	if dupe then
		return
	end

    if self.bufferedaction then
        self.bufferedaction:Fail()
        self.bufferedaction = nil
    end
    
    local success, reason = bufferedaction:TestForStart()

    if not success then
        self:PushEvent("actionfailed", {action = bufferedaction, reason = reason})
        return
    end
    
    --walkto is kind of a nil action - the locomotor will have put us at the destination by now if we get to here
    if bufferedaction.action == ACTIONS.WALKTO then
        bufferedaction:Succeed()
        self.bufferedaction = nil
    elseif bufferedaction.action.instant then
        if bufferedaction.target and bufferedaction.target.Transform and (not self.sg or self.sg:HasStateTag("canrotate")) then
            self:FacePoint(bufferedaction.target.Transform:GetWorldPosition())
        end
        
        bufferedaction:Do()
        self.bufferedaction = nil
        
    else


        self.bufferedaction = bufferedaction
        if not self.sg then
            self:PushEvent("startaction", {action = bufferedaction})
        elseif not self.sg:StartAction(bufferedaction) then
            self.bufferedaction:Fail()
            self.bufferedaction = nil
        end
    end
end


function EntityScript:PerformBufferedAction()

	
    if self.bufferedaction then
       
        if self.bufferedaction.target and self.bufferedaction.target:IsValid() and self.bufferedaction.target.Transform then
            self:FacePoint(self.bufferedaction.target.Transform:GetWorldPosition())
        end
                
        local success, reason = self.bufferedaction:Do()

        if success then
            self:PushEvent("actionsuccess", {action = self.bufferedaction})
            self.bufferedaction = nil   
            return true
        end
        self:PushEvent("actionfailed", {action = self.bufferedaction, reason = reason})
        self.bufferedaction:Fail()
        self.bufferedaction = nil
    end
end

function EntityScript:GetBufferedAction()
    if self.bufferedaction then
        return self.bufferedaction
    elseif self.components.locomotor then
        return self.components.locomotor.bufferedaction
    end
end

function EntityScript:OnBuilt(builder)
    for k,v in pairs(self.components) do
        if v.OnBuilt then
            v:OnBuilt(builder)
        end
    end
end

function EntityScript:SinkIfOnWater()
    if self:GetIsOnWater() and self.Transform then
        local x, y, z = self.Transform:GetWorldPosition()
        if x and y and z then
            local fx = SpawnPrefab("splash_water_sink")
            fx.Transform:SetPosition(x, y, z)
            if self.SoundEmitter then
                self.SoundEmitter:PlaySound("dontstarve_DLC002/common/item_sink")
            end
        end

        local tile = GetWorld().Map:GetTileAtPoint(x, y, z)

        if tile ~= GROUND.OCEAN_DEEP and
            self.components.inventoryitem and
            self.components.inventoryitem.cangoincontainer and
            self.persists then
                SpawnPrefab("sunkenprefab"):Initialize(self)
        end

        self:Remove()
        return true
    end
    return false
end

function EntityScript:Remove()

    if self.parent then
        self.parent:RemoveChild(self)
    end
    
	OnRemoveEntity(self.GUID)    
	
    self:PushEvent("onremove")
    
    --tell our listeners to forget about us
    self:RemoveAllEventCallbacks()
    self:CancelAllPendingTasks()
    
    for k,v in pairs(self.components) do
        if v.OnRemoveEntity then
            v:OnRemoveEntity()
        end
    end
    
    if self.interior then
        local interiorSpawner = GetWorld().components.interiorspawner
        interiorSpawner:removeprefab(self, self.interior)
    end
    
    if self.updatecomponents then
        self.updatecomponents = nil
        NewUpdatingEnts[self.GUID] = nil
        UpdatingEnts[self.GUID] = nil
        num_updating_ents = num_updating_ents - 1
    end

    --UpdatingEnts[self.GUID] = nil

    if self.wallupdatecomponents then
        self.wallupdatecomponents = nil
        WallUpdatingEnts[self.GUID] = nil
    end
    
    
    if self.children then
		for k,v in pairs(self.children) do
			k.parent = nil
			k:Remove()
		end
	end
    
    if self.OnRemoveEntity then
		self.OnRemoveEntity(self)
    end
    self.persists = false
    self.retired = true
    self.entity:Retire()
    
    
end

function EntityScript:IsValid()
    return self.entity:IsValid() and not self.retired
end

function EntityScript:CanInteractWith(inst)
    if not inst:IsValid() then
        return false
    end
    local parent = inst.entity:GetParent()
    if parent and parent ~= self then
        return false
    end
    
    return true
end


function EntityScript:IsActionValid(action, right)

    if action.rmb and action.rmb ~= right then
        return false
    end
    for k,v in pairs(self.components) do
        if v.IsActionValid and v:IsActionValid(action, right) then
            return true
        end
    end
end


function EntityScript:OnUsedAsItem(action)
    for k,v in pairs(self.components) do
        if v.OnUsedAsItem then
            v:OnUsedAsItem(action)
        end
    end
end

function EntityScript:CanDoAction(action)
    if self.inherentactions and self.inherentactions[action] then
        return true
    end
    
    if self.components.tool and self.components.tool.action == action then
        return true
    end
    
    if self.components.inventory then
        local item = self.components.inventory:GetActiveItem()
        
        if item and item:CanDoAction(action) then
            return true
        end
        
        item = self.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        if item and item:CanDoAction(action) then
            return true
        end

        item = self.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
        if item and item:CanDoAction(action) then
            return true
        end           
        
    end
    
end

function EntityScript:IsOnValidGround()
	local tile = self:GetCurrentTileType()
	return tile and tile ~= GROUND.IMPASSABLE
end


function EntityScript:GetCurrentTileType(x,y,z)

    if GetWorld().Map then
        local ptx, pty, ptz
        if x and y and z then 
            ptx = x
            pty = y
            ptz = z
        else
            ptx, pty, ptz = self.Transform:GetWorldPosition()
        end 
		
        if(ptx == nil or ptz == nil) then 
            print(debug.traceback())
        end
        assert(ptx ~= nil and ptz ~= nil, "trying to get tiletype for a nil position!")

        return GetVisualTileType(ptx, pty, ptz)
	end
    return nil
  
end

function EntityScript:GetPersistData()
    local references = nil
    local data = nil
    for k,v in pairs(self.components) do
        if v.OnSave then
            local t, refs = v:OnSave()
            if type(t) == "table" then
				if t and next(t) and not data then
					data = {}
				end
				if t and data then
					data[k] = t
				end
			end
			
			if refs then
				if not references then
					references = {}
				end
				for k,v in pairs(refs) do
					
					table.insert(references, v)
				end
			end
        end
    end
    
    if self.OnSave then
        if not data then
            data = {}
        end

        local refs = self.OnSave(self, data)

        if refs then
            if not references then
                references = {}
            end
            for k,v in pairs(refs) do
                
                table.insert(references, v)
            end
        end
        
    end

    if self:HasTag("INTERIOR_LIMBO") then
        if not data then
            data = {}
        end
        --print("THIS IS IN INTERIOR LIMBO", self.prefab)
        data.interior_limbo = true
		data.interior_id = self.interior

        if self.dissablephysics then
            data.dissablephysics = true
        end
    end

    if self.RuntimeComponents then
        if not data then data = {} end
        data.RuntimeComponents = {}
        for k,v in pairs(self.RuntimeComponents) do
            if v then
                table.insert(data.RuntimeComponents, v)
            end
        end
    end
    
	
	if self.origspawnedFrom then
        if not data then data = {} end
		data.origspawnedFrom = self.origspawnedFrom
	end

    if (data and next(data)) or references then
		return data, references
    end
end

function EntityScript:LoadPostPass(newents, savedata)
    
    if savedata then
        for k,v in pairs(savedata) do
            local cmp = self.components[k]
            if cmp and cmp.LoadPostPass then
                cmp:LoadPostPass(newents, v)
            end
        end
    end    
    
    if self.OnLoadPostPass then
        self:OnLoadPostPass(newents, savedata)
    end
end



function EntityScript:SetPersistData(data, newents)
    if data and data.citypossession then
        if not self.components.citypossession then
            self:AddComponent("citypossession")
        end
        self.components.citypossession:SetCity( data.citypossession.cityID )
    end

    if data and data.RuntimeComponents then
        for k,v in pairs(data.RuntimeComponents) do
            self:AddComponentAtRuntime(v)
        end
    end	

	if self.OnPreLoad then
		self:OnPreLoad(data, newents)
	end
    
    if data then
        for k,v in pairs(data) do
            local cmp = self.components[k]
            if cmp and cmp.OnLoad then
                cmp:OnLoad(v, newents)
            end
        end
    end

    if self.OnLoad then
        self:OnLoad(data, newents)
    end

    if data and data.interior_limbo then        
        --print("this thing should be in limbo",self.prefab)
        self:AddTag("INTERIOR_LIMBO")
        self:RemoveFromScene() 
		self.interior = data.interior_id or GetInteriorSpawner():getPropInterior(self)
                       
        if self.SoundEmitter then
            self.SoundEmitter:OverrideVolumeMultiplier(0)
        end
    end
    if data and data.dissablephysics then        
        self.dissablephysics = data.dissablephysics
    end    

	if data and data.origspawnedFrom then
		self.origspawnedFrom = data.origspawnedFrom
	else
		self.origspawnedFrom = { source = "*already existed*", line = -1 }
	end
end

function EntityScript:GetAdjective()

	for k,v in pairs(self.components) do
		if v.GetAdjective then
			local str = v:GetAdjective()
			if str then
				return str
			end
		end
	end
end

function EntityScript:SetProfile(profile)
    self.profile = profile
    if profile then
        for k,v in pairs(self.components) do
            if v.OnSetProfile then
                v:OnSetProfile(profile)
            end
        end
    end
    
    if self.OnSetProfile then
        self:OnSetProfile(profile)
    end
    
    self:PushEvent("onsetprofile", {})
    
end


function EntityScript:SetInherentSceneAction(action)
	self.inherentsceneaction = action
end

function EntityScript:SetInherentSceneAltAction(action)
	self.inherentscenealtaction = action
end

function EntityScript:LongUpdate(dt)

	if self.OnLongUpdate then
		self:OnLongUpdate(dt)
	end

	for k,v in pairs(self.components) do
		if v.LongUpdate then
			v:LongUpdate(dt)
		end
	end

end

function EntityScript:GetPhysicsRadius(default)
    return self.physicsradiusoverride or (self.Physics ~= nil and self.Physics:GetRadius()) or default
end

function EntityScript:SetAddColour(r,g,b,a)
    self.addcolourdata = {r=r,g=g,b=b,a=a}
    if self.AnimState then
        self.AnimState:SetAddColour(r,g,b,a)
    end
end
