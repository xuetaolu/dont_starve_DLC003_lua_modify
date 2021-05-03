require "behaviours/wander"
require "behaviours/chaseandattack"


local LEASH_RETURN_DIST = 5
local LEASH_MAX_DIST = 10

local wander_times =
{
	minwalktime = 4,
	randwalktime = 4,
	minwaittime = 4,
	randwaittime = 3,
}

local WhiteWhaleBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

function WhiteWhaleBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("home", Point(self.inst.Transform:GetWorldPosition()), true)
end

function WhiteWhaleBrain:OnStart()
	
	local root = PriorityNode(
	{
		SequenceNode{
            ConditionNode(function() 
	            local tile = self.inst.components.tiletracker.tile
	            if tile == GROUND.OCEAN_SHALLOW then
	            	self.inst.hitshallow = true
	            end
	            return tile == GROUND.OCEAN_SHALLOW or self.inst.hitshallow
	        end, "HitShallow"),

            ParallelNodeAny {
                WaitNode(15+math.random()*2),
                Leash(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, LEASH_MAX_DIST, LEASH_RETURN_DIST),
            },
            DoAction(self.inst, function() self.inst.hitshallow = nil end ),
        },

		ChaseAndAttack(self.inst, TUNING.WHALE_WHITE_FOLLOW_TIME, TUNING.WHALE_WHITE_CHASE_DIST),
		Wander(self.inst, nil, nil, wander_times)
	}, .25)
	
	self.bt = BT(self.inst, root)
end

return WhiteWhaleBrain
