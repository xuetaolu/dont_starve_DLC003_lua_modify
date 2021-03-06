local assets=
{
	Asset("ANIM", "anim/spider_gland.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.MEDIUM, TUNING.WINDBLOWN_SCALE_MAX.MEDIUM)

    inst.AnimState:SetBank("spider_gland")
    inst.AnimState:SetBuild("spider_gland")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("stackable")
    
	MakeSmallBurnable(inst, TUNING.TINY_BURNTIME)
    MakeSmallPropagator(inst)

    ---------------------       
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")

    inst:AddTag("cattoy")
    inst:AddComponent("tradable")
    
    inst:AddComponent("healer")
    inst.components.healer:SetHealthAmount(TUNING.HEALING_MEDSMALL)
    
    return inst
end

return Prefab( "common/inventory/spidergland", fn, assets) 

