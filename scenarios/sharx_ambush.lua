
local SHARX_SPAWN_DIST = 40

local function SpawnSharx(inst, threatprefab)
	
	local threat = SpawnPrefab(threatprefab)
	if threat then
		local x, y, z = inst.Transform:GetWorldPosition()
		local rads = math.random(0, 359) * DEGREES
		threat.Transform:SetPosition(x + SHARX_SPAWN_DIST * math.cos(rads), y, z + SHARX_SPAWN_DIST * math.sin(rads))
		threat.components.combat:SetTarget(inst)
	end
end

local function TriggerTrap(inst, scenariorunner)
	local loots = {"smallmeat", "smallmeat", "smallmeat", "spear_launcher", "spear"}
	for i = 1, #loots, 1 do
		local prefab = SpawnPrefab(loots[i])
		inst.components.container:GiveItem(prefab)
	end

	local threats = {"sharx","crocodog"}
	local threat = threats[math.random(#threats)]
	for i = 1, 3, 1 do
		inst:DoTaskInTime(math.random(0, 3), function() SpawnSharx(inst, threat) end)
	end

	scenariorunner:ClearScenario()
end

local function OnCreate(inst, scenariorunner)
	inst.components.boathealth:SetPercent(GetRandomWithVariance(0.48, 0.1))
end

local function OnLoad(inst, scenariorunner)
    inst.scene_mountedfn = function() TriggerTrap(inst, scenariorunner) end
	inst:ListenForEvent("mounted", inst.scene_mountedfn)
end

local function OnDestroy(inst)
    if inst.scene_mountedfn then
        inst:RemoveEventCallback("mounted", inst.scene_mountedfn)
        inst.scene_mountedfn = nil
    end
end

return
{
	OnCreate = OnCreate,
	OnLoad = OnLoad,
	OnDestroy = OnDestroy
}