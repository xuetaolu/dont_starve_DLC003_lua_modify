
local function OnCreate(inst, scenariorunner)
	if inst == nil or inst.components.container == nil then
		return
	end

	inst.components.boathealth:SetPercent(GetRandomWithVariance(0.48, 0.1))

	if math.random() < 0.99 then
		local sails = {"sail", "clothsail"}
		local sail = SpawnPrefab(sails[math.random(1, 2)])
		if sail then
			sail.components.fueled:SetPercent(GetRandomWithVariance(0.3, 0.1))
			inst.components.container:Equip(sail)
		end
	end

	if math.random() < 0.9 then
		local lantern = SpawnPrefab("boat_lantern")
		if lantern then
			lantern.components.fueled:SetPercent(GetRandomWithVariance(0.25, 0.1))
			inst.components.container:Equip(lantern)
			lantern.components.equippable:ToggleOff()
		end
	end
end

return
{
	OnCreate = OnCreate
}