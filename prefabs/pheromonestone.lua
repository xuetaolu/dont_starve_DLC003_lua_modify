local assets=
{
	Asset("ANIM", "anim/pheromone_stone.zip"),
	Asset("ANIM", "anim/torso_amulets.zip"),
}

--[[ Each amulet has a seperate onequip and onunequip function so we can also
add and remove event listeners, or start/stop update functions here. ]]

---RED

local function onPutInInventory(inst, owner)    
    owner:AddTag("antlingual")
end

local function OnRemoved(inst, owner)     
    local target = nil
    if owner.components.inventory then
        target = owner.components.inventory:FindItem(function(item) return item:HasTag("ant_translator") end)
        if not target then 
            owner:RemoveTag("antlingual")
        end
    end
end

local function makefn(inst)
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)   

    inst.AnimState:SetBank("pheromone_stone")
    inst.AnimState:SetBuild("pheromone_stone")

    inst:AddTag("ant_translator")
    inst:AddTag("irreplaceable")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/jewlery"

    inst.components.inventoryitem:SetOnPutInInventoryFn(onPutInInventory)
    inst.components.inventoryitem:SetOnRemovedFn(OnRemoved)
    
    MakeInventoryFloatable(inst, "pherostone_water", "pherostone")
    inst.AnimState:PlayAnimation("pherostone")

    return inst
end

return Prefab( "common/inventory/pheromonestone", makefn, assets)