local assets =
{
	Asset("ANIM", "anim/swap_trusty_shooter.zip"),
    Asset("ANIM", "anim/trusty_shooter.zip"),
    Asset("INV_IMAGE", "trusty_shooter_unloaded"),
    Asset("MINIMAP_IMAGE", "trusty_shooter"),  
}

local AMMO_CAPACITY = 6

----------------------------------------------------------------------------------------------
---------------------------------- SPECIAL SLOT CODE -----------------------------------------

local function oncontrolfn (tile, control, down)
    if down then
        if control == CONTROL_ACCEPT then
            local active_item = GetPlayer().components.inventory:GetActiveItem()

            if not tile.owner or (tile.owner and tile.owner.components.equippable.un_unequipable) or (active_item and active_item:HasTag("irreplaceable")  )then
                return 
            end

            if active_item then
                if tile.owner.components.weapon.projectile == nil or (tile.owner.components.weapon.projectile == active_item.prefab and active_item.components.stackable) then
                    if tile.owner.CanTakeItem and tile.owner.CanTakeItem(tile.owner, active_item) and tile.owner.TakeItem then
                        tile.owner.TakeItem(tile.owner, active_item)
                    end
                else
                    local trade_item = tile.owner.components.inventory:RemoveItemBySlot(1)
                    trade_item.components.inventoryitem.candrop = true
                    tile:OnItemLose()

                    GetPlayer().components.inventory:GiveActiveItem(trade_item)
                    
                    tile.owner.TakeItem(tile.owner, active_item, true)
                end
            else
                local trade_item = tile.owner.components.inventory:RemoveItemBySlot(1)
                if trade_item then
                    tile:OnItemLose()
                    tile.owner.ammo = 0
                    trade_item.components.inventoryitem.candrop = true
                    tile.owner.ResetAmmo(tile.owner)
                    GetPlayer().components.inventory:GiveActiveItem(trade_item)
                end
            end

            return true
        end
    end
end

----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------

local function CheckSpecialSlotStatus(inst, player)
    if not player.HUD.controls.inv:GetSpecialSlot("trusty_shooter") then
        player.HUD.controls.inv:AddSpecialSlot("trusty_shooter", inst) 
        player.HUD.controls.inv:SetSpecialSlotFn("trusty_shooter", nil, oncontrolfn, nil, nil)
    end
end

local function onequip(inst, owner, force)
    owner.AnimState:OverrideSymbol("swap_object", inst.override_bank, "swap_trusty_shooter")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    local function setspecialslot()
        CheckSpecialSlotStatus(inst, owner)
        owner.HUD.controls.inv:SetSpecialSlotActive("trusty_shooter", true, inst)
        local item = inst.components.inventory:GetItemInSlot(1)
        if item then
            owner.HUD.controls.inv:GetSpecialSlot("trusty_shooter"):OnItemGet(item)
        end
    end

    if owner and owner.HUD then
        setspecialslot()
    else
    --Needs to be in place because this can be called before the HUD exists
        inst:DoTaskInTime(0, function() setspecialslot() end)
    end
end

local function onunequip(inst,owner)
    owner.AnimState:ClearOverrideSymbol("swap_object")
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    CheckSpecialSlotStatus(inst, owner)
    owner.HUD.controls.inv:SetSpecialSlotActive("trusty_shooter", false)
end

local function CanTakeAmmo(inst, ammo, giver)
    return (ammo.components.inventoryitem ~= nil) and
            inst.components.trader.enabled and ((inst.components.weapon.projectile == nil or inst.components.weapon.projectile == ammo.prefab))
            and not ammo.components.health and not ammo:HasTag("irreplaceable")
end

local function SetAmmoDamageAndRange(inst, ammo)

    if ammo.components.equippable then
        inst.components.weapon:SetRange(TUNING.TRUSTY_SHOOTER_ATTACK_RANGE_HIGH, TUNING.TRUSTY_SHOOTER_HIT_RANGE_HIGH)
        inst.components.weapon:SetDamage(TUNING.TRUSTY_SHOOTER_DAMAGE_HIGH)
        inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/wheeler/air_horn/load_3")
    end

    for i,v in ipairs(TUNING.TRUSTY_SHOOTER_TIERS.AMMO_HIGH) do
        if ammo.prefab == v then
            inst.components.weapon:SetRange(TUNING.TRUSTY_SHOOTER_ATTACK_RANGE_HIGH, TUNING.TRUSTY_SHOOTER_HIT_RANGE_HIGH)
            inst.components.weapon:SetDamage(TUNING.TRUSTY_SHOOTER_DAMAGE_HIGH)
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/wheeler/air_horn/load_3")
            return
        end
    end

    for i,v in ipairs(TUNING.TRUSTY_SHOOTER_TIERS.AMMO_LOW) do
        if ammo.prefab == v then
            inst.components.weapon:SetRange(TUNING.TRUSTY_SHOOTER_ATTACK_RANGE_LOW, TUNING.TRUSTY_SHOOTER_HIT_RANGE_LOW)
            inst.components.weapon:SetDamage(TUNING.TRUSTY_SHOOTER_DAMAGE_LOW)
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/wheeler/air_horn/load_1")
            return
        end
    end
    
    inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/wheeler/air_horn/load_2")
    inst.components.weapon:SetRange(TUNING.TRUSTY_SHOOTER_ATTACK_RANGE_MEDIUM, TUNING.TRUSTY_SHOOTER_HIT_RANGE_MEDIUM)
    inst.components.weapon:SetDamage(TUNING.TRUSTY_SHOOTER_DAMAGE_MEDIUM)
end

local function LoadWeapon(inst, item)

    local owner =  inst.components.equippable.equipper
    if inst.ammo == 0 then
            -- inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/wheeler/air_horn/load_2")

        inst:AddTag("projectile")
        inst.components.weapon:SetProjectile(item.prefab)
        inst:AddTag("gun")

        SetAmmoDamageAndRange(inst, item)

        --If equipped, change current equip overrides
        if inst.components.equippable and inst.components.equippable:IsEquipped() then
            owner.AnimState:OverrideSymbol("swap_object", inst.override_bank, "swap_trusty_shooter")
        end

        inst.components.inventoryitem:ChangeImageName("trusty_shooter")
    end

    if item.components.stackable then
        inst.ammo = inst.ammo + item.components.stackable.stacksize
    else
        inst.ammo = inst.ammo + 1
    end
    -- Needs to be in place because this can be called before the HUD exists

    local function settrustyshooterimage()
        if owner then
            CheckSpecialSlotStatus(inst, owner)
            owner.HUD.controls.inv:GetSpecialSlot("trusty_shooter"):OnItemGet(inst.components.inventory:GetItemInSlot(1))
        end
    end

    if owner and owner.HUD then
        settrustyshooterimage()
    else -- Needs to be in place in case this gets called before the hud exists
        inst:DoTaskInTime(0, function() settrustyshooterimage() end)
    end
end

local function OnTakeAmmo(inst, data)
    local ammo = data and data.item
    if not ammo then return end

    LoadWeapon(inst, data.item)
end

local function CanAttack(inst, target)
    return inst.components.weapon.projectile ~= nil
end

local function OnHit(inst, attacker, target, weapon)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/krampus/bag_impact")
    local impactfx = SpawnPrefab("impact")
    if impactfx and attacker then
        local follower = impactfx.entity:AddFollower()
        follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
        impactfx:FacePoint(attacker.Transform:GetWorldPosition())
    end

    if weapon.ammo == 0 then
        weapon.ResetAmmo(weapon)
    end

    if inst.self_destruct then
        inst.self_destruct:Cancel()
        inst.self_destruct = nil
    end

    inst:Remove()
end

local function ResetAmmo(inst)
    inst.components.trader.enabled = true
    --Go back to crummy bat mode
    inst:RemoveTag("projectile")
    inst.components.weapon:SetProjectile(nil)
    inst:RemoveTag("gun")

    --Change ranges back to melee
    inst.components.weapon:SetRange(nil, nil)
    inst.components.weapon:SetDamage(TUNING.UNARMED_DAMAGE)

    --Change equip overrides
    inst.override_bank = "swap_trusty_shooter"

    --If equipped, change current equip overrides
    local owner = inst.components.equippable.equipper
    if inst.components.equippable and inst.components.equippable:IsEquipped() then
        owner.AnimState:OverrideSymbol("swap_object", inst.override_bank, "swap_trusty_shooter")
    end

    inst.components.inventoryitem:ChangeImageName("trusty_shooter_unloaded")

    if owner then
        owner.HUD.controls.inv:GetSpecialSlot("trusty_shooter"):OnItemLose()
    end
end

local function OnProjectileLaunch(inst, attacker, target, proj)

    inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/wheeler/air_horn/shoot")

    proj:AddTag("projectile")
    proj:AddComponent("projectile")
    
    proj.components.projectile:SetSpeed(35)
    proj.components.projectile:SetOnHitFn(OnHit)
    
    proj.components.inventoryitem.canbepickedup = false

    proj:RemoveComponent("blowinwind")

    proj.persists = false

    -- If the projectile still exists in 2 seconds something went wrong
    proj.self_destruct = proj:DoTaskInTime(2, function() proj:Remove() end)
    inst.ammo = inst.ammo - 1

    local removed_item = inst.components.inventory:RemoveSingleItemBySlot(1)
    if removed_item then
        removed_item:Remove()
    end
end

local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon( "trusty_shooter.png" )    

    MakeInventoryPhysics(inst)
    inst:AddTag("gun")
    inst:AddTag("hand_gun")
    inst:AddTag("irreplaceable")

    anim:SetBank("trusty_shooter")
    anim:SetBuild("trusty_shooter")
    anim:PlayAnimation("idle")

    inst:AddComponent("inspectable")

    inst:AddComponent("weapon")
    inst.components.weapon:SetCanAttack(CanAttack)
    --inst.components.weapon:SetAttackCallback(OnAttack)
    inst.components.weapon:SetOnProjectileLaunch(OnProjectileLaunch)
    inst.components.weapon.heightoffset = 2.5

    inst:AddComponent("inventoryitem")

    inst:AddComponent("inventory")
    inst.components.inventory.maxslots = 1
    
    inst.ResetAmmo = ResetAmmo

    inst.TakeItem = function(inst, item, replace)
        if replace then
            inst.ammo = 0
            ResetAmmo(inst)
        end

        item.components.inventoryitem.candrop = false

        if item.components.stackable then
            local stack_num = 0
            local item_in_slot = inst.components.inventory:GetItemInSlot(1)
            if item_in_slot and item_in_slot.components.stackable then
                stack_num = item_in_slot.components.stackable:RoomLeft()
            else
                stack_num = item.components.stackable:StackSize()
            end

            inst.components.trader:AcceptGift(GetPlayer(), item, true, stack_num)
        else
            inst.components.trader:AcceptGift(GetPlayer(), item)
        end
    end

    inst:ListenForEvent("trade", OnTakeAmmo)

    inst.CanTakeItem = CanTakeAmmo

    inst:AddComponent("trader")
    inst.components.trader.deleteitemonaccept = true
    inst.components.trader:SetAcceptTest(CanTakeAmmo)
    inst.components.trader.enabled = true
    inst.components.trader.always_accept_stack = true

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    MakeInventoryFloatable(inst, "idle_water", "idle")
    inst.override_bank = "swap_trusty_shooter"

    inst:DoTaskInTime(0, function()
        inst.ammo = 0

        local ammo_item = inst.components.inventory:GetItemInSlot(1)
        if ammo_item then
            LoadWeapon(inst, ammo_item)
        else
            inst.components.inventoryitem:ChangeImageName("trusty_shooter_unloaded")
        end
    end)

    inst:DoTaskInTime(0, function() if not GetPlayer() or GetPlayer().prefab ~= "wheeler" then inst:Remove() end end)

    return inst
end

return Prefab( "common/trusty_shooter", fn, assets)