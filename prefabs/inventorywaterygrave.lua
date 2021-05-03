local assets =
{
	Asset("ANIM", "anim/graves_water.zip"),
    Asset("ANIM", "anim/graves_water_crate.zip"),
    Asset("MINIMAP_IMAGE", "gravestones"),
}

local prefabs = 
{
    "seaweed",
    "coral",
    "pirateghost"
}

for k= 1,NUM_TRINKETS do
    table.insert(prefabs, "trinket_"..tostring(k) )
end

local anims =
{
    {idle = "idle1", pst = "fishing_pst1"},
    {idle = "idle2", pst = "fishing_pst2"},
    {idle = "idle3", pst = "fishing_pst3"},
    {idle = "idle4", pst = "fishing_pst4"},
    {idle = "idle5", pst = "fishing_pst5"},
}

local function ReturnChildren(inst)
    for k,child in pairs(inst.components.childspawner.childrenoutside) do
        child.components.health:Kill()

        if child:IsAsleep() then
            child:Remove()
        end
    end
end

local function onload(inst, data)
    inst:DoTaskInTime(0, function(inst)
        if inst.components.childspawner then
            if GetClock():IsNight() and GetClock():GetMoonPhase() == "full" then
                inst.components.childspawner:StartSpawning()
                inst.components.childspawner:StopRegen()
            else
                inst.components.childspawner:StopSpawning()
                inst.components.childspawner:StartRegen()
                ReturnChildren(inst) 
            end
        end
    end)
end

local function oninvsave(inst, data)
    data.sunkeninventory = inst.sunkeninventory
end

local function oninvload(inst, data)
    if data then
        inst.sunkeninventory = data.sunkeninventory
    end
end

local function onretrieve(inst, worker, loot)
    inst:RemoveComponent("workable")

	if worker then
		if worker.components.sanity then
			worker.components.sanity:DoDelta(-TUNING.SANITY_SMALL)
		end

        inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/loot_reveal")

        if loot ~= nil and #loot > 0 then
            local x, y, z = worker.Transform:GetWorldPosition()
            for i, prefab in ipairs(loot) do
                prefab.Transform:SetPosition(x, y, z)
                if prefab.components.inventoryitem then
                    prefab.components.inventoryitem:OnDropped(true, nil, false)
                    --prefab.components.inventoryitem:OnStartFalling()
                end
            end
            --[[if worker.components.inventory then
                local srcpos = Vector3(TheSim:GetScreenPos(worker.Transform:GetWorldPosition()))
                for i, prefab in ipairs(loot) do
                    worker.components.inventory:GiveItem(prefab, nil, srcpos)
                end
            else
                local x, y, z = worker.Transform:GetWorldPosition()
                for i, prefab in ipairs(loot) do
                    prefab.Transform:SetPosition(x, 0, z)
                
                    local angle = math.random()*2*PI
                    local speed = 1
                    speed = speed * math.random()
                    prefab.Physics:SetVel(speed*math.cos(angle), GetRandomWithVariance(16, 4), speed*math.sin(angle))

                    if prefab.components.inventoryitem then
                        prefab.components.inventoryitem:OnStartFalling()
                    end
                end
            end]]
        end
    end
    inst:Remove()
end

local function onfinishcallback(inst, worker)
    local loot = {}
    if math.random() < 0.1 then
        local ghost = SpawnPrefab("pirateghost")
        if ghost then
            local pos = Point(inst.Transform:GetWorldPosition())
            ghost.Transform:SetPosition(pos.x - .3, pos.y, pos.z - .3)
        end
    else
        table.insert(loot, SpawnPrefab("seaweed"))
        if math.random() < 0.75 then
            table.insert(loot, SpawnPrefab("coral"))
        end

        if math.random() < 0.5 then
            table.insert(loot, SpawnPrefab("trinket_"..tostring(math.random(NUM_TRINKETS))))
        end
    end
    
    if not TheSim:FindFirstEntityWithTag("woodlegs_key1") and not Profile:IsCharacterUnlocked("woodlegs") then
        local num_graves = math.max(#TheSim:FindEntities(0,0,0, 1000, {"waterygrave"}), 1)

        if math.random() < 1/(num_graves or 1) then
            table.insert(loot, SpawnPrefab("woodlegs_key1"))
        end
    end
    onretrieve(inst, worker, loot)
end

local function oninvfinishcallback(inst, worker)
    local loot = {}
    if inst.sunkeninventory ~= nil then
        for k,v in pairs(inst.sunkeninventory) do
            local pref = SpawnPrefab(v.prefab)
            pref:SetPersistData(v.data, {})
            table.insert(loot, pref)
        end
    end
    onretrieve(inst, worker, loot)
end

local function commonfn(Sim)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    inst:AddTag("fishable")

    inst.anim = math.random(1, #anims)

    anim:SetBank("graves_water")
    anim:SetBuild("graves_water")
    anim:PlayAnimation(anims[inst.anim].idle, true)
    --anim:SetLayer(LAYER_WORLD_BACKGROUND)

    inst:AddComponent("inspectable")
    --inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.FISH)
    inst.components.workable:SetWorkLeft(1)

    inst:ListenForEvent("retrieve", function(inst)
        inst.AnimState:PlayAnimation(anims[inst.anim].pst, false)
        inst:ListenForEvent("animover", function(inst) inst:Hide() end)
    end)

    MakeObstaclePhysics(inst, 0.2)

    return inst
end

local function gravefn(Sim)
    local inst = commonfn(Sim)

    inst:AddComponent("childspawner")
    inst.components.childspawner.childname = "pirateghost"
    inst.components.childspawner:SetMaxChildren(1)
    inst.components.childspawner:SetSpawnPeriod(10, 3)

    inst:AddTag("waterygrave")

    inst:ListenForEvent("fullmoon", function() 
        inst.components.childspawner:StartSpawning()
        inst.components.childspawner:StopRegen()
    end, GetWorld())

    inst:ListenForEvent("daytime", function()
        inst.components.childspawner:StopSpawning()
        inst.components.childspawner:StartRegen()
        ReturnChildren(inst) 
    end, GetWorld())

    inst.components.workable:SetOnFinishCallback(onfinishcallback)

    inst.OnLoad = onload

    return inst
end

local function invgravefn(Sim)
    local inst = commonfn(Sim)

    inst.components.workable:SetOnFinishCallback(oninvfinishcallback)

    inst.sunkeninventory = {}

    inst.OnSave = oninvsave
    inst.OnLoad = oninvload

    return inst
end

return Prefab( "shipwrecked/objects/waterygrave", gravefn, assets, prefabs ),
    Prefab( "shipwrecked/objects/inventorywaterygrave", invgravefn, assets ) 
