local assets=
{
    Asset("ANIM", "anim/speargun.zip"),
    Asset("ANIM", "anim/swap_speargun.zip"),

    Asset("ANIM", "anim/speargun_obsidian.zip"),
    Asset("ANIM", "anim/swap_speargun_obsidian.zip"),

    Asset("ANIM", "anim/speargun_poison.zip"),
    Asset("ANIM", "anim/swap_speargun_poison.zip"),
}

local prefabs =
{
    "impact",
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_speargun", "swap_speargun")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_object")
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function onhit(inst, attacker, target)
    local impactfx = SpawnPrefab("impact")
    if impactfx and attacker then
	    local follower = impactfx.entity:AddFollower()
	    follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0 )
        impactfx:FacePoint(attacker.Transform:GetWorldPosition())
    end
    inst:Remove()
end

local function onthrown(inst, data)
    inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
    inst.AnimState:PlayAnimation("speargun")
end

local function poisonattack(inst, attacker, target)
    if target.components.poisonable then
        target.components.poisonable:Poison()
    end
    if target.components.combat then
        target.components.combat:SuggestTarget(attacker)
    end
    if target.sg and target.sg.sg.states.hit then
        target.sg:GoToState("hit")
    end
end


local function commonfn()


	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    --inst.Transform:SetFourFaced()
    anim:SetBank("speargun")
    anim:SetBuild("speargun")

    inst:AddTag("speargun")
    inst:AddTag("sharp")
    inst:AddTag("projectile")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SPEARGUN_DAMAGE)
    inst.components.weapon:SetRange(12, 14)

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(60)
    inst.components.projectile:SetOnHitFn(onhit)
    inst:ListenForEvent("onthrown", onthrown)
    -------

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("stackable")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.equipstack = true

    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "idle_water", "idle")

    return inst
end

local function onequippoison(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_speargun_poison", "swap_speargun")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function poisonfn(Sim)
    local inst = commonfn(Sim)

    inst.AnimState:SetBuild("speargun_poison")
    inst.AnimState:SetBank("speargun")

    inst.components.weapon:SetOnAttack(poisonattack)
    inst.components.equippable:SetOnEquip( onequippoison)

    return inst
end

local function onequipobsidian(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_speargun_obsidian", "swap_speargun")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function fireattack(inst, attacker, target)
    if target.components.freezable then
        target.components.freezable:Unfreeze()
    end
    if target.components.combat then
        target.components.combat:SuggestTarget(attacker)
    end
    target:PushEvent("attacked", {attacker = attacker, damage = 0})
end

local function obsidianfn(Sim)
    local inst = commonfn(Sim)

    inst.entity:AddSoundEmitter()

    --inst.components.floatable:SetOnHitWaterFn(function(inst)
    --    inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/obsidian_wetsizzles")
    --end)

    inst.AnimState:SetBuild("speargun_obsidian")
    inst.AnimState:SetBank("speargun_obsidian")
    inst.components.equippable:SetOnEquip( onequipobsidian )

    --inst:AddTag("obsidian")
    --inst:AddTag("notslippery")
	--inst.no_wet_prefix = true

    inst.components.weapon:SetOnAttack(fireattack)

    --MakeObsidianTool(inst)

    return inst
end

return Prefab( "common/inventory/speargun", commonfn, assets, prefabs),
       Prefab( "common/inventory/speargun_poison", poisonfn, assets, prefabs),
       Prefab( "common/inventory/obsidianspeargun", obsidianfn, assets, prefabs)
