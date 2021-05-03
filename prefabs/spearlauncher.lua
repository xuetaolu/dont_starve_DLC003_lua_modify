local assets =
{
    Asset("ANIM", "anim/speargun_empty.zip"),

    Asset("ANIM", "anim/swap_speargun_empty.zip"),
    Asset("ANIM", "anim/swap_speargun_spear.zip"),
    Asset("ANIM", "anim/swap_speargun_obsidian.zip"),
    Asset("ANIM", "anim/swap_speargun_poison.zip"),
    Asset("ANIM", "anim/swap_speargun_wathgrithr.zip"),    

    Asset("INV_IMAGE", "spear_launcher_obsidian"),
    Asset("INV_IMAGE", "spear_launcher_spear"),
    Asset("INV_IMAGE", "spear_launcher_poison"),
    Asset("INV_IMAGE", "spear_launcher_wathgrithr"),
}

local prefabs =
{
	"spear_projectile"
}

local function OnEquip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", inst.override_bank, "swap_speargun")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function OnUnequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_object")
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function OnAttack(inst, attacker, target)
    local spear = inst.components.inventory:GetItemInSlot(1)
    if spear then
    	local old = spear.components.weapon.attackwear
    	spear.components.weapon.attackwear = TUNING.SPEAR_LAUNCHER_SPEAR_WEAR
    	spear.components.weapon:OnAttack(attacker, target, true)
    	spear.components.weapon.attackwear = old
    	inst.components.inventory:DropItem(spear, true, false, target:GetPosition(), false, (attacker:GetPosition() - target:GetPosition()):Normalize())
    end
end

local function CanTakeAmmo(inst, ammo, giver)
	return ammo:HasTag("spear")
end

local function OnTakeAmmo(inst, data)
	local ammo = data and data.item
	if not ammo then return end

    inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/speargun_load")

	inst.components.trader.enabled = false
	--Set up as projectile thrower instead of crummy bat
    inst:AddTag("speargun")
    inst:AddTag("projectile")
    inst.components.weapon:SetProjectile("spear_projectile")
    --Change ranges
    inst.components.weapon:SetRange(TUNING.SPEAR_LAUNCHER_ATTACK_RANGE, TUNING.SPEAR_LAUNCHER_HIT_RANGE)
    local damage = ammo.components.weapon.damage * TUNING.SPEAR_LAUNCHER_DAMAGE_MOD
    inst.components.weapon:SetDamage(damage)

    --Change equip overrides
    inst.override_bank = "swap_speargun_"..(ammo.speartype or "spear")

    --If equipped, change current equip overrides
    if inst.components.equippable and inst.components.equippable:IsEquipped() then
        local owner = inst.components.equippable.equipper
        owner.AnimState:OverrideSymbol("swap_object", inst.override_bank, "swap_speargun")
    end
    
    --Change invo image.
    inst.components.inventoryitem:ChangeImageName("spear_launcher_"..(ammo.speartype or "spear"))
end

local function OnLoseAmmo(inst, data)
    inst.components.trader.enabled = true
    --Go back to crummy bat mode
    inst:RemoveTag("speargun")
    inst:RemoveTag("projectile")
	inst.components.weapon:SetProjectile(nil)
	--Change ranges back to melee
    inst.components.weapon:SetRange(nil, nil)
    inst.components.weapon:SetDamage(TUNING.UNARMED_DAMAGE)

	--Change equip overrides
	inst.override_bank = "swap_speargun_empty"

	--If equipped, change current equip overrides
	if inst.components.equippable and inst.components.equippable:IsEquipped() then
		local owner = inst.components.equippable.equipper
	    owner.AnimState:OverrideSymbol("swap_object", inst.override_bank, "swap_speargun")
	end

	inst.components.inventoryitem:ChangeImageName(nil)
end

local function OnFinished(inst)
	inst:Remove()
end

local function OnDropped(inst)
	inst.components.inventory:DropEverything()
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)

    anim:SetBank("speargun")
    anim:SetBuild("speargun_empty")
    anim:PlayAnimation("idle")

    inst:AddComponent("inspectable")

    inst:AddComponent("weapon")
    inst.components.weapon.onattack = OnAttack

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)

    inst:AddComponent("inventory")
    inst.components.inventory.maxslots = 1
    inst:ListenForEvent("dropitem", OnLoseAmmo)
    inst:ListenForEvent("itemget", OnTakeAmmo)

    inst:AddComponent("trader")
    inst.components.trader.deleteitemonaccept = false
    inst.components.trader:SetAcceptTest(CanTakeAmmo)
	inst.components.trader.enabled = true

	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(TUNING.SPEAR_LAUNCHER_USES)
	inst.components.finiteuses:SetUses(TUNING.SPEAR_LAUNCHER_USES)
	inst.components.finiteuses:SetOnFinished(OnFinished)

	inst.override_bank = "swap_speargun_empty"
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

    MakeInventoryFloatable(inst, "idle_water", "idle")

    return inst
end

local function OnHit(inst, attacker, target, weapon)
    local impactfx = SpawnPrefab("impact")
    if impactfx and attacker then
	    local follower = impactfx.entity:AddFollower()
	    follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
        impactfx:FacePoint(attacker.Transform:GetWorldPosition())
    end
    inst:Remove()
end

local function OnThrown(inst, owner, target)
    inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround)
    inst:ForceFacePoint(target:GetPosition():Get())

    --Change projectile art to match spear type.
    local spear = owner.components.inventory:GetItemInSlot(1)
    if spear then
        inst.AnimState:PlayAnimation("spear_"..(spear.speartype or "spear"))
    end
end

local function projectile_fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)

    anim:SetBank("speargun")
    anim:SetBuild("speargun_empty")
    anim:PlayAnimation("spear_spear")

    inst:AddTag("projectile")
    inst:AddTag("sharp")

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(60)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile.onthrown = OnThrown

    inst.persists = false

    return inst
end

return Prefab("spear_launcher", fn, assets, prefabs),
Prefab("spear_projectile", projectile_fn, assets)