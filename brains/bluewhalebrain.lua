require "behaviours/wander"
require "behaviours/faceentity"
require "behaviours/chaseandattack"
require "behaviours/panic"
require "behaviours/runaway"
require "behaviours/leash"

local RUN_AWAY_DIST = 10
local STOP_RUN_AWAY_DIST = 14
local START_FACE_DIST = 15
local KEEP_FACE_DIST = 20

local LEASH_RETURN_DIST = 5
local LEASH_MAX_DIST = 10

local wander_times =
{
	minwalktime = 4,
	randwalktime = 4,
	minwaittime = 4,
	randwaittime = 3,
}

local function GetFaceTargetFn(inst)
	local target = GetClosestInstWithTag("player", inst, START_FACE_DIST)
	if target and not target:HasTag("notarget") then
		return target
	end
end

local function KeepFaceTargetFn(inst, target)
	return inst:GetDistanceSqToInst(target) <= KEEP_FACE_DIST * KEEP_FACE_DIST and not target:HasTag("notarget")
end

local BlueWhaleBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

function BlueWhaleBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("home", Point(self.inst.Transform:GetWorldPosition()), true)
end

function BlueWhaleBrain:OnStart()
	
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

		ChaseAndAttack(self.inst, TUNING.WHALE_BLUE_FOLLOW_TIME, TUNING.WHALE_BLUE_CHASE_DIST),
		SequenceNode{
			FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn, 0.5),
			RunAway(self.inst, "character", RUN_AWAY_DIST, STOP_RUN_AWAY_DIST)
		},
		FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
		Wander(self.inst, nil, nil, wander_times)
	}, .25)
	
	self.bt = BT(self.inst, root)
end

return BlueWhaleBrain
