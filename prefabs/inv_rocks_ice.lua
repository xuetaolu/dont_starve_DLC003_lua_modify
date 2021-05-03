local assets=
{
	Asset("ANIM", "anim/ice.zip"),
}

local names = {"f1","f2","f3"}

local function onsave(inst, data)
	data.anim = inst.animname
end

local function onload(inst, data)
    if data and data.anim then
        inst.animname = data.anim
	    inst.AnimState:PlayAnimation(inst.animname)
	end
end

local function onperish(inst)
    local player = GetPlayer()
    if inst.components.inventoryitem and player and inst.components.inventoryitem:IsHeldBy(player) then
        if player.components.moisture then
            local stacksize = inst.components.stackable:StackSize()
            player.components.moisture:DoDelta(2*stacksize)
        end
        inst:Remove()
    elseif inst.components.inventoryitem:GetContainer() then
        inst:Remove()
    else
        inst.components.inventoryitem.canbepickedup = false
        inst.AnimState:PlayAnimation("melt")
        inst:ListenForEvent("animover", function(inst) inst:Remove() end)
    end
end

local function playfallsound(inst)
    local ice_fall_sound =
    {
        [GROUND.BEACH] = "dontstarve_DLC002/common/ice_fall_beach",
        [GROUND.JUNGLE] = "dontstarve_DLC002/common/ice_fall_jungle",
        [GROUND.TIDALMARSH] = "dontstarve_DLC002/common/ice_fall_marsh",
        [GROUND.MAGMAFIELD] = "dontstarve_DLC002/common/ice_fall_rocks",
        [GROUND.MEADOW] = "dontstarve_DLC002/common/ice_fall_grass",
        [GROUND.VOLCANO] = "dontstarve_DLC002/common/ice_fall_rocks",
        [GROUND.ASH] = "dontstarve_DLC002/common/ice_fall_rocks",
    }

    local tile = inst:GetCurrentTileType()
    if ice_fall_sound[tile] ~= nil then
        inst.SoundEmitter:PlaySound(ice_fall_sound[tile])
    end
end

local function onhitground_ice(inst, onwater)
    if not onwater then
        playfallsound(inst)
    end
end

local function onhitground_hail(inst, onwater)
    if not onwater then
        playfallsound(inst)
    end
end

local function onhitground_haildrop(inst, onwater)
    if not onwater then
        if math.random() < TUNING.HURRICANE_HAIL_BREAK_CHANCE then
            inst.components.inventoryitem.canbepickedup = false
            inst.AnimState:PlayAnimation("break")
            inst:ListenForEvent("animover", function(inst) inst:Remove() end)
        else
            inst.components.blowinwind:Start()
            inst:RemoveEventCallback("onhitground", onhitground_haildrop)
            ChangeToInventoryPhysics(inst)
            --inst.Physics:SetCollisionCallback(nil)
        end
    end
end

local function hail_startfalling(inst, x, y, z)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
	inst.Physics:CollidesWith(COLLISION.WAVES)
    inst.Physics:CollidesWith(COLLISION.INTWALL)
    --inst.Physics:SetCollisionCallback(function(inst, other)
    --  if other and other.components.health and other.Physics:GetCollisionGroup() == COLLISION.CHARACTERS then
    --      other.components.health:DoDelta(-TUNING.HURRICANE_HAIL_DAMAGE, false, "hail")
    --  end
    --end)
    inst.Physics:Teleport(x, 35, z)
    inst:ListenForEvent("onhitground", onhitground_haildrop)
    inst.components.blowinwind:Stop()
    inst.components.inventoryitem:OnStartFalling()
end

local function commonfn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)

    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.MEDIUM, TUNING.WINDBLOWN_SCALE_MAX.MEDIUM)
    
    inst.AnimState:SetBank("ice")
    inst.AnimState:SetBuild("ice")
    inst.animname = names[math.random(#names)]
    inst.AnimState:PlayAnimation(inst.animname)
    -- MakeInventoryFloatable(inst, inst.animname.."_water", inst.animname)

    inst:AddComponent("smotherer")

    inst:AddTag("frozen")

    inst:ListenForEvent("firemelt", function(inst)
        inst.components.perishable.frozenfiremult = true
    end)
    inst:ListenForEvent("stopfiremelt", function(inst)
        inst.components.perishable.frozenfiremult = false
    end)

    inst:AddComponent("edible")
    inst.components.edible.foodtype = "GENERIC"
    inst.components.edible.healthvalue = TUNING.HEALING_TINY/2
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY/4
    inst.components.edible.degrades_with_spoilage = false
    inst.components.edible.temperaturedelta = TUNING.COLD_FOOD_BONUS_TEMP
    inst.components.edible.temperatureduration = TUNING.FOOD_TEMP_BRIEF * 1.5

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable:SetOnPerishFn(onperish)

    inst:AddComponent("tradable")
    
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    -- inst.components.inventoryitem.imagename = "ice"
    inst.components.inventoryitem:SetOnPickupFn(function(inst, owner)
        inst.components.perishable.frozenfiremult = false
    end)

    inst.OnSave = onsave
    inst.OnLoad = onload
    return inst
end

local function icefn(Sim) 
    local inst = commonfn(Sim)
    
    inst:AddComponent("repairer")
    inst.components.repairer.repairmaterial = "ICE"
    inst.components.repairer.perishrepairvalue = .05

    inst:AddComponent("bait")
    inst:AddTag("molebait")

    inst:ListenForEvent("onhitground", onhitground_ice)
    
    return inst
end

local function hailfn(Sim)
    local inst = commonfn(Sim)


    inst.components.perishable:SetPerishTime(TUNING.PERISH_ONE_DAY)

    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY/8
    inst.components.edible.foodtype = "ELEMENTAL"
    
    inst:ListenForEvent("onhitground", onhitground_hail)

    inst.StartFalling = hail_startfalling
    
    return inst
end

return Prefab( "common/inventory/ice", icefn, assets),
        Prefab( "common/inventory/hail_ice", hailfn, assets)
