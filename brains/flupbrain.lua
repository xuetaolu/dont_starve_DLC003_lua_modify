require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/chaseandattack"
require "behaviours/standstill"

local AVOID_PLAYER_DIST = 1.5
local AVOID_PLAYER_STOP = 3

local MAX_WANDER_DIST = 20
local SEE_TARGET_DIST = 6

local MAX_CHASE_TIME = 8

local HOME_LEASH_DIST = 5
local HOME_RETURN_DIST = 3

local function SetUpAmbush(inst)
    if inst.components.combat.target or inst.sg:HasStateTag("ambusher") then
        return
    end

    return BufferedAction(inst, inst, ACTIONS.FLUP_HIDE)
end

local function ShouldRun(hunter, inst)
    return not inst.sg:HasStateTag("jumping") and not inst.sg:HasStateTag("ambusher")
end

local FlupBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function FlupBrain:OnStart()

	local clock = GetClock()

    local root = PriorityNode(
    {
        WhileNode(function() return not self.inst.components.combat.target end, "No Target",
            Leash(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, HOME_LEASH_DIST, HOME_RETURN_DIST, true)),
        DoAction(self.inst, SetUpAmbush, "Try Ambush"),
        WhileNode(function() return self.inst.sg:HasStateTag("ambusher") end, "Lay In Wait",
            StandStill(self.inst, function() return self.inst.sg:HasStateTag("ambusher") end, nil)),
        RunAway(self.inst, "scarytoprey", AVOID_PLAYER_DIST, AVOID_PLAYER_STOP, ShouldRun),
        ChaseAndAttack(self.inst, MAX_CHASE_TIME),
        Wander(self.inst, function() return self.inst:GetPosition() end, MAX_WANDER_DIST),
    }, .25)

    self.bt = BT(self.inst, root)

end

return FlupBrain
