local assets=
{
	Asset("ANIM", "anim/feather_peagawk_prism.zip"),
}


local function fn(Sim)
    
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddPhysics()
    MakeInventoryPhysics(inst)
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.MEDIUM, TUNING.WINDBLOWN_SCALE_MAX.MEDIUM)


	inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
	
    inst.AnimState:SetBank("feather_peagawk_prism")
    inst.AnimState:SetBuild("feather_peagawk_prism")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("edible")
    inst.components.edible.foodtype = "ELEMENTAL"
    inst.components.edible.hungervalue = 2
    inst:AddComponent("tradable")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("stackable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("bait")
    inst:AddTag("molebait")
    inst:AddTag("scarerbait")
    
    return inst
end

return Prefab( "common/inventory/peagawkfeather_prism", fn, assets) 
