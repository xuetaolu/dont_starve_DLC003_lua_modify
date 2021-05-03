local assets=
{
	Asset("ANIM", "anim/boat_repair_kit.zip"),
}

local function onfinished(inst)
	inst:Remove()
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")

    inst.AnimState:SetBank("boat_repair_kit")
    inst.AnimState:SetBuild("boat_repair_kit")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.BOAT_REPAIR_KIT_USES)
    inst.components.finiteuses:SetUses(TUNING.BOAT_REPAIR_KIT_USES)
    inst.components.finiteuses:SetOnFinished( onfinished )
    
    inst:AddComponent("repairer")
    inst.components.repairer.healthrepairvalue = TUNING.BOAT_REPAIR_KIT_HEALING
    inst.components.repairer.repairmaterial = "boat"    
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")

    return inst
end

return Prefab( "common/inventory/boatrepairkit", fn, assets) 

