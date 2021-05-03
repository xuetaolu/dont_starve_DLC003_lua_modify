local SunkenPrefabInfo = Class(function(self, inst)
	self.inst = inst
	self.prefabinfo = {}
	self.sunktime = 0
	self.base_sunktime = 0
end)

function SunkenPrefabInfo:SetPrefab(prefab)
	self.prefabinfo = prefab:GetSaveRecord()
	self.sunktime = GetTime()
end

function SunkenPrefabInfo:GetSunkenPrefab()
	return self.prefabinfo
end

function SunkenPrefabInfo:GetTimeSubmerged()
	return (GetTime() - self.sunktime) + self.base_sunktime
end

function SunkenPrefabInfo:OnSave()
	local data = {}
	data.prefabinfo = self.prefabinfo
	data.sunktime = self:GetTimeSubmerged()
	return data
end

function SunkenPrefabInfo:OnLoad(data)
	if data then
		self.prefabinfo = data.prefabinfo
		self.base_sunktime = data.sunktime or 0
	end
end

return SunkenPrefabInfo