local assets =
{
	Asset("ANIM", "anim/fireflies.zip"),
}

local INTENSITY = .5



local function fadein(inst)
    inst.components.fader:StopAll()
    inst.AnimState:PlayAnimation("swarm_pre")
    inst.AnimState:PushAnimation("swarm_loop", true)
    inst.Light:Enable(true)
	if inst:IsAsleep() then
		inst.Light:SetIntensity(INTENSITY)
	else
		inst.Light:SetIntensity(0)
		inst.components.fader:Fade(0, INTENSITY, 3+math.random()*2, function(v) inst.Light:SetIntensity(v) end, function() inst:RemoveTag("NOCLICK") end)
	end
end

local function fadeout(inst)
    inst.components.fader:StopAll()
    inst.AnimState:PlayAnimation("swarm_pst")
	if inst:IsAsleep() then
		inst.Light:SetIntensity(0)
	else
		inst.components.fader:Fade(INTENSITY, 0, .75+math.random()*1, function(v) inst.Light:SetIntensity(v) end, function() inst:AddTag("NOCLICK") inst.Light:Enable(false) end)
	end
end

local function updatelight(inst)
    local ground = GetWorld()
    local x,y,z = GetPlayer().Transform:GetWorldPosition()
    local tile_type = ground.Map:GetTileAtPoint(x,y,z)
    if tile_type == GROUND.DEEPRAINFOREST or tile_type == GROUND.GASJUNGLE then 
        inst:AddTag("under_leaf_canopy")
    else
        inst:RemoveTag("under_leaf_canopy")
    end   

   
    if (GetClock():IsNight() or (inst:HasTag("under_leaf_canopy") and GetClock():IsDusk()) ) and not GetSeasonManager():IsWetSeason() and not inst.components.playerprox:IsPlayerClose() and not inst.components.inventoryitem.owner then
        if not inst.lighton then
            fadein(inst)
        else
            inst.Light:Enable(true)
            inst.Light:SetIntensity(INTENSITY)
        end
        inst.lighton = true
        inst:RemoveTag("NOCLICK")
    else
        if inst.lighton then
            fadeout(inst)
        else
            inst.Light:Enable(false)
            inst.Light:SetIntensity(0)
        end
        inst.lighton = false
        inst:AddTag("NOCLICK")
    end
end

local function ondropped(inst)
    if inst.components.inventoryitem then inst.components.inventoryitem.canbepickedup = false end
    if inst.components.workable then inst.components.workable:SetWorkLeft(1) end
    
    inst.components.fader:Fade(0, INTENSITY, 0, function(v) inst.Light:SetIntensity(v) end, function() inst:RemoveTag("NOCLICK") end)
    inst.lighton = true

    updatelight(inst)
end

local function getstatus(inst)
    if inst.components.inventoryitem and inst.components.inventoryitem.owner then
        return "HELD"
    end
end 

-- onfar gets hit on spawn and on load, so we don't have to update the light in the constructor
local function onfar(inst) 
    updatelight(inst)
end

local function onnear(inst) 
	updatelight(inst) 
end

local function fn(Sim)


	local inst = CreateEntity()

    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    inst.entity:AddPhysics()
 
    local light = inst.entity:AddLight()
    light:SetFalloff(1)
    light:SetIntensity(INTENSITY)
    light:SetRadius(1)
    light:SetColour(180/255, 195/255, 150/255)
    light:Enable(false)
    
    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
    
    inst.AnimState:SetBank("fireflies")
    inst.AnimState:SetBuild("fireflies")


    inst.AnimState:SetRayTestOnBB(true);
    
    inst:AddComponent("playerprox")

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus
    
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.NET)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(function(inst, worker)
        if worker.components.inventory then
            if inst.components.inventoryitem then inst.components.inventoryitem.canbepickedup = true end
            if inst.components.fader then inst.components.fader:StopAll() end
            inst:AddTag("NOCLICK")
            inst.Light:Enable(false)
            inst.lighton = false
            worker.components.inventory:GiveItem(inst, nil, Vector3(TheSim:GetScreenPos(inst.Transform:GetWorldPosition())))
        end
    end)

    inst:AddComponent("fader")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    inst.components.stackable.forcedropsingle = true

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem.canbepickedup = false

    inst:AddTag("cattoyairborne")
    inst:AddComponent("tradable")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL
    inst.components.fuel.fueltype = "CAVE"

    inst.components.playerprox:SetDist(3,5)
    inst.components.playerprox:SetOnPlayerNear(onnear)
    inst.components.playerprox:SetOnPlayerFar(onfar)

    inst:AddComponent("appeasement")
    inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_SMALL

    inst:ListenForEvent( "daytime", function()
        inst:DoTaskInTime(2+math.random()*1, function() updatelight(inst) end)
    end, GetWorld())
    inst:ListenForEvent( "nighttime", function()
        inst:DoTaskInTime(2+math.random()*1, function() updatelight(inst) end)
    end, GetWorld())
    inst:ListenForEvent( "dusktime", function()
        inst:DoTaskInTime(2+math.random()*1, function() updatelight(inst) end)
    end, GetWorld())    
    inst:ListenForEvent( "seasonChange", function()
        inst:DoTaskInTime(2+math.random()*1, function() updatelight(inst) end)
    end, GetWorld())
    inst:ListenForEvent( "onchangecanopyzone", function()
        inst:DoTaskInTime(2+math.random()*1, function() updatelight(inst) end)
    end, GetWorld())
    
    return inst
end

return Prefab( "common/objects/fireflies", fn, assets) 

