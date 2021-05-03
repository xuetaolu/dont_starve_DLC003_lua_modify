local assets=
{
	Asset("ANIM", "anim/tuna.zip"),
    Asset("INV_IMAGE", "tuna"),
    Asset("INV_IMAGE", "tuna_opened"),
}


local prefabs =
{
    "fish_med_cooked",
}    

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    inst.AnimState:SetBank("tuna")
    inst.AnimState:SetBuild("tuna")
    inst.AnimState:PlayAnimation("idle")
    
    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.MEDIUM, TUNING.WINDBLOWN_SCALE_MAX.MEDIUM)
        
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "tuna"
    
    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = 1

    inst:AddComponent("useableitem")
    inst.components.useableitem.verb = "OPEN"
    inst.components.useableitem:SetCanInteractFn(function() return true end)
    inst.components.useableitem:SetOnUseFn(function(inst)
        inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/can_open")
        local steak = SpawnPrefab("fish_med_cooked")
        GetPlayer().components.inventory:GiveItem(steak)

        inst:Remove()
    end)
    

    return inst
end

return Prefab("common/inventory/tunacan", fn, assets, prefabs)
