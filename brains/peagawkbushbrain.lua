require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"

local SEE_PLAYER_DIST = 5

local PeagawkBushBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function TransformAction(inst)
    local hunter = FindEntity(inst, SEE_PLAYER_DIST, nil, {'scarytoprey'}, {'notarget'} )

    if hunter == nil then
        return BufferedAction(inst, nil, ACTIONS.PEAGAWK_TRANSFORM)
    end
end

function PeagawkBushBrain:OnStart()
    local clock = GetClock()
    
    local root = PriorityNode(
    {
        DoAction(self.inst, TransformAction, "Transform To Animal", true)
    }, .25)
    
    self.bt = BT(self.inst, root)
end

return PeagawkBushBrain