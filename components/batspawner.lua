local trace = function() end
-- local trace = function(inst, ...)
-- 	if inst.prefab == "beebox" then
-- 		print(inst, ...)
-- 	end
-- end

--- Spawns and tracks child entities in the world
-- For setup the following params should be set
-- @param childname The prefab name of the default child to be spawned. This can be overridden in the SpawnChild method
-- @param delay The time between spawning children when the spawner is actively spawning. If nil, only manual spawning works.
-- @param newchilddelay The time it takes for a killed/captured child to be regenerated in the BatSpawner. If nil, dead children aren't regenerated.
-- It's also a good idea to call SetMaxChildren as part of the BatSpawner setup.
local BatSpawner = Class(function(self, inst)
	self.inst = inst
	self.childrenoutside = {}
	self.maxchildren = 0
	self.spawnpoints = {}
	
	self.childname = ""
    
    self.regening = true
    self.timetonextregen = 0
    self.regenperiod = 20
	self.regenvariance = 2
    self.spawnoffscreen = false

    self.nooffset = nil
end)

function BatSpawner:InitSpawns()
	local pos = Vector3(self.inst.Transform:GetWorldPosition())
	local start_angle = math.random()*PI*2
	local rad = 2.5
end 

function BatSpawner:StartRegen()
	self.regening = true
	
	if self.numchildrenoutside + self.childreninside < self.maxchildren then
		self.timetonextregen = self.regenperiod + (math.random()*2-1)*self.regenvariance
		self:StartUpdate(6)
	end
end

function BatSpawner:SetRareChild(childname, chance)
	self.rarechild = childname
	self.rarechildchance = chance
end

function BatSpawner:StopRegen()
	self.regening = false
end

function BatSpawner:SetSpawnPeriod(period, variance)
	self.spawnperiod = period
	self.spawnvariance = variance or period * 0.1
end

function BatSpawner:SetRegenPeriod(period, variance)
	self.regenperiod = period
	self.regenvariance = variance or period * 0.1
end

function BatSpawner:OnUpdate(dt)
	
	if self.regening then
		if self.numchildrenoutside + self.childreninside < self.maxchildren then
			self.timetonextregen = self.timetonextregen - dt
			if self.timetonextregen < 0 then
				self.timetonextregen = self.regenperiod + (math.random()*2-1)*self.regenvariance
				self:AddChildrenInside(1)
			end
		else
			self.timetonextregen = self.regenperiod + (math.random()*2-1)*self.regenvariance
		end
	end
	
	local need_to_continue_regening = self.regening and self.numchildrenoutside < self.maxchildren
	
	
	if not need_to_continue_regening then
		if self.task then
			self.task:Cancel()
			self.task = nil
		end
		--self.inst:StopUpdatingComponent(self)
	end
end

function BatSpawner:StartUpdate(dt)
	if not self.task then
		local dt = 5 + math.random()*5 
		self.task = self.inst:DoPeriodicTask(dt, function() self:OnUpdate(dt) end)
	end
end

function BatSpawner:StartSpawning(timetonextspawn)
	trace(self.inst, "BatSpawner:StartSpawning()")
	self.spawning = true
	self.timetonextspawn = timetonextspawn or 0
	self:StartUpdate(6)
	
end

function BatSpawner:StopSpawning()
	self.spawning = false
end

function BatSpawner:SetOccupiedFn(fn)
    self.onoccupied = fn
end

function BatSpawner:SetSpawnedFn(fn)
    self.onspawned = fn
end

function BatSpawner:SetGoHomeFn(fn)
    self.ongohome = fn
end

function BatSpawner:SetVacateFn(fn)
    self.onvacate = fn
end

function BatSpawner:SetOnAddChildFn(fn)
	self.onaddchild = fn
end

function BatSpawner:CountChildrenOutside(fn)
    local vacantchildren = 0
    for k,v in pairs(self.childrenoutside) do
        if v and v:IsValid() and (not fn or fn(v) ) then
            vacantchildren = vacantchildren + 1
        end
    end
    return vacantchildren
end

function BatSpawner:SetMaxChildren(max)
    self.childreninside = max - self:CountChildrenOutside()
    self.maxchildren = max
    if self.childreninside < 0 then self.childreninside = 0 end
end


function BatSpawner:OnSave()
    local data = {}
	local references = {}

    for k,v in pairs(self.childrenoutside) do
        if not data.childrenoutside then
            data.childrenoutside = {v.GUID}
            
        else
            table.insert(data.childrenoutside, v.GUID)
        end
        
        table.insert(references, v.GUID)
    end
    data.childreninside = self.childreninside

	data.spawning = self.spawning
	data.regening = self.regening
	data.timetonextregen = math.floor(self.timetonextregen)
	data.timetonextspawn = math.floor(self.timetonextspawn)
	data.nooffset = self.nooffset
	
    return data, references
end

function BatSpawner:GetDebugString()
    local str = string.format("%s - %d in, %d out", self.childname, self.childreninside, self.numchildrenoutside )
	
	local num_children = self.numchildrenoutside + self.childreninside
	if num_children < self.maxchildren and self.regening then
		str = str..string.format(" Regen in %2.2f ", self.timetonextregen )
	end
	
	if self.childreninside > 0 and self.spawning then
		str = str..string.format(" Spawn in %2.2f ", self.timetonextspawn )
	end
	
	if self.spawning then
		str = str.."S"
	end

	if self.regening then
		str = str.."R"
	end
	
	return str
end

function BatSpawner:OnLoad(data)
	trace(self.inst, "BatSpawner:OnLoad")
    
    --convert previous data
    if data.occupied then
        data.childreninside = 1
    end
    if data.childid then
        data.childrenoutside = {data.childid}
    end
    
    if data.childreninside then
        self.childreninside = 0
        self:AddChildrenInside(data.childreninside)
        if self.childreninside > 0 and self.onoccupied then
            self.onoccupied(self.inst)
        elseif self.childreninside == 0 and self.onvacate then
            self.onvacate(self.inst)
        end
    end
    
    
	self.spawning = data.spawning or self.spawning
	self.regening = data.regening or self.regening
	self.timetonextregen = data.timetonextregen or self.timetonextregen
	self.timetonextspawn = data.timetonextspawn or self.timetonextspawn
	self.nooffset = data.nooffset or self.nooffset
	
	if self.spawning or self.regening then
		self:StartUpdate(6)
	end
	
end

function BatSpawner:TakeOwnership(child)
    if child.components.knownlocations then
        child.components.knownlocations:RememberLocation("home", Vector3(self.inst.Transform:GetWorldPosition()))
    end
    child:AddComponent("homeseeker")
    child.components.homeseeker:SetHome(self.inst)
	self.inst:ListenForEvent( "ontrapped", function() self:OnChildKilled( child ) end, child )
	self.inst:ListenForEvent( "death", function() self:OnChildKilled( child ) end, child )
	self.inst:ListenForEvent( "pickedup", function() self:OnChildKilled( child ) end, child )
	self.inst:ListenForEvent( "onremove", function() self:OnChildKilled( child ) end, child )
	
	self.childrenoutside[child] = child
	self.numchildrenoutside = self.numchildrenoutside + 1
	
end

function BatSpawner:LoadPostPass(newents, savedata)
	trace(self.inst, "BatSpawner:LoadPostPass")
    if savedata.childrenoutside then
        for k,v in pairs(savedata.childrenoutside) do
            local child = newents[v]
            if child then
                child = child.entity
                self:TakeOwnership(child)
            end
        end
    end
end

function BatSpawner:SpawnChild(target, prefab, radius)
    if not self:CanSpawn() then
        return
    end

	trace(self.inst, "BatSpawner:SpawnChild")

	local pos = Vector3(self.inst.Transform:GetWorldPosition())
	local start_angle = math.random()*PI*2
	local rad = radius or 0.5
	if self.inst.Physics then
		rad = rad + self.inst.Physics:GetRadius()
	end

	if not self.nooffset then
		local offset = FindWalkableOffset(pos, start_angle, rad, 8, false)
		if offset == nil then
			return
		end

		pos = pos + offset
	end

	local childtospawn = prefab or self.childname

	if self.rarechild and math.random() < self.rarechildchance then
		childtospawn = self.rarechild
	end
	
    local child = SpawnPrefab(childtospawn)
    
    if child ~= nil then
        
        child.Transform:SetPosition(pos:Get())
        self:TakeOwnership(child)
        if target and child.components.combat then
            child.components.combat:SetTarget(target)
        end
        
        if self.onspawned then
            self.onspawned(self.inst, child)
        end
		
		if self.childreninside == 1 and self.onvacate then
            self:onvacate(self.inst)
	    end
	    self.childreninside = self.childreninside - 1
	    
		
	end
	return child
end

function BatSpawner:GoHome( child )
    if self.childrenoutside[child] then
        self.inst:PushEvent("childgoinghome", {child = child})
        child:PushEvent("goinghome", {home = self.inst})
        if self.ongohome then
            self.ongohome(self.inst, child)
        end
        child:Remove()
        self.childrenoutside[child] = nil

        self.numchildrenoutside = self.numchildrenoutside - 1
        self:AddChildrenInside(1)
        return true
    end
end


function BatSpawner:CanSpawn()
    if self.childreninside <= 0 then
        return false
    end
    
    if self.inst:IsAsleep() and not self.spawnoffscreen then
		return false
    end
    
    if not self.inst:IsValid() then
        return false
    end
    
    if self.inst.components.health and self.inst.components.health:IsDead() then
        return false
    end

    if self.canspawnfn then
    	self.canspawnfn(self.inst)
    end
    
    return true
end


function BatSpawner:OnChildKilled( child )
    if self.childrenoutside[child] then
        self.childrenoutside[child] = nil
        self.numchildrenoutside = self.numchildrenoutside - 1

        if self.onchildkilledfn then
        	self.onchildkilledfn(self.inst, child)
        end
        
        if self.regening then
			self:StartUpdate(6)
        end
    end
end

function BatSpawner:ReleaseAllChildren(target, prefab)
    while self:CanSpawn() do
        self:SpawnChild(target, prefab)
    end
end

function BatSpawner:AddChildrenInside(count)
    if self.childreninside == 0 and self.onoccupied then
        self.onoccupied(self.inst)
    end
    if self.onaddchild then
    	self.onaddchild(self.inst, count)
    end
    self.childreninside = self.childreninside + count
    if self.maxchildren then
        self.childreninside = math.min(self.maxchildren, self.childreninside)
    end
end

function BatSpawner:LongUpdate(dt)
	if self.spawning then
		self:OnUpdate(dt)
	end
end


return BatSpawner

