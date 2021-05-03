require "prefabutil"

local function test_ground(inst, pt)
	local basetile = GROUND.DIRT
	if GetWorld():HasTag("shipwrecked") then
		basetile = GROUND.BEACH
	elseif GetWorld():HasTag("volcano") then
		basetile = GROUND.VOLCANO_ROCK
	end
	local tiletype = GetGroundTypeAtPosition(pt)
	return tiletype == basetile or inst.data.tile == "webbing"
end


local function setTileBlocking(block, pt)
	local ground = GetWorld()
	local px,py,pz = ground.Map:GetTileCenterPoint(pt.x, pt.y, pt.z)			
	for ix=0,1 do
		for iy =0,1 do
			local modx =-1
			local mody =-1
			if ix == 1 then
				modx = modx+2
			end
			if iy == 1 then
				mody = mody+2
			end		
			print("Altering tile",px+modx,pz+mody)			
			ground.Flooding:SetIsPositionBlocked(px+modx,0,pz+mody, block, false)
		end
	end
end

local function ondeploy(inst, pt, deployer)
	if deployer and deployer.SoundEmitter then
		deployer.SoundEmitter:PlaySound("dontstarve/wilson/dig")
	end

	local ground = GetWorld()
	if ground then
		local original_tile_type = ground.Map:GetTileAtPoint(pt.x, pt.y, pt.z)
		local x, y = ground.Map:GetTileCoordsAtPoint(pt.x, pt.y, pt.z)
		if x and y then
			ground.Map:SetTile(x,y, inst.data.tile)
			--[[
			if inst.data.tile == GROUND.LEAKPROOFCARPET then
				ground.Flooding:SetIsPositionBlocked(pt.x, 0, pt.z, true)
				ground.Flooding:SetIsPositionBlocked(pt.x, 0, pt.z + 2, true)
				ground.Flooding:SetIsPositionBlocked(pt.x, 0, pt.z - 2, true)

				ground.Flooding:SetIsPositionBlocked(pt.x + 2, 0, pt.z, true)
				ground.Flooding:SetIsPositionBlocked(pt.x + 2, 0, pt.z + 2, true)
				ground.Flooding:SetIsPositionBlocked(pt.x + 2, 0, pt.z - 2, true)

				ground.Flooding:SetIsPositionBlocked(pt.x - 2, 0, pt.z, true)
				ground.Flooding:SetIsPositionBlocked(pt.x - 2, 0, pt.z + 2, true)
				ground.Flooding:SetIsPositionBlocked(pt.x - 2, 0, pt.z - 2, true)
			end
			]]
			ground.Map:RebuildLayer( original_tile_type, x, y )
			ground.Map:RebuildLayer( inst.data.tile, x, y )
		end
		
		local minimap = TheSim:FindFirstEntityWithTag("minimap")
		if minimap then
			minimap.MiniMap:RebuildLayer( original_tile_type, x, y )
			minimap.MiniMap:RebuildLayer( inst.data.tile, x, y )
		end
		--setTileBlocking(true, pt)
	end

	inst.components.stackable:Get():Remove()
end


local function make_turf(data)
	local name = data.name
	
	local assets =
	{
		Asset("ANIM", "anim/turf.zip"),
		Asset("ANIM", "anim/turf_1.zip"),
		Asset("INV_IMAGE", "turf_deciduous"),
		Asset("INV_IMAGE", "turf_desertdirt"),
		Asset("INV_IMAGE", "turf_fungus_green"),
		Asset("INV_IMAGE", "turf_fungus_red"),
		Asset("INV_IMAGE", "turf_webbing"),
		Asset("INV_IMAGE", "turf_meadow"),

		Asset("INV_IMAGE", "turf_pigruins"),
		Asset("INV_IMAGE", "turf_rainforest"),
		Asset("INV_IMAGE", "turf_deeprainforest"),
		Asset("INV_IMAGE", "turf_lawn"),
		Asset("INV_IMAGE", "turf_gasjungle"),
		Asset("INV_IMAGE", "turf_moss"),
		Asset("INV_IMAGE", "turf_fields"),
		Asset("INV_IMAGE", "turf_foundation"),
		Asset("INV_IMAGE", "turf_cobbleroad"),	
		Asset("INV_IMAGE", "turf_beard_hair"),		
		Asset("INV_IMAGE", "turf_plains"),	
		Asset("INV_IMAGE", "turf_painted"),						

	}
	
	local prefabs =
	{
		"gridplacer",
	}
	
	local function fn(Sim)
		local inst = CreateEntity()
		inst:AddTag("groundtile")
		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		MakeInventoryPhysics(inst)
	    
		inst.AnimState:SetBank("turf")
		inst.AnimState:SetBuild("turf")
		inst.AnimState:AddOverrideBuild("turf_1")
		inst.AnimState:PlayAnimation(data.anim)

		MakeInventoryFloatable(inst, data.anim.."_water", data.anim)

		inst:AddComponent("stackable")
		inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM
		
		inst:AddComponent("inspectable")
		inst:AddComponent("inventoryitem")
		inst.data = data

		inst:AddComponent("bait")
    	inst:AddTag("molebait")
	    
		inst:AddComponent("fuel")
		inst.components.fuel.fuelvalue = TUNING.MED_FUEL
		
		inst:AddComponent("appeasement")
    	inst.components.appeasement.appeasementvalue = TUNING.WRATH_SMALL

        MakeMediumBurnable(inst, TUNING.MED_BURNTIME)
		MakeSmallPropagator(inst)
		inst.components.burnable:MakeDragonflyBait(3)
		
	    inst:AddComponent("deployable")
	    --inst.components.deployable.test = function() return true end
	    inst.components.deployable.ondeploy = ondeploy
	    inst.components.deployable.test = test_ground
	    inst.components.deployable.min_spacing = 0
	    inst.components.deployable.placer = "gridplacer"
	    
		---------------------  
		return inst      
	end

	return Prefab( "common/objects/turf_"..name, fn, assets, prefabs)
end

local turfs = 
{
	{name="road",			anim="road",		tile=GROUND.ROAD},
	{name="rocky",			anim="rocky",		tile=GROUND.ROCKY},
	{name="forest",			anim="forest",		tile=GROUND.FOREST},
	{name="marsh",			anim="marsh",		tile=GROUND.MARSH},
	{name="grass",			anim="grass",		tile=GROUND.GRASS},
	{name="savanna",		anim="savanna",		tile=GROUND.SAVANNA},
	{name="dirt",			anim="dirt",		tile=GROUND.DIRT},
	{name="woodfloor",		anim="woodfloor",	tile=GROUND.WOODFLOOR},
	{name="carpetfloor",	anim="carpet",		tile=GROUND.CARPET},
	{name="checkerfloor",	anim="checker",		tile=GROUND.CHECKER},

	{name="cave",			anim="cave",		tile=GROUND.CAVE},
	{name="fungus",			anim="fungus",		tile=GROUND.FUNGUS},
    {name="fungus_red",		anim="fungus_red",	tile=GROUND.FUNGUSRED},
	{name="fungus_green",	anim="fungus_green",tile=GROUND.FUNGUSGREEN},

	{name="sinkhole",		anim="sinkhole",	tile=GROUND.SINKHOLE},
	{name="underrock",		anim="rock",		tile=GROUND.UNDERROCK},
	{name="mud",			anim="mud",			tile=GROUND.MUD},
	{name="deciduous",		anim="deciduous",	tile=GROUND.DECIDUOUS},
	{name="desertdirt",		anim="dirt",		tile=GROUND.DESERT_DIRT},

	{name="beach",			anim="beach",		tile=GROUND.BEACH},
	{name="jungle",			anim="jungle",		tile=GROUND.JUNGLE},
	{name="swamp",			anim="marsh",		tile=GROUND.SWAMP},
	{name="volcano",		anim="lavarock",	tile=GROUND.VOLCANO},
	{name="ash",			anim="ash", 		tile=GROUND.ASH},
	{name="magmafield",		anim="magmafield",	tile=GROUND.MAGMAFIELD},
	{name="tidalmarsh",		anim="tidalmarsh",	tile=GROUND.TIDALMARSH},
	{name="meadow",			anim="meadow",		tile=GROUND.MEADOW},

--	{name="leakproofcarpetfloor",	anim="leakproofcarpet",		tile=GROUND.LEAKPROOFCARPET},
	{name="snakeskinfloor",	anim="snakeskin",		tile=GROUND.SNAKESKIN},

	{name="pigruins",		anim="pig_ruins",		tile=GROUND.PIGRUINS},
	{name="rainforest",		anim="rainforest",		tile=GROUND.RAINFOREST},
	{name="deeprainforest",	anim="deepjungle",		tile=GROUND.DEEPRAINFOREST},
	{name="lawn",			anim="checkeredlawn",	tile=GROUND.LAWN},
	{name="gasjungle",		anim="gasjungle",		tile=GROUND.GASJUNGLE},
	{name="moss",			anim="mossy_blossom",	tile=GROUND.SUBURB},
	{name="fields",			anim="farmland",		tile=GROUND.FIELDS},
	{name="foundation",		anim="fanstone",		tile=GROUND.FOUNDATION},
	{name="cobbleroad",		anim="cobbleroad",		tile=GROUND.COBBLEROAD},
	
	{name="painted",		anim="bog",				tile=GROUND.PAINTED},
	{name="plains",			anim="plains",			tile=GROUND.PLAINS},

	{name="beard_hair",		anim="beard_hair",		tile=GROUND.BEARDRUG},
	{name="deeprainforest_nocanopy", anim="deepjungle",		tile=GROUND.DEEPRAINFOREST_NOCANOPY},	

}

local prefabs= {}
for k,v in pairs(turfs) do
	table.insert(prefabs, make_turf(v))
end

return unpack(prefabs) 
