require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/findflower"
require "behaviours/panic"
local beecommon = require "brains/beecommon"

local MAX_CHASE_DIST = 15
local MAX_CHASE_TIME = 8

local RUN_AWAY_DIST = 6
local STOP_RUN_AWAY_DIST = 10

local MAX_WANDER_DIST_BLOOMER = 6

local BeeBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function SpringMod(amt)
    if GetSeasonManager() and (GetSeasonManager():IsSpring() or GetSeasonManager():IsGreenSeason()) then
        return amt * TUNING.SPRING_COMBAT_MOD
    else
        return amt
    end
end

local function bloomernearby(inst, returntargetlocation)
    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, 30,{"beebeacon"},{"INLIMBO"})
    local target = nil
    for i,ent in pairs(ents)do
        if ent.components.bloomable and ent.components.bloomable.blooming and ent.components.bloomable.attractbees then 
            target = ent
            break
        end
    end
    if target and returntargetlocation then
        local x,y,z = target.Transform:GetWorldPosition()
        return {x=x,y=y,z=z}
    elseif target then
        return true 
    end
end

function BeeBrain:OnStart()

    local clock = GetClock()
    local seasonmanager = GetSeasonManager()
    
    local root =
        PriorityNode(
        {
            WhileNode( function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
            
            WhileNode( function() return self.inst.components.combat.target == nil or not self.inst.components.combat:InCooldown() end, "AttackMomentarily", ChaseAndAttack(self.inst, SpringMod(MAX_CHASE_TIME), SpringMod(MAX_CHASE_DIST)) ),
            WhileNode( function() return self.inst.components.combat.target and self.inst.components.combat:InCooldown() end, "Dodge", RunAway(self.inst, function() return self.inst.components.combat.target end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST) ),
            
            --ChaseAndAttack(self.inst, beecommon.MAX_CHASE_TIME),
            IfNode(function() return clock and not clock:IsDay() end, "IsNight",
                DoAction(self.inst, function() return beecommon.GoHomeAction(self.inst) end, "go home", true )),
            IfNode(function() return self.inst.components.pollinator:HasCollectedEnough() end, "IsFullOfPollen",
                DoAction(self.inst, function() return beecommon.GoHomeAction(self.inst) end, "go home", true )),
            IfNode(function() return seasonmanager and seasonmanager:IsWinter() end, "IsWinter",
                DoAction(self.inst, function() return beecommon.GoHomeAction(self.inst) end, "go home", true )),

            IfNode(function() return bloomernearby(self.inst) end, "bloomer",
                Wander(self.inst, function() return bloomernearby(self.inst, true) end, MAX_WANDER_DIST_BLOOMER)),

            FindFlower(self.inst),        
            Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, beecommon.MAX_WANDER_DIST)            
        },1)
    
    
    self.bt = BT(self.inst, root)
    
end

function BeeBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("home", Point(self.inst.Transform:GetWorldPosition()), true)
end

return BeeBrain
