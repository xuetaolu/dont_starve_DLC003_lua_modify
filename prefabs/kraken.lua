local assets =
{
    Asset("ANIM", "anim/quacken.zip"),
    Asset("MINIMAP_IMAGE", "quacken"),
}

local prefabs =
{
    "kraken_tentacle",
    "kraken_projectile",
    "kraken_inkpatch",
    "krakenchest",
}

SetSharedLootTable('kraken',
{
    {"piratepack", 1.00},
})

local MIN_HEALTH = 
{
	0.75,
	0.50,
	0.25,
	-1.0,
}

local function MoveToNewSpot(inst)
	local pos = inst:GetPosition()
	local offset = FindWaterOffset(pos, math.pi * 2 * math.random(), 40, 30)
	local new_pos = pos + offset
	inst:PushEvent("move", {pos = new_pos})
end

local function OnMinHealth(inst, data)
    if not inst.components.health:IsDead() then
    	inst.health_stage = inst.health_stage + 1
    	inst.health_stage = math.min(inst.health_stage, #MIN_HEALTH)
    	inst.components.health:SetMinHealth(inst.components.health:GetMaxHealth() * MIN_HEALTH[inst.health_stage])
    	MoveToNewSpot(inst)
    end
end

local RND_OFFSET = 10

local function OnAttack(inst, data)
    local numshots = 3
    if data.target then
        for i = 1, numshots do
            local offset = Vector3(math.random(-RND_OFFSET, RND_OFFSET), math.random(-RND_OFFSET, RND_OFFSET), math.random(-RND_OFFSET, RND_OFFSET))
            inst.components.thrower:Throw(data.target:GetPosition() + offset)
        end
    end
end

local function Retarget(inst)
    return FindEntity(inst, 40, function(guy) 
        if guy.components.combat and guy.components.health and not guy.components.health:IsDead() then
            return not (guy.prefab == inst.prefab)
        end
    end, nil, {"prey"}, {"character", "monster", "animal"})
end

local function ShouldKeepTarget(inst, target)
    if target and target:IsValid() and target.components.health and not target.components.health:IsDead() then
        local distsq = target:GetDistanceSqToInst(inst)
        return distsq < 1600
    else
        return false
    end
end

local function SpawnChest(inst)
    inst:DoTaskInTime(3, function()
        inst.SoundEmitter:PlaySound("dontstarve/common/ghost_spawn")
        
        local chest = SpawnPrefab("krakenchest")
        local pos = inst:GetPosition()
        chest.Transform:SetPosition(pos.x, 0, pos.z)

        local fx = SpawnPrefab("statue_transition_2")
        if fx then
            fx.Transform:SetPosition(inst:GetPosition():Get())
            fx.AnimState:SetScale(1,2,1)
        end

        fx = SpawnPrefab("statue_transition")
        if fx then
            fx.Transform:SetPosition(inst:GetPosition():Get())
            fx.AnimState:SetScale(1,1.5,1)
        end

        chest:AddComponent("scenariorunner")
        chest.components.scenariorunner:SetScript("chest_kraken")
        chest.components.scenariorunner:Run()
    end)
end

local function OnRemove(inst)
    inst.components.minionspawner:DespawnAll()
end

local function OnSave(inst, data)
	data.health_stage = inst.health_stage
end

local function OnLoad(inst, data)
	if data.health_stage then
		inst.health_stage = data.health_stage or inst.health_stage
		inst.components.health:SetMinHealth(inst.components.health:GetMaxHealth() * MIN_HEALTH[inst.health_stage])
	end
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()

    anim:SetBank("quacken")
    anim:SetBuild("quacken")
    anim:PlayAnimation("idle_loop", true)

    inst:AddTag("kraken")
    inst:AddTag("nowaves")
    inst:AddTag("epic")
    inst:AddTag("noteleport")
    inst:AddTag("seacreature")

    MakePoisonableCharacter(inst)
    MakeCharacterPhysics(inst, 1000, 1)

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("quacken.png")

    inst:AddComponent("inspectable")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(1000)
    inst.components.health.nofadeout = true

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(0)
    inst.components.combat:SetAttackPeriod(7.5)
    inst.components.combat:SetRange(40,50)
    inst.components.combat:SetRetargetFunction(1, Retarget)
    inst.components.combat:SetKeepTargetFunction(ShouldKeepTarget)

    inst:AddComponent("sanityaura")    
    inst:AddComponent("locomotor")

    inst:AddComponent("minionspawner")
    inst.components.minionspawner.validtiletypes = {GROUND.OCEAN_SHALLOW, GROUND.OCEAN_MEDIUM, GROUND.OCEAN_DEEP, GROUND.OCEAN_CORAL, GROUND.MANGROVE, GROUND.OCEAN_SHIPGRAVEYARD}
    inst.components.minionspawner.miniontype = "kraken_tentacle"
    inst.components.minionspawner.distancemodifier = 35
    inst.components.minionspawner.maxminions = 45
	inst.components.minionspawner:RegenerateFreePositions()
	inst.components.minionspawner.shouldspawn = false

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('kraken')

	inst:AddComponent("thrower")
	inst.components.thrower.throwable_prefab = "kraken_projectile"

    inst:SetStateGraph("SGkraken")
    local brain = require("brains/krakenbrain")
    inst:SetBrain(brain)

    inst.health_stage = 1

    inst:ListenForEvent("minhealth", OnMinHealth)
    inst.components.health:SetMinHealth(inst.components.health:GetMaxHealth() * MIN_HEALTH[inst.health_stage])
    inst:ListenForEvent("death", SpawnChest)
    inst:ListenForEvent("onattackother", OnAttack)
    inst:ListenForEvent("onremove", OnRemove)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

	return inst
end

return Prefab("kraken", fn, assets, prefabs)
