local function SpawnSnake(vine, target)
	local snake = SpawnPrefab("snake_poison")
	local spawnpos = Vector3(vine.Transform:GetWorldPosition() )
	spawnpos = spawnpos + TheCamera:GetDownVec()
	snake.Transform:SetPosition(spawnpos:Get() )
	snake.components.combat:SetTarget(target)
end

local function TriggerTrap(inst, scenariorunner)
	local x, y, z = inst.Transform:GetWorldPosition()

	local vines = TheSim:FindEntities(x, y, z, 10, {"vinehideout"})
	for i = 1, #vines, 1 do
		if vines[i].components.hackable:CanBeHacked() then
			inst:DoTaskInTime(math.random(0, 2), function() SpawnSnake(vines[i], GetPlayer()) end)
		end
	end

	local vinetraps = TheSim:FindEntities(x, y, z, 10, {"vinetrap"})
	for i = 1, #vinetraps, 1 do
		vinetraps[i].components.scenariorunner:ClearScenario()
	end
	scenariorunner:ClearScenario()
end

local function OnLoad(inst, scenariorunner)
	inst:AddTag("vinetrap")
    inst.scene_putininventoryfn = function() TriggerTrap(inst, scenariorunner) end
	inst:ListenForEvent("onputininventory", inst.scene_putininventoryfn)
	RemoveBlowInHurricane(inst)
end

local function OnDestroy(inst)
	inst:RemoveTag("vinetrap")
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