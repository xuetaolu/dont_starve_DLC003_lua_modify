require "prefabutil"
local assets =
{
Asset("ANIM", "anim/acorn.zip"),
}

local prefabs = 
{
}

local notags = {'NOBLOCK', 'player', 'FX'}

local function displaynamefn(inst)
    if inst.growtime then
        return STRINGS.NAMES.ACORN_SAPLING
    end
    return STRINGS.NAMES.ACORN
end

local function InitInteriorPrefab(inst, doer, prefab_definition, interior_definition)
	--If we are spawned inside of a building, then update our door to point at our interior
	local door_definition = {
		my_interior_name = interior_definition.unique_name,
		my_door_id = prefab_definition.my_door_id,
		target_door_id = prefab_definition.target_door_id,
		sound = prefab_definition.doorsound,
	}
	
	if door_definition.my_door_id == nil then
		door_definition.my_door_id = inst.components.door.door_id
	end
	if door_definition.target_door_id == nil then
		door_definition.target_door_id = inst.components.door.target_door_id
	end
	GetWorld().components.interiorspawner:AddDoor(inst, door_definition)
end

local function SaveInteriorData(inst, save_data)
	local door_data = GetWorld().components.interiorspawner.doors[inst.components.door.door_id]
	save_data.my_interior_name = door_data.my_interior_name
end

local function InitFromInteriorSave(inst, save_data)
	local interior = GetWorld().components.interiorspawner:GetInteriorByName(save_data.my_interior_name)
	if interior then
		local prefab_def = {}
		InitInteriorPrefab(inst, save_data.doer, prefab_def, interior)
	end
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("acorn")
    inst.AnimState:SetBuild("acorn")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "idle_water", "idle")

    inst:AddTag("icebox_valid")
    inst:AddTag("cattoy")
    inst:AddComponent("tradable")
    
	MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    inst.components.burnable:MakeDragonflyBait(3)
    inst.displaynamefn = displaynamefn
    
	local interior_spawner = GetWorld().components.interiorspawner
	local door_def = {
		my_door_id = "acorn door",
		target_door_id = "Bottom Acorn Door",
	}
	interior_spawner:AddDoor(inst, door_def)
	inst.door_target_offset_x = 5
	
	local interior_def = {
		unique_name = "The Acorn Door",
		width = 94,
		height = 20,
		prefabs = {
			{ name = "generic_interior", x_offset = -2, z_offset = 0 },
			{ name = "side_door", x_offset = 6.8, z_offset = 0, type = "bottom", my_door_id="Bottom Acorn Door", target_door_id="acorn door" },
		}
	}	
	interior_spawner:AddInterior(interior_def)
	
	inst.initInteriorPrefab = InitInteriorPrefab	
	inst.saveInteriorData = SaveInteriorData
	inst.initFromInteriorSave = InitFromInteriorSave
    return inst
end

return Prefab( "common/inventory/acorn_door", fn, assets, prefabs),
	   MakePlacer( "common/acorn_door_placer", "acorn", "acorn", "idle_planted" ) 


