require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"

local STOP_RUN_DIST = 20
local SEE_PLAYER_DIST = 8
local HIDE_PLAYER_DIST = 16

local SEE_FOOD_DIST = 20
local SEE_BUSH_DIST = 40
local MAX_WANDER_DIST = 80


local PeagawkBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function EatFoodAction(inst)
    if not inst.is_bush then
        local target = nil
        if inst.components.inventory and inst.components.eater then
            target = inst.components.inventory:FindItem(function(item) return inst.components.eater:CanEat(item) end)
        end
        if not target then
            target = FindEntity(inst, SEE_FOOD_DIST, function(item) return inst.components.eater:CanEat(item) end)
            if target then
                --check for scary things near the food
                local predator = GetClosestInstWithTag("scarytoprey", target, SEE_PLAYER_DIST)
                if predator then target = nil end
            end
        end
        if target then
            local act = BufferedAction(inst, target, ACTIONS.EAT)
            act.validfn = function() return not (target.components.inventoryitem and target.components.inventoryitem.owner and target.components.inventoryitem.owner ~= inst) end
            return act
        end
    end
end

local function TransformAction(inst)
    
    if not inst.components.health:IsDead() then
        if not inst.is_bush then
            local hunter = FindEntity(inst, HIDE_PLAYER_DIST, nil, {'scarytoprey'}, {'notarget'} )
            if hunter == nil then
                return BufferedAction(inst, nil, ACTIONS.PEAGAWK_TRANSFORM)
            end
        else
            local hunter = FindEntity(inst, SEE_PLAYER_DIST, nil, {'scarytoprey'}, {'notarget'} )
            if hunter and not inst.components.sleeper.isasleep then
                return BufferedAction(inst, nil, ACTIONS.PEAGAWK_TRANSFORM)
            end
        end
    end
end

function PeagawkBrain:OnStart()
    local clock = GetClock()
    
    local root = PriorityNode(
    {
        WhileNode( function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),

        IfNode(function() return not self.inst.is_bush and not self.inst.components.health:IsDead() end, "ThreatInRange",
            RunAway(self.inst, "scarytoprey", SEE_PLAYER_DIST, STOP_RUN_DIST)),

        DoAction(self.inst, EatFoodAction, "Eat Food"),
        DoAction(self.inst, TransformAction, "Transform", true),
    }, .25)
    
    self.bt = BT(self.inst, root)
end

return PeagawkBrain