require("brains/mosquitobrain")
require "stategraphs/SGglowfly"

local assets=
{
	Asset("ANIM", "anim/lantern_fly.zip"),	
	Asset("INV_IMAGE", "lantern_fly"),
}

local prefabs = 
{
	"mosquitosack",
	"mosquitosack_yellow",
}

local sounds =
{
	takeoff = "dontstarve/creatures/mosquito/mosquito_takeoff",
	attack = "dontstarve/creatures/mosquito/mosquito_attack",
	-- buzz = "dontstarve_DLC003/creatures/glowfly/buzz_LP",
	hit = "dontstarve_DLC003/creatures/glowfly/hit",
	death = "dontstarve_DLC003/creatures/glowfly/death",
	explode = "dontstarve/creatures/mosquito/mosquito_explo",
}

SetSharedLootTable( 'glowfly',
{
	{'lightbulb', .1},
})


SetSharedLootTable( 'glowflyinventory',
{
	{'lightbulb', 1},
})

local INTENSITY = .75

local SHARE_TARGET_DIST = 30
local MAX_TARGET_SHARES = 10


local function StopTrackingInSpawner(inst)
    local ground = GetWorld()
    if ground and ground.components.glowflyspawner then
        ground.components.glowflyspawner:StopTracking(inst)
    end
end

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
		inst.components.fader:Fade(INTENSITY, 0, .75+math.random()*1, function(v) inst.Light:SetIntensity(v) end, function() inst.Light:Enable(false) end)
	end
end

local function updatelight(inst)
    local ground = GetWorld()
    local x,y,z = GetPlayer().Transform:GetWorldPosition()
    local tile_type = ground.Map:GetTileAtPoint(x,y,z)
    if tile_type == GROUND.DEEPRAINFOREST or tile_type == GROUND.GASJUNGLE then 
        inst:AddTag("under_leaf_canopy")
    else
        inst:RemoveTag("under_leaf_canopy")
    end   

    if (GetClock():IsNight() or GetClock():IsDusk() or inst:HasTag("under_leaf_canopy")  ) and not inst.components.inventoryitem.owner then
        if not inst.lighton then
            fadein(inst)
        else
            inst.Light:Enable(true)
            inst.Light:SetIntensity(INTENSITY)
        end
        inst.lighton = true
    else
        if inst.lighton then
            fadeout(inst)
        else
            inst.Light:Enable(false)
            inst.Light:SetIntensity(0)
        end
        inst.lighton = false
    end
end

local function OnWorked(inst, worker)
	local owner = inst.components.homeseeker and inst.components.homeseeker.home
	if owner and owner.components.childspawner then
		owner.components.childspawner:OnChildKilled(inst)
	end
	StopTrackingInSpawner(inst)
	if METRICS_ENABLED and worker.components.inventory then
		FightStat_Caught(inst)	
	end
	if worker.components.inventory then
		worker.components.inventory:GiveItem(inst, nil, Vector3(TheSim:GetScreenPos(inst.Transform:GetWorldPosition())))	
	else		
		inst:Remove()
	end	
end

local function OnWake(inst)
	if not inst.components.inventoryitem:IsHeld() and not inst:HasTag("cocoon") then
		-- inst.SoundEmitter:PlaySound(inst.sounds.buzz, "buzz")
	end
	if inst.components.tiletracker then
		inst.components.tiletracker:Start()
	end	
end

local function OnSleep(inst)	
	inst.SoundEmitter:KillSound("buzz")
	
	if inst.components.tiletracker then
		inst.components.tiletracker:Stop()
	end	
end

local function OnDropped(inst)
	inst.sg:GoToState("idle")
	if inst.components.workable then
		inst.components.workable:SetWorkLeft(1)
	end
	if inst.brain then
		inst.brain:Start()
	end
	if inst.sg then
		inst.sg:Start()
	end
	if inst.components.stackable then
		while inst.components.stackable:StackSize() > 1 do
			local item = inst.components.stackable:Get()
			if item then
				if item.components.inventoryitem then
					item.components.inventoryitem:OnDropped()
				end
				item.Physics:Teleport(inst.Transform:GetWorldPosition() )
			end
		end
	end
end

local function OnPickedUp(inst)
	-- inst.SoundEmitter:KillSound("buzz")
	StopTrackingInSpawner(inst)
end

local function KillerRetarget(inst)
	local range = 20
	if GetSeasonManager() and (GetSeasonManager():IsSpring() or GetSeasonManager():IsGreenSeason()) then
		range = range * TUNING.SPRING_COMBAT_MOD
	end
	local notags = {"FX", "NOCLICK","INLIMBO", "insect"}
	local yestags = {"character", "animal", "monster"}
	return FindEntity(inst, range, function(guy)
		return inst.components.combat:CanTarget(guy)
	end, nil, notags, yestags)
end

local function OnAttacked(inst, data)
	inst.components.combat:SetTarget(data.attacker)
	local shareRange = SHARE_TARGET_DIST
	if GetSeasonManager() and (GetSeasonManager():IsSpring() or GetSeasonManager():IsGreenSeason()) then
		shareRange = shareRange * TUNING.SPRING_COMBAT_MOD
	end
	inst.components.combat:ShareTarget(data.attacker, shareRange, function(dude) return dude:HasTag("mosquito") and not dude.components.health:IsDead() end, MAX_TARGET_SHARES)
end

local function OnKilled(inst)
	StopTrackingInSpawner(inst)
    inst.components.fader:Fade(INTENSITY, 0, .75+math.random()*1, function(v) inst.Light:SetIntensity(v) end, function() inst.Light:Enable(false) end)
end

local function OnBorn(inst)	
	inst.components.fader:Fade(0, INTENSITY, .75+math.random()*1, function(v) inst.Light:SetIntensity(v) end)
end

local function OnWaterChange(inst, onwater)
	if onwater then
		inst.onwater = true
	else
		inst.onwater = false		
	end
end

local function OnEntityWake(inst)

	if not inst.components.inventoryitem:IsHeld() then
--		inst.SoundEmitter:PlaySound(inst.sounds.buzz, "buzz")
	end
	if inst.components.tiletracker then
		inst.components.tiletracker:Start()
	end	
end

local function OnEntitySleep(inst)
	-- inst.SoundEmitter:KillSound("buzz")
	
	if inst.components.tiletracker then
		inst.components.tiletracker:Stop()
	end	
end

local function checkRemoveGlowfly(inst)
	if not inst:HasTag("cocoonspawn") and inst:GetDistanceSqToInst(GetPlayer()) > 30*30 and not inst.components.inventoryitem:IsHeld() then
		print("REMOVING GLOWFLY, TOO FAR AWAY")
		inst:Remove()
	end
end
 
local function OnRemoveEntity(inst)
	StopTrackingInSpawner(inst)		
end

local function begincocoonstage(inst)
	inst:AddTag("wantstococoon")
end

local function onnear(inst)
	if inst:HasTag("readytohatch") then
		inst:DoTaskInTime(5+math.random()*3, function() inst:PushEvent("hatch") end)
	end
end

local function changetococoon(inst,forced)                        

 	inst:AddTag("cocoon")
 	inst:AddTag("cocoonspawn")
 	inst.components.inspectable.nameoverride = "glowfly_cocoon"
    --inst:SetPrefabName("glowfly_cocoon")
    inst.components.health:SetMaxHealth(TUNING.GLOWFLY_COCOON_HEALTH)
    inst.components.health:SetPercent(1)
    if not forced then
    	inst.sg:GoToState("cocoon_pre") 
	else
    	inst.sg:GoToState("idle")
    	inst.AnimState:SetTime(math.random()*2)
	end
	-- inst.SoundEmitter:KillSound("buzz")

	if not GetSeasonManager():IsTemperateSeason() then
        inst:AddTag("readytohatch")
        inst:AddComponent("playerprox")
        inst.components.playerprox:SetDist(30,31)
        inst.components.playerprox:SetOnPlayerNear(onnear)                          
    end
end

local function forceCocoon(inst)
	changetococoon(inst, true)	
end

local function inspect(inst)
	if inst.components.health:GetPercent() <= 0 then
    	return "DEAD"    
    elseif inst.components.sleeper:IsAsleep() then
    	return "SLEEPING"	
    end
end


local function setcocoontask(inst, time)
	if not time then
		time = math.random()*3
	end
	inst.cocoon_task, inst.cocoon_taskinfo = inst:ResumeTask(time, function() inst.begincocoonstage(inst) end ) --+ (math.random()*TUNING.SEG_TIME*2)
end

local function OnSave(inst, data)
	if inst.cocoon_task then
		data.cocoon_task = inst:TimeRemainingInTask(inst.cocoon_taskinfo)
	end
	if inst:HasTag("cocoon") then
		data.cocoon = true
	end
	if inst:HasTag("cocoonspawn") then
		data.cocoonspawn = true
	end	
	if inst.expiretaskinfo then
		data.expiretasktime = inst:TimeRemainingInTask(inst.expiretaskinfo)
	end
end

local function OnLoad(inst, data)
	if data then
		if data.cocoon_task then
			inst.setcocoontask(inst, data.cocoon_task)
		end
		if data.cocoon then
			forceCocoon(inst)
		end
		if data.cocoonspawn then
			inst:AddTag("cocoonspawn")
		end			
		if data.expiretasktime then					
			inst.expiretask, inst.expiretaskinfo = inst:ResumeTask(data.expiretasktime, function() inst.sg:GoToState("cocoon_expire") end)
		end
	end
end

local function TrackInSpawner(inst)
    local ground = GetWorld()
    if ground and ground.components.glowflyspawner then
        ground.components.glowflyspawner:StartTracking(inst)
    end
end

local function StopTrackingInSpawner(inst)
    local ground = GetWorld()
    if ground and ground.components.glowflyspawner then
        ground.components.glowflyspawner:StopTracking(inst)
    end
end

local function OnDropped(inst)
	inst.sg:GoToState("idle")
	if inst.components.workable then
		inst.components.workable:SetWorkLeft(1)
	end
	if inst.brain then
		inst.brain:Start()
	end
	if inst.sg then
		inst.sg:Start()
	end
	
	updatelight(inst)
	inst.components.lootdropper:SetChanceLootTable('glowfly')
    inst.sg:GoToState("idle")
    TrackInSpawner(inst)

	if inst.components.stackable then
		while inst.components.stackable:StackSize() > 1 do
			local item = inst.components.stackable:Get()
			if item then
				if item.components.inventoryitem then
					item.components.inventoryitem:OnDropped()
				end
				item.Physics:Teleport(inst.Transform:GetWorldPosition() )
			end
		end
	end
end

local function OnPickedUp(inst)
	inst.components.lootdropper:SetChanceLootTable('glowflyinventory')
    StopTrackingInSpawner(inst)
end

local function commonfn(Sim)
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddLightWatcher()
	inst.entity:AddDynamicShadow()
	inst.DynamicShadow:SetSize( .8, .5 )
    inst.Transform:SetSixFaced()

    inst.Transform:SetScale(0.6,0.6,0.6)    

	inst:SetBrain(require("brains/glowflybrain"))

	----------
	inst:AddTag("insect")
	inst:AddTag("flying")
	inst:AddTag("animal")
	inst:AddTag("smallcreature")
	inst:AddTag("glowfly")
	
	MakeAmphibiousCharacterPhysics(inst, 1, .5)
	inst.Physics:SetCollisionGroup(COLLISION.FLYERS)
	inst.Physics:CollidesWith(COLLISION.FLYERS)

	inst.AnimState:SetBank("lantern_fly")
	inst.AnimState:SetBuild("lantern_fly")
	inst.AnimState:PlayAnimation("idle")
	inst.AnimState:SetRayTestOnBB(true);

	inst:AddComponent("tiletracker")
	inst.components.tiletracker:SetOnWaterChangeFn(OnWaterChange)

    inst:AddComponent("fader")
	local light = inst.entity:AddLight()
    light:SetFalloff(.7)
    light:SetIntensity(INTENSITY)
    light:SetRadius(2)
    light:SetColour(120/255, 120/255, 120/255)
    light:Enable(false)

	inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
	inst.components.locomotor:EnableGroundSpeedMultiplier(false)
	inst.components.locomotor:SetTriggersCreep(false)
	inst.components.locomotor.walkspeed = 6
	inst.components.locomotor.runspeed = 8
	inst:SetStateGraph("SGglowfly")

	inst.sounds = sounds

	inst.OnEntityWake = OnEntityWake
	inst.OnEntitySleep = OnEntitySleep    

	inst.OnRemoveEntity = OnRemoveEntity

	inst.OnBorn = OnBorn

	inst:AddComponent("inventoryitem")
	
	inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
	inst.components.inventoryitem:SetOnPutInInventoryFn(OnPickedUp)
	inst.components.inventoryitem.canbepickedup = false
	inst.components.inventoryitem:ChangeImageName("lantern_fly")

	---------------------

	inst:AddComponent("pollinator")

	---------------------

	inst:AddComponent("lootdropper")

	inst:AddComponent("tradable")
	inst:AddTag("cattoyairborne")

	 ------------------
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.NET)
	inst.components.workable:SetWorkLeft(1)
	inst.components.workable:SetOnFinishCallback(OnWorked)

	MakeSmallBurnableCharacter(inst, "upper_body", Vector3(0, -1, 1))
	MakeTinyFreezableCharacter(inst, "upper_body", Vector3(0, -1, 1))

	------------------
	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(1)

	------------------
	inst:AddComponent("combat")
	inst.components.combat.hiteffectsymbol = "body"

	------------------
	inst:AddComponent("sleeper")
	inst.components.sleeper.onlysleepsfromitems = true

	------------------
	inst:AddComponent("knownlocations")

	------------------    
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = inspect

	inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("death", OnKilled)


    inst:ListenForEvent( "daytime", function()
        inst:DoTaskInTime(2+math.random()*1, function() updatelight(inst) end)
    end, GetWorld())
    inst:ListenForEvent( "nighttime", function()
        inst:DoTaskInTime(2+math.random()*1, function() updatelight(inst) end)
    end, GetWorld())
    inst:ListenForEvent( "dusktime", function()
        inst:DoTaskInTime(2+math.random()*1, function() updatelight(inst) end)
    end, GetWorld())    
    inst:ListenForEvent( "onchangecanopyzone", function()
        inst:DoTaskInTime(2+math.random()*1, function() updatelight(inst) end)
    end)

    inst:ListenForEvent( "seasonChange", function(it,data)
    	if data.season ~= SEASONS.HUMID then -- data.season == SEASONS.LUSH 
	   		inst.expiretask, inst.expiretaskinfo = inst:ResumeTask(2* TUNING.SEG_TIME + math.random()*3, function() inst.sg:GoToState("cocoon_expire") end)
	   	else
   			inst:AddTag("readytohatch")
			if not inst.components.playerprox then
				inst:AddComponent("playerprox")
			end
		    inst.components.playerprox:SetDist(30,31)
		    inst.components.playerprox:SetOnPlayerNear(onnear)       			
   		end
    end, GetWorld())


    inst.begincocoonstage = begincocoonstage
    inst.forceCocoon = forceCocoon
    inst.changetococoon = changetococoon
    inst.setcocoontask = setcocoontask 

	inst.OnSave = OnSave
	inst.OnLoad = OnLoad

	inst:DoTaskInTime(0,updatelight)

	--inst:DoTaskInTime(5, beginbeetlestage)
	inst:DoPeriodicTask(5, checkRemoveGlowfly, math.random() * 5)

	return inst
end

local function glowflyfn(sim)
	local inst = commonfn(sim)
	MakePoisonableCharacter(inst)
	inst.components.lootdropper:SetChanceLootTable('glowfly')	
	return inst 
end 

function CleanUpGlowFlies()
	-- one time cleanup of surplus glowflies.
	if GetWorld().culledGlowFlies then
		return 
	end
	print("Cleaning up suprlus glowflies")
	local glowflies = {}
	for i,v in pairs(Ents) do
		if v.prefab == "glowfly" and not v:IsInLimbo() then
			table.insert(glowflies, v)
		end
	end
	local overage = #glowflies - 800
	if overage > 0 then
		glowflies = shuffleArray(glowflies)
		for i=1, overage do
			glowflies[i]:Remove()
		end
		print(string.format("Removed %d surplus glowflies",overage))
	end
	GetWorld().culledGlowFlies = true
end

return Prefab( "forest/monsters/glowfly", glowflyfn, assets, prefabs)
