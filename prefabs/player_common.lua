local easing = require("easing")
require "stategraphs/SGwilson"
require "stategraphs/SGwilsonboating"

local function OnSane(inst)
	print ("SANE!")
end

local function OnInsane(inst)
	inst.SoundEmitter:PlaySound("dontstarve/sanity/gonecrazy_stinger")
end

local function DropItem(inst, target, item)
	inst.components.inventory:Unequip(EQUIPSLOTS.HANDS, true)
	inst.components.inventory:DropItem(item)
	if item.Physics then

		local x, y, z = item:GetPosition():Get()
		y = .3
		item.Physics:Teleport(x,y,z)

		local hp = target:GetPosition()
		local pt = inst:GetPosition()
		local vel = (hp - pt):GetNormalized()
		local speed = 3 + (math.random() * 2)
		local angle = -math.atan2(vel.z, vel.x) + (math.random() * 20 - 10) * DEGREES
		item.Physics:SetVel(math.cos(angle) * speed, 10, math.sin(angle) * speed)
		inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_TOOL_SLIP"))
	end
end

local function OnWork(inst, data)
	--Tool slip.
	local m = inst.components.moisture

	if m:GetSegs() < 4 then
		return
	end

	local mm = GetWorld().components.moisturemanager
	local tool = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if tool and mm:IsEntityWet(tool) and math.random() < easing.inSine(m:GetMoisture(), 0, 0.15, m.moistureclamp.max)  then
		if not tool:HasTag("notslippery") then
			DropItem(inst, data.target, tool)
			--Lock out from picking up for a while?
		end
	end
end

local function OnAttack(inst, data)
	if not data.weapon then return end
	--Tool slip.
	local m = inst.components.moisture

	if m:GetSegs() < 4 then
		return
	end

	local mm = GetWorld().components.moisturemanager
	local weapon = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if weapon and mm:IsEntityWet(weapon) and math.random() < easing.inSine(m:GetMoisture(), 0, 0.15, m.moistureclamp.max)  then
		if not weapon:HasTag("notslippery") then
			DropItem(inst, data.target, weapon)
			--Lock out from picking up for a while?
		end
	end
end


local function IsPoisonDisabled()
	local world = GetWorld()
	return world and world.components.globalsettings and world.components.globalsettings.settings.poisondisabled and world.components.globalsettings.settings.poisondisabled == true
end

local function BeginGas(inst)
	if inst.gasTask == nil then
		inst.gasTask = inst:DoPeriodicTask(TUNING.GAS_INTERVAL,
			function()				
				local player = GetPlayer()

				local safe = false
				-- check armour
				if player.components.inventory then
					for k,v in pairs (player.components.inventory.equipslots) do
						if v.components.equippable and v.components.equippable:IsPoisonGasBlocker() then
							safe = true
						end		
					end
				end

				if player:HasTag("has_gasmask") then
					safe = true
				end

				if IsPoisonDisabled() then
					safe = true
				end
				
				if not safe then
					player.components.health:DoGasDamage(TUNING.GAS_DAMAGE_PER_INTERVAL)			
					player:PushEvent("poisondamage")	
					player.components.talker:Say(GetString(player.prefab, "ANNOUNCE_GAS_DAMAGE"))
				end
			end)
	end
end

local function EndGas(inst)
	if inst.gasTask then
		inst.gasTask:Cancel()
		inst.gasTask = nil
	end
end

local function OnGasChange(inst, onGas)
	if not inst.gassources then
		inst.gassources = 0
	end

	if onGas then
		inst.gassources = inst.gassources +1	
		if inst.gassources > 0 and not inst.gasTask then
			BeginGas(inst)
		end
	else
		inst.gassources = math.max(0,inst.gassources - 1)
		if inst.gassources < 1 then
			EndGas(inst)
		end
	end
end

local function OnTileChange(inst, tile, tileInfo)
end

local function giveupstring(combat, target)
	local str = ""
	if target and target:HasTag("prey") then
		str = GetString(combat.inst.prefab, "COMBAT_QUIT", "prey")
	else
		str = GetString(combat.inst.prefab, "COMBAT_QUIT")
	end
	return str
end

local function addlevelspecificcomponents(inst, levelprefab)
	if levelprefab == "shipwrecked" then
		inst:AddComponent("mapwrapper")
		inst:AddComponent("ballphinfriend")
	end

	if not (levelprefab == "shipwrecked" or levelprefab == "volcanolevel") then
		if not Profile:IsCharacterUnlocked("webber") then
			inst:AddComponent("globalloot")
			inst.components.globalloot:AddGlobalLoot({
				loot = "webberskull",
				dropchance = 0.05,
				candropfn = function()
					return not TheSim:FindFirstEntityWithTag("webberskull") and not
					Profile:IsCharacterUnlocked("webber")
				end,
				droppers =
				{
					"spider",
					"spider_warrior",
					"spiderqueen",
					"spider_hider",
					"spider_dropper",
					"spider_spitter",
					"spiderden",
					"spiderden_2",
					"spiderden_3",
					"spiderhole",
				},
			})
		end
	end
end

local TALLER_FROSTYBREATHER_OFFSET = Vector3(.3, 3.75, 0)
local DEFAULT_FROSTYBREATHER_OFFSET = Vector3(.3, 1.15, 0)
local function GetFrostyBreatherOffset(inst)
    local rider = inst.components.rider
    return rider and rider:IsRiding()
        and TALLER_FROSTYBREATHER_OFFSET
        or DEFAULT_FROSTYBREATHER_OFFSET
end

local function MakePlayerCharacter(name, customprefabs, customassets, customfn, starting_inventory)

	local font = TALKINGFONT
	local fontsize = 28
	local assets =
	{
		Asset("ANIM", "anim/player_basic.zip"),
		Asset("ANIM", "anim/player_idles_shiver.zip"),
		Asset("ANIM", "anim/player_actions.zip"),
		Asset("ANIM", "anim/player_actions_axe.zip"),
		Asset("ANIM", "anim/player_actions_pickaxe.zip"),
		Asset("ANIM", "anim/player_actions_shovel.zip"),
		Asset("ANIM", "anim/player_actions_blowdart.zip"),
		Asset("ANIM", "anim/player_actions_speargun.zip"),
		Asset("ANIM", "anim/player_actions_shear.zip"),
		Asset("ANIM", "anim/player_actions_hand_lens.zip"),
		Asset("ANIM", "anim/player_actions_panning.zip"),
		--Asset("ANIM", "anim/player_actions_machete.zip"), --This file overwrites the axe actions file and is broken...
		Asset("ANIM", "anim/player_actions_eat.zip"),
		Asset("ANIM", "anim/player_actions_item.zip"),
		Asset("ANIM", "anim/player_actions_paddle.zip"),
		Asset("ANIM", "anim/player_cave_enter.zip"),
		Asset("ANIM", "anim/player_actions_uniqueitem.zip"),
		Asset("ANIM", "anim/book_uniqueitem_swap.zip"),
		Asset("ANIM", "anim/player_actions_bugnet.zip"),
		Asset("ANIM", "anim/player_actions_fishing.zip"),
		Asset("ANIM", "anim/player_actions_boomerang.zip"),
		Asset("ANIM", "anim/player_bush_hat.zip"),
		Asset("ANIM", "anim/player_attacks.zip"),
		Asset("ANIM", "anim/player_idles.zip"),
		Asset("ANIM", "anim/player_rebirth.zip"),
		Asset("ANIM", "anim/player_jump.zip"),
		Asset("ANIM", "anim/player_amulet_resurrect.zip"),
		Asset("ANIM", "anim/player_teleport.zip"),
		Asset("ANIM", "anim/wilson_fx.zip"),
		Asset("ANIM", "anim/player_one_man_band.zip"),
		Asset("ANIM", "anim/player_slurtle_armor.zip"),
		Asset("ANIM", "anim/player_staff.zip"),
		Asset("ANIM", "anim/player_boat_onoff.zip"),
		Asset("ANIM", "anim/player_boat_death.zip"),
		Asset("ANIM", "anim/player_actions_trawl.zip"),
		Asset("ANIM", "anim/player_actions_twister.zip"),
		Asset("ANIM", "anim/player_actions_bucked.zip"),
		Asset("ANIM", "anim/player_pistol.zip"),

		Asset("ANIM", "anim/player_teleport_bfb.zip"),
		Asset("ANIM", "anim/player_teleport_bfb2.zip"),

		Asset("ANIM", "anim/player_sneeze.zip"),
		Asset("ANIM", "anim/player_actions_tap.zip"),
		Asset("ANIM", "anim/player_actions_cropdust.zip"),
		Asset("ANIM", "anim/player_lifeplant.zip"),

		Asset("ANIM", "anim/player_actions_telescope.zip"),
		Asset("ANIM", "anim/player_idles_poison.zip"),

		Asset("ANIM", "anim/player_idles_groggy.zip"),
		Asset("ANIM", "anim/player_groggy.zip"),

		Asset("ANIM", "anim/player_frozen.zip"),
		Asset("ANIM", "anim/player_shock.zip"),
		Asset("ANIM", "anim/shock_fx.zip"),
		Asset("ANIM", "anim/player_tornado.zip"),
		Asset("ANIM", "anim/player_portal_shipwrecked.zip"),
		Asset("ANIM", "anim/player_portal_hamlet.zip"),

		Asset("ANIM", "anim/shadow_hands.zip"),

        Asset("ANIM", "anim/player_mount.zip"),
        Asset("ANIM", "anim/player_mount_travel.zip"),
        Asset("ANIM", "anim/player_mount_actions.zip"),
        Asset("ANIM", "anim/player_mount_actions_item.zip"),
        Asset("ANIM", "anim/player_mount_unique_actions.zip"),
        Asset("ANIM", "anim/player_mount_one_man_band.zip"),
        Asset("ANIM", "anim/player_mount_blowdart.zip"),
        Asset("ANIM", "anim/player_mount_shock.zip"),
        Asset("ANIM", "anim/player_mount_frozen.zip"),
        Asset("ANIM", "anim/player_mount_groggy.zip"),
        Asset("ANIM", "anim/player_mount_hit_darkness.zip"),
		Asset("ANIM", "anim/player_mount_idles_shiver.zip"),
        Asset("ANIM", "anim/player_mount_actions_speargun.zip"),
        Asset("ANIM", "anim/player_mount_actions_telescope.zip"),
		Asset("ANIM", "anim/player_mount_idles_poison.zip"),
		Asset("ANIM", "anim/player_mount_sneaky.zip"),
		Asset("ANIM", "anim/player_mount_actions_cropdust.zip"),
		Asset("ANIM", "anim/player_mount_hand_lens.zip"),
		Asset("ANIM", "anim/player_mount_sneeze.zip"),

		Asset("ANIM", "anim/player_living_suit_shoot.zip"),	
		Asset("ANIM", "anim/player_living_suit_morph.zip"),			
		Asset("ANIM", "anim/player_living_suit_punch.zip"),
		Asset("ANIM", "anim/player_living_suit_destruct.zip"),
		Asset("ANIM", "anim/living_suit_build.zip"),

        Asset("ANIM", "anim/player_actions_unsaddle.zip"),

        Asset("ANIM", "anim/goo.zip"),

		Asset("SOUND", "sound/sfx.fsb"),
		Asset("SOUND", "sound/wilson.fsb"),

		Asset("ANIM", "anim/fish01.zip"),   --These are used for the fishing animations.
		Asset("ANIM", "anim/eel01.zip"),
		Asset("INV_IMAGE", "skull_"..name ),
	}

	local prefabs =
	{
		"beardhair",
		"brokentool",
		"abigail",
		"terrorbeak",
		"crawlinghorror",
		"creepyeyes",
		"shadowskittish",
		"shadowwatcher",
		"shadowhand",
		"swimminghorror",
		"shadowskittish_water",
		"frostbreath",
		"book_birds",
		"book_tentacles",
		"book_gardening",
		"book_sleep",
		"book_brimstone",
		"pine_needles",
		"reticule",
		"shovel_dirt",
		"mining_fx",
		"splash_footstep",
		"pixel_out",
		"pixel_in",
		"boat_death",
		"wilbur_unlock",
		"woodlegs_cage",
		"wormhole_shipwrecked_fx",
		"compostwrap",
		"poisonbalm",
		"armor_bramble",
		"trap_bramble",

	    "gogglesnormalhat",
	    "gogglesheathat",
	    "gogglesarmorhat",
	    "gogglesshoothat",
	    "telebrella",
	    "thumper",
	    "groundpound_fx",
	    "groundpoundring_fx",    
	    "telipad",
	    "beacon",		
	}


	local function checktax(inst)
	    if inst:HasTag("mayor") and GetClock().numcycles%10 == 0 then        
	    	inst:DoTaskInTime(2, function()
				inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_TAXDAY"))
	    	end)
	    end
	end

	local fx = require("fx")
    for k, v in pairs(fx) do
        table.insert(prefabs, v.name)
    end

	if starting_inventory then
		for k,v in pairs(starting_inventory) do
			table.insert(prefabs, v)
		end
	end

	if customprefabs then
		for k,v in ipairs(customprefabs) do
			table.insert(prefabs, v)
		end
	end

	if customassets then
		for k,v in ipairs(customassets) do
			table.insert(assets, v)
		end
	end

	local fn = function(Sim)

		local inst = CreateEntity()
		inst.entity:SetCanSleep(false)

		local trans = inst.entity:AddTransform()
		local anim = inst.entity:AddAnimState()
		local sound = inst.entity:AddSoundEmitter()
		local shadow = inst.entity:AddDynamicShadow()
		local minimap = inst.entity:AddMiniMapEntity()

		inst.gasTask = nil

		inst.Transform:SetFourFaced()

		inst.persists = false --handled in a special way

		MakeCharacterPhysics(inst, 75, .5)
		MakePoisonableCharacter(inst, nil, nil, 0, 0, 0)
		inst.components.poisonable.duration = TUNING.TOTAL_DAY_TIME * 3
		inst.components.poisonable.transfer_poison_on_attack = false
		inst.components.poisonable.show_fx = false

		shadow:SetSize( 1.3, .6 )

		minimap:SetIcon( name .. ".png" )
		minimap:SetPriority( 10 )

		local lightwatch = inst.entity:AddLightWatcher()
		lightwatch:SetLightThresh(.075)
		lightwatch:SetDarkThresh(.05)

		inst:AddTag("player")
		inst:AddTag("scarytoprey")
		inst:AddTag("character")

		anim:SetBank("wilson")
		anim:SetBuild(name)

        if( name == "wolfgang" or name == "wickerbottom" or name == "wes" ) then
			anim:OverrideSymbol("torso_pelvis", name, "torso" ) --put the torso in pelvis slot to go behind
			anim:OverrideSymbol("torso", name, "torso_pelvis" ) --put the pelvis on top of the base torso by putting it in the torso slot
        end

		anim:PlayAnimation("idle")

		anim:Hide("ARM_carry")
		anim:Hide("hat")
		anim:Hide("hat_hair")
		anim:Hide("PROPDROP")
		anim:OverrideSymbol("fx_wipe", "wilson_fx", "fx_wipe")
		anim:OverrideSymbol("fx_liquid", "wilson_fx", "fx_liquid")
		anim:OverrideSymbol("shadow_hands", "shadow_hands", "shadow_hands")

		anim:OverrideSymbol("ripplebase", "player_boat_death", "ripplebase")
		anim:OverrideSymbol("waterline", "player_boat_death", "waterline")
		anim:OverrideSymbol("waterline", "player_boat_death", "waterline")
    	anim:AddOverrideBuild("player_portal_shipwrecked")
    	anim:AddOverrideBuild("player_pistol")
		anim:AddOverrideBuild("player_portal_hamlet")		anim:AddOverrideBuild("player_actions_cropdust")
		inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
		inst.components.locomotor:SetSlowMultiplier( 0.6 )
		inst.components.locomotor.pathcaps = { player = true, ignorecreep = true } -- 'player' cap not actually used, just useful for testing
		inst.components.locomotor.fasteronroad = true

		inst:AddComponent("combat")
		inst.components.combat:SetDefaultDamage(TUNING.UNARMED_DAMAGE)
		inst.components.combat.GetGiveUpString = giveupstring
		inst.components.combat.hiteffectsymbol = "torso"

		inst:AddComponent("inventory")
		inst.components.inventory.starting_inventory = starting_inventory

		inst:AddComponent("shopper")

		inst:AddComponent("dynamicmusic")
		inst:AddComponent("playercontroller")

		--inst:AddComponent("vehiclecontroller")

		inst:AddComponent("sanitymonsterspawner")
		inst:AddComponent("autosaver")

		---------------------------------

	    inst:AddComponent("grogginess")
	    inst.components.grogginess:SetResistance(3)

		---------------------------------

		inst:AddComponent("moisture")
		------

		inst:AddComponent("health")
		inst.components.health:SetMaxHealth(TUNING.WILSON_HEALTH)
		inst.components.health.nofadeout = true
		-------

		inst:AddComponent("hunger")
		inst.components.hunger:SetMax(TUNING.WILSON_HUNGER)
		inst.components.hunger:SetRate(TUNING.WILSON_HUNGER_RATE)
		inst.components.hunger:SetKillRate(TUNING.WILSON_HEALTH/TUNING.STARVE_KILL_TIME)


		inst:AddComponent("sanity")
		inst.components.sanity:SetMax(TUNING.WILSON_SANITY)
		inst.components.sanity.onSane = OnSane
		inst.components.sanity.onInsane = OnInsane


		inst:AddComponent("hayfever")
		inst:AddComponent("infestable")		

		-------

		inst:AddComponent("kramped")

		inst:AddComponent("talker")
		-- Reset overrides just in case
		inst.hurtsoundoverride = nil
		inst.talker_path_override = nil

		inst:AddComponent("trader")
		inst:AddComponent("wisecracker")
		inst:AddComponent("distancetracker")
		inst:AddComponent("resurrectable")
		inst:AddComponent("farseer")

		inst:AddComponent("temperature")

		inst:AddComponent("catcher")

		inst:AddComponent("playerlightningtarget")
		local light = inst.entity:AddLight()
		inst.Light:Enable(false)
		inst.Light:SetRadius(.8)
		inst.Light:SetFalloff(0.5)
		inst.Light:SetIntensity(.65)
		inst.Light:SetColour(255/255,255/255,236/255)

		-------

		inst:AddComponent("tiletracker")
		inst.components.tiletracker:SetOnGasChangeFn(OnGasChange)
		-- inst.components.tiletracker:SetOnTileChangeFn(OnTileChange)
		inst.components.tiletracker:Start()

		inst.OnGasChange = OnGasChange

		inst:AddComponent("builder")

		--give the default recipes
		local valid_recipes = GetAllRecipes()
		for k,v in pairs(valid_recipes) do
			if v.level == 0 then
				inst.components.builder:AddRecipe(v.name)
			end
		end

		inst:AddComponent("eater")
		inst:AddComponent("playeractionpicker")
		inst:AddComponent("leader")

		inst:AddComponent("frostybreather")
        inst.components.frostybreather:SetOffsetFn(GetFrostyBreatherOffset)

		inst:AddComponent("age")
        
		inst:AddComponent("grue")
		inst.components.grue:SetSounds("dontstarve/charlie/warn","dontstarve/charlie/attack")

		inst:AddComponent("keeponland")

		inst:AddComponent("krakener")

		inst:AddComponent("bundler")

        inst:AddComponent("rider")	
		inst:AddComponent("pinnable")

        inst:AddComponent("vision")        

		-----------------------------------
		inst:AddComponent("driver")
		inst.components.driver.landstategraph = "SGwilson"
		inst.components.driver.boatingstategraph = "SGwilsonboating"
		-------------------------------------

        if not Profile:IsCharacterUnlocked("wilbur") then
            if not inst.components.globalloot then
                inst:AddComponent("globalloot")
            end
            inst.components.globalloot:AddGlobalLoot({
                loot = "wilbur_crown", 
                dropchance = 0.10,
                candropfn = function()
                    return not TheSim:FindFirstEntityWithTag("wilbur_crown") and not
                    Profile:IsCharacterUnlocked("wilbur")
                end,
                droppers = 
                {
                    "primeape",
                    "primeapebarrel",
                },
            })
        end

        if not Profile:IsCharacterUnlocked("woodlegs") then
            if not inst.components.globalloot then
                inst:AddComponent("globalloot")
            end
            inst.components.globalloot:AddGlobalLoot({
                loot = "woodlegs_key3", 
                dropchance = 1.00,
                candropfn = function()
                    return not TheSim:FindFirstEntityWithTag("woodlegs_key3") and not
                    Profile:IsCharacterUnlocked("woodlegs")
                end,
                droppers = 
                {
                    "kraken",
                },
            })
        end

		--For message bottle reading
		inst:AddComponent("reader")

		MakeHugeFreezableCharacter(inst)
		inst.components.freezable:SetDefaultWearOffTime(TUNING.PLAYER_FREEZE_WEAR_OFF_TIME)

		-------
		if METRICS_ENABLED then
			inst:AddComponent("overseer")
		end
		-------

		inst.components.combat:SetAttackPeriod(TUNING.WILSON_ATTACK_PERIOD)
		inst.components.combat:SetRange(2)

		function inst.components.combat:GetBattleCryString(target)
		    return target ~= nil
		        and target:IsValid()
		        and GetString(
		            inst.prefab,
		            "BATTLECRY",
		            (target:HasTag("prey") and not target:HasTag("hostile") and "PREY") or
		            (string.find(target.prefab, "pig") ~= nil and target:HasTag("pig") and not target:HasTag("werepig") and "PIG") or		            
		            target.prefab
		        )
		        or nil
		end

		local brain = require "brains/wilsonbrain"
		inst:SetBrain(brain)

		inst:AddInherentAction(ACTIONS.PICK)
		inst:AddInherentAction(ACTIONS.SLEEPIN)



		inst:SetStateGraph("SGwilson")

		inst:ListenForEvent( "startfiredamage", function(it, data)
					inst.SoundEmitter:PlaySound("dontstarve/wilson/burned")
					inst.SoundEmitter:PlaySound("dontstarve/common/campfire", "burning")
					inst.SoundEmitter:SetParameter("burning", "intensity", 1)
					local frozenitems = inst.components.inventory:FindItems(function(item) return item:HasTag("frozen") end)
					if #frozenitems > 0 then
						for i,v in pairs(frozenitems) do
							v:PushEvent("firemelt")
						end
					end
			end)

		inst:ListenForEvent( "stopfiredamage", function(it, data)
					inst.SoundEmitter:KillSound("burning")
					local frozenitems = inst.components.inventory:FindItems(function(item) return item:HasTag("frozen") end)
					if #frozenitems > 0 then
						for i,v in pairs(frozenitems) do
							v:PushEvent("stopfiremelt")
						end
					end
			end)

		inst:ListenForEvent( "containergotitem", function(it, data)
				if inst.components.driver and inst.components.driver:GetIsDriving() then 
					inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/HUD_water_collect_resource")
				else 
					inst.SoundEmitter:PlaySound("dontstarve/HUD/collect_resource")
				end 
			end)

		inst:ListenForEvent( "gotnewitem", function(it, data)
				if data.slot then
					Print(VERBOSITY.DEBUG, "gotnewitem: ["..data.item.prefab.."]")
					if inst.components.driver and inst.components.driver:GetIsDriving() then 
						inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/HUD_water_collect_resource")
					else 
						inst.SoundEmitter:PlaySound("dontstarve/HUD/collect_resource")
					end 	
					
				end
			end)

		inst:ListenForEvent( "equip", function(it, data)
				Print(VERBOSITY.DEBUG, "equip: ["..data.item.prefab.."]")
				inst.SoundEmitter:PlaySound("dontstarve/wilson/equip_item")
			end)

		inst:ListenForEvent( "picksomething", function(it, data)
				if data.object and data.object.components.pickable and data.object.components.pickable.picksound then
					Print(VERBOSITY.DEBUG, "picksomething: ["..data.object.prefab.."]")    -- BTW why is this one 'object'?
					inst.SoundEmitter:PlaySound(data.object.components.pickable.picksound)
				end
			end)

		inst:ListenForEvent( "dropitem", function(it, data)
			Print(VERBOSITY.DEBUG, "dropitem: ["..data.item.prefab.."]")
			inst.SoundEmitter:PlaySound("dontstarve/common/dropGeneric")
			end)

		inst:ListenForEvent( "builditem", function(it, data)
			Print(VERBOSITY.DEBUG, "builditem: ["..data.item.prefab.."]")
			inst.SoundEmitter:PlaySound("dontstarve/HUD/collect_newitem")
			end)

		inst:ListenForEvent( "buildstructure", function(it, data)
			Print(VERBOSITY.DEBUG, "buildstructure: ["..data.item.prefab.."]")
			inst.SoundEmitter:PlaySound("dontstarve/HUD/collect_newitem")
			end)

		inst:ListenForEvent("working", OnWork)
		--set up the UI root entity
		--HUD:SetMainCharacter(inst)

		inst:ListenForEvent("actionfailed", function(it, data)
			inst.components.talker:Say(GetActionFailString(inst.prefab, data.action.action.id, data.reason))
		end)

		inst:ListenForEvent("canteatfood", function()
			inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_EAT", "INVALID"))
		end)

		inst:ListenForEvent("onpickup", function(inst, data)
			if data and data.item and data.item.prefab == "sand" then
				inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/sandpile")
			end
		end)

		inst:ListenForEvent("hurricanestart", function()
			if inst.components.farseer then
				inst.components.farseer:AddBonus("hurricane", 1, TUNING.MAPREVEAL_HURRICANE_PENALTY)
			end
		end, GetWorld())

		inst:ListenForEvent("hurricanestop", function()
			if inst.components.farseer then
				inst.components.farseer:RemoveBonus("hurricane")
			end
		end, GetWorld())

        inst:ListenForEvent("spawn", function(it, data)
            inst.components.bundler:StopBundling()
        end)

		inst.CanExamine = function() return not inst.beaver end

		inst.Soak = function()
			local percent = 1 - inst.components.inventory:GetWaterproofness()
			print("Soaker!! "..percent)
			inst.components.moisture:Soak(percent)
			--inst.components.inventory:Soak()
			GetWorld().components.inventorymoisture:Soak(percent)
		end

		inst.OnSave = function(inst, data)
			data.summertrapped = inst.summertrapped
			data.homeowner = inst.homeowner		
			data.paytax = inst:HasTag("paytax")	
			data.toolwantstobreak = inst.toolwantstobreak
		end
		inst.OnLoad = function(inst, data)
			inst.summertrapped = data.summertrapped
			inst.homeowner = data.homeowner
			if data.paytax then
				inst:AddTag("paytax")
			end
			if data.toolwantstobreak then
				inst.toolwantstobreak = data.toolwantstobreak
			end
		end

		inst.AddLevelComponents = addlevelspecificcomponents

		if customfn then
			local commonOnSave = inst.OnSave
			local commonOnLoad = inst.OnLoad
			customfn(inst)
			-- see if this guys had a custom save/load function that stomped the original
			local customOnSave = inst.OnSave
			if customOnSave ~= commonOnSave then
				inst.OnSave = function(inst, data)
					commonOnSave(inst, data)
					customOnSave(inst, data)
				end
			end
			local customOnLoad = inst.OnLoad
			if customOnLoad ~= commonOnLoad then
				inst.OnLoad = function(inst, data)
					commonOnLoad(inst, data)
					customOnLoad(inst, data)
				end
			end
		end

		inst:ListenForEvent( "daytime", function() checktax(inst) end, GetWorld())  

		return inst
	end

	return Prefab( "characters/"..name, fn, assets, prefabs)
end

return MakePlayerCharacter