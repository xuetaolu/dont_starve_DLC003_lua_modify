
local assets = 
{
	Asset("ANIM", "anim/bioluminessence.zip"),
}

local prefabs = 
{
}
  
local INTENSITY = .65


-- light, rad, intensity, falloff, colour, time, callback

local function turnlightoff(inst, light)
	if light then
		light:Enable(false)
	end
	-- inst:AddTag("NOCLICK")
	inst:Hide()
end

local function fadein(inst, secs)
	--print("fadein")
	inst.AnimState:PlayAnimation("idle_pre")
	inst.AnimState:PushAnimation("idle_loop", true)
	inst.Light:Enable(true)
	inst:Show()
	inst:RemoveTag("NOCLICK")

	secs = secs or 1+math.random()
	inst.components.lighttweener:StartTween(nil, 0, nil, nil, nil, 0)
	inst.components.lighttweener:StartTween(nil, INTENSITY, nil, nil, nil, secs)
end

local function fadeout(inst, secs)
	--print("fadeout")
	secs = secs or 0.5+math.random()
	inst:AddTag("NOCLICK")
	inst.components.lighttweener:StartTween(nil, INTENSITY, nil, nil, nil, 0)
	inst.components.lighttweener:StartTween(nil, 0, nil, nil, nil, secs, turnlightoff) 
end

local function updatelight(inst)
	--print("updatelight")
	if not GetClock():IsDay() and not inst.components.inventoryitem.owner then
		fadein(inst)
	else
		fadeout(inst)
	end
end

local function instantlight(inst)
	if not GetClock():IsDay() and not inst.components.inventoryitem.owner then
		fadein(inst, 0)
	else
		fadeout(inst, 0)
	end
end

local function LongUpdate(inst)
	updatelight(inst)
end 


local function OnWorked(inst, worker)
	print('onworked')
	if worker.components.inventory then
		if inst.components.inventoryitem then
			inst.components.inventoryitem.canbepickedup = true
		end
		inst.Light:Enable(false)
		worker.components.inventory:GiveItem(inst, nil, Vector3(TheSim:GetScreenPos(inst.Transform:GetWorldPosition())))
	end
end

local function onwake(inst)
	updatelight(inst)
	inst:ListenForEvent("daytime", inst.daytime, GetWorld())
	inst:ListenForEvent("dusktime", inst.nighttime, GetWorld())
	inst.OnLongUpdate = LongUpdate
end

local function onsleep(inst)
	inst:RemoveEventCallback("daytime", inst.daytime, GetWorld())
	inst:RemoveEventCallback("dusktime", inst.nighttime, GetWorld())
	inst.OnLongUpdate = nil
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()

	inst.OnEntityWake = onwake
	inst.OnEntitySleep = onsleep

	inst.no_wet_prefix = true


	MakeInventoryPhysics(inst)

	inst:AddTag("unramable")
	inst:AddTag("aquatic")
	inst.entity:AddAnimState()
	inst.AnimState:SetBank("bioluminessence")
	inst.AnimState:SetBuild("bioluminessence")
	inst.AnimState:PlayAnimation("idle_loop", true)   
	inst.AnimState:SetLayer( LAYER_BACKGROUND )
	inst.AnimState:SetSortOrder( 3 )
	inst.AnimState:SetRayTestOnBB(true)
	
	inst:AddComponent("lighttweener")
	local light = inst.entity:AddLight()
	inst.entity:AddLight()
	inst.Light:SetColour(0/255, 180/255, 255/255)
	inst.Light:Enable(false)
	inst.Light:SetIntensity(0.65)
	inst.Light:SetRadius(0.9)
	inst.Light:SetFalloff(.45)


	inst:AddComponent("inventoryitem")
	inst:AddComponent("inspectable")
	inst.components.inventoryitem.canbepickedup = false 
	inst.components.inventoryitem:SetOnDroppedFn(function(inst)
		inst.components.workable:SetWorkLeft(1)
		onwake(inst)
	end)
	inst.components.inventoryitem:SetOnPickupFn(function(inst)
		onsleep(inst)
	end)

	inst:AddComponent("stackable")
	inst.components.stackable.forcedropsingle = true
	inst:AddComponent("fader")
	inst:AddComponent("fuel")
	inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL
	inst.components.fuel.fueltype = "CAVE"

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.NET)
	inst.components.workable:SetWorkLeft(1)
	inst.components.workable:SetOnFinishCallback(OnWorked)


	inst:AddComponent("floatable")
	inst.components.floatable.onwater = true 
	inst.components.floatable:SetOnHitWaterFn(function(inst) updatelight(inst) end)
	inst.components.floatable:SetOnHitLandFn(function(inst) 
		-- When the gamne loads, these are temporarily not in an inventory.. so they were hitting the ground and being
		-- destroyed. Delaying a frame waits until they have a chance to be inventoried before being removed. 
		-- Load post pass might also have worked
		inst:DoTaskInTime(0,function()
			if not inst.components.inventoryitem.owner then			
				local x, y, z = inst.Transform:GetLocalPosition()
				local fx = SpawnPrefab("splash_water_drop")
				fx.Transform:SetPosition(x, y, z)
				inst:Remove()
			end
		end)

	 end)

	inst.daytime = function() updatelight(inst) end
	inst.nighttime = function() updatelight(inst) end
	
	inst.components.lighttweener:StartTween(light, nil, nil, nil, nil, 0, instantlight)

	return inst
end

return Prefab("common/bioluminescence", fn, assets, prefabs)
