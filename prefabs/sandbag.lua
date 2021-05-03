

local assets =
{
	Asset("ANIM", "anim/sandbag.zip"),
}

local prefabs =
{
	"gridplacer",
}

local function ondeploy(inst, pt, deployer)
	--[[if deployer and deployer.SoundEmitter then
		deployer.SoundEmitter:PlaySound("dontstarve/wilson/dig")
	end

	local ground = GetWorld()
	if ground then
		local original_tile_type = ground.Map:GetTileAtPoint(pt.x, pt.y, pt.z)
		local x, y = ground.Map:GetTileCoordsAtPoint(pt.x, pt.y, pt.z)
		if x and y then
			ground.Map:SetTile(x,y, inst.data.tile)
			ground.Map:RebuildLayer( original_tile_type, x, y )
			ground.Map:RebuildLayer( inst.data.tile, x, y )
		end

		local minimap = TheSim:FindFirstEntityWithTag("minimap")
		if minimap then
			minimap.MiniMap:RebuildLayer( original_tile_type, x, y )
			minimap.MiniMap:RebuildLayer( inst.data.tile, x, y )
		end
	end]]--
	local wall = SpawnPrefab("sandbag") 
	if wall then
		local map = GetWorld().Map
		local cx, cy, cz = map:GetTileCenterPoint(pt.x, pt.y, pt.z)
		pt = Vector3(cx, cy, cz)
		wall.Physics:SetCollides(false)
		wall.Physics:Teleport(pt.x, pt.y, pt.z) 
		wall.Physics:SetCollides(true)
		inst.components.stackable:Get():Remove()
	end
end

local function onhammered(inst, worker)
	inst.components.lootdropper:SpawnLootPrefab("sand")
	
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	
	--inst.SoundEmitter:PlaySound(data.destroysound)
	
	inst:Remove()
end

local function onhit(inst)
end

local function test_sandbag(inst, pt)
	local map = GetWorld().Map
	local tiletype = GetGroundTypeAtPosition(pt)
	local ground_OK = tiletype ~= GROUND.IMPASSABLE and not map:IsWater(tiletype)
	

	
	if ground_OK then
		local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 2, nil, {"NOBLOCK", "player", "FX", "INLIMBO", "DECOR"}) -- or we could include a flag to the search?

		for k, v in pairs(ents) do
			if v ~= inst and v:IsValid() and v.entity:IsVisible() and not v.components.placer and v.parent == nil then
				local dsq = distsq( Vector3(v.Transform:GetWorldPosition()), pt)
				if  dsq< 2.83 * 2.83 then return false end
			end
		end
		return true

	end
	return false
end


local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddFloodingBlockerEntity()

	inst:AddTag("wall")

	MakeObstaclePhysics(inst, 1.5)
	inst.entity:SetCanSleep(false)
	anim:SetBank("sandbag")
	anim:SetBuild("sandbag")
    anim:PlayAnimation("full")
	
	inst:AddComponent("inspectable")
	inst:AddComponent("lootdropper")

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(3)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)
    
	---------------------  
	return inst      
end

local function itemfn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

	MakeInventoryPhysics(inst)

	anim:SetBank("sandbag")
	anim:SetBuild("sandbag")
	anim:PlayAnimation("idle")

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM
	
	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy
    inst.components.deployable.min_spacing = 2.83
    inst.components.deployable.placer = "gridplacer"	
    inst.components.deployable.test = test_sandbag
    
	---------------------  
	return inst      
end

return Prefab( "shipwrecked/objects/sandbag", fn, assets, prefabs ),
		Prefab( "shipwrecked/objects/sandbag_item", itemfn, assets, prefabs )
