require("stategraphs/commonstates")

local actionhandlers =
{    
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

    ActionHandler(ACTIONS.MOUNT, "mount"),
    ActionHandler(ACTIONS.DISMOUNT, "dismount"),
}

local events = 
{
   EventHandler("locomote", function(inst)
        local is_attacking = inst.sg:HasStateTag("attack")
        local is_busy = inst.sg:HasStateTag("busy")
        if is_attacking or is_busy then return end
        local is_moving = inst.sg:HasStateTag("moving")
        local is_running = inst.sg:HasStateTag("running")
        local should_move = inst.components.locomotor:WantsToMoveForward()
        local should_run = inst.components.locomotor:WantsToRun()
        local hasSail = inst.components.driver:GetIsSailing()
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
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnAttack(),
}

local states =
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
        tags = {"canrotate", "boating"},
        onenter = function(inst)
            inst.components.driver:OnDismount(false, nil, true)
        end,
    },

     State{
        name = "dismount",
        onenter = function(inst)
            inst:PerformBufferedAction()
        end, 

        onexit = function(inst)
        end, 
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
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst, pushanim)    
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_loop", true)
        end,
    },

    State{
        name = "run_start",
        tags = {"moving", "running", "canrotate"},
        
        onenter = function(inst)
			inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("run_pre")
            inst.sg.mem.foosteps = 0
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),        
        },
        
        timeline=
        {        
            TimeEvent(4*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_step")
            end),
        },        
        
    },

    State{
        name = "run",
        tags = {"moving", "running", "canrotate"},
        
        onenter = function(inst) 
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("run_loop")
            
        end,
        
        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        timeline=
        {
            TimeEvent(7*FRAMES, function(inst)
				inst.sg.mem.foosteps = inst.sg.mem.foosteps + 1
                inst.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_step")
            end),
            TimeEvent(15*FRAMES, function(inst)
				inst.sg.mem.foosteps = inst.sg.mem.foosteps + 1
                inst.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_step")
            end),
        },
        
        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),        
        },
    },
    
    State{
    
        name = "run_stop",
        tags = {"canrotate", "idle"},
        
        onenter = function(inst) 
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("run_pst")
        end,
        
        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),        
        },
        
    },

    State{
        name = "attack",
        tags = {"attack", "notalking", "abouttoattack", "busy"},
        
        onenter = function(inst)
            inst.equipfn(inst, inst.items["SWORD"])        

            inst.sg.statemem.target = inst.components.combat.target
            inst.components.combat:StartAttack()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_nightsword")
            
            if inst.components.combat.target then
                if inst.components.combat.target and inst.components.combat.target:IsValid() then
                    inst:FacePoint(Point(inst.components.combat.target.Transform:GetWorldPosition()))
                end
            end
            
        end,
        
        timeline=
        {
            TimeEvent(8*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) inst.sg:RemoveStateTag("abouttoattack") end),
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
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:Hide("swap_arm_carry")
            inst.AnimState:PlayAnimation("death")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst:DoTaskInTime(1, function() 
                    SpawnPrefab("statue_transition").Transform:SetPosition(inst:GetPosition():Get())
                    SpawnPrefab("statue_transition_2").Transform:SetPosition(inst:GetPosition():Get())
                    inst.SoundEmitter:PlaySound("dontstarve/maxwell/shadowmax_despawn")
                    inst:Remove()
                end)
            end ),
        },
    },  
   
    State{
        name = "hit",
        tags = {"busy"},
        
        onenter = function(inst)
            inst:ClearBufferedAction()
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()            
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
        name = "stunned",
        tags = {"busy", "canrotate"},

        onenter = function(inst)
            inst:ClearBufferedAction()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_sanity_pre")
            inst.AnimState:PushAnimation("idle_sanity_loop", true)
            inst.sg:SetTimeout(5)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("idle")
        end,
    },

        State{ name = "chop_start",
        tags = {"prechop", "chopping", "working"},
        onenter = function(inst)
            inst.equipfn(inst, inst.items["AXE"])
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("chop_pre")

        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("chop") end),
        },
    },
    
    State{
        name = "chop",
        tags = {"prechop", "chopping", "working"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("chop_loop")        
        end,

        timeline=
        {
            TimeEvent(5*FRAMES, function(inst) 
                    inst:PerformBufferedAction() 
            end),

            TimeEvent(9*FRAMES, function(inst)
                    inst.sg:RemoveStateTag("prechop")
            end),

            TimeEvent(16*FRAMES, function(inst) 
                inst.sg:RemoveStateTag("chopping")
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
        name = "mine_start",
        tags = {"premine", "working"},
        onenter = function(inst)
            inst.equipfn(inst, inst.items["PICK"])
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("pickaxe_pre")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("mine") end),
        },
    },
    
    State{
        name = "mine",
        tags = {"premine", "mining", "working"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("pickaxe_loop")
        end,

        timeline=
        {
            TimeEvent(9*FRAMES, function(inst) 
                inst:PerformBufferedAction() 
                inst.sg:RemoveStateTag("premine") 
                inst.SoundEmitter:PlaySound("dontstarve/wilson/use_pick_rock")
            end),
            
            -- TimeEvent(14*FRAMES, function(inst)
            --     if  inst.sg.statemem.action and 
            --         inst.sg.statemem.action.target and 
            --         inst.sg.statemem.action.target:IsActionValid(inst.sg.statemem.action.action) and 
            --         inst.sg.statemem.action.target.components.workable then
            --             inst:ClearBufferedAction()
            --             inst:PushBufferedAction(inst.sg.statemem.action)
            --     end
            -- end),            
        },
        
        events=
        {
            EventHandler("animover", function(inst) 
                inst.AnimState:PlayAnimation("pickaxe_pst") 
                inst.sg:GoToState("idle", true)
            end ),            
        },        
    },


    State{
        name = "row_start",
        tags = {"moving", "running", "canrotate", "rowing"},
        
        onenter = function(inst)
            --inst.components.driver:CombineWithVehicle()
            inst.components.locomotor:RunForward()
            local anim = inst.components.driver.vehicle.components.drivable.prerunanimation
            inst.AnimState:PlayAnimation(anim)

            -- unequip whatever the player is holding and store it somewhere 
            local equipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if equipped then 
                equipped:PushEvent("startrowing", {owner = inst})
            end
      
           -- print("currently equipped ", equipped.prefab)
        end,

        onupdate = function(inst)
            inst.components.locomotor:RunForward()
        end,

        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("row") end ),
        },
    },

    State{
        name = "row",
        tags = {"canrotate", "moving", "running", "boating", "rowing"},
        onenter = function(inst)
       
            --inst.components.driver:CombineWithVehicle()
            inst.SoundEmitter:PlaySound(inst.components.driver.vehicle.components.drivable.creaksound)
            inst.SoundEmitter:PlaySound( "dontstarve_DLC002/common/boat_paddle")
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
                if nextState == "dismount" then --Make sure equipped items are pulled back out (only really for items with flames right now)
                    local equipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                    if equipped then
                        equipped:PushEvent("stoprowing", {owner = inst})
                    end
                end 
            end 
        end,

         events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("row") end ),
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

        events=
        {
            EventHandler("animqueueover", function(inst)
                local equipped = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                if equipped then
                    equipped:PushEvent("stoprowing", {owner = inst})
                end
                inst.sg:GoToState("idle")
            end),
            EventHandler("trawlover", function(inst) inst.AnimState:PlayAnimation("trawlover") end),
        },
    },


}

return StateGraph("shadowmaxwell", states, events, "idle", actionhandlers)
