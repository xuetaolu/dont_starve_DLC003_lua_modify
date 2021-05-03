local assets=
{
	Asset("ANIM", "anim/pigskin.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    inst.AnimState:SetBank("pigskin")
    inst.AnimState:SetBuild("pigskin")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
    
	MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)
    
	inst:AddComponent("tradable")    
	inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
	
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("edible")
    inst.components.edible.foodtype = "HORRIBLE"
    
    inst.OnSave = function(inst, data)
        if inst.animbankoverride then
            data.animbankoverride = inst.animbankoverride 
        end                 
        if inst.animbuildoverride then
            data.animbuildoverride = inst.animbuildoverride
        end   
        if inst.nameoverride then
            data.nameoverride = inst.nameoverride
        end  
        if inst.imagenameoverride then
            data.imagenameoverride = inst.imagenameoverride
        end   
    end        
    
    inst.OnLoad = function(inst, data)    
        if data then                
            if data.animbankoverride then
                inst.AnimState:SetBank(data.animbankoverride)
                inst.animbankoverride = data.animbankoverride
            end                 
            if data.animbuildoverride then
                inst.AnimState:SetBuild(data.animbuildoverride)
                inst.animbuildoverride = data.animbuildoverride
            end   
            if data.nameoverride then
                inst.name = data.nameoverride
                inst.nameoverride = data.nameoverride
            end  
            if data.imagenameoverride then
                inst.components.inventoryitem:ChangeImageName(data.imagenameoverride)
                inst.imagenameoverride = data.imagenameoverride
            end  
        end        
    end 

    return inst
end

return Prefab( "common/inventory/pigskin", fn, assets) 
