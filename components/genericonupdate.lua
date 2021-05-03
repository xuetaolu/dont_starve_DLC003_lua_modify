local GenericOnUpdate = Class(function(self, inst)	
    self.inst = inst
end)

function GenericOnUpdate:Setup(fn)
  self.updatefn = fn
  self.inst:StartUpdatingComponent(self)
end

function GenericOnUpdate:OnUpdate(dt)
  if self.updatefn then
    self.updatefn(self.inst, dt)
  end
end

return GenericOnUpdate
