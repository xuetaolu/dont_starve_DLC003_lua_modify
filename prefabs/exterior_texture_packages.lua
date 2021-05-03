local assets =
{

    Asset("ANIM", "anim/pig_townhouse1_white_build.zip"),  

    Asset("ANIM", "anim/player_small_house1.zip"),  
    Asset("ANIM", "anim/player_large_house1.zip"),  

    Asset("ANIM", "anim/player_large_house1_manor_build.zip"),  
    Asset("ANIM", "anim/player_large_house1_villa_build.zip"),    
    Asset("ANIM", "anim/player_small_house1_cottage_build.zip"),    
    Asset("ANIM", "anim/player_small_house1_tudor_build.zip"), 
    Asset("ANIM", "anim/player_small_house1_gothic_build.zip"), 
    Asset("ANIM", "anim/player_small_house1_brick_build.zip"),    
    Asset("ANIM", "anim/player_small_house1_turret_build.zip"),    
  
    Asset("ANIM", "anim/player_house_kits.zip"), 

    Asset("INV_IMAGE", "player_house_cottage_craft"),
    Asset("INV_IMAGE", "player_house_cottage"),
    
    Asset("INV_IMAGE", "player_house_villa_craft"), 
    Asset("INV_IMAGE", "player_house_villa"), 
 
    Asset("INV_IMAGE", "player_house_tudor_craft"), 
    Asset("INV_IMAGE", "player_house_tudor"),

    Asset("INV_IMAGE", "player_house_manor_craft"), 
    Asset("INV_IMAGE", "player_house_manor"),    
 
    Asset("INV_IMAGE", "player_house_gothic_craft"), 
    Asset("INV_IMAGE", "player_house_gothic"),    
 
    Asset("INV_IMAGE", "player_house_brick_craft"), 
    Asset("INV_IMAGE", "player_house_brick"), 

    Asset("INV_IMAGE", "player_house_turret_craft"), 
    Asset("INV_IMAGE", "player_house_turret"),     
}

local prefabs =
{

}

local function paint(inst, build, bank)

    local house = GetWorld().playerhouse

    if build then
        house.AnimState:SetBuild(build)
        house.build = build
    end

    if bank then
        house.AnimState:SetBank(bank)
        house.bank = bank
    end

    inst:DoTaskInTime(0,function() inst:Remove() end)
end

local function common(build, bank, icon, anim)
    assert(anim, "THE RENOVATION KIT DIDN'T HAVE AN ANIM SET")
    local function fn(Sim)
        local inst = CreateEntity()
        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        
        inst.AnimState:SetBuild("player_house_kits")
        inst.AnimState:SetBank("house_kit")
        inst.AnimState:PlayAnimation(anim)

        MakeInventoryPhysics(inst)
        MakeInventoryFloatable(inst, anim.."_water", anim)
        inst:AddComponent("inventoryitem")
        if icon then
            inst.components.inventoryitem:ChangeImageName(icon) 
        end
    
        MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
        MakeSmallPropagator(inst)
        inst.components.burnable:MakeDragonflyBait(3)        
    
        inst:AddComponent("inspectable")


        inst:AddComponent("renovator")
        inst.components.renovator.bank = bank
        inst.components.renovator.build = build
        inst.components.renovator.prefabname = "playerhouse_"..anim
        inst.components.renovator.minimap = icon
--        paint(inst, build, bank)

        return inst
    end
    return fn
end

local function material(name, build, bank, icon, anim)
    return Prefab( name, common(build, bank, icon, anim), assets, prefabs)
end

return  material("player_house_villa",              "pig_townhouse1_white_build",           "pig_house_sale" ,      nil,                        "villa"),
        material("player_house_cottage_craft",      "player_small_house1_cottage_build",    "playerhouse_small",    "player_house_cottage",     "cottage"),
        material("player_house_villa_craft",        "player_large_house1_villa_build",      "playerhouse_large",    "player_house_villa",       "villa"),
        material("player_house_manor_craft",        "player_large_house1_manor_build",      "playerhouse_large",    "player_house_manor",       "manor"),
        material("player_house_tudor_craft",        "player_small_house1_tudor_build",      "playerhouse_small",    "player_house_tudor",       "tudor"),
        material("player_house_gothic_craft",       "player_small_house1_gothic_build",     "playerhouse_small",    "player_house_gothic",      "gothic"),
        material("player_house_brick_craft",        "player_small_house1_brick_build",      "playerhouse_small",    "player_house_brick",       "brick"),
        material("player_house_turret_craft",       "player_small_house1_turret_build",     "playerhouse_small",    "player_house_turret",      "turret")        