local assets=
{
	Asset("ANIM", "anim/feather_peagawk.zip"),
}


local function fn(Sim)
    
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddPhysics()
    MakeInventoryPhysics(inst)
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.MEDIUM, TUNING.WINDBLOWN_SCALE_MAX.MEDIUM)

    inst.AnimState:SetBank("feather_peagawk")
    inst.AnimState:SetBuild("feather_peagawk")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("tradable")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("stackable")
    inst:AddComponent("inventoryitem")

    return inst
end

return Prefab( "common/inventory/peagawkfeather", fn, assets) 
