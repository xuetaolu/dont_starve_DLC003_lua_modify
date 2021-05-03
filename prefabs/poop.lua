local assets =
{
	Asset("ANIM", "anim/poop.zip"),
    Asset("ANIM", "anim/monkey_projectile.zip"),
    Asset("ANIM", "anim/swap_poop.zip"),
}

local prefabs =
{
    "flies",
    "poopcloud",
    "poop_splat",
}

local function OnBurn(inst)
    DefaultBurnFn(inst)
    if inst.flies then
        inst.flies:Remove()
        inst.flies = nil
    end
end

local function FuelTaken(inst, taker)
    local cloud = SpawnPrefab("poopcloud")
    if cloud then
        cloud.Transform:SetPosition(taker.Transform:GetWorldPosition() )
    end
end

local function OnEntityWake(inst)
    if inst.components.inventoryitem and not inst:HasTag("thrown") then 
        inst.components.inventoryitem:OnStartFalling()
    end
end

local function OnHitGround(inst)
    inst.components.floatable:UpdateAnimations("idle_water", "idle")
end

local function MakeEquippable(inst)

    local onequip = function(inst, owner)
        owner.AnimState:OverrideSymbol("swap_object", "swap_poop", "swap_poop")
        owner.AnimState:Show("ARM_carry")
        owner.AnimState:Hide("ARM_normal")
    end

    local onunequip = function(inst, owner)
        owner.AnimState:Hide("ARM_carry")
        owner.AnimState:Show("ARM_normal")
    end

    local onthrown = function(inst, thrower, pt)

        inst:AddTag("thrown")
        inst.AnimState:SetBank("monkey_projectile")
        inst.AnimState:SetBuild("monkey_projectile")
        inst.AnimState:PlayAnimation("idle", true)

        inst.Physics:SetFriction(.2)

        inst.GroundTask = inst:DoPeriodicTask(FRAMES, function()
            local pos = inst:GetPosition()
            if pos.y <= 0.5 then
                local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 1.5, nil, {"FX", "NOCLICK", "DECOR", "INLIMBO"})

                for k,v in pairs(ents) do
                    if v.components.combat then
                        v.components.combat:GetAttacked(thrower, TUNING.POOP_THROWN_DAMAGE)
                    end
                end

                local pt = inst:GetPosition()
                local other = SpawnPrefab("poop_splat")
                other.Transform:SetPosition(pt:Get())

                inst:Remove()
            end
        end)
    end

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.equipstack = true

    inst:AddComponent("throwable")
    inst.components.throwable.onthrown = onthrown

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = function() 
        return inst.components.throwable:GetThrowPoint()
    end
    inst.components.reticule.ease = true
end

local function OnPickup(inst, owner)
    if inst.cityID then
        GetWorld().components.periodicpoopmanager:OnPickedUp(inst.cityID, inst)
        inst.cityID = nil
    end
end

local function OnRemove(inst)
    if inst.flies then 
        inst.flies:Remove() 
	inst.flies = nil 
    end
end

local function OnReturn(inst)
    if not inst.flies then
        inst.flies = inst:SpawnChild("flies")
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

    inst.OnEntityWake = OnEntityWake

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "dump")
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.MEDIUM, TUNING.WINDBLOWN_SCALE_MAX.MEDIUM)

    inst.components.floatable:SetOnHitWaterFn(OnHitGround)
    inst.components.floatable:SetOnHitLandFn(OnHitGround)
    
    inst.AnimState:SetBank("poop")
    inst.AnimState:SetBuild("poop")
    inst.AnimState:PlayAnimation("dump")
    inst.AnimState:PushAnimation("idle")
    
    inst:AddComponent("stackable")
 
    inst:AddComponent("inspectable")
    

    inst:AddComponent("fertilizer")
    inst.components.fertilizer.fertilizervalue = TUNING.POOP_FERTILIZE
    inst.components.fertilizer.soil_cycles = TUNING.POOP_SOILCYCLES
    inst.components.fertilizer.withered_cycles = TUNING.POOP_WITHEREDCYCLES
    inst.components.fertilizer.planthealing = true

    inst:AddComponent("smotherer")

    inst:AddComponent("tradable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPickupFn(OnPickup)
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPickup)

    inst.flies = inst:SpawnChild("flies")
    
    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL
    inst.components.fuel:SetOnTakenFn(FuelTaken)

    inst:AddComponent("appeasement")
    inst.components.appeasement.appeasementvalue = TUNING.WRATH_SMALL
    

	MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
    inst.components.burnable:SetOnIgniteFn(OnBurn)
    MakeSmallPropagator(inst)
    inst.components.burnable:MakeDragonflyBait(3)
    
    inst:ListenForEvent("enterlimbo", OnRemove)
    inst:ListenForEvent("exitlimbo", OnReturn)
    ---------------------        
    
    if GetPlayer():HasTag("monkey") then
        MakeEquippable(inst)
    end

    
    return inst
end

return Prefab( "common/inventory/poop", fn, assets, prefabs)
