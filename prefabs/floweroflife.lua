require "prefabutil"

local assets=
{
	Asset("ANIM", "anim/lifeplant.zip"),
	Asset("ANIM", "anim/lifeplant_fx.zip"),
	Asset("MINIMAP_IMAGE", "lifeplant"),
}

local prefabs =
{
	"collapse_small",
}

local INTENSITY = .5

local function fadein(inst)
    inst.components.fader:StopAll()
    inst.Light:Enable(true)
	if inst:IsAsleep() then
		inst.Light:SetIntensity(INTENSITY)
	else
		inst.Light:SetIntensity(0)
		inst.components.fader:Fade(0, INTENSITY, 3+math.random()*2, function(v) inst.Light:SetIntensity(v) end)
	end
end

local function fadeout(inst)
    inst.components.fader:StopAll()
	if inst:IsAsleep() then
		inst.Light:SetIntensity(0)
	else
		inst.components.fader:Fade(INTENSITY, 0, .75+math.random()*1, function(v) inst.Light:SetIntensity(v) end)
	end
end


local function onburnt(inst)

	local ash = SpawnPrefab("ash")
	ash.Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst:Remove()

end

local function makeused(inst)
	if inst.components.resurrector and not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("debris")
		inst.components.resurrector.penalty = 0	
	end
end

local function onhit(inst, worker)
	if not inst:HasTag("burnt") then
		if not inst.components.resurrector.used then
			inst.AnimState:PlayAnimation("hit")
			inst.AnimState:PushAnimation("idle")
		end
	end
end

local function doresurrect(inst, dude)

	inst.reserrecting = true
	if inst.starvetask then
		inst.starvetask:Cancel()
		inst.starvetask = nil

		inst.starvetask2:Cancel()
		inst.starvetask2 = nil		
	end

	if inst:HasTag("fire") and inst.components.burnable then
		inst.components.burnable:Extinguish()
	end
	if dude.components.poisonable and dude.components.poisonable:IsPoisoned() then 
		dude.components.poisonable:Cure()
	end 

	if(dude == GetPlayer()) then --Would this ever be false? 
		if dude.components.driver:GetIsDriving() then 
			dude.components.driver:OnDismount()
		end 
	end
	
	inst:AddTag("busy")	

    inst:RemoveComponent("lootdropper")
    inst:RemoveComponent("workable")
    inst:RemoveComponent("inspectable")
	inst.MiniMapEntity:SetEnabled(false)
    if inst.Physics then
		RemovePhysicsColliders(inst)
    end

	GetClock():MakeNextDay()

    dude.Transform:SetPosition(inst.Transform:GetWorldPosition())

    dude:Hide()
    dude:ClearBufferedAction()

    if dude.HUD then
        dude.HUD:Hide()
    end
    if dude.components.playercontroller then
        dude.components.playercontroller:Enable(false)
    end

	if TheCamera.interior or inst.interior then
		GetPlayer().Transform:SetRotation(0)
		local interiorSpawner = GetWorld().components.interiorspawner
		interiorSpawner:PlayTransition(GetPlayer(), nil, inst.interior, inst)			
	else		
	    GetPlayer().Transform:SetRotation(inst.Transform:GetRotation())
	end
	
	if not inst.interior then
		if TheCamera.interior then
			local interiorSpawner = GetWorld().components.interiorspawner
			interiorSpawner.exteriorCamera:SetDistance(12)
		else
			TheCamera:SetDistance(12)	
		end
	end

	dude.components.hunger:Pause()
	
    scheduler:ExecuteInTime(2, function()
    	inst.persists = false
        dude:Show()

        inst:Hide()
        inst.AnimState:PlayAnimation("transform")
        inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/flower_of_life/rebirth")
		inst.components.resurrector.penalty = 0                
		
        dude.sg:GoToState("rebirth2")
        
        --SaveGameIndex:SaveCurrent()
        dude:DoTaskInTime(3, function() 
            if dude.HUD then
                dude.HUD:Show()
            end
            if dude.components.hunger then
                dude.components.hunger:SetPercent(2/3)
            end
			
            if dude.components.health then
				dude.components.health:RecalculatePenalty()
                dude.components.health:Respawn(TUNING.RESURRECT_HEALTH)
                dude.components.health:SetInvincible(true)
            end

            if dude.components.moisture then
            	dude.components.moisture.moisture = 0
            end

            if dude.components.temperature then
            	dude.components.temperature:SetTemperature(TUNING.STARTING_TEMP)
            end
            
            if dude.components.sanity then
			    dude.components.sanity:SetPercent(.5)
            end
            if dude.components.playercontroller then
                dude.components.playercontroller:Enable(true)
            end
            
            dude.components.hunger:Resume()
            
            TheCamera:SetDefault()
            inst:RemoveTag("busy")
        end)
        inst:DoTaskInTime(4, function() 
            dude.components.health:SetInvincible(false)
			--inst:Show()
        end)
		inst:DoTaskInTime(7, function()

			--reset fountain
			if inst.fountain then
				inst.fountain.deactivate(inst.fountain)
			end

		    local tick_time = TheSim:GetTickTime()
		    local time_to_erode = 4
		    inst:StartThread( function()
			    local ticks = 0
			    while ticks * tick_time < time_to_erode do
				    local erode_amount = ticks * tick_time / time_to_erode
				    inst.AnimState:SetErosionParams( erode_amount, 0.1, 1.0 )
				    ticks = ticks + 1
				    Yield()
			    end
			    print("REMOVING")
			    inst:Remove()
		    end)
		end)
        
    end)

end

local function onplanted(inst,fountain)
    inst.AnimState:PlayAnimation("grow")
    inst.AnimState:PushAnimation("idle_loop",true)
    if fountain then
        inst.fountain = fountain
    end
    inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/flower_of_life/plant")
	inst.components.resurrector:OnBuilt(GetPlayer())
end

local function onsave(inst, data)

	if inst:HasTag("burnt") or inst:HasTag("fire") then
        data.burnt = true
    end

    return 
end

local function onload(inst, data)
	if data and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function OnLoadPostPass(inst, newents, data)

end


local function OnRemoved(inst)

    -- Remove from save index
	SaveGameIndex:DeregisterResurrector(inst)
	-- Remove penalty if not used
	if not inst.components.resurrector.used then
		local player = GetPlayer()
		if player and player.components.health then
			player.components.health:RecalculatePenalty()
		end
	end

    if inst.fountain and not inst.dug then
    	print("DEACTIVATING FOUNTAIN")
        inst.fountain.deactivate(inst.fountain)
    end 
	inst.SoundEmitter:KillSound("drainloop")   
end

local function CalcSanityAura(inst, observer)
	return TUNING.SANITYAURA_MED
end

local function sparkle(inst)
	local player = GetPlayer()

	local sparkle = SpawnPrefab("lifeplant_sparkle")
	sparkle.Transform:SetPosition(player.Transform:GetWorldPosition())	
end

local function drain(inst)
	local player = GetPlayer()
	player.components.hunger:DoDelta(-1)   
end

local function onnear(inst)	
	if not inst.reserrecting then
		inst.starvetask = inst:DoPeriodicTask(0.5,function() sparkle(inst) end)
		inst.starvetask2 = inst:DoPeriodicTask(2,function() drain(inst) end)
		inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/flower_of_life/fx_LP","drainloop")
	end
end

local function onfar(inst)
	if inst.starvetask then
		inst.starvetask:Cancel()
		inst.starvetask = nil

		inst.starvetask2:Cancel()
		inst.starvetask2 = nil	
		inst.SoundEmitter:KillSound("drainloop")	
	end
end

local function dig_up(inst, chopper)
		
	local drop = inst.components.lootdropper:SpawnLootPrefab("waterdrop")
	inst.SoundEmitter:KillSound("drainloop")
	inst.dug = true

	inst:Remove()
end

local function manageidle(inst)
	local anim = "idle_gargle"
	if math.random() < 0.5 then
		anim = "idle_vanity"
	end

	inst.AnimState:PlayAnimation(anim)
	inst.AnimState:PushAnimation("idle_loop",true)

	inst:DoTaskInTime(8+(math.random()*20), function() inst.manageidle(inst) end)
end

local function fn(Sim)
	local inst = CreateEntity()
	
    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddSoundEmitter()
    
    MakeObstaclePhysics(inst, .3)

	inst.MiniMapEntity:SetIcon( "lifeplant.png" )
    
    inst.AnimState:SetBank("lifeplant")
    inst.AnimState:SetBuild("lifeplant")
    inst.AnimState:PlayAnimation("idle_loop",true)

    inst:AddTag("lifeplant")
    
    inst:AddComponent("inspectable")
    inst:AddComponent("resurrector")
    inst.components.resurrector.active = true
	inst.components.resurrector.doresurrect = doresurrect
	inst.components.resurrector.makeusedfn = makeused
	inst.components.resurrector.penalty = 1
	
    inst:AddComponent("lootdropper")
    
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetWorkLeft(1)
	inst.components.workable:SetOnFinishCallback(dig_up)
	
	MakeSnowCovered(inst, .01)    

	inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(3)
    inst.components.burnable:SetBurnTime(10)
    inst.components.burnable:AddBurnFX("fire", Vector3(0, 0, 0) )
    inst.components.burnable:SetOnBurntFn(onburnt)
    MakeLargePropagator(inst)

    inst:AddComponent("fader")

    local light = inst.entity:AddLight()
    inst.Light:SetIntensity(INTENSITY)
    inst.Light:SetColour(180/255, 195/255, 150/255)
    inst.Light:SetFalloff( 0.9 )
    inst.Light:SetRadius( 2 )
    
    inst.Light:Enable(true)    
    fadein(inst)

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura


    inst:AddComponent("playerprox")

    inst.components.playerprox:SetDist(6,7)
    inst.components.playerprox:SetOnPlayerNear(onnear)
    inst.components.playerprox:SetOnPlayerFar(onfar)

    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )

	inst.OnSave = onsave 
    inst.OnLoad = onload
    inst.OnLoadPostPass = OnLoadPostPass
    inst.onplanted = onplanted

    inst:ListenForEvent("onremove", OnRemoved)
    inst.manageidle = manageidle
    inst:DoTaskInTime(8+(math.random()*20), function() inst.manageidle(inst) end)

    inst:DoTaskInTime(0,function()    	   
            for k,v in pairs(Ents) do                
                if v:HasTag("pugalisk_fountain") then
                    inst.fountain = v
                    break
                end
            end
        end)

   	inst.AnimState:SetMultColour(0.9,0.9,0.9,1)
    return inst
end

local function testforplant(inst)
	local x,y,z = inst.Transform:GetWorldPosition()
	local ent = TheSim:FindFirstEntityWithTag("lifeplant")

	if ent and ent:GetDistanceSqToInst(inst) < 1 then
		inst:Remove()
	end
end

local function onspawn(inst)
	local x,y,z = inst.Transform:GetWorldPosition()
	local ent = TheSim:FindFirstEntityWithTag("lifeplant")
	if ent then
		local x2,y2,z2 = ent.Transform:GetWorldPosition()
    	local angle = inst:GetAngleToPoint(x2, y2, z2)
    	inst.Transform:SetRotation(angle)

		inst.components.locomotor:WalkForward()
		inst:DoPeriodicTask(0.1,function() testforplant(inst) end)
	else
		inst:Remove()
	end
end

local function sparklefn(Sim)
	local inst = CreateEntity()

    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
   

    MakeNoPhysics(inst, 1, 0.3)
    RemovePhysicsColliders(inst)
        
	inst.AnimState:SetBank("lifeplant_fx")
    inst.AnimState:SetBuild("lifeplant_fx")
    inst.AnimState:PlayAnimation("single"..math.random(1,3),true)


	inst:AddTag("flying")
    inst:AddTag("NOCLICK")
    inst:AddTag("fx")
    --inst:AddTag("DELETE_ON_INTERIOR")
    inst.persists = false

    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 2
	inst.components.locomotor:SetTriggersCreep(false)

    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
    inst:DoTaskInTime(0,function() onspawn(inst) end)
	
	inst.OnEntitySleep = function() inst:Remove() end
   

    return inst
end


return Prefab( "common/objects/lifeplant", fn, assets, prefabs),
	   Prefab( "common/objects/lifeplant_sparkle", sparklefn, assets, prefabs)		
