local Dryable = Class(function(self, inst)
    self.inst = inst
    self.product = nil
    self.drytime = nil
    self.overridesymbol = nil 
end)

function Dryable:SetProduct(product)
    self.product = product
end

function Dryable:GetProduct()
    return self.product
end

function Dryable:GetDryingTime()
    return self.drytime
end

function Dryable:SetDryTime(time)
    self.drytime = time
end

function Dryable:SetOverrideSymbol(symbol)
    self.overridesymbol = symbol
end 

function Dryable:GetOverrideSymbol()
    return self.overridesymbol or self.inst.prefab
end 

function Dryable:CollectUseActions(doer, target, actions)
    if not target:HasTag("burnt") then
        if target.components.dryer and target.components.dryer:CanDry(self.inst) then
            table.insert(actions, ACTIONS.DRY)
        end
    end
end

return Dryable