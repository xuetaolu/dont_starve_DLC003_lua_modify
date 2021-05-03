local function OnCreate(inst, scenariorunner)
	if not Profile:IsCharacterUnlocked("wilbur") then
		local pos = inst:GetPosition()
		local unlock = SpawnPrefab("wilbur_unlock")
		unlock.Transform:SetPosition(pos:Get())
	end
	inst:Remove()
end

return
{
	OnCreate = OnCreate,
}