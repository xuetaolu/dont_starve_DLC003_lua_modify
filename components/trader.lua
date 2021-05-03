local Trader = Class(function(self, inst)
    self.inst = inst
    self.enabled = true
    self.deleteitemonaccept = true
end)

function Trader:OnSave()
    return  { enabled = self.enabled }
end

function Trader:OnLoad(data)
    self.enabled = data.enabled
end

function Trader:IsTryingToTradeWithMe(inst)
    local act = inst:GetBufferedAction()
    if act then
        return act.target == self.inst and act.action == ACTIONS.GIVE
    end
end

function Trader:Enable( fn )
    self.enabled = true
end

function Trader:Disable( fn )
    self.enabled = false
end

function Trader:SetAcceptTest( fn )
    self.test = fn
end

function Trader:CanAccept( item , giver )

    local frozen = false
    if  self.inst.components.freezable and self.inst.components.freezable:IsFrozen() then
        frozen = true        
    end

    return self.enabled and (not self.test or self.test(self.inst, item, giver)) and not frozen
end

function Trader:AcceptGift( giver, item, accept_stack, stack_num)

    if not self.enabled then
        return false
    end
    
    if self:CanAccept(item, giver) then

        if accept_stack or self.always_accept_stack and item.components.stackable then

            if stack_num == nil then
                local slot = self.inst.components.inventory:GetItemSlotByName(item.prefab)
                
                if not slot then
                    stack_num = item.components.stackable.stacksize
                else
                    stack_num = self.inst.components.inventory:GetItemInSlot(slot).components.stackable:RoomLeft()
                end
            end
            
            item = item.components.stackable:Get(stack_num)
        else
    		if item.components.stackable and item.components.stackable.stacksize > 1 then
    			item = item.components.stackable:Get()
    		else
    			item.components.inventoryitem:RemoveFromOwner()
    		end
        end


        
        if self.inst.components.inventory then
            self.inst.components.inventory:GiveItem(item)
        elseif self.deleteitemonaccept then
            item:Remove()
        end
        
		if self.onaccept then
			self.onaccept(self.inst, giver, item)
		end
		
        self.inst:PushEvent("trade", {giver = giver, item = item})

        return true
    end

    local frozen = false
    if  self.inst.components.freezable and self.inst.components.freezable:IsFrozen() then
        frozen = true        
    end

	if self.onrefuse and not frozen then
		self.onrefuse(self.inst, giver, item)
	end
end

return Trader
