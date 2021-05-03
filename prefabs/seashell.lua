local assets =
{
	Asset("ANIM", "anim/seashell.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.LIGHT, TUNING.WINDBLOWN_SCALE_MAX.LIGHT)
    
    inst.AnimState:SetBank("seashell")
    inst.AnimState:SetBuild("seashell")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

    inst:AddComponent("tradable")
 
    inst:AddComponent("inspectable")
      
    
    inst:AddComponent("inventoryitem")
    
   
    return inst
end

return Prefab( "common/inventory/seashell", fn, assets) 

