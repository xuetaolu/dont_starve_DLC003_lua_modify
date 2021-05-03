
local function DoSpawn(inst)
    local spawner = inst.components.periodicspawner
    if spawner then
		spawner.target_time = nil    
		spawner:TrySpawn()
        spawner:Start()
    end
end

local PeriodicSpawner = Class(function(self, inst)
    self.inst = inst
    self.basetime = 40
    self.randtime = 60
    self.prefab = nil
    self.chancetable = nil 
    
    self.range = nil
    self.density = nil
    self.spacing = nil
    
    self.onspawn = nil 
    self.spawntest = nil
    
    self.spawnoffscreen = false 
end)

function PeriodicSpawner:SetPrefab(prefab)
    self.prefab = prefab
end

function PeriodicSpawner:SetRandomTimes(basetime, variance, no_reset)
    self.basetime = basetime
    self.randtime = variance
    if self.task and not no_reset then
        self:Stop()
        self:Start()
    end
end

function PeriodicSpawner:SetDensityInRange(range, density)
    self.range = range
    self.density = density
end

function PeriodicSpawner:SetMinimumSpacing(spacing)
    self.spacing = spacing
end

function PeriodicSpawner:SetOnlySpawnOffscreen(offscreen)
    self.spawnoffscreen = offscreen
end

function PeriodicSpawner:SetOnSpawnFn(fn)
    self.onspawn = fn
end

function PeriodicSpawner:SetSpawnTestFn(fn)
    self.spawntest = fn
end

function PeriodicSpawner:TrySpawn(prefab)
    local chanceprefab = nil
    if self.chancetable ~= nil then 
        local totalchance = 0 
        --add up all the odds 
        for k,v in ipairs(self.chancetable) do 
            totalchance = totalchance + v[2]
        end 

        local rand = math.random() * totalchance 

        totalchance = 0 
         for k,v in ipairs(self.chancetable) do 
            totalchance = totalchance + v[2]
            if rand <= totalchance then 
                chanceprefab = v[1]
                break
            end 
        end 
    end

    prefab = prefab or self.prefab or chanceprefab

    if not self.inst:IsValid() or not prefab then
        return
    end
    
    local canspawn = true
    
    if self.range or self.spacing then
        local pos = Vector3(self.inst.Transform:GetWorldPosition())
        local ents = TheSim:FindEntities(pos.x,pos.y,pos.z, self.range or self.spacing)
        local count = 0
        for k,v in pairs(ents) do
            if v.prefab == prefab then
                if self.spacing and v:GetDistanceSqToInst(self.inst) < self.spacing*self.spacing then
                    canspawn = false
                    break
                end
                count = count + 1
            end
        end
        if self.density and count >= self.density then
            canspawn = false
        end
    end
    
    if self.spawnoffscreen and not self.inst:IsAsleep() then
        canspawn = false
    end
    
    if self.spawntest then
        canspawn = canspawn and self.spawntest(self.inst)
    end

    if self.inst:HasTag("INTERIOR_LIMBO") then
        canspawn = false
    end
    if canspawn then
        local inst = SpawnPrefab(prefab)
        -- transform first incase the callback wants to change it

        inst.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
       
        if inst.components.inventoryitem then
            inst.components.inventoryitem:OnDropped()
        end
 
        if self.onspawn then
            self.onspawn(self.inst, inst)
        end
        return canspawn, inst
    end
    return canspawn
end

function PeriodicSpawner:Start()
    local t = self.basetime + math.random()*self.randtime
    self.target_time = GetTime() + t
    self.task = self.inst:DoTaskInTime(t, DoSpawn)
end


function PeriodicSpawner:Stop()
    self.target_time = nil
    if self.task then
        self.task:Cancel()
        self.task = nil
    end
end

--[[
function PeriodicSpawner:OnEntitySleep()
	self:Stop()
end

function PeriodicSpawner:OnEntityWake()
	self:Start()
end
--]]

function PeriodicSpawner:LongUpdate(dt)
	if self.target_time then
		if self.task then
			self.task:Cancel()
			self.task = nil
		end
		local time_to_wait = self.target_time - GetTime() - dt
		
		if time_to_wait <= 0 then
			DoSpawn(self.inst)		
		else
			self.target_time = GetTime() + time_to_wait
			self.task = self.inst:DoTaskInTime(time_to_wait, DoSpawn)
		end
	end
end

return PeriodicSpawner