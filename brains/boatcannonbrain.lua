require "behaviours/standandattack"

local BoatCannonBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function throw(inst)
    local target = FindEntity(inst, 20, function(guy) return guy.components.health ~= nil end, nil, {"FX", "player", "NOCLICK"})
    if target then
        local randomoffset = inst:GetPosition() + Vector3(math.random(-10,10),math.random(-10,10),math.random(-10,10))
        return BufferedAction(inst, nil, ACTIONS.CREATURE_THROW, nil, target:GetPosition())
    end
end

function BoatCannonBrain:OnStart()
    local root = PriorityNode(
    {
        WhileNode(function() return not self.inst.sg:HasStateTag("attack") end, "not attacking",
            DoAction(self.inst, function() return throw(self.inst) end, "Launch Cannonball")),
    }, 1)
    
    self.bt = BT(self.inst, root)
end

return BoatCannonBrain