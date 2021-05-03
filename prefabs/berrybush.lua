

local assets =
{
	berrybush = {Asset("ANIM", "anim/berrybush.zip"), Asset("MINIMAP_IMAGE", "berrybush")},
	berrybush2 = {Asset("ANIM", "anim/berrybush2.zip"), Asset("MINIMAP_IMAGE", "berrybush2")},
	coffeebush = {Asset("ANIM", "anim/coffeebush.zip")},
}

local prefabs =
{
	berrybush = {
		"berries",
		"dug_berrybush",
		--"peacock",
		"twigs",
		"perd", 
	},
	berrybush_snake = {
		"berries",
		"dug_berrybush",
		--"peacock",
		"twigs",
		"snake",
		"perd", 
	},
	berrybush2 = {
		"berries",
		"dug_berrybush2",
		--"peacock",
		"twigs",
		"perd", 
	},
	berrybush2_snake = {
		"berries",
		"dug_berrybush2",
		--"peacock",
		"twigs",
		"snake",
		"perd", 
	},
	coffeebush = {
		"coffeebeans",
		"dug_coffeebush",
		--"peacock",
		"twigs",
	},
}

local function ontransplantfn(inst)
	inst.components.pickable:MakeBarren()
end

local function makeemptyfn(inst)
	if inst.components.pickable and inst.components.pickable.withered then
		inst.AnimState:PlayAnimation("dead_to_empty")
		inst.AnimState:PushAnimation("empty")
	else
		inst.AnimState:PlayAnimation("empty")
	end
end

local function makebarrenfn(inst)
	if inst.components.pickable and inst.components.pickable.withered then
		if not inst.components.pickable.hasbeenpicked then
			inst.AnimState:PlayAnimation("full_to_dead")
		else
			inst.AnimState:PlayAnimation("empty_to_dead")
		end
		inst.AnimState:PushAnimation("idle_dead")
	else
		inst.AnimState:PlayAnimation("idle_dead")
	end
end

local function pickanim(inst)
	if inst.components.pickable then
		if inst.components.pickable:CanBePicked() then
			local percent = 0
			if inst.components.pickable then
				percent = inst.components.pickable.cycles_left / inst.components.pickable.max_cycles
			end
			if percent >= .9 then
				return "berriesmost"
			elseif percent >= .33 then
				return "berriesmore"
			else
				return "berries"
			end
		else
			if inst.components.pickable:IsBarren() then
				return "idle_dead"
			else
				return "idle"
			end
		end
	end

	return "idle"
end


local function shake(inst)
	if inst.components.pickable and inst.components.pickable:CanBePicked() then
		inst.AnimState:PlayAnimation("shake")
	else
		inst.AnimState:PlayAnimation("shake_empty")
	end
	inst.AnimState:PushAnimation(pickanim(inst), false)
end

local function spawnperd(inst)
	if inst:IsValid() then
		local perd
		if SaveGameIndex:IsModeShipwrecked() then 
			--perd = SpawnPrefab("peacock")
		else 
			perd = SpawnPrefab("perd")
		end 
		if perd then 
			local spawnpos = Vector3(inst.Transform:GetWorldPosition() )
			spawnpos = spawnpos + TheCamera:GetDownVec()
			perd.Transform:SetPosition(spawnpos:Get() )
			perd.sg:GoToState("appear")
			perd.components.homeseeker:SetHome(inst)
			shake(inst)
		end 
	end
end

local function pickberries(inst)
	if inst.components.pickable then
		local old_percent = (inst.components.pickable.cycles_left+1) / inst.components.pickable.max_cycles

		if old_percent >= .9 then
			inst.AnimState:PlayAnimation("berriesmost_picked")
		elseif old_percent >= .33 then
			inst.AnimState:PlayAnimation("berriesmore_picked")
		else
			inst.AnimState:PlayAnimation("berries_picked")
		end

		if inst.components.pickable:IsBarren() then
			inst.AnimState:PushAnimation("idle_dead")
		else
			inst.AnimState:PushAnimation("idle")
		end
	end	
end

local function onpickedfn(inst, picker)
	pickberries(inst)
	 
	 if inst.spawnsperd and picker and not picker:HasTag("berrythief") and math.random() < TUNING.PERD_SPAWNCHANCE then
	 	inst:DoTaskInTime(3+math.random()*3, spawnperd)
	 end
end

local function ongustpickfn(inst)
	if inst.components.pickable and inst.components.pickable:CanBePicked() then
		inst.components.pickable:MakeEmpty()
		inst.components.lootdropper:SpawnLootPrefab(inst.components.pickable.product)
	end
end

local function getregentimefn(inst)
	if inst.components.pickable then
		local num_cycles_passed = math.min(inst.components.pickable.max_cycles - inst.components.pickable.cycles_left, 0)
		return TUNING.BERRY_REGROW_TIME + TUNING.BERRY_REGROW_INCREASE*num_cycles_passed+ math.random()*TUNING.BERRY_REGROW_VARIANCE
	else
		return TUNING.BERRY_REGROW_TIME
	end
	
end

local function makefullfn(inst)
	inst.AnimState:PlayAnimation(pickanim(inst))
end

local function check_spawn_snake(inst)
	if inst:IsValid() then
		local distsq = inst:GetDistanceSqToInst(GetPlayer())

		if distsq < 4 then
			if math.random() > 0.75 then
				local perd = SpawnPrefab("snake")
				local spawnpos = Vector3(inst.Transform:GetWorldPosition() )
				spawnpos = spawnpos + TheCamera:GetDownVec()
				perd.Transform:SetPosition(spawnpos:Get() )
				shake(inst)
			end
		end

		inst:DoTaskInTime(5+(math.random()*2), check_spawn_snake)
	end
end

local function digupberrybush(inst, chopper)	
	if inst.components.pickable and inst.components.lootdropper then
	
		if inst.components.pickable:IsBarren() or inst.components.pickable.withered then
			inst.components.lootdropper:SpawnLootPrefab("twigs")
			inst.components.lootdropper:SpawnLootPrefab("twigs")
		else
			
			if inst.components.pickable and inst.components.pickable:CanBePicked() then
				inst.components.lootdropper:SpawnLootPrefab("berries")
			end
		
			inst.components.lootdropper:SpawnLootPrefab(inst.dugprefab)
		end
	end	
	inst:Remove()
end

local function digupcoffeebush(inst, chopper)	
	if inst.components.pickable and inst.components.lootdropper then
	
		if inst.components.pickable:IsBarren() or inst.components.pickable.withered then
			inst.components.lootdropper:SpawnLootPrefab("twigs")
			inst.components.lootdropper:SpawnLootPrefab("twigs")
		else
			
			if inst.components.pickable and inst.components.pickable:CanBePicked() then
				inst.components.lootdropper:SpawnLootPrefab("coffeebeans")
			end
		
			inst.components.lootdropper:SpawnLootPrefab("dug_"..inst.prefab)
		end
	end	
	inst:Remove()
end

local function onload(inst, data)
	-- just from world gen really
	if data and data.makebarren then
		makebarrenfn(inst)
		inst.components.pickable:MakeBarren()
	end
end

local function commonfn(Sim)
	local inst = CreateEntity()

	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local minimap = inst.entity:AddMiniMapEntity()

	inst.OnLoad = onload

	inst:AddTag("bush")
	inst:AddTag("plant")
	
	MakeObstaclePhysics(inst, .1)

	inst:AddComponent("pickable")
	inst.components.pickable.picksound = "dontstarve/wilson/harvest_berries"

	inst.components.pickable.getregentimefn = getregentimefn
	inst.components.pickable.onpickedfn = onpickedfn
	inst.components.pickable.makeemptyfn = makeemptyfn
	inst.components.pickable.makebarrenfn = makebarrenfn
	inst.components.pickable.makefullfn = makefullfn
	inst.components.pickable.ontransplantfn = ontransplantfn
	inst.components.pickable.max_cycles = TUNING.BERRYBUSH_CYCLES + math.random(2)
	inst.components.pickable.cycles_left = inst.components.pickable.max_cycles
	inst.spawnsperd = true
	local variance = math.random() * 4 - 2
	inst.makewitherabletask = inst:DoTaskInTime(TUNING.WITHER_BUFFER_TIME + variance, function(inst) inst.components.pickable:MakeWitherable() end)


	inst:AddComponent("lootdropper")
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.DIG)
	inst.components.workable:SetOnFinishCallback(digupberrybush)
	inst.components.workable:SetWorkLeft(1)

	inst:AddComponent("inspectable")
	inst.components.inspectable.nameoverride = "berrybush"

	inst:AddComponent("blowinwindgust")
	inst.components.blowinwindgust:SetWindSpeedThreshold(TUNING.BERRYBUSH_WINDBLOWN_SPEED)
	inst.components.blowinwindgust:SetDestroyChance(TUNING.BERRYBUSH_WINDBLOWN_FALL_CHANCE)
	inst.components.blowinwindgust:SetDestroyFn(ongustpickfn)
	inst.components.blowinwindgust:Start()

	inst:ListenForEvent("onwenthome", shake)
	MakeSnowCovered(inst, .01)
	MakeNoGrowInWinter(inst)

	return inst
end

local function berrybushfn(Sim)
	local inst = commonfn(Sim)

	inst.AnimState:SetBank("berrybush")
	inst.AnimState:SetBuild("berrybush")
	inst.AnimState:PlayAnimation("berriesmost", false)

	inst.MiniMapEntity:SetIcon("berrybush.png")

	inst.components.pickable:SetUp("berries", TUNING.BERRY_REGROW_TIME)
	inst.dugprefab = "dug_berrybush"

	MakeLargeBurnable(inst)
	MakeLargePropagator(inst)
	inst.components.burnable:MakeDragonflyBait(1)
	
	return inst
end

local function berrybush_snakefn(Sim)
	local inst = commonfn(Sim)

	inst.AnimState:SetBank("berrybush")
	inst.AnimState:SetBuild("berrybush")
	inst.AnimState:PlayAnimation("berriesmost", false)

	inst.MiniMapEntity:SetIcon("berrybush.png")
	
	inst.components.pickable:SetUp("berries", TUNING.BERRY_REGROW_TIME)
	
	inst:DoTaskInTime(5+(math.random()*2), check_spawn_snake)
	inst.dugprefab = "dug_berrybush"

	MakeLargeBurnable(inst)
	MakeLargePropagator(inst)
	inst.components.burnable:MakeDragonflyBait(1)

	return inst
end

local function berrybush2fn(Sim)
	local inst = commonfn(Sim)

	inst.AnimState:SetBank("berrybush2")
	inst.AnimState:SetBuild("berrybush2")
	inst.AnimState:PlayAnimation("berriesmost", false)

	inst.MiniMapEntity:SetIcon("berrybush2.png")

	inst.components.pickable:SetUp("berries", TUNING.BERRY_REGROW_TIME)
	inst.dugprefab = "dug_berrybush2"

	MakeLargeBurnable(inst)
	MakeLargePropagator(inst)
	inst.components.burnable:MakeDragonflyBait(1)

	return inst
end

local function berrybush2_snakefn(Sim)
	local inst = commonfn(Sim)

	inst.AnimState:SetBank("berrybush2")
	inst.AnimState:SetBuild("berrybush2")
	inst.AnimState:PlayAnimation("berriesmost", false)

	inst.MiniMapEntity:SetIcon("berrybush2.png")

	inst.components.pickable:SetUp("berries", TUNING.BERRY_REGROW_TIME)
	
	inst:DoTaskInTime(5+(math.random()*2), check_spawn_snake)
	inst.dugprefab = "dug_berrybush2"

	MakeLargeBurnable(inst)
	MakeLargePropagator(inst)
	inst.components.burnable:MakeDragonflyBait(1)
	
	return inst
end

local function coffeebushfn(Sim)
	local inst = commonfn(Sim)
	inst.MiniMapEntity:SetIcon("coffeebush.png")
	inst.AnimState:SetBank("coffeebush")
	inst.AnimState:SetBuild("coffeebush")
	inst.AnimState:PlayAnimation("berriesmost", false)

	inst.components.workable:SetOnFinishCallback(digupcoffeebush)
	inst.components.inspectable.nameoverride = "coffeebush"

	inst.components.pickable:SetUp("coffeebeans", TUNING.BERRY_REGROW_TIME)
	inst.components.pickable:SetReverseSeasons(true)
	inst.spawnsperd = false 
	inst:AddTag("fire_proof")

	return inst
end

return Prefab( "common/objects/berrybush", berrybushfn, assets.berrybush, prefabs.berrybush),
	   Prefab( "common/objects/berrybush_snake", berrybush_snakefn, assets.berrybush, prefabs.berrybush_snake),
	   Prefab( "common/objects/berrybush2", berrybush2fn, assets.berrybush2, prefabs.berrybush2),
	   Prefab( "common/objects/berrybush2_snake", berrybush2_snakefn, assets.berrybush2, prefabs.berrybush2_snake),
	   Prefab( "common/objects/coffeebush", coffeebushfn, assets.coffeebush, prefabs.coffeebush)
