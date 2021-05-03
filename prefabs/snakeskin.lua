local assets=
{
	Asset("ANIM", "anim/snakeskin.zip"),
    Asset("ANIM", "anim/snakeskin_scaly.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    local name =  "snakeskin"
	if SaveGameIndex:IsModePorkland() then 
        name = "snakeskin_scaly" 
        inst.shelfart = "snakeskin_scaly"
    end
    inst.AnimState:SetBank(name)
    inst.AnimState:SetBuild(name)
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryPhysics(inst)
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.LIGHT, TUNING.WINDBLOWN_SCALE_MAX.LIGHT)
    MakeInventoryFloatable(inst, "idle_water", "idle")
    
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    

	MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
    MakeSmallPropagator(inst)
    inst.components.burnable:MakeDragonflyBait(3)

    ---------------------       
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("appeasement")
    inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_TINY

	--inst:ListenForEvent("burnt", function(inst) inst.entity:Retire() end)
    
    return inst
end

return Prefab( "common/inventory/snakeskin", fn, assets) 

