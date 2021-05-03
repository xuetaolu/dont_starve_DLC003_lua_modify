local assets=
{
	Asset("ANIM", "anim/honey.zip"),
}

local prefabs =
{
	"spoiled_food",
}

local function OnPutInInventory(inst, owner)
    if owner.prefab == "antchest" then
        inst.components.perishable:StopPerishing()
    end
end

local function OnRemoved(inst, owner)
    if owner.prefab == "antchest" then
        inst.components.perishable:StartPerishing()
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")
    
    inst:AddTag("honeyed")
    
    inst.AnimState:SetBuild("honey")
    inst.AnimState:SetBank("honey")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("edible")
    inst.components.edible.healthvalue = TUNING.HEALING_SMALL
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY

    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("tradable")

    inst:AddComponent("inspectable")
    
	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERSLOW)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"
    
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
    inst.components.inventoryitem:SetOnRemovedFn(OnRemoved)
    
    return inst
end

return Prefab( "common/inventory/honey", fn, assets, prefabs) 
