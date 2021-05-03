local Distancefade = Class(function(self, inst)	
    self.inst = inst
    self.inst:StartUpdatingComponent(self)

    self.range =  25
    self.fadedist = 15
end)

function Distancefade:Setup(range,fadedist)
  self.range = range
  self.fadedist = fadedist
end

function Distancefade:SetExtraFn(fn)
  self.extrafn = fn
end


function Distancefade:OnEntitySleep()
  self.inst:StopUpdatingComponent(self)
end

function Distancefade:OnEntityWake()
  self.inst:StartUpdatingComponent(self)
end


function Distancefade:OnUpdate(dt)

    local player = GetPlayer()
    local x,y,z = player.Transform:GetWorldPosition()
    local x1,y1,z1 = self.inst.Transform:GetWorldPosition()

    local distx = math.abs(x1-x)
    local distz = math.abs(z1-z)
    local dist = (distx*distx) + (distz*distz)

    local extrapercent = 1
    if self.extrafn then
      extrapercent = self.extrafn(self.inst, dt)
    end

    if dist > self.range*self.range then
      dist = dist - (self.range*self.range)
      dist = math.min(dist,self.fadedist*self.fadedist)
      local percent = 1- (dist/(self.fadedist*self.fadedist))   
      percent = percent *  extrapercent
      self.inst.AnimState:SetMultColour(percent,percent,percent,percent)
    else
      local percent = 1 * extrapercent
      self.inst.AnimState:SetMultColour(percent,percent,percent,percent)
    end
end

return Distancefade

 


