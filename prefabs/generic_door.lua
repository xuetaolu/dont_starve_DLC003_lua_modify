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
		my_door_id = "generic door",
		target_door_id = "Bottom Door",
	}
	interior_spawner:AddDoor(inst, door_def)
	
	local interior_def = {
		unique_name = "The Generic Door",
		width = 65, -- Visible Spawn Width
		height = 20, -- Visible Spawn Height
		wall_width = 30, 
		wall_height = 20,
		prefabs = {
			{ name = "generic_interior", x_offset = -2, z_offset = 0 },
			{ name = "side_door", x_offset = 6.8, z_offset = 0, type = "bottom", my_door_id="CrazyDoor", target_door_id="Bottom Acorn Door" },
		}
	}	
	interiors:AddInterior(interior_def)
		
    return inst
end

return Prefab( "common/inventory/generic_door", fn, assets, prefabs)


