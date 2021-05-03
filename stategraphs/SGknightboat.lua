require("stategraphs/commonstates")

local actionhandlers = {}

local events =
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
}

local states=
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                -- inst.AnimState:PushAnimation("idle_loop", true)
            else
                inst.AnimState:PlayAnimation("idle_loop", true)
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/knight_steamboat/idle")
            end
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "taunt",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/knight_steamboat/taunt")
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "walk_start",
        tags = {"moving", "canrotate"},

        onenter = function(inst)
            inst.components.rowboatwakespawner:StartSpawning()
            inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("walk_pre")
        end,

        onexit = function(inst)
            inst.components.rowboatwakespawner:StopSpawning()
        end,

        events =
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),        
        },
    },

    State{
        name = "walk",
        tags = {"moving", "canrotate"},

        onenter = function(inst)
            inst.components.rowboatwakespawner:StartSpawning()
            inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("walk_loop", true)
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/knight_steamboat/move", "walk_loop")
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("walk_loop")
            inst.components.rowboatwakespawner:StopSpawning()
        end,

        -- events =
        -- {   
        --     EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),        
        -- },
    },

    State{
        name = "walk_stop",
        tags = {"canrotate"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("walk_pst")
            inst.components.locomotor:StopMoving()
            inst.components.rowboatwakespawner:StartSpawning()
        end,

        onexit = function(inst)
            inst.components.rowboatwakespawner:StopSpawning()
        end,

        events =
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),        
        },
    },
}

CommonStates.AddSleepStates(states,
{
    sleeptimeline = 
    {
        TimeEvent( 0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/knight_steamboat/sleep") end),
    }
})
CommonStates.AddFrozenStates(states)
CommonStates.AddCombatStates(states,
{
    attacktimeline = 
    {
        TimeEvent( 0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/knight_steamboat/attack") end),
        TimeEvent(11*FRAMES, function(inst) inst.components.combat:DoAttack() end),
        TimeEvent(31*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/knight_steamboat/cannon") end),
    },
    deathtimeline = 
    {
        TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/knight_steamboat/death") end),
        TimeEvent(35*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/knight_steamboat/death_voice") end),
        TimeEvent(72*FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/knight_steamboat/sinking_bubbles")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/knight_steamboat/sinking_parts")
        end),
    },
})


return StateGraph("knightboat", states, events, "idle", actionhandlers)
