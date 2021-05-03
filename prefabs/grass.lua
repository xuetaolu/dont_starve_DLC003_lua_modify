local grassassets=
{
	Asset("ANIM", "anim/grass.zip"),
	Asset("ANIM", "anim/grass1.zip"),
	Asset("ANIM", "anim/grassgreen_build.zip"),
	Asset("SOUND", "sound/common.fsb"),	
    Asset("INV_IMAGE", "dug_grass_green"),	
	Asset("MINIMAP_IMAGE", "grassGreen"),
}

local waterassets=
{
	Asset("ANIM", "anim/grass_inwater.zip"),
	Asset("ANIM", "anim/grassgreen_build.zip"),	
	Asset("SOUND", "sound/common.fsb"),
}

local grassprefabs =
{
    "cutgrass",
    "dug_grass",
    "grass_tall",
}

local waterprefabs =
{
    "cutgrass"
}

local function ontransplantfn(inst)
	if inst.components.pickable then
		inst.components.pickable:MakeBarren()
	end

	-- checks to turn into Tall Grass if on the right terrain
	local pt = Vector3(inst.Transform:GetWorldPosition())
	local tiletype = GetGroundTypeAtPosition(pt)
	if tiletype == GROUND.PLAINS or tiletype == GROUND.RAINFOREST or tiletype == GROUND.DEEPRAINFOREST or tiletype == GROUND.DEEPRAINFOREST_NOCANOPY  then	
		local newgrass = SpawnPrefab("grass_tall")
		newgrass.Transform:SetPosition(pt:Get())
		-- need to make it new grass here.. 
		newgrass.components.hackable:MakeEmpty()
		inst:Remove()
	end
end

local function onregenfn(inst)
	inst.AnimState:PlayAnimation("grow") 
	inst.AnimState:PushAnimation("idle", true)
	if inst.inwater then 
		inst.Physics:SetCollides(true)
		inst.AnimState:SetLayer( LAYER_WORLD)
		inst.AnimState:SetSortOrder(0)
	end 
end

local function makeemptyfn(inst)
	if inst.components.pickable and inst.components.pickable.withered then
		inst.AnimState:PlayAnimation("dead_to_empty")
		inst.AnimState:PushAnimation("picked")
	else
		inst.AnimState:PlayAnimation("picked")
	end
	if inst.inwater then 
		inst.Physics:SetCollides(false)

		inst.AnimState:SetLayer( LAYER_BACKGROUND )
    	inst.AnimState:SetSortOrder( 3 )
	end 
end

local function makebarrenfn(inst)
	if inst.components.pickable and inst.components.pickable.withered then

		if inst.inwater then 
			inst.Physics:SetCollides(true)
			inst.AnimState:SetLayer( LAYER_WORLD)
			inst.AnimState:SetSortOrder(0)
		end 

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


local function onpickedfn(inst)
	--inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds") 
	inst.AnimState:PlayAnimation("picking") 
	
	if inst.components.pickable and inst.components.pickable:IsBarren() then
		inst.AnimState:PushAnimation("idle_dead")
	else
		inst.AnimState:PushAnimation("picked")
		if inst.inwater then 
			inst.Physics:SetCollides(false)

			inst.AnimState:SetLayer( LAYER_BACKGROUND )
	    	inst.AnimState:SetSortOrder( 3 )
		end 
	end
end

local function canshear(inst)
	return inst.components.pickable and inst.components.pickable:CanBePicked()
end

local function onshear(inst)
	if inst.components.pickable then
		inst.components.pickable:SimulatePick()
	end
end

local function makebrown(inst)
	inst.MiniMapEntity:SetIcon("grass.png")
	inst.AnimState:SetBank("grass")
	inst.AnimState:SetBuild("grass1")
end

local function makegreen(inst)
	inst.MiniMapEntity:SetIcon("grassGreen.png")
	inst.AnimState:SetBank("grass")
	inst.AnimState:SetBuild("grassgreen_build")
end

local function makegrass(inst)
	if SaveGameIndex:IsModeShipwrecked() or SaveGameIndex:IsModePorkland() then
		makegreen(inst)
	else
		makebrown(inst)
	end
end

local function makewater(inst)
	inst.MiniMapEntity:SetIcon("grassGreen.png")
	inst.AnimState:SetBank("grass_inwater")
	inst.AnimState:SetBuild("grass_inwater")
	MakeObstaclePhysics(inst, .25)
	inst.inwater = true 
end

local function makefn(stage, artfn, product, dig_product, burnable, pick_sound)
	local function dig_up(inst, chopper)
		if inst.components.pickable and inst.components.pickable:CanBePicked() then
			inst.components.lootdropper:SpawnLootPrefab(product)
		end
		if inst.components.pickable and not inst.components.pickable.withered then
			local bush = inst.components.lootdropper:SpawnLootPrefab(dig_product)
		else
			inst.components.lootdropper:SpawnLootPrefab(product)
		end
		inst:Remove()
	end

	local function fn(Sim)
		local inst = CreateEntity()
		local trans = inst.entity:AddTransform()
		local anim = inst.entity:AddAnimState()
	    local sound = inst.entity:AddSoundEmitter()
		local minimap = inst.entity:AddMiniMapEntity()

		artfn(inst)
		--minimap:SetIcon( icon )
	    
	    --anim:SetBank(bank)
	    --anim:SetBuild(build)
	    anim:PlayAnimation("idle",true)
	    anim:SetTime(math.random()*2)
	    local color = 0.75 + math.random() * 0.25
	    anim:SetMultColour(color, color, color, 1)

	    inst:AddTag("gustable")
	    inst:AddTag("plant")

		inst:AddComponent("pickable")
		inst.components.pickable.picksound = pick_sound
		
		inst.components.pickable:SetUp(product, TUNING.GRASS_REGROW_TIME)
		inst.components.pickable.onregenfn = onregenfn
		inst.components.pickable.onpickedfn = onpickedfn
		inst.components.pickable.makeemptyfn = makeemptyfn
		inst.components.pickable.makebarrenfn = makebarrenfn
		inst.components.pickable.max_cycles = 20
		inst.components.pickable.cycles_left = 20
		inst.components.pickable.ontransplantfn = ontransplantfn

		inst:AddComponent("shearable")
		inst.components.shearable:SetProduct("cutgrass", 1, true)
		inst.canshear = canshear
    	inst.onshear = onshear

		if dig_product then
			local variance = math.random() * 4 - 2
			inst.makewitherabletask = inst:DoTaskInTime(TUNING.WITHER_BUFFER_TIME + variance, function(inst) inst.components.pickable:MakeWitherable() end)
		end

	    if stage == 1 then
			inst.components.pickable:MakeBarren()
		end

		inst:AddComponent("lootdropper")
	    inst:AddComponent("inspectable")    
	
		if dig_product ~= nil then
			inst:AddComponent("workable")
		    inst.components.workable:SetWorkAction(ACTIONS.DIG)
		    inst.components.workable:SetOnFinishCallback(dig_up)
		    inst.components.workable:SetWorkLeft(1)
		end

	    MakePickableBlowInWindGust(inst, TUNING.GRASS_WINDBLOWN_SPEED, TUNING.GRASS_WINDBLOWN_FALL_CHANCE)
	    
	    ---------------------

	    if burnable then
		    MakeMediumBurnable(inst)
		    MakeSmallPropagator(inst)
		    inst.components.burnable:MakeDragonflyBait(1)
		end

		MakeNoGrowInWinter(inst)
		  
	    ---------------------	 

	    return inst
	end

    return fn
end

return Prefab("forest/objects/grass", makefn(0, makegrass, "cutgrass", "dug_grass", true, "dontstarve/wilson/pickup_reeds"), grassassets, grassprefabs),
	   Prefab("forest/objects/depleted_grass", makefn(1, makegrass, "cutgrass", "dug_grass", true, "dontstarve/wilson/pickup_reeds"), grassassets, grassprefabs),
	   Prefab("forest/objects/grass_water", makefn(0, makewater, "cutgrass", nil, false, "dontstarve_DLC002/common/item_wet_harvest"), waterassets, waterprefabs),
	   Prefab("forest/objects/depleted_grass_water", makefn(1, makewater, "cutgrass", nil, false, "dontstarve_DLC002/common/item_wet_harvest"), waterassets, waterprefabs)
