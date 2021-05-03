local assets=
{
	Asset("ANIM", "anim/staffs.zip"),
	Asset("ANIM", "anim/swap_staffs.zip"), 
}

local prefabs = 
{
    "ice_projectile",
    "fire_projectile",
    "staffcastfx",
	"stafflight",
    "staff_tornado",
    "cutgrass",
}

---------RED STAFF---------

local function onattack_red(inst, attacker, target)

    if target.components.burnable and not target.components.burnable:IsBurning() then
        if target.components.freezable and target.components.freezable:IsFrozen() then           
            target.components.freezable:Unfreeze()            
        else            
            if target.components.fueled and target:HasTag("campfire") and target:HasTag("structure") then
                -- Rather than worrying about adding fuel cmp here, just spawn some fuel and immediately feed it to the fire
                local fuel = SpawnPrefab("cutgrass")
                if fuel then target.components.fueled:TakeFuelItem(fuel) end
            else
                target.components.burnable:Ignite(true)
            end
        end   
    end

    if target:HasTag("aquatic") and not target.components.burnable then 
        local pt = target:GetPosition()
        local smoke = SpawnPrefab("smoke_out")
        smoke.Transform:SetPosition(pt:Get())

         if target.SoundEmitter then 
            target.SoundEmitter:PlaySound("dontstarve_DLC002/common/fire_weapon_out") 
        end 
    end 

    if target.components.freezable then
        target.components.freezable:AddColdness(-1) --Does this break ice staff?
        if target.components.freezable:IsFrozen() then
            target.components.freezable:Unfreeze()            
        end
    end

    if target.components.sleeper and target.components.sleeper:IsAsleep() then
        target.components.sleeper:WakeUp()
    end

    if attacker and attacker.components.sanity then
        attacker.components.sanity:DoDelta(-TUNING.SANITY_SUPERTINY)
    end

    attacker.SoundEmitter:PlaySound("dontstarve/wilson/fireball_explo")

    target:PushEvent("attacked", { attacker = attacker, damage = 0 })
end

local function onlight(inst, target)
    if inst.components.finiteuses then
        inst.components.finiteuses:Use(1)
    end
end

---------BLUE STAFF---------

local function onattack_blue(inst, attacker, target)
    if attacker and attacker.components.sanity then
        attacker.components.sanity:DoDelta(-TUNING.SANITY_SUPERTINY)
    end

    if not target:IsValid() then
        --target killed or removed in combat damage phase
        return
    end
    
    if target.components.sleeper and target.components.sleeper:IsAsleep() then
        target.components.sleeper:WakeUp()
    end
    if target.components.burnable then
        if target.components.burnable:IsBurning() then
            target.components.burnable:Extinguish()
        elseif target.components.burnable:IsSmoldering() then
            target.components.burnable:SmotherSmolder()
        end
    end

    if target.sg ~= nil and not target.sg:HasStateTag("frozen") then
        target:PushEvent("attacked", { attacker = attacker, damage = 0 })
    end

    if target.components.freezable then
        target.components.freezable:AddColdness(1)
        target.components.freezable:SpawnShatterFX()
    end
end

---------PURPLE STAFF---------

local function getrandomposition(inst, caster)
    local ground = GetWorld()
    local centers = {}

    if caster:HasTag("aquatic") then
        for i,node in ipairs(ground.topology.nodes) do
            if inst:GetIsOnWater(node.x, 0, node.y) then
                table.insert(centers, {x = node.x, z = node.y})
            end
        end
    else
        for i,node in ipairs(ground.topology.nodes) do
            if inst:GetIsOnLandOutside(node.x, 0, node.y) then
                table.insert(centers, {x = node.x, z = node.y})
            end
        end
    end

    if #centers > 0 then
		local pos = centers[math.random(#centers)]
		return Point(pos.x, 0, pos.z)
	else
		return GetPlayer():GetPosition()
	end
end

local function canteleport(inst, caster, target)
    if target then
        return target.components.locomotor ~= nil and not target:HasTag("noteleport")
    end

    return true
end

local function teleport_thread(inst, caster, teletarget, loctarget)
    local ground = GetWorld()

    local t_loc = nil
    if loctarget then
        t_loc = loctarget:GetPosition()
    else
        t_loc = getrandomposition(inst, caster)
    end

    local teleportee = teletarget
    local pt = teleportee:GetPosition()
    if teleportee.components.locomotor then
        teleportee.components.locomotor:StopMoving()
    end

    inst.components.finiteuses:Use(1)

    if ground.topology.level_type == "cave" then
        TheCamera:Shake("FULL", 0.3, 0.02, .5, 40)
        ground.components.quaker:MiniQuake(3, 5, 1.5, teleportee)     
        return
    end

    if teleportee.components.health then
        teleportee.components.health:SetInvincible(true)
    end

    if TUNING.DO_SEA_DAMAGE_TO_BOAT and (teleportee.components.driver and teleportee.components.driver.vehicle and teleportee.components.driver.vehicle.components.boathealth) then
        teleportee.components.driver.vehicle.components.boathealth:SetInvincible(true)
    end
    
    GetSeasonManager():DoLightningStrike(pt)
    teleportee:Hide()

    if teleportee == GetPlayer() then
        TheFrontEnd:Fade(false, 2)
        Sleep(3)
    end
    
    if caster.components.sanity then
        caster.components.sanity:DoDelta(-TUNING.SANITY_HUGE)
    end
    if ground.components.seasonmanager then
        ground.components.seasonmanager:ForcePrecip()
    end

	teleportee:Teleport(loctarget or t_loc)

    if loctarget and loctarget.onteleto then loctarget.onteleto(loctarget) end
    GetSeasonManager():DoLightningStrike(t_loc)
    teleportee:Show()
    if teleportee.components.health then
        teleportee.components.health:SetInvincible(false)
    end
    if TUNING.DO_SEA_DAMAGE_TO_BOAT and (teleportee.components.driver and teleportee.components.driver.vehicle and teleportee.components.driver.vehicle.components.boathealth) then
        teleportee.components.driver.vehicle.components.boathealth:SetInvincible(false)
    end

    if teleportee == GetPlayer() then
        teleportee.sg:GoToState("wakeup")
        teleportee.SoundEmitter:PlaySound("dontstarve/common/staffteleport")
    end
end

local function teleport_func(inst, target)
    local mindistance = 1
    local caster = inst.components.inventoryitem.owner
    local tar = target or caster
    local pt = tar:GetPosition()
    local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 9000, {"telebase"})

    if #ents <= 0 or tar:HasTag("aquatic") or tar:GetIsOnWater() then
        --There's no bases, active or inactive. Teleport randomly.
        inst.task = inst:StartThread(function() teleport_thread(inst, caster, tar) end)
        return
    end

    local targets = {}
    for k,v in pairs(ents) do
        local v_pt = v:GetPosition()
        if distsq(pt, v_pt) >= mindistance * mindistance then
            table.insert(targets, {base = v, distance = distsq(pt, v_pt)}) 
        end
    end

    table.sort(targets, function(a,b) return (a.distance) < (b.distance) end)
    for i = 1, #targets do
        local teletarget = targets[i]
        if teletarget.base and teletarget.base.canteleto(teletarget.base) then
            inst.task = inst:StartThread(function()  teleport_thread(inst, caster, tar, teletarget.base) end)
            return
        end
    end

    inst.task = inst:StartThread(function() teleport_thread(inst, caster, tar) end)
end

---------ORANGE STAFF-----------

local function onblink(staff, pos, caster)

    if caster.components.sanity then
        caster.components.sanity:DoDelta(-TUNING.SANITY_MED)
    end

    staff.components.finiteuses:Use(1) 

end

-------GREEN STAFF-----------

local DESTSOUNDS =
{
    {   --magic
        soundpath = "dontstarve/common/destroy_magic",
        ing = {"nightmarefuel", "livinglog"},
    },
    {   --cloth
        soundpath = "dontstarve/common/destroy_clothing",
        ing = {"silk", "beefalowool"},
    },
    {   --tool
        soundpath = "dontstarve/common/destroy_tool",
        ing = {"twigs"},
    },
    {   --gem
        soundpath = "dontstarve/common/gem_shatter",
        ing = {"redgem", "bluegem", "greengem", "purplegem", "yellowgem", "orangegem"},
    },
    {   --wood
        soundpath = "dontstarve/common/destroy_wood",
        ing = {"log", "board"}
    },
    {   --stone
        soundpath = "dontstarve/common/destroy_stone",
        ing = {"rocks", "cutstone"}
    },
    {   --straw
        soundpath = "dontstarve/common/destroy_straw",
        ing = {"cutgrass", "cutreeds"}
    },
}

local function candestroy(staff, caster, target)
	if not target then return false end

    local recipe = GetRecipe(target.prefab)

    return recipe ~= nil
end

local function SpawnLootPrefab(inst, lootprefab)
    if lootprefab then
        local loot = SpawnPrefab(lootprefab)
        if loot then
            
            local pt = Point(inst.Transform:GetWorldPosition())           
            
            loot.Transform:SetPosition(pt.x,pt.y,pt.z)
            
            if loot.Physics then
            
                local angle = math.random()*2*PI
                loot.Physics:SetVel(2*math.cos(angle), 10, 2*math.sin(angle))

                if loot.Physics and inst.Physics then
                    pt = pt + Vector3(math.cos(angle), 0, math.sin(angle))*(loot.Physics:GetRadius() + inst.Physics:GetRadius())
                    loot.Transform:SetPosition(pt.x,pt.y,pt.z)
                end
                
                loot:DoTaskInTime(1, 
                    function() 
                        if not (loot.components.inventoryitem and loot.components.inventoryitem:IsHeld()) then
                            if not loot:IsOnValidGround() then
                                local fx = SpawnPrefab("splash_ocean")
                                local pos = loot:GetPosition()
                                fx.Transform:SetPosition(pos.x, pos.y, pos.z)
                                --PlayFX(loot:GetPosition(), "splash", "splash_ocean", "idle")
                                if loot:HasTag("irreplaceable") then
                                    loot.Transform:SetPosition(GetPlayer().Transform:GetWorldPosition())
                                else
                                    loot:Remove()
                                end
                            end
                        end
                    end)
            end
            
            return loot
        end
    end
end

local function getsoundsforstructure(inst, target)

    local sounds = {}

    local recipe = GetRecipe(target.prefab)

    if recipe then       
        for k, soundtbl in pairs(DESTSOUNDS) do
            for k2, ing in pairs(soundtbl.ing) do
                for k3, rec_ingredients in pairs(recipe.ingredients) do
                    if rec_ingredients.type == ing then
                        table.insert(sounds, soundtbl.soundpath)
                    end
                end 
            end
        end
    end

    return sounds

end

local function destroystructure(staff, target)

    local ingredient_percent = 1

    if target.components.finiteuses then
        ingredient_percent = target.components.finiteuses:GetPercent()
    elseif target.components.fueled and target.components.inventoryitem then
        ingredient_percent = target.components.fueled:GetPercent()
    elseif target.components.armor and target.components.inventoryitem then
        ingredient_percent = target.components.armor:GetPercent()
    end

    local recipe = GetRecipe(target.prefab)

    local caster = staff.components.inventoryitem.owner

    local loot = {}

    if recipe then       
        for k,v in ipairs(recipe.ingredients) do
            if not string.find(v.type, "gem") then
                local amt = math.ceil(v.amount * ingredient_percent)
                for n = 1, amt do
                    table.insert(loot, v.type)
                end
            end
        end
    end

    if #loot <= 0 then
        return
    end

    local sounds = {}
    sounds = getsoundsforstructure(staff, target)
    for k,v in pairs(sounds) do
        print("playing ",v)
        staff.SoundEmitter:PlaySound(v)
    end

    for k,v in pairs(loot) do
        SpawnLootPrefab(target, v)
    end

    if caster.components.sanity then
        caster.components.sanity:DoDelta(-TUNING.SANITY_MEDLARGE)
    end

    staff.SoundEmitter:PlaySound("dontstarve/common/staff_star_dissassemble")

    staff.components.finiteuses:Use(1)

    if target.components.inventory then
        target.components.inventory:DropEverything()
    end

    if target.components.container then
        target.components.container:DropEverything()
    end

    if target.components.stackable then
        --if it's stackable we only want to destroy one of them.
        target = target.components.stackable:Get()
    end

    if target.components.fixable then
        target.components.fixable.overridden = true
    end

    target:Remove()
    
    if target.components.resurrector and not target.components.resurrector.used then
        local player = GetPlayer()
        if player then
            player.components.health:RecalculatePenalty()
        end
    end
end

---------YELLOW STAFF-------------

local function cancreatelight(staff, caster, target, pos)
    local ground = GetWorld()
    if ground and pos then
        local tile = ground.Map:GetTileAtPoint(pos.x, pos.y, pos.z)
        return tile ~= GROUND.IMPASSIBLE and tile < GROUND.UNDERGROUND
    end
    return false
end

local function createlight(staff, target, pos)
    local light = SpawnPrefab("stafflight")
    light.Transform:SetPosition(pos.x, pos.y, pos.z)
    staff.components.finiteuses:Use(1)

    local caster = staff.components.inventoryitem.owner
    if caster and caster.components.sanity then
        caster.components.sanity:DoDelta(-TUNING.SANITY_MEDLARGE)
    end

end

---------VOLCANO STAFF------------
local function cancreateeruption(staff, caster, target, pos)
    return cancreatelight(staff, caster, target, pos)
end

local function createeruption(staff, target, pos)
    if SaveGameIndex:IsModeShipwrecked() then
        staff.components.finiteuses:Use(1)

        local delay = 0.0
        for i = 1, TUNING.VOLCANOSTAFF_FIRERAIN_COUNT, 1 do
            local x, y, z = TUNING.VOLCANOSTAFF_FIRERAIN_RADIUS * UnitRand() + pos.x, pos.y, TUNING.VOLCANOSTAFF_FIRERAIN_RADIUS * UnitRand() + pos.z
            staff:DoTaskInTime(delay, function(inst)
                local firerain = SpawnPrefab("firerain")
                firerain.Transform:SetPosition(x, y, z)
                firerain:StartStep()
            end)
            delay = delay + TUNING.VOLCANOSTAFF_FIRERAIN_DELAY
        end

        GetWorld().components.volcanomanager:StartStaffEffect(TUNING.VOLCANOSTAFF_ASH_TIMER)
    else
        --Say something about why the staff doesn't work here.
        local owner = nil
        owner = staff.components.inventoryitem:GetGrandOwner()
        if owner then
            owner:PushEvent("magic_fail")
        end
    end
end
---------BONE STAFF------------
local function spawngaze(inst)

    local owner = nil
    owner = inst.components.inventoryitem:GetGrandOwner()
    local mousepos = TheInput:GetWorldPosition()
    local rotation = nil

    if TheInput:ControllerAttached() then
        local pc = GetPlayer().components.playercontroller
        if pc.reticule and pc.reticule.targetpos then
            local pt = pc.reticule.targetpos
            rotation = owner:GetAngleToPoint(pt.x, pt.y, pt.z)
        end        
        
        if not rotation then 
            print("GETTING PLAYER ROTATION")
            rotation = owner.Transform:GetRotation()
        end
        print(rotation, owner:GetAngleToPoint(mousepos.x, mousepos.y, mousepos.z) )
    else
        rotation = owner:GetAngleToPoint(mousepos.x, mousepos.y, mousepos.z)
    end

    local beam = SpawnPrefab("gaze_beam")
    local pt = Vector3(owner.Transform:GetWorldPosition())
    local angle = rotation * DEGREES
    local radius = 4 
    local offset = Vector3(radius * math.cos( angle ), 0, -radius * math.sin( angle ))
    local newpt = pt+offset

    beam.Transform:SetPosition(newpt.x,newpt.y,newpt.z)
    beam.host = owner

    beam.Transform:SetRotation(rotation)
end

local function endgaze(inst)
    if inst.gazetask then
        inst.gazetask:Cancel()
        inst.gazetask = nil
    end
    inst.SoundEmitter:KillSound("gazor")
end

local function endbonecast(inst)
    endgaze(inst)
end

local function dogaze(inst)
    local owner = nil
    owner = inst.components.inventoryitem:GetGrandOwner()
    if inst.gazetask then
        endgaze(inst)
    end
    if owner then
        inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/pugalisk/gaze_start")
        inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/pugalisk/gaze_LP","gazor")
        inst.gazetask = inst:DoPeriodicTask(0.4,function() 
                if owner.sg:HasStateTag("spell") then
                    spawngaze(inst) 
                else
                    endgaze(inst)
                end
            end)     
    end
end

local function cancreategaze(staff, caster, target, pos)
    return cancreatelight(staff, caster, target, pos)
end

local function creategaze(staff, target, pos)
    dogaze(staff)
end
---------COMMON FUNCTIONS---------

local function onfinished(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/gem_shatter")
    inst:Remove()
end

local function unimplementeditem(inst)
    local player = GetPlayer()
    player.components.talker:Say(GetString(player.prefab, "ANNOUNCE_UNIMPLEMENTED"))
    if player.components.health.currenthealth > 1 then
        player.components.health:DoDelta(-player.components.health.currenthealth * 0.5)
    end

    if inst.components.useableitem then
        inst.components.useableitem:StopUsingItem()
    end
end

local function commonfn(colour, infinite)

    local onequip = function(inst, owner) 
        owner.AnimState:OverrideSymbol("swap_object", "swap_staffs", colour.."staff")
        owner.AnimState:Show("ARM_carry") 
        owner.AnimState:Hide("ARM_normal") 
    end

    local onunequip = function(inst, owner) 
        owner.AnimState:Hide("ARM_carry") 
        owner.AnimState:Show("ARM_normal") 
    end

	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, colour.."staff_water", colour.."staff")
    
    anim:SetBank("staffs")
    anim:SetBuild("staffs")
    anim:PlayAnimation(colour.."staff")
    -------   
    if not infinite then
        inst:AddComponent("finiteuses")
        inst.components.finiteuses:SetOnFinished( onfinished )
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("tradable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )


    
    return inst
end


---------COLOUR SPECIFIC CONSTRUCTIONS---------

local function red()
    local inst = commonfn("red")


    inst:AddTag("firestaff")
    inst:AddTag("rangedfireweapon")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)
    inst.components.weapon:SetRange(8, 10)
    inst.components.weapon:SetOnAttack(onattack_red)
    inst.components.weapon:SetProjectile("fire_projectile")

    -- inst:AddComponent("lighter")
    -- inst.components.lighter:SetOnLightFn(onlight)
    inst:AddTag("rangedlighter")

    inst.components.finiteuses:SetMaxUses(TUNING.FIRESTAFF_USES)
    inst.components.finiteuses:SetUses(TUNING.FIRESTAFF_USES)

    return inst
end

local function blue()
    local inst = commonfn("blue")
    
    inst:AddTag("icestaff")
    inst:AddTag("extinguisher")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)
    inst.components.weapon:SetRange(8, 10)
    inst.components.weapon:SetOnAttack(onattack_blue)
    inst.components.weapon:SetProjectile("ice_projectile")

    inst.components.finiteuses:SetMaxUses(TUNING.ICESTAFF_USES)
    inst.components.finiteuses:SetUses(TUNING.ICESTAFF_USES)
    
    return inst
end

local function purple()
    local inst = commonfn("purple")
    inst.fxcolour = {104/255,40/255,121/255}
    inst.components.finiteuses:SetMaxUses(TUNING.TELESTAFF_USES)
    inst.components.finiteuses:SetUses(TUNING.TELESTAFF_USES)
    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(teleport_func)
    inst.components.spellcaster.canuseontargets = true
    --inst.components.spellcaster.canusefrominventory = false
    inst.components.spellcaster:SetSpellTestFn(canteleport)
    inst:AddTag("nopunch")

    return inst
end

local function yellow()
    local inst = commonfn("yellow")
    inst.fxcolour = {223/255, 208/255, 69/255}
    inst.castsound = "dontstarve/common/staffteleport"

    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(createlight)
    inst.components.spellcaster:SetSpellTestFn(cancreatelight)
    inst.components.spellcaster.canuseonpoint = true
    inst.components.spellcaster.canusefrominventory = false

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = function() 
        return Vector3(GetPlayer().entity:LocalToWorldSpace(5,0,0))
    end
    inst.components.reticule.ease = true

    inst.components.finiteuses:SetMaxUses(TUNING.YELLOWSTAFF_USES)
    inst.components.finiteuses:SetUses(TUNING.YELLOWSTAFF_USES)
    inst:AddTag("nopunch")

    return inst
end

local function green()
    local inst = commonfn("green")
    inst:AddTag("nopunch")
    inst.fxcolour = {51/255,153/255,51/255}
    inst:AddComponent("spellcaster")
    inst.components.spellcaster.canuseontargets = true
    inst.components.spellcaster.canusefrominventory = false
    inst.components.spellcaster:SetSpellTestFn(candestroy)
    inst.components.spellcaster:SetSpellFn(destroystructure)

    inst.components.finiteuses:SetMaxUses(TUNING.GREENSTAFF_USES)
    inst.components.finiteuses:SetUses(TUNING.GREENSTAFF_USES)

    return inst
end

local function orange()
    local inst = commonfn("orange")
    
    inst.fxcolour = {1, 145/255, 0}
    inst.castsound = "dontstarve/common/staffteleport"

    inst:AddComponent("blinkstaff")
    inst.components.blinkstaff.onblinkfn = onblink
    
    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = function() 
        return inst.components.blinkstaff:GetBlinkPoint()
    end
    inst.components.reticule.ease = true

    inst.components.equippable.walkspeedmult = TUNING.CANE_SPEED_MULT

    inst.components.finiteuses:SetMaxUses(TUNING.ORANGESTAFF_USES)
    inst.components.finiteuses:SetUses(TUNING.ORANGESTAFF_USES)
    inst:AddTag("nopunch")

    return inst
end

local function volcano()
    local inst = commonfn("meteor")

    inst:AddTag("nosteal")
    inst.fxcolour = {223/255, 208/255, 69/255}
    inst.castsound = "dontstarve/common/staffteleport"

    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(createeruption)
    inst.components.spellcaster:SetSpellTestFn(cancreateeruption)
    inst.components.spellcaster.canuseonpoint = true
    inst.components.spellcaster.canusefrominventory = false

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = function() 

        return Vector3(GetPlayer().entity:LocalToWorldSpace(5,0,0))
    end
    inst.components.reticule.ease = true

    inst.components.finiteuses:SetMaxUses(TUNING.VOLCANOSTAFF_USES)
    inst.components.finiteuses:SetUses(TUNING.VOLCANOSTAFF_USES)
    inst:AddTag("nopunch")

    return inst
end

local function bone()
    local inst = commonfn("bone",true)

    inst:AddTag("nosteal")
    inst.fxcolour = {223/255, 208/255, 69/255}
   -- inst.castsound = "dontstarve_DLC003/creatures/boss/pugalisk/gaze_start"

    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(creategaze)
    inst.components.spellcaster:SetSpellTestFn(cancreategaze)
    inst.components.spellcaster.canuseonpoint = true
    inst.components.spellcaster.canusefrominventory = false
    inst.castfast = true

    inst:AddTag("show_spoilage")

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_ONE_DAY/2)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "boneshard"

    inst.endcast = endbonecast

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = function()
        local pc = GetPlayer().components.playercontroller
        local offset = pc:GetWorldControllerVector()
        if offset then
            local newpt = Vector3(GetPlayer().Transform:GetWorldPosition())
            newpt.x = newpt.x + (offset.x *5)
            newpt.z = newpt.z + (offset.z *5)
            return newpt
        end
    end
    inst.components.reticule.ease = true

    inst:AddTag("nopunch")

    return inst
end

return Prefab( "common/inventory/icestaff", blue, assets, prefabs),
Prefab("common/inventory/firestaff", red, assets, prefabs),
Prefab("common/inventory/telestaff", purple, assets, prefabs),
Prefab("common/inventory/orangestaff", orange, assets, prefabs),
Prefab("common/inventory/greenstaff", green, assets, prefabs),
Prefab("common/inventory/yellowstaff", yellow, assets, prefabs),
Prefab("common/inventory/volcanostaff", volcano, assets, prefabs),
Prefab("common/inventory/bonestaff", bone, assets, prefabs)
