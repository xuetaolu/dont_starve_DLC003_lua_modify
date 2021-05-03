require "behaviours/doaction"

local AntWarriorBrain_Egg = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function AntWarriorBrain_Egg:OnStart()
    local root = PriorityNode(
    {

    }, .25)
    
    self.bt = BT(self.inst, root)
end

return AntWarriorBrain_Egg