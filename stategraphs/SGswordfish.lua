
require("stategraphs/commonstates")

local actionhandlers = 
{
   -- ActionHandler(ACTIONS.EAT, "eat"),
    --ActionHandler(ACTIONS.GOHOME, "action"),
}


local function GoToLocoState(inst, state)
    if inst:IsLocoState(state) then
        return true
    end
    inst.sg:GoToState("goto"..string.lower(state), {endstate = inst.sg.currentstate.name})
end

local events=
{
   CommonHandlers.OnSleep(),
   CommonHandlers.OnFreeze(),

   EventHandler("locomote", 
        function(inst) 
            if not inst.sg:HasStateTag("idle") and not inst.sg:HasStateTag("moving") then return end
            
            if not inst.components.locomotor:WantsToMoveForward() then
                if not inst.sg:HasStateTag("idle") then
                    if not inst.sg:HasStateTag("running") then
                        inst.sg:GoToState("idle")
                    end
                        inst.sg:GoToState("idle")
                end
            elseif inst.components.locomotor:WantsToRun() then
                if not inst.sg:HasStateTag("running") then
                    inst.sg:GoToState("run")
                end
            else
                if not inst.sg:HasStateTag("swimming") then
                    inst.sg:GoToState("swimming")
                end
            end
        end),

    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("attacked", function(inst) if not inst.components.health:IsDead() and not inst.sg:HasStateTag("attack") then inst.sg:GoToState("hit") end end),
    EventHandler("doattack", function(inst, data) if not inst.components.health:IsDead() and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then inst.sg:GoToState("attack", data.target) end end),
}

local states=
{
    State{
        name = "gotobelow",
        tags = {"busy"},
        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("submerge")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/water_submerge_med")
            inst.Physics:Stop()
            inst.sg.statemem.endstate = data.endstate
        end,

        onexit = function(inst)
            inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
            inst.Transform:SetNoFaced()
            inst:SetLocoState("below")
        end,

        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState(inst.sg.statemem.endstate)
            end),
        },
    },

    State{
        name = "gotoabove",
        tags = {"busy"},
        onenter = function(inst, data)
            inst.Physics:Stop()
            inst.AnimState:SetOrientation(ANIM_ORIENTATION.Default)
            inst.Transform:SetFourFaced()
            inst.AnimState:PlayAnimation("emerge")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/water_emerge_med")
            inst.sg.statemem.endstate = data.endstate

        end,

        onexit = function(inst)
            inst:SetLocoState("above")
        end,

        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState(inst.sg.statemem.endstate)
            end),
        },
    },

    State{       
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            local anim = "shadow"
            if inst.IsLocoState(inst, "above") then
                anim = "fishmed"
            end

            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation(anim, true)
            else
                inst.AnimState:PlayAnimation(anim, true)
            end                                
        end,
    },

    State{
        name = "eat",
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("shadow_hooked_loop", true)
            inst.sg:SetTimeout(2+math.random()*4)
        end,
        
        ontimeout = function(inst)
            inst:PerformBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },  
    
    State{
        name = "swimming",
        tags = {"moving", "canrotate", "swimming"},
        
        onenter = function(inst)
            if GoToLocoState(inst, "below") then
                inst.AnimState:PlayAnimation("shadow_flap_loop", true)
                inst.components.locomotor:WalkForward()
            end
        end,
        
        onupdate = function(inst)
            if not inst.components.locomotor:WantsToMoveForward() then
                inst.sg:GoToState("idle")
            end
        end,
    },

    State{
        name = "run",
        tags = {"moving", "running", "canrotate"},
        
        onenter = function(inst)
            if GoToLocoState(inst, "above") then
                inst.AnimState:PlayAnimation("fishmed", true)
                inst.components.locomotor:RunForward()
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/swordfish/swim", "run")
            end
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("run")
        end,
    },    
    
    State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            if GoToLocoState(inst, "above") then
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/swordfish/death")
                inst:Hide()
                inst.Physics:Stop()
                RemovePhysicsColliders(inst)
                inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
            end
        end,

    },

    State{
        name = "hit",
        tags = {"busy", "hit"},

        onenter = function(inst, cb)
            if GoToLocoState(inst, "above") then
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation("hit")
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/swordfish/hit")
            end
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "attack",
        tags = {"attack", "busy"},

        onenter = function(inst, target)
            if GoToLocoState(inst, "above") then
                inst.sg.statemem.target = target
                inst.Physics:Stop()
                inst.components.combat:StartAttack()
                inst.AnimState:PlayAnimation("atk_pre")
                inst.AnimState:PushAnimation("atk", false)
            end
        end,

        timeline =
        {
            TimeEvent( 2*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/swordfish/attack_pre") end),
            TimeEvent( 6*FRAMES, function(inst)
                if inst.components.combat.target then 
                    inst:ForceFacePoint(inst.components.combat.target:GetPosition()) 
                end 
            end),
            TimeEvent(11*FRAMES, function(inst)
                if inst.components.combat.target then 
                    inst:ForceFacePoint(inst.components.combat.target:GetPosition()) 
                end 
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/swordfish/attack")
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/swordfish_sword")
            end),
            TimeEvent(16*FRAMES, function(inst)
                if inst.components.combat.target then 
                    inst:ForceFacePoint(inst.components.combat.target:GetPosition()) 
                end 
                inst.components.combat:DoAttack(inst.sg.statemem.target)
            end),
        },

        events =
        {
            EventHandler("animqueueover",  function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "sleep",
        tags = {"busy", "sleeping"},

        onenter = function(inst)
            if GoToLocoState(inst, "above") then
                inst.components.locomotor:StopMoving()
                inst.AnimState:PlayAnimation("sleep_pre")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("sleeping") end ),
            EventHandler("onwakeup", function(inst) inst.sg:GoToState("wake") end),
        },
    },

    State{

        name = "sleeping",
        tags = {"busy", "sleeping"},

        onenter = function(inst)
            if GoToLocoState(inst, "above") then
                inst.AnimState:PlayAnimation("sleep_loop")
            end
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("sleeping") end ),
            EventHandler("onwakeup", function(inst) inst.sg:GoToState("wake") end),
        },
    },

    State{
        name = "wake",
        tags = {"busy", "waking"},

        onenter = function(inst)
            if GoToLocoState(inst, "above") then
                inst.components.locomotor:StopMoving()
                inst.AnimState:PlayAnimation("sleep_pst")
                if inst.components.sleeper and inst.components.sleeper:IsAsleep() then
                    inst.components.sleeper:WakeUp()
                end
            end
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },

    State{
        name = "frozen",
        tags = {"busy", "frozen"},

        onenter = function(inst)
            if GoToLocoState(inst, "above") then
                inst.components.locomotor:StopMoving()
                inst.AnimState:PlayAnimation("frozen", true)
                inst.SoundEmitter:PlaySound("dontstarve/common/freezecreature")
                inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
            end
        end,

        onexit = function(inst)
            inst.AnimState:ClearOverrideSymbol("swap_frozen")
        end,

        events=
        {
            EventHandler("onthaw", function(inst) inst.sg:GoToState("thaw") end ),
        },
    },

    State{
        name = "thaw",
        tags = {"busy", "thawing"},

        onenter = function(inst)
            if GoToLocoState(inst, "above") then
                inst.components.locomotor:StopMoving()
                inst.AnimState:PlayAnimation("frozen_loop_pst", true)
                inst.SoundEmitter:PlaySound("dontstarve/common/freezethaw", "thawing")
                inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
            end
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("thawing")
            inst.AnimState:ClearOverrideSymbol("swap_frozen")
        end,

        events =
        {
            EventHandler("unfreeze", function(inst)
                if inst.sg.sg.states.hit then
                    inst.sg:GoToState("hit")
                else
                    inst.sg:GoToState("idle")
                end
            end ),
        },
    },
}

  
return StateGraph("swordfish", states, events, "idle", actionhandlers)
