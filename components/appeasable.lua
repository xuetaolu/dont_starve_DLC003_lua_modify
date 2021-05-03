local Appeasable = Class(function(self, inst)
    self.inst = inst
    self.enabled = true
    self.deleteitemonaccept = true
end)


function Appeasable:IsTryingToTradeWithMe(inst)
    local act = inst:GetBufferedAction()
    if act then
        return act.target == self.inst and act.action == ACTIONS.GIVE
    end
end

function Appeasable:Enable( fn )
    self.enabled = true
end

function Appeasable:Disable( fn )
    self.enabled = false
end

function Appeasable:SetAcceptTest( fn )
    self.test = fn
end

function Appeasable:CanAccept( item , giver )
    return self.enabled and (not self.test or self.test(self.inst, item, giver))
end

function Appeasable:AcceptGift( giver, item )
    
    if not self.enabled then
        return false
    end
    
   
    if self:CanAccept(item, giver) then

		if item.components.stackable and item.components.stackable.stacksize > 1 then
			item = item.components.stackable:Get()
		else
			item.components.inventoryitem:RemoveFromOwner()
		end
        
        if self.inst.components.inventory then
            self.inst.components.inventory:GiveItem(item)
        elseif self.deleteitemonaccept then
            item:Remove()
        end
        
		if self.onaccept then
			self.onaccept(self.inst, giver, item)
		end
		
        self.inst:PushEvent("Appeased", {giver = giver, item = item})

        return true
    end

	if self.onrefuse then
		self.onrefuse(self.inst, giver, item)
	end
end

return Appeasable
