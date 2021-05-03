require "behaviours/wander"
require "behaviours/migrate"

local MAX_WANDER_DIST = 40


local RainbowJellyfishBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)


function RainbowJellyfishBrain:OnInitializationComplete()
      --self.inst.components.knownlocations:RememberLocation("home", Point(self.inst.Transform:GetWorldPosition()), true)
 end

function RainbowJellyfishBrain:OnStart()
    local clock = GetClock()
    local migrationMgr = GetRainbowJellyMigrationManager()

    local root = PriorityNode(
    {
        WhileNode(function() return migrationMgr and migrationMgr:IsMigrationActive() end, "Migrating",
                PriorityNode({
                    Migrate(self.inst, function() return self.inst.components.knownlocations:GetLocation("migration") end),
                    Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("migration") end, MAX_WANDER_DIST * 0.25)
                }, 1)
            ),
        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("home") end, MAX_WANDER_DIST)
    }, 1)
    self.bt = BT(self.inst, root)
end

return RainbowJellyfishBrain
