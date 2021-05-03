local PigShopManager = Class(function(self, inst)
    self.inst = inst
    self.active_shops = {}
end)

function PigShopManager:GenerateName(cave)
	table.insert(self.active_caves, cave)
	local name = "Bat Cave " .. #self.active_caves
	return name 
end 

return PigShopManager 