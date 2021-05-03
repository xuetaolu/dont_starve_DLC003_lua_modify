
local assets=
{
	Asset("ANIM", "anim/stinkray.zip"),
	Asset("SOUND", "sound/bat.fsb"),
	Asset("MINIMAP_IMAGE", "stinkray"),
}

local prefabs =
{
	"venomgland",
	"poisonbubble_short",
	"monstermeat",
	"splash_water",
}

local SLEEP_DIST_FROMHOME = 1
local SLEEP_DIST_FROMTHREAT = 20
local MAX_CHASEAWAY_DIST = 80
local MAX_TARGET_SHARES = 5
local SHARE_TARGET_DIST = 30


local function KeepThreat(inst, threat)
	return threat:GetIsOnWater(threat:GetPosition():Get()) -- and not (threat.components.poisonable and threat.components.poisonable:IsPoisoned())
end

local function MakeTeam(inst, attacker)
	local leader = SpawnPrefab("teamleader")
	leader:AddTag("stungray")
	leader.components.teamleader.threat = attacker
	leader.components.teamleader.team_type = inst.components.teamattacker.team_type
	leader.components.teamleader:NewTeammate(inst)
	leader.components.teamleader:BroadcastDistress(inst)
	leader.components.teamleader:SetKeepThreatFn(KeepThreat)
end

local function Retarget(inst)
	local ta = inst.components.teamattacker
	local notags = {"FX", "NOCLICK","INLIMBO", "stungray"}
	local yestags = {"monster", "character"}

	local newtarget = FindEntity(inst, TUNING.STINKRAY_TARGET_DIST, function(guy)
			return (guy:HasTag("character") or guy:HasTag("monster") )
				   and not guy:HasTag("stungray")
				   and inst.components.combat:CanTarget(guy)
				   and guy:GetIsOnWater(guy:GetPosition():Get())
				   -- and (guy.components.poisonable == nil or not guy.components.poisonable:IsPoisoned())
	end, nil, notags, yestags)

	if newtarget and not ta.inteam and not ta:SearchForTeam() then
		MakeTeam(inst, newtarget)
	end

	if ta.inteam and not ta.teamleader:CanAttack() then
		return newtarget
	end
end

local function KeepTarget(inst, target)
	if not target:GetIsOnWater(target:GetPosition():Get()) then return false end
	-- if target.components.poisonable and target.components.poisonable:IsPoisoned() then return false end

	if (inst.components.teamattacker.teamleader and not inst.components.teamattacker.teamleader:CanAttack()) or inst.components.teamattacker.orders == "ATTACK" then
		return true
	else
		return false
	end
end

local function OnAttacked(inst, data)
	if not inst.components.teamattacker.inteam and not inst.components.teamattacker:SearchForTeam() then
		MakeTeam(inst, data.attacker)
	elseif inst.components.teamattacker.teamleader then
		inst.components.teamattacker.teamleader:BroadcastDistress()   --Ask for  help!
	end

	if inst.components.teamattacker.inteam and not inst.components.teamattacker.teamleader:CanAttack() then
		local attacker = data and data.attacker
		inst.components.combat:SetTarget(attacker)
		inst.components.combat:ShareTarget(attacker, SHARE_TARGET_DIST, function(dude) return dude:HasTag("stungray") end, MAX_TARGET_SHARES)
	end
end

local function OnCombatTarget(inst, data)
	--If you're in a team or have a combat target then run.
	if (data and data.target) or inst.components.teamattacker.inteam then
		inst.components.locomotor:SetShouldRun(true)
	else
		inst.components.locomotor:SetShouldRun(false)
	end
end

local function OnHitOther(inst, other, damage, stimuli)
	local prefab = SpawnPrefab("poisonbubble_short")
	prefab.Transform:SetPosition(inst:GetPosition():Get())

	inst.components.areapoisoner:DoPoison(true)
end

local function SetLocoState(inst, state)
	--"gotofly" or "gotoswim"
	inst.LocoState = string.lower(state)
end

local function IsLocoState(inst, state)
	return inst.LocoState == string.lower(state)
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 1.75, .6 )
	shadow:Enable(false)

	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.Transform:SetNoFaced()

	inst.scale_flying = TUNING.STINKRAY_SCALE_FLYING
	inst.scale_water = TUNING.STINKRAY_SCALE_WATER
	inst.Transform:SetScale(inst.scale_water, inst.scale_water, inst.scale_water)

	MakeGhostPhysics(inst, 1, .5)

	anim:SetBank("stinkray")
	anim:SetBuild("stinkray")

	inst:AddComponent("locomotor")
	inst.components.locomotor:SetSlowMultiplier( 1 )
	inst.components.locomotor:SetTriggersCreep(false)
	inst.components.locomotor.pathcaps = { ignorecreep = true }
	inst.components.locomotor.walkspeed = TUNING.STINKRAY_WALK_SPEED


	inst:AddTag("aquatic")
	inst:AddTag("monster")
	inst:AddTag("hostile")
	inst:AddTag("stungray")
	inst:AddTag("scarytoprey")
	inst:AddTag("flying")

	inst:AddComponent("eater")
	inst.components.eater:SetCarnivore()
	inst.components.eater.strongstomach = true

	inst:AddComponent("sleeper")
	inst.components.sleeper:SetResistance(2)
	inst.components.sleeper:SetNocturnal(true)
	inst.components.sleeper.onlysleepsfromitems = true 


	inst:AddComponent("combat")
	inst.components.combat.hiteffectsymbol = "bat_body"
	inst.components.combat:SetAttackPeriod(TUNING.STINKRAY_ATTACK_PERIOD)
	inst.components.combat:SetRange(TUNING.STINKRAY_ATTACK_DIST)
	inst.components.combat:SetRetargetFunction(3, Retarget)
	inst.components.combat:SetKeepTargetFunction(KeepTarget)
	inst.components.combat.poisonous = true
	inst.components.combat.gasattack = true 
	inst.components.combat:SetOnHitOther(OnHitOther)
	inst.components.combat:SetDefaultDamage(0)

	MakeAreaPoisoner(inst, 3)

	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(TUNING.STINKRAY_HEALTH)

	inst:AddComponent("lootdropper")
	inst.components.lootdropper:AddRandomLoot("venomgland", 1)   
	inst.components.lootdropper:AddRandomLoot("monstermeat", 2)
	inst.components.lootdropper.numrandomloot = 1

	inst:AddComponent("inventory")

	inst:AddComponent("inspectable")
	inst:AddComponent("knownlocations")

	inst:DoTaskInTime(1*FRAMES, function() inst.components.knownlocations:RememberLocation("home", Vector3(inst.Transform:GetWorldPosition()), true) end)

	MakeMediumBurnableCharacter(inst, "ray_face")
	MakeMediumFreezableCharacter(inst, "ray_face")

	inst:AddComponent("teamattacker")
	inst.components.teamattacker.team_type = "stungray"
	inst.components.teamattacker.run = true

	inst:ListenForEvent("attacked", OnAttacked)
	inst:ListenForEvent("newcombattarget", OnCombatTarget)
	inst:ListenForEvent("losttarget", OnCombatTarget)

	SetLocoState(inst, "swim")
	inst.SetLocoState = SetLocoState
	inst.IsLocoState = IsLocoState

	inst:SetStateGraph("SGStungray")
	local brain = require "brains/stungraybrain"
	inst:SetBrain(brain)

	return inst
end

return Prefab("forest/monsters/stungray", fn, assets, prefabs)
