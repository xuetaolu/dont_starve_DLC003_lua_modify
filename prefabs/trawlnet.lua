local net_assets=
{
    Asset("ANIM", "anim/swap_trawlnet.zip"),
    Asset("ANIM", "anim/swap_trawlnet_half.zip"),
    Asset("ANIM", "anim/swap_trawlnet_full.zip"),
}

local net_prefabs =
{
    "dropped_net"
}

local dropped_assets=
{
    Asset("ANIM", "anim/swap_trawlnet.zip"),
    Asset("ANIM", "anim/ui_chest_3x2.zip"),
}

local chance =
{
    verylow = 1,
    low = 2,
    medium = 4,
    high = 8,
}



local loot =
{
    shallow =
    {
     
        {"roe", chance.medium},

        {"seaweed", chance.high},
        {"mussel", chance.medium},
        {"lobster", chance.low},
        {"jellyfish", chance.low},
        {"fish", chance.medium},
        {"coral", chance.medium},
        {"messagebottleempty", chance.medium},
        {"fish_med", chance.low},
        {"rocks", chance.high},
    },


    medium =
    {
        {"roe", chance.medium},

        {"seaweed", chance.high},
        {"mussel", chance.high},
        {"lobster", chance.low},
        {"jellyfish", chance.medium},
        {"fish", chance.high},
        {"coral", chance.high},
        {"fish_med", chance.medium},
        {"messagebottleempty", chance.medium},
        {"boneshard", chance.medium},
        {"spoiled_fish", chance.medium},
        {"dubloon", chance.low},
        {"goldnugget", chance.low},
        {"telescope", chance.verylow},
        {"firestaff", chance.verylow},
        {"icestaff", chance.verylow},
        {"panflute", chance.verylow},
        {"trinket_16", chance.low},
        {"trinket_17", chance.medium},
        {"trinket_18", chance.verylow},
    },

    deep =
    {
        {"roe", chance.low},

        {"seaweed", chance.high},
        {"mussel", chance.high},
        {"lobster", chance.low},
        {"jellyfish", chance.high},
        {"fish", chance.high},
        {"coral", chance.high},
        {"fish_med", chance.high},
        {"messagebottleempty", chance.medium},
        {"boneshard", chance.medium},
        {"spoiled_fish", chance.medium},
        {"dubloon", chance.medium},
        {"goldnugget", chance.medium},
        {"telescope", chance.low},
        {"firestaff", chance.low},
        {"icestaff", chance.low},
        {"panflute", chance.low},
        {"redgem", chance.low},
        {"bluegem", chance.low},
        {"purplegem", chance.low},
        {"goldenshovel", chance.low},
        {"goldenaxe", chance.low},
        {"razor", chance.low},
        {"spear", chance.low},
        {"compass", chance.low},
        {"amulet", chance.verylow},
        {"trinket_16", chance.low},
        {"trinket_17", chance.low},
        {"trinket_18", chance.verylow},
        {"trident", chance.verylow},
    }
}

local hurricaneloot =
{
    shallow =
    {

        {"roe", chance.medium},

        {"seaweed", chance.high},
        {"mussel", chance.medium},
        {"lobster", chance.medium},
        {"jellyfish", chance.medium},
        {"fish", chance.high},
        {"coral", chance.high},
        {"messagebottleempty", chance.high},
        {"fish_med", chance.medium},
        {"rocks", chance.high},
        {"dubloon", chance.low},
        {"trinket_16", chance.low},
        {"trinket_17", chance.low},
    },


    medium =
    {
         {"roe", chance.medium},

        {"seaweed", chance.high},
        {"mussel", chance.high},
        {"lobster", chance.medium},
        {"jellyfish", chance.high},
        {"fish", chance.high},
        {"coral", chance.high},
        {"fish_med", chance.high},
        {"messagebottleempty", chance.high},
        {"boneshard", chance.high},
        {"spoiled_fish", chance.high},
        {"dubloon", chance.medium},
        {"goldnugget", chance.medium},
        {"telescope", chance.low},
        {"firestaff", chance.low},
        {"icestaff", chance.low},
        {"panflute", chance.low},
        {"trinket_16", chance.low},
        {"trinket_17", chance.low},
        {"trinket_18", chance.verylow},
        {"trident", chance.verylow},
    },


    deep =
    {
        {"roe", chance.low},

        {"seaweed", chance.high},
        {"mussel", chance.high},
        {"lobster", chance.low},
        {"jellyfish", chance.high},
        {"fish", chance.high},
        {"coral", chance.high},
        {"fish_med", chance.high},
        {"messagebottleempty", chance.high},
        {"boneshard", chance.high},
        {"spoiled_fish", chance.high},
        {"dubloon", chance.medium},
        {"goldnugget", chance.medium},
        {"telescope", chance.medium},
        {"firestaff", chance.low},
        {"icestaff", chance.medium},
        {"panflute", chance.medium},
        {"redgem", chance.medium},
        {"bluegem", chance.medium},
        {"purplegem", chance.medium},
        {"goldenshovel", chance.medium},
        {"goldenaxe", chance.medium},
        {"razor", chance.medium},
        {"spear", chance.medium},
        {"compass", chance.medium},
        {"amulet", chance.verylow},
        {"trinket_16", chance.medium},
        {"trinket_17", chance.medium},
        {"trinket_18", chance.verylow},
        {"trident", chance.low},
    }
}

local dryloot =
{
    shallow =
    {
        {"seaweed", chance.high},
        {"mussel", chance.high},
        {"lobster", chance.medium},
        {"jellyfish", chance.medium},
        {"fish", chance.high},
        {"coral", chance.high},
        {"messagebottleempty", chance.high},
        {"fish_med", chance.medium},
        {"rocks", chance.high},
        {"dubloon", chance.low},
        {"obsidian", chance.high},
    },


    medium =
    {
        {"seaweed", chance.high},
        {"mussel", chance.high},
        {"lobster", chance.medium},
        {"jellyfish", chance.high},
        {"fish", chance.high},
        {"coral", chance.high},
        {"fish_med", chance.high},
        {"messagebottleempty", chance.high},
        {"boneshard", chance.high},
        {"spoiled_fish", chance.high},
        {"dubloon", chance.medium},
        {"goldnugget", chance.medium},
        {"telescope", chance.low},
        {"firestaff", chance.medium},
        {"icestaff", chance.low},
        {"panflute", chance.low},
        {"obsidian", chance.medium},
        {"trinket_16", chance.low},
        {"trinket_17", chance.low},
        {"trinket_18", chance.verylow},
        {"trident", chance.verylow},
    },


    deep =
    {
        {"seaweed", chance.high},
        {"mussel", chance.high},
        {"lobster", chance.low},
        {"jellyfish", chance.high},
        {"fish", chance.high},
        {"coral", chance.high},
        {"fish_med", chance.high},
        {"messagebottleempty", chance.high},
        {"boneshard", chance.high},
        {"spoiled_fish", chance.high},
        {"dubloon", chance.medium},
        {"goldnugget", chance.medium},
        {"telescope", chance.medium},
        {"firestaff", chance.medium},
        {"icestaff", chance.low},
        {"panflute", chance.medium},
        {"redgem", chance.medium},
        {"bluegem", chance.medium},
        {"purplegem", chance.medium},
        {"goldenshovel", chance.medium},
        {"goldenaxe", chance.medium},
        {"razor", chance.medium},
        {"spear", chance.medium},
        {"compass", chance.medium},
        {"amulet", chance.verylow},
        {"obsidian", chance.medium},
        {"trinket_16", chance.low},
        {"trinket_17", chance.low},
        {"trinket_18", chance.verylow},
        {"trident", chance.low},
    }
}

local uniqueItems =
{
    "trinket_16",
    "trinket_17",
    "trinket_18",
    "trident",
}

local function gettrawlbuild(inst)
    local fullness = inst.components.inventory:NumItems()/inst.components.inventory.maxslots
    if fullness <= 0.33 then
        return "swap_trawlnet"
    elseif fullness <= 0.66 then
        return "swap_trawlnet_half"
    else
        return "swap_trawlnet_full"
    end
end

local function ontrawlpickup(inst, numitems, pickup)
    --#TODO: Change animoveride to represent the # of items in net.
    --print(string.format("%s picked up %s! Now has %2.0f items.", inst.prefab, pickup.prefab, numitems))

    local owner = inst.components.inventoryitem.owner
    local driver = nil

    if owner and owner.components.drivable then
        driver = owner.components.drivable.driver
        owner.AnimState:OverrideSymbol("swap_trawlnet", gettrawlbuild(inst), "swap_trawlnet")
        if driver then
            driver:PushEvent("trawlitem")
            driver.AnimState:OverrideSymbol("swap_trawlnet", gettrawlbuild(inst), "swap_trawlnet")
        end
    end

    inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/trawl_net/collect")
end


local function updatespeedmult(inst)
    local fullpenalty = TUNING.TRAWLING_SPEED_MULT
    local penalty = fullpenalty * (inst.components.inventory:NumItems()/TUNING.TRAWLNET_MAX_ITEMS)

    if inst.components.equippable.equipper and inst.components.equippable.equipper.components.drivable then
        local driver = inst.components.equippable.equipper.components.drivable.driver
        if driver then
            driver.components.locomotor:AddSpeedModifier_Mult("TRAWL", penalty)
        end
    end
end

local function pickupitem(inst,pickup)
    if pickup then
        print(pickup.prefab)
        local num = inst.components.inventory:NumItems()
        inst.components.inventory:GiveItem(pickup, num + 1)
        ontrawlpickup(inst, num + 1, pickup)

        if inst.components.inventory:IsFull() then
            local owner = inst.components.inventoryitem.owner
            if owner then
                if owner.components.drivable and owner.components.drivable.driver then
                    owner.components.drivable.driver:PushEvent("trawl_full")
                end
                owner.components.container:DropItem(inst)
            end
        else
            updatespeedmult(inst)
        end
    end
end

local specialCasePrefab =
{
    ["seaweed_planted"] = function(inst,net)
        if inst and inst.components.pickable then
            if inst.components.pickable.canbepicked
            and inst.components.pickable.caninteractwith then
                pickupitem(net, SpawnPrefab(inst.components.pickable.product))
            end            
            inst:Remove()
            return SpawnPrefab("seaweed_stalk")            
        end
    end,
    ["jellyfish_planted"] = function(inst)
        inst:Remove()
        return SpawnPrefab("jellyfish")
    end,
    ["mussel_farm"] = function(inst,net)
        if inst then     
            if inst.growthstage <= 0 then                              
                inst:Remove()
                return SpawnPrefab(inst.components.pickable.product)  
            end
        end
    end,
    ["sunkenprefab"] = function(inst)
        local sunken = SpawnSaveRecord(inst.components.sunkenprefabinfo:GetSunkenPrefab())
        sunken:LongUpdate(inst.components.sunkenprefabinfo:GetTimeSubmerged())
        inst:Remove()
        return sunken
    end,
    ["lobster"] = function(inst)
        return inst
    end,
}

local function isItemUnique(item)
    for i = 1, #uniqueItems do
        if uniqueItems[i] == item then
            return true
        end
    end
    return false
end

local function hasUniqueItem(inst)
    for k,v in pairs(inst.components.inventory.itemslots) do
        for i = 1, #uniqueItems do
            if uniqueItems[i] == v then
                return true
            end
        end
    end

    return false
end

local function getLootList(inst)
    local loottable = loot
    if GetWorld().components.seasonmanager:IsWetSeason() then
        loottable = hurricaneloot
    elseif GetWorld().components.seasonmanager:IsDrySeason() then
        loottable = dryloot
    end

    local pos = GetPlayer():GetPosition()
    local ground = GetWorld()
    local tile = GROUND.OCEAN_SHALLOW
    if ground and ground.Map then
        tile = ground.Map:GetTileAtPoint(pos:Get())
    end
    if tile == GROUND.OCEAN_MEDIUM then
        return loottable.medium
    elseif tile == GROUND.OCEAN_DEEP then
        return loottable.deep
    else
        return loottable.shallow
    end
end

local function selectLoot(inst)
    local total = 0
    local lootList = getLootList(inst)

    for i = 1, #lootList do
        total = total + lootList[i][2]
    end

    local choice = math.random(0,total)
    total = 0
    for i = 1, #lootList do
        total = total + lootList[i][2]
        if choice <= total then
            local loot = lootList[i][1]

            --Check if the player has already found one of these
            if isItemUnique(loot) and hasUniqueItem(inst) then
                --If so, pick a different item to give
                loot = selectLoot(inst)
                --NOTE - Possible infinite loop here if only possible loot is unique items.
            end

            return loot
        end
    end
end



local function droploot(inst, owner)
    local chest = SpawnPrefab("trawlnetdropped")
	local pt = inst.lastPos

    chest:DoDetach()

    chest.Transform:SetPosition(pt.x, pt.y, pt.z)

    local slotnum = 1
    for k,v in pairs(inst.components.inventory.itemslots) do
        chest.components.container:GiveItem(v, slotnum)
        slotnum = slotnum + 1
    end

    if owner and owner.components.drivable and owner.components.drivable.driver then
        local driver = owner.components.drivable.driver
        local angle = driver.Transform:GetRotation()
        local dist = -3
        local offset = Vector3(dist * math.cos(angle*DEGREES), 0, -dist*math.sin(angle*DEGREES))
        local chestpos = pt + offset        
        chest.Transform:SetPosition(chestpos:Get())
        chest:FacePoint(pt:Get())
    end
end



local function generateLoot(inst)
    return SpawnPrefab(selectLoot(inst))
end

local function stoptrawling(inst)
    inst.trawling = false
    if inst.trawltask then
        inst.trawltask:Cancel()
    end
end


local function isBehind(inst, tar)
    local pt = inst:GetPosition()
    local hp = tar:GetPosition()

    local heading_angle = -(inst.Transform:GetRotation())
    local dir = Vector3(math.cos(heading_angle*DEGREES),0, math.sin(heading_angle*DEGREES))

    local offset = (hp - pt):GetNormalized()     
    local dot = offset:Dot(dir)

    local dist = pt:Dist(hp)

    return dot <= 0 and dist >= 1
end

local function updateTrawling(inst)
    if not inst.trawling then
        return
    end

    local owner = inst.components.inventoryitem.owner
    local driver = nil

    if owner and owner.components.drivable then
        driver = owner.components.drivable.driver
    end

    if not driver then
        print("NO DRIVER IN TRAWLNET?! SOMETHING WENT WRONG!")
        stoptrawling(inst)
        return
    end

    local pickup = nil
    local pos = inst:GetPosition()
    local displacement = pos - inst.lastPos
    inst.distanceCounter = inst.distanceCounter + displacement:Length()

    if inst.distanceCounter > TUNING.TRAWLNET_ITEM_DISTANCE then
        pickup = generateLoot(inst)
        inst.distanceCounter = 0
    end

    inst.lastPos = pos

    if not pickup then
        local range = 2
        pickup = FindEntity(driver, range, function(item)
            return isBehind(driver, item)
                and ((item.components.inventoryitem and not item.components.inventoryitem:IsHeld()
                and item.components.floatable and item.components.inventoryitem.cangoincontainer)
                or specialCasePrefab[item.prefab] ~= nil) end, nil, {"trap", "FX", "NOCLICK", "player"})
    end

    if pickup and specialCasePrefab[pickup.prefab] then
        pickup = specialCasePrefab[pickup.prefab](pickup,inst)
    end

    if pickup then
        pickupitem(inst,pickup)
    end

end

local function starttrawling(inst)
    inst.trawling = true
    inst.lastPos = GetPlayer():GetPosition()
    inst.trawltask = inst:DoPeriodicTask(FRAMES * 5, updateTrawling)
    inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/trawl_net/attach")
end

local function onmounted(boat, data)
    local item = boat.components.container:GetItemInBoatSlot(BOATEQUIPSLOTS.BOAT_SAIL)
    data.driver.AnimState:OverrideSymbol("swap_trawlnet", gettrawlbuild(item), "swap_trawlnet")
    starttrawling(item)
    updatespeedmult(item)
end

local function ondismounted(boat, data)
    local item = boat.components.container:GetItemInBoatSlot(BOATEQUIPSLOTS.BOAT_SAIL)
    data.driver.AnimState:ClearOverrideSymbol("swap_trawlnet")
    stoptrawling(item)

    if data.driver.components.locomotor then
        data.driver.components.locomotor:RemoveSpeedModifier_Mult("TRAWL")
    end
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_trawlnet", gettrawlbuild(inst), "swap_trawlnet")
    if owner.components.drivable and owner.components.drivable.driver then
        owner.components.drivable.driver.AnimState:OverrideSymbol("swap_trawlnet", gettrawlbuild(inst), "swap_trawlnet")
    end
    inst.equippedby = owner
    inst.components.inventoryitem.cangoincontainer = false
    inst:ListenForEvent("mounted",  onmounted , owner)
    inst:ListenForEvent("dismounted", ondismounted , owner)
    updatespeedmult(inst)
    starttrawling(inst)
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_trawlnet")

    if owner.components.drivable and owner.components.drivable.driver then

        owner.components.drivable.driver.AnimState:ClearOverrideSymbol("swap_trawlnet")

        if owner.components.drivable.driver.components.locomotor then
            owner.components.drivable.driver.components.locomotor:RemoveSpeedModifier_Mult("TRAWL")
        end

    end

    inst.equippedby = nil
    inst:RemoveEventCallback("mounted", onmounted, owner)
    inst:RemoveEventCallback("dismounted", ondismounted, owner)
    stoptrawling(inst)
    droploot(inst, owner)
    inst:DoTaskInTime(2*FRAMES, inst.Remove)
end

local loots = {}

local function net(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

    inst.AnimState:SetBank("trawlnet")
    inst.AnimState:SetBuild("swap_trawlnet")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")
    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    inst.components.burnable:MakeDragonflyBait(3)

    inst:AddTag("trawlnet")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("inventory")
    inst.components.inventory.maxslots = TUNING.TRAWLNET_MAX_ITEMS
    inst.components.inventory.show_invspace = true

    inst:AddComponent("equippable")
    inst.components.equippable.boatequipslot = BOATEQUIPSLOTS.BOAT_SAIL
    inst.components.equippable.equipslot = nil

    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    inst.components.equippable.boatspeedmult = TUNING.TRAWLING_SPEED_MULT

    inst.currentLoot = {}
    inst.uniqueItemsFound = {}
    inst.distanceCounter = 0
    inst.trawltask = nil
    inst.equippedby = nil
    inst.rowsound = "dontstarve_DLC002/common/trawl_net/move_LP"
    updatespeedmult(inst)

    return inst
end


local function sink(inst, instant)
    if not instant then
        inst.AnimState:PlayAnimation("sink_pst")
        inst:ListenForEvent("animover", function()
            inst.components.container:DropEverything()            
            inst:Remove()
        end)
    else
        -- this is to catch the nets that for some reason dont have the right timer save data. 
        inst.components.container:DropEverything()
        inst:Remove()
    end
end

local function getsinkstate(inst)
    if inst.components.timer:TimerExists("sink") then
        return "sink"
    elseif inst.components.timer:TimerExists("startsink") then
        return "full"
    end
    return "sink"
end

local function startsink(inst)
    inst.AnimState:PlayAnimation("full_to_sink")
    inst.components.timer:StartTimer("sink", TUNING.TRAWL_SINK_TIME * 1/3)
    inst.AnimState:PushAnimation("idle_"..getsinkstate(inst), true)
end


local function dodetach(inst)
    inst.components.timer:StartTimer("startsink", TUNING.TRAWL_SINK_TIME * 2/3)
    inst.AnimState:PlayAnimation("detach")
    inst.AnimState:PushAnimation("idle_"..getsinkstate(inst), true)
    inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/trawl_net/detach")
end

local function onopen(inst)
    inst.AnimState:PlayAnimation("interact_"..getsinkstate(inst)) --TODO: uncomment this when this anim exists
    inst.AnimState:PushAnimation("idle_"..getsinkstate(inst), true)
    inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/trawl_net/open")
end

local function onclose(inst)
    inst.AnimState:PlayAnimation("interact_"..getsinkstate(inst)) --TODO: uncomment this when this anim exists
    inst.AnimState:PushAnimation("idle_"..getsinkstate(inst), true)
    inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/trawl_net/close")
end

local function ontimerdone(inst, data)
    if data.name == "startsink" then
        startsink(inst)
    end

    if data.name == "sink" then
        sink(inst)
    end
    -- These are sticking around some times.. maybe the timer name is being lost somehow? This will catch that?
    if data.name ~= "sink" and data.name ~= "startsink" then
        sink(inst)
    end
end


local function getstatusfn(inst, viewer)
    local sinkstate = getsinkstate(inst)
    local timeleft = (inst.components.timer and inst.components.timer:GetTimeLeft("sink")) or TUNING.TRAWL_SINK_TIME
    if sinkstate == "sink" then
        return "SOON"
    elseif sinkstate == "full" and timeleft <= (TUNING.TRAWL_SINK_TIME * 0.66) * 0.5 then
        return "SOONISH"
    else
        return "GENERIC"
    end
end

local function onloadtimer(inst)
    if not inst.components.timer:TimerExists("sink") and not inst.components.timer:TimerExists("startsink") then
        print("TRAWL NET HAD NO TIMERS AND WAS FORCE SUNK")
        sink(inst, true)
    end
end

local function onload(inst, data)
    inst.AnimState:PlayAnimation("idle_"..getsinkstate(inst), true)    
end

local slotpos = {}
for y = 2, 0, -1 do
    for x = 0, 2 do
        table.insert(slotpos, Vector3(80*x-80*2+80, 80*y-80*2+80,0))
    end
end

local function dropped_net()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    inst.Transform:SetTwoFaced()

    inst:AddTag("structure")
    inst:AddTag("chest")

    inst.AnimState:SetBank("trawlnet")
    inst.AnimState:SetBuild("swap_trawlnet")
    inst.AnimState:PlayAnimation("idle_full", true)
    inst.AnimState:SetLayer( LAYER_BACKGROUND )
    inst.AnimState:SetSortOrder( 3 )

    MakeInventoryPhysics(inst)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatusfn

    inst:AddComponent("container")
    inst.components.container:SetNumSlots(#slotpos)

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", ontimerdone)
    inst.onloadtimer = onloadtimer

    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose

    inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetanimbank = "ui_chest_3x3"
    inst.components.container.widgetanimbuild = "ui_chest_3x3"
    inst.components.container.widgetpos = Vector3(0,200,0)
    inst.components.container.side_align_tip = 160

    inst.DoDetach = dodetach

    -- this task is here because sometimes the savedata on the timer is empty.. so no timers are reloaded.
    -- when that happens, the nets sit around forever. 
    inst:DoTaskInTime(0,function() onloadtimer(inst) end)

    inst.OnLoad = onload

    return inst
end

return Prefab( "common/inventory/trawlnet", net, net_assets, net_prefabs),
Prefab( "common/inventory/trawlnetdropped", dropped_net, dropped_assets)