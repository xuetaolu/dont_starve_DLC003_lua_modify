local Disarming = Class(function(self, inst)
    self.inst = inst
    self.repair_value = 1
end)


function Disarming:DoDisarming(target, doer)
	
    if target.components.disarmable and target.components.disarmable.armed then	
		
		if self.ondisarm then
			self.ondisarm(self.inst, target, doer)
		end

		target.components.disarmable:disarm(doer, self.inst)		
		
		return true
	end
end


function Disarming:CollectUseActions(doer, target, actions)
	if target.components.disarmable and  target.components.disarmable.armed then
        table.insert(actions, ACTIONS.DISARM)
    end
end

return Disarming
