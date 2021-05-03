local assets=
{
	Asset("ANIM", "anim/log.zip"),
    Asset("ANIM", "anim/log_tropical.zip"),
    Asset("ANIM", "anim/log_rainforest.zip"),    
    Asset("INV_IMAGE", "log_tropical"),
    Asset("INV_IMAGE", "log_rainforest"),    
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.HEAVY, TUNING.WINDBLOWN_SCALE_MAX.HEAVY)

    inst:AddComponent("inventoryitem")
    
    if SaveGameIndex:IsModeShipwrecked() then
        inst.AnimState:SetBuild("log_tropical")
        inst.shelfart = "log_tropical"
    elseif SaveGameIndex:IsModePorkland() then
        inst.AnimState:SetBuild("log_rainforest")
        inst.shelfart = "log_teatree"
    else
        inst.AnimState:SetBuild("log")
    end
    inst.AnimState:SetBank("log")

    inst:AddComponent("tradable")

    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("stackable")
    
    inst:AddComponent("edible")
    inst.components.edible.foodtype = "WOOD"
    inst.components.edible.woodiness = 10

    
    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL

    inst:AddComponent("appeasement")
    inst.components.appeasement.appeasementvalue = TUNING.WRATH_SMALL
    
    
	MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
    MakeSmallPropagator(inst)
    inst.components.burnable:MakeDragonflyBait(3)

    ---------------------       
    
    inst:AddComponent("inspectable")
    
  
    
	inst:AddComponent("repairer")
	inst.components.repairer.repairmaterial = "wood"
	inst.components.repairer.healthrepairvalue = TUNING.REPAIR_LOGS_HEALTH

	--inst:ListenForEvent("burnt", function(inst) inst.entity:Retire() end)
    
    return inst
end

return Prefab( "common/inventory/log", fn, assets) 

