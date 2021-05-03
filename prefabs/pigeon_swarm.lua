require "prefabutil"


local assets =
{
    Asset("ANIM", "anim/crow.zip"),
    Asset("ANIM", "anim/pigeon_build.zip"),
}

local prefabs = 
{
    "pigeon" 
}


local function onsave(inst, data)

end

local function onload(inst, data)

end

local function spawn_pigeon(inst)
    local DIST = 8
    local pigeon = SpawnPrefab("pigeon")                
    local x,y,z = inst.Transform:GetWorldPosition()
    x = x + (math.random()*DIST) - DIST/2
    z = z + (math.random()*DIST) - DIST/2
    pigeon.Transform:SetPosition(x,15,z)

    if math.random() < .5 then
       pigeon.Transform:SetRotation(180)
    end
end

local function set_spawn(inst)
    inst.pigeons = inst.pigeons - 1
    spawn_pigeon(inst)
    if inst.pigeons > 0 then
        inst:DoTaskInTime(math.random()*0.7,function()                
            set_spawn(inst)               
        end)    
    else
        inst:Remove()
    end
end

local function StopTrackingInSpawner(inst)
	local ground = GetWorld()
	if ground and ground.components.birdspawner then
		ground.components.birdspawner:StopTracking(inst)
	end
end

local function fn(Sim)

	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()

    inst.entity:AddPhysics()

   -- anim:SetBank("crow")
   -- anim:SetBuild("pigeon_build")

    inst.pigeons = math.random(3,7)

    set_spawn(inst)

	inst:ListenForEvent("onremove", StopTrackingInSpawner)
--[[
    inst.OnSave = onsave 
    inst.OnLoad = onload
]]
    return inst
end


return  Prefab("common/objects/pigeon_swarm", fn, assets, prefabs )

	   
