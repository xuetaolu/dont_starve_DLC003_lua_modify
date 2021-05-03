local assets=
{
}

local prefabs =
{
}    


local function OnSave(inst, data)
	data.fixedInteriorLocation = inst.fixedInteriorLocation
end

local function OnLoad(inst, data)
	if data then
		inst.fixedInteriorLocation = data.fixedInteriorLocation
	end
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst:AddTag("NOBLOCK")
    inst:AddTag("interior_spawn_origin")

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
   
    return inst
end

local function storagefn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst:AddTag("NOBLOCK")
    inst:AddTag("interior_spawn_storage")

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab( "forest/objects/interior_spawn_origin", fn, assets, prefabs),
	   Prefab( "forest/objects/interior_spawn_storage", storagefn, assets, prefabs)
