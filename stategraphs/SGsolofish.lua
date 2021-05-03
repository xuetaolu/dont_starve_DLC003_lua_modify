
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
    CommonHandlers.OnLocomote(true,true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
        
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("attacked", function(inst) if not inst.components.health:IsDead() and not inst.sg:HasStateTag("attack") then inst.sg:GoToState("hit") end end),
}

local states=
{
    

    State{
        name = "gotobelow",
        tags = {"busy"},
        onenter = function(inst, data)

            local splash = SpawnPrefab("splash_water_drop")
            local pos = inst:GetPosition()
            splash.Transform:SetPosition(pos.x, pos.y, pos.z)

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

            local splash = SpawnPrefab("splash_water_drop")
            local pos = inst:GetPosition()
            splash.Transform:SetPosition(pos.x, pos.y, pos.z)
            
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
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation("shadow", true)
            else
                inst.AnimState:PlayAnimation("shadow", true)
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
        
        ontimeout= function(inst)
            inst:PerformBufferedAction()
            inst.sg:GoToState("idle")
        end,
    },  
    
    State{
        name = "walk_start",
        tags = {"moving", "canrotate", "swimming"},
        
       
        onenter = function(inst) 
            if GoToLocoState(inst, "below") then
                inst.AnimState:PlayAnimation("shadow_flap_loop")
                inst.components.locomotor:WalkForward()
            end
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),        
        },
    },

    State{
        name = "walk",
        tags = {"moving", "canrotate", "swimming"},
        
       
        onenter = function(inst) 
            if GoToLocoState(inst, "below") then
                inst.AnimState:PlayAnimation("shadow_flap_loop")
                inst.components.locomotor:WalkForward()
            end
        end,     

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),        
        },
    },

    State{
        name = "walk_stop",
        tags = {"moving", "canrotate", "swimming"},
        
       
        onenter = function(inst) 
            inst.sg:GoToState("idle")
        end,
    },

    State{
        name = "run_start",
        tags = {"moving", "running", "canrotate"},
        
        onenter = function(inst) 
            if GoToLocoState(inst, "above") then
                inst.AnimState:PlayAnimation("fishmed", true)
                inst.components.locomotor:RunForward()
                if not inst.SoundEmitter:PlayingSound("runsound") then
                    inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/water_swimemerged_med_LP", "runsound")
                end
            end
        end,
        
        timeline=
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/water_emerge_med") end),
            TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Dogfish/emerge") end),
        },
            
        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),        
        },
    },

    State{
        name = "run",
        tags = {"moving", "running", "canrotate"},
        
        onenter = function(inst)
            if GoToLocoState(inst, "above") then
                inst.components.locomotor:RunForward()
                inst.AnimState:PlayAnimation("fishmed")
                if not inst.SoundEmitter:PlayingSound("runsound") then
                    inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/water_swimemerged_med_LP", "runsound")
                end
            end
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),
        },

        onexit = function(inst)
            -- inst.SoundEmitter:KillSound("runsound")
        end,
    },

    State{
        name = "run_stop",
        tags = {"moving", "running", "canrotate"},
        
        onenter = function(inst) 
            if GoToLocoState(inst, "below") then
                inst.AnimState:PlayAnimation("shadow_flap_loop")
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/water_submerge_med")
                inst.SoundEmitter:KillSound("runsound")
            end
        end,
        
        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),        
        },
    },
    
    State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Dogfish/death")
            inst:Hide()
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)        
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))            
        end,

    },

    State{
        name = "hit",
        tags = {"busy", "hit"},

        onenter = function(inst, cb)
            if GoToLocoState(inst, "above") then
                inst.Physics:Stop()
                inst.AnimState:PlayAnimation("hit")
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Dogfish/hit")
            end
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
}

CommonStates.AddSleepStates(states, 
{
    starttimeline = 
    {
        TimeEvent(0*FRAMES, function(inst)
            GoToLocoState(inst, "above")
        end)
    },
})

CommonStates.AddFrozenStates(states, 
{
    frozentimeline = 
    {
        TimeEvent(FRAMES*1, function(inst)  
            inst.AnimState:SetOrientation(ANIM_ORIENTATION.Default )
            inst.Transform:SetFourFaced()
        end)
    },
})
  
return StateGraph("solofish", states, events, "idle", actionhandlers)
