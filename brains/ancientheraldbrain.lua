require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/wander"
require "behaviours/doaction"
require "behaviours/attackwall"
require "behaviours/panic"
require "behaviours/minperiod"


local SEE_DIST = 40

local CHASE_DIST = 32
local CHASE_TIME = 20

local SUMMON_COOLDOWN = 15
local TAUNT_COOLDOWN = 100

local function GetHomePos(inst)
    if inst.home_pos then
        return inst.home_pos
    end

    return Point(GetPlayer().Transform:GetWorldPosition())
end

local function ShoudSummonEntities(inst)
    local x, y, z = GetPlayer().Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 20, {"aporkalypse_cleanup"})

    return #ents < 12
end

local function CanSummon(inst)
    return not inst.components.health:IsDead() and GetTime() - inst.summon_time > SUMMON_COOLDOWN and 
           (inst.components.combat.target and inst.components.combat.target == GetPlayer()) and ShoudSummonEntities()
end

local function PerformSummon(inst)
    inst.sg:GoToState("summon")
    inst.summon_time = GetTime()
end

local function CanTaunt(inst)
    return not inst.components.health:IsDead() and GetTime() - inst.taunt_time > TAUNT_COOLDOWN and 
           (inst.components.combat.target and inst.components.combat.target == GetPlayer()) and math.random() < 0.1
end

local function PerformTaunt(inst)
    inst.sg:GoToState("taunt")
    inst.taunt_time = GetTime()
end


local AncientHeraldBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function AncientHeraldBrain:OnStart()

    local clock = GetClock()

    local root =
        PriorityNode(
        {
            IfNode(function() return CanTaunt(self.inst) end, "CanTaunt",
                DoAction(self.inst, function() PerformTaunt(self.inst) end)),

            IfNode(function() return CanSummon(self.inst) end, "CanSummon", 
                DoAction(self.inst, function() PerformSummon(self.inst) end)),

            WhileNode( function() return self.inst.components.combat.target == nil or not self.inst.components.combat:InCooldown() end, "AttackMomentarily",
                ChaseAndAttack(self.inst, CHASE_TIME, CHASE_DIST)),
            Wander(self.inst, GetHomePos, CHASE_DIST),
        },1)
    
    self.bt = BT(self.inst, root)
         
end

return AncientHeraldBrain