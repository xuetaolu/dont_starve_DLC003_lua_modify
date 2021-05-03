require "brains/shadowwaxwellbrain"
require "stategraphs/SGshadowwaxwell"

local assets = 
{
    Asset("ANIM", "anim/waxwell_shadow_mod.zip"),
	Asset("SOUND", "sound/maxwell.fsb"),
	Asset("ANIM", "anim/swap_pickaxe.zip"),
    Asset("ANIM", "anim/swap_axe.zip"),
	Asset("ANIM", "anim/swap_machete.zip"),
    Asset("ANIM", "anim/swap_nightmaresword.zip"),
}

local prefabs = 
{
    "shadowwaxwell_boat",
}

local items =
{
	AXE = "swap_axe",
	PICK = "swap_pickaxe",
    SWORD = "swap_nightmaresword",
    MACHETE = "swap_machete",
}

local function ondeath(inst)
	inst.components.sanityaura.penalty = 0
	local player = GetPlayer()
	if player then
		player.components.sanity:RecalculatePenalty()
	end
end

local function EquipItem(inst, item)
	if item then
	    inst.AnimState:OverrideSymbol("swap_object", item, item)
	    inst.AnimState:Show("ARM_carry") 
	    inst.AnimState:Hide("ARM_normal")
	end
end

local function die(inst)
	inst.components.health:Kill()
end

local function resume(inst, time)
    if inst.death then
        inst.death:Cancel()
        inst.death = nil
    end
    inst.death = inst:DoTaskInTime(time, die)
end

local function onsave(inst, data)
    data.timeleft = (inst.lifetime - inst:GetTimeAlive())

    local refs = {}
    if inst.boat then
        data.boat = inst.boat.GUID
        table.insert(refs, inst.boat.GUID)
    end
    return refs
end

local function KeepTarget(isnt, target)

    if target.components.health and target.components.health.invincible then
        return false
    end

    return target and target:IsValid()
end

local function onload(inst, data)
    if data.timeleft then
        inst.lifetime = data.timeleft
        if inst.lifetime > 0 then
            resume(inst, inst.lifetime)
        else
            die(inst)
        end
    end
end

local function onloadpostpass(inst, ents, data)
    if inst.boat == nil and data.boat and ents[data.boat] then
        inst.boat = ents[data.boat].entity
    end
end

local function entitydeathfn(inst, data)
    if data.inst:HasTag("player") then
        inst:DoTaskInTime(math.random(), function() inst.components.health:Kill() end)
    end
end

local function onstopfollow(inst, data)
    local leader = data.leader

    inst:RemoveEventCallback("mountboat", inst.mountfn, leader)
    inst:RemoveEventCallback("dismountboat", inst.dismountfn, leader)

    --If you're not following anything then something has gone wrong... just remove yourself
    inst.components.health:Kill()
end

local function shadowboatfx(pos)
    SpawnPrefab("statue_transition").Transform:SetPosition(pos:Get())
    SpawnPrefab("statue_transition_2").Transform:SetPosition(pos:Get())
end

local function onremove(inst)
    if inst.boat then
        shadowboatfx(inst.boat:GetPosition())
        inst.boat:Remove()
        inst.boat = nil
    end
end

local function spawnshadowboat(inst, pos)
    if inst.boat == nil then
        inst.boat = SpawnPrefab("shadowwaxwell_boat")
        inst.boat.Transform:SetPosition(pos:Get())
        shadowboatfx(pos)
    end
end

local function onstartfollow(inst, data)
    local leader = data.leader

    inst.mountfn = function()  
        local offset = FindWaterOffset(leader:GetPosition(), math.random() * 2*PI, 5, 36) or Vector3(0,0,0)
        local pos = leader:GetPosition() + offset
        spawnshadowboat(inst, pos)
    end
    
    inst.dismountfn = function() 
        if inst.boat then
            inst.boat:ListenForEvent("dismounted", function() onremove(inst) end)
        end
    end

    inst:ListenForEvent("mountboat", inst.mountfn, leader)
    inst:ListenForEvent("dismountboat", inst.dismountfn, leader)
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()

	inst.Transform:SetFourFaced(inst)

	MakeGhostPhysics(inst, 1, .5)

	anim:SetBank("wilson")
	anim:SetBuild("waxwell_shadow_mod")
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

    inst:AddTag("amphibious")
    inst:AddTag("scarytoprey")
    --inst:AddTag("NOCLICK")

	inst:AddComponent("colourtweener")
	inst.components.colourtweener:StartTween({0,0,0,.5}, 0)

	inst:AddComponent("locomotor")
    inst.components.locomotor:SetSlowMultiplier( 0.6 )
    inst.components.locomotor.pathcaps = { ignorecreep = true }
    inst.components.locomotor.runspeed = TUNING.SHADOWWAXWELL_SPEED

    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "torso"
    -- inst.components.combat:SetRetargetFunction(1, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetAttackPeriod(TUNING.SHADOWWAXWELL_ATTACK_PERIOD)
    inst.components.combat:SetRange(2, 3)
    inst.components.combat:SetDefaultDamage(TUNING.SHADOWWAXWELL_DAMAGE)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.SHADOWWAXWELL_LIFE)
    inst.components.health.nofadeout = true
    inst:ListenForEvent("death", ondeath)

	inst:AddComponent("inventory")
    inst.components.inventory.dropondeath = false

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.penalty = TUNING.SHADOWWAXWELL_SANITY_PENALTY

    inst:AddComponent("driver")
    inst.components.driver.landstategraph = "SGshadowwaxwell"
    inst.components.driver.boatingstategraph = "SGshadowwaxwellboating"

    inst.items = items
    inst.equipfn = EquipItem

    inst.lifetime = TUNING.SHADOWWAXWELL_LIFETIME
    inst.death = inst:DoTaskInTime(inst.lifetime, die)

    inst.OnSave = onsave
    inst.OnLoad = onload
    inst.OnLoadPostPass = onloadpostpass
    inst.SpawnShadowBoat = spawnshadowboat

    EquipItem(inst)

    inst:ListenForEvent("entity_death", function(world, data) entitydeathfn(inst, data) end, GetWorld())

    inst:AddComponent("follower")

	local brain = require"brains/shadowwaxwellbrain"
	inst:SetBrain(brain)
	inst:SetStateGraph("SGshadowwaxwell")

    inst:ListenForEvent("startfollowing", onstartfollow)
    inst:ListenForEvent("stopfollowing", onstopfollow)
    inst:ListenForEvent("onremove", onremove)


	return inst
end

return Prefab("common/shadowwaxwell", fn, assets, prefabs)
