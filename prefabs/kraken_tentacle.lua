local assets =
{
    Asset("ANIM", "anim/quacken_tentacle.zip"),
    Asset("MINIMAP_IMAGE", "quacken_tentacle"),
}

local prefabs =
{
    "kraken_tentacle",
}

SetSharedLootTable('kraken_tentacle',
{
    {'tentaclespots', 0.10},
    {'tentaclespike', 0.05},
})

local function Retarget(inst)
    return FindEntity(inst, 7, function(guy) 
        if guy.components.combat and guy.components.health and not guy.components.health:IsDead() then
            return not (guy.prefab == inst.prefab)
        end
    end, nil, {"prey"}, {"character", "monster", "animal"})
end

local function ShouldKeepTarget(inst, target)
    if target and target:IsValid() and target.components.health and not target.components.health:IsDead() then
        local distsq = target:GetDistanceSqToInst(inst)
        return distsq < 100
    else
        return false
    end
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()

    anim:SetBank("quacken_tentacle")
    anim:SetBuild("quacken_tentacle")
    anim:PlayAnimation("enter", true)

    inst:AddTag("kraken")
    inst:AddTag("tentacle")
    inst:AddTag("nowaves")
    inst:AddTag("epic")
    inst:AddTag("noteleport")

    MakePoisonableCharacter(inst)
    MakeCharacterPhysics(inst, 1000, 1)

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("quacken_tentacle.png")

    inst:AddComponent("inspectable")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(90)

    inst:AddComponent("combat")
    inst.components.combat:SetRange(4)
    inst.components.combat:SetDefaultDamage(50)
    inst.components.combat:SetAttackPeriod(6)
    inst.components.combat:SetRetargetFunction(1, Retarget)
    inst.components.combat:SetKeepTargetFunction(ShouldKeepTarget)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('kraken_tentacle')

    inst:AddComponent("locomotor")
    
    inst:SetStateGraph("SGkrakententacle")
    local brain = require("brains/krakententaclebrain")
    inst:SetBrain(brain)

	return inst
end

return Prefab("kraken_tentacle", fn, assets, prefabs)
