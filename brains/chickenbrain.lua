require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"
require "behaviours/chaseandattack"

local STOP_RUN_DIST = 10
local SEE_PLAYER_DIST = 5

local AVOID_PLAYER_DIST = 3
local AVOID_PLAYER_STOP = 6

local SEE_BAIT_DIST = 20
local MAX_WANDER_DIST = 20
local SEE_STOLEN_ITEM_DIST = 10

local MAX_CHASE_TIME = 8


local ChickenBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function EatFoodAction(inst)
    local target = FindEntity(inst, SEE_BAIT_DIST,
        function(item)
            return inst.components.eater:CanEat(item) and
            item.components.bait and
            not item:HasTag("planted") and
            not (item.components.inventoryitem and
                item.components.inventoryitem:IsHeld())
        end)
    if target then
        local act = BufferedAction(inst, target, ACTIONS.EAT)
        act.validfn = function() return not (target.components.inventoryitem and target.components.inventoryitem:IsHeld()) end
        return act
    end
end

function ChickenBrain:OnStart()
    local clock = GetClock()
    local seasonmgr = GetSeasonManager()

    local root = PriorityNode(
    {
        WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
        RunAway(self.inst, "scarytoprey", AVOID_PLAYER_DIST, AVOID_PLAYER_STOP),
        DoAction(self.inst, EatFoodAction),
        Wander(self.inst, function() return Vector3(0.0, 0.0, 0.0) end, MAX_WANDER_DIST)
    }, 0.25)

    self.bt = BT(self.inst, root)
end

return ChickenBrain
