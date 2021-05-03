local Book = Class(function(self, inst)
	self.inst = inst
	self.action = ACTIONS.READ
end)

function Book:SetOnReadFn(fn)
	self.onread = fn
end

function Book:SetAction(act)
	self.action = act
end

function Book:OnRead(reader)
	if self.onread then
		return self.onread(self.inst, reader)
	end

	return true
end

function Book:CanRead(reader)
    if self.onreadtest then
        return self.onreadtest(self.inst, reader)
    end
    return true
end

function Book:CollectSceneActions(doer, actions)
	if doer.components.reader then
		table.insert(actions, self.action)
	end
end

function Book:CollectInventoryActions(doer, actions)
	if doer.components.reader then
		table.insert(actions, self.action)
	end
end

return Book
