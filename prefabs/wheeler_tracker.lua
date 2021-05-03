local assets=
{
	Asset("ANIM", "anim/tracker.zip"),
    Asset("INV_IMAGE", "tracker"),
    Asset("INV_IMAGE", "tracker_open"),
    Asset("ANIM", "anim/tracker_pointer.zip"),
    Asset("MINIMAP_IMAGE", "tracker"),    
}

local function oncontrolfn(tile, control, down)
    
    if down then
        if control == CONTROL_ACCEPT then
            local active_item = GetPlayer().components.inventory:GetActiveItem()

            if not tile.owner or (tile.owner and tile.owner.components.equippable.un_unequipable) then
                return
            end

            if active_item then
                -- If there's no item, take it
                if tile.owner.components.inventory:GetItemInSlot(1) == nil then
                    tile.owner.TakeItem(tile.owner, active_item)
                else -- If there's an item, replace it
                    local trade_item = tile.owner.components.inventory:RemoveItemBySlot(1)
                    tile:OnItemLose()
                    tile.owner.TakeItem(tile.owner, active_item)
                    GetPlayer().components.inventory:GiveActiveItem(trade_item)
                end
            else -- Just take it off
                local trade_item = tile.owner.components.inventory:RemoveItemBySlot(1)
                tile:OnItemLose()
                GetPlayer().components.inventory:GiveActiveItem(trade_item)
                return true
            end

            return true
        end
    end
end

local function CheckSpecialSlotStatus(inst, player)
    if player and not player.HUD.controls.inv:GetSpecialSlot("wheeler_tracker") then
        player.HUD.controls.inv:AddSpecialSlot("wheeler_tracker", inst) 
        player.HUD.controls.inv:SetSpecialSlotFn("wheeler_tracker", nil, oncontrolfn, nil, nil)
    end
end

local function CanGiveLoot(inst, goalinst)
    local prefab = goalinst.prefab
    if not (inst.components.inventoryitem and (inst.components.inventoryitem.owner ~= nil)) and not inst:IsInLimbo() then
        if inst.prefab == prefab then
            return true
        elseif inst.components.pickable and inst.components.pickable:CanBePicked() and inst.components.pickable.product == prefab then
            return true

        elseif inst.components.harvestable and inst.components.harvestable:CanBeHarvested() and inst.components.harvestable.product == prefab then
            return true

        elseif inst.components.dryable and inst.components.dryable.product == prefab then
            return true

        elseif inst.components.shearable and inst.components.shearable:CanShear() and inst.components.shearable.product == prefab then
            return true

        elseif inst.components.dislodgeable and inst.components.dislodgeable:CanBeDislodged() and inst.components.dislodgeable.product == prefab then
            return true

        elseif inst.components.cookable and inst.components.cookable.product == prefab then
            return true   

        elseif goalinst.components.deployable and goalinst.components.deployable.product == inst.prefab then
            return true

        elseif inst.components.lootdropper then
            local total_loot = inst.components.lootdropper:GetPotentialLoot()
            for i,v2 in ipairs(total_loot) do
                if v2 == prefab then
                    return true
                end
            end
        end
    end
    return false
end

local function TrackNext(inst, goalinst)
    local prefab = goalinst.prefab
    print ("TRACKING A ", prefab)

    local x,y,z = inst.Transform:GetWorldPosition()

    local found_ents = {}
    local ents = TheSim:FindEntities(x,y,z, 1000)
    for k,v in pairs(ents) do

        --if goalinst.components.deployable and goalinst.components.deployable.product == v.prefab then
        --    table.insert(found_ents, v)
       -- else

        if CanGiveLoot(v, goalinst) then
            table.insert(found_ents, v)
        end
    end

    local sorted_ents = {}
    local pos = inst:GetPosition()

    for k,v in pairs(found_ents) do
        local v_pt = v:GetPosition()
        table.insert(sorted_ents, {inst = v, distance = distsq(pos, v_pt)})
    end

    table.sort(sorted_ents, function(a,b) return (a.distance) < (b.distance) end)
    
    if next(sorted_ents) ~= nil then
        return sorted_ents[1].inst
    end

    print ("NO INSTANCES FOUND FOR TRACKING")
end


local function DeactivateTracking(inst)
    if inst.arrow_rotation_update then
        inst.arrow_rotation_update:Cancel()
        inst.arrow_rotation_update = nil
    end

    if inst.distance_update then
        inst.distance_update:Cancel()
        inst.distance_update = nil
    end

    if inst.arrow then
        inst.arrow:Remove()
        inst.arrow = nil
    end
end

local function ActivateTracking(inst)
    local owner = inst.components.equippable.equipper

    local function update_item()
        local closer_item = TrackNext(inst, inst.tracked_item)
        if closer_item ~= inst.tracked_item then
            inst.tracked_item = closer_item
        end
    end

    if owner then
        if inst.tracked_item then

            if not inst.arrow then
                inst.arrow = SpawnPrefab("wheeler_tracker_arrow")
                owner:AddChild(inst.arrow)
            end
            
            if inst.arrow_rotation_update == nil then
                inst.arrow_rotation_update = inst:DoPeriodicTask(0, function() 

                    if inst.tracked_item and (inst.tracked_item:IsInLimbo() or not CanGiveLoot(inst.tracked_item, inst.components.inventory:GetItemInSlot(1))) then
                        inst.tracked_item = nil
                    end

                    if inst.tracked_item == nil or not inst.tracked_item:IsValid() then
                        DeactivateTracking(inst)
                        inst.tracked_item = TrackNext(inst, inst.components.inventory:GetItemInSlot(1))
                        ActivateTracking(inst)
                    else
                        inst.arrow:UpdateRotation(inst.tracked_item.Transform:GetWorldPosition())
                    end
                end)
            end
        else
            owner.components.talker:Say(GetString(GetPlayer().prefab, "ANNOUNCE_NOTHING_FOUND"))
        end
    end
end

local function on_equip(inst, owner, force)
    local function setspecialslot()
        CheckSpecialSlotStatus(inst, owner)
        owner.HUD.controls.inv:SetSpecialSlotActive("wheeler_tracker", true, inst)
        owner.HUD.controls.inv:GetSpecialSlot("wheeler_tracker"):OnItemGet(inst.components.inventory:GetItemInSlot(1))

        -- defer this by one frame as well, so it works on load
        if inst.components.inventory:GetItemInSlot(1) then
            inst.tracked_item = TrackNext(inst, inst.components.inventory:GetItemInSlot(1))
            ActivateTracking(inst)
        end
    end

    if owner.HUD then
        setspecialslot()
    else
        inst:DoTaskInTime(0, function() setspecialslot() end)
    end
end

local function on_unequip(inst, owner)
    CheckSpecialSlotStatus(inst, owner)
    owner.HUD.controls.inv:SetSpecialSlotActive("wheeler_tracker", false)

    DeactivateTracking(inst)
end

local function can_take_item(inst)        
    if inst.components.inventory:IsFull() then -- If there's an item, replace it
        local trade_item = inst.components.inventory:RemoveItemBySlot(1)
        GetPlayer().components.inventory:GiveActiveItem(trade_item)
    end

    return true--not inst.components.inventory:IsFull()
end

local  function on_lose_item(inst, data)
    DeactivateTracking(inst)

    inst.components.inventoryitem:ChangeImageName("tracker_open")
    inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/wheeler/tracker/open")
end

local function on_take_item(inst, data)
    -- Needs to be in place because this can be called before the HUD exists

    inst.components.inventoryitem:ChangeImageName("tracker")
    inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/wheeler/tracker/close")
    if inst.components.equippable:IsEquipped() then
        inst:DoTaskInTime(0, function()
            local owner = inst.components.equippable.equipper
            CheckSpecialSlotStatus(inst, owner)
            if owner then
                owner.HUD.controls.inv:GetSpecialSlot("wheeler_tracker"):OnItemGet(inst.components.inventory:GetItemInSlot(1))
            end
        end)
        DeactivateTracking(inst)
        inst.tracked_item = TrackNext(inst, data.item)
        ActivateTracking(inst)
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon( "tracker.png" )
    
    anim:SetBank("tracker")
    anim:SetBuild("tracker")
    anim:PlayAnimation("idle")
    
    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:ChangeImageName("tracker_open")

    inst:AddComponent("inspectable")
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(on_equip)
    inst.components.equippable:SetOnUnequip(on_unequip)

    inst:AddComponent("inventory")
    inst.components.inventory.maxslots = 1
    inst:ListenForEvent("itemlose", on_lose_item)
    inst:ListenForEvent("trade", on_take_item)

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(can_take_item)
    
    inst.TakeItem = function(inst, item)
        inst.components.trader:AcceptGift(GetPlayer(), item)
    end

    inst:AddTag("irreplaceable")

    local function refreshoninterior()
        DeactivateTracking(inst)

        local item = inst.components.inventory:GetItemInSlot(1)
        if item then
            inst.tracked_item = TrackNext(inst, item)
            ActivateTracking(inst)
        end
    end

    inst:ListenForEvent("exitinterior",  function() refreshoninterior() end, GetWorld())
    inst:ListenForEvent("enterinterior", function() refreshoninterior() end, GetWorld())

    inst:DoTaskInTime(0, function() if not GetPlayer() or GetPlayer().prefab ~= "wheeler" then inst:Remove() end end)

    return inst
end

local function arrowfn(Sim)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()

    anim:SetBank("tracker_pointer")
    anim:SetBuild("tracker_pointer")
    anim:PlayAnimation("idle")

    anim:SetOrientation( ANIM_ORIENTATION.OnGround )
    anim:SetLayer( LAYER_BACKGROUND )
    inst.AnimState:SetSortOrder( 4 )

    inst.pos_target = GetPlayer()
    inst.UpdateRotation = function(inst, x,y,z)
        inst:FacePoint(x,y,z)
        inst.Transform:SetRotation(inst.Transform:GetRotation() + 90 - inst.pos_target.Transform:GetRotation())
    end
    
    return inst
end

return Prefab( "common/inventory/wheeler_tracker", fn, assets),
       Prefab( "common/inventory/wheeler_tracker_arrow", arrowfn, assets)