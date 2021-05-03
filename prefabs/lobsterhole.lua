local assets =
{
	Asset("ANIM", "anim/lobster_home.zip"),
}

local prefabs = 
{
	"lobster",
	"smallmeat",
}


--[[
local function dig_up(inst, chopper)
	if inst.components.spawner:IsOccupied() then
		inst.components.lootdropper:SpawnLootPrefab("lobster")
	end
	inst:Remove()
end
]]
local function startspawning(inst)
	if inst.components.spawner and not inst.spring then
		if not inst.components.spawner:IsSpawnPending() then
			inst.components.spawner:SpawnWithDelay(10 + math.random(15) )
		end
	end
end

local function stopspawning(inst)
	if inst.components.spawner then
		inst.components.spawner:CancelSpawning()
	end
end

local function onoccupied(inst)
	if not GetClock():IsDay() then
		startspawning(inst)
	end
	if inst.spring then
		-- inst.AnimState:PlayAnimation("idle_flooded")
		-- inst.wet_prefix = STRINGS.WET_PREFIX.RABBITHOLE
		inst.always_wet = true
	end
end

local function GetChild(inst)
	return "lobster"
end

local function SetSpringMode(inst, force)
	if not inst.spring or force then
		stopspawning(inst)
		inst.springtask = nil
		inst.spring = true
		if inst.components.spawner:IsOccupied() then
			-- inst.AnimState:PlayAnimation("idle_flooded")
			-- inst.wet_prefix = STRINGS.WET_PREFIX.RABBITHOLE
			inst.always_wet = true
		end
	end
end

local function SetNormalMode(inst, force)
	if inst.spring or force then
		--inst.AnimState:PlayAnimation("idle")
		if not GetClock():IsDay() and inst.components.spawner and not inst.components.spawner:IsSpawnPending() then
			startspawning(inst)
		end
		inst.normaltask = nil
		inst.spring = false
		--inst.wet_prefix = STRINGS.WET_PREFIX.GENERIC
		inst.always_wet = false
	end
end

local function OnWake(inst)
	if inst.spring and inst.components.spawner and inst.components.spawner:IsOccupied() then
		if inst.components.spawner:IsSpawnPending() then
			stopspawning(inst)
		end
		-- inst.AnimState:PlayAnimation("idle_flooded")
		-- inst.wet_prefix = STRINGS.WET_PREFIX.RABBITHOLE
		inst.always_wet = true
		if inst.springtask then
			inst.springtask:Cancel()
			inst.springtask = nil
		end
	end
end

  
local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

	anim:SetBank("lobster_home")
	anim:SetBuild("lobster_home")
	anim:PlayAnimation("idle", true)
	--anim:SetOrientation( ANIM_ORIENTATION.OnGround )
	anim:SetLayer(LAYER_BACKGROUND)
	anim:SetSortOrder(3)

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("lobster.png")

	inst.no_wet_prefix = true
	--inst:AddTag("NOCLICK")
	inst:AddTag("aquatic")
	
	inst:AddComponent( "spawner" )
	inst.components.spawner:Configure( "lobster", TUNING.RABBIT_RESPAWN_TIME)
	inst.components.spawner.childfn = GetChild
	
	inst.components.spawner:SetOnOccupiedFn(onoccupied)
	inst.components.spawner:SetOnVacateFn(stopspawning)
	
	--inst:AddComponent("lootdropper")
	--inst:AddComponent("workable")
	--inst.components.workable:SetWorkAction(ACTIONS.DIG)
	--inst.components.workable:SetOnFinishCallback(dig_up)
	--inst.components.workable:SetWorkLeft(1)
	
	inst:ListenForEvent( "dusktime", function() startspawning(inst) end, GetWorld())
	inst:ListenForEvent( "daytime", function() stopspawning(inst) end, GetWorld())

	inst.spring = GetSeasonManager():IsSpring()
	if inst.spring then
		inst:DoTaskInTime(.1, function(inst) SetSpringMode(inst, true) end)
	else
		inst:DoTaskInTime(.1, function(inst) SetNormalMode(inst, true) end)
	end
	inst:ListenForEvent( "rainstart", function(it, data)
		if GetSeasonManager() and GetSeasonManager():IsSpring() and not inst.spring then
			inst.springtask = inst:DoTaskInTime(math.random(3,20), SetSpringMode)
		end
	end, GetWorld())

	inst:ListenForEvent("seasonChange", function(it, data)
		if data.season ~= SEASONS.SPRING and inst.spring then
			inst.normaltask = inst:DoTaskInTime(math.random(TUNING.MIN_RABBIT_HOLE_TRANSITION_TIME, TUNING.MAX_RABBIT_HOLE_TRANSITION_TIME), SetNormalMode)
		end
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

return Prefab( "common/objects/lobsterhole", fn, assets, prefabs ) 
