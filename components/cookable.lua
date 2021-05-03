local Cookable = Class(function(self, inst)
    self.inst = inst
    self.product = nil
    self.oncooked = nil
end)

function Cookable:SetOnCookedFn(fn)
	self.oncooked = fn
end


function Cookable:GetProduct()
    local prefab = nil 
    if self.product then 
        prefab = self.product
        if type(self.product) == "function" then
            prefab = self.product(self.inst)
        end
    end 
    return prefab
end 

function Cookable:Cook(cooker, chef)
    if self.oncooked then
		self.oncooked(self.inst, cooker, chef)
    end
    local product = self:GetProduct()
    if product then
        local prod = SpawnPrefab(product)

        if GetWorld().components.moisturemanager and prod then
            GetWorld().components.moisturemanager:MakeEntityDry(prod)
        end
        
        if prod then
			if self.inst.components.perishable and prod.components.perishable and not self.inst:HasTag("smallcreature") then
				
				local new_percent = 1 - (1 - self.inst.components.perishable:GetPercent())*.5
				prod.components.perishable:SetPercent(new_percent)
			end
			
			
			return prod
        end
    end
end


function Cookable:CollectUseActions(doer, target, actions)
    if target.components.cooker then
        table.insert(actions, ACTIONS.COOK)
    end
end



return Cookable