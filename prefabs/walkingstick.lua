local assets=
{
	Asset("ANIM", "anim/walking_stick.zip"),
	Asset("ANIM", "anim/swap_walking_stick.zip"),
    --Asset("INV_IMAGE", "cane"),
}

local function onfinished(inst)
    inst:Remove()
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_walking_stick", "swap_object")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
    inst.equipped = true
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
    inst.equipped = false
    inst.components.fueled:StopConsuming()
end

local function onwornout(inst)
    inst:Remove()
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()        
    MakeInventoryPhysics(inst)
    
    anim:SetBank("cane")
    anim:SetBuild("walking_stick")
    anim:PlayAnimation("idle")
    
    MakeInventoryFloatable(inst, "idle_water", "idle")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.WALKING_STICK_DAMAGE)
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("equippable")
    
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    inst.components.equippable.walkspeedmult = TUNING.WALKING_STICK_SPEED_MULT

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "USAGE"
    inst.components.fueled:InitializeFuelLevel(TUNING.WALKING_STICK_PERISHTIME)
    inst.components.fueled:SetDepletedFn(onwornout)

    GetPlayer():ListenForEvent("locomote", function() 
            local player = GetPlayer()
            if player.sg and player.sg:HasStateTag("moving") and inst.equipped then
                inst.components.fueled:StartConsuming()
            else
                inst.components.fueled:StopConsuming()
            end
        end)
    
    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    return inst
end


return Prefab( "common/inventory/walkingstick", fn, assets) 

