local prefabs =
{
	"lava_erupt",
	"lava_bubbling"
}

local function GetPrefab()
	local vm = GetWorld().components.volcanomanager
	if vm and vm:IsErupting() and math.random() < 0.5 then
		return "lava_erupt"
	end
	return "lava_bubbling"
end

local function CanSpawn(inst, ground, x, y, z)
	return inst:IsPosSurroundedByTileType(x, y, z, 6, GROUND.VOLCANO_LAVA)
end

local function SetRadius(inst, radius)
	inst.radius = radius
	inst.Light:SetRadius(inst.radius)
	inst.components.areaspawner:SetDensityInRange(inst.radius)
end

local function OnEntitySleep(inst)
	inst.components.areaspawner:Stop()
end

local function OnEntityWake(inst)
	inst.components.areaspawner:Start()
end

local function OnSave(inst, data)
	if data then
		data.radius = inst.radius
	end
end

local function OnLoad(inst, data)
	if data and data.radius then
		SetRadius(inst, data.radius)
	end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local light = inst.entity:AddLight()

	inst.persists = false

	--local minimap = inst.entity:AddMiniMapEntity()
	--minimap:SetIcon( "obelisk.png" )

	light:SetIntensity(0.2)
	light:SetFalloff(2.5)
	light:SetColour(255/255,84/255,61/255)

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

	inst.OnEntitySleep = OnEntitySleep
	inst.OnEntityWake = OnEntityWake
	inst.OnSave = OnSave
	inst.OnLoad = OnLoad
	inst.SetRadius = SetRadius

	inst:AddComponent("areaspawner")
	inst.components.areaspawner:SetPrefabFn(GetPrefab)
	inst.components.areaspawner:SetSpawnTestFn(CanSpawn)
	inst.components.areaspawner:SetRandomTimes(0.5, 0.25)
	inst.components.areaspawner:SetValidTileType(GROUND.VOLCANO_LAVA)

	return inst
end

return Prefab("common/volcano/volcanolavafx", fn, nil, prefabs)
