local KeepOnLand = Class(function(self, inst)
    self.inst = inst
    self.inst:StartUpdatingComponent(self)
  
end)

function KeepOnLand:OnUpdateSw(dt)
    --local onWater = 
    if (not self.inst.components.driver or not self.inst.components.driver:GetIsDriving()) and not self.inst.sg:HasStateTag("busy") and not self.inst.components.health:IsDead() then 
        local pt = self.inst:GetPosition()
        local radius = 1 --buffer zone because the walls aren't perfecly along the visual line 
        local result_offset = FindValidPositionByFan(0, radius, 12, function(offset)
            local test_point = pt + offset
            if self.inst:GetIsOnWater(test_point.x, test_point.y, test_point.z) then
                return false
            end
            return true 
        end)

        local onWater = result_offset == nil 

        if onWater then 
            pt = self.inst:GetPosition()
            radius = 5 
            result_offset = FindValidPositionByFan(0, radius, 12, function(offset)
                local test_point = pt + offset
                if self.inst:GetIsOnWater(test_point.x, test_point.y, test_point.z) then
                    return false
                end
                return true 
            end)

            if result_offset then 
                local moveto = pt + result_offset
                self.inst.Transform:SetPosition(moveto.x, moveto.y, moveto.z)
            elseif self.inst.components.health then 
                if CHEATS_ENABLED then
                    local boat = SpawnPrefab("rowboat")
                    boat.Transform:SetPosition(self.inst:GetPosition():Get())
					self.inst.components.driver:OnMount(boat) 
					boat.components.drivable:OnMounted(self.inst)
                else
                    self.inst.components.health:Kill("drowning")
                end
            end 
        end 
    end 
end

function KeepOnLand:OnUpdateVolcano(dt)
    local world = GetWorld()
    local function testfn(offset)

        local test_point = self.inst:GetPosition() + offset
        local tx, ty = world.Map:GetTileCoordsAtPoint(test_point.x, test_point.y, test_point.z)
        local actual_tile = world.Map:GetTile(tx, ty)
        return actual_tile ~= GROUND.VOLCANO_LAVA
    end
    if not self.inst.sg:HasStateTag("busy") and not self.inst.components.health:IsDead() then 
        local pt = self.inst:GetPosition()
        local radius = 1.75 --buffer zone because the walls aren't perfecly along the visual line 
        local result_offset = FindValidPositionByFan(0, radius, 12, testfn)

        local onLava = result_offset == nil 

        if onLava then 
            pt = self.inst:GetPosition()
            radius = 5 
            result_offset = FindValidPositionByFan(0, radius, 12, testfn)

            if result_offset then 
                local moveto = pt + result_offset
                self.inst.Transform:SetPosition(moveto.x, moveto.y, moveto.z)
            elseif self.inst.components.health then 
                if not CHEATS_ENABLED then
                    self.inst.components.health:Kill("burnt")
                end
            end 
        end 
    end 
end

function KeepOnLand:OnUpdate(dt)
    local world = GetWorld()
    if world:IsVolcano() then
        self:OnUpdateVolcano(dt)
    else
        self:OnUpdateSw(dt)
    end
end


return KeepOnLand
