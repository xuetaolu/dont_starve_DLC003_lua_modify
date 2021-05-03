local assets=
{
	Asset("ANIM", "anim/deed.zip"),
}

---RED

local function revealHouse(inst)
    local house = GetWorld().playerhouse
    if house and house:IsValid() then
        house:RevealFog(house)
    end
end

local function showOnMinimap(house, reader)
    if house and house:IsValid() then
        house:FocusMinimap(house)
    end
end

local function readfn(inst, reader)

    print("Read deed")

    if not SaveGameIndex:IsModePorkland() or TheCamera.interior then

        reader.components.talker:Say(GetString(reader.prefab, "ANNOUCE_OTHERWORLD_DEED"))
        return true
    end

    if GetWorld().playerhouse then
        revealHouse(inst)
        GetWorld().playerhouse:DoTaskInTime(0, function() showOnMinimap(GetWorld().playerhouse, reader) end)
    end

    return true
end

local function onPutInInventory(inst, owner)    
    --owner:AddTag("antlingual")
end

local function OnRemoved(inst, owner)     
    --[[
    local target = nil
    target = owner.components.inventory:FindItem(function(item) return item:HasTag("ant_translator") end)
    if not target then 
        owner:RemoveTag("antlingual")
    end
    ]]
end

local function OnBought(inst)
    print("DEED BOUGHT")
    GetWorld():PushEvent("deedbought")
    GetPlayer().homeowner = true
end

local function onpickupfn(inst, owner)
    OnBought(inst)
end

local function makefn(inst)
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)   

    inst.AnimState:SetBank("deed")
    inst.AnimState:SetBuild("deed")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("book")
    inst.components.book:SetOnReadFn(readfn)
    inst.components.book:SetAction(ACTIONS.READMAP)

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/jewlery"
    inst.components.inventoryitem:SetOnPickupFn(onpickupfn)

    inst.components.inventoryitem:SetOnPutInInventoryFn(onPutInInventory)
    inst.components.inventoryitem:SetOnRemovedFn(OnRemoved)
    
    MakeInventoryFloatable(inst, "idle_water", "idle")
    --inst.OnBought = OnBought
    

    return inst
end

return Prefab( "common/inventory/deed", makefn, assets)