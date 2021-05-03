local GlobalSettings = Class(function(self,inst)
	self.inst = inst
	self.settings = {}
end)

function GlobalSettings:OnSave()
	return {settings = self.settings}
end

function GlobalSettings:OnLoad(data)
	if data and data.settings then
		self.settings = data.settings
	end
end

return GlobalSettings