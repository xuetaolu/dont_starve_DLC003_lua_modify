local assets=
{
	Asset("ANIM", "anim/lava_pool.zip"),
}

local prefabs=
{
    "ash",
    "rocks",
    "charcoal",
    -- "dragoon",
    "rock1",
    "obsidian",
}



local function CollectUseActions(inst, useitem, actions, right)
    if useitem.prefab == "ice" then
        table.insert(actions, ACTIONS.GIVE)
    elseif useitem.components.cookable then
        table.insert(actions, ACTIONS.COOK)
    end
end

local function ShouldAcceptItem(inst, item)
    return item.prefab == "ice"
end

local function OnGetItemFromPlayer(inst, giver, item)
    local x, y, z = inst.Transform:GetWorldPosition()
    local obsidian = SpawnPrefab("obsidian")
    obsidian.Transform:SetPosition(x, y, z)

    SpawnPrefab("collapse_small").Transform:SetPosition(x, y, z)

    --inst.cooltask:Cancel()
    inst:Remove()
end

local function OnRefuseItem(inst, giver, item)
    print("Lavapool refuses "..tostring(item.prefab))
end

local function OnIgnite(inst)
end

local function OnExtinguish(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    --spawn some things
    local radius = 1
    local things = {"rocks", "rocks", "ash", "ash", "charcoal"}
    for i = 1, #things, 1 do
        local thing = SpawnPrefab(things[i])
        thing.Transform:SetPosition(x + radius * UnitRand(), y, z + radius * UnitRand())
    end

    -- if math.random() < 0.25 then
    --     local snake = SpawnPrefab("dragoon")
    --     snake.Transform:SetPosition(x, y, z)
    --     snake.components.combat:SetTarget(GetPlayer())
    -- end

    inst.AnimState:ClearBloomEffectHandle()
    inst:Remove()
end

local function OnFloodedStart(inst)
    if inst.components.burnable then
        inst.components.burnable:Extinguish()
    end
end

local INTENSITY = .8

--[[local function fade_in(inst)
    inst.components.fader:StopAll()
    inst.Light:Enable(true)
    inst.components.fader:Fade(0, INTENSITY, 5*FRAMES, function(v) inst.Light:SetIntensity(v) end)
end

local function fade_out(inst)
    inst.components.fader:StopAll()
    inst.components.fader:Fade(INTENSITY, 0, 5*FRAMES, function(v) inst.Light:SetIntensity(v) end, function() inst.Light:Enable(false) end)
end]]

local function fn(Sim)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddLight()

    inst.AnimState:SetBank("lava_pool")
    inst.AnimState:SetBuild("lava_pool")
    inst.Transform:SetFourFaced()

    inst:AddTag("fire")

    inst.AnimState:PlayAnimation("dump")
    inst.AnimState:PushAnimation("idle_loop")
    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )


    MakeObstaclePhysics(inst, .6)
    inst.Physics:SetCollides(false)

    --[[inst.cooltask = inst:DoTaskInTime(30, function(inst) 
        --inst.AnimState:PushAnimation("cool", false)
        fade_out(inst)
        inst:DoTaskInTime(4*FRAMES, function(inst)
            inst.AnimState:ClearBloomEffectHandle()
        end)
        if inst.components.propagator then 
            inst.components.propagator:StopSpreading()
            inst:RemoveComponent("propagator") 
        end

        local x, y, z = inst.Transform:GetWorldPosition()
        --spawn some things
        local radius = 1
        local things = {"rocks", "rocks", "ash", "ash", "charcoal"}
        for i = 1, #things, 1 do
            local thing = SpawnPrefab(things[i])
            thing.Transform:SetPosition(x + radius * UnitRand(), y, z + radius * UnitRand())
        end

        if math.random() < 0.25 then
            local snake = SpawnPrefab("dragoon")
            snake.Transform:SetPosition(x, y, z)
            snake.components.combat:SetTarget(GetPlayer())
        end

        inst:Remove()
    end)]]

    inst:AddComponent("burnable")
    inst.components.burnable:AddBurnFX("campfirefire", Vector3(0,0,0) )
    inst.components.burnable:MakeNotWildfireStarter()
    inst:ListenForEvent("onextinguish", OnExtinguish)
    inst:ListenForEvent("onignite", OnIgnite)

    -------------------------
    inst:AddComponent("fueled")
    inst.components.fueled.maxfuel = TUNING.LAVAPOOL_FUEL_MAX
    inst.components.fueled.accepting = false
    inst:AddComponent("propagator")
    inst.components.propagator.damagerange = 1
    inst.components.propagator.damages = true

    inst.components.fueled:SetSections(4)
    inst.components.fueled.rate = 1

    inst.components.fueled:SetUpdateFn( function()
        if inst.components.burnable and inst.components.fueled then
            inst.components.burnable:SetFXLevel(inst.components.fueled:GetCurrentSection(), inst.components.fueled:GetSectionPercent())
        end
    end)
        
    inst.components.fueled:SetSectionCallback( function(section)
        if section == 0 then
            inst.components.burnable:Extinguish() 

        else
            if not inst.components.burnable:IsBurning() then
                inst.components.burnable:Ignite()
            end
            
            inst.components.burnable:SetFXLevel(section, inst.components.fueled:GetSectionPercent())
            local ranges = {1,1,1,1}
            local output = {2,5,5,10}
            inst.components.propagator.propagaterange = ranges[section]
            inst.components.propagator.heatoutput = output[section]
        end
    end)
        
    inst.components.fueled:InitializeFuelLevel(TUNING.LAVAPOOL_FUEL_START)


      
    inst:AddComponent("inspectable")

    inst:AddComponent("cooker")

    inst:AddComponent("floodable")
    inst.components.floodable.onStartFlooded = OnFloodedStart

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem
    inst.CollectUseActions = CollectUseActions

    return inst
end

return Prefab( "common/shipwrecked/lavapool", fn, assets, prefabs)