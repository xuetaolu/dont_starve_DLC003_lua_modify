require "prefabutil"


local anims =
{
    { threshold = 0, anim = "broken" },
    { threshold = 0.4, anim = "onequarter" },
    { threshold = 0.5, anim = "half" },
    { threshold = 0.99, anim = "threequarter" },
    { threshold = 1, anim = { "fullA", "fullB", "fullC" } },
}

local function resolveanimtoplay(inst, percent)

    local function getbasename(inst, percent)
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
    
    local animname = getbasename(inst, percent)
    if isWallOnWater(inst) then
        animname = "water_" .. animname
    end
    
    
    return animname
end

function isDeepWaterWall(inst)    
    return inst.prefab == "wall_enforcedlimestone" or inst.prefab == "wall_enforcedlimestone_item"
end

function isWaterWall(inst)    
    return inst.prefab == "wall_enforcedlimestone" or inst.prefab == "wall_enforcedlimestone_item"
end

function isWallOnWater(inst)
    local map = GetWorld().Map
    local pt = Point(inst.Transform:GetWorldPosition())
	local tiletype = GetGroundTypeAtPosition(pt)	
	--return map:IsBuildableWater(tiletype)
	return map:IsWater(tiletype)
end

function MakeWallType(data)

	local assets =
	{
		Asset("ANIM", "anim/wall.zip"),
		Asset("ANIM", "anim/wall_".. data.name..".zip"),
		Asset("INV_IMAGE", "rockwall"),
	}

	local prefabs =
	{
		"collapse_small",
	}


	local function quantizeposition(pt)
		local retval = Vector3(math.floor(pt.x)+.5, 0, math.floor(pt.z)+.5)
		return retval
	end 

	local function ondeploywall(inst, pt, deployer)
		--inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/spider_egg_sack")
		local wall = SpawnPrefab("wall_"..data.name) 
		if wall then 
			pt = quantizeposition(pt)
			wall.Physics:SetCollides(false)
			wall.Physics:Teleport(pt.x, pt.y, pt.z) 
			wall.Physics:SetCollides(true)
			inst.components.stackable:Get():Remove()

	        if isWallOnWater(wall) then
				wall.AnimState:PlayAnimation("water_half", true)
			end

		    local ground = GetWorld()
		    if ground then
		    	ground.Pathfinder:AddWall(pt.x, pt.y, pt.z)
		    end

		end 		
	end

	local function onhammered(inst, worker)
		if data.maxloots and data.loot then
			local num_loots = math.max(1, math.floor(data.maxloots*inst.components.health:GetPercent()))
			for k = 1, num_loots do
				inst.components.lootdropper:SpawnLootPrefab(data.loot)
			end
		end		
		
		SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
		
		if data.destroysound then
			inst.SoundEmitter:PlaySound(data.destroysound)		
		end
		
		inst:Remove()
	end

	local function ongusthammerfn(inst)
	    --onhammered(inst, nil)
	    inst.components.health:DoDelta(-data.windblown_damage, false, "wind")
	end

	local function test_wall(inst, pt)
		local map = GetWorld().Map
		local tiletype = GetGroundTypeAtPosition(pt)
		local ground_OK = tiletype ~= GROUND.IMPASSABLE

		if isDeepWaterWall(inst) then
			ground_OK = ground_OK and map:IsWater(tiletype)
		elseif isWaterWall(inst) then
			ground_OK = ground_OK and (not map:IsWater(tiletype) or map:IsBuildableWater(tiletype))
		else 
			ground_OK = ground_OK and not map:IsWater(tiletype)
		end
	
		if ground_OK then
			local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 2, nil, {"NOBLOCK", "player", "FX", "INLIMBO", "DECOR"}) -- or we could include a flag to the search?

			for k, v in pairs(ents) do
				if v ~= inst and v:IsValid() and v.entity:IsVisible() and not v.components.placer and v.parent == nil then
					local dsq = distsq( Vector3(v.Transform:GetWorldPosition()), pt)
					if v:HasTag("wall") then
						if dsq < 0.1 then return false end
					else
						if dsq< 1 then return false end
					end
				end
			end

			local playerPos = GetPlayer():GetPosition()
			local xDiff = playerPos.x - pt.x 
			local zDiff = playerPos.z - pt.z 
			local dsq = xDiff * xDiff + zDiff * zDiff
			if dsq < .5 then 
				return false 
			end 
			return true

		end
		return false
		
	end

	local function makeobstacle(inst)
		-- print('makeobstacle walls.lua')
	
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
			--print("    at: ", pt)
	    	ground.Pathfinder:AddWall(pt.x, pt.y, pt.z)
	    end
	end

	local function clearobstacle(inst)
		-- Alia: 
		-- Since we are removing the wall anytway we may as well not bother setting the physics    
	    -- We had better wait for the callback to complete before trying to remove ourselves
	    inst:DoTaskInTime(2*FRAMES, function()
			if inst:IsValid() then
				inst.Physics:SetActive(false)
			end
		end)

	    local ground = GetWorld()
	    if ground then
	    	local pt = Point(inst.Transform:GetWorldPosition())
	    	ground.Pathfinder:RemoveWall(pt.x, pt.y, pt.z)
	    end
	end

	local function onhealthchange(inst, old_percent, new_percent)
		if old_percent <= 0 and new_percent > 0 then makeobstacle(inst) end
		if old_percent > 0 and new_percent <= 0 then clearobstacle(inst) end

		local anim_to_play = resolveanimtoplay(inst, new_percent)
		local shouldLoop = isWaterWall(inst)

		if new_percent > 0 then
			inst.AnimState:PlayAnimation(anim_to_play.."_hit")            
			inst.AnimState:PushAnimation(anim_to_play, shouldLoop)		
		else
			inst.AnimState:PlayAnimation(anim_to_play, shouldLoop)
		end
	end

	
	local function itemfn(Sim)

		local inst = CreateEntity()
		inst:AddTag("wallbuilder")
		
		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		MakeInventoryPhysics(inst)
	    
		inst.AnimState:SetBank("wall")
		inst.AnimState:SetBuild("wall_"..data.name)
		inst.AnimState:PlayAnimation("idle")

		if data.name == "wood" or data.name == "hay" or data.name == "limestone" or data.name == "enforcedlimestone" then
			MakeInventoryFloatable(inst, "idle_water", "idle")
		end

		inst:AddComponent("stackable")
		inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

		inst:AddComponent("inspectable")
		inst:AddComponent("inventoryitem")

		inst:AddComponent("repairer")

        if data.name == "ruins" then
		    inst.components.repairer.repairmaterial = "thulecite"
        else
		    inst.components.repairer.repairmaterial = data.name
        end

		inst.components.repairer.healthrepairvalue = data.maxhealth / 6
	    
		
		if data.flammable then
			MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
			MakeSmallPropagator(inst)
			
			inst:AddComponent("fuel")
			inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

			inst:AddComponent("appeasement")
    		inst.components.appeasement.appeasementvalue = TUNING.WRATH_SMALL

			inst.components.burnable:MakeDragonflyBait(3)
		end
		
		inst:AddComponent("deployable")
		inst.components.deployable.ondeploy = ondeploywall
		inst.components.deployable.test = test_wall
		inst.components.deployable.min_spacing = 0
		inst.components.deployable.placer = "wall_"..data.name.."_placer"
		inst.components.deployable:SetQuantizeFunction(quantizeposition)
		if data.name == "limestone" or data.name == "enforcedlimestone" then
			inst.components.deployable.deploydistance = 2
		else
			inst.components.deployable.deploydistance = 1.5
		end

		return inst
	end

	local function onhit(inst)
		-- if data.destroysound then
		-- 	inst.SoundEmitter:PlaySound(data.destroysound)		
		-- end

		local healthpercent = inst.components.health:GetPercent()
		local anim_to_play = resolveanimtoplay(inst, healthpercent)

		local shouldLoop = isWaterWall(inst)		

		if healthpercent > 0 then
			inst.AnimState:PlayAnimation(anim_to_play.."_hit")		
			inst.AnimState:PushAnimation(anim_to_play, shouldLoop)	
		end	
	end

	local function onrepaired(inst)
		if isWallOnWater(inst) and data.buildwatersound then
			inst.SoundEmitter:PlaySound(data.buildwatersound)	
		elseif data.buildsound then
			inst.SoundEmitter:PlaySound(data.buildsound)		
		end
		makeobstacle(inst)
	end
	    
	local function onload(inst, data)
		--print("walls - onload")
		makeobstacle(inst)
		if inst.components.health:GetPercent() <= 0 then
			clearobstacle(inst)
		end
	end

	local function onremoveentity(inst)
		clearobstacle(inst)
	end

	local function returntointeriorscene(inst)
		makeobstacle(inst)
	end

	local function removefrominteriorscene(inst)
		clearobstacle(inst)
	end

	local function fn(Sim)
		local inst = CreateEntity()
		local trans = inst.entity:AddTransform()
		local anim = inst.entity:AddAnimState()
		inst.entity:AddSoundEmitter()
		trans:SetEightFaced()

		inst:AddTag("wall")
		MakeObstaclePhysics(inst, .5)     
        inst.Physics:SetDontRemoveOnSleep(true)

		anim:SetBank("wall")
		anim:SetBuild("wall_"..data.name)
	    anim:PlayAnimation("half", false)
        	    
		inst:AddComponent("inspectable")
		inst:AddComponent("lootdropper")
		
		for k,v in ipairs(data.tags) do
		    inst:AddTag(v)
		end

		if data.waveobstacle then
			inst:AddComponent("waveobstacle")
		end

		inst:AddComponent("repairable")
        if data.name == "ruins" then
		    inst.components.repairable.repairmaterial = "thulecite"
        else
		    inst.components.repairable.repairmaterial = data.name
        end
		inst.components.repairable.onrepaired = onrepaired
		
		inst:AddComponent("combat")
		inst.components.combat.onhitfn = onhit
		
		inst:AddComponent("health")
		inst.components.health:SetMaxHealth(data.maxhealth)
		inst.components.health.currenthealth = data.maxhealth / 2
		inst.components.health.ondelta = onhealthchange
		inst.components.health.nofadeout = true
		inst.components.health.canheal = false
		inst:AddTag("noauradamage")
		
		if data.flammable then
			MakeMediumBurnable(inst)
			MakeLargePropagator(inst)
			inst.components.burnable.flammability = .5
			
			--lame!
			if data.name == "wood" then
				inst.components.propagator.flashpoint = 30+math.random()*10			
			end
		else
			inst.components.health.fire_damage_scale = 0
		end

		if isWallOnWater(inst) and data.buildwatersound then
			inst.SoundEmitter:PlaySound(data.buildwatersound)	
		elseif data.buildsound then
			inst.SoundEmitter:PlaySound(data.buildsound)		
		end	     

		inst:AddComponent("workable")
		inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
		inst.components.workable:SetWorkLeft(3)
		inst.components.workable:SetOnFinishCallback(onhammered)
		inst.components.workable:SetOnWorkCallback(onhit) 

		if data.windblown_speed and data.windblown_fall_chance and data.windblown_damage then
		    inst:AddComponent("blowinwindgust")
		    inst.components.blowinwindgust:SetWindSpeedThreshold(data.windblown_speed)
		    inst.components.blowinwindgust:SetDestroyChance(data.windblown_fall_chance)
		    inst.components.blowinwindgust:SetDestroyFn(ongusthammerfn)
		    inst.components.blowinwindgust:Start()
		end	
		
	    inst.OnLoad = onload
	    inst.OnRemoveEntity = onremoveentity

		inst:ListenForEvent("endinteriorcam", function() 
                inst.Transform:SetRotation(inst.Transform:GetRotation())
            end, GetWorld())	    
		
		MakeSnowCovered(inst)

		inst:AddComponent("gridnudger")

	    inst.returntointeriorscene = returntointeriorscene
    	inst.removefrominteriorscene = removefrominteriorscene
	
		return inst
	end


	local function fn_repaired(Sim)
		local inst = fn(Sim)
		inst.components.health:SetPercent(1)
		inst:SetPrefabName("wall_"..data.name)
		return inst
	end

	return Prefab( "common/wall_"..data.name, fn, assets, prefabs),
	 	   Prefab( "common/wall_"..data.name.."_repaired", fn_repaired, assets, prefabs),
		   Prefab( "common/wall_"..data.name.."_item", itemfn, assets, {"wall_"..data.name, "wall_"..data.name.."_placer", "collapse_small"}),
		   MakePlacer("common/wall_"..data.name.."_placer", "wall", "wall_"..data.name, "half", false, false, true, nil, nil, nil, "eight") 
end



local wallprefabs = {}

--6 rock, 8 wood, 4 straw
--NOTE: Stacksize is now set in the actual recipe for the item.
local walldata = {
			{name = "stone", tags={"stone"}, loot = "rocks", maxloots = 2, maxhealth=TUNING.STONEWALL_HEALTH, buildsound="dontstarve/common/place_structure_stone", destroysound="dontstarve/common/destroy_stone"},
			{name = "wood", tags={"wood"}, loot = "log", maxloots = 2, maxhealth=TUNING.WOODWALL_HEALTH, flammable = true, buildsound="dontstarve/common/place_structure_wood", destroysound="dontstarve/common/destroy_wood", windblown_speed=TUNING.WALLWOOD_WINDBLOWN_SPEED, windblown_fall_chance=TUNING.WALLWOOD_WINDBLOWN_DAMAGE_CHANCE, windblown_damage=TUNING.WALLWOOD_WINDBLOWN_DAMAGE},
			{name = "hay", tags={"grass"}, loot = "cutgrass", maxloots = 2, maxhealth=TUNING.HAYWALL_HEALTH, flammable = true, buildsound="dontstarve/common/place_structure_straw", destroysound="dontstarve/common/destroy_straw", windblown_speed=TUNING.WALLHAY_WINDBLOWN_SPEED, windblown_fall_chance=TUNING.WALLHAY_WINDBLOWN_DAMAGE_CHANCE, windblown_damage=TUNING.WALLHAY_WINDBLOWN_DAMAGE},
			{name = "ruins", tags={"stone", "ruins"}, loot = "thulecite_pieces", maxloots = 2, maxhealth=TUNING.RUINSWALL_HEALTH, buildsound="dontstarve/common/place_structure_stone", destroysound="dontstarve/common/destroy_stone"},
			{name = "limestone", tags={"stone"}, loot = "coral", maxloots = 2, maxhealth=TUNING.LIMESTONEWALL_HEALTH, buildsound="dontstarve/common/place_structure_stone", destroysound="dontstarve/common/destroy_stone", buildwatersound="dontstarve_DLC002/creatures/seacreature_movement/water_emerge_lrg"},
			{name = "enforcedlimestone", tags={"stone"}, loot = "coral", maxloots = 1, maxhealth=TUNING.ENFORCEDLIMESTONEWALL_HEALTH, buildsound="dontstarve/common/place_structure_stone", destroysound="dontstarve/common/destroy_stone", buildwatersound="dontstarve_DLC002/creatures/seacreature_movement/water_emerge_lrg", waveobstacle = true},
			{name = "pig_ruins", tags={"stone"}, loot = "rocks", maxloots = 2, maxhealth=TUNING.STONEWALL_HEALTH, buildsound="dontstarve/common/place_structure_stone", destroysound="dontstarve/common/destroy_stone"},			
		}

for k,v in pairs(walldata) do
	local wall, reparied, item, placer = MakeWallType(v)
	table.insert(wallprefabs, wall)
	table.insert(wallprefabs, reparied)
	table.insert(wallprefabs, item)
	table.insert(wallprefabs, placer)
end


return unpack(wallprefabs) 
	