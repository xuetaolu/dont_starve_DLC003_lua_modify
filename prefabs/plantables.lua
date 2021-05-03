require "prefabutil"

local notags = {'NOBLOCK', 'player', 'FX'}
local function test_ground(inst, pt)
	local tiletype = GetGroundTypeAtPosition(pt)
	local ground_OK = tiletype ~= GROUND.ROCKY and tiletype ~= GROUND.ROAD and tiletype ~= GROUND.IMPASSABLE and tiletype ~= GROUND.INTERIOR and
						tiletype ~= GROUND.UNDERROCK and tiletype ~= GROUND.WOODFLOOR and tiletype ~= GROUND.MAGMAFIELD and 
						tiletype ~= GROUND.CARPET and tiletype ~= GROUND.CHECKER and 
						tiletype ~= GROUND.ASH and tiletype ~= GROUND.VOLCANO and tiletype ~= GROUND.VOLCANO_ROCK and tiletype ~= GROUND.BRICK_GLOW and
						tiletype < GROUND.UNDERGROUND
    
    
    local ground = GetWorld()
    if ground.Map:IsWater(tiletype) then 
    	ground_OK = false 
    end 
	
	if ground_OK then
	    local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 4, nil, notags) -- or we could include a flag to the search?
		local min_spacing = inst.components.deployable.min_spacing or 2

	    for k, v in pairs(ents) do
			if v ~= inst and v:IsValid() and v.entity:IsVisible() and not v.components.placer and v.parent == nil then
				if distsq( Vector3(v.Transform:GetWorldPosition()), pt) < min_spacing*min_spacing then
					return false
				end
			end
		end
		
		return true

	end
	return false
	
end

local function test_nobeach(inst, pt)
	local tiletype = GetGroundTypeAtPosition(pt)
	local ground_OK = tiletype ~= GROUND.BEACH

	return ground_OK and test_ground(inst, pt)
end

local function test_volcano(inst, pt)
	local tiletype = GetGroundTypeAtPosition(pt)

	if tiletype == GROUND.MAGMAFIELD or tiletype == GROUND.ASH or tiletype == GROUND.VOLCANO then
		local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 4, nil, notags) -- or we could include a flag to the search?
		local min_spacing = inst.components.deployable.min_spacing or 2

		for k, v in pairs(ents) do
			if v ~= inst and v:IsValid() and v.entity:IsVisible() and not v.components.placer and v.parent == nil then
				if distsq( Vector3(v.Transform:GetWorldPosition()), pt) < min_spacing*min_spacing then
					return false
				end
			end
		end
		
		return true
	end

	return false
end

local grassassets=
{
	Asset("ANIM", "anim/grass1.zip"),
	Asset("ANIM", "anim/grassgreen_build.zip"),
}

local function makegrass_plantable(inst)
	inst.AnimState:SetBank("grass")
	
	if SaveGameIndex:IsModeShipwrecked() then
		inst.AnimState:SetBuild("grassgreen_build")
	else
		inst.AnimState:SetBuild("grass1")
	end
end


local function make_plantable(data)

	local name = data.name
	local assetname = data.build or name
	local assets = nil

	if data.assets ~= nil then
		assets = data.assets
	else
		assets =
		{
			Asset("ANIM", "anim/"..assetname..".zip"),
		}
	end


	local function ondeploy(inst, pt, deployer)
		local tree = SpawnPrefab(data.name) 
		if tree then 
			tree.Transform:SetPosition(pt.x, pt.y, pt.z) 
			inst.components.stackable:Get():Remove()

			if deployer ~= nil and deployer.SoundEmitter ~= nil then
				deployer.SoundEmitter:PlaySound("dontstarve/common/plant")
			end
			
			if tree.components.pickable then 
				tree.components.pickable:OnTransplant()
			elseif tree.components.hackable then 
				tree.components.hackable:OnTransplant()
			end 
		end 
	end
	
	local function fn(Sim)
		local inst = CreateEntity()
		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddSoundEmitter()
		MakeInventoryPhysics(inst)
	
		if data.artfn ~= nil then
			data.artfn(inst)
		else    
			inst.AnimState:SetBank(data.bank or name)
			inst.AnimState:SetBuild(data.build or name)
		end
		inst.AnimState:PlayAnimation("dropped")		

		inst:AddTag("plant")

		inst:AddComponent("stackable")
		inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM
		
		inst:AddComponent("inspectable")
		inst.components.inspectable.nameoverride = data.inspectoverride or "dug_"..data.name
		inst:AddComponent("inventoryitem")
	    
		inst:AddComponent("fuel")
		inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL

		inst:AddComponent("appeasement")
    	inst.components.appeasement.appeasementvalue = TUNING.WRATH_SMALL

    	if not data.noburn then
	        MakeMediumBurnable(inst, TUNING.LARGE_BURNTIME)
			MakeSmallPropagator(inst)
			inst.components.burnable:MakeDragonflyBait(3)
		else
			inst:AddTag("fire_proof")
		end
		
	    inst:AddComponent("deployable")
	    --inst.components.deployable.test = function() return true end

	    inst.components.deployable.ondeploy = ondeploy
	    inst.components.deployable.test = data.testfn or test_ground
	    inst.components.deployable.min_spacing = data.minspace or 2
	    if data.deployatrange then
	    	inst.components.deployable.deployatrange = true
	    end
	    -- used for the navigadget
	    inst.components.deployable.product = data.name
	    
	    inst:AddComponent("edible")
	    inst.components.edible.foodtype = "WOOD"
	    inst.components.edible.woodiness = 10
	    
		MakeInventoryFloatable(inst, "dropped_water", "dropped")
		---------------------  

		return inst      
	end

	return Prefab( "common/objects/dug_"..data.name, fn, assets)
end

local plantables =
{
	{name="berrybush", anim="idle_dead", minspace=2, testfn=test_nobeach},
	{name="berrybush2", bank = "berrybush", inspectoverride = "dug_berrybush", anim = "idle_dead", minspace=2, testfn=test_nobeach},
	{name="sapling", minspace=1},
	{name="grass", build="grassgreen_build", minspace=1, artfn=makegrass_plantable, assets=grassassets },
    {name="marsh_bush", minspace=1, testfn=test_nobeach},
    {name="bambootree", minspace = 2, bank = "bambootree", build = "bambootree_build", testfn=test_nobeach },
    {name="bush_vine", minspace = 2, bank = "bush_vine", build = "bush_vine", testfn=test_nobeach },
	{name="coffeebush", bank = "coffeebush", build = "coffeebush", anim="idle_dead", minspace=2, testfn=test_volcano, noburn=true},
	{name="elephantcactus", bank = "cactus_volcano", build = "cactus_volcano", anim="idle_dead", minspace=2, testfn=test_volcano, noburn=true, deployatrange=true},
	{name="nettle", minspace=2},
	--"reeds",
}

local prefabs= {}
for k,v in pairs(plantables) do
	table.insert(prefabs, make_plantable(v))
	table.insert(prefabs, MakePlacer( "common/dug_"..v.name.."_placer", v.bank or v.name, v.build or v.name, v.anim or "idle" ))
end

return unpack(prefabs) 
