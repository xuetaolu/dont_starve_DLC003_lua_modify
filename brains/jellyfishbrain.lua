require "behaviours/wander"

local MAX_WANDER_DIST = 40


local JellyfishBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)


function JellyfishBrain:OnInitializationComplete()
      self.inst.components.knownlocations:RememberLocation("home", Point(self.inst.Transform:GetWorldPosition()), true)
 end

function JellyfishBrain:OnStart()
    local clock = GetClock()
    local seasonmgr = GetSeasonManager()
    
    local root = PriorityNode(
    {
        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, MAX_WANDER_DIST)
    }, .25)
    self.bt = BT(self.inst, root)
end

return JellyfishBrain
