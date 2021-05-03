local assets=
{
  
}

MAXTIME = 0.2

local function spawnCloud(inst) 

    local pt = Vector3(inst.Transform:GetWorldPosition())
    local cloudpuff = SpawnPrefab( "cloudpuff" )
    cloudpuff.Transform:SetPosition( pt.x + (math.random()*0.5 -0.25), pt.y, pt.z + (math.random()*0.5 -0.25))    

    inst:DoTaskInTime(math.random()*MAXTIME, function() inst.spawnCloud(inst) end)
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()

    inst.spawnCloud = spawnCloud
	inst:DoTaskInTime(math.random()*MAXTIME, function() spawnCloud(inst) end)
    
    return inst
end

return Prefab( "cloud_spawner", fn, assets) 

