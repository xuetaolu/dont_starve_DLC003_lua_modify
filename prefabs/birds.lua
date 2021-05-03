--[[
birds.lua

Different birds are just reskins of crow without any special powers at the moment.
To make a new bird add it at the bottom of the file as a 'makebird(name)' call

This assumes the bird already has a build, inventory icon, sounds and a feather_name prefab exists

]]--
require "brains/birdbrain"
require "stategraphs/SGbird"

local function TrackInSpawner(inst)
	local ground = GetWorld()
	if ground and ground.components.birdspawner then
		ground.components.birdspawner:StartTracking(inst)
	end
end

local function StopTrackingInSpawner(inst)
	local ground = GetWorld()
	if ground and ground.components.birdspawner then
		ground.components.birdspawner:StopTracking(inst)
	end
end

local function ShouldSleep(inst)
	return DefaultSleepTest(inst) and not inst.sg:HasStateTag("flying")
end

local function ondrop(inst)
	if inst:GetIsOnWater() then
		if inst:HasTag("aquatic") then
			inst.AnimState:SetBank("seagull_water")
		end		
		inst.sg:GoToState("flyaway")		
	else
		if inst:HasTag("aquatic") then
			inst.AnimState:SetBank("seagull")
		end
		inst.sg:GoToState("stunned")
	end
end

local function inspect_bird(inst)
    if inst:HasTag("cormorant") then
        return "CORMORANT"
    end
end

local function OnAttacked(inst, data)
	local x,y,z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x,y,z, 30, {'bird'})

	local num_friends = 0
	local maxnum = 5
	for k,v in pairs(ents) do
		if v ~= inst then
			v:PushEvent("gohome")
			num_friends = num_friends + 1
		end

		if num_friends > maxnum then
			break
		end

	end
end

local function seedspawntest(inst)
	local ground = GetWorld()
	local onwater = false
	local isWinter = GetWorld().components.seasonmanager:IsWinter()
	if ground and ground.components.birdspawner then
		local x, y, z = inst.Transform:GetWorldPosition()
		local ground = GetWorld()
		local tile = ground.Map:GetTileAtPoint(x, y, z)
		onwater = ground.components.birdspawner:IsWaterTileType(tile)
	end
	return not (onwater or isWinter)
end

local function makebirdex(name, feathername, takeoff_soundname, chirp_soundname, land_sound, takeoff2_soundname)

	local featherpostfix = feathername or name

	local assets
	if name == "seagull" then
		assets =
		{
			Asset("ANIM", "anim/seagull.zip"),
			Asset("ANIM", "anim/seagull_build.zip"),
			Asset("SOUND", "sound/birds.fsb"),
		}
	elseif name == "seagull_water" then
		assets =
		{
			Asset("ANIM", "anim/seagull_water.zip"),
			Asset("ANIM", "anim/seagull_build.zip"),
			Asset("ANIM", "anim/cormorant_build.zip"),
			Asset("ANIM", "anim/cormorant_water.zip"),
			Asset("SOUND", "sound/birds.fsb"),
			Asset("INV_IMAGE", "cormorant"),
			Asset("INV_IMAGE", "seagull"),			
		}
	elseif name == "parrot" or name == "parrot_pirate" then
		assets =
		{
			Asset("ANIM", "anim/crow.zip"),
			Asset("ANIM", "anim/parrot_pirate.zip"),
			Asset("ANIM", "anim/parrot_build.zip"),
			Asset("ANIM", "anim/parrot_pirate_build.zip"),
			Asset("SOUND", "sound/birds.fsb"),
			Asset("INV_IMAGE", "parrot_pirate"),
		}
	elseif name == "parrot_blue" then
		assets =
		{
			Asset("ANIM", "anim/crow.zip"),
			Asset("ANIM", "anim/parrot_blue_build.zip"),
			Asset("SOUND", "sound/birds.fsb"),
			Asset("INV_IMAGE", "parrot_pirate"),
		}		
	elseif name == "kingfisher" then
		assets =
		{
			Asset("ANIM", "anim/crow.zip"),
			Asset("ANIM", "anim/kingfisher_build.zip"),
			Asset("SOUND", "sound/birds.fsb"),
			Asset("INV_IMAGE", "parrot_pirate"),
		}		
	elseif name == "pigeon" then
		assets =
		{
			Asset("ANIM", "anim/crow.zip"),
			Asset("ANIM", "anim/pigeon_build.zip"),
			Asset("SOUND", "sound/birds.fsb"),
			Asset("INV_IMAGE", "parrot_pirate"),
		}		
	else
		assets =
		{
			Asset("ANIM", "anim/crow.zip"),
			Asset("ANIM", "anim/"..name.."_build.zip"),
			Asset("ANIM", "anim/"..name.."_build.zip"),
			Asset("SOUND", "sound/birds.fsb"),
		}
	end

	local prefabs =
	{
		"seeds",
		"smallmeat",
		"cookedsmallmeat",
		"feather_"..featherpostfix,
		"feather_crow",
	}

	local sounds =
	{
		takeoff = takeoff_soundname,
		takeoff2 = takeoff2_soundname,
		chirp = chirp_soundname,
		flyin = "dontstarve/birds/flyin",
		land = land_sound,
	}

	local cormorantsounds =
	{
		takeoff = "dontstarve_DLC002/creatures/cormorant/takeoff",
		chirp = "dontstarve_DLC002/creatures/cormorant/chirp",
		flyin = "dontstarve/birds/flyin",
		land = "dontstarve_DLC002/creatures/cormorant/landwater",
	}

	local function OnTrapped(inst, data)
		if data and data.trapper and data.trapper.settrapsymbols then
			data.trapper.settrapsymbols(name.."_build")
		end
	end


	local function canbeattacked(inst, attacked)
		return not inst.sg:HasStateTag("flying")
	end

	local function setSeaBird(inst,birdtype)

		local featherloot = "feather_robin_winter"	

		if birdtype == "cormorant" then			
			inst.AnimState:SetBank("cormorant_water")
			inst.AnimState:SetBuild("cormorant_build")
			
			inst:AddTag("cormorant")
			inst.cormorant = true
			inst.seagull = nil			
			inst.sounds = cormorantsounds
			inst:SetPrefabNameOverride("cormorant")		
			inst.Transform:SetScale(0.85, 0.85, 0.85)	
			featherloot = "feather_crow"					
			inst.trappedbuild = "cormorant_build"
			inst.components.inventoryitem:ChangeImageName("cormorant")
		elseif birdtype == "seagull" then
			inst.AnimState:SetBank("seagull_water")
			inst.AnimState:SetBuild("seagull_build")	
			
			inst:RemoveTag("cormorant")
			inst.cormorant = nil
			inst.seagull = true
			inst.sounds = sounds
			inst:SetPrefabNameOverride("seagull")		
			inst.Transform:SetScale(1,1,1)	
			featherloot = "feather_robin_winter"					
			inst.trappedbuild = "seagull_build"			
			inst.components.inventoryitem:ChangeImageName("seagull")		
		end
		inst.components.lootdropper.randomloot = {}
		inst.components.lootdropper.totalrandomweight = 0
		inst.components.lootdropper:AddRandomLoot(featherloot, 1)
		inst.components.lootdropper:AddRandomLoot("smallmeat", 1)
		inst.components.lootdropper.numrandomloot = 1		

		return featherloot
	end

	local function OnLoad(inst,data)
	    if not data then
	        return
	    end
	    
		if data.cormorant then
			setSeaBird(inst,"cormorant")
		end
	    
		if data.seagull then
			setSeaBird(inst,"seagull")
		end		
	end

	local function OnSave(inst,data)
	    data.cormorant = inst.cormorant 
	    data.seagull = inst.seagull 
	end


	local function fn()
		-- randomly make this a dubloon dropping named parrot
		local namedParrot = (name == "parrot_pirate")

		local inst = CreateEntity()
		local trans = inst.entity:AddTransform()
		local anim = inst.entity:AddAnimState()
		local sound = inst.entity:AddSoundEmitter()

		inst.sounds = sounds
		inst.entity:AddPhysics()
		inst.Transform:SetTwoFaced()
		local shadow = inst.entity:AddDynamicShadow()
		shadow:SetSize( 1, .75 )
		shadow:Enable(false)

		inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
		inst.Physics:ClearCollisionMask()
		inst.Physics:CollidesWith(COLLISION.GROUND)
		inst.Physics:CollidesWith(COLLISION.INTWALL)
		inst.Physics:SetSphere(1)
		inst.Physics:SetMass(1)

		MakeInventoryFloatable(inst, "takeoff_diagonal_pre", "stunned_loop")

		MakePoisonableCharacter(inst)
		inst.components.poisonable.damge_per_interval = TUNING.POISON_DAMAGE_PER_INTERVAL*50

		inst:AddTag("bird")
		if name == "seagull_water" then
			inst:AddTag("seagull")
			inst:AddTag("aquatic")
		else
			inst:AddTag(name)
		end
		inst:AddTag("smallcreature")

		inst:AddComponent("inspectable")
		inst.components.inspectable.getstatus = inspect_bird

		local featherloot = "feather_"..featherpostfix

		if string.find(name, "seagull") then
			anim:SetBuild("seagull_build")
			anim:SetBank("seagull")
			--inst.trappedbuild = "seagull_build"

			if name == "seagull_water" then
				-- alternate seagull_water skin
				if math.random() < 0.4 then			
					inst.cormorant = true
					inst.trappedbuild = "cormorant_build"
				else
					inst.seagull = true
					inst.trappedbuild = "seagull_build"
				end
			else
				inst.trappedbuild = name.."_build"
			end
		else
			anim:SetBank("crow")
			if namedParrot then
				anim:SetBuild("parrot_pirate_build")
			else
				anim:SetBuild(name.."_build")
			end
			inst.trappedbuild = name.."_build"
		end
		

		anim:PlayAnimation("idle")

		inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
		inst.components.locomotor:EnableGroundSpeedMultiplier(false)
		inst.components.locomotor:SetTriggersCreep(false)
		inst:SetStateGraph("SGbird")

		inst:AddComponent("lootdropper")
		inst.components.lootdropper:AddRandomLoot(featherloot, 1)
		inst.components.lootdropper:AddRandomLoot("smallmeat", 1)
		inst.components.lootdropper.numrandomloot = 1

		inst:AddComponent("occupier")

		inst:AddComponent("eater")
		if string.find(name, "seagull") then			
    		inst.components.eater:SetOmnivore()
			inst.components.eater:SetCanEatTestFn(function(inst)
				-- seagulls shall not eat hydrofarm objects				
				return (inst:HasTag("hydrofarm") == false)
			end)
    	elseif name == "kingfisher" then
    		inst.components.eater.foodprefs = {"SEEDS","MEAT"}
    		inst.components.eater.ablefoods = {"SEEDS","MEAT"}
    	else
			inst.components.eater:SetBird()
		end

		inst:AddComponent("sleeper")
		inst.components.sleeper:SetSleepTest(ShouldSleep)

		inst:AddComponent("inventoryitem")
		inst.components.inventoryitem.nobounce = true
		inst.components.inventoryitem.canbepickedup = false
		--inst.components.inventoryitem:SetOnDroppedFn(ondrop) -- done in MakeFeedablePet

		inst:AddComponent("cookable")
		inst.components.cookable.product = "cookedsmallmeat"

	  	inst:AddComponent("appeasement")
    	inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_MEDIUM


		inst:AddComponent("combat")
		inst.components.combat.hiteffectsymbol = "crow_body"
		inst.components.combat.canbeattackedfn = canbeattacked
		inst:AddComponent("health")
		inst.components.health:SetMaxHealth(TUNING.BIRD_HEALTH)
		inst.components.health.murdersound = "dontstarve/wilson/hit_animal"

		if namedParrot then
			inst.components.inspectable.nameoverride = "PARROT"
			inst:AddComponent("named")
			inst.components.named.possiblenames = STRINGS.PARROTNAMES
			inst.components.named:PickNewName()
			inst.components.health.canmurder = false

			inst:AddComponent("talker")
			inst.components.talker.fontsize = 28
		    inst.components.talker.font = TALKINGFONT
		    inst.components.talker.colour = Vector3(.9, .4, .4, 1)
		    inst:ListenForEvent("donetalking", function() inst.SoundEmitter:KillSound("talk") end)
		    inst:ListenForEvent("ontalk", function()
		    	inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/parrot/chirp", "talk")
			end)

			inst:AddComponent("talkingbird")

			inst:AddComponent("sanityaura")
			inst.components.sanityaura.aura = TUNING.SANITYAURA_SMALL
		end


		local brain = require "brains/birdbrain"
		inst:SetBrain(brain)

		MakeSmallBurnableCharacter(inst, "crow_body")
		MakeTinyFreezableCharacter(inst, "crow_body")

		inst:AddComponent("periodicspawner")
		if namedParrot then
			inst.components.periodicspawner:SetPrefab("dubloon")
		elseif inst.cormorant then --name == "seagull_water" or name == "seagull" and			
			inst.components.periodicspawner:SetPrefab("roe")	
			inst.components.periodicspawner.onlanding = true

		elseif name == "kingfisher" and math.random() < 0.1 then
			inst.components.periodicspawner:SetPrefab("fish")
			inst.components.periodicspawner.onlanding = true
		else
			inst.components.periodicspawner:SetPrefab("seeds")
		end
		inst.components.periodicspawner:SetDensityInRange(20, 2)
		inst.components.periodicspawner:SetMinimumSpacing(8)
		--inst.components.periodicspawner:SetSpawnTestFn( seedspawntest )

		inst.TrackInSpawner = TrackInSpawner

		inst:ListenForEvent("ontrapped", OnTrapped)
		inst:ListenForEvent("onremove", StopTrackingInSpawner)
		inst:ListenForEvent("enterlimbo", StopTrackingInSpawner)
		inst:ListenForEvent("attacked", OnAttacked)

		MakeFeedablePet(inst, TUNING.TOTAL_DAY_TIME*2, nil, ondrop)

		if inst.seagull then
			setSeaBird(inst,"seagull")
		end

		if inst.cormorant then
			setSeaBird(inst,"cormorant")
		end
		

        inst.OnSave = OnSave
        inst.OnLoad = OnLoad

		return inst
	end

	return Prefab("forest/animals/"..name, fn, assets, prefabs)
end

local function makebird(name, soundname, feathername)
	return makebirdex(name, feathername, "dontstarve/birds/takeoff_"..soundname, "dontstarve/birds/chirp_"..soundname)
end

return makebird("crow", "crow"),	
   	   makebird("robin", "robin"),
	   makebird("robin_winter", "junco"),
	   makebirdex("parrot", "robin", "dontstarve_DLC002/creatures/parrot/takeoff", "dontstarve_DLC002/creatures/parrot/chirp"),
	   makebirdex("parrot_pirate", "robin", "dontstarve_DLC002/creatures/parrot/takeoff", "dontstarve_DLC002/creatures/parrot/chirp"),
	   makebirdex("toucan", "crow", "dontstarve_DLC002/creatures/toucan/takeoff", "dontstarve_DLC002/creatures/toucan/chirp"),
	   makebirdex("seagull","robin_winter", "dontstarve_DLC002/creatures/seagull/takeoff_seagull", "dontstarve_DLC002/creatures/seagull/chirp_seagull"),
	   makebirdex("seagull_water", "robin_winter", "dontstarve_DLC002/creatures/seagull/takeoff_seagull", "dontstarve_DLC002/creatures/seagull/chirp_seagull","dontstarve_DLC002/creatures/seagull/landwater"),
	   makebirdex("pigeon", "robin_winter", "dontstarve_DLC003/creatures/pigeon/takeoff", "dontstarve_DLC003/creatures/pigeon/chirp"),
	   makebirdex("parrot_blue", "robin", "dontstarve_DLC002/creatures/parrot/takeoff", "dontstarve_DLC002/creatures/parrot/chirp"),
	   makebirdex("kingfisher", "robin_winter", "dontstarve/birds/takeoff_faster", "dontstarve_DLC003/creatures/king_fisher/chirp",nil,"dontstarve_DLC003/creatures/king_fisher/take_off")	   
