local Instrument = Class(function(self, inst)
    self.inst = inst
    self.range = 15
    self.onheard = nil
    self.onplayed = nil
    self.sound = nil
end)

function Instrument:SetOnHeardFn(fn)
    self.onheard = fn
end

function Instrument:CollectInventoryActions(doer, actions)
    table.insert(actions, ACTIONS.PLAY)
end

function Instrument:Play(musician)
    if self.onplayed then
        self.onplayed(self.inst, musician)
    end
    local pos = Vector3(musician.Transform:GetWorldPosition())
    local ents = TheSim:FindEntities(pos.x,pos.y,pos.z, self.range)
    for k,v in pairs(ents) do
		if v ~= self.inst and self.onheard then
		    self.onheard(v, musician, self.inst)
		end
    end
    return true    
end

return Instrument
