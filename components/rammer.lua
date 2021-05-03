

local Rammer = Class(function(self, inst)
    self.inst = inst
    self.minSpeed = 2.0
    self.cooldown = 0.0
    self.checkRadius = 3
    self.hitRadius = 1

    self.wasActive = false

    self.ramFilters = {}
    self.onActivate = function() end
    self.onDeactivate = function() end
    self.onUpdate = function(dt) end
    self.onRamTarget = function(target) end

    if self.inst == nil then
        error("Rammer Component needs to be initialized with a valid Entity instance!")
    end

    self.inst:StartUpdatingComponent(self)
end)

function Rammer:StartCooldown()
    self.cooldown = 5 * FRAMES
end

function Rammer:CheckRamHit()

    if self.inst == nil or self.inst:IsValid() == false then
        print("Component instance is invalid!")
        return
    end

    if self.onRamTarget == nil then
        return
    end

    local driver = self:FindDriver()

    if driver == nil then
        print("could not determine quackeringRam's driver, are you using a dev-teleport-boat?")
        return
    end

    local driverVelocity = Vector3(driver.Physics:GetVelocity())

	local function isInHitCone(item)
		local origin = Vector3(self.inst.Transform:GetWorldPosition())
        local point = Vector3(item.Transform:GetWorldPosition())

        local d = (point - origin)
        d = d:GetNormalized()

        if driver == nil or driver.Physics == nil or item == nil or item.Physics == nil then
            return false
        end

        local maxDistance = self.hitRadius + driver.Physics:GetRadius() + item.Physics:GetRadius()

        local l = d:LengthSq()
        if l > (maxDistance * maxDistance) then
            return false
        else
            local v = driverVelocity:GetNormalized()
            local dot = v:Dot(d)
            return dot > 0.75
        end
	end

    local yestags = {}
    local notags = {"falling", "FX", "NOCLICK", "DECOR", "INLIMBO","unramable"}

    local pos = Vector3(self.inst.Transform:GetWorldPosition())
    local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, driver.Physics:GetRadius() + self.hitRadius * 2, yestags, notags)

    for i=#ents, 1, -1 do
        local item = ents[i]
        local remove = false

        if item.components.health and item.components.health.currenthealth <= 0 then
            remove = true
        end

        local driver = self:FindDriver()
        
        if not remove and item:HasTag("shadow") and driver.components.sanity and not driver.components.sanity:IsCrazy() then
            remove = true
        end

        if remove then
            table.remove(ents,i)
        end
    end

    -- foreach entity, notify callback
    for k, v in pairs(ents) do
        if v ~= driver then -- avoid self-ramming
            if isInHitCone(v) then           
                self.onRamTarget(self.inst, v)
            end
        end
    end
end


function Rammer:OnUpdate(dt)

    local isActive = self:IsActive()

    -- toggle on/off callbacks
    if isActive == true and self.wasActive == false then
        self.onActivate()
    elseif isActive == false and self.wasActive == true then
        self.onDeactivate()
    end

    if isActive then
        self:CheckRamHit()

        if self.onUpdate ~= nil then
            self.onUpdate(dt)
        end
    end
    --self:DebugRender()

    if self.cooldown > 0.0 then
        self.cooldown = self.cooldown - dt
    elseif self.cooldown < 0.0 then
        self.cooldown = 0.0
    end

    self.wasActive = isActive
end

function Rammer:FindDriver()
    local driver = nil

    if self.inst == nil or self.inst:IsValid() == false then
        return nil
    end

    if self.inst.equippedby ~= nil then
        if self.inst.equippedby.components.drivable.driver ~= nil then
            driver = self.inst.equippedby.components.drivable.driver
        end
    end

    return driver
end

function Rammer:IsActive()
    -- TODO: consider storing the driver whenever it changes to avoid the constant lookup
    local driver = self:FindDriver()

    if driver == nil then
        return false
    end

    local v = Vector3(driver.Physics:GetVelocity())
    local minSpeedSq = self.minSpeed * self.minSpeed

    return (v:LengthSq() >= minSpeedSq) and (self.cooldown <= 0.0)
end


function Rammer:DebugRender()
    if TheSim:GetDebugRenderEnabled() then
        if self.inst.draw then
            self.inst.draw:Flush()
            self.inst.draw:SetRenderLoop(true)
            self.inst.draw:SetZ(0.15)

            local dim = 2.0 * self.range
            local x, y, z = self.inst.Transform:GetWorldPosition()

            self.inst.draw:Box(x - self.range, z - self.range, dim, dim, 0, 1, 0, 1)
        else
            --TheSim:SetDebugRenderEnabled(true)
            self.inst.draw = self.inst.entity:AddDebugRender()
        end
    end
end

return Rammer
