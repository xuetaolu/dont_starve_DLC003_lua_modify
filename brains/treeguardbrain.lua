require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/attackwall"
require "behaviours/spreadout"


local TreeGuardBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function TreeGuardBrain:OnStart()

    local clock = GetClock()

    local root =
        PriorityNode(
        {
            RunAway(self.inst, "treeguard", 5, 10),
            --SpreadOut(self.inst, 10, {"treeguard"}),
            AttackWall(self.inst),
            ChaseAndAttack(self.inst),
            Wander(self.inst),
        },1)
    
    self.bt = BT(self.inst, root)
end

return TreeGuardBrain
