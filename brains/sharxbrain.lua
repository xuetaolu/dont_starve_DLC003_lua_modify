require "behaviours/wander"
require "behaviours/chaseandattack"
require "behaviours/panic"
require "behaviours/attackwall"
require "behaviours/minperiod"
require "behaviours/leash"
require "behaviours/faceentity"
require "behaviours/doaction"
require "behaviours/standstill"

local SharxBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local SEE_DIST = 30

local MIN_FOLLOW_LEADER = 2
local MAX_FOLLOW_LEADER = 6
local TARGET_FOLLOW_LEADER = (MAX_FOLLOW_LEADER+MIN_FOLLOW_LEADER)/2

local LEASH_RETURN_DIST = 10
local LEASH_MAX_DIST = 40

local HOUSE_MAX_DIST = 40
local HOUSE_RETURN_DIST = 50 

local SIT_BOY_DIST = 10

local function EatFoodAction(inst)
    local notags = {"FX", "NOCLICK", "DECOR","INLIMBO"}
    local target = FindEntity(inst, SEE_DIST, function(item) return inst.components.eater:CanEat(item) and item:IsOnValidGround() end, {"aquatic"}, notags)
    if target then
        return BufferedAction(inst, target, ACTIONS.EAT)
    end
end

local function GetLeader(inst)
    return inst.components.follower and inst.components.follower.leader
end


local function GetWanderPoint(inst)
    local target = GetLeader(inst) or GetPlayer()

    if target and target:HasTag("aquatic") then
        return target:GetPosition()
    else 
        return inst:GetPosition()
    end 
end


function SharxBrain:OnStart()
    
    local root = PriorityNode(
    {
        --WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst) ),
        --WhileNode(function() return not GetLeader(self.inst) end, "NoLeader", AttackWall(self.inst) ),

        ChaseAndAttack(self.inst, 100),
        

        DoAction(self.inst, EatFoodAction, "eat food", true ),
        Follow(self.inst, GetLeader, MIN_FOLLOW_LEADER, TARGET_FOLLOW_LEADER, MAX_FOLLOW_LEADER),
        FaceEntity(self.inst, GetLeader, GetLeader),

        Wander(self.inst, GetWanderPoint, 20),

    }, .25)
    
    self.bt = BT(self.inst, root)
    
end

return SharxBrain
