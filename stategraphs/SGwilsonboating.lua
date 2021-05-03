local function DoFoleySounds(inst)

    for k,v in pairs(inst.components.inventory.equipslots) do
        if v.components.inventoryitem and v.components.inventoryitem.foleysound then
            inst.SoundEmitter:PlaySound(v.components.inventoryitem.foleysound)
        end
    end

    if inst.prefab == "wx78" then
        inst.SoundEmitter:PlaySound("dontstarve/movement/foley/wx78")
    end
end


local actionhandlers = 
{
    
    --ActionHandler(ACTIONS.CHOP, "work"),
    --ActionHandler(ACTIONS.MINE, "work"),
    --ActionHandler(ACTIONS.DIG, "work"),
    ActionHandler(ACTIONS.HAMMER,
        function(inst)
            if not inst.sg:HasStateTag("prehammer") then
                if inst.sg:HasStateTag("hammering") then
                    return "hammer"
                else
                    return "hammer_start"
                end
            end
        end),

     ActionHandler(ACTIONS.CHOP, 
        function(inst) 
            if not inst.sg:HasStateTag("prechop") then 
                if inst.sg:HasStateTag("chopping") then
                    return "chop"
                else
                    return "chop_start"
                end
            end 
        end),

     ActionHandler(ACTIONS.HACK, 
        function(inst) 
            if not inst.sg:HasStateTag("prehack") then 
                if inst.sg:HasStateTag("hacking") then
                    return "hack"
                else
                    return "hack_start"
                end
            end 
        end),
     
    ActionHandler(ACTIONS.MOUNT, "mount"),
	ActionHandler(ACTIONS.SEARCH, "mount"),
    ActionHandler(ACTIONS.DISMOUNT, "dismount"),
    
    ActionHandler(ACTIONS.PICKUP,
        function(inst, action)
            if action.target.components.inventoryitem then
                if action.target.components.inventoryitem.longpickup then
                    return "dolongaction"
                end
            end
            return "doshortaction"
        end),
    ActionHandler(ACTIONS.MANUALEXTINGUISH, "dolongaction"),
    ActionHandler(ACTIONS.DROP, "doshortaction"),
    ActionHandler(ACTIONS.BUILD, "dolongaction"),
    ActionHandler(ACTIONS.DEPLOY, "doshortaction"),
    ActionHandler(ACTIONS.RUMMAGE, "doshortaction"),
    ActionHandler(ACTIONS.TEACH, "dolongaction"),
    ActionHandler(ACTIONS.COMBINESTACK, "doshortaction"),
    ActionHandler(ACTIONS.BLINK, "quicktele"),
    ActionHandler(ACTIONS.GIVE, "give"),
	ActionHandler(ACTIONS.PLANT, "doshortaction"),
	ActionHandler(ACTIONS.PLANTONGROWABLE, "doshortaction"),
	ActionHandler(ACTIONS.HARVEST, "dolongaction"),
    ActionHandler(ACTIONS.TURNOFF, "give"),
    ActionHandler(ACTIONS.TURNON, "give"),
    ActionHandler(ACTIONS.FERTILIZE, "doshortaction"),
    ActionHandler(ACTIONS.TRAVEL, "doshortaction"),
    ActionHandler(ACTIONS.LIGHT, "give"),
    ActionHandler(ACTIONS.ADDFUEL, "doshortaction"),
    ActionHandler(ACTIONS.ADDWETFUEL, "doshortaction"),
    ActionHandler(ACTIONS.LAUNCH, "dolongaction"),
    ActionHandler(ACTIONS.RETRIEVE, "dolongaction"),
    ActionHandler(ACTIONS.REPAIR, "dolongaction"),
    ActionHandler(ACTIONS.REPAIRBOAT, "dolongaction"),
    ActionHandler(ACTIONS.READ, "book"),
    ActionHandler(ACTIONS.READMAP, "map"),
    ActionHandler(ACTIONS.MAKEBALLOON, "makeballoon"),
    ActionHandler(ACTIONS.MURDER, "dolongaction"),
    ActionHandler(ACTIONS.TAKEITEM, "dolongaction" ),
    ActionHandler(ACTIONS.SHAVE, "shave"),
    ActionHandler(ACTIONS.COOK, "dolongaction"),
    ActionHandler(ACTIONS.CHECKTRAP, "doshortaction"),
    ActionHandler(ACTIONS.BAIT, "doshortaction"),
    ActionHandler(ACTIONS.HEAL, "dolongaction"),
    ActionHandler(ACTIONS.CUREPOISON, "curepoison"),
    ActionHandler(ACTIONS.SEW, "dolongaction"),
    ActionHandler(ACTIONS.FAN, "use_fan"),
    ActionHandler(ACTIONS.TOGGLEOFF, "give"),
    ActionHandler(ACTIONS.TOGGLEON, "give"),
    ActionHandler(ACTIONS.STORE, "doshortaction"),

    ActionHandler(ACTIONS.FISH,
        function(inst, action)
            if action.target.components.workable then
                return "fishing_retrieve"
            else
                return "fishing_pre"
            end
        end),

    ActionHandler(ACTIONS.EAT, 
       function(inst, action)
            if inst.sg:HasStateTag("busy") then
                return nil
            end
            local obj = action.target or action.invobject
            if not (obj and obj.components.edible) then
                return nil
            end

            if inst.components.eater:CanEat(obj) and obj.components.edible.foodtype == "MEAT" and not obj.components.edible.forcequickeat then
                return "eat"
            elseif inst.components.eater:CanEat(obj) then
                return "quickeat"
            else
                inst:PushEvent("canteatfood", {food = obj})
                return nil
            end
        end),


    ActionHandler(ACTIONS.GAS,
        function(inst)
            return "crop_dust"
        end),     


    ActionHandler(ACTIONS.NET, 
        function(inst)
            if not inst.sg:HasStateTag("prenet") then 
                if inst.sg:HasStateTag("netting") then
                    return "bugnet"
                else
                    return "bugnet_start"
                end
            end
        end),      

    ActionHandler(ACTIONS.ACTIVATE, 
        function(inst, action)
            if action.target.components.activatable then
                if action.target.components.activatable.quickaction then
                    return "doshortaction"
                else
                    return "dolongaction"
                end
            end
        end),  

     ActionHandler(ACTIONS.PICK, 
        function(inst, action)
            if action.target.components.pickable then
                if action.target.components.pickable.quickpick then
                    return "doshortaction"
                else
                    return "dolongaction"
                end
            end
        end),

    ActionHandler(ACTIONS.CASTSPELL, 
        function(inst, action) 
            return action.invobject.components.spellcaster.castingstate or "castspell"
        end),

    ActionHandler(ACTIONS.PEER, "peertelescope"),

    ActionHandler(ACTIONS.PLAY, 
        function(inst, action)
            if action.invobject then
                if action.invobject:HasTag("flute") then
                    return "play_flute"
                elseif action.invobject:HasTag("horn") then
                    return "play_horn"
                elseif action.invobject:HasTag("bell") then
                    return "play_bell"
                end
            end
        end),
     ActionHandler(ACTIONS.MINE, 
        function(inst) 
            if not inst.sg:HasStateTag("premine") then 
                if inst.sg:HasStateTag("mining") then
                    return "mine"
                else
                    return "mine_start"
                end
            end 
        end),


    ActionHandler(ACTIONS.JUMPIN, "jumpin"),
    ActionHandler(ACTIONS.STICK, "doshortaction"),
    ActionHandler(ACTIONS.THROW, "throw"),
    ActionHandler(ACTIONS.LAUNCH_THROWABLE, "cannon"),
    ActionHandler(ACTIONS.FEED, "dolongaction"),
}

local function OnAttackFn(inst, data)
    local vehicle = inst.components.driver.vehicle
    if not inst.components.health:IsDead() and not (vehicle and vehicle.components.boathealth and vehicle.components.boathealth:IsDead()) then
        
        if not vehicle.components.drivable or not vehicle.components.drivable:CanDoHit() then 
			return 
		end

        if data.attacker and (data.attacker:HasTag("insect") or data.attacker:HasTag("twister"))then
            local is_idle = inst.sg:HasStateTag("idle")
            if not is_idle then
                return
            end
        end

        vehicle.components.drivable:GetHit()
        
        if data.stimuli and data.stimuli == "electric" and not inst.components.inventory:IsInsulated() then
            inst.sg:GoToState("electrocute")
        elseif data.damage > 0 then
            inst.sg:GoToState("hit")
        end

    end
end

local function DoAttackFn(inst, data)
    if not inst.components.health:IsDead() and not inst.sg:HasStateTag("attack") then
        local weapon = inst.components.combat and inst.components.combat:GetWeapon()
        if weapon and weapon:HasTag("blowdart") then
            inst.sg:GoToState("blowdart")
        elseif weapon and weapon:HasTag("thrown") then
            inst.sg:GoToState("throw")
        elseif weapon and (weapon:HasTag("speargun") or weapon:HasTag("blunderbuss") )  then 
            inst.sg:GoToState("speargun")      
        else
            inst.sg:GoToState("attack")
        end
    end
end

local events=
{
    --[[
    CommonHandlers.OnLocomote(true,false),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    EventHandler("transform_person", function(inst) inst.sg:GoToState("towoodie") end),
    EventHandler("freeze", 
        function(inst)
            if inst.components.health and inst.components.health:GetPercent() > 0 then
                inst.sg:GoToState("frozen")
            end
        end),
        ]]--

    -- Disable this until we have talking animations from all directions.
    --Dave: Enabled it because the character was still turning towards the camera but wasn't talking or making sound 
    EventHandler("ontalk", function(inst, data)
        if inst.sg:HasStateTag("idle") then
            if inst.prefab == "wes" then
                inst.sg:GoToState("mime")
            else
                inst.sg:GoToState("talk", data.noanim)
            end
        end
    end),

    EventHandler("wrap", function(inst, data)
        inst.sg:GoToState("wrap")
        inst.sg.statemem.container = data.container_obj
    end),

    EventHandler("wrapdone", function(inst, data)
        inst.sg:GoToState("idle")
    end),

     EventHandler("powerup",
        function(inst)
            if GetTick() > 0 then
                inst.sg:GoToState("powerup")
            end
    end),        
    
    EventHandler("powerdown",
        function(inst)
            inst.sg:GoToState("powerdown")
    end),        
    
    EventHandler("equip", function(inst, data)
        if inst.sg:HasStateTag("idle") then
            if data.eslot == EQUIPSLOTS.HANDS then
                inst.sg:GoToState("item_out")
            else
                inst.sg:GoToState("item_hat")
            end
        end
    end),

    EventHandler("unequip", function(inst, data)

        if inst.sg:HasStateTag("idle") then

            if data.eslot == EQUIPSLOTS.HANDS then
                if data.slip then
                    inst.sg:GoToState("tool_slip")
                else
                    inst.sg:GoToState("item_in")
                end
            else
                inst.sg:GoToState("item_hat")
            end
        end
    end),

  EventHandler("coast",
        function(inst)
            inst.sg:GoToState("idle")
    end),

   EventHandler("transform_werebeaver", function(inst, data)
        if inst.components.beaverness then
            TheCamera:SetDistance(14)
            inst.sg:GoToState("werebeaver")

        end
    end),


   EventHandler("locomote", function(inst)

        local is_attacking = inst.sg:HasStateTag("attack")
        local is_busy = inst.sg:HasStateTag("busy")
     
        local is_moving = inst.sg:HasStateTag("moving")
        local is_running = inst.sg:HasStateTag("running")
        local should_move = inst.components.locomotor:WantsToMoveForward()
		if inst.components.driver and inst.components.driver.vehicle and not inst.components.driver.vehicle.components.drivable then
			should_move = false
		end

        local should_run = inst.components.locomotor:WantsToRun()
        local hasSail = inst.components.driver:GetIsSailing()
        if not should_move then
            if inst.components.driver and inst.components.driver.vehicle then
                inst.components.driver.vehicle:PushEvent("boatstopmoving")
            end
        end 
        if should_move  then 
            if inst.components.driver and inst.components.driver.vehicle then
                inst.components.driver.vehicle:PushEvent("boatstartmoving")
            end
        end 
        if is_attacking or is_busy then return end
        if is_moving and not should_move then
            if hasSail then
                inst.sg:GoToState("sail_stop")
            else
                inst.sg:GoToState("row_stop")
            end
        elseif (not is_moving and should_move) or (is_moving and should_move and is_running ~= should_run) then
            if hasSail then
                inst.sg:GoToState("sail_start")
            else
                inst.sg:GoToState("row_start")
            end
        end 
    end),

    EventHandler("doattack", DoAttackFn),

    EventHandler("attacked", function(inst, data)
        OnAttackFn(inst, data)
    end),

    EventHandler("boatattacked", function(inst, data)
        OnAttackFn(inst, data)
    end),

    EventHandler("sneeze", function(inst, data)
        if not inst.components.health:IsDead() and not inst.components.health.invincible then
            if inst.sg:HasStateTag("busy") then
                inst.wantstosneeze = true
            else
                inst.sg:GoToState("sneeze")
            end
        end
    end),    

    EventHandler("death", function(inst, data)
        inst.components.playercontroller:Enable(false)

        if data.cause == "drowning" then
            inst.sg:GoToState("death_boat")
            local sound_name = inst.soundsname or inst.prefab
            local path = inst.talker_path_override or "dontstarve_DLC002/characters/"
            inst.SoundEmitter:PlaySound(path..sound_name.."/sinking_death")
        else
            inst.sg:GoToState("death")
            local sound_name = inst.soundsname or inst.prefab
            local path = inst.talker_path_override or "dontstarve/characters/"
            if inst.prefab ~= "wes" then
                inst.SoundEmitter:PlaySound(path..sound_name.."/death_voice")
            end
        end

        inst.SoundEmitter:PlaySound("dontstarve/wilson/death")
    end),

    EventHandler("readytocatch",
        function(inst)
            inst.sg:GoToState("catch_pre")
    end),

     EventHandler("fishingcancel",
        function(inst)
            if inst.sg:HasStateTag("fishing") then
                inst.sg:GoToState("fishing_pst")
            end
        end),


      EventHandler("hitbywave",
        function(inst, data)
           -- local currentSpeed = inst.Physics:GetMotorSpeed()
            --inst.Physics:SetMotorVel(currentSpeed/3.0, 0, 0)
        end), 

       EventHandler("boostbywave",
        function(inst, data)
            if inst.sg:HasStateTag("running") then 
                
                local boost = TUNING.WAVEBOOST
                if inst.components.driver and inst.components.driver.vehicle then

                    if inst.components.driver.vehicle.waveboost then
                        boost = data.boost or inst.components.driver.vehicle.waveboost
                    end
                    -- sanity boost, walani's surfboard mainly
                    if inst.components.driver.vehicle.wavesanityboost and inst.components.sanity then
                        inst.components.sanity:DoDelta(inst.components.driver.vehicle.wavesanityboost)
                    end
                end

                local currentSpeed = inst.Physics:GetMotorSpeed()

                inst.Physics:SetMotorVel(currentSpeed + boost , 0, 0)
                --local x,y,z = inst.Transform:GetWorldPosition()
                --print("position is ", y)

                --inst.Transform:SetPosition(x, 1, z)


                --x,y,z = inst.Physics:GetVelocity() 
                --y = 3
                --inst.Physics:SetVel(x, y, z)
            end 

        end),

       EventHandler("sailequipped", 
            function(inst)
                if inst.sg:HasStateTag("rowing") then 
                    inst.sg:GoToState("sail")
                    local equipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                    if equipped then 
                        equipped:PushEvent("stoprowing", {owner = inst})
                    end
                end 

            end 
        ), 

       EventHandler("sailunequipped", 
            function(inst)
                if inst.sg:HasStateTag("sailing") then 
                    inst.sg:GoToState("row")
                    local equipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                    if equipped then 
                        equipped:PushEvent("startrowing", {owner = inst})
                    end
                end 
            end 
        ),

        EventHandler("landboat", function(inst)
            inst.sg:GoToState("jumpboatland")
        end),

        EventHandler("toolbroke", function(inst, data)
            if inst.sg:HasStateTag("playing") then
                inst.toolwantstobreak = true
            else
                inst.sg:GoToState("toolbroke", data.tool)
            end
        end),   
}


local states=
{

    State{
    --[[
        How does this work? Here is how.
        -> Enter state, call OnDismount
        -> StateGraph changes to SGWilson in that function
        -> OnDismount tells SGWilson to enter a new state (jumponboatstart) which handles the jump
        -> At the end of that state BufferedAction is called, which mounts the new boat & changes SG back to this one.
    --]]
        name = "mount",
        tags = {"canrotate", "boating", "busy"},
        onenter = function(inst)
            inst.components.driver:OnDismount(false, nil, true)
        end,
    },

     State{

        name = "dismount",
        tags = {"canrotate", "boating", "busy"},
        onenter = function(inst)
            --inst.components.playercontroller:Enable(false)
            inst:PerformBufferedAction()
            --inst.components.playercontroller:Enable(true)
        end, 

        onexit = function(inst)
        end, 
    },


    State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
            --inst.components.driver:SplitFromVehicle()
            --inst.components.driver:CombineWithVehicle()
            inst.components.locomotor:Stop()
            inst.last_death_position = inst:GetPosition()
			SpawnPlayerSkeletonHidden(inst:GetPosition())
            inst.AnimState:Hide("swap_arm_carry")
            inst.AnimState:PlayAnimation("death")
        end,
    },

    State{
        name = "death_boat",
        tags = {"busy"},

        onenter = function(inst)
            --inst.components.driver:SplitFromVehicle()
            --inst.components.driver:CombineWithVehicle()
            inst.components.locomotor:Stop()
            inst.last_death_position = inst:GetPosition()
			SpawnPlayerSkeletonHidden(inst:GetPosition())
            inst.AnimState:Hide("swap_arm_carry")
            inst.AnimState:PlayAnimation("boat_death")
        end,

        onexit= function(inst) inst.DynamicShadow:Enable(true) end,

        timeline=
        {
            TimeEvent(70*FRAMES, function(inst)
                inst.DynamicShadow:Enable(false)
            end),
        },
    },

    State{
        name = "idle",
        tags = {"idle", "canrotate", "boating"},
        onenter = function(inst, pushanim)            

            inst.components.locomotor:Stop()

            if inst.wantstosneeze then
                inst.sg:GoToState("sneeze")
            elseif inst.toolwantstobreak then
                inst.sg:GoToState("toolbroke")
            else

                local equippedArmor = inst.components.inventory and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)

                if equippedArmor and equippedArmor:HasTag("band") then
                    inst.sg:GoToState("enter_onemanband")
                    return
                end

                local anims = {}
                
                local anim = "idle_loop"
                
                if not inst.components.sanity:IsSane() then
                    table.insert(anims, "idle_sanity_pre")
                    table.insert(anims, "idle_sanity_loop")
                elseif inst.components.temperature:IsFreezing() then
                    table.insert(anims, "idle_shiver_pre")
                    table.insert(anims, "idle_shiver_loop")
                elseif inst.components.temperature:IsOverheating() then
                    table.insert(anims, "idle_hot_pre")
                    table.insert(anims, "idle_hot_loop")

                else
                    table.insert(anims, "idle_loop")
                end
                
                if pushanim then
                    for k,v in pairs (anims) do
                        inst.AnimState:PushAnimation(v, k == #anims)
                    end
                else
                    inst.AnimState:PlayAnimation(anims[1], #anims == 1)
                    for k,v in pairs (anims) do
                        if k > 1 then
                            inst.AnimState:PushAnimation(v, k == #anims)
                        end
                    end
                end
                
                inst.sg:SetTimeout(math.random()*4+2)
            end
        end,
        
        ontimeout= function(inst)
            if inst.components.temperature:GetCurrent() > 70 then
                return 
            end
            inst.sg:GoToState("funnyidle")
        end,
    },

    State{
        
        name = "funnyidle",
        tags = {"idle", "canrotate", "boating"},
        onenter = function(inst)
        
            if inst.components.poisonable:IsPoisoned() then
                inst.AnimState:PlayAnimation("idle_poison_pre")
                inst.AnimState:PushAnimation("idle_poison_loop")
                inst.AnimState:PushAnimation("idle_poison_pst", false)
            elseif inst.components.temperature:GetCurrent() < 10 then
                inst.AnimState:PlayAnimation("idle_shiver_pre")
                inst.AnimState:PushAnimation("idle_shiver_loop")
                inst.AnimState:PushAnimation("idle_shiver_pst", false)
            elseif inst.components.temperature:GetCurrent() > 60 then
                --plug in overheats once they're done
                inst.AnimState:PlayAnimation("idle_hot_pre")
                inst.AnimState:PushAnimation("idle_hot_loop")
                inst.AnimState:PushAnimation("idle_hot_pst", false)
            elseif inst.components.hunger:GetPercent() < TUNING.HUNGRY_THRESH then
                inst.AnimState:PlayAnimation("hungry")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/hungry")    
            elseif inst.components.sanity:GetPercent() < .5 then
                inst.AnimState:PlayAnimation("idle_inaction_sanity")
            else
                inst.AnimState:PlayAnimation("idle_inaction")
            end
        end,

        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end ),
        },
        
    },

    State{
        name = "row_start",
        tags = {"moving", "running", "canrotate", "rowing"},
        
        onenter = function(inst)
            --inst.components.driver:CombineWithVehicle()
            inst.components.locomotor:RunForward()
			if inst.components.driver.vehicle.components.drivable then
	            local anim = inst.components.driver.vehicle.components.drivable.prerunanimation
		        inst.AnimState:PlayAnimation(anim)
			end
            DoFoleySounds(inst)

            
            -- unequip whatever the player is holding and store it somewhere 
            local equipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if equipped then 
                equipped:PushEvent("startrowing", {owner = inst})
            end
            

            inst:PushEvent("startrowing")

           -- print("currently equipped ", equipped.prefab)
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("row") end ),
            EventHandler("trawlover", function(inst) inst.AnimState:PlayAnimation("trawlover") end),
        },                          
        
    },

    State{
        name = "row",
        tags = {"canrotate", "moving", "running", "boating", "rowing"},
        onenter = function(inst)
            -- inst.components.driver:CombineWithVehicle()
            inst.SoundEmitter:PlaySound(inst.components.driver.vehicle.components.drivable.creaksound)           
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/boat_paddle")
            -- print("CATEGORY VOLUME "..TheSim:GetSoundVolume("boat_paddle"))
            DoFoleySounds(inst)
            local anim = inst.components.driver.vehicle.components.drivable.runanimation
            inst.AnimState:PlayAnimation(anim, false)
            if inst.components.driver.vehicle.components.rowboatwakespawner then 
                inst.components.driver.vehicle.components.rowboatwakespawner:StartSpawning()
            end 
        end,

        onexit = function(inst, nextState)
           if inst.components.driver.vehicle.components.rowboatwakespawner then 
                inst.components.driver.vehicle.components.rowboatwakespawner:StopSpawning()
            end 
            if nextState ~= "row" and nextState ~= "sail" then 
                inst.components.locomotor:Stop(true)
                if nextState == "dismount" or nextState == "doshortaction" then --Make sure equipped items are pulled back out (only really for items with flames right now)
                    local equipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                    if equipped then
                        equipped:PushEvent("stoprowing", {owner = inst})
                    end
                end 
            end 
        end,

        timeline=
        {
            TimeEvent(8*FRAMES, function(inst)
                if inst.components.driver.vehicle.components.container then
                    local trawlnet = inst.components.driver.vehicle.components.container:GetItemInBoatSlot(BOATEQUIPSLOTS.BOAT_SAIL)
                    if trawlnet and trawlnet.rowsound then
                        inst.SoundEmitter:PlaySound(trawlnet.rowsound)
                    end
                end
            end),
        },     

         events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("row") end ),
            EventHandler("trawlitem", function(inst) inst.AnimState:PlayAnimation("trawlover") end),
        },
             
    },  

     State{

        name = "row_stop",
        tags = {"canrotate", "idle"},

        onenter = function(inst) 
            --inst.components.driver:CombineWithVehicle()
            inst.components.locomotor:Stop()
            local anim = inst.components.driver.vehicle.components.drivable.postrunanimation
            inst.AnimState:PlayAnimation(anim)
            --If the player had something in their hand before starting to row, put it back.
            if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                inst.AnimState:PushAnimation("item_out", false)
            end
            

        end,

        onexit = function(inst)
            if inst.components.driver and inst.components.driver.vehicle and inst.components.driver.vehicle.components.boathealth then

            end
        end,

        events=
        {
            EventHandler("animqueueover", function(inst)
                local equipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if equipped then
                    equipped:PushEvent("stoprowing", {owner = inst})
                end
                inst:PushEvent("stoprowing")
                inst.sg:GoToState("idle")
            end),
            EventHandler("trawlover", function(inst) inst.AnimState:PlayAnimation("trawlover") end),
        },
    },

    State{
        name = "sail_start",
        tags = {"moving", "running", "canrotate", "sailing"},
        
        onenter = function(inst)
            --inst.components.driver:CombineWithVehicle()

            
            inst.components.locomotor:RunForward()
            local anim = inst.components.driver.vehicle.components.drivable.sailstartanim or "sail_pre"
            inst.AnimState:PlayAnimation(anim)

            local equipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if equipped then 
                equipped:PushEvent("startsailing", {owner = inst})
            end
      
           -- print("currently equipped ", equipped.prefab)
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("sail") end ),
            EventHandler("trawlover", function(inst) inst.AnimState:PlayAnimation("trawlover") end),
        },
               
        
    },

    State{
        name = "sail",
        tags = {"canrotate", "moving", "running", "boating", "sailing"},
        onenter = function(inst)
            --inst.components.driver:CombineWithVehicle()

            local loopsound = nil 
            local flapsound = nil 

            local boat = inst.components.driver.vehicle
            if boat then 
                if boat.components.container and boat.components.container.hasboatequipslots then 
                    local sail = boat.components.container:GetItemInBoatSlot(BOATEQUIPSLOTS.BOAT_SAIL)
                    if sail then 
                        loopsound = sail.loopsound
                        flapsound = sail.flapsound
                    end 
                elseif boat.sailsound then
                    loopsound = boat.sailsound
                end 
            end
           
            if not inst.SoundEmitter:PlayingSound("sail_loop") and loopsound then 
                  inst.SoundEmitter:PlaySound( "dontstarve_DLC002/" .. loopsound, "sail_loop")
              end 
            if flapsound then 
                inst.SoundEmitter:PlaySound( "dontstarve_DLC002/" .. flapsound) 
            end 
            inst.SoundEmitter:PlaySound(inst.components.driver.vehicle.components.drivable.creaksound)
            
			if inst.components.driver.vehicle.components.drivable then
	            local anim = inst.components.driver.vehicle.components.drivable.sailloopanim or "sail_loop"
		        inst.AnimState:PlayAnimation(anim, false)
            end
			if inst.components.driver.vehicle.components.rowboatwakespawner then 
                inst.components.driver.vehicle.components.rowboatwakespawner:StartSpawning()
            end 

        end,
        
        onexit = function(inst, nextState)

           if inst.components.driver.vehicle.components.rowboatwakespawner then 
                inst.components.driver.vehicle.components.rowboatwakespawner:StopSpawning()
            end 
            
            local loopsound
            local boat = inst.components.driver.vehicle
            if boat then 
                if boat.components.container and boat.components.container.hasboatequipslots then 
                    local sail = boat.components.container:GetItemInBoatSlot(BOATEQUIPSLOTS.BOAT_SAIL)
                    if sail then 
                        loopsound = sail.loopsound
                    end 
                end 
            end

            if nextState ~= "sail" then 
                inst.SoundEmitter:KillSound( "sail_loop")
                if nextState ~= "row" then 
                    inst.components.locomotor:Stop(true)
                end 
            end

            
           -- inst.components.playercontroller:Enable(true)
        end,

        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("sail") end ),
            EventHandler("trawlover", function(inst) inst.AnimState:PlayAnimation("trawlover") end),
        },
             
    },  

     State{
    
        name = "sail_stop",
        tags = {"canrotate", "idle"},
        
        onenter = function(inst) 
            --inst.components.driver:CombineWithVehicle()
            inst.components.locomotor:Stop()
            local anim = (inst.components.driver.vehicle.components.drivable and inst.components.driver.vehicle.components.drivable.sailstopanim) or "sail_pst"
            inst.AnimState:PlayAnimation(anim)
           
            --If the player had something in their hand before starting to row, put it back. 
            
        end,

        onexit = function(inst, nextState)
            
            if inst.components.driver and inst.components.driver.vehicle and inst.components.driver.vehicle.components.boathealth then
                
            end
        end,
        
        events=
        {   
            EventHandler("animover", function(inst) 
                local equipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if equipped then 
                    equipped:PushEvent("stopsailing", {owner = inst})
                end
                inst.sg:GoToState("idle") 
            end ),
            EventHandler("trawlover", function(inst) inst.AnimState:PlayAnimation("trawlover") end),
        },
    },


    State{
        name = "brake",
        tags = {"canrotate", "boating"},
        onenter = function(inst)
            --inst.components.playercontroller:Enable(false)
           -- inst.Physics:Stop()            
            --inst.AnimState:PlayAnimation("transform_pst")
        end,
        
        onexit = function(inst)
            
           -- inst.components.playercontroller:Enable(true)
        end,
        
        events=
        {
           -- EventHandler("animover", function(inst) TheCamera:SetDistance(30) inst.sg:GoToState("idle") end ),
        },        
    },     

    State{
        name = "doshortaction",
        tags = {"doing", "busy", "boating"},
        
        onenter = function(inst)
            inst.components.locomotor:Stop()
            --inst.components.driver:SplitFromVehicle()
            inst.AnimState:PlayAnimation("pickup")
            inst.sg:SetTimeout(6*FRAMES)
        end,
        
        timeline=
        {
            TimeEvent(4*FRAMES, function( inst )
                inst.sg:RemoveStateTag("busy")
            end),
            TimeEvent(10*FRAMES, function( inst )
            inst.sg:RemoveStateTag("doing")
            inst.sg:AddStateTag("idle")
            end),
        },
        
        ontimeout = function(inst)
            inst:PerformBufferedAction()
            
        end,
        
        events=
        {
            EventHandler("animover", function(inst) if inst.AnimState:AnimDone() then inst.sg:GoToState("idle") end end ),
        },
    },

     State{
        name = "dolongaction",
        tags = {"doing", "busy", "boating"},
        
        timeline=
        {
            TimeEvent(4*FRAMES, function( inst )
                inst.sg:RemoveStateTag("busy")
            end),
        },
        
        onenter = function(inst, timeout)
            --inst.components.driver:SplitFromVehicle()
            local targ = inst:GetBufferedAction() and inst:GetBufferedAction().target or nil
            if targ then targ:PushEvent("startlongaction") end
            
            inst.sg:SetTimeout(timeout or 1)
            inst.components.locomotor:Stop()
            inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")
            
            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("build_loop", true)
        end,
        
        ontimeout= function(inst)
            inst.AnimState:PlayAnimation("build_pst")
            inst.sg:GoToState("idle", false)
            inst:PerformBufferedAction()
        end,
        
        onexit= function(inst)
            inst.SoundEmitter:KillSound("make")
        end,
    }, 

    State{
        name = "wrap",
        tags = {"doing", "busy"},
        
        timeline=
        {
            TimeEvent(4*FRAMES, function( inst )
                inst.sg:RemoveStateTag("busy")
            end),
        },
        
        onenter = function(inst, timeout)
            inst.components.locomotor:Stop()
            inst.SoundEmitter:PlaySound("dontstarve/wilson/make_trap", "make")
            
            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("build_loop", true)
        end,
        
        onexit= function(inst)
            inst.SoundEmitter:KillSound("make")
            if inst.sg.statemem.container then
                inst.sg.statemem.container.components.container:Close()
                inst.sg.statemem.container = nil
            end
        end,
    },

     State{
        name = "eat",
        tags ={"busy", "boating"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            --inst.components.driver:SplitFromVehicle()
            local is_gear = inst:GetBufferedAction() and inst:GetBufferedAction().invobject and inst:GetBufferedAction().invobject.components.edible and inst:GetBufferedAction().invobject.components.edible.foodtype == "GEARS"

            if not is_gear then
                inst.SoundEmitter:PlaySound("dontstarve/wilson/eat", "eating")    
            end
            
            inst.AnimState:PlayAnimation("eat")
            inst.components.hunger:Pause()
        end,

        timeline=
        {
            
            TimeEvent(28*FRAMES, function(inst) 
                inst:PerformBufferedAction() 
            end),
            
            TimeEvent(30*FRAMES, function(inst) 
                inst.sg:RemoveStateTag("busy")
            end),
            
            TimeEvent(70*FRAMES, function(inst) 
                inst.SoundEmitter:KillSound("eating")    
            end),
            
        },        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
        
        onexit= function(inst)
            inst.SoundEmitter:KillSound("eating")    
            inst.components.hunger:Resume()
        end,
    }, 


    State{
        name = "quickeat",
        tags ={"busy", "boating"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            --inst.components.driver:SplitFromVehicle()
            local is_gear = inst:GetBufferedAction() and inst:GetBufferedAction().invobject and inst:GetBufferedAction().invobject.components.edible and inst:GetBufferedAction().invobject.components.edible.foodtype == "GEARS"
            if not is_gear then
                inst.SoundEmitter:PlaySound("dontstarve/wilson/eat", "eating")    
            end
            inst.AnimState:PlayAnimation("quick_eat")
            inst.components.hunger:Pause()
        end,

        timeline=
        {
            TimeEvent(12*FRAMES, function(inst) 
                inst:PerformBufferedAction() 
                inst.sg:RemoveStateTag("busy")
            end),
        },        
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
        
        onexit= function(inst)
            inst.SoundEmitter:KillSound("eating")    
            inst.components.hunger:Resume()
        end,
    },  

    State{
        name = "blowdart",
        tags = {"attack", "notalking", "abouttoattack", "boating"},
        
        onenter = function(inst)
            --inst.components.driver:SplitFromVehicle()
            inst.sg.statemem.target = inst.components.combat.target
            inst.components.combat:StartAttack()
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("dart")
            
            if inst.components.combat.target then
                if inst.components.combat.target and inst.components.combat.target:IsValid() then
                    inst:FacePoint(Point(inst.components.combat.target.Transform:GetWorldPosition()))
                end
            end
        end,
        
        timeline=
        {
            TimeEvent(8*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/blowdart_shoot")
            end),
            TimeEvent(10*FRAMES, function(inst)
                inst.sg:RemoveStateTag("abouttoattack")
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/blowdart_shoot")
            end),
            TimeEvent(20*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),
        },
        
        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

     State{
        name = "speargun",
        tags = {"attack", "notalking", "abouttoattack"},
        
        onenter = function(inst)
            inst.sg.statemem.target = inst.components.combat.target
            inst.components.combat:StartAttack()
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("speargun")
            
            if inst.components.combat.target then
                if inst.components.combat.target and inst.components.combat.target:IsValid() then
                    inst:FacePoint(Point(inst.components.combat.target.Transform:GetWorldPosition()))
                end
            end
        end,
        
        timeline=
        {
           
            TimeEvent(12*FRAMES, function(inst)
                inst.sg:RemoveStateTag("abouttoattack")
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                if inst.components.combat:GetWeapon() and inst.components.combat:GetWeapon():HasTag("blunderbuss") then
                    inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/items/weapon/blunderbuss_shoot")
                    local cloud = SpawnPrefab("cloudpuff")
                    local pt = Vector3(inst.Transform:GetWorldPosition())

                    local angle = (inst:GetAngleToPoint(inst.components.combat.target.Transform:GetWorldPosition()) -90)*DEGREES

                    local DIST = 1.5
                    local offset = Vector3(DIST * math.cos( angle+(PI/2) ), 0, -DIST * math.sin( angle+(PI/2) ))

                    cloud.Transform:SetPosition(pt.x+offset.x,2,pt.z+offset.z)
                else
                    inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/use_speargun")
                end
            end),
            TimeEvent(20*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),
        },
        
        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },
    
    State{
        name = "throw",
        tags = {"attack", "notalking", "abouttoattack", "boating"},
        
        onenter = function(inst)
            --inst.components.driver:SplitFromVehicle()
            inst.sg.statemem.target = inst.components.combat.target
            inst.components.combat:StartAttack()
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("throw")
            
            if inst.components.combat.target then
                if inst.components.combat.target and inst.components.combat.target:IsValid() then
                    inst:FacePoint(inst.components.combat.target.Transform:GetWorldPosition())
                end
            end
            
        end,
        
        timeline=
        {
            TimeEvent(7*FRAMES, function(inst)
                inst:PerformBufferedAction()
                inst.components.combat:DoAttack(inst.sg.statemem.target)
                inst.sg:RemoveStateTag("abouttoattack")
            end),
            TimeEvent(11*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),
        },
        
        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },
    
    State{
        name = "catch_pre",
        tags = {"notalking", "readytocatch", "boating"},
        
        onenter = function(inst)
            --inst.components.driver:SplitFromVehicle()
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("catch_pre")
            inst:PerformBufferedAction()
            inst.sg:SetTimeout(2)
        end,
        
        ontimeout= function(inst)
            inst.sg:GoToState("idle")
        end,
        
        events=
        {
            EventHandler("catch", function(inst)
                inst.sg:GoToState("catch")
            end),
        },
    },
    
    State{
        name = "catch",
        tags = {"busy", "notalking", "boating"},
        
        onenter = function(inst)
            --inst.components.driver:SplitFromVehicle()
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("catch")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/boomerang_catch")
        end,
        
        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "attack",
        tags = {"attack", "notalking", "abouttoattack", "busy", "boating"},
        
        onenter = function(inst)
            --print(debugstack())
            --inst.components.driver:SplitFromVehicle()
            local weapon = inst.components.combat:GetWeapon()
            local otherequipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

            if (weapon and weapon:HasTag("gun")) or (otherequipped and otherequipped:HasTag("gun")) then
                inst.sg:GoToState("shoot")
                return
            end

            if weapon then
                inst.AnimState:PlayAnimation("atk")
                if weapon:HasTag("icestaff") then
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_icestaff")
                elseif weapon:HasTag("shadow") then
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_nightsword")
                elseif weapon:HasTag("firestaff") then
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_firestaff")
                elseif weapon:HasTag("halberd") then
                    inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/items/weapon/halberd")                    
                elseif weapon:HasTag("cutlass") then
                    inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/swordfish_sword")
                elseif weapon:HasTag("pegleg") then
                    inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/pegleg_weapon")
                elseif weapon:HasTag("corkbat") then
                    inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/items/weapon/corkbat")                    
                else
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
                end
            elseif otherequipped and (otherequipped:HasTag("light") or otherequipped:HasTag("nopunch")) then
                inst.AnimState:PlayAnimation("atk")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
            else
                inst.sg.statemem.slow = true
                inst.AnimState:PlayAnimation("punch")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
            end
            
            if inst.components.combat.target then
                inst.components.combat:BattleCry()
                if inst.components.combat.target and inst.components.combat.target:IsValid() then
                    inst:FacePoint(Point(inst.components.combat.target.Transform:GetWorldPosition()))
                end
            end

            inst.sg.statemem.target = inst.components.combat.target
            inst.components.combat:StartAttack()
            inst.components.locomotor:Stop()
            
        end,
        
        timeline=
        {
            TimeEvent(8*FRAMES, function(inst) 
                    inst.components.combat:DoAttack(inst.sg.statemem.target) 
                    inst.sg:RemoveStateTag("abouttoattack") 

                    local weapon = inst.components.combat:GetWeapon()
                    if weapon and weapon:HasTag("corkbat") then
                        inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/items/weapon/corkbat_hit")
                    end                    
                end),
            TimeEvent(12*FRAMES, function(inst) 
                inst.sg:RemoveStateTag("busy")
            end),               
            TimeEvent(13*FRAMES, function(inst)
                if not inst.sg.statemem.slow then
                    inst.sg:RemoveStateTag("attack")
                end
            end),
            TimeEvent(24*FRAMES, function(inst)
                if inst.sg.statemem.slow then
                    inst.sg:RemoveStateTag("attack")
                end
            end),
            
        },
        
        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end ),
        },
    },

    State{
        name = "shoot",
        tags = {"attack", "notalking", "abouttoattack", "busy", "boating"},
        
        onenter = function(inst)
            local weapon = inst.components.combat:GetWeapon()
            local otherequipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if (weapon and weapon:HasTag("hand_gun")) or (otherequipped and otherequipped:HasTag("hand_gun")) then
                inst.AnimState:PlayAnimation("hand_shoot")
            else
                inst.AnimState:PlayAnimation("shoot")
            end

            if inst.components.combat.target then
                inst.components.combat:BattleCry()
                if inst.components.combat.target and inst.components.combat.target:IsValid() then
                    inst:FacePoint(Point(inst.components.combat.target.Transform:GetWorldPosition()))
                end
            end
            inst.sg.statemem.target = inst.components.combat.target
            inst.components.combat:StartAttack()
            inst.components.locomotor:Stop()            
        end,
        
        timeline=
        {
            TimeEvent(17*FRAMES, function(inst) 
                inst.components.combat:DoAttack(inst.sg.statemem.target) 
                inst.sg:RemoveStateTag("abouttoattack") 
            end),            
            TimeEvent(20*FRAMES, function(inst)
                    inst.sg:RemoveStateTag("attack")
            end),           
            
        },
        
        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end ),
        },
    }, 
    
    State{ name = "crop_dust",
        tags = {"busy","canrotate"},
        
        onenter = function(inst)
            local action = inst:GetBufferedAction()
            
            inst:FacePoint(Point(action.pos.x,action.pos.y,action.pos.z))
           
            --dumptable(action,1,1,1)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("cropdust_pre")
            inst.AnimState:PushAnimation("cropdust_loop")
            inst.AnimState:PushAnimation("cropdust_pst", false)
        end,
        
        timeline=
        {
            TimeEvent(20*FRAMES, function(inst) 
                inst:PerformBufferedAction() 
                inst.sg:RemoveStateTag("busy") 
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/items/weapon/bugrepellant")
            end),
        },
        
        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

     State{ name = "bugnet_start",
        tags = {"prenet", "working", "boating"},
        onenter = function(inst)
            --inst.components.driver:SplitFromVehicle()
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("bugnet_pre")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("bugnet") end),
        },
    },
    
    State{
        name = "bugnet",
        tags = {"prenet", "netting", "working", "boating"},
        onenter = function(inst)
            --inst.components.driver:SplitFromVehicle()
            inst.AnimState:PlayAnimation("bugnet")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/use_bugnet")
        end,

        timeline=
        {
            TimeEvent(10*FRAMES, function(inst) 
                inst:PerformBufferedAction() 
                inst.sg:RemoveStateTag("prenet") 
                inst.SoundEmitter:PlaySound("dontstarve/wilson/dig")
            end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) 
                inst.sg:GoToState("idle", true)
            end ),
        },        
    },    

    State{ name = "chop_start",
        tags = {"prechop", "chopping", "working"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation(inst.prefab == "woodie" and "woodie_chop_pre" or "chop_pre")
        end,
        
        events=
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end ),
            EventHandler("animover", function(inst) inst.sg:GoToState("chop") end),
        },
    },
    
    State{
        name = "chop",
        tags = {"prechop", "chopping", "working"},
        onenter = function(inst)
            inst.sg.statemem.action = inst:GetBufferedAction()
            inst.AnimState:PlayAnimation(inst.prefab == "woodie" and "woodie_chop_loop" or "chop_loop")            
        end,
        
        timeline=
        {
            TimeEvent(2*FRAMES, function(inst) 
                if inst.prefab == "woodie" then
                    inst:PerformBufferedAction() 
                end
            end),

            TimeEvent(5*FRAMES, function(inst)
                if inst.prefab == "woodie" then
                    inst.sg:RemoveStateTag("prechop")
                end
            end),

            TimeEvent(10*FRAMES, function(inst)
                if inst.prefab == "woodie" and
                   (TheInput:IsControlPressed(CONTROL_PRIMARY) or TheInput:IsControlPressed(CONTROL_ACTION) or TheInput:IsControlPressed(CONTROL_CONTROLLER_ACTION)) and 
                    inst.sg.statemem.action and 
                    inst.sg.statemem.action:IsValid() and 
                    inst.sg.statemem.action.target and 
                    inst.sg.statemem.action.target:IsActionValid(inst.sg.statemem.action.action) and 
                    inst.sg.statemem.action.target.components.workable then
                        inst:ClearBufferedAction()
                        inst:PushBufferedAction(inst.sg.statemem.action)
                end
            end),

            
            TimeEvent(5*FRAMES, function(inst) 
                if inst.prefab ~= "woodie" then
                    inst:PerformBufferedAction() 
                end
            end),


            TimeEvent(9*FRAMES, function(inst)
                if inst.prefab ~= "woodie" then
                    inst.sg:RemoveStateTag("prechop")
                end
            end),
            
            TimeEvent(14*FRAMES, function(inst)
                if inst.prefab ~= "woodie" and
                    (TheInput:IsMouseDown(MOUSEBUTTON_LEFT) or TheInput:IsControlPressed(CONTROL_ACTION) or TheInput:IsControlPressed(CONTROL_CONTROLLER_ACTION)) and 
                    inst.sg.statemem.action and 
                    inst.sg.statemem.action:IsValid() and 
                    inst.sg.statemem.action.target and 
                    inst.sg.statemem.action.target:IsActionValid(inst.sg.statemem.action.action) and 
                    inst.sg.statemem.action.target.components.workable then
                        inst:ClearBufferedAction()
                        inst:PushBufferedAction(inst.sg.statemem.action)
                end
            end),

            TimeEvent(16*FRAMES, function(inst) 
                inst.sg:RemoveStateTag("chopping")
            end),

        },
        
        events=
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end ),
            EventHandler("animover", function(inst) 
                --inst.AnimState:PlayAnimation("chop_pst") 
                inst.sg:GoToState("idle")
            end ),
            
        },        
    },


    ---------------Fishing start ---------------------
 State{ name = "fishing_pre",
        tags = {"prefish", "fishing", "boating"},
        onenter = function(inst)
            --inst.components.driver:SplitFromVehicle()
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("fishing_pre")
        end,
        
        timeline = 
        {
            TimeEvent(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_cast") end),
            TimeEvent(15*FRAMES, function(inst) inst:PerformBufferedAction() end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) 
                inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_baitsplash")
                inst.sg:GoToState("fishing")
            end ),
        },        
    },
    
    State{
        name = "fishing",
        tags = {"fishing", "boating"},
        onenter = function(inst, pushanim)
            --inst.components.driver:SplitFromVehicle()
            if pushanim then
                if type(pushanim) == "string" then
                    inst.AnimState:PlayAnimation(pushanim)
                end
                inst.AnimState:PushAnimation("fishing_idle", true)
            else
                inst.AnimState:PlayAnimation("fishing_idle", true)
            end
            local equippedTool = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if equippedTool and equippedTool.components.fishingrod then
                equippedTool.components.fishingrod:WaitForFish()
            end
        end,
        
        events=
        {
            EventHandler("fishingnibble", function(inst) inst.sg:GoToState("fishing_nibble") end ),
            EventHandler("fishingloserod", function(inst) inst.sg:GoToState("loserod")end),
        },
    },
    
    State{ name = "fishing_pst",
        tags = {"boating"},
        onenter = function(inst)
            --inst.components.driver:SplitFromVehicle()
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("fishing_pst")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },
    
    State{
        name = "fishing_nibble",
        tags = {"fishing", "nibble", "boating"},
        onenter = function(inst)
           -- inst.components.driver:SplitFromVehicle()
            inst.AnimState:PlayAnimation("bite_light_pre")
            inst.AnimState:PushAnimation("bite_light_loop", true)
            inst.sg:SetTimeout(1 + math.random())
            inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_fishinwater", "splash")
        end,
        
        onexit = function(inst)
            inst.SoundEmitter:KillSound("splash")
        end,
        
        ontimeout = function(inst)
            inst.sg:GoToState("fishing", "bite_light_pst")
        end,
        
        events = 
        {
            EventHandler("fishingstrain", function(inst) inst.sg:GoToState("fishing_strain") end),
        },
    }, 
    
    State{
        name = "fishing_strain",
        tags = {"fishing", "boating"},
        onenter = function(inst)
           -- inst.components.driver:SplitFromVehicle()
            inst.AnimState:PlayAnimation("bite_heavy_pre")
            inst.AnimState:PushAnimation("bite_heavy_loop", true)
            inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_fishinwater", "splash")
            inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_strain", "strain")
            if math.random() < TUNING.FISHING_CROCODOG_SPAWN_CHANCE then 
                GetWorld().components.hounded:SummonHound()
            end 
        end,
        
        onexit = function(inst)
            inst.SoundEmitter:KillSound("splash")
            inst.SoundEmitter:KillSound("strain")
        end,
        
        events = 
        {
            EventHandler("fishingcatch", function(inst, data)
                inst.sg:GoToState("catchfish", data.build)
            end),
            EventHandler("fishingloserod", function(inst)
                inst.sg:GoToState("loserod")
            end),

        },
    },
    
    State{
        name = "catchfish",
        tags = {"fishing", "catchfish", "busy", "boating"},
        onenter = function(inst, build)
            --inst.components.driver:SplitFromVehicle()
            inst.AnimState:PlayAnimation("fish_catch")
            print("Using ", build, " to swap out fish01")
            inst.AnimState:OverrideSymbol("fish01", build, "fish01")
            
        end,
        
        onexit = function(inst)
            inst.AnimState:ClearOverrideSymbol("fish01")

        end,

        timeline=
        {
            TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_fishcaught") end),
            TimeEvent(10*FRAMES, function(inst) inst.sg:RemoveStateTag("fishing") end),
            TimeEvent(23*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_fishland") end),
            TimeEvent(24*FRAMES, function(inst)
                local equippedTool = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if equippedTool and equippedTool.components.fishingrod then
                    equippedTool.components.fishingrod:Collect()
                end
            end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) 
                inst.sg:GoToState("idle")
            end ),
        },        
    },       
    
    State{
        name = "loserod",
        tags = {"busy", "boating"},
        onenter = function(inst)
            --inst.components.driver:SplitFromVehicle()
            local equippedTool = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if equippedTool and equippedTool.components.fishingrod then
                equippedTool.components.fishingrod:Release()
                equippedTool:Remove()
            end
            inst.AnimState:PlayAnimation("fish_nocatch")
        end,

        timeline=
        {
            TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_lostrod") end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) 
                inst.sg:GoToState("idle")
            end ),
        },        
    }, 

    State{
        name = "fishing_retrieve",
        --tags = {"prefish", "fishing", "boating"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("fishing_pre") --26

            inst.AnimState:PushAnimation("bite_heavy_pre") --5
            inst.AnimState:PushAnimation("bite_heavy_loop", false) --14

            inst.AnimState:PushAnimation("fish_catch", false)

            if inst.bufferedaction.target and 
               inst.bufferedaction.target.components.sinkable and 
               inst.bufferedaction.target.components.sinkable.swapbuild and 
               inst.bufferedaction.target.components.sinkable.swapsymbol then

                local s = inst.bufferedaction.target.components.sinkable               
                inst.AnimState:OverrideSymbol("fish01", s.swapbuild, s.swapsymbol )               
            else
                inst.AnimState:OverrideSymbol("fish01", "graves_water_crate", "fish01")
            end
        end,

        onexit = function(inst)
            inst.AnimState:ClearOverrideSymbol("fish01")
        end,
        
        timeline = 
        {
            TimeEvent(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_cast") end),
            TimeEvent(15*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_baitsplash")
                inst:PerformBufferedAction()
            end),
            TimeEvent((26+5+14+8)*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_fishcaught") end),
            TimeEvent((26+5+14+14)*FRAMES, function(inst)              
                local equippedTool = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if equippedTool and equippedTool.components.fishingrod then
                    equippedTool.components.fishingrod.target:PushEvent("retrieve")
                end
                inst:DoTaskInTime(10*FRAMES, function(inst)
                    local equippedTool = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                    if equippedTool and equippedTool.components.fishingrod then
                        equippedTool.components.fishingrod:Retrieve()
                    end
                end)
            end),
            TimeEvent((26+5+14+23)*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/fishingpole_fishland") end),
            --TimeEvent((26+5+14+24)*FRAMES, function(inst)end),
        },
        
        events=
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle")
            end ),
        },        
    },



    ---------------Fishing End-------------------------
    State{
        name = "werebeaver",
        tags = {"busy"},
        onenter = function(inst)
            --inst.components.beaverness.doing_transform = true
            inst.Physics:Stop()          
            inst.AnimState:PlayAnimation("transform_pre")
            inst.components.playercontroller:Enable(false)
        end,
        
        onexit = function(inst)
            
            
            --inst.components.playercontroller:Enable(true)
            --inst.components.beaverness.doing_transform = false
        end,

        events =
        {
            EventHandler("animover", function(inst)
                  inst.sg:GoToState("werebeaver_boat_transform")     
            end ),
        } 
    },


     State{
        name = "werebeaver_boat_transform",
        tags = {"busy"},
        onenter = function(inst)
            --inst.components.beaverness.doing_transform = true
            inst.Physics:Stop()          
            inst.AnimState:SetBuild("werebeaver_build")
            inst.AnimState:SetBank("werebeaver")
            inst.AnimState:PlayAnimation("transform_boat_pst")
        end,
        
        events =
        {
            EventHandler("animover", function(inst)

                 if inst.components.driver and inst.components.driver:GetIsDriving() then 
                    inst.components.resurrectable.cantdrown = true 
                    inst.components.driver.vehicle.components.boathealth:SetHealth(0)
                    inst.components.driver.vehicle.components.boathealth:DoDelta(-1, "combat")
                    inst.components.beaverness:SetPercent(0)
                end 
                inst.sg:GoToState("werebeaver_death_boat")  -- This state is in SGWilson, the stategraph gets switch when the boat dies 
            end ),
        } 
    },

   

    State{
        name = "quicktele",
        tags = {"doing", "busy", "canrotate", "boating"},

        onenter = function(inst)
            --inst.components.driver:SplitFromVehicle()
            inst.AnimState:PlayAnimation("atk")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
        end,

        timeline = 
        {
            TimeEvent(8*FRAMES, function(inst) inst:PerformBufferedAction() end),
        },

        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle") 
            end ),
        },
    },  


     State{
        name = "give",
        tags = {"boating"},
        
        onenter = function(inst)
            --inst.components.driver:SplitFromVehicle()
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("give") 
        end,
        
        timeline =
        {
            TimeEvent(13*FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },        

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },   

    State{
        name = "book",
        tags = {"doing", "boating"},
        
        onenter = function(inst)
           -- inst.components.driver:SplitFromVehicle()
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("book")
            inst.AnimState:OverrideSymbol("book_open", "book_uniqueitem_swap", "book_open")
            inst.AnimState:OverrideSymbol("book_closed", "book_uniqueitem_swap", "book_closed")
            inst.AnimState:OverrideSymbol("book_open_pages", "book_uniqueitem_swap", "book_open_pages")
            --inst.AnimState:Hide("ARM_carry") 
            inst.AnimState:Show("ARM_normal")
            if inst.components.inventory.activeitem and inst.components.inventory.activeitem.components.book then
                inst.components.inventory:ReturnActiveItem()
            end
            inst.SoundEmitter:PlaySound("dontstarve/common/use_book")
        end,
        
        onexit = function(inst)
            if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                inst.AnimState:Show("ARM_carry") 
                inst.AnimState:Hide("ARM_normal")
            end
            if inst.sg.statemem.book_fx then
                inst.sg.statemem.book_fx:Remove()
                inst.sg.statemem.book_fx = nil
            end
        end,
        
        timeline=
        {
            TimeEvent(0, function(inst)
                local fxtoplay = "book_fx"
                if inst.prefab == "waxwell" then
                    fxtoplay = "waxwell_book_fx" 
                end       
                local fx = SpawnPrefab(fxtoplay)
                local pos = inst:GetPosition()
                fx.Transform:SetRotation(inst.Transform:GetRotation())
                fx.Transform:SetPosition( pos.x, pos.y - .2, pos.z ) 
                inst.sg.statemem.book_fx = fx
            end),

            TimeEvent(58*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/book_spell")
                inst:PerformBufferedAction()
                inst.sg.statemem.book_fx = nil
            end),
        },
        
        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

     State{
        name = "map",
        tags = {"doing"},
        
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("scroll", false)
            inst.AnimState:OverrideSymbol("scroll", "messagebottle", "scroll")
            inst.AnimState:PushAnimation("scroll_pst", false)
            
            --inst.AnimState:Hide("ARM_carry") 
            inst.AnimState:Show("ARM_normal")
            if inst.components.inventory.activeitem and inst.components.inventory.activeitem.components.book then
                inst.components.inventory:ReturnActiveItem()
            end
        end,
        
        onexit = function(inst)
            if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                inst.AnimState:Show("ARM_carry") 
                inst.AnimState:Hide("ARM_normal")
            end
        end,
        
        timeline=
        {
            TimeEvent(24*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/treasuremap_open") end),
            TimeEvent(58*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/treasuremap_close") end),
        },
        
        events=
        {
            EventHandler("animover", function(inst)
                inst:PerformBufferedAction()
            end),

            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle")
            end),
            
        },
    },    

     State{
        name = "makeballoon",
        tags = {"doing", "boating"},
        
        onenter = function(inst, timeout)
            --inst.components.driver:SplitFromVehicle()
            inst.sg:SetTimeout(timeout or 1)
            inst.components.locomotor:Stop()
            inst.SoundEmitter:PlaySound("dontstarve/common/balloon_make", "make")
            inst.SoundEmitter:PlaySound("dontstarve/common/balloon_blowup")
            
            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("build_loop", true)
        end,
        
        ontimeout= function(inst)
            inst.AnimState:PlayAnimation("build_pst")
            inst.sg:GoToState("idle", false)
            inst:PerformBufferedAction()
        
        end,
        
        onexit= function(inst)
            inst.SoundEmitter:KillSound("make")
        end,
    },

    State{
        name = "shave",
        tags = {"doing", "shaving", "boating"},
        
        onenter = function(inst)
            --inst.components.driver:SplitFromVehicle()
            local timeout = 1
            inst.sg:SetTimeout(timeout)
            inst.components.locomotor:Stop()
            inst.SoundEmitter:PlaySound("dontstarve/wilson/shave_LP", "shave")
            
            inst.AnimState:PlayAnimation("build_pre")
            inst.AnimState:PushAnimation("build_loop", true)
        end,
        
        ontimeout = function(inst)
            inst:PerformBufferedAction()
            inst.AnimState:PlayAnimation("build_pst")
            inst.sg:GoToState("idle", false)
        end,
        
        onexit= function(inst)
            inst.SoundEmitter:KillSound("shave")
        end,
        
    },

    State{
        name = "jumpin",
        tags = {"doing", "canrotate"},
        
        onenter = function(inst)
            inst.sg.statemem.action = inst:GetBufferedAction()
            inst.components.locomotor:Stop()

            inst.AnimState:Pause()

            inst.sg:SetTimeout(145*FRAMES)

            inst.sg.statemem.startinfo =
            {
                colour = inst.AnimState:GetMultColour(),
                scale = inst.Transform:GetScale(),
            }
        
            local textures =
            {
                "images/bermudaTriangle01.tex",
                "images/bermudaTriangle02.tex",
                "images/bermudaTriangle03.tex",
                "images/bermudaTriangle04.tex",
                "images/bermudaTriangle05.tex",
            }

            local colours = 
            {
                { 30/255, 57/255, 81/255, 1.0 },
                { 30/255, 57/255, 81/232, 1.0 },
				{ 30/255, 57/255, 81/232, 1.0 },
				{ 30/255, 57/255, 81/232, 1.0 },

                { 255/255, 255/255, 255/255, 1.0 },
                { 255/255, 255/255, 255/255, 1.0 },
				
                { 0, 0, 0, 1.0 },
            }

            local colourfn = nil
            local posfn = nil
            local scalefn = nil
            local texturefn = nil

            colourfn = function()
                local colour = colours[math.random(#colours)]
                inst.AnimState:SetAddColour(colour[1], colour[2], colour[3], colour[4])
                inst.sg.statemem.colourtask = nil
                inst.sg.statemem.colourtask = inst:DoTaskInTime(math.random(10, 15) * FRAMES, colourfn)
            end

            posfn = function()
                local offset = Vector3(math.random(-1, 1) * .1, math.random(-1, 1) * .1, math.random(-1, 1) * .1)
                inst.Transform:SetPosition((inst:GetPosition() + offset):Get())
                inst.sg.statemem.postask = nil
                inst.sg.statemem.postask = inst:DoTaskInTime(math.random(4, 6) * FRAMES, posfn)
            end

            scalefn = function()
                inst.Transform:SetScale(math.random(95, 105) * 0.01, math.random(99, 101) * 0.01, 1)

                inst.sg.statemem.scaletask = nil
                inst.sg.statemem.scaletask = inst:DoTaskInTime(math.random(3, 6) * FRAMES, scalefn)
            end

            texturefn = function()
                inst.AnimState:SetErosionParams(math.random(4, 6) * 0.1, 0, 1)
                inst.AnimState:SetErosionTexture(textures[math.random(#textures)])

                inst.sg.statemem.texturetask = nil
                inst.sg.statemem.texturetask = inst:DoTaskInTime(math.random(3, 6) * FRAMES, texturefn)
            end

            colourfn()
            posfn()
            scalefn()
            texturefn()
        end,
        
        onexit = function(inst)
            inst.sg.statemem.colourtask:Cancel()
            inst.sg.statemem.colourtask = nil

            inst.sg.statemem.postask:Cancel()
            inst.sg.statemem.postask = nil

            inst.sg.statemem.scaletask:Cancel()
            inst.sg.statemem.scaletask = nil

            inst.sg.statemem.texturetask:Cancel()
            inst.sg.statemem.texturetask = nil

            inst.AnimState:SetAddColour(0,0,0,1)
            inst.Transform:SetScale(1,1,1)

            inst.AnimState:SetErosionParams(0, 0, 0)

            inst.AnimState:Resume()

            inst:Show()
            inst.components.health:SetInvincible(false)
        end,

        timeline =
        {
            -- this is just hacked in here to make the sound play BEFORE the player hits the wormhole
            TimeEvent(30*FRAMES, function(inst)
                inst:Hide()
                inst.components.health:SetInvincible(true)
                SpawnPrefab("pixel_out").Transform:SetPosition(inst:GetPosition():Get())
            end),

            TimeEvent(40*FRAMES, function(inst)
                inst:PerformBufferedAction()                
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/bermudatriangle_travel", "wormhole_travel")
            end),

            TimeEvent(110*FRAMES, function(inst)
                SpawnPrefab("pixel_in").Transform:SetPosition(inst:GetPosition():Get())
            end),

            TimeEvent(120*FRAMES, function(inst)
                inst:Show()
                inst.components.health:SetInvincible(false)
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("idle") 
        end,
    },

    State{
        name = "telebrella",
        tags = {"doing", "busy", "canrotate", "spell"},

        onenter = function(inst)
            inst.telbrellalight = SpawnPrefab("telebrella_glow")
            if inst.telbrellalight then
                local x,y,z = inst.Transform:GetWorldPosition()
                inst.telbrellalight.Transform:SetPosition(x,y,z)
            end           
            inst.components.playercontroller:Enable(false)
            inst.AnimState:PlayAnimation("teleport_out") 
       
            inst.components.locomotor:Stop()
        end,

        onexit = function(inst)
            inst.components.playercontroller:Enable(true)
        end,

        timeline = 
        {
            TimeEvent(13*FRAMES, function(inst)     
                GetClock():DoLightningLighting(.5)
                GetPlayer().SoundEmitter:PlaySound("dontstarve/rain/thunder_close")
                GetPlayer().components.playercontroller:ShakeCamera(inst, "FULL", 0.7, 0.02, .5, 40)
            end),
        },

        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("telebrella_finish") 
            end ),
        },
    },

    State{
        name = "telebrella_finish",
        tags = {"doing", "busy", "canrotate", "spell"},

        onenter = function(inst)
            if not inst.telbrellalight then
                inst.telbrellalight = SpawnPrefab("telebrella_glow")
                if inst.telbrellalight then
                    local x,y,z = inst.Transform:GetWorldPosition()
                    inst.telbrellalight.Transform:SetPosition(x,y,z)
                end
            end          
            inst.components.playercontroller:Enable(false)
            inst.AnimState:PlayAnimation("teleport_finish") 
       
            inst.components.locomotor:Stop()
        end,

        onexit = function(inst)
            inst.components.playercontroller:Enable(true)
        end,

        timeline = 
        {
            TimeEvent(0*FRAMES, function(inst)     

            end),
        },

        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("telebrella_pst") 
            end ),
        },
    },    

    State{
        name = "telebrella_pst",
        tags = {"doing", "busy", "canrotate", "spell"},

        onenter = function(inst)
            if inst.components.driver and inst.components.driver.vehicle then
                inst.components.driver:OnDismount()
                inst.sg:GoToState("telebrella_pst")                
            else
                inst.components.playercontroller:Enable(false)
                inst.AnimState:PlayAnimation("teleport_in") 

                local equipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if equipped and equipped:HasTag("telebrella") then            
                    equipped.teleport(equipped)
                end
                inst:ClearBufferedAction()
                inst.components.locomotor:Stop()
            end
        end,

        onexit = function(inst)
            inst.components.playercontroller:Enable(true)
        end,

        timeline = 
        {
            TimeEvent(39*FRAMES, function(inst)            
            end),
        },

        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle") 
            end ),
        },
    },

    State{
        name = "castspell",
        tags = {"doing", "busy", "canrotate", "boating", "spell"},

        onenter = function(inst)
            --inst.components.driver:SplitFromVehicle()
            inst.components.playercontroller:Enable(false)
            inst.AnimState:PlayAnimation("staff") 
            local colourizefx = function(staff)
                return staff.fxcolour or {1,1,1}
            end
            inst.components.locomotor:Stop()
            --Spawn an effect on the player's location
            inst.stafffx = SpawnPrefab("staffcastfx")            

            local pos = inst:GetPosition()
            local staff = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            inst.stafffx.Transform:SetPosition(pos.x, pos.y, pos.z)
            local colour = colourizefx(staff)

            inst.stafffx.Transform:SetRotation(inst.Transform:GetRotation())
            inst.stafffx.AnimState:SetMultColour(colour[1], colour[2], colour[3], 1)
        end,

        onexit = function(inst)
            inst.components.playercontroller:Enable(true)
            if inst.stafffx then
                inst.stafffx:Remove()
            end
        end,

        timeline = 
        {
            TimeEvent(13*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/use_gemstaff") 
                local staff = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if staff and staff.castfast then
                    inst:PerformBufferedAction()
                end                
            end),
            TimeEvent(0*FRAMES, function(inst)
                inst.stafflight = SpawnPrefab("staff_castinglight")
                local staff = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                local pos = inst:GetPosition()
                local colour = staff.fxcolour or {1,1,1}
                inst.stafflight.Transform:SetPosition(pos.x, pos.y, pos.z)
                inst.stafflight.setupfn(inst.stafflight, colour, 1.9, .33)                

            end),
            TimeEvent(53*FRAMES, function(inst) inst:PerformBufferedAction() end),

            TimeEvent(60*FRAMES, function(inst) 
                    local staff = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                    if staff and staff.endcast then
                        staff.endcast(staff)
                    end
                end),              
        },

        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle") 
            end ),
        },

    },
    
    State{
        name = "peertelescope",
        tags = {"doing", "busy", "canrotate"},

        onenter = function(inst)
            inst.sg.statemem.action = inst:GetBufferedAction()
            local act = inst:GetBufferedAction()

            inst:ForceFacePoint(act.pos.x, act.pos.y, act.pos.z)
            inst.components.playercontroller:Enable(false)
            inst.AnimState:PlayAnimation("telescope", false)
            inst.AnimState:PushAnimation("telescope_pst", false)

            inst.components.locomotor:Stop()
        end,

        timeline = 
        {
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/use_spyglass") end),
        },

        onexit = function(inst)
            inst.components.playercontroller:Enable(true)
        end,

        events = {
            EventHandler("animover", function(inst)
                inst:PerformBufferedAction()
            end ),
            EventHandler("animqueueover", function(inst)
                
                local telescope = inst.sg.statemem.action.invobject or inst.sg.statemem.action.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if telescope and telescope.components.finiteuses then
                    -- this is here because the telescope still needs to exist while playing the put away animation
                    --telescope.components.finiteuses:Use()
                end

                inst.sg:GoToState("idle")

            end ),
        },
    },

    State{
        name = "castspell_tornado",
        tags = {"doing", "busy", "canrotate", "boating"},

        onenter = function(inst)
            --inst.components.driver:SplitFromVehicle()
            inst.components.playercontroller:Enable(false)
            inst.AnimState:PlayAnimation("atk") 
            inst.components.locomotor:Stop()
            --Spawn an effect on the player's location
        end,

        onexit = function(inst)
            inst.components.playercontroller:Enable(true)
        end,

        timeline = 
        {
            TimeEvent(5*FRAMES, function(inst) inst:PerformBufferedAction() end),
        },

        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle") 
            end ),
        },

    },

    State{
        name = "enter_onemanband",
        tags = {"doing", "playing", "idle", "boating"},

        onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("idle_onemanband1_pre")
        inst.SoundEmitter:PlaySound("dontstarve/wilson/onemanband")
        end,

        onexit = function(inst)
        end,

        events = 
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("play_onemanband") end),
        },
    },

    State{
        name = "play_onemanband",
        tags = {"doing", "playing", "idle", "boating"},

        onenter = function(inst)

            inst.components.locomotor:Stop()
            --inst.AnimState:PlayAnimation("idle_onemanband1_pre")
            inst.AnimState:PlayAnimation("idle_onemanband1_loop")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/onemanband")
        end,

        onexit = function(inst)
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if math.random() <= 0.15 then
                    inst.sg:GoToState("play_onemanband_stomp") -- go into stomp
                else
                    inst.sg:GoToState("play_onemanband")-- loop state again
                end
            end),
        },
    },

    State{
        name = "play_onemanband_stomp",
        tags = {"doing", "playing", "idle", "boating"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("idle_onemanband1_pst")
            inst.AnimState:PushAnimation("idle_onemanband2_pre")
            inst.AnimState:PushAnimation("idle_onemanband2_loop")
            inst.AnimState:PushAnimation("idle_onemanband2_pst", false)  
            inst.SoundEmitter:PlaySound("dontstarve/wilson/onemanband") 
        end,

        onexit = function(inst)
        end,

        timeline=
        {
            TimeEvent(20*FRAMES, function( inst )
                inst.SoundEmitter:PlaySound("dontstarve/wilson/onemanband")                
            end),

            TimeEvent(25*FRAMES, function( inst )
                inst.SoundEmitter:PlaySound("dontstarve/wilson/onemanband")                
            end),
            
            TimeEvent(30*FRAMES, function( inst )
                inst.SoundEmitter:PlaySound("dontstarve/wilson/onemanband")                
            end),

            TimeEvent(35*FRAMES, function( inst )
                inst.SoundEmitter:PlaySound("dontstarve/wilson/onemanband")                
            end),
        },

        events = 
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle") 
            end),
        },
    },

     State{
        name = "play_flute",
        tags = {"doing", "playing", "boating"},
        
        onenter = function(inst)
           -- inst.components.driver:SplitFromVehicle()
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("flute")
            local ba = inst:GetBufferedAction()
            inst.AnimState:OverrideSymbol("pan_flute01", ba.invobject.flutebuild or "pan_flute", ba.invobject.flutesymbol or "pan_flute01")
            inst.AnimState:Hide("ARM_carry") 
            inst.AnimState:Show("ARM_normal")
            if inst.components.inventory.activeitem and inst.components.inventory.activeitem.components.instrument then
                inst.components.inventory:ReturnActiveItem()
            end
        end,
        
        onexit = function(inst)
            inst.SoundEmitter:KillSound("flute")
            if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                inst.AnimState:Show("ARM_carry") 
                inst.AnimState:Hide("ARM_normal")
            end
        end,
        
        timeline=
        {
            TimeEvent(30*FRAMES, function(inst)
                local ba = inst:GetBufferedAction()
				if ba then
	                if ba.invobject and ba.invobject.components.instrument and ba.invobject.components.instrument.sound then
    	                inst.SoundEmitter:PlaySound(ba.invobject.components.instrument.sound, "flute")
        	        elseif ba.invobject and ba.invobject.components.instrument and ba.invobject.components.instrument.sound_noloop then
            	        inst.SoundEmitter:PlaySound(ba.invobject.components.instrument.sound_noloop)
                	else
                    	inst.SoundEmitter:PlaySound("dontstarve/wilson/flute_LP", "flute")
	                end
				end
                inst:PerformBufferedAction()
            end),
            TimeEvent(85*FRAMES, function(inst)
                inst.SoundEmitter:KillSound("flute")
            end),
        },
        
        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },
    
    State{
        name = "play_horn",
        tags = {"doing", "playing", "boating"},
        
        onenter = function(inst)
            --inst.components.driver:SplitFromVehicle()
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("horn")
            local ba = inst:GetBufferedAction()
            inst.AnimState:OverrideSymbol("horn01", ba.invobject.hornbuild or "horn", ba.invobject.hornsymbol or "horn01")
            --inst.AnimState:Hide("ARM_carry") 
            inst.AnimState:Show("ARM_normal")
            if inst.components.inventory.activeitem and inst.components.inventory.activeitem.components.instrument then
                inst.components.inventory:ReturnActiveItem()
            end
        end,
        
        onexit = function(inst)
            if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                inst.AnimState:Show("ARM_carry") 
                inst.AnimState:Hide("ARM_normal")
            end
        end,
        
        timeline=
        {
            TimeEvent(21*FRAMES, function(inst)
                local ba = inst:GetBufferedAction()
                if ba.invobject and ba.invobject.components.instrument and ba.invobject.components.instrument.sound then
                    inst.SoundEmitter:PlaySound(ba.invobject.components.instrument.sound)
                elseif ba.invobject and ba.invobject.components.instrument and ba.invobject.components.instrument.sound_noloop then
                    inst.SoundEmitter:PlaySound(ba.invobject.components.instrument.sound_noloop)
                else
                    inst.SoundEmitter:PlaySound("dontstarve/common/horn_beefalo")
                end
                inst:PerformBufferedAction()
            end),
        },
        
        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "play_bell",
        tags = {"doing", "playing", "boating"},
        
        onenter = function(inst)
           -- inst.components.driver:SplitFromVehicle()
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("bell")
            inst.AnimState:OverrideSymbol("bell01", "bell", "bell01")
            --inst.AnimState:Hide("ARM_carry") 
            inst.AnimState:Show("ARM_normal")
            if inst.components.inventory.activeitem and inst.components.inventory.activeitem.components.instrument then
                inst.components.inventory:ReturnActiveItem()
            end
        end,
        
        onexit = function(inst)
            if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                inst.AnimState:Show("ARM_carry") 
                inst.AnimState:Hide("ARM_normal")
            end
        end,
        
        timeline=
        {
            TimeEvent(15*FRAMES, function(inst)
                local ba = inst:GetBufferedAction()
                if ba.invobject and ba.invobject.components.instrument and ba.invobject.components.instrument.sound then
                    inst.SoundEmitter:PlaySound(ba.invobject.components.instrument.sound)
                elseif ba.invobject and ba.invobject.components.instrument and ba.invobject.components.instrument.sound_noloop then
                    inst.SoundEmitter:PlaySound(ba.invobject.components.instrument.sound_noloop)
                else
                    inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/glommer_bell")
                end
            end),

            TimeEvent(60*FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },
        
        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "use_fan",
        tags = {"doing", "boating"},
        
        onenter = function(inst)
           -- inst.components.driver:SplitFromVehicle()
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("fan")
            inst.AnimState:OverrideSymbol("fan01", "fan", "fan01") 
            inst.AnimState:Show("ARM_normal")
            if inst.components.inventory.activeitem and inst.components.inventory.activeitem.components.fan then
                inst.components.inventory:ReturnActiveItem()
            end
        end,
        
        onexit = function(inst)
            if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                inst.AnimState:Show("ARM_carry") 
                inst.AnimState:Hide("ARM_normal")
            end
        end,
        
        timeline=
        {
            TimeEvent(70*FRAMES, function(inst)
                inst:PerformBufferedAction()
            end),
        },
        
        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{ name = "hack_start",
        tags = {"prehack", "hacking", "working"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("chop_pre")
        end,
        
        events=
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end ),
            EventHandler("animover", function(inst) inst.sg:GoToState("hack") end),
        },
    },
    
    State{
        name = "hack",
        tags = {"prehack", "hacking", "working"},
        onenter = function(inst)
            inst.sg.statemem.action = inst:GetBufferedAction()
            inst.AnimState:PlayAnimation("chop_loop")            
        end,
        
        timeline=
        {
                       
            TimeEvent(5*FRAMES, function(inst) 
                inst:PerformBufferedAction() 
            end),


            TimeEvent(9*FRAMES, function(inst)
                inst.sg:RemoveStateTag("prehack")
            end),
            
            TimeEvent(14*FRAMES, function(inst)
                    if (TheInput:IsMouseDown(MOUSEBUTTON_LEFT) or TheInput:IsControlPressed(CONTROL_ACTION) or TheInput:IsControlPressed(CONTROL_CONTROLLER_ACTION)) and 
                    inst.sg.statemem.action and 
                    inst.sg.statemem.action:IsValid() and 
                    inst.sg.statemem.action.target and 
                    inst.sg.statemem.action.target:IsActionValid(inst.sg.statemem.action.action) and 
                    inst.sg.statemem.action.target.components.hackable then
                        inst:ClearBufferedAction()
                        inst:PushBufferedAction(inst.sg.statemem.action)
                end
            end),

            TimeEvent(16*FRAMES, function(inst) 
                inst.sg:RemoveStateTag("hacking")
            end),

        },
        
        events=
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end ),
            EventHandler("animover", function(inst) 
                --inst.AnimState:PlayAnimation("chop_pst") 
                inst.sg:GoToState("idle")
            end ),
            
        },        
    },

    State{ name = "mine_start",
        tags = {"premine", "working"},
        onenter = function(inst)
           -- inst.components.driver:SplitFromVehicle()
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pickaxe_pre")
        end,
        
        events=
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end ),
            EventHandler("animover", function(inst) inst.sg:GoToState("mine") end),
        },
    },
    
    State{
        name = "mine",
        tags = {"premine", "mining", "working"},
        onenter = function(inst)
           -- inst.components.driver:SplitFromVehicle()
            inst.sg.statemem.action = inst:GetBufferedAction()
            inst.AnimState:PlayAnimation("pickaxe_loop")
        end,

        timeline=
        {
            TimeEvent(9*FRAMES, function(inst) 
                if inst.sg.statemem.action and inst.sg.statemem.action.target then
                    local fx = SpawnPrefab("mining_fx")
                    fx.Transform:SetPosition(inst.sg.statemem.action.target:GetPosition():Get())
                end
                inst:PerformBufferedAction() 
                inst.sg:RemoveStateTag("premine") 
                if inst.sg.statemem.action and inst.sg.statemem.action.target and inst.sg.statemem.action.target.prefab == "rock_ice" then
                    inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/iceboulder_hit")
                elseif inst.sg.statemem.action and inst.sg.statemem.action.target and inst.sg.statemem.action.target.prefab == "coralreef" then
                    inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/coral_hit_mine_pick")
                else
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/use_pick_rock")
                end
            end),
            
            TimeEvent(14*FRAMES, function(inst)
                if (TheInput:IsControlPressed(CONTROL_PRIMARY) or
                   TheInput:IsControlPressed(CONTROL_ACTION)  or TheInput:IsControlPressed(CONTROL_CONTROLLER_ACTION)) and 
                    inst.sg.statemem.action and 
                    inst.sg.statemem.action.target and 
                    inst.sg.statemem.action.target:IsActionValid(inst.sg.statemem.action.action) and 
                    inst.sg.statemem.action.target.components.workable then
                        inst:ClearBufferedAction()
                        inst:PushBufferedAction(inst.sg.statemem.action)
                end
            end),
            
        },
        
        events=
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end ),
            EventHandler("animover", function(inst) 
                inst.AnimState:PlayAnimation("pickaxe_pst") 
                inst.sg:GoToState("idle", true)
            end ),        
        },        
    },

    State{
        name = "sneeze",
        tags = {"busy","sneeze"},
        
        onenter = function(inst)
            inst.wantstosneeze = false
            inst.SoundEmitter:PlaySound("dontstarve/wilson/hit",nil,.02)
            inst.AnimState:PlayAnimation("sneeze")
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/sneeze")
            inst:ClearBufferedAction()
            
            if inst.prefab ~= "wes" then
                local sound_name = inst.soundsname or inst.prefab
                local path = inst.talker_path_override or "dontstarve/characters/"
                --local equippedHat = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
                --if equippedHat and equippedHat:HasTag("muffler") then
                    --inst.SoundEmitter:PlaySound(path..sound_name.."/gasmask_hurt")
                --else
                    local sound_event = path..sound_name.."/hurt"
                    inst.SoundEmitter:PlaySound(inst.hurtsoundoverride or sound_event)
                --end
            end
            inst.components.locomotor:Stop()  

            inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_SNEEZE"))        
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        }, 
        
        timeline =
        {
            TimeEvent(10*FRAMES, function(inst)
                if inst.components.hayfever then
                    inst.components.hayfever:DoSneezeEffects()
                end
                inst.sg:RemoveStateTag("busy")
            end),
        },        
               
    },
    

    State{
        name = "hit",
        tags = {"busy", "canrotate"},

        onenter = function(inst)
            --inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")
            inst.AnimState:PlayAnimation("hit")
            inst:ClearBufferedAction()

            --[[
            if inst.prefab ~= "wes" then
                local sound_name = inst.soundsname or inst.prefab
                local path = inst.talker_path_override or "dontstarve/characters/"
                local sound_event = path..sound_name.."/hurt"
                inst.SoundEmitter:PlaySound(inst.hurtsoundoverride or sound_event)
            end
            ]]
            local boat = inst.components.driver.vehicle
            if TUNING.DO_SEA_DAMAGE_TO_BOAT and boat then
                local fx = (boat.components.drivable and boat.components.drivable.hitfx) or "boat_hit_fx"
                SpawnPrefab(fx).Transform:SetPosition(inst:GetPosition():Get())
            end

            inst.components.locomotor:Stop()
        end,


        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
        timeline =
        {
            TimeEvent(3*FRAMES, function(inst)
                inst.sg:RemoveStateTag("busy")
            end),
        },
    },

    State{
        name = "powerup",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("powerup")
            inst.components.health:SetInvincible(true)
        end,
        
        onexit = function(inst)
            inst.components.health:SetInvincible(false)
            
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
    State{
        name = "powerdown",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("powerdown")
            inst.components.health:SetInvincible(true)
        end,
        
        onexit = function(inst)
            inst.components.health:SetInvincible(false)
            
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "electrocute",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("shock")
            inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
            inst.fx = SpawnPrefab("shock_fx")

            inst.fx.Transform:SetRotation(inst.Transform:GetRotation())

            local pos = inst:GetPosition()
            inst.fx.Transform:SetPosition(pos.x, pos.y, pos.z)
            if inst.prefab ~= "wx78" then
                inst.Light:Enable(true)
            end
            if inst.prefab ~= "wes" then
                local sound_name = inst.soundsname or inst.prefab
                local path = inst.talker_path_override or "dontstarve/characters/"
                local equippedHat = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
                if equippedHat and equippedHat:HasTag("muffler") then
                    inst.SoundEmitter:PlaySound(path..sound_name.."/gasmask_hurt")
                else
                    local sound_event = path..sound_name.."/hurt"
                    inst.SoundEmitter:PlaySound(inst.hurtsoundoverride or sound_event)
                end
            end
        end,

        onexit = function(inst)
            if inst.prefab ~= "wx78" then
                inst.Light:Enable(false)
            end
            inst.AnimState:ClearBloomEffectHandle()
            inst.fx:Remove()
        end,
        
        events=
        {
            EventHandler("animover", function(inst)
                local equipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if equipped and equipped:HasTag("telebrella") then
                    inst.sg:GoToState("telebrella_finish")
                else
                    inst.sg:GoToState("electrocute_pst")                
                end
            end),
        },
    },
    State{
        name = "electrocute_pst",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("shock_pst")
        end,
        
        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle") 
            end),
        },
    },


    State{
        name = "jumpboatland",
        tags = {"doing", "busy", "canrotate", "invisible"},

        onenter = function(inst)
            inst.components.health:SetInvincible(true)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("landboat")
            local boat = inst.components.driver.vehicle 
            if boat.landsound then
                inst.SoundEmitter:PlaySound(boat.landsound)
            end
        end,

        onexit = function(inst)
            inst.components.health:SetInvincible(false)
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },


    State{
        name = "jumpboatstart",
        tags = {"doing", "busy", "canrotate"},

        onenter = function(inst)
            inst:PerformBufferedAction()
            inst.components.health:SetInvincible(true)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(false)
            inst.AnimState:PlayAnimation("jumpboat")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/boatjump_whoosh")
            local BA = inst:GetBufferedAction()
            inst.sg.statemem.startpos = inst:GetPosition()
            inst.sg.statemem.targetpos = (BA.target and BA.target:GetPosition()) or BA.pos

            RemovePhysicsColliders(inst)
        end,

        onexit = function(inst)
            --This shouldn't actually be reached
            inst.components.health:SetInvincible(false)
            ChangeToCharacterPhysics(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        end,

        timeline =
        {
            TimeEvent(7*FRAMES, function(inst)
                inst:ForceFacePoint(inst.sg.statemem.targetpos:Get())
                local dist = inst:GetPosition():Dist(inst.sg.statemem.targetpos)
                local speed = dist / (18/30)
                inst.Physics:SetMotorVelOverride(1 * speed, 0, 0)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.components.health:SetInvincible(false)
                inst.Transform:SetPosition(inst.sg.statemem.targetpos:Get())
                inst.Physics:Stop()
                ChangeToCharacterPhysics(inst)
                inst.components.locomotor:Stop()
                inst.components.locomotor:EnableGroundSpeedMultiplier(true)
            end),
        },
    },

    State{
        name="item_in",
        tags = {"canrotate", "idle"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("item_in")
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },

    State{
        name="item_out",
        tags = {"canrotate", "idle"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("item_out")
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },

    State{
        name="item_hat",
        tags = {"canrotate", "idle"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("item_hat")
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },

    State{
        name = "toolbroke",
        tags = {"canrotate", "busy"},
        onenter = function(inst, tool)
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/use_break")
            inst.AnimState:Hide("ARM_carry") 
            inst.AnimState:Show("ARM_normal") 
            local brokentool = SpawnPrefab("brokentool")
            brokentool.Transform:SetPosition(inst.Transform:GetWorldPosition() )
            inst.sg.statemem.tool = tool
            inst.toolwantstobreak = nil
        end,
        
        onexit = function(inst)
            local sameTool = inst.components.inventory:FindItem(function(item)
                return item.prefab == (inst.sg.statemem.tool and inst.sg.statemem.tool.prefab)
            end)
            if sameTool then
                inst.components.inventory:Equip(sameTool)
            end

            if inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                inst.AnimState:Show("ARM_carry") 
                inst.AnimState:Hide("ARM_normal")
            end

        end,
        
        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end ),
        },
    },

    State{
        name = "tool_slip",
        tags = {"busy"},
        onenter = function(inst, tool)
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/tool_slip")
            inst.AnimState:Hide("ARM_carry")
            inst.AnimState:Show("ARM_normal")
            local brokentool = SpawnPrefab("brokentool")
            brokentool.Transform:SetPosition(inst.Transform:GetWorldPosition() )
            inst.sg.statemem.tool = tool
        end,

        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end ),
        },
    },

    State{
        name = "curepoison",
        tags ={"busy"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("quick_eat")

        end,

        timeline=
        {
            TimeEvent(12*FRAMES, function(inst)
                inst:PerformBufferedAction()
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/player_drink")
                inst.sg:RemoveStateTag("busy")
            end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("celebrate") end),
        },
    },

    State{
        name = "celebrate",
        tags ={"idle"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("research")
        end,

        timeline = 
        {
            TimeEvent( 8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/antivenom_whoosh") end),
            TimeEvent(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/heelclick") end),
            TimeEvent(21*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/heelclick") end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

   State{
        name = "talk",
        tags = {"idle", "talking"},

        onenter = function(inst, noanim)
            inst.components.locomotor:Stop()
            if not noanim then
                inst.AnimState:PlayAnimation("dial_loop", true)
            end

            local sound_name = inst.soundsname or inst.prefab
            local path = inst.talker_path_override or "dontstarve/characters/"
            local equippedHat = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)

            if equippedHat and equippedHat:HasTag("muffler") then
                inst.SoundEmitter:PlaySound(path..sound_name.."/gasmask_talk", "talk")
                
            elseif inst.talksoundoverride then
                 inst.SoundEmitter:PlaySound(inst.talksoundoverride, "talk")
            else
                local sound_name = inst.soundsname or inst.prefab
                local path = inst.talker_path_override or "dontstarve/characters/"
                inst.SoundEmitter:PlaySound(path..sound_name.."/talk_LP", "talk")
            end

            inst.sg:SetTimeout(1.5 + math.random()*.5)
        end,

        ontimeout = function(inst)
            inst.SoundEmitter:KillSound("talk")
            if inst.components.talker.endspeechsound then
                inst.SoundEmitter:PlaySound(inst.components.talker.endspeechsound)
            end            
            inst.sg:GoToState("idle")
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("talk")
            if inst.components.talker.endspeechsound then
                inst.SoundEmitter:PlaySound(inst.components.talker.endspeechsound)
            end               
        end,

        events=
        {
            EventHandler("donetalking", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "mime",
        tags = {"idle", "talking"},
        
        onenter = function(inst)
            inst.components.locomotor:Stop()
            
            
            for k = 1, math.random(2,3) do
                local aname = "mime" .. tostring(math.random(8))
                if k == 1 then
                    inst.AnimState:PlayAnimation(aname, false)
                else
                    inst.AnimState:PushAnimation(aname, false)
                end
            end
        end,
        
        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },           


    State{ name = "hammer_start",
        tags = {"prehammer", "working"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pickaxe_pre")
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("hammer") end),
        },
    },

    State{
        name = "hammer",
        tags = {"prehammer", "hammering", "working"},
        onenter = function(inst)
            inst.sg.statemem.action = inst:GetBufferedAction()
            inst.AnimState:PlayAnimation("pickaxe_loop")
        end,

        timeline=
        {
            TimeEvent(9*FRAMES, function(inst)
                inst:PerformBufferedAction()
                inst.sg:RemoveStateTag("prehammer")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/hit")
            end),

            TimeEvent(14*FRAMES, function(inst)

                if (TheInput:IsControlPressed(CONTROL_SECONDARY) or
                   TheInput:IsControlPressed(CONTROL_ACTION) or TheInput:IsControlPressed(CONTROL_CONTROLLER_ALTACTION)) and
                    inst.sg.statemem.action and
                    inst.sg.statemem.action.target and
                    inst.sg.statemem.action.target:IsActionValid(inst.sg.statemem.action.action, true) and 
                    inst.sg.statemem.action.target.components.workable then
                        inst:ClearBufferedAction()
                        inst:PushBufferedAction(inst.sg.statemem.action)
                end
            end),

        },

        events=
        {
            EventHandler("unequip", function(inst) inst.sg:GoToState("idle") end ),
            EventHandler("animover", function(inst) 
                inst.AnimState:PlayAnimation("pickaxe_pst") 
                inst.sg:GoToState("idle", true)
            end ),
        },
    },

    State{
        name = "cannon",
        tags = {"busy", "boating"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("give")
        end,

        timeline =
        {
            TimeEvent(13*FRAMES, function(inst) 
                --Light Cannon
                inst.sg:RemoveStateTag("abouttoattack")
                inst:PerformBufferedAction()
            end),
            TimeEvent(15*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

State{
        name = "amulet_rebirth",
        tags = {"busy"},
        onenter = function(inst)
            GetClock():MakeNextDay()
            inst.components.playercontroller:Enable(false)
            inst.AnimState:PlayAnimation("amulet_rebirth")
            TheCamera:SetDistance(14)
            inst.HUD:Hide()
            inst.AnimState:OverrideSymbol("FX", "player_amulet_resurrect", "FX")
        end,
        
        onexit= function(inst)
            inst.components.hunger:SetPercent(2/3)
            inst.components.health:Respawn(TUNING.RESURRECT_HEALTH)
            
            if inst.components.sanity then
                inst.components.sanity:SetPercent(.5)
            end
            
            local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
            if item and item.prefab == "amulet" then
                item = inst.components.inventory:RemoveItem(item)
                if item then
                    item:Remove()
                    item.persists = false
                end
            end
            --SaveGameIndex:SaveCurrent()
            inst.HUD:Show()
            TheCamera:SetDefault()
            inst.components.playercontroller:Enable(true)
            inst.AnimState:ClearOverrideSymbol("FX")
            
        end,
        
        timeline =
        {
            TimeEvent(0*FRAMES, function(inst)
                inst.stafflight = SpawnPrefab("staff_castinglight")
                local pos = inst:GetPosition()
                local colour = {150/255, 46/255, 46/255}
                inst.stafflight.Transform:SetPosition(pos.x, pos.y, pos.z)
                inst.stafflight.setupfn(inst.stafflight, colour, 1.7, 1)           

            end),

            TimeEvent(0, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/rebirth_amulet_raise") end),
            TimeEvent(60*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/rebirth_amulet_poof") end),
        
            TimeEvent(80*FRAMES, function(inst)
                local pos = Vector3(inst.Transform:GetWorldPosition())
                local ents = TheSim:FindEntities(pos.x,pos.y,pos.z, 10)
                for k,v in pairs(ents) do
                    if v ~= inst and v.components.sleeper then
                        v.components.sleeper:GoToSleep(20)
                    end
                end
                
                
            end),
        },        
                   
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },    

}

--CommonStates.AddIdle(states)
--CommonStates.AddFrozenStates(states)

return StateGraph("wilsonboating", states, events, "idle", actionhandlers)
