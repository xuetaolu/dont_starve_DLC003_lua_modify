require "brains/bunnymanbrain"
require "stategraphs/SGmandrakeman"

local assets =
{
	Asset("ANIM", "anim/elderdrake_basic.zip"),
	Asset("ANIM", "anim/elderdrake_actions.zip"),
	Asset("ANIM", "anim/elderdrake_attacks.zip"),
    Asset("ANIM", "anim/elderdrake_build.zip"),   

	Asset("SOUND", "sound/bunnyman.fsb"),
}

local prefabs =
{
    "meat",
    "monstermeat",
    "manrabbit_tail",
}


local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 30

local function ontalk(inst, script)
	inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/idle_med")
end

local function CalcSanityAura(inst, observer)

	if inst.beardlord then
        return -TUNING.SANITYAURA_MED
    end
    
    if inst.components.follower and inst.components.follower.leader == observer then
		return TUNING.SANITYAURA_SMALL
	end
	
	return 0
end


local function ShouldAcceptItem(inst, item)
    if inst:HasTag("grumpy") then
        return false
    end
    if item.components.equippable and item.components.equippable.equipslot == EQUIPSLOTS.HEAD then
        return true
    end

    if item.components.edible then
        
        if inst.components.eater:AbleToEat(item) 
           and inst.components.follower.leader
           and inst.components.follower:GetLoyaltyPercent() > 0.9 then
            return false
        end
        
        return true
    end

end

local function OnGetItemFromPlayer(inst, giver, item)

    --I eat food
    if item.components.edible then
        if inst.components.eater:AbleToEat(item) then
            if inst.components.combat.target and inst.components.combat.target == giver then
                inst.components.combat:SetTarget(nil)
            elseif giver.components.leader then
				inst.SoundEmitter:PlaySound("dontstarve/common/makeFriend")
				giver.components.leader:AddFollower(inst)
                inst.components.follower:AddLoyaltyTime(TUNING.RABBIT_CARROT_LOYALTY)
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


local function OnAttacked(inst, data)
    --print(inst, "OnAttacked")
    local attacker = data.attacker
    inst.components.combat:SetTarget(attacker)
    inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, function(dude) return dude.prefab == inst.prefab end, MAX_TARGET_SHARES)
end

local function OnNewTarget(inst, data)
    inst.components.combat:ShareTarget(data.target, SHARE_TARGET_DIST, function(dude) return dude.prefab == inst.prefab end, MAX_TARGET_SHARES)
end

local function is_mandrake(item)
    return item:HasTag("mandrake")
end

local function RetargetFn(inst)
    
    local defenseTarget = inst
    local home = inst.components.homeseeker and inst.components.homeseeker.home
    if home and inst:GetDistanceSqToInst(home) < TUNING.MANDRAKEMAN_DEFEND_DIST*TUNING.MANDRAKEMAN_DEFEND_DIST then
        defenseTarget = home
    end
    local dist = TUNING.MANDRAKEMAN_TARGET_DIST
    local invader = FindEntity(defenseTarget or inst, dist, function(guy)
        return guy:HasTag("character") and not guy:HasTag("mandrakeman") and (guy == GetPlayer() and inst:HasTag("grumpy"))
    end)
    return invader

--[[
    return FindEntity(inst, TUNING.PIG_TARGET_DIST,
        function(guy)
            
            if guy.components.health and not guy.components.health:IsDead() and inst.components.combat:CanTarget(guy) then
                if guy:HasTag("monster") then return guy end
                if guy:HasTag("player") and guy.components.inventory and guy:GetDistanceSqToInst(inst) < TUNING.MANDRAKEMAN_SEE_MANDRAKE_DIST*TUNING.MANDRAKEMAN_SEE_MANDRAKE_DIST and guy.components.inventory:FindItem(is_mandrake ) then return guy end
            end
        end)
        ]]
end
local function KeepTargetFn(inst, target)
    local home = inst.components.homeseeker and inst.components.homeseeker.home
    if home then
        return home:GetDistanceSqToInst(target) < TUNING.MANDRAKEMAN_DEFEND_DIST*TUNING.MANDRAKEMAN_DEFEND_DIST
               and home:GetDistanceSqToInst(inst) < TUNING.MANDRAKEMAN_DEFEND_DIST*TUNING.MANDRAKEMAN_DEFEND_DIST
    end
    return inst.components.combat:CanTarget(target)     
end


local function giveupstring(combatcmp, target)
    return STRINGS.MANDRAKEMAN_GIVEUP[math.random(#STRINGS.MANDRAKEMAN_GIVEUP)]
end


local function battlecry(combatcmp, target)
    
    if target and target.components.inventory then
    

        local item = target.components.inventory:FindItem(function(item) return item:HasTag("mandrake") end )    
        if item then
            return STRINGS.MANDRAKEMAN_MANDRAKE_BATTLECRY[math.random(#STRINGS.MANDRAKEMAN_MANDRAKE_BATTLECRY)]
        end
    end
    return STRINGS.MANDRAKEMAN_BATTLECRY[math.random(#STRINGS.MANDRAKEMAN_BATTLECRY)]
end 

local function DoAreaEffect(inst, knockout)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/mandrake/death")
    local pos = Vector3(inst.Transform:GetWorldPosition())
    local ents = TheSim:FindEntities(pos.x,pos.y,pos.z, TUNING.MANDRAKE_SLEEP_RANGE)
    for k,v in pairs(ents) do
        if v.components.sleeper then
            v.components.sleeper:AddSleepiness(10, TUNING.MANDRAKE_SLEEP_TIME)
        elseif v:HasTag("player") and knockout then
            v.sg:GoToState("wakeup")
            v.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_KNOCKEDOUT") )
        end
    end
end

local function deathscream(inst)
    DoAreaEffect(inst)
end

local function transform(inst,grumpy)
    local anim = inst.AnimState
    if grumpy then    
        inst.AnimState:Show("head_angry")
        inst.AnimState:Hide("head_happy")
        inst:AddTag("grumpy")
    else
        inst.AnimState:Hide("head_angry")
        inst.AnimState:Show("head_happy")        
        inst.sg:GoToState("happy")
        inst:RemoveTag("grumpy")
    end 
end

local function transformtest(inst)
    if GetClock():GetMoonPhase() == "full" and GetClock():IsNight() then
        if inst:HasTag("grumpy") then
            inst:DoTaskInTime(1+(math.random()*1) , function() transform(inst) end )
        end
    else
        if not inst:HasTag("grumpy") then
            inst:DoTaskInTime(1+(math.random()*1) , function() transform(inst,true) end )
        end
    end
end

local function OnWake(inst)
     transformtest(inst)
end

local function OnSleep(inst)
	 if inst.checktask then
	 	inst.checktask:Cancel()
	 	inst.checktask = nil
	 end
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 1.5, .75 )
    inst.Transform:SetFourFaced()
    local s = 1.25
    inst.Transform:SetScale(s,s,s)

    inst.entity:AddLightWatcher()
    
    anim:SetBuild("elderdrake_build")  
    anim:SetBank("elderdrake")  

    MakeCharacterPhysics(inst, 50, .5)
    MakePoisonableCharacter(inst)

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = TUNING.MANDRAKEMAN_RUN_SPEED --5
    inst.components.locomotor.walkspeed = TUNING.MANDRAKEMAN_WALK_SPEED --3

    inst:AddTag("character")
    inst:AddTag("pig")
    inst:AddTag("mandrakeman")
    inst:AddTag("scarytoprey")

    inst:AddTag("grumpy")
    
    anim:PlayAnimation("idle_loop")
    anim:Hide("hat")
    anim:Hide("head_happy")

    ------------------------------------------
    inst:AddComponent("eater")
    inst.components.eater:SetVegetarian()
    table.insert(inst.components.eater.foodprefs, "RAW")
    table.insert(inst.components.eater.ablefoods, "RAW")

    ------------------------------------------
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "elderdrake_torso"
    inst.components.combat.panic_thresh = TUNING.MANDRAKEMAN_PANIC_THRESH

    inst.components.combat.GetBattleCryString = battlecry
    inst.components.combat.GetGiveUpString = giveupstring

    MakeMediumBurnableCharacter(inst, "elderdrake_torso")

    inst:AddComponent("named")
    inst.components.named.possiblenames = STRINGS.MANDRAKEMANNAMES
    inst.components.named:PickNewName()
    
    ------------------------------------------
    inst:AddComponent("follower")
    inst.components.follower.maxfollowtime = TUNING.PIG_LOYALTY_MAXTIME
    ------------------------------------------
    inst:AddComponent("health")
    inst.components.health:StartRegen(TUNING.MANDRAKEMAN_HEALTH_REGEN_AMOUNT, TUNING.MANDRAKEMAN_HEALTH_REGEN_PERIOD)

    ------------------------------------------

    inst:AddComponent("inventory")
    
    ------------------------------------------

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"livinglog","livinglog"})
    --inst.components.lootdropper.numrandomloot = 1

    ------------------------------------------

    inst:AddComponent("knownlocations")
    inst:AddComponent("talker")
    inst.components.talker.ontalk = ontalk
    inst.components.talker.fontsize = 24
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.offset = Vector3(0,-500,0)

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
    MakeMediumFreezableCharacter(inst, "pig_torso")
    
    ------------------------------------------

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = function(inst)
        if inst.components.follower.leader ~= nil then
            return "FOLLOWER"
        end
    end
    ------------------------------------------
    
    inst:ListenForEvent("attacked", OnAttacked)    
    inst:ListenForEvent("newcombattarget", OnNewTarget)
    
	--inst.components.werebeast:SetOnWereFn(SetBeardlord)
	--inst.components.werebeast:SetOnNormaleFn(SetNormalRabbit)

    --CheckTransformState(inst)
	inst.OnEntityWake = OnWake
	inst.OnEntitySleep = OnSleep    
    
    
    inst.components.sleeper:SetResistance(2)
    inst.components.sleeper.nocturnal = true

    inst.components.combat:SetDefaultDamage(TUNING.MANDRAKEMAN_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.MANDRAKEMAN_ATTACK_PERIOD)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetRetargetFunction(3, RetargetFn)

    inst.components.locomotor.runspeed = TUNING.MANDRAKEMAN_RUN_SPEED
    inst.components.locomotor.walkspeed = TUNING.MANDRAKEMAN_WALK_SPEED

    inst.components.health:SetMaxHealth(TUNING.MANDRAKEMAN_HEALTH)

    inst:ListenForEvent("death", deathscream)

    inst:ListenForEvent("nighttime", function(world, data) transformtest(inst) end, GetWorld())
    inst:ListenForEvent("daytime", function(world, data) transformtest(inst) end, GetWorld())

    
    inst.components.trader:Enable()
    --inst.Label:Enable(true)
    --inst.components.talker:StopIgnoringAll()


    local brain = require "brains/bunnymanbrain"
    inst:SetBrain(brain)
    inst:SetStateGraph("SGmandrakeman")

    transformtest(inst)

    return inst
end


return Prefab( "common/characters/mandrakeman", fn, assets, prefabs) 
