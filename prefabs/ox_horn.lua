local assets=
{
	Asset("ANIM", "anim/ox_horn.zip"),
}

local function onfinished(inst)
    inst:Remove()
end

local function HearPanFlute(inst, musician, instrument)
	GetWorld().components.seasonmanager:ForcePrecip()
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

    inst.AnimState:SetBank("ox_horn")
    inst.AnimState:SetBuild("ox_horn")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")
    
    inst:AddComponent("inspectable")
        
    inst:AddComponent("inventoryitem")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = 5

    return inst
end

return Prefab( "common/inventory/ox_horn", fn, assets) 