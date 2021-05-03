local grassassets=
{
	Asset("ANIM", "anim/grass_tall.zip", ALT_RENDERPATH),	-- you really only want to use this if you know what it means to the engine. Generally it's a bad plan with worse outcomes.
	Asset("SOUND", "sound/common.fsb"),
	Asset("MINIMAP_IMAGE", "grass"),
}

local waterassets=
{
	Asset("ANIM", "anim/grass_inwater.zip"),
	Asset("ANIM", "anim/grassgreen_build.zip"),
	Asset("SOUND", "sound/common.fsb"),
}

local grassprefabs =
{
	"weevole",
    "cutgrass",
    "dug_grass",
   	"hacking_tall_grass_fx",
}

local waterprefabs =
{
    "cutgrass"
}


local function startspawning(inst)
	if inst.components.childspawner and inst.components.hackable:CanBeHacked() then
		local frozen = (inst.components.freezable and inst.components.freezable:IsFrozen())
		if not frozen and not GetClock():IsDay() then
			inst.components.childspawner:StartSpawning()
		end
	end
end

local function stopspawning(inst)
	if inst.components.childspawner then
		inst.components.childspawner:StopSpawning()
	end
end

local function removeweevoleden(inst)
	inst:RemoveTag("weevole_infested")
	inst:RemoveEventCallback("dusktime", function() startspawning(inst) end, GetWorld())
	inst:RemoveEventCallback("daytime", function() stopspawning(inst) end , GetWorld())
end

local function makeweevoleden(inst)
	inst:AddTag("weevole_infested")
	inst:ListenForEvent("dusktime", function() startspawning(inst) end, GetWorld())
	inst:ListenForEvent("daytime", function() stopspawning(inst) end , GetWorld())
end

local function onsave(inst, data)
	data.weevoleinfested = inst:HasTag("weevole_infested")
end

local function onload(inst, data)
    if data and data.weevoleinfested then
	    makeweevoleden(inst)
	end
end

local function onspawnweevole(inst)
	if inst:IsValid() then
	--	inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/snake/snake_bush")		
		if inst.components.hackable and inst.components.hackable:CanBeHacked() then	
			inst.AnimState:PlayAnimation("rustle", false)
			inst.AnimState:PushAnimation("idle", true)
		end
	end
end

local function weevolenesttest(inst)
	local pt = Vector3(inst.Transform:GetWorldPosition())
	local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 12, {"grass_tall"})
	local weevoleents = TheSim:FindEntities(pt.x,pt.y,pt.z, 12, {"weevole_infested"})

	if #weevoleents < 1 and math.random() < #ents/100 then
		local ent = ents[math.random(#ents)]
		makeweevoleden(ent)		
	end
end

local function onregenfn(inst)
	inst.AnimState:PlayAnimation("grow") 
	inst.AnimState:PushAnimation("idle", true)
	inst.components.hackable.hacksleft = inst.components.hackable.maxhacks
	weevolenesttest(inst)
end

local function makeemptyfn(inst)
	inst.AnimState:PlayAnimation("picked",true)	
	inst.components.hackable.hacksleft = 0
	inst.components.childspawner:StopSpawning()  
end

local function makebarrenfn(inst)
	inst.AnimState:PlayAnimation("picked",true)
	inst.components.hackable.hacksleft = 0
	inst.components.childspawner:StopSpawning()  
end

local function spawnweevole(inst, target)

	local weevole = inst.components.childspawner:SpawnChild()
	if weevole then
		local spawnpos = Vector3(inst.Transform:GetWorldPosition())
		spawnpos = spawnpos + TheCamera:GetDownVec()
		weevole.Transform:SetPosition(spawnpos:Get())
		if weevole and target and weevole.components.combat then
			weevole.components.combat:SetTarget(target)
		end
	end
end

local function onhackedfn(inst, target, hacksleft, from_shears)

	local fx = SpawnPrefab("hacking_tall_grass_fx")
	local x, y, z= inst.Transform:GetWorldPosition()
    fx.Transform:SetPosition(x,y + math.random()*2,z)

	if inst:HasTag("weevole_infested")then
		spawnweevole(inst, target)
	end

	if inst.components.hackable and inst.components.hackable.hacksleft <= 0 then		
		inst.AnimState:PlayAnimation("fall")			
		inst.AnimState:PushAnimation("picked",true)			
		inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/vine_drop")	
		if inst:HasTag("weevole_infested")then	
			removeweevoleden(inst)
		end
	else
		inst.AnimState:PlayAnimation("chop") 
		inst.AnimState:PushAnimation("idle",true)
	end

	if inst.components.pickable then
		inst.components.pickable:MakeEmpty()
	end

	if not from_shears then	
		inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/harvested/grass_tall/machete")
	end
	

	--[[
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
	]]
end

local function makegrass(inst)
	inst.MiniMapEntity:SetIcon("grass.png")
	inst.AnimState:SetBank("grass_tall")	
	inst.AnimState:SetBuild("grass_tall")
end

local function placegrassoffgrids(inst)
    
    local x,y,z = 0,0,0
    local offgrid = false
    local inc = 1
    while offgrid == false do
        x,y,z = inst.Transform:GetWorldPosition()
        
        local radiusMax = 12        
        local rad = math.random()*radiusMax
        local xdiff = math.random()*rad
        local ydiff = math.sqrt( (rad*rad) - (xdiff*xdiff))

        if math.random() > 0.5 then
        	xdiff= -xdiff
        end

        if math.random() > 0.5 then
        	ydiff= -ydiff
        end
        x = x+ xdiff
        z = z+ ydiff

        local ents = TheSim:FindEntities(x,y,z, 1, {"grass_tall"})
        local test = true
        for i,ent in ipairs(ents) do
            local entx,enty,entz = ent.Transform:GetWorldPosition()
           -- print("checing round x:",round(x),round(entx),"z:", round(z), round(entz),"diff:",round(math.abs(entx-x)),round( math.abs(entz-z)) )
            if round(x) == round(entx) or round(z) == round(entz) or ( math.abs(round(entx-x)) == math.abs(round(entz-z)) )  then
                test = false
         --       print("test fail")
                break
            end           
        end
        
        offgrid = test
        inc = inc +1 
    end
    if  GetWorld().Map:GetTileAtPoint(x,y,z) > 1 then
    	local plant = SpawnPrefab("grass_tall")
    	plant.Transform:SetPosition(x,y,z)    
	end
    
end
local function spawngrass(inst)
    for i=1,math.random(100,200),1 do
        placegrassoffgrids(inst)        
    end
end

local function onnear(inst)
	if not inst.playernear then
		if inst.components.hackable and inst.components.hackable:CanBeHacked() then		                                								
			inst.AnimState:PlayAnimation("rustle") 
			inst.AnimState:PushAnimation("idle",true)		
		end		
	end
	inst.playernear = true
end


local function onfar(inst)
	inst.playernear = false
end



local function makefn(stage, artfn, product, dig_product, burnable, pick_sound, patch)

	local function dig_up(inst, chopper)
		if inst.components.hackable and inst.components.hackable:CanBeHacked() then
			inst.components.lootdropper:SpawnLootPrefab(product)
		end
		local bush = inst.components.lootdropper:SpawnLootPrefab(dig_product)
		inst:Remove()
	end

	local function fn(Sim)
		local inst = CreateEntity()
		local trans = inst.entity:AddTransform()
		local anim = inst.entity:AddAnimState()
	    local sound = inst.entity:AddSoundEmitter()
		local minimap = inst.entity:AddMiniMapEntity()

		artfn(inst)

	    anim:PlayAnimation("idle",true)
	    anim:SetTime(math.random()*2)
	    local color = 0.75 + math.random() * 0.25
	    anim:SetMultColour(color, color, color, 1)

	    inst:AddTag("gustable")
	    inst:AddTag("grass_tall")
	    inst:AddTag("plant")


		inst:AddComponent("hackable")
		inst.components.hackable:SetUp("cutgrass", TUNING.VINE_REGROW_TIME )  
		inst.components.hackable.onregenfn = onregenfn
		inst.components.hackable.onhackedfn = onhackedfn
		inst.components.hackable.makeemptyfn = makeemptyfn
		inst.components.hackable.makebarrenfn = makebarrenfn
		inst.components.hackable.max_cycles = 20
		inst.components.hackable.cycles_left = 20
		inst.components.hackable.hacksleft = 2.5
		inst.components.hackable.maxhacks = 2.5

		inst:AddComponent("shearable")
		inst.components.shearable:SetProduct("cutgrass", 2)

	    inst:AddComponent("creatureprox")
	    inst.components.creatureprox:SetOnPlayerNear(onnear)
	    inst.components.creatureprox:SetOnPlayerFar(onfar)
	    inst.components.creatureprox:SetDist(0.75,1)

		inst:AddComponent("lootdropper")
	    inst:AddComponent("inspectable")    
	
		if dig_product ~= nil then
			inst:AddComponent("workable")
		    inst.components.workable:SetWorkAction(ACTIONS.DIG)
		    inst.components.workable:SetOnFinishCallback(dig_up)
		    inst.components.workable:SetWorkLeft(1)
		end

	    MakeHackableBlowInWindGust(inst, TUNING.GRASS_WINDBLOWN_SPEED, 0)
	    
	    ---------------------

	    if burnable then
		    MakeMediumBurnable(inst)
		    MakeSmallPropagator(inst)
		    inst.components.burnable:MakeDragonflyBait(1)
		end

		MakeNoGrowInWinter(inst)		

		
	    ---------------------
		inst:AddComponent("childspawner")
		inst.components.childspawner.childname = "weevole"
		inst.components.childspawner:SetRegenPeriod(TUNING.SPIDERDEN_REGEN_TIME)
		inst.components.childspawner:SetSpawnPeriod(TUNING.SPIDERDEN_RELEASE_TIME)
		inst.components.childspawner:SetSpawnedFn(onspawnweevole)
		inst.components.childspawner:SetMaxChildren(TUNING.WEEVOLEDEN_MAX_WEEVOLES)	 

	    if patch then
	    --	inst:DoTaskInTime(0,function() spawngrass(inst) end) 
	    	inst:SetPrefabName("grass_tall") 
			makeweevoleden(inst)
	    end

	    --------SaveLoad
	    inst.OnSave = onsave 
	    inst.OnLoad = onload 

	    return inst
	end

    return fn
end

return Prefab("forest/objects/grass_tall", makefn(0, makegrass, "cutgrass", "dug_grass", true, "dontstarve/wilson/pickup_reeds"), grassassets, grassprefabs),
	   Prefab("forest/objects/grass_tall_patch", makefn(0, makegrass, "cutgrass", "dug_grass", true, "dontstarve/wilson/pickup_reeds",true), grassassets, grassprefabs)