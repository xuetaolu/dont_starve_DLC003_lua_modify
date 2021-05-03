require "stategraphs/SGcrab"

local assets=
{
	Asset("ANIM", "anim/crabbit_build.zip"),
	Asset("ANIM", "anim/crabbit_beardling_build.zip"),
	Asset("ANIM", "anim/beardling_crabbit.zip"),

	Asset("ANIM", "anim/crabbit.zip"),
	--Asset("ANIM", "anim/crab_basic.zip"),
	--Asset("ANIM", "anim/crab_build.zip"),

	Asset("SOUND", "sound/dontstarve_shipwreckedSFX.fsb"),
	Asset("INV_IMAGE", "crabbit_beardling"),
	
}

local prefabs =
{
    "fish_raw_small",
    "fish_raw_small_cooked",
    "beardhair",
}

local crabbitsounds = 
{
    scream = "dontstarve_DLC002/creatures/crab/scream",
    hurt = "dontstarve_DLC002/creatures/crab/scream_short",
}

local beardsounds = 
{
    scream = "dontstarve_DLC002/creatures/crab/bearded_crab",
    hurt = "dontstarve_DLC002/creatures/crab/scream_short",
}


local brain = require "brains/crabbrain"

local function BecomeRabbit(inst)
	if not inst.iscrab then
		inst.AnimState:SetBuild("crabbit_build")
	    inst.components.lootdropper:SetLoot({"fish_raw_small"})
	    inst.iscrab = true
	    inst.components.sanityaura.aura = 0
		inst.components.inventoryitem:ChangeImageName("crab")
		inst.sounds = crabbitsounds
	end
end

local function BecomeBeardling(inst)
	if inst.iscrab then
		inst.AnimState:SetBuild("crabbit_beardling_build")
	    inst.components.lootdropper:SetLoot{}
		inst.components.lootdropper:AddRandomLoot("beardhair", .5)	    
		inst.components.lootdropper:AddRandomLoot("monstermeat", 1)	    
		inst.components.lootdropper:AddRandomLoot("nightmarefuel", 1)	  
		inst.components.lootdropper.numrandomloot = 1
		inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED		
	    inst.iscrab = false
	    inst.components.inventoryitem:ChangeImageName("crabbit_beardling")
		inst.sounds = beardsounds
	end
end

local function CheckTransformState(inst)
	if not inst.components.health:IsDead() then
		local player = GetPlayer()
		if player.components.sanity:GetPercent() > TUNING.BEARDLING_SANITY then
			BecomeRabbit(inst)
		else
			BecomeBeardling(inst)			
		end
	end
end

local function ondrop(inst)
	inst.sg:GoToState("stunned")
	CheckTransformState(inst)
end

local function OnWake(inst)
	CheckTransformState(inst)
	inst.checktask = inst:DoPeriodicTask(10, CheckTransformState)
end

local function OnSleep(inst)
	if inst.checktask then
		inst.checktask:Cancel()
		inst.checktask = nil
	end
	if not GetClock():IsDay() and inst.components.homeseeker then
		inst.components.homeseeker:ForceGoHome()
	end
end

local function StartDusk(inst)
	if inst:IsAsleep() and inst.components.homeseeker then
		inst.components.homeseeker:ForceGoHome()
	end
end

local function GetCookProductFn(inst)
	if inst.iscrab then
		return "fish_raw_small_cooked" 
	else 
		return "cookedmonstermeat"
	end
end

local function OnCookedFn(inst)
	inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/crab/scream_short")
end

local function OnAttacked(inst, data)
    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, 30, {'crab'})
    
    local num_friends = 0
    local maxnum = 5
    for k,v in pairs(ents) do
        v:PushEvent("gohome")
        num_friends = num_friends + 1
        
        if num_friends > maxnum then
            break
        end
    end
end

local function OnDug(inst, worker)
	local rnd = math.random()
	local home = inst.components.homeseeker and inst.components.homeseeker.home
	if rnd >= 0.66 or not home then
		--Sometimes just go to stunned state

		inst:PushEvent("stunned")
	else
		--Sometimes return home instantly?
		worker:DoTaskInTime(1, function()
			worker:PushEvent("crab_fail")
		end)

		inst.components.lootdropper:SpawnLootPrefab("sand")
		local home = inst.components.homeseeker.home
		home.components.spawner:GoHome(inst)
	end
end

local function DisplayName(inst)
    if inst.sg:HasStateTag("invisible") then
        return STRINGS.NAMES.CRAB_HIDDEN
    end
    return STRINGS.NAMES.CRAB
end

local function getstatus(inst)
    if inst.sg:HasStateTag("invisible") then 
        return "HIDDEN"
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local physics = inst.entity:AddPhysics()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 1.5, .5 )
    inst.Transform:SetFourFaced()

    MakeCharacterPhysics(inst, 1, 0.5)
    MakePoisonableCharacter(inst)

    anim:SetBank("crabbit")
    anim:SetBuild("crabbit_build")
    anim:PlayAnimation("idle")
    
    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = TUNING.CRAB_RUN_SPEED
    inst.components.locomotor.walkspeed = TUNING.CRAB_WALK_SPEED
    inst:SetStateGraph("SGcrab")

    inst:AddTag("animal")
    inst:AddTag("prey")
    inst:AddTag("rabbit")
    inst:AddTag("smallcreature")
    inst:AddTag("canbetrapped")    

    inst:SetBrain(brain)
    
    inst.data = {}
    
    inst:AddComponent("eater")
    inst.components.eater.foodprefs = { "MEAT", "VEGGIE", "INSECT" }
    inst.components.eater.ablefoods = { "MEAT", "VEGGIE", "INSECT" }

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.nobounce = true
	inst.components.inventoryitem.canbepickedup = false
	--inst.components.inventoryitem:SetOnDroppedFn(ondrop) Done in MakeFeedablePet
	inst:AddComponent("sanityaura")

    inst:AddComponent("cookable")
    inst.components.cookable.product = GetCookProductFn
    inst.components.cookable:SetOnCookedFn(OnCookedFn)
    
    inst:AddComponent("knownlocations")
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "chest"
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.CRAB_HEALTH)
    inst.components.health.murdersound = "dontstarve_DLC002/creatures/crab/scream_short"

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable.workable = false
    inst.components.workable:SetOnFinishCallback(OnDug)

    MakeSmallBurnableCharacter(inst, "chest")
    MakeTinyFreezableCharacter(inst, "chest")

    inst:AddComponent("lootdropper")

    inst:AddComponent("tradable")
    inst:AddTag("cattoy")
    inst:AddTag("catfood")
    
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus
    inst:AddComponent("sleeper")

	inst:AddComponent("appeasement")
	inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_MEDIUM

	BecomeRabbit(inst)
    CheckTransformState(inst)
    inst.CheckTransformState = CheckTransformState
	
	inst.OnEntityWake = OnWake
	inst.OnEntitySleep = OnSleep
	inst:ListenForEvent( "dusktime", function() StartDusk( inst ) end, GetWorld())
    
    inst.OnSave = function(inst, data)
		data.iscrab = inst.iscrab
    end        
    
    inst.OnLoad = function(inst, data)
        if data then
			if not data.iscrab then
				BecomeBeardling(inst)
	        end
	    end 
    end

    inst.displaynamefn = DisplayName

    inst:ListenForEvent("attacked", OnAttacked)

    MakeFeedablePet(inst, TUNING.TOTAL_DAY_TIME*2, nil, ondrop)

    return inst
end

return Prefab( "forest/animals/crab", fn, assets, prefabs) 
