local assets =
{
	Asset("ANIM", "anim/tidal_pool.zip")
}

local prefabs =
{
	"tidal_plant",
	"tropical_fish",
}

local function SpawnPlants(inst, plantname, count, maxradius)

	if inst.decor then
		for i,item in ipairs(inst.decor) do
			item:Remove()
		end
	end
	inst.decor = {}

	local plant_offsets = {}

	for i=1,math.random(math.ceil(count/2),count) do
		local a = math.random()*math.pi*2
		local x = math.sin(a)*maxradius+math.random()*0.2
		local z = math.cos(a)*maxradius+math.random()*0.2
		table.insert(plant_offsets, {x,0,z})
	end

	for k, offset in pairs( plant_offsets ) do
		local plant = SpawnPrefab( plantname )
		plant.entity:SetParent( inst.entity )
		plant.Transform:SetPosition( offset[1], offset[2], offset[3] )
		table.insert( inst.decor, plant )
	end
end

local sizes =
{
	{anim="small_idle", rad=2.0, plantcount=2, plantrad=1.6},
	{anim="med_idle", rad=2.6, plantcount=3, plantrad=2.5},
	{anim="big_idle", rad=3.6, plantcount=4, plantrad=3.4},
}

local function SetSize(inst, size)
	inst.size = size or 1 --math.random(1, #sizes)
	inst.AnimState:PlayAnimation(sizes[inst.size].anim, true)
	inst.Physics:SetCylinder(sizes[inst.size].rad, 1.0)
	SpawnPlants(inst, "marsh_plant_tropical", sizes[inst.size].plantcount, sizes[inst.size].plantrad)
end

local function onsave(inst, data)
	data.size = inst.size
end

local function onload(inst, data, newents)
	if data and data.size then
		SetSize(inst, data.size)
	end
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()
    MakeObstaclePhysics( inst, 3.5)

    anim:SetBuild("tidal_pool")
    anim:SetBank("tidal_pool")
	anim:SetOrientation( ANIM_ORIENTATION.OnGround )
	anim:SetLayer( LAYER_BACKGROUND )
	anim:SetSortOrder( 3 )

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "pond_cave.png" )

	inst:AddTag("fishable")

    inst:AddComponent("inspectable")
    inst.no_wet_prefix = true

	inst:AddComponent("fishable")
	inst.components.fishable:AddFish("tropical_fish")
	inst.components.fishable:SetRespawnTime(TUNING.FISH_RESPAWN_TIME)

	inst.OnSave = onsave
	inst.OnLoad = onload

	SetSize(inst)

	return inst
end

return Prefab( "shipwrecked/objects/tidalpool", fn, assets, prefabs)

