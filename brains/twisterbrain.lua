require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/chaseandram"
require "behaviours/chaseandattack"
require "behaviours/standandattack"
require "behaviours/leash"

local MAX_CHASE_TIME = 10
local GIVE_UP_DIST = 20
local MAX_CHARGE_DIST = 60

local wandertimes =
{
    minwalktime = 5,
    randwalktime =  3,
    minwaittime = 0,
    randwaittime = 0,
}

local TwisterBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function TwisterBrain:OnStart()
    local root =
        PriorityNode(
        {
            WhileNode(function() return self.inst.shouldGoAway end, "Should Leave", Leash(self.inst, function() return self.inst:GetPosition() + Vector3(10,0,10) end, 5, 1, true)),

            WhileNode(function() return self.inst.sg:HasStateTag("running") or
                (self.inst.CanCharge and self.inst.components.combat.target and self.inst.components.combat.target:GetPosition():Dist(self.inst:GetPosition()) >= TUNING.TWISTER_ATTACK_RANGE) end, 
                "Charge Behaviours", ChaseAndRam(self.inst, MAX_CHASE_TIME, GIVE_UP_DIST, MAX_CHARGE_DIST)),

            WhileNode(function() return not self.inst.CanCharge end, "Attack Behaviours", ChaseAndAttack(self.inst, nil, nil, nil, nil, true)),

            Wander(self.inst, function() return GetPlayer():GetPosition() end, 20, wandertimes),
        }, .25)
    
    self.bt = BT(self.inst, root)
end

return TwisterBrain