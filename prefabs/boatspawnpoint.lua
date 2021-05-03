

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()

	inst:AddComponent("scenariorunner")
	inst.components.scenariorunner:SetScript("moored_boat")
	--inst.components.scenariorunner:Run()

	return inst
end

return Prefab( "common/inventory/boatspawnpoint", fn)