require "brains/antbrain"
require "stategraphs/SGant"

local assets =
{
	Asset("ANIM", "anim/antman_basic.zip"),
	Asset("ANIM", "anim/antman_attacks.zip"),
	Asset("ANIM", "anim/antman_actions.zip"),

    Asset("ANIM", "anim/antman_translucent_build.zip"),    
	--Asset("ANIM", "anim/antman_build.zip"),
	Asset("SOUND", "sound/pig.fsb"),
}

local prefabs =
{
    "monstermeat",
    "chitin",
}

local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 30


local function setEatType(inst,eattype)

    if eattype == 1 then
        inst.components.eater:SetVegetarian()
    elseif eattype == 2 then    
        inst.components.eater:SetBird()
    elseif eattype == 3 then
        inst.components.eater:SetBeaver()
    elseif eattype == 4 then
        inst.components.eater:SetCarnivore()
    end
end


local function ontalk(inst, script)
    if inst.is_complete_disguise(GetPlayer()) then
        inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/crickant/pick_up")
    else
	   inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/crickant/abandon")
    end
end

local function SpringMod(amt)
    if GetSeasonManager() and (GetSeasonManager():IsSpring() or GetSeasonManager():IsGreenSeason()) then
        return amt --* TUNING.SPRING_COMBAT_MOD
    else
        return amt
    end
end

local function CalcSanityAura(inst, observer)
    if inst.components.follower and inst.components.follower.leader == observer then
        return TUNING.SANITYAURA_SMALL
    end
    
    return 0
end

local function ShouldAcceptItem(inst, item)
    if inst.components.sleeper:IsAsleep() then
        return false
    end

    if item.components.equippable and item.components.equippable.equipslot == EQUIPSLOTS.HEAD then
        return true
    end
    if item.components.edible then
        
        if (item.components.edible.foodtype == "MEAT" or item.components.edible.foodtype == "HORRIBLE")
           and inst.components.follower.leader
           and inst.components.follower:GetLoyaltyPercent() > 0.9 then
            return false
        end
        
        if (item.components.edible.foodtype == "VEGGIE" or item.components.edible.foodtype == "RAW") then
			local last_eat_time = inst.components.eater:TimeSinceLastEating()
			if last_eat_time and last_eat_time < TUNING.PIG_MIN_POOP_PERIOD then        
				return false
			end

            if inst.components.inventory:Has(item.prefab, 1) then
                return false
            end
		end
		
        return true
    end
end

local function OnGetItemFromPlayer(inst, giver, item)
    --I eat food    
    if item.components.edible then
        --meat makes us friends
        if inst.components.eater:CanEat(item) then
      --  if item.components.edible.foodtype == "MEAT" or item.components.edible.foodtype == "HORRIBLE" then
            if inst.components.combat.target and inst.components.combat.target == giver then
                inst.components.combat:SetTarget(nil)
            elseif giver.components.leader then
				inst.SoundEmitter:PlaySound("dontstarve/common/makeFriend")
				giver.components.leader:AddFollower(inst)
                inst.components.follower:AddLoyaltyTime(item.components.edible:GetHunger() * TUNING.ANTMAN_LOYALTY_PER_HUNGER)
            end
        end
        if inst.components.sleeper:IsAsleep() then
            inst.components.sleeper:WakeUp()
        end
    end
    
    --I wear hats
    if item.components.equippable and item.components.equippable.equipslot == EQUIPSLOTS.HEAD then
        local current = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
        if current then
            inst.components.inventory:DropItem(current)
        end
        
        inst.components.inventory:Equip(item)
        inst.AnimState:Show("hat")
    end
end

local function OnRefuseItem(inst, item)
    inst.sg:GoToState("refuse")
    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
end

local function OnEat(inst, food)
end

local function OnAttackedByDecidRoot(inst, attacker)
    local fn = function(dude) return dude:HasTag("antman") end

    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = nil
    if GetSeasonManager() and (GetSeasonManager():IsSpring() or GetSeasonManager():IsGreenSeason()) then
        ents = TheSim:FindEntities(x, y, z, (SHARE_TARGET_DIST * TUNING.SPRING_COMBAT_MOD) / 2)
    else
        ents = TheSim:FindEntities(x, y, z, SHARE_TARGET_DIST / 2)
    end
    
    if ents then
        local num_helpers = 0
        for k, v in pairs(ents) do
            if v ~= inst and v.components.combat and not (v.components.health and v.components.health:IsDead()) and fn(v) then
                if v:PushEvent("suggest_tree_target", {tree=attacker}) then
                    num_helpers = num_helpers + 1
                end
            end
            if num_helpers >= MAX_TARGET_SHARES then
                break
            end     
        end
    end
end

local function OnAttacked(inst, data)
    --print(inst, "OnAttacked")
    local attacker = data.attacker
    inst:ClearBufferedAction()

    if attacker.prefab == "deciduous_root" and attacker.owner then 
        OnAttackedByDecidRoot(inst, attacker.owner)
    elseif attacker.prefab ~= "deciduous_root" then
        inst.components.combat:SetTarget(attacker)
        inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, function(dude) return dude:HasTag("ant") end, MAX_TARGET_SHARES)
    end
end

local function OnNewTarget(inst, data)
end

local builds = {"antman_translucent_build"}-- {"antman_build"} 

local function is_complete_disguise(target)
    return target:HasTag("has_antmask") and target:HasTag("has_antsuit")
end

local function NormalRetargetFn(inst)
    return FindEntity(inst, TUNING.PIG_TARGET_DIST,
        function(guy)
            if guy.components.health and not guy.components.health:IsDead() and inst.components.combat:CanTarget(guy) and not is_complete_disguise(guy) then
                if guy:HasTag("monster") then return guy end
                if guy:HasTag("player") and guy.components.inventory and guy:GetDistanceSqToInst(inst) < TUNING.ANTMAN_ATTACK_ON_SIGHT_DIST*TUNING.ANTMAN_ATTACK_ON_SIGHT_DIST and not guy:HasTag("ant_disguise") then return guy end
            end
        end)
end

local function NormalKeepTargetFn(inst, target)
    --give up on dead guys, or guys in the dark, or werepigs
    return inst.components.combat:CanTarget(target)
           and (not target.LightWatcher or target.LightWatcher:IsInLight())
           and not (target.sg and target.sg:HasStateTag("transform") )
end

local function NormalShouldSleep(inst)
    if inst.components.follower and inst.components.follower.leader then
        local fire = FindEntity( inst, 6, 
            function(ent)
                return ent.components.burnable and ent.components.burnable:IsBurning()
            end, 
        {"campfire"} )
        
        return DefaultSleepTest(inst) and fire and (not inst.LightWatcher or inst.LightWatcher:IsInLight())
    else
        return DefaultSleepTest(inst)
    end
end

local function TransformToWarrior(inst, from_limbo_or_asleep)
    if from_limbo_or_asleep then
        local warrior = SpawnPrefab("antman_warrior")
        warrior.Transform:SetPosition(  inst.Transform:GetWorldPosition() )
        warrior:AddTag("aporkalypse_cleanup")
		-- re-register us with the childspawner and interior
		ReplaceEntity(inst, warrior)
        inst:Remove()
    else
        inst.sg:GoToState("transform")
    end

end

local function SetNormalAnt(inst)
    local brain = require "brains/antbrain"
    inst:SetBrain(brain)
    inst:SetStateGraph("SGant")
	inst.AnimState:SetBuild(inst.build)
    
    inst.components.sleeper:SetResistance(2)

    inst.components.combat:SetDefaultDamage(TUNING.ANTMAN_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.ANTMAN_ATTACK_PERIOD)
    inst.components.combat:SetKeepTargetFunction(NormalKeepTargetFn)
    inst.components.locomotor.runspeed = TUNING.ANTMAN_RUN_SPEED
    inst.components.locomotor.walkspeed = TUNING.ANTMAN_WALK_SPEED
    
    inst.components.sleeper:SetSleepTest(NormalShouldSleep)
    inst.components.sleeper:SetWakeTest(DefaultWakeTest)
    
    inst.components.lootdropper:SetLoot({})
    inst.components.lootdropper:AddRandomLoot("monstermeat", 3)
    inst.components.lootdropper:AddRandomLoot("chitin", 1)
    inst.components.lootdropper.numrandomloot = 1

    inst.components.health:SetMaxHealth(TUNING.ANTMAN_HEALTH)
    inst.components.combat:SetRetargetFunction(3, NormalRetargetFn)
    inst.components.combat:SetTarget(nil)
    inst:ListenForEvent("suggest_tree_target", function(inst, data)
        if data and data.tree and inst:GetBufferedAction() ~= ACTIONS.CHOP then
            inst.tree_target = data.tree
        end
    end)
    
    inst.components.trader:Enable()
    inst.components.talker:StopIgnoringAll()
end

local function common()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize(1.5, .75)
    inst.Transform:SetFourFaced()

    inst.Transform:SetScale(1.15, 1.15, 1.15)

    inst.entity:AddLightWatcher()
    
    inst:AddComponent("talker")
    inst.components.talker.ontalk = ontalk
    inst.components.talker.fontsize = 35
    inst.components.talker.font = TALKINGFONT
    --inst.components.talker.colour = Vector3(133/255, 140/255, 167/255)
    inst.components.talker.offset = Vector3(0, -400, 0)

    MakeCharacterPhysics(inst, 50, .5)
    MakePoisonableCharacter(inst)
    
    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = TUNING.ANTMAN_RUN_SPEED --5
    inst.components.locomotor.walkspeed = TUNING.ANTMAN_WALK_SPEED --3

    inst:AddTag("character")
    inst:AddTag("ant")
    inst:AddTag("insect")    
    inst:AddTag("scarytoprey")
    anim:SetBank("antman")
    anim:PlayAnimation("idle_loop")
    anim:Hide("hat")

    inst.combatTargetWasDisguisedOnExit = false

    ------------------------------------------
    inst:AddComponent("eater")
    inst.eattype = math.random(4)
    setEatType(inst,inst.eattype)

	inst.components.eater:SetCanEatHorrible()
    table.insert(inst.components.eater.foodprefs, "RAW")
    table.insert(inst.components.eater.ablefoods, "RAW")
    inst.components.eater.strongstomach = true -- can eat monster meat!
    inst.components.eater:SetOnEatFn(OnEat)
    ------------------------------------------
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "antman_torso"

    MakeMediumBurnableCharacter(inst, "antman_torso")

    inst:AddComponent("named")
    inst.components.named.possiblenames = STRINGS.ANTNAMES
    inst.components.named:PickNewName()
	
    ------------------------------------------
    inst:AddComponent("follower")
    inst.components.follower.maxfollowtime = TUNING.ANTMAN_LOYALTY_MAXTIME
    ------------------------------------------
    inst:AddComponent("health")

    ------------------------------------------

    inst:AddComponent("inventory")
    
    ------------------------------------------

    inst:AddComponent("lootdropper")

    ------------------------------------------

    inst:AddComponent("knownlocations")
    
    ------------------------------------------

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem
    
    ------------------------------------------

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura

    ------------------------------------------

    inst:AddComponent("sleeper")
    
    ------------------------------------------
    MakeMediumFreezableCharacter(inst, "antman_torso")
    
    ------------------------------------------

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = function(inst)
        if inst.components.follower.leader ~= nil then
            return "FOLLOWER"
        end
    end
    ------------------------------------------

    inst.OnSave = function(inst, data)
        data.build = inst.build
        data.eattype = inst.eattype
        data.combatTargetWasDisguisedOnExit = inst.combatTargetWasDisguisedOnExit
    end        
    
    inst.OnLoad = function(inst, data)    
		if data then
			inst.build = data.build or builds[1]

            inst.combatTargetWasDisguisedOnExit = data.combatTargetWasDisguisedOnExit
			inst.AnimState:SetBuild(inst.build)
            inst.eattype = data.eattype
            setEatType(inst, inst.eattype)
		end
    end           
    
    inst:ListenForEvent("attacked", OnAttacked)    
    inst:ListenForEvent("newcombattarget", OnNewTarget)
    inst.is_complete_disguise = is_complete_disguise

    inst:ListenForEvent("beginaporkalypse", function() 
        if not inst:IsInLimbo() then
			if inst:IsAsleep() then
	            TransformToWarrior(inst, true)
			else
	            TransformToWarrior(inst, false)
			end
        end
    end, GetWorld())
    
    local function CheckForAporkalypse(from_limbo)
        local aporkalypse = GetAporkalypse()

        if aporkalypse and aporkalypse:IsActive() then
            inst:DoTaskInTime(.2, function(inst)
                TransformToWarrior(inst, from_limbo)
            end)
        end
    end

    inst:ListenForEvent("exitlimbo", function(inst)
        CheckForAporkalypse(true)
    end)

    CheckForAporkalypse(true)
    return inst
end

local function normal()
    local inst = common()
    inst.build = builds[math.random(#builds)]
    inst.AnimState:SetBuild(inst.build)
    SetNormalAnt(inst)
    return inst
end

-- Here to clean up mess of too many mants
function CleanUpMants()
	-- one time cleanup of surplus glowflies.
	if GetWorld().culledMants then
		return 
	end
	print("Cleaning up stray Mants")
	local count = 0
	for i,v in pairs(Ents) do
		if v.prefab == "antman" or v.prefab == "antman_warrior" then
			if not v:HasTag("INTERIOR_LIMBO") then
				-- it's not in interior limbo, so it's either current room or outside
				if GetInteriorSpawner() then
					local pt = GetInteriorSpawner():getSpawnOrigin()
					local pos = v:GetPosition()
					local delta = (pos-pt):Length()
					-- we're not in interior limbo, so we're either in the current room, or we are outside
					if delta > 20 then
						-- not in the current room, so we're outside
						if not v.components.homeseeker then
							-- we lost our home	.
							count = count + 1
							v:DoTaskInTime(0, function() v:Remove() end)
						end
					end
				end
			end
		end
	end
	if count > 0 then
		print(string.format("Removed %d stray mants", count))
	end
	GetWorld().culledMants = true
end


return Prefab("common/characters/antman", normal, assets, prefabs)