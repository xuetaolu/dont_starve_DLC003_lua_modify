require "behaviours/wander"
require "behaviours/leash"
require "behaviours/doaction"
require "behaviours/chaseandattack"
require "behaviours/runaway"

local MAX_LEASH_DIST = 40
local MAX_WANDER_DIST = 40
local RUN_AWAY_DIST = 4
local STOP_RUN_AWAY_DIST = 8
local RUN_AWAY_DIST = 5

local MAX_CHASE_DIST = 8
local MAX_CHASE_TIME = 10

local SEE_FLOWER_DIST = 30

local function GoHomeAction(inst)
    if inst.components.homeseeker and 
       inst.components.homeseeker.home and 
       inst.components.homeseeker.home:IsValid() then
        return BufferedAction(inst, inst.components.homeseeker.home, ACTIONS.GOHOME)
    end
end

local function ShouldGoHome(inst)
    return GetClock():IsDay() or GetSeasonManager():IsWinter()
end

local GlowflyBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function NearestFlowerPos(inst)
    local flower = GetClosestInstWithTag("flower_rainforest", inst, SEE_FLOWER_DIST)
    if flower and 
       flower:IsValid() then
        return Vector3(flower.Transform:GetWorldPosition() )
    end
end



local function startCocooning(inst)
    inst:PushEvent("cocoon") 
  --  inst:DoTaskInTime(10, function() inst:PushEvent("hatch") end)
end

function GlowflyBrain:OnStart()
    local clock = GetClock()

	local wandertimes = {minwalktime=2,randwalktime=2,minwaittime=0,randwaittime=0}

    local root = PriorityNode(
    {
      WhileNode( function() return not self.inst:HasTag("cocoon") end, "is not cocoon", 
        PriorityNode{
      		WhileNode( function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),

          WhileNode( function() return self.inst:HasTag("wantstococoon") and  not self.inst.onwater end, "do cocoon", ActionNode(function() startCocooning(self.inst)  end)), 
          
          WhileNode( function() return self.inst.components.combat.target and self.inst.components.combat:InCooldown() end, "Dodge", RunAway(self.inst, function() return self.inst.components.combat.target end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST) ),

          Wander(self.inst, nil, MAX_WANDER_DIST, wandertimes)
        },1)

    }, .25)
    
    self.bt = BT(self.inst, root)
    
end

function GlowflyBrain:OnInitializationComplete()
    self.inst.components.knownlocations:RememberLocation("home", Point(self.inst.Transform:GetWorldPosition()), true)
end

return GlowflyBrain
