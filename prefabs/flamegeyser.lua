local assets=
{
	Asset("ANIM", "anim/geyser.zip"),
    Asset("MINIMAP_IMAGE", "geyser"),
}


local function StartBurning(inst)
    inst.Light:Enable(true)
    
    inst.components.geyserfx:Ignite()
end

local function OnIgnite(inst)
    StartBurning(inst)
end

local function OnBurn(inst)
    inst.components.fueled:StartConsuming()
    inst.components.propagator:StartSpreading()
    inst.components.geyserfx:SetPercent(inst.components.fueled:GetPercent())
    inst:AddComponent("cooker")
end

local function SetIgniteTimer(inst)
    inst:DoTaskInTime(GetRandomWithVariance(TUNING.FLAMEGEYSER_REIGNITE_TIME, TUNING.FLAMEGEYSER_REIGNITE_TIME_VARIANCE), function()
        if not inst.components.floodable.flooded then 
            inst.components.fueled:SetPercent(1.0)
            OnIgnite(inst)
        end 
    end)
end

local function OnErupt(inst)
    StartBurning(inst)
    inst.components.fueled:SetPercent(1.0)
    OnBurn(inst)
    TheCamera:Shake("FULL", 0.7, 0.02, 0.75)
end

local function OnExtinguish(inst, setTimer)
    if setTimer == nil then 
        setTimer = true
    end 
    inst.AnimState:ClearBloomEffectHandle()
    inst.components.fueled:StopConsuming()
    inst.components.propagator:StopSpreading()
    inst.components.geyserfx:Extinguish()
    if inst.components.cooker then 
        inst:RemoveComponent("cooker")
    end 
    if setTimer then 
        SetIgniteTimer(inst)
    end 
end

local function OnIdle(inst)
    inst.AnimState:PlayAnimation("idle_dormant", true)
    inst.Light:Enable(false)
end

local function OnLoad(inst, data)
    if not inst.components.fueled:IsEmpty() then
        OnIgnite(inst)
    else
        SetIgniteTimer(inst)
    end
end

local heats = { 70, 85, 100, 115 }
local function GetHeatFn(inst)
    return 100 --heats[inst.components.geyserfx.level] or 20
end

local function onFloodedStart(inst)
    inst.components.fueled:SetPercent(0)
    OnExtinguish(inst, false)
end


local function onFloodedEnd(inst)
    SetIgniteTimer(inst)
end 

local function fn(Sim)
	local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    local light = inst.entity:AddLight()
    local sound = inst.entity:AddSoundEmitter()
    local minimap = inst.entity:AddMiniMapEntity()

    MakeObstaclePhysics(inst, 2.05)
    inst.Physics:SetCollides(false)

	minimap:SetIcon("geyser.png")
    anim:SetBank("geyser")
    anim:SetBuild("geyser")
    anim:PlayAnimation("idle_dormant", true)
    anim:SetBloomEffectHandle( "shaders/anim.ksh" )

    inst:AddComponent("inspectable")
    inst:AddComponent("heater")
    inst.components.heater.heatfn = GetHeatFn

    inst:AddComponent("fueled")
    inst.components.fueled.maxfuel = TUNING.FLAMEGEYSER_FUEL_MAX
    inst.components.fueled.accepting = false
    inst:AddComponent("propagator")
    inst.components.propagator.damagerange = 2
    inst.components.propagator.damages = true

    inst.components.fueled:SetSections(4)
    inst.components.fueled.rate = 1
    inst.components.fueled.period = 1

    inst:AddComponent("floodable")
    inst.components.floodable.onStartFlooded = onFloodedStart
    inst.components.floodable.onStopFlooded = onFloodedEnd

    inst.components.fueled:SetUpdateFn( function()
        if not inst.components.fueled:IsEmpty() then
            inst.components.geyserfx:SetPercent(inst.components.fueled:GetPercent())
        end
    end)
        
    inst.components.fueled:SetSectionCallback( function(section)
        if section == 0 then
            OnExtinguish(inst)
        else
            local damagerange = {2,2,2,2}
            local ranges = {2,2,2,4}
            local output = {4,10,20,40}
            inst.components.propagator.damagerange = damagerange[section]
            inst.components.propagator.propagaterange = ranges[section]
            inst.components.propagator.heatoutput = output[section]
        end
    end)
        
    inst.components.fueled:InitializeFuelLevel(TUNING.FLAMEGEYSER_FUEL_START)

    inst:AddComponent("geyserfx")
    inst.components.geyserfx.usedayparamforsound = true
    inst.components.geyserfx.lightsound = "dontstarve_DLC002/common/flamegeyser_open"
    --inst.components.geyserfx.extinguishsound = "dontstarve_DLC002/common/flamegeyser_out"
    inst.components.geyserfx.pre =
    {
        {percent=1.0, anim="active_pre", radius=0, intensity=.8, falloff=.33, colour = {255/255,187/255,187/255}, soundintensity=.1},
        {percent=1.0-(24/42), sound="dontstarve_DLC002/common/flamegeyser_lp", radius=1, intensity=.8, falloff=.33, colour = {255/255,187/255,187/255}, soundintensity=1},
        {percent=0.0, sound="dontstarve_DLC002/common/flamegeyser_lp", radius=3.5, intensity=.8, falloff=.33, colour = {255/255,187/255,187/255}, soundintensity=1},
    }
    inst.components.geyserfx.levels =
    {
        {percent=1.0, anim="active_loop", sound="dontstarve_DLC002/common/flamegeyser_lp", radius=3.5, intensity=.8, falloff=.33, colour = {255/255,187/255,187/255}, soundintensity=1},
    }
    inst.components.geyserfx.pst =
    {
        {percent=1.0, anim="active_pst", sound="dontstarve_DLC002/common/flamegeyser_lp", radius=3.5, intensity=.8, falloff=.33, colour = {255/255,187/255,187/255}, soundintensity=1},
        {percent=1.0-(61/96), sound="dontstarve_DLC002/common/flamegeyser_out", radius=0, intensity=.8, falloff=.33, colour = {255/255,187/255,187/255}, soundintensity=.1},
    }


    if not inst.components.fueled:IsEmpty() then
        OnIgnite(inst)
    end
    
    inst:DoTaskInTime(1, function()
        if inst:GetIsFlooded() then 
            onFloodedStart(inst)
        end 
    end)


    inst.OnIgnite = OnIgnite
    inst.OnErupt = OnErupt
    inst.OnBurn = OnBurn
    inst.OnIdle = OnIdle

    return inst
end

return Prefab( "common/shipwrecked/flamegeyser", fn, assets)