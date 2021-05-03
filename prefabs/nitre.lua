local assets=
{
	Asset("ANIM", "anim/nitre.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    inst.entity:AddSoundEmitter()

    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.MEDIUM, TUNING.WINDBLOWN_SCALE_MAX.MEDIUM)
    
    inst.AnimState:SetBank("nitre")
    inst.AnimState:SetBuild("nitre")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("edible")
    inst.components.edible.foodtype = "ELEMENTAL"
    inst.components.edible.hungervalue = 2
    inst:AddComponent("tradable")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_LARGE_FUEL
    inst.components.fuel.fueltype = "CHEMICAL"

    inst:AddComponent("appeasement")
    inst.components.appeasement.appeasementvalue = TUNING.WRATH_LARGE
    
    inst:AddComponent("inspectable")

    inst:AddComponent("bait")
    inst:AddTag("molebait")
    
    inst:AddComponent("inventoryitem")
    return inst
end

return Prefab( "common/inventory/nitre", fn, assets) 
