local assets=
{
	Asset("ANIM", "anim/livinglog.zip"),
}

local function FuelTaken(inst, taker)
    if taker and taker.SoundEmitter then
        taker.SoundEmitter:PlaySound("dontstarve/creatures/leif/livinglog_burn")
    end
end

local function oneaten(inst, eater)
	inst.SoundEmitter:PlaySound("dontstarve/creatures/leif/livinglog_burn") 
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()    
    
    inst.AnimState:SetBank("livinglog")
    inst.AnimState:SetBuild("livinglog")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.HEAVY, TUNING.WINDBLOWN_SCALE_MAX.HEAVY)
    
    inst:AddComponent("stackable")
    
    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL
    inst.components.fuel:SetOnTakenFn(FuelTaken)

    inst:AddComponent("appeasement")
    inst.components.appeasement.appeasementvalue = TUNING.WRATH_SMALL
    
    inst:AddComponent("edible")
    inst.components.edible.foodtype = "WOOD"
    inst.components.edible.woodiness = 50
	inst.components.edible:SetOnEatenFn(oneaten)
    
	MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
    MakeSmallPropagator(inst)
    inst.components.burnable:MakeDragonflyBait(3)

    ---------------------       
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
	inst:AddComponent("repairer")
	inst.components.repairer.repairmaterial = "wood"
	inst.components.repairer.healthrepairvalue = TUNING.REPAIR_LOGS_HEALTH*3

	inst:ListenForEvent("onignite", function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/leif/livinglog_burn") end)
    
    return inst
end

return Prefab( "common/inventory/livinglog", fn, assets) 

