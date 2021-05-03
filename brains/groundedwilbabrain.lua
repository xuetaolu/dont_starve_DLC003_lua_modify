require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"
require "behaviours/panic"
require "behaviours/chattynode"

local MAX_WANDER_DIST = 2

local MIN_RADIUS = -2
local MAX_RADIUS = 2

local function GetRandomRadius(pos, min, max)
    return pos + math.random(min, max)
end

local function GetHomePos(inst)
    local pos = GetWorld().components.interiorspawner:getSpawnOrigin()
    pos.x = GetRandomRadius(pos.x, MIN_RADIUS, MAX_RADIUS)
    pos.z = GetRandomRadius(pos.z, MIN_RADIUS, MAX_RADIUS)

    return pos
end

local GroundedWilbaBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function GroundedWilbaBrain:OnStart()
 
    local root = 
        PriorityNode(
        {
    --         WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire",
				-- ChattyNode(self.inst, STRINGS.PIG_TALK_PANICFIRE,
				-- 	Panic(self.inst))),
            Wander(self.inst, GetHomePos, MAX_WANDER_DIST)
        }, .5)
    
    self.bt = BT(self.inst, root)
    
end

return GroundedWilbaBrain
