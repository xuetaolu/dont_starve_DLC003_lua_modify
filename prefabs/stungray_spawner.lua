local assets = {}

local prefabs = 
{
	"stungray",
}
  
local start_day = 5+(math.random()*5)

local function onsave(inst, data)
	data.start_day = inst.start_day
end

local function teststartspawning(inst)
	if inst.start_day then
		if GetClock():GetNumCycles() >= inst.start_day then
			inst.components.childspawner:StartSpawning()
			inst.start_day = nil
			inst.MiniMapEntity:SetEnabled(true)
		end
	end
end
	

local function onload(inst, data)
	if data and data.start_day then
		inst.start_day = data.start_day
		teststartspawning(inst)
	end
end

local function longupdate(inst, dt)
	teststartspawning(inst)
end

local function onwake(inst)
	teststartspawning(inst)
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()


    local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("stinkray.png")
	minimap:SetEnabled(false)

	inst:AddTag("NOCLICK")

	inst:AddComponent( "childspawner" )
	inst.components.childspawner:SetRegenPeriod(60)
	inst.components.childspawner:SetSpawnPeriod(.1)
	inst.components.childspawner:SetMaxChildren(6)
	inst.components.childspawner.childname = "stungray"

	inst.start_day = start_day

	inst.OnLongUpdate = longupdate
	inst.OnSave = onsave
	inst.OnLoad = onload
	inst.OnEntityWake = onwake

    return inst
end

return Prefab( "common/stungray_spawner", fn, assets, prefabs) 
