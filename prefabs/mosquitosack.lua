local assets=
{
	Asset("ANIM", "anim/bladder.zip"),
    Asset("ANIM", "anim/bladder_yellow.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("bladder")
    inst.AnimState:SetBuild("bladder")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "idle_water", "idle")
    
    inst:AddComponent("stackable")
    
	MakeSmallBurnable(inst, TUNING.TINY_BURNTIME)
    MakeSmallPropagator(inst)

    ---------------------       
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("healer")
    inst.components.healer:SetHealthAmount(TUNING.HEALING_MEDSMALL)

    inst:AddComponent("tradable")
    inst:AddTag("cattoy")
    
    return inst
end

local function poisonfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("bladder")
    inst.AnimState:SetBuild("bladder_yellow")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "idle_water", "idle")
    
    inst:AddComponent("stackable")
    
    MakeSmallBurnable(inst, TUNING.TINY_BURNTIME)
    MakeSmallPropagator(inst)

    ---------------------       
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("healer")
    inst.components.healer:SetHealthAmount(TUNING.HEALING_MED)

    inst:AddComponent("tradable")
    inst:AddTag("cattoy")
    
    return inst
end

return Prefab( "common/inventory/mosquitosack", fn, assets),
Prefab("mosquitosack_yellow", poisonfn, assets)
