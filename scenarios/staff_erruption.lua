local function TriggerTrap(inst, scenariorunner)
	local vm = GetWorld().components.volcanomanager
	vm:StartStaffTrap()
	scenariorunner:ClearScenario()
end

local function OnLoad(inst, scenariorunner)
	if not inst:HasTag("nosteal") then
		inst:AddTag("nosteal")
	end
    inst.scene_putininventoryfn = function() TriggerTrap(inst, scenariorunner) end
	inst:ListenForEvent("onputininventory", inst.scene_putininventoryfn)
end

local function OnDestroy(inst)
    if inst.scene_putininventoryfn then
        inst:RemoveEventCallback("onputininventory", inst.scene_putininventoryfn)
        inst.scene_putininventoryfn = nil
    end
end

return
{
	OnLoad = OnLoad,
	OnDestroy = OnDestroy
}