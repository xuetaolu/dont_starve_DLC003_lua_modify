
local assets =
{
	Asset("ANIM", "anim/meteor.zip"),
	Asset("ANIM", "anim/meteor_shadow.zip")
}

local prefabs =
{
	"lavapool",
    "groundpound_fx",
    "groundpoundring_fx",
    "bombsplash",
    "lava_bombsplash",
    "clouds_bombsplash",
    "firerainshadow",
    "meteor_impact",
	"soundplayer"
}

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
	elseif ground == GROUND.IMPASSABLE then
		local fx = SpawnPrefab("clouds_bombsplash")
		fx.Transform:SetPosition(x, y, z)
	elseif map:IsWater(ground) then
		local fx = SpawnPrefab("bombsplash")
		fx.Transform:SetPosition(x, y, z)
		SpawnWaves(inst, 8, 360, 6)
		playSound(inst, "dontstarve_DLC002/common/volcano/volcano_rock_splash")
		inst.components.groundpounder.burner = false
		inst.components.groundpounder.groundpoundfx = nil 
		inst.components.groundpounder:GroundPound()
	else
		if inst:IsPosSurroundedByLand(x, y, z, 2) then
			if math.random() < TUNING.VOLCANO_FIRERAIN_LAVA_CHANCE then
				local lavapool = SpawnPrefab("lavapool")
				lavapool.Transform:SetPosition(x, y, z)
			else
				local impact = SpawnPrefab("meteor_impact")
				impact.components.timer:StartTimer("remove", TUNING.TOTAL_DAY_TIME * 2)
				impact.Transform:SetPosition(x, y, z)
			end
		end
		playSound(inst, "dontstarve_DLC002/common/volcano/volcano_rock_smash")
		inst.components.groundpounder.numRings = 4
		inst.components.groundpounder.burner = true
		inst.components.groundpounder:GroundPound()
	
		if isInside then
			inst.components.groundpounder.groundpoundfx = nil
    		inst.components.groundpounder.groundpoundringfx = nil
		end
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
	--inst:Hide()
	inst:DoTaskInTime(TUNING.VOLCANO_FIRERAIN_WARNING - (5*FRAMES), function(inst) inst:DoStep() end)
	inst:DoTaskInTime(TUNING.VOLCANO_FIRERAIN_WARNING - (14*FRAMES), function(inst)
		if not GetInteriorSpawner():IsPlayerConsideredInside() then
			if not GetInteriorSpawner():IsPlayerConsideredInside() then
				inst:Show()
				inst.AnimState:PlayAnimation("idle")
				inst:ListenForEvent("animover", function(inst) inst:Remove() end)
			end
		end
	end)
end

local function StartStepWithDelay(inst, delay)
	if inst.startsteptask then
		inst.startsteptask:Cancel()
		inst.startsteptask = nil
	end

	inst.startsteptask = inst:DoTaskInTime(delay, function () inst.StartStep(inst) end)
end

local function firerainfn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()

	trans:SetFourFaced()

	anim:SetBank("meteor")
	anim:SetBuild("meteor")
	--anim:PlayAnimation("idle")

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
	inst.StartStepWithDelay = StartStepWithDelay

	inst:Hide()

	return inst
end

local easing = require("easing")
local function LerpIn(inst)
	local s = easing.inExpo(inst:GetTimeAlive(), 1, 1 - inst.StartingScale, inst.TimeToImpact)

	inst.Transform:SetScale(s,s,s)
	if s >= inst.StartingScale then
		inst.sizeTask:Cancel()
		inst.sizeTask = nil
	end
end

local function OnRemove(inst)
	if inst.sizeTask then
		inst.sizeTask:Cancel()
		inst.sizeTask = nil
	end

	if inst.startsteptask then
		inst.startsteptask:Cancel()
		inst.startsteptask = nil
	end
end

local function Impact(inst)
	inst:Remove()
end

local function shadowfn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

	anim:SetBank("meteor_shadow")
	anim:SetBuild("meteor_shadow")
	anim:PlayAnimation("idle")
	anim:SetOrientation( ANIM_ORIENTATION.OnGround )
	anim:SetLayer( LAYER_BACKGROUND )
	anim:SetSortOrder( 3 )

	inst:AddTag("FX")

	inst.persists = false
	
	local s = 2
	inst.StartingScale = s
	inst.Transform:SetScale(s,s,s)
	inst.TimeToImpact = TUNING.VOLCANO_FIRERAIN_WARNING

	inst:AddComponent("colourtweener")
	inst.AnimState:SetMultColour(0,0,0,0)
	inst.components.colourtweener:StartTween({0,0,0,1}, inst.TimeToImpact, Impact)

	inst.OnRemoveEntity = OnRemove

	inst.sizeTask = inst:DoPeriodicTask(FRAMES, LerpIn)

	return inst
end

return Prefab("common/shipwrecked/firerain", firerainfn, assets, prefabs),
		Prefab("common/shipwrecked/firerainshadow", shadowfn, assets, prefabs)
