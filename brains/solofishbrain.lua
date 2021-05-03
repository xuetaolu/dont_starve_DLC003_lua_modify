require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"


local STOP_RUN_DIST = 12
local SEE_PLAYER_DIST = 7

local AVOID_PLAYER_DIST = 5
local AVOID_PLAYER_STOP = 8

local SEE_BAIT_DIST = 20
local MAX_IDLE_WANDER_DIST = TUNING.SOLOFISH_WANDER_DIST


local SolofishBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)


function SolofishBrain:OnInitializationComplete()
      self.inst.components.knownlocations:RememberLocation("home", Point(self.inst.Transform:GetWorldPosition()), true)
 end

local wandertimes =
{
    minwalktime = 2,
    randwalktime =  2,
    minwaittime = 0.1,
    randwaittime = 0.1,
}


local function EatFoodAction(inst)
    local notags = {"FX", "NOCLICK", "DECOR","INLIMBO", "planted"}
    local target = FindEntity(inst, SEE_BAIT_DIST, function(item) return inst.components.eater:CanEat(item) and item.components.bait and not (item.components.inventoryitem and item.components.inventoryitem:IsHeld()) end, nil, notags)
    if target then
        local act = BufferedAction(inst, target, ACTIONS.EAT)
        act.validfn = function() return not (target.components.inventoryitem and target.components.inventoryitem:IsHeld()) end
        return act
    end
end


function SolofishBrain:OnStart()
    local root = PriorityNode(
    {
        -- DoAction(self.inst, EatFoodAction),
        RunAway(self.inst, "scarytoprey", AVOID_PLAYER_DIST, AVOID_PLAYER_STOP),
        -- RunAway(self.inst, "scarytoprey", SEE_PLAYER_DIST, STOP_RUN_DIST, nil),
        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, MAX_IDLE_WANDER_DIST, wandertimes),
    }, .25)
    self.bt = BT(self.inst, root)
end

return SolofishBrain
