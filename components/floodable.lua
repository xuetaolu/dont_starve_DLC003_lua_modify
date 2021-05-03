local Floodable = Class(function(self, inst)
    self.inst = inst
    self.onStartFlooded = nil 
    self.onStopFlooded = nil 
    self.flooded = false 
    self.floodEffect = nil 
    self.floodSound = nil
    self.timeToEffect = 0
    self.fxPeriod = 5
end)

function Floodable:OnEntitySleep()
    self.inst:StopUpdatingComponent(self)
end

function Floodable:OnEntityWake()
    self.inst:StartUpdatingComponent(self)
end

function Floodable:OnUpdate(dt)
    local onFlood = self.inst:GetIsFlooded()

    if onFlood and not self.flooded then 
        self.flooded = true 
        self.inst:AddTag("flooded")
        if self.onStartFlooded then 
            self.onStartFlooded(self.inst)
        end 

    elseif not onFlood and self.flooded then 
        self.flooded = false 
        self.inst:RemoveTag("flooded")
        if self.onStopFlooded then 
            self.onStopFlooded(self.inst)
        end 
    end 

    if self.flooded then 
        if self.floodEffect then 
            self.timeToEffect = self.timeToEffect - dt
            if self.timeToEffect <= 0 then 
                local fx = SpawnPrefab(self.floodEffect)
                if fx then 
                    local pt = self.inst:GetPosition()
                    fx.Transform:SetPosition(pt.x, pt.y, pt.z)
                end 
                if self.floodSound and self.inst.SoundEmitter then
                    self.inst.SoundEmitter:PlaySound(self.floodSound)
                end
                self.timeToEffect = self.fxPeriod
            end 
        end 
    end 
end


return Floodable
