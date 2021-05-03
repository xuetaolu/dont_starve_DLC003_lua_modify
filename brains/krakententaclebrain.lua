require 'behaviours/standandattack'
require 'behaviours/standstill'

local KrakenTentacleBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function KrakenTentacleBrain:OnStart()
    local clock = GetClock()
    
    local root = PriorityNode({
        StandAndAttack(self.inst),
        StandStill(self.inst),
    }, .25)
    
    self.bt = BT(self.inst, root)
end

return KrakenTentacleBrain