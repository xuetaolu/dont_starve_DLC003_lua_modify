require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/chaseandattack"

local CHASE_TIME = 30
local CHASE_DIST = 40
local MAX_IDLE_WANDER_DIST = TUNING.SOLOFISH_WANDER_DIST


local SwordfishBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)


function SwordfishBrain:OnInitializationComplete()
      self.inst.components.knownlocations:RememberLocation("home", Point(self.inst.Transform:GetWorldPosition()), true)
 end

local wandertimes =
{
    minwalktime = 2,
    randwalktime =  2,
    minwaittime = 0.1,
    randwaittime = 0.1,
}

function SwordfishBrain:OnStart()
    
    local root = PriorityNode(
    {
        ChaseAndAttack(self.inst, CHASE_TIME, CHASE_DIST),
        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, MAX_IDLE_WANDER_DIST, wandertimes)

    }, .25)
    self.bt = BT(self.inst, root)
end

return SwordfishBrain
