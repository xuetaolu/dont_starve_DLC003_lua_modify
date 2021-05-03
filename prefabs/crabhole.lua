local assets =
{
	Asset("ANIM", "anim/rabbit_hole.zip"),
}

local prefabs = 
{
	"crab",
	"smallmeat",
}


local function dig_up(inst, chopper)
	if inst.components.spawner:IsOccupied() then
		inst.components.lootdropper:SpawnLootPrefab("crab")
	end
	inst:Remove()
end

local function startspawning(inst)
    if inst.components.spawner and not inst.spring then
    	if not inst.components.spawner:IsSpawnPending() then
    		inst.components.spawner:SpawnWithDelay(60 + math.random(120) )
    	end
    end
end

local function stopspawning(inst)
    if inst.components.spawner then
        inst.components.spawner:CancelSpawning()
    end
end

local function onoccupied(inst)
    if GetClock():IsDay() then
        startspawning(inst)
    end
    if inst.spring then
    	inst.AnimState:PlayAnimation("idle_flooded")
    	inst.wet_prefix = STRINGS.WET_PREFIX.RABBITHOLE
    	inst.always_wet = true
    end
end

local function GetChild(inst)
	return "crab"
end

local function SetSpringMode(inst, force)
	if not inst.spring or force then
		stopspawning(inst)
		inst.springtask = nil
		inst.spring = true
		if inst.components.spawner:IsOccupied() then
			inst.AnimState:PlayAnimation("idle_flooded")
			inst.wet_prefix = STRINGS.WET_PREFIX.RABBITHOLE
			inst.always_wet = true
		end
	end
end

local function SetNormalMode(inst, force)
	if inst.spring or force then
		inst.AnimState:PlayAnimation("idle")
		if GetClock():IsDay() and inst.components.spawner and not inst.components.spawner:IsSpawnPending() then
	        startspawning(inst)
	    end
	    inst.normaltask = nil
	    inst.spring = false
	   	inst.wet_prefix = STRINGS.WET_PREFIX.GENERIC
	   	inst.always_wet = false
	end
end

local function OnWake(inst)
	if inst.spring and inst.components.spawner and inst.components.spawner:IsOccupied() then
		if inst.components.spawner:IsSpawnPending() then
			stopspawning(inst)
		end
		inst.AnimState:PlayAnimation("idle_flooded")
		inst.wet_prefix = STRINGS.WET_PREFIX.RABBITHOLE
		inst.always_wet = true
		if inst.springtask then
			inst.springtask:Cancel()
			inst.springtask = nil
		end
	end
end

local function CheckFlooding(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	if GetWorld().Flooding and GetWorld().Flooding:OnFlood(x, y, z) then
		SetSpringMode(inst, true)
	end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

    anim:SetBank("rabbithole")
    anim:SetBuild("rabbit_hole")
    anim:PlayAnimation("idle")
	--anim:SetOrientation( ANIM_ORIENTATION.OnGround )
	anim:SetLayer( LAYER_BACKGROUND )
	anim:SetSortOrder( 3 )

	inst:AddComponent( "spawner" )
	inst.components.spawner:Configure( "crab", TUNING.RABBIT_RESPAWN_TIME)
	inst.components.spawner.childfn = GetChild

	inst:AddTag("cattoy")
	
	inst.components.spawner:SetOnOccupiedFn(onoccupied)
	inst.components.spawner:SetOnVacateFn(stopspawning)
    
	inst:AddComponent("lootdropper")
	inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetOnFinishCallback(dig_up)
    inst.components.workable:SetWorkLeft(1)
    
	inst:ListenForEvent( "dusktime", function() stopspawning(inst) end, GetWorld())
	inst:ListenForEvent( "daytime", function() startspawning(inst) end, GetWorld())

	inst:DoTaskInTime(.1, function(inst) SetNormalMode(inst, true) end)

	inst.spring = GetSeasonManager():IsGreenSeason()
	if inst.spring then
		inst:DoTaskInTime(.1, function(inst) SetSpringMode(inst, true) end)
	else
		inst:DoTaskInTime(.1, function(inst) SetNormalMode(inst, true) end)
	end
	inst:ListenForEvent( "rainstart", function(it, data)
		if GetSeasonManager() and GetSeasonManager():IsGreenSeason() and not inst.spring then
			inst.springtask = inst:DoTaskInTime(math.random(3,20), SetSpringMode)
		end
	end, GetWorld())

	inst:ListenForEvent("seasonChange", function(it, data)
		if data.season ~= SEASONS.GREEN and inst.spring then
			inst.normaltask = inst:DoTaskInTime(math.random(TUNING.MIN_RABBIT_HOLE_TRANSITION_TIME, TUNING.MAX_RABBIT_HOLE_TRANSITION_TIME), SetNormalMode)
		end
	end, GetWorld())

	inst:ListenForEvent("floodChange", function(it, data)
		CheckFlooding(inst)
	end, GetWorld())

	inst.OnEntityWake = OnWake
	
    inst:AddComponent("inspectable")


    inst.components.inspectable.getstatus =  function(inst)
    	if inst.spring then
    		return "SPRING"
    	end
   	end
	
    return inst
end

return Prefab( "common/objects/crabhole", fn, assets, prefabs ) 
