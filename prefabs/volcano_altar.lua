require "prefabutil"

local LARGE_APPEASEMENT = TUNING.APPEASEMENT_LARGE
local LARGE_WRATH = TUNING.WRATH_LARGE

local prefabs =
{
    "obsidian",
    "volcano_altar_tower",
    "volcano_altar_meter",
    --"volcano_altar_grate", 
    "volcano_altar_pillar"
}

local baseassets = 
{
    Asset("ANIM", "anim/volcano_altar_fx.zip"),
    Asset("MINIMAP_IMAGE", "volcano_altar")
}

local towerassets = 
{
    Asset("ANIM", "anim/volcano_altar.zip"),
}

local meterassets = 
{
    Asset("ANIM", "anim/altar_meter.zip"),
}

--[[local grateassets = 
{
    Asset("ANIM", "anim/altar_grate.zip"),
}]]

local pillarassets = 
{
    Asset("ANIM", "anim/altar_pillar.zip"),
}


local function UpdateMeter(inst)
    local sm = GetSeasonManager()
    local vm = GetVolcanoManager()
    if vm:IsFireRaining() then
        inst.components.volcanometer.targetseg = 0
    elseif sm:GetSeason() == SEASONS.DRY then
        inst.components.volcanometer.maxseg = vm:GetNumSegmentsOfEruption() or 67
        inst.components.volcanometer.targetseg = vm:GetNumSegmentsUntilEruption() or inst.components.volcanometer.maxseg
    else
        inst.components.volcanometer.maxseg = 10
        inst.components.volcanometer.targetseg = 10
    end
    inst.components.volcanometer:Start()
end

local function OnGetItemFromPlayer(inst, giver, item)
    local vm = GetWorld().components.volcanomanager
    local appeasesegs = item.components.appeasement.appeasementvalue
    vm:Appease(appeasesegs)

    inst.appeasements = inst.appeasements + 1

    if inst.meterprefab then 
        UpdateMeter(inst.meterprefab)
    end

    inst.fullappeased = inst.meterprefab.components.volcanometer.targetseg >= inst.meterprefab.components.volcanometer.maxseg

    if appeasesegs > 0 then
        inst.sg:GoToState("appeased")
    else
        if giver and giver.components.health then
            giver.components.health:DoFireDamage(TUNING.VOLCANO_ALTAR_DAMAGE, inst, true)
        end
        inst.sg:GoToState("unappeased")
    end

    print(string.format("Volcano Altar takes your %d seg appeasement from %s\n", appeasesegs, tostring(item.prefab)))
end

local function AcceptTest(inst, item, giver)
    return inst.sg.currentstate.name == "opened"
end

local function SetIsOpen(inst)
    local sm = GetSeasonManager()
    local vm = GetVolcanoManager()
    if not inst:FullAppeased() and sm:IsDrySeason() and not vm:IsFireRaining() then
    --if inst.appeasements < TUNING.VOLCANO_ALTAR_MAXAPPEASEMENTS and sm:IsDrySeason() and not vm:IsErupting() then
        if inst.sg.currentstate.name ~= "opened" then
            inst.sg:GoToState("open")
        end
        inst.components.appeasable:Enable()
    else
        if inst.sg.currentstate.name ~= "closed" then
            inst.sg:GoToState("close")
        end
        inst.components.appeasable:Disable()
    end
end

local function getstatus(inst)
    if inst.components.appeasable.enabled then 
        return "OPEN"
    else
        return "CLOSED"
    end
end

local function onsave(inst, data)
    data.fullappeased = inst.fullappeased
    data.appeasements = inst.appeasements
end

local function onload(inst, data)
    inst.fullappeased = data and data.fullappeased and data.fullappeased == true
    inst.appeasements = (data and data.appeasements) or 0
end

local function onloadpostpass(inst, ents, data)
    SetIsOpen(inst)
end

local function fullappeased(inst)
    return inst.meterprefab and inst.meterprefab.components.volcanometer.targetseg >= inst.meterprefab.components.volcanometer.maxseg
end

local toweroff = 0
local meteroff = 1
local altaroff = 2

local function baseFn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetPriority( 5 )
	minimap:SetIcon( "volcano_altar.png" )
    inst.Transform:SetScale(1,1,1)
    
	MakeObstaclePhysics(inst, 2.0, 1.2)
    
	inst.entity:AddSoundEmitter()

	anim:SetBank("volcano_altar_fx")
	anim:SetBuild("volcano_altar_fx")
	anim:PlayAnimation("idle_close")
    --anim:SetLayer(LAYER_WORLD)
    --anim:SetSortOrder(2)
    anim:SetFinalOffset(altaroff)

    inst.entity:AddLight()
    inst.Light:Enable(true)
    inst.Light:SetIntensity(.75)
    inst.Light:SetColour(197/255,197/255,50/255)
    inst.Light:SetFalloff( 0.5 )
    inst.Light:SetRadius( 2 )

	--inst:AddTag("prototyper")
	inst:AddTag("altar")
    inst:AddTag("structure")
    inst:AddTag("stone")
	
	inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("appeasable")
    inst.components.appeasable.onaccept = OnGetItemFromPlayer
    inst.components.appeasable:SetAcceptTest(AcceptTest)
    inst.components.appeasable:Disable()

    inst:SetPrefabName("volcano_altar")

    local function createExtras(inst)
        local x, y, z = inst.Transform:GetWorldPosition()
        inst.meterprefab =  SpawnPrefab("volcano_altar_meter")
        inst.meterprefab.Transform:SetPosition( x, y, z )
        inst.towerprefab =  SpawnPrefab("volcano_altar_tower")
        inst.towerprefab.Transform:SetPosition( x, y, z )
        UpdateMeter(inst.meterprefab)
        print("createExtras", inst.meterprefab.components.volcanometer:GetDebugString())
        inst.meterprefab.components.volcanometer.curseg = inst.meterprefab.components.volcanometer.targetseg
        inst.meterprefab.components.volcanometer:UpdateMeter()
    end

    inst.fullappeased = false
    inst.appeasements = 0

    inst:DoPeriodicTask(10, SetIsOpen)

    inst:ListenForEvent("seasonChange", function(it, data)
        if data.season ~= SEASONS.DRY then
            --inst.fullappeased = false
            inst.appeasements = 0
        end
        SetIsOpen(inst)
    end,  GetWorld())

    --inst:ListenForEvent("daytime", function(it, data)
    --    SetIsOpen(inst)
    --end, GetWorld())

    --inst:ListenForEvent("nighttime", function(it, data)
    --    inst.fullappeased = false
    --    inst.appeasements = 0
    --end, GetWorld())

    inst:ListenForEvent("OnVolcanoEruptionBegin", function(it, data)
        SetIsOpen(inst)
    end, GetWorld())

    inst:ListenForEvent("OnVolcanoFireRainEnd", function(it, data)
        inst.fullappeased = false
        SetIsOpen(inst)
    end, GetWorld())
 
    inst:DoTaskInTime(FRAMES * 1, createExtras)

    inst:SetStateGraph("SGvolcanoaltar")

    inst.OnSave = onsave
    inst.OnLoad = onload
    inst.OnLoadPostPass = onloadpostpass
    inst.FullAppeased = fullappeased

    SetIsOpen(inst)

	return inst
end


local function meterFn(Sim)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()

    inst.Transform:SetScale(1,1,1)
    
    anim:SetBank("volcano_altar")
    anim:SetBuild("volcano_altar")
    anim:PlayAnimation("meter")
    --anim:SetLayer(LAYER_WORLD)
    --anim:SetSortOrder(1)
    anim:SetFinalOffset(meteroff)
    anim:SetPercent("meter", 0)
    inst.persists = false

    inst:AddComponent("volcanometer")
    inst.components.volcanometer.targetseg = 66 --66 seems to the longest time between eruptions but this number really shouldn't be hardcoded.
    inst.components.volcanometer.curseg = 66
    inst.components.volcanometer.maxseg = 66
    inst.components.volcanometer.updatemeterfn = function(inst, perc)
        inst.AnimState:SetPercent("meter", perc)
    end
    inst.components.volcanometer.updatedonefn = function(inst)
        inst:PushEvent("MeterDone")
    end

    UpdateMeter(inst)

    inst:DoPeriodicTask(10, UpdateMeter)

    inst:ListenForEvent("seasonChange", function(it, data)
        UpdateMeter(inst)
        if data and data.season == "dry" then
            inst.components.volcanometer.curseg = inst.components.volcanometer.targetseg
        end
    end, GetWorld())

    inst:ListenForEvent("OnVolcanoEruptionBegin", function(it, data)
        UpdateMeter(inst)
    end, GetWorld())

    inst:ListenForEvent("OnVolcanoFireRainEnd", function(it, data)
        UpdateMeter(inst)
    end, GetWorld())

    return inst
end

local function towerFn(Sim)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    --MakeObstaclePhysics(inst, 1.0)
    inst.Transform:SetScale(1,1,1)
    
    anim:SetBank("volcano_altar")
    anim:SetBuild("volcano_altar")
    anim:PlayAnimation("idle_close")
    --anim:SetLayer(LAYER_WORLD)
    --anim:SetSortOrder(0)
    anim:SetFinalOffset(toweroff)
    inst.persists = false
    return inst
end

--[[local function grateFn(Sim)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()

    --anim:SetLayer( LAYER_BACKGROUND )
    --anim:SetOrientation( ANIM_ORIENTATION.OnGround )
    anim:SetSortOrder( 0 )

    inst.Transform:SetScale(1,1,1)
    
    anim:SetBank("altar_grate")
    anim:SetBuild("altar_grate")
    anim:PlayAnimation("idle")

    local function updateSmoke(inst)
         local seasonmgr = GetSeasonManager()
        local season = seasonmgr:GetSeason()
        if season == SEASONS.DRY then
            anim:PlayAnimation("smoke", true)
        else 
            anim:PlayAnimation("idle")
        end 
    end

    updateSmoke(inst)

    inst:ListenForEvent("seasonChange", function(it, data)
        updateSmoke(inst)
    end,  GetWorld())

    return inst
end]]



local function pillarFn(Sim)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    MakeObstaclePhysics(inst, .25)   
    inst.Transform:SetScale(1,1,1)
    
    anim:SetBank("altar_pillar")
    anim:SetBuild("altar_pillar")
    anim:PlayAnimation("idle")
    return inst
end



return Prefab( "common/objects/volcano_altar", baseFn, baseassets, prefabs), 
       Prefab( "common/objects/volcano_altar_tower", towerFn, towerassets),
       Prefab( "common/objects/volcano_altar_meter", meterFn, meterassets,nil), 
       --Prefab( "common/objects/volcano_altar_grate", grateFn, grateassets,nil), 
       Prefab( "common/objects/volcano_altar_pillar", pillarFn, pillarassets,nil)







