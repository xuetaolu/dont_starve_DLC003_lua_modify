require("stategraphs/commonstates")

local actionhandlers = 
{
}

local function onattack(inst, data)
    if inst.components.health:GetPercent() > 0 and
    (inst.sg:HasStateTag("hit") or not
    inst.sg:HasStateTag("busy")) then
        local dist = inst:GetDistanceSqToInst(data.target)

        if dist > TUNING.PALMTREEGUARD_MELEE * TUNING.PALMTREEGUARD_MELEE then
            --Throw
            inst:SetRange()
            inst.sg:GoToState("throw_pre", data.target)
        else
            --Melee
            inst:SetMelee()
            inst.sg:GoToState("attack", data.target) 
        end
    end
end

local events=
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnLocomote(false,true),
    CommonHandlers.OnFreeze(),
    EventHandler("doattack", onattack),
    EventHandler("attacked", function(inst) if not inst.components.health:IsDead() and not
        inst.sg:HasStateTag("attack") and not
        inst.sg:HasStateTag("waking") and not
        inst.sg:HasStateTag("sleeping") and 
        (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("frozen")) then
            inst.sg:GoToState("hit") 
        end
    end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("gotosleep", function(inst) inst.sg:GoToState("sleeping") end),
    EventHandler("onwakeup", function(inst) inst.sg:GoToState("wake") end),

    EventHandler("onignite", function(inst) inst.sg:GoToState("panic") end),
}

local states=
{
    State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/death")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/death_drop")
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))            
        end,
        
    },
    
    State{
        name = "tree",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("tree_idle", true)
        end,
    },   

    State{
        name = "panic",
        tags = {"busy"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("panic_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("panic_loop") end),
            EventHandler("onextinguish", function(inst) inst.sg:GoToState("panic_pst") end),
        }
    },

    State{
        name = "panic_loop",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("panic_loop")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/panic")
        end,

        timeline = {
            TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/tree_movement") end),
            TimeEvent(9*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/footstep") end),
            TimeEvent(18*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/footstep") end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("panic") end),
            EventHandler("onextinguish", function(inst) inst.sg:GoToState("panic_pst") end),
        },
    },

    State{
        name = "panic_pst",
        tags = {"busy"},
        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("panic_post")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
        }
    },
    
	State{
        name = "attack",
        tags = {"attack", "busy"},
        
        onenter = function(inst, target)
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk")
            inst.sg.statemem.target = target
        end,
        
        timeline=
        {
			TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/attack") end),
            TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/attack_swipe") end),
			TimeEvent(22*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/tree_movement") end),
            TimeEvent(25*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) end),
            TimeEvent(26*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "throw_pre",
        tags = {"attack", "busy"},
        
        onenter = function(inst, target)
            inst.Physics:Stop()
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("pluck")
            inst.sg.statemem.target = target
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/pluck")
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("throw", inst.sg.statemem.target) end),
        },
    },

    State{
        name = "throw",
        tags = {"attack", "busy"},
        
        onenter = function(inst, target)
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("throw_pre")
            inst.AnimState:PushAnimation("throw", false)
            inst.sg.statemem.target = target
        end,
        
        timeline=
        {
            TimeEvent(25*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) end),
            TimeEvent(26*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),

            TimeEvent(00*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/tree_movement") end),
            TimeEvent(05*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/attack") end),
            TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/attack_swipe") end),
            TimeEvent(22*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/tree_movement") end),
            TimeEvent(25*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/coconut_throw") end),
        },
        
        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },  
    
    
	State{
        name = "hit",
        tags = {"hit", "busy"},
        
        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/hit")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
        
        timeline=
        {
            TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/tree_movement") end),
        },
        
    },      
    
    State{
        name = "sleeping",
        tags = {"sleeping", "busy"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("transform_tree", false)
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/transform_out")
            inst.DynamicShadow:Enable(false)
        end,

        onexit = function(inst)
            inst.DynamicShadow:Enable(true)
        end,

        events=
        {
		    EventHandler("attacked", function(inst) if not inst.components.health:IsDead() then inst.sg:GoToState("wake") end end),
        },
        
        timeline=
        {
            TimeEvent(17*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/tree_movement") end),
            TimeEvent(31*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/tree_movement") end),
        },
        
    },
    
    State{
        name = "spawn",
        tags = {"waking", "busy"},
        
        onenter = function(inst, start_anim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("transform_ent")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/transform_in")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },

        timeline=
        {
            TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/tree_movement") end),
            TimeEvent(25*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/tree_movement") end),
            TimeEvent(41*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/footstep") end),
            TimeEvent(49*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/footstep") end),
            TimeEvent(53*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/transform_VO") end),
        },
        
    },
    
    State{
        name = "wake",
        tags = {"waking", "busy"},
        
        onenter = function(inst, start_anim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("transform_ent_mad")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/transform_in")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },

        timeline=
        {
            TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/tree_movement") end),
            TimeEvent(25*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/tree_movement") end),
            TimeEvent(26*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/coconut_throw") end),
            TimeEvent(33*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/attack") end),
            TimeEvent(41*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/footstep") end),
            TimeEvent(46*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/attack") end),
            TimeEvent(49*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/footstep") end),
            TimeEvent(53*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/transform_VO") end),
        },
        
    },

    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_loop")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/idle")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
}

CommonStates.AddWalkStates(
    states,
    {
		starttimeline =
		{
            TimeEvent(0*FRAMES, function(inst) inst.Physics:Stop() end),
            TimeEvent(11*FRAMES, function(inst) inst.components.locomotor:WalkForward() end),
            TimeEvent(11*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/tree_movement") end),
            TimeEvent(17*FRAMES, function(inst) inst.Physics:Stop() end),
		},
        walktimeline = 
        { 
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/walk_VO") end),
            TimeEvent(18*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/tree_movement") end),
            TimeEvent(17*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/footstep") end),
            TimeEvent(51*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/tree_movement") end),
            TimeEvent(52*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/footstep") end),
        },
        endtimeline=
        {
            TimeEvent(2*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/tree_movement") end),
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/palm_tree_guard/footstep") end),
        },
    })

CommonStates.AddFrozenStates(states)

return StateGraph("treeguard", states, events, "idle", actionhandlers)