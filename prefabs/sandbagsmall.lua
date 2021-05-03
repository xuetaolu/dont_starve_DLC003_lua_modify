

local assets =
{
	Asset("ANIM", "anim/sandbag_small.zip"),
}

local prefabs =
{
	"gridplacer",
}

local anims =
{
    { threshold = 0, anim = "rubble" },
    { threshold = 0.4, anim = "heavy_damage" },
    { threshold = 0.5, anim = "half" },
    { threshold = 0.99, anim = "light_damage" },
    { threshold = 1, anim = { "full", "full", "full" } },
}


local function resolveanimtoplay(inst, percent)
	for i, v in ipairs(anims) do
		if percent <= v.threshold then
			if type(v.anim) == "table" then
				-- get a stable animation, by basing it on world position
				local x, y, z = inst.Transform:GetWorldPosition()
				local x = math.floor(x)
				local z = math.floor(z)
				local q1 = #v.anim + 1
				local q2 = #v.anim + 4
				local t = ( ((x%q1)*(x+3)%q2) + ((z%q1)*(z+3)%q2) )% #v.anim + 1
				return v.anim[t]
			else
				return v.anim
			end
		end
	end
end

local function quantizepos(pt)
	local x, y, z = pt:Get()
	y = 0
	
	if GetWorld().Flooding then
		local px,py,pz = GetWorld().Flooding:GetTileCenterPoint(x,y,z)
		return Vector3(px,py,pz)
	else
		return Vector3(x,y,z)
	end
end


local function makeobstacle(inst)
	inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)	
    inst.Physics:ClearCollisionMask()
	--inst.Physics:CollidesWith(GetWorldCollision())
	inst.Physics:SetMass(0)
	inst.Physics:CollidesWith(COLLISION.ITEMS)
	inst.Physics:CollidesWith(COLLISION.CHARACTERS)
	inst.Physics:CollidesWith(COLLISION.WAVES)
	inst.Physics:CollidesWith(COLLISION.INTWALL)
	inst.Physics:SetActive(true)
	
	local ground = GetWorld()
	if ground then
		local pt = Point(inst.Transform:GetWorldPosition())
		ground.Pathfinder:AddWall(pt.x + 0.5, pt.y, pt.z + 0.5)
		ground.Pathfinder:AddWall(pt.x + 0.5, pt.y, pt.z - 0.5)
		ground.Pathfinder:AddWall(pt.x - 0.5, pt.y, pt.z + 0.5)
		ground.Pathfinder:AddWall(pt.x - 0.5, pt.y, pt.z - 0.5)
		ground:PushEvent("floodblockercreated",{blocker = inst})
	end
end

local function ondeploy(inst, pt, deployer)
	local wall = SpawnPrefab("sandbagsmall") 
	local ground = GetWorld()
	
	if wall then
		
		pt = quantizepos(pt)

		wall.Physics:SetCollides(false)
		wall.Physics:Teleport(pt.x, pt.y, pt.z) 
		wall.Physics:SetCollides(true)
		wall.SoundEmitter:PlaySound("dontstarve_DLC002/common/sandbag")
		inst.components.stackable:Get():Remove()

		--GetWorld():PushEvent("floodblockercreated",{blocker = wall})
		makeobstacle(wall)
	end
end



local function clearobstacle(inst)
	inst:DoTaskInTime(2*FRAMES, function() inst.Physics:SetActive(false) end)

	local ground = GetWorld()
	if ground then
		local pt = Point(inst.Transform:GetWorldPosition())
		ground.Pathfinder:RemoveWall(pt.x + 0.5, pt.y, pt.z + 0.5)
		ground.Pathfinder:RemoveWall(pt.x + 0.5, pt.y, pt.z - 0.5)
		ground.Pathfinder:RemoveWall(pt.x - 0.5, pt.y, pt.z + 0.5)
		ground.Pathfinder:RemoveWall(pt.x - 0.5, pt.y, pt.z - 0.5)
		ground:PushEvent("floodblockerremoved",{blocker = inst})
	end
end

local function onhammered(inst, worker)
	local max_loots = 2
	local num_loots = math.max(1, math.floor(max_loots*inst.components.health:GetPercent()))
	for k = 1, num_loots do
		inst.components.lootdropper:SpawnLootPrefab("sand")
	end
	
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	
	--inst.SoundEmitter:PlaySound(data.destroysound)
	GetWorld():PushEvent("floodblockerremoved",{blocker = inst})
	inst:Remove()
	
end

local function onhealthchange(inst, old_percent, new_percent)
	if old_percent <= 0 and new_percent > 0 then makeobstacle(inst) end
	if old_percent > 0 and new_percent <= 0 then clearobstacle(inst) end

	local anim_to_play = resolveanimtoplay(inst, new_percent)
	inst.AnimState:PlayAnimation(anim_to_play)
end

local function onhit(inst)
	inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/sandbag")		
	
	local healthpercent = inst.components.health:GetPercent()
	local anim_to_play = resolveanimtoplay(inst, healthpercent)
	inst.AnimState:PlayAnimation(anim_to_play)		
end

local function onrepaired(inst)
	inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/sandbag")		
	makeobstacle(inst)
end

local function test_wall(inst, pt)
	local map = GetWorld().Map
	local tiletype = GetGroundTypeAtPosition(pt)
	local ground_OK = tiletype ~= GROUND.IMPASSABLE and not map:IsWater(tiletype)
	

	
	if ground_OK then
		local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 2, nil, {"NOBLOCK", "player", "FX", "INLIMBO", "DECOR"}) -- or we could include a flag to the search?

		for k, v in pairs(ents) do
			if v ~= inst and v:IsValid() and v.entity:IsVisible() and not v.components.placer and v.parent == nil then
				local dsq = distsq( Vector3(v.Transform:GetWorldPosition()), pt)
				if v:HasTag("sandbag") then
					if dsq < .1 then 
						return false 
					end
				else
					if  dsq< 1 then 
						return false 
					end
				end
			end
		end

		local playerPos = GetPlayer():GetPosition()
		local xDiff = playerPos.x - pt.x 
		local zDiff = playerPos.z - pt.z 
		local dsq = xDiff * xDiff + zDiff * zDiff
		if dsq < 1 then 
			return false 
		end 


		return true

	end
	return false
	
end

local function onremoveentity(inst)
	clearobstacle(inst)
end

local function onload(inst, data)
	makeobstacle(inst)
	if inst.components.health:GetPercent() <= 0 then
		clearobstacle(inst)
	end
end


local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	trans:SetEightFaced()
	--inst.entity:AddFloodingBlockerEntity()
	--anim:SetScale(.65, .65)
	MakeObstaclePhysics(inst, 1) 
	inst:AddTag("floodblocker")
	inst:AddTag("sandbag")
	inst:AddTag("wall")
	--inst.entity:SetCanSleep(false)
	
	anim:SetBank("sandbag_small")
	anim:SetBuild("sandbag_small")
	anim:PlayAnimation("full", false)

	
	inst:AddComponent("inspectable")
	inst:AddComponent("lootdropper")

	inst:AddComponent("repairable")
	inst.components.repairable.repairmaterial = "sandbagsmall"
	inst.components.repairable.onrepaired = onrepaired
	
	inst:AddComponent("combat")
	inst.components.combat.onhitfn = onhit
	
	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(TUNING.SANDBAG_HEALTH)
	inst.components.health.currenthealth = TUNING.SANDBAG_HEALTH
	inst.components.health.ondelta = onhealthchange
	inst.components.health.nofadeout = true
	inst.components.health.canheal = false
	inst:AddTag("noauradamage")

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(3)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)

	inst.OnLoad = onload
	inst.OnRemoveEntity = onremoveentity
	inst:ListenForEvent("FloodModeChanged", function(it, data)
		if inst.components.health.currenthealth > 0 then 
			GetWorld():PushEvent("floodblockercreated",{blocker = inst})
		end 
	end, GetWorld())
	
	inst:DoTaskInTime(0, function() makeobstacle(inst) end)

    inst.returntointeriorscene = makeobstacle
   	inst.removefrominteriorscene = clearobstacle

	---------------------  
	return inst      
end

local function itemfn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

	inst:AddTag("wallbuilder")

	MakeInventoryPhysics(inst)

	anim:SetBank("sandbag")
	anim:SetBuild("sandbag")
	anim:PlayAnimation("idle")

	inst:AddComponent("repairer")
	inst.components.repairer.repairmaterial = "sandbagsmall"
	inst.components.repairer.healthrepairvalue = TUNING.SANDBAG_HEALTH / 2

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM
	
	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")

	inst:AddComponent("deployable")
	inst.components.deployable.ondeploy = ondeploy
	inst.components.deployable.min_spacing = 0
	--inst.components.deployable.placer = "gridplacer"	
	inst.components.deployable.test = test_wall
	inst.components.deployable.placer = "sandbagsmall_placer"
	inst.components.deployable:SetQuantizeFunction(quantizepos)
	inst.components.deployable.deploydistance = 2
	
	---------------------  
	return inst      
end

return Prefab( "shipwrecked/objects/sandbagsmall", fn, assets, prefabs ),
		Prefab( "shipwrecked/objects/sandbagsmall_item", itemfn, assets, prefabs ), 
		 MakePlacer("common/sandbagsmall_placer",  "sandbag_small", "sandbag_small", "full", false, false, false, 1.0, true, nil, "eight") 
