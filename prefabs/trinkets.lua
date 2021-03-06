local function MakeTrinket(num)
    
    local name = "trinket_"..tostring(num)
    local prefabname = "common/inventory/"..name
    
    local assets=
    {
        Asset("ANIM", "anim/trinkets.zip"),
    }
    
    local function fn(Sim)
        local inst = CreateEntity()
        
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        
        MakeInventoryPhysics(inst)
        MakeInventoryFloatable(inst, tostring(num).."_water", tostring(num))
        
        inst.AnimState:SetBank("trinkets")
        inst.AnimState:SetBuild("trinkets")
        inst.AnimState:PlayAnimation(tostring(num))
        
        inst:AddComponent("inspectable")
        inst:AddComponent("stackable")
		inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

        inst:AddComponent("inventoryitem")
        inst:AddComponent("tradable")
        inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.TRINKETS[num] or 3
        inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.TRINKETS[num] or 3

        inst:AddComponent("appeasement")
        local appeasementvalue = TUNING.APPEASEMENT_SMALL
        if num > 12 then 
            appeasementvalue = TUNING.APPEASEMENT_LARGE
        end 
        inst.components.appeasement.appeasementvalue = appeasementvalue

        inst:AddComponent("bait")
        inst:AddTag("molebait")
        inst:AddTag("cattoy")
        inst:AddTag("trinket")

        return inst
    end
    
    return Prefab( prefabname, fn, assets)
end

local ret = {}
for k =1,NUM_TRINKETS do
    table.insert(ret, MakeTrinket(k))
end

return unpack(ret) 
