local assets=
{
	Asset("ANIM", "anim/jellyfish.zip"),
    Asset("ANIM", "anim/meat_rack_food.zip"),
    Asset("INV_IMAGE", "jellyJerky"),
}


local prefabs=
{
    "jellyfish_planted",
}

local function playshockanim(inst)
    if inst:HasTag("aquatic") then
        inst.AnimState:PlayAnimation("idle_water_shock")
        inst.AnimState:PushAnimation("idle_water", true)
        inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/jellyfish/electric_water")
    else
        inst.AnimState:PlayAnimation("idle_ground_shock")
        inst.AnimState:PushAnimation("idle_ground", true)
        inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/jellyfish/electric_land")
    end
end

local function playDeadAnimation(inst)
    inst.AnimState:PlayAnimation("idle_ground", true) 
end 

local function ondropped(inst)
   

    --Get tile under my position and set animation accordingly
    local ground = GetWorld()
    local tile = GROUND.GRASS
    tile = inst:GetCurrentTileType()

    local onWater = ground.Map:IsWater(tile)

    if onWater then
     
        local replacement = SpawnPrefab("jellyfish_planted")
        replacement.Transform:SetPosition(inst.Transform:GetWorldPosition())

        inst:Remove()
    else
        local replacement = SpawnPrefab("jellyfish_dead")
        replacement.Transform:SetPosition(inst.Transform:GetWorldPosition())
        replacement.AnimState:PlayAnimation("death_ground", true)
        replacement:DoTaskInTime(2.5, playDeadAnimation)
        replacement.shocktask = replacement:DoPeriodicTask(math.random() * 10 + 5, playshockanim)
        replacement:AddTag("stinger")
        inst:Remove()
    end
end

local function ondroppeddead(inst)
    inst:AddTag("stinger")
    inst.shocktask = inst:DoPeriodicTask(math.random() * 10 + 5, playshockanim)
    inst.AnimState:PlayAnimation("idle_ground", true)
end 

local function onpickup(inst, pickupguy)
    if inst:HasTag("stinger") and pickupguy.components.combat and pickupguy.components.inventory then
        if not pickupguy.components.inventory:IsInsulated() then
            pickupguy.components.health:DoDelta(-TUNING.JELLYFISH_DAMAGE)
            if pickupguy == GetPlayer() then
                pickupguy.sg:GoToState("electrocute")
            end
        end
        inst:RemoveTag("stinger")
    end

    if inst.shocktask then
        inst.shocktask:Cancel()
        inst.shocktask = nil
    end
end

local function commonfn(Sim)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    inst.entity:AddSoundEmitter()

    inst:AddTag("seacreature")
    
    inst.AnimState:SetRayTestOnBB(true);    
    inst.AnimState:SetBank("jellyfish")
    inst.AnimState:SetBuild("jellyfish")

    inst.AnimState:SetLayer( LAYER_BACKGROUND )
    inst.AnimState:SetSortOrder( 3 )

    
    inst:AddComponent("appeasement")
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("perishable")
  
    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
    inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD

    --shine(inst)
    
    return inst
end

local function defaultfn(sim)

    local inst = commonfn(sim)

    inst.components.perishable:SetPerishTime(TUNING.PERISH_ONE_DAY * 1.5)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "jellyfish_dead"

    inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem:SetOnPickupFn(onpickup)
    inst.AnimState:PlayAnimation("idle_ground", true)

    MakeInventoryFloatable(inst, "idle_water", "idle_ground")

    inst:AddComponent("cookable")
    inst.components.cookable.product = "jellyfish_cooked"

    inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_TINY
   
    inst:AddComponent("health")
    inst.components.health.murdersound = "dontstarve_DLC002/creatures/jellyfish/death_murder"
    inst:AddTag("show_spoilage")
    inst:AddTag("jellyfish")
	inst:AddTag("fishmeat")

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"jellyfish_dead"}) --Replace with dead jelly

    return inst

end 

local function deadfn(sim)
     local inst = commonfn(sim)

    inst:AddComponent("edible")
    inst.components.edible.foodtype = "MEAT"
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst.components.inventoryitem:SetOnDroppedFn(ondroppeddead)
    inst.components.inventoryitem:SetOnPickupFn(onpickup)
    inst.AnimState:PlayAnimation("idle_ground", true)

    MakeInventoryFloatable(inst, "idle_water", "idle_ground")

    inst:AddComponent("cookable")
    inst.components.cookable.product = "jellyfish_cooked"

    inst:AddComponent("dryable")
    inst.components.dryable:SetProduct("jellyjerky")
    inst.components.dryable:SetDryTime(TUNING.DRY_FAST)
    inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_TINY

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

    return inst
end


local function cookedfn(sim)

    local inst = commonfn(sim)

    inst:AddComponent("edible")
    inst.components.edible.foodtype = "MEAT"
    inst.components.edible.foodstate = "COOKED"
    inst.components.edible.hungervalue = TUNING.CALORIES_MEDSMALL
    inst.components.edible.sanityvalue = 0--TUNING.SANITY_SMALL
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst.AnimState:PlayAnimation("cooked", true)
    inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_SMALL
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM
    return inst 
end 

local function driedfn(sim)
    local inst = commonfn(sim)
    inst:AddComponent("edible")
    inst.components.edible.foodtype = "MEAT"
    inst.components.edible.foodstate = "DRIED"
    inst.components.edible.hungervalue = TUNING.CALORIES_MEDSMALL
    inst.components.edible.sanityvalue = 0--TUNING.SANITY_SMALL
    inst.components.perishable:SetPerishTime(TUNING.PERISH_PRESERVED)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"
    
    inst.AnimState:SetBank("meat_rack_food")
    inst.AnimState:SetBuild("meat_rack_food")
    inst.AnimState:PlayAnimation("idle_dried_jellyjerky", true)

    MakeInventoryFloatable(inst, "idle_dried_jellyjerky_water", "idle_dried_jellyjerky")
    
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM
    inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_SMALL
    return inst

end 

return Prefab( "common/inventory/jellyfish", defaultfn, assets), 
       Prefab( "common/inventory/jellyfish_dead", deadfn, assets), 
       Prefab( "common/inventory/jellyfish_cooked", cookedfn, assets), 
       Prefab( "common/inventory/jellyjerky", driedfn, assets)