local Repairer = Class(function(self, inst)
    self.inst = inst
    self.workrepairvalue = 0
    self.healthrepairvalue = 0
    self.perishrepairvalue = 0
	self.repairmaterial = nil

end)

function Repairer:CollectUseActions(doer, target, actions, right)
    if right and target.components.repairable and target.components.repairable.repairmaterial == self.repairmaterial then
        if (target.components.health and 
            target.components.health:GetPercent() < 1 and self.healthrepairvalue > 0) or  

            (target.components.workable and target.components.workable.workleft and
            target.components.workable.workleft < target.components.workable.maxwork and 
            self.workrepairvalue > 0) or
        
            (target.components.perishable and target.components.perishable:GetPercent() < 1 and
            self.perishrepairvalue > 0) then
                table.insert(actions, ACTIONS.REPAIR)
        end
    elseif not right and target.components.repairable and target.components.repairable.repairmaterial == self.repairmaterial and target.components.boathealth and 
        self.healthrepairvalue > 0 then
            table.insert(actions, ACTIONS.REPAIRBOAT)
    end
end

function Repairer:CollectInventoryActions(doer, actions, right)
    if doer and doer.components.driver and doer.components.driver.vehicle then
        local vehicle = doer.components.driver.vehicle
        if (vehicle.components.boathealth and self.healthrepairvalue > 0 and self.repairmaterial == "boat") then
            table.insert(actions, ACTIONS.REPAIRBOAT)
        end
    end
end

return Repairer

