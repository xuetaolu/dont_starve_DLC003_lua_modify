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

    ActionHandler(ACTIONS.MOUNT, "jumponboatstart"),

}

local events = 
{
    CommonHandlers.OnLocomote(true, false),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnAttack(),

    EventHandler("landboat", function(inst)
        inst.sg:GoToState("jumpboatland")
    end),
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
        name = "jumponboatstart",
        tags = {"doing", "busy", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(false)
            inst.AnimState:PlayAnimation("jumpboat")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/boatjump_whoosh")
            local BA = inst:GetBufferedAction()
            inst.sg.statemem.startpos = inst:GetPosition()
            inst.sg.statemem.targetpos = BA.target and BA.target:GetPosition()

            RemovePhysicsColliders(inst)
            inst.components.health:SetInvincible(true)
        end,

        onexit = function(inst)
        --This shouldn't actually be reached
            ChangeToCharacterPhysics(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
            inst.components.health:SetInvincible(false)

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
                inst:PerformBufferedAction()
            end),
        },
    },

    State{
        name = "jumpoffboatstart",
        tags = {"doing", "busy", "canrotate"},

        onenter = function(inst, pos)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(false)
            inst.AnimState:PlayAnimation("jumpboat")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/boatjump_whoosh")
            inst.sg.statemem.startpos = inst:GetPosition()
            inst.sg.statemem.targetpos = pos

            RemovePhysicsColliders(inst)
            inst.components.health:SetInvincible(true)
        end,

        onexit = function(inst)
        --This shouldn't actually be reached
            ChangeToCharacterPhysics(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
            inst.components.health:SetInvincible(false)
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
                inst.Transform:SetPosition(inst.sg.statemem.targetpos:Get())
                inst.Physics:Stop()
                inst.components.health:SetInvincible(false)
                inst.sg:GoToState("jumpoffboatland")
            end),
        },
    },

    State{
        name = "jumpoffboatland",
        tags = {"doing", "busy", "canrotate"},

        onenter = function(inst)
            inst.components.health:SetInvincible(true)
            inst.Physics:Stop()
            inst.AnimState:PushAnimation("land", false)
            PlayFootstep(inst)
        end,

        onexit = function(inst)
            inst.components.health:SetInvincible(false)
        end,

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst:PerformBufferedAction()
                inst.sg:GoToState("idle")
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
        name = "hack_start",
        tags = {"prehack", "working"},
        onenter = function(inst)
            inst.equipfn(inst, inst.items["MACHETE"])
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("chop_pre")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("hack") end),
        },
    },
    
    State{
        name = "hack",
        tags = {"prehack", "hacking", "working"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("chop_loop")
        end,

        timeline=
        {
            TimeEvent(9*FRAMES, function(inst) 
                inst:PerformBufferedAction() 
                inst.sg:RemoveStateTag("prehack") 
            end),
        },
        
        events=
        {
            EventHandler("animover", function(inst)
                inst.AnimState:PlayAnimation("chop_pst") 
                inst.sg:GoToState("idle", true)
            end ),            
        },        
    },

}

return StateGraph("shadowmaxwell", states, events, "idle", actionhandlers)