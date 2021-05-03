local MakePlayerCharacter = require "prefabs/player_common"
local assets = 
{
    Asset("ANIM", "anim/wilba.zip"),
    Asset("ANIM", "anim/werewilba.zip"),
    Asset("ANIM", "anim/werewilba_actions.zip"),
    Asset("ANIM", "anim/werewilba_transform.zip"),
    Asset("INV_IMAGE", "werewilbafur"),
    Asset("ATLAS", "images/woodie.xml"),    
    Asset("IMAGE", "images/woodie.tex"),
    Asset("IMAGE", "images/colour_cubes/beaver_vision_cc.tex"),     Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}


local prefabs = { "silvernecklace","werewilbafur_head","werewilbafur_body","werewilbafur_hands" }

local start_inv = { "silvernecklace" }

local MONSTERMEAT_COUNT = 2
local MONSTER_COOLDOWN = TUNING.TOTAL_DAY_TIME / MONSTERMEAT_COUNT

local function CanGoWere(inst)
    return (inst.monster_count >= MONSTERMEAT_COUNT or inst.from_food) or ((GetClock():IsNight() and GetClock():GetMoonPhase() == "full") or GetClock():GetBloodMoon())
end

local function WereActionButton(inst)

    local action_target = FindEntity(inst, 6, function(guy) return (guy.components.door and not guy.components.door.disabled and (not guy.components.burnable or not guy.components.burnable:IsBurning())) or 
                                                                   (guy.components.edible and inst.components.eater:CanEat(guy)) or
                                                                   (guy.components.workable and guy.components.workable.workable and inst.components.worker:CanDoAction(guy.components.workable.action)) or
                                                                   (guy.components.inventoryitem and guy.components.inventoryitem.canbepickedup) or 
                                                                   (guy.components.pickable and guy.components.pickable:CanBePicked()) or
                                                                   (guy.components.hackable and guy.components.hackable:CanBeHacked() and inst.components.worker:CanDoAction(ACTIONS.HACK)) or
                                                                   (guy.components.activatable and guy.components.activatable.inactive) end)

    if not inst.sg:HasStateTag("busy") and action_target then
        if action_target.components.inventoryitem and action_target.components.inventoryitem.canbepickedup then 
            return BufferedAction(inst, action_target, ACTIONS.PICKUP)
        elseif action_target.components.door and not action_target.components.door.disabled and (not action_target.components.burnable or not action_target.components.burnable:IsBurning()) then
            return BufferedAction(inst, action_target, ACTIONS.USEDOOR)
        elseif (action_target.components.edible and inst.components.eater:CanEat(action_target)) then
            return BufferedAction(inst, action_target, ACTIONS.EAT)
        elseif action_target.components.workable and action_target.components.workable.workable and action_target.components.workable.workleft > 0 then
            return BufferedAction(inst, action_target, action_target.components.workable.action)
        elseif action_target.components.pickable and action_target.components.pickable:CanBePicked() then
            return BufferedAction(inst, action_target, ACTIONS.PICK)
        elseif action_target.components.hackable and action_target.components.hackable:CanBeHacked() and action_target.components.hackable.hacksleft > 0 then
            return BufferedAction(inst, action_target, ACTIONS.HACK)
        elseif action_target.components.activatable and action_target.components.activatable.inactive then
            return BufferedAction(inst, action_target, ACTIONS.ACTIVATE)
        end
    end

end

local function LeftClickPicker(inst, target_ent, pos)
    local active_item = inst.components.inventory:GetActiveItem()

    if target_ent then

        if target_ent.components.inventoryitem and target_ent.components.inventoryitem.canbepickedup then 
            return inst.components.playeractionpicker:SortActionList({ACTIONS.PICKUP}, target_ent, nil)

        elseif target_ent.components.door and not target_ent.components.door.disabled and not target_ent.components.door.hidden and (not target_ent.components.burnable or not target_ent.components.burnable:IsBurning()) then
            return inst.components.playeractionpicker:SortActionList({ACTIONS.USEDOOR}, target_ent, nil)

        elseif inst.components.combat:CanTarget(target_ent) then
            return inst.components.playeractionpicker:SortActionList({ACTIONS.ATTACK}, target_ent, nil)

        elseif target_ent.components.edible and inst.components.eater:CanEat(target_ent) then
            return inst.components.playeractionpicker:SortActionList({ACTIONS.EAT}, target_ent, nil)

        elseif target_ent.components.workable and target_ent.components.workable.workable and target_ent.components.workable.workleft > 0 and inst.components.worker:CanDoAction(target_ent.components.workable.action) then
            return inst.components.playeractionpicker:SortActionList({target_ent.components.workable.action}, target_ent, nil)

        elseif target_ent.components.pickable and target_ent.components.pickable:CanBePicked() then
            return inst.components.playeractionpicker:SortActionList({ACTIONS.PICK}, target_ent, nil)

        elseif target_ent.components.pickable and target_ent.components.pickable:CanBePicked() then
            return inst.components.playeractionpicker:SortActionList({ACTIONS.PICK}, target_ent, nil)

        elseif target_ent.components.hackable and target_ent.components.hackable:CanBeHacked() and target_ent.components.hackable.hacksleft > 0 and inst.components.worker:CanDoAction(ACTIONS.HACK) then
            return inst.components.playeractionpicker:SortActionList({ACTIONS.HACK}, target_ent, nil)

        elseif target_ent.components.activatable and target_ent.components.activatable.inactive then
            return inst.components.playeractionpicker:SortActionList({ACTIONS.ACTIVATE}, target_ent, nil)

        elseif active_item and active_item.components.edible and target_ent:HasTag("player") then
            return inst.components.playeractionpicker:SortActionList({ACTIONS.EAT}, nil, active_item)

        elseif active_item and target_ent:HasTag("weighdownable") then
            return inst.components.playeractionpicker:SortActionList({ACTIONS.WEIGHDOWN}, target_ent, active_item)
        end

    elseif active_item then
        local passable = true
        local ground = GetWorld()

        if pos and ground and ground.Map then
            local tile = ground.Map:GetTileAtPoint(pos.x, pos.y, pos.z)
            passable = tile ~= GROUND.IMPASSABLE
        end

        if passable then
            return inst.components.playeractionpicker:GetPointActions(pos, active_item)
        end
    end
end
--[[
local function RightClickPicker(inst, target_ent, pos)

    local active_item = inst.components.inventory:GetActiveItem()

    if target_ent then
        print("TARGET ENT",target_ent.prefab)

    elseif active_item then
        print("ACTIVE ITEM",active_item.prefab)
    end
    return {}
end
]]

local function BreatheSounds(inst)    
    inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/werewilba/breath_in")
end

local function BreatheSounds_out(inst)    
    inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/werewilba/breath_out")
end


local function RandomGrunt(inst)
    if inst.grunt_task then
        inst.grunt_task:Cancel()
        inst.grunt_task = nil    
    end

    inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/werewilba/bark")
    inst.grunt_task = inst:DoTaskInTime(math.random(TUNING.TOTAL_DAY_TIME/15, TUNING.TOTAL_DAY_TIME/10), function() RandomGrunt(inst) end)
end

local function NecklaceComment(inst)
    if inst.comment_task then
        inst.comment_task:Cancel()
        inst.comment_task = nil
    end

    inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_NECKLACE_ACTIVE"))
    inst.comment_task = inst:DoTaskInTime(math.random(TUNING.TOTAL_DAY_TIME/15, TUNING.TOTAL_DAY_TIME/10), function() NecklaceComment(inst) end)
end

local function SetHUDState(inst, force)
    if inst.HUD then
        if inst.were or force then
            if not inst.HUD.werepigOL then                
                inst.HUD.werepigOL = inst.HUD.under_root:AddChild(Image("images/woodie.xml", "beaver_vision_OL.tex"))
                inst.HUD.werepigOL:SetVRegPoint(ANCHOR_MIDDLE)
                inst.HUD.werepigOL:SetHRegPoint(ANCHOR_MIDDLE)
                inst.HUD.werepigOL:SetVAnchor(ANCHOR_MIDDLE)
                inst.HUD.werepigOL:SetHAnchor(ANCHOR_MIDDLE)
                inst.HUD.werepigOL:SetScaleMode(SCALEMODE_FILLSCREEN)
                inst.HUD.werepigOL:SetClickable(false)
            end
        else           
            if inst.HUD.werepigOL then
                inst.HUD.werepigOL:Kill()
                inst.HUD.werepigOL = nil
            end
        end
    end    
end

local function StartRegen(inst)
    inst.components.health:StartRegen(0.5, 1, nil, true)
    inst.pulse_task = inst:DoPeriodicTask(1, function()
        if inst.HUD and inst.components.health:GetPercent() < 1 then
            inst.HUD.controls.status.heart:PulseGreen()
        end
    end)
end

local function StopRegen(inst)
    inst.components.health:StopRegen()
    if inst.pulse_task then
        inst.pulse_task:Cancel()
        inst.pulse_task = nil
    end
end

local function TransformToWere(inst)  
    local inventory = inst.components.inventory
    for k,v in pairs(inventory.equipslots) do
        inventory:DropItem(inventory:Unequip(k),true)
    end
    inventory:DropItems(inventory:UnequipAll(),true)

    local headfur = SpawnPrefab("werewilbafur_head")
    local handfur = SpawnPrefab("werewilbafur_hands")
    local bodyfur = SpawnPrefab("werewilbafur_body")

    inventory:Equip(headfur) 
    inventory:Equip(handfur) 
    inventory:Equip(bodyfur)

    if inst.comment_task then
        inst.comment_task:Cancel()
        inst.comment_task = nil
    end
    inst:DoTaskInTime(0, function() SetHUDState(inst, true) end)
end

local function TransformToWere_pst(inst)    
    inst.ready_to_transform = false
    inst.were = true
    inst.components.hunger:AddBurnRateModifier("werewilba", 5)

    inst.components.health:SetMaxHealth(TUNING.WEREWILBA_HEALTH)
    inst.components.health:SetPercent(1)

    if not inst.components.hunger:IsStarving() then
        StartRegen(inst)
    end

    inst:ListenForEvent("startstarving", StopRegen)
    inst:ListenForEvent("stopstarving", StartRegen)

    inst.components.sanity:SetNightDrainMultiplier(0)

    inst.components.combat:SetDefaultDamage(TUNING.WEREWILBA_DAMAGE)
    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED*1.5

    inst.components.playercontroller.actionbuttonoverride = WereActionButton
    inst.components.playeractionpicker.leftclickoverride = LeftClickPicker
    inst.components.playeractionpicker.rightclickoverride = function() return {} end

    inst:AddComponent("worker")
    inst.components.worker:SetAction(ACTIONS.DIG)
    inst.components.worker:SetAction(ACTIONS.CHOP, 2)
    inst.components.worker:SetAction(ACTIONS.MINE)
    inst.components.worker:SetAction(ACTIONS.HAMMER)
    inst.components.worker:SetAction(ACTIONS.HACK)

    inst:AddTag("monster")
    inst:RemoveTag("pigroyalty")

    inst.AnimState:SetBuild("werewilba")
    inst.AnimState:SetBank("wilson")
    inst.components.talker.special_speech = true

    inst.components.dynamicmusic:Disable()
    inst.SoundEmitter:PlaySound("dontstarve_DLC003/music/werepig_of_london", "werepigmusic")
    inst:DoTaskInTime(0, function() SetHUDState(inst) end)
    GetWorld().components.colourcubemanager:SetOverrideColourCube("images/colour_cubes/beaver_vision_cc.tex")
    
    inst.components.temperature:SetTemp(20)
    inst.grunt_task = inst:DoTaskInTime(math.random(TUNING.TOTAL_DAY_TIME/15, TUNING.TOTAL_DAY_TIME/5), function () RandomGrunt(inst) end)

    inst.breath_task = inst:DoPeriodicTask(2, function () BreatheSounds(inst) end)
    inst.breath_task2 = inst:DoTaskInTime(3,function() 
        if inst.breath_task2 then
            inst.breath_task2:Cancel()
            inst.breath_task2 = nil
        end
        inst.breath_task2 = inst:DoPeriodicTask(2, function () BreatheSounds_out(inst) end) 
        end)
    inst.Light:Enable(true)
    inst.soundsname = "werewilba"

    if inst:HasTag("lightsource") then       
        inst:RemoveTag("lightsource")    
    end    
end

local function TransformToWilba(inst)

    local inventory = inst.components.inventory
    
    local headfur = inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
    if headfur then
        headfur.components.equippable.un_unequipable = nil
        headfur:Remove()
    end
    
    local handfur = inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    if handfur then
        handfur.components.equippable.un_unequipable = nil
        handfur:Remove()
    end

    local bodyfur = inventory:GetEquippedItem(EQUIPSLOTS.BODY)
    if bodyfur then
        bodyfur.components.equippable.un_unequipable = nil
        bodyfur:Remove()
    end


    inst.components.hunger:RemoveBurnRateModifier("werewilba")

    inst.components.health:SetMaxHealth(TUNING.WILBA_HEALTH)
    inst.components.health:SetPercent(1)

    inst:RemoveEventCallback("startstarving", StopRegen)
    inst:RemoveEventCallback("stopstarving", StartRegen)

    inst.components.sanity:SetNightDrainMultiplier(1.5)

    StopRegen(inst)

    inst.components.combat:SetDefaultDamage(TUNING.UNARMED_DAMAGE)
    inst.components.locomotor.runspeed = TUNING.WILSON_RUN_SPEED

    inst.components.playercontroller.actionbuttonoverride = nil
    inst.components.playeractionpicker.leftclickoverride = nil
    inst.components.playeractionpicker.rightclickoverride = nil

    inst:RemoveComponent("worker")

    inst.components.talker.special_speech = false

    inst:RemoveTag("monster")
    inst:AddTag("pigroyalty")
    
    inst.AnimState:SetBuild("wilba")
    inst.AnimState:AddOverrideBuild("werewilba_transform")

    inst.were = false

    inst.components.dynamicmusic:Enable()
    inst.SoundEmitter:KillSound("werepigmusic")
    GetWorld().components.colourcubemanager:SetOverrideColourCube(nil)    
    inst:DoTaskInTime(0, function() SetHUDState(inst) end)      
    inst.components.temperature:SetTemp(nil)
    
    if inst.grunt_task then
        inst.grunt_task:Cancel()
        inst.grunt_task = nil
    end

    if inst.breath_task then
        inst.breath_task:Cancel()
        inst.breath_task = nil
    end    
    if inst.breath_task2 then
        inst.breath_task2:Cancel()
        inst.breath_task2 = nil
    end    

    inst.Light:Enable(false)
    inst.soundsname = "wilba"
end

local function SetWere(inst, active)
    if active then
        if not inst.were then
            inst.ready_to_transform = true
            inst:PushEvent("ready_to_transform")

            if not inst.components.inventory:IsItemNameEquipped("silvernecklace") then
                inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_TRANSFORM"))
                inst:PushEvent("transform_to_werewilba")
            else
                NecklaceComment(inst)
            end
        end
    else
        inst.ready_to_transform = false
	    inst:PushEvent("end_ready_to_transform")
        if inst.were then
            inst.components.talker:Say("")
            inst:PushEvent("transform_to_wilba")                   
        end
    
    end
end

local function CheckWere(inst)
    inst:DoTaskInTime(0, function()
        SetWere(inst, CanGoWere(inst))
    end)
end

local function cooldown_monster_count(inst)    
    inst.monster_count = inst.monster_count - 1
    if inst.monster_count <= 0 then
        inst.monster_count = 0
        
        if inst.ready_to_transform then
            inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_NECKLACE_INACTIVE"))
        end

        inst.ready_to_transform = false
        inst.from_food = false
        CheckWere(inst)
    else
        inst.cooldown_schedule = (inst.monster_cooldown - inst.cooldown_schedule) % MONSTER_COOLDOWN
        if inst.cooldown_schedule == 0 then
            inst.cooldown_schedule = MONSTER_COOLDOWN
        end

        inst.transform_task, inst.trans_task_info = inst:ResumeTask(inst.cooldown_schedule, cooldown_monster_count)
    end
end

local function OnSave(inst, data)
    data.were = inst.were
    data.were_health = inst.components.health:GetPercent()
    data.monster_count = inst.monster_count
    data.monster_cooldown = inst.monster_cooldown
    data.cooldown_schedule = inst.cooldown_schedule
    data.from_food = inst.from_food
    data.ready_to_transform = inst.ready_to_transform

    if inst.trans_task_info then
        data.timeleft = inst:TimeRemainingInTask(inst.trans_task_info)
    end
end

local function OnLoad(inst, data)
    if data.were then
        inst.TransformToWere(inst)
        inst.TransformToWere_pst(inst)
        
        if data.were_health then
            inst.components.health:SetPercent(data.were_health)
        end
    end

    if data.monster_count then
        inst.monster_count = data.monster_count
    end

    if data.monster_cooldown then
        inst.monster_cooldown = data.monster_cooldown
    end

    if data.cooldown_schedule then
        inst.cooldown_schedule = data.cooldown_schedule
    end

    if data.from_food then
        inst.from_food = data.from_food
    end

    if data.ready_to_transform then
        inst.ready_to_transform = data.ready_to_transform
    end

    if data.timeleft then
        inst.transform_task, inst.trans_task_info = inst:ResumeTask(data.timeleft, cooldown_monster_count)
    end
end

local fn = function(inst)
    inst.components.sanity:SetMax(TUNING.WILBA_SANITY)
    inst.components.hunger:SetMax(TUNING.WILBA_HUNGER)
    inst.components.health:SetMaxHealth(TUNING.WILBA_HEALTH)

    inst.components.eater.monsterimmune = true
    
    inst.ready_to_transform = false
    inst.from_food = false
    inst.were = false
    inst.monster_count = 0
    inst.monster_cooldown = 0
    inst.cooldown_schedule = 0

    inst.components.sanity:SetNightDrainMultiplier(1.5)
    inst.soundsname = "wilba"
    inst.talker_path_override = "dontstarve_DLC003/characters/"
    inst:AddTag("pigroyalty")

    
    inst:ListenForEvent("daycomplete", function() 
        if inst.ready_to_transform and not inst.from_food then
            inst.ready_to_transform = false
        end
        CheckWere(inst)

    end, GetWorld())

    inst:ListenForEvent("daytime",          function() print("DAYTIME") CheckWere(inst) end, GetWorld())
    inst:ListenForEvent("nighttime",        function() CheckWere(inst) end, GetWorld())
    inst:ListenForEvent("beginaporkalypse", function() CheckWere(inst) end, GetWorld())
    inst:ListenForEvent("endaporkalypse",   function() CheckWere(inst) end, GetWorld())

    inst.AnimState:AddOverrideBuild("werewilba_transform")

    inst:ListenForEvent("oneat", function(_, data) 
        if data.food:HasTag("monstermeat") then
            inst.monster_count = inst.monster_count + 1
            inst.monster_cooldown = inst.monster_cooldown + MONSTER_COOLDOWN

            if inst.transform_task then
                inst.transform_task:Cancel()
                inst.transform_task = nil
            end

            inst.cooldown_schedule = inst.monster_cooldown % MONSTER_COOLDOWN
            if inst.cooldown_schedule == 0 then
                inst.cooldown_schedule = MONSTER_COOLDOWN
            end

            inst.transform_task, inst.trans_task_info = inst:ResumeTask(inst.cooldown_schedule, cooldown_monster_count)

            if inst.monster_count >= MONSTERMEAT_COUNT then
                inst.from_food = true
            end

            CheckWere(inst)
        end
    end)

    inst:ListenForEvent("itemget", function(_, data) 
        if inst.were and data.item.components.equippable and not data.item:HasTag("werepigfur") then
            --inst.components.inventory:DropItem(data.item)
            inst.components.talker:Say("")
        end
    end)

    inst:ListenForEvent("cantequip", function(_, data)
        if inst.were and not data.item:HasTag("werepigfur") then
            inst:DoTaskInTime(0, function()
                inst.components.inventory:DropItem(data.item)
                inst.components.talker:Say("") 
            end)
        end
    end)

    inst:ListenForEvent("unequip", function (_, data) 
        if inst.were then
            -- if an item is unequipped when werewilba, unless something is in place now, fill the space with fur.
            if data.item and data.item.components.equippable and not data.item:HasTag("werepigfur") then
                local inventory = inst.components.inventory                       
                local fur = nil
                if data.item.components.equippable.equipslot == EQUIPSLOTS.HANDS then                
                    fur = SpawnPrefab("werewilbafur_hands")
                elseif data.item.components.equippable.equipslot == EQUIPSLOTS.HEAD then                    
                    fur = SpawnPrefab("werewilbafur_head")
                elseif data.item.components.equippable.equipslot == EQUIPSLOTS.BODY then
                    fur = SpawnPrefab("werewilbafur_body")
                end
                if fur then
                    inst:DoTaskInTime(0,function() inventory:Equip(fur) end) 
                end
            end
        end         
        if data.item.prefab == "silvernecklace" and inst.ready_to_transform and not inst.were then
            inst.SetWere(inst, true)
        end        
        if data.item:HasTag("werepigfur") then
            data.item:Remove()
        end            
    end)

    inst:ListenForEvent("itemlose", function (_, data) 
        if data.item:HasTag("werepigfur") then
            data.item:Remove()
        end        
    end)    

    inst:ListenForEvent("resurrect", function()
        inst.ready_to_transform = false
        inst.from_food = false
        inst.were = false
        inst.monster_count = 0
        inst.monster_cooldown = 0
        inst.cooldown_schedule = 0

        if inst.transform_task then
            inst.transform_task:Cancel()
            inst.transform_task = nil
            inst.trans_task_info = nil
        end

        inst.TransformToWilba(inst)
    end)
    inst:ListenForEvent("death", function()
        if inst.breath_task then
            inst.breath_task:Cancel()
            inst.breath_task = nil
        end
        if inst.breath_task2 then
            inst.breath_task2:Cancel()
            inst.breath_task2 = nil
        end        
    end)

    inst.entity:AddLight()
    inst.Light:Enable(false)
    inst.Light:SetRadius(5)
    inst.Light:SetFalloff(.5)
    inst.Light:SetIntensity(.6)
    inst.Light:SetColour(245/255,40/255,0/255)
    inst:DoTaskInTime(0,function()
        if inst:HasTag("lightsource") then       
            inst:RemoveTag("lightsource")    
        end
    end)

    inst.components.talker.allcaps = true

    inst.SetWere = SetWere
    inst.TransformToWere = TransformToWere
    inst.TransformToWere_pst = TransformToWere_pst
    inst.TransformToWilba = TransformToWilba

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
end

return MakePlayerCharacter("wilba", prefabs, assets, fn, start_inv)