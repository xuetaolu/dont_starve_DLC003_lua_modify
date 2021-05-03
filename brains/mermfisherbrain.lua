require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"
require "behaviours/chattynode"

local SEE_FOOD_DIST = 10
local MAX_WANDER_DIST = 15
local MAX_CHASE_TIME = 10
local MAX_CHASE_DIST = 20
local RUN_AWAY_DIST = 5
local STOP_RUN_AWAY_DIST = 8

local MermFisherBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function GoHomeAction(inst)
    if inst.components.homeseeker and 
       inst.components.homeseeker.home and 
       not inst.components.homeseeker.home:HasTag("fire") and
       not inst.components.homeseeker.home:HasTag("burnt") and
       inst.components.homeseeker.home:IsValid() and
       not inst.components.combat.target then
        return BufferedAction(inst, inst.components.homeseeker.home, ACTIONS.GOHOME)
    end
end

local function ShouldGoHome(inst)
    --one merm should stay outside
    local home = inst.components.homeseeker and inst.components.homeseeker.home
    local shouldStay = home and home.components.childspawner
        and home.components.childspawner:CountChildrenOutside() <= 1
    return GetClock():IsDay() and not shouldStay
end

local function Fish(inst)
    local pond = FindEntity(inst, 20, nil, {"fishable"})

    if pond and not inst.sg:HasStateTag("fishing") and inst.CanFish then
        return BufferedAction(inst, pond, ACTIONS.FISH)
    end
end

function MermFisherBrain:OnStart()
    local IsThreatened = --When the fisherman has a combat target 
    PriorityNode(
    {
        ChattyNode(self.inst, STRINGS.MERM_TALK_RUNAWAY,
            RunAway(self.inst, function() return self.inst.components.combat.target end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST, 
                function(hunter, inst) return hunter and hunter:GetPosition():Dist(inst:GetPosition()) < STOP_RUN_AWAY_DIST end)),
        ChattyNode(self.inst, STRINGS.MERM_TALK_PANIC, 
            Panic(self.inst)),
    }, 0.25)

    local IsIdle =
    PriorityNode(
    {
        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, MAX_WANDER_DIST),
    }, 0.25)

    local root = PriorityNode(
    {
        WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire", 
            ChattyNode(self.inst, STRINGS.MERM_TALK_PANIC,
                Panic(self.inst))),

        WhileNode(function() return self.inst.components.combat.target ~= nil and not self.inst.sg:HasStateTag("fishing") end, "Is Threatened", IsThreatened),
        
        ChattyNode(self.inst, STRINGS.MERM_TALK_GO_HOME,
            WhileNode(function() return ShouldGoHome(self.inst) end, "ShouldGoHome", DoAction(self.inst, GoHomeAction, "Go Home", true))),

        ChattyNode(self.inst, STRINGS.MERM_TALK_FISH,
            DoAction(self.inst, Fish, "Fish Action")),

        WhileNode(function() return not self.inst.sg:HasStateTag("fishing") end, "Is Idle", IsIdle),
    }, 0.25)
    
    self.bt = BT(self.inst, root)
end

return MermFisherBrain