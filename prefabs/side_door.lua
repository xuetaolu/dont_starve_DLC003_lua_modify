require "prefabutil"

local assets =
{
}

local prefabs = 
{
}

local notags = {'NOBLOCK', 'player', 'FX'}

local function HibernateInteriorPrefab(inst)
	if inst.activate_door then
		inst.activate_door:Cancel()
		inst.activate_door = nil
	end
end

local function CheckForActivation(inst)
	if inst.activate_door then
		return
	end
	
	inst.activate_door = inst:DoPeriodicTask(0.000001, function() 
		if inst.door_doer then
			local x, y, z = inst.door_doer.Transform:GetWorldPosition()
			local door_x, door_y, door_z = inst.Transform:GetWorldPosition() 
			local activate = false
			if inst.door_side == "bottom" and x > door_x then
				activate = true 
			elseif inst.door_side == "top" and x < door_x then 
				activate = true
			elseif inst.door_side == "left" and z < door_z then 
				activate = true
			elseif inst.door_side == "right" and z > door_z then 
				activate = true
			elseif inst.door_side == "centre" and z > door_z then 
				activate = true
			end
			
			if activate then
				inst.components.door:Activate(inst.door_doer)
				HibernateInteriorPrefab(inst)
			end
		end
	end)
end

local function ResumeInteriorPrefab(inst)
	local door_x, door_y, door_z = inst.Transform:GetWorldPosition() 
	CheckForActivation(inst) -- Update Door Doer?
end

local function InitInteriorPrefab(inst, doer, prefab_definition, interior_definition)
	local door_definition = {
		my_interior_name = interior_definition.unique_name,
		my_door_id = prefab_definition.my_door_id,
		target_door_id = prefab_definition.target_door_id,
	}
	GetWorld().components.interiorspawner:AddDoor(inst, door_definition)
	
	-- Configure and activate door detection
	inst.door_side = prefab_definition.type
	if inst.door_side == "bottom" then
		inst.door_target_offset_x = -1
		inst.door_target_offset_z = 0
	elseif inst.door_side == "top" then 
		inst.door_target_offset_x = 1
		inst.door_target_offset_z = 0
	elseif inst.door_side == "left" then 
		inst.door_target_offset_x = 0
		inst.door_target_offset_z = 1
	elseif inst.door_side == "right" then 
		inst.door_target_offset_x = 0
		inst.door_target_offset_z = -1
	elseif inst.door_side == "centre" then 
		inst.door_target_offset_x = 0
		inst.door_target_offset_z = 0		
	end	
	
	inst.door_doer = doer

	CheckForActivation(inst)
end

local function SaveInteriorData(inst, save_data)
	save_data.door_id = inst.components.door.door_id
	if inst.activate_door == nil then
		save_data.hibernate = true
	end
end

local function InitFromInteriorSave(inst, save_data)
	local interior = GetWorld().components.interiorspawner:GetInteriorByDoorId(save_data.door_id)
	if interior then
		for k,prefab in ipairs(interior.prefabs) do
			if prefab.my_door_id == save_data.door_id then
				InitInteriorPrefab(inst, save_data.doer, prefab, interior)
				if save_data.hibernate then
					HibernateInteriorPrefab(inst)
				end
				return
			end
		end
	end
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)

	inst.initInteriorPrefab = InitInteriorPrefab	
	inst.resumeInteriorPrefab = ResumeInteriorPrefab
	inst.hibernateInteriorPrefab = HibernateInteriorPrefab
	inst.saveInteriorData = SaveInteriorData
	inst.initFromInteriorSave = InitFromInteriorSave
    return inst
end

return Prefab( "common/inventory/side_door", fn, assets, prefabs)


