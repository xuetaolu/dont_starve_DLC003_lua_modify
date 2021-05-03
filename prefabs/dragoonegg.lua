local assets=
{
	Asset("ANIM", "anim/meteor.zip"),
}

local prefabs = 
{
	"dragoon",
	"rocks",
	"groundpound_fx",
	"groundpoundring_fx",
	"bombsplash",
	"lava_bombsplash",
	"firerainshadow",
	"soundplayer"
}

local loot = 
{
	"flint",
	--"obsidian",
	--"obsidian",
	"rocks",
}

local function DropLoot(inst)
	print("dragoonegg - DropLoot")
	
	if inst.components.hatchable.toohot then
		
	else
		inst.components.lootdropper:SetLoot(loot_cold)
	end
end

local function cracksound(inst, loudness) --is this worth a stategraph?
	inst:DoTaskInTime(11*FRAMES, function(inst)
		inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/dragoon/meteor_shake")
	end)
	inst:DoTaskInTime(24*FRAMES, function(inst)
		inst.SoundEmitter:PlaySoundWithParams("dontstarve_DLC002/creatures/dragoon/meteor_land", {loudness=loudness})
	end)
end

local function cracksmall(inst)
	inst.AnimState:PlayAnimation("crack_small")
	inst.AnimState:PushAnimation("crack_small_idle", true)
	cracksound(inst, 0.2)
end

local function crackmed(inst)
	inst.AnimState:PlayAnimation("crack_med")
	inst.AnimState:PushAnimation("crack_med_idle", true)
	cracksound(inst, 0.5)
end

local function crackbig(inst)
	inst.AnimState:PlayAnimation("crack_big")
	inst.AnimState:PushAnimation("crack_big_idle", true)
	cracksound(inst, 0.7)
end

local function hatch(inst)
	inst.AnimState:PlayAnimation("egg_hatch")
	
	-- inst:ListenForEvent("animover", function(inst) 
	inst:DoTaskInTime(42*FRAMES, function(inst)
		local dragoon = SpawnPrefab("dragoon")
		dragoon.Transform:SetPosition(inst:GetPosition():Get())
		dragoon.components.combat:SuggestTarget(GetPlayer())
		dragoon.sg:GoToState("taunt")
		inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")
		inst.components.lootdropper:DropLoot()
		inst:Remove()
	end)
end

local function groundfn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()
	inst.entity:AddAnimState()
	
	inst.AnimState:SetBuild("meteor")
	inst.AnimState:SetBank("meteor")
	inst.AnimState:PlayAnimation("egg_idle")

	MakeObstaclePhysics(inst, 1.)
	
	inst:AddComponent("inspectable")
	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot(loot)

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.MINE)
	inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE*2)
	
	inst.components.workable:SetOnFinishCallback(
		function(inst, worker)
			inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")
			inst.components.lootdropper:DropLoot()
			inst:Remove()
		end)

	inst:DoTaskInTime(0.25 * TUNING.DRAGOONEGG_HATCH_TIMER, cracksmall)
	inst:DoTaskInTime(0.5 * TUNING.DRAGOONEGG_HATCH_TIMER, crackmed)
	inst:DoTaskInTime(0.75 * TUNING.DRAGOONEGG_HATCH_TIMER, crackbig)
	inst:DoTaskInTime(TUNING.DRAGOONEGG_HATCH_TIMER, hatch)
	
	
	return inst
end

-------
local function playSound(origInst, sound) 
	local interiorSpawner = GetInteriorSpawner()
	if interiorSpawner:IsPlayerConsideredInside() then
		local simulatedPlayerPos = Vector3(interiorSpawner:GetInteriorEntryPosition())
		local delta = simulatedPlayerPos - origInst:GetPosition()
		local proxyPos = GetPlayer():GetPosition() + delta
		local proxy = SpawnPrefab("soundplayer")
		proxy.PlaySound(proxyPos, sound)
	else
		origInst.SoundEmitter:PlaySound(sound)
	end
end


local function DoStep(inst)
	local player = GetPlayer()
	local pos = player:GetPosition()
	local interiorSpawner = GetInteriorSpawner()
	local isInside = false
	if interiorSpawner:IsPlayerConsideredInside() then
		pos = Vector3(interiorSpawner:GetInteriorEntryPosition())
		isInside = true
	end

	local distToPlayer = inst:GetPosition():Dist(pos)
	local power = Lerp(3, 1, distToPlayer/180)

	local map = GetWorld().Map
	local x, y, z = inst.Transform:GetLocalPosition()
	local ground = map:GetTile(map:GetTileCoordsAtPoint(x, y, z))

	if ground == GROUND.VOLCANO_LAVA then
		local fx = SpawnPrefab("lava_bombsplash")
		fx.Transform:SetPosition(x, y, z)
		inst:Remove()
	elseif ground == GROUND.IMPASSABLE then
		local fx = SpawnPrefab("clouds_bombsplash")
		fx.Transform:SetPosition(x, y, z)
		inst:Remove()
	elseif map:IsWater(ground) then
		local fx = SpawnPrefab("bombsplash")
		fx.Transform:SetPosition(x, y, z)
		SpawnWaves(inst, 8, 360, 6)
		playSound(inst, "dontstarve_DLC002/common/volcano/volcano_rock_splash")
		--inst.components.groundpounder.numRings = 0
		inst.components.groundpounder.burner = false
		inst.components.groundpounder.groundpoundfx = nil
		inst.components.groundpounder.onfinished = function(inst)
			inst:Remove()
		end
		inst.components.groundpounder:GroundPound()
	else
		playSound(inst, "dontstarve_DLC002/common/volcano/volcano_rock_smash")
		inst.components.groundpounder.numRings = 4
		inst.components.groundpounder.burner = true
		if GetInteriorSpawner():IsPlayerConsideredInside() then
			inst.components.groundpounder.groundpoundfx = nil
    		inst.components.groundpounder.groundpoundringfx = nil
		end
		inst.components.groundpounder.onfinished = function(inst)
			if inst:IsPosSurroundedByLand(x, y, z, 2) then
				local lava = SpawnPrefab("dragoonegg")
				if not GetInteriorSpawner():IsPlayerConsideredInside() then
					lava.AnimState:PlayAnimation("egg_crash")
					lava.AnimState:PushAnimation("egg_idle", false)
				else
					lava.AnimState:PlayAnimation("egg_idle")
				end
				lava.Transform:SetPosition(x, y, z)
			end
			inst:Remove()
		end
		inst.components.groundpounder:GroundPound()
	end

	player.components.playercontroller:ShakeCamera(player, "VERTICAL", 0.5, 0.03, power, 40) 
end

local function roundToNearest(numToRound, multiple)
	local half = multiple/2
	return numToRound+half - (numToRound+half) % multiple
end

local function SimulateStep(inst)
	inst:DoTaskInTime(TUNING.VOLCANO_FIRERAIN_WARNING, function(inst) 
		inst:DoStep()
		inst:Remove()
	end)
end

local function StartStep(inst)
	local shadow = SpawnPrefab("firerainshadow")
	shadow.Transform:SetPosition(inst:GetPosition():Get())
	shadow.Transform:SetRotation(math.random(0, 360))--(GetRotation(inst))
	playSound(inst, "dontstarve_DLC002/common/bomb_fall")

	inst:DoTaskInTime(TUNING.VOLCANO_FIRERAIN_WARNING - (7*FRAMES), DoStep)
	inst:DoTaskInTime(TUNING.VOLCANO_FIRERAIN_WARNING - (17*FRAMES), function(inst)
		inst:Show()
		local pt = inst:GetPosition()
		local ground = GetMap():GetTileAtPoint(pt.x, 0, pt.z)
		if ground == GROUND.IMPASSABLE or GetMap():IsWater(ground) then
			inst.AnimState:PlayAnimation("idle")
		else
			inst.AnimState:PlayAnimation("egg_crash_pre")
		end
	end)
end

local function fallingfn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()

	trans:SetFourFaced()

	anim:SetBank("meteor")
	anim:SetBuild("meteor")

	inst:AddTag("FX")

	inst:AddComponent("groundpounder")
	inst.components.groundpounder.numRings = 4
	inst.components.groundpounder.ringDelay = 0.1
	inst.components.groundpounder.initialRadius = 1
	inst.components.groundpounder.radiusStepDistance = 2
	inst.components.groundpounder.pointDensity = .25
	inst.components.groundpounder.damageRings = 2
	inst.components.groundpounder.destructionRings = 3
	inst.components.groundpounder.destroyer = true
	inst.components.groundpounder.burner = true
	inst.components.groundpounder.ring_fx_scale = 0.75

	inst:AddComponent("combat")
	inst.components.combat:SetDefaultDamage(TUNING.VOLCANO_FIRERAIN_DAMAGE)

	inst.DoStep = DoStep
	inst.StartStep = StartStep

	inst:Hide()

	return inst
end


return Prefab( "common/inventory/dragoonegg", groundfn, assets, prefabs),
	   Prefab( "common/inventory/dragoonegg_falling", fallingfn, assets, prefabs)
