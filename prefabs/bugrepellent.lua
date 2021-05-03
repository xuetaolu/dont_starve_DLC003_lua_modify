local assets=
{
    Asset("ANIM", "anim/bugrepellent.zip"),
    Asset("ANIM", "anim/swap_bugrepellent.zip"),
}

local prefabs =
{
    "impact",
    "gascloud",
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_bugrepellent", "swap_bugrepellent")
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

local function onfinished(inst)
    inst:Remove()
end


local function commonfn()


	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    --inst.Transform:SetFourFaced()
    anim:SetBank("bugrepellent")
    anim:SetBuild("bugrepellent")

    inst:AddTag("bugrepellent")
--[[
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SPEARGUN_DAMAGE)
    inst.components.weapon:SetRange(12, 14)
]]

    inst:AddTag("nopunch")

    inst:AddComponent("gasser")    

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.equipstack = true

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.BUGREPELLENT_USES)
    inst.components.finiteuses:SetUses(TUNING.BUGREPELLENT_USES)
    inst.components.finiteuses:SetOnFinished( onfinished )    
    inst.components.finiteuses:SetConsumption(ACTIONS.GAS, 1)

    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "idle_water", "idle")

    return inst
end

return Prefab( "common/inventory/bugrepellent", commonfn, assets, prefabs)

