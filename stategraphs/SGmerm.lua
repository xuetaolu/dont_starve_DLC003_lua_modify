require("stategraphs/commonstates")

local actionhandlers = 
{
    ActionHandler(ACTIONS.GOHOME, "gohome"),
    ActionHandler(ACTIONS.EAT, "eat"),
    ActionHandler(ACTIONS.FISH, "fishing_pre"),
}


local events=
{
    CommonHandlers.OnLocomote(true,true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
}

local states=
{
    State{
        name = "fishing_pre",
        tags = {"canrotate", "prefish", "fishing"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("fish_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst:PerformBufferedAction()
                inst.sg:GoToState("fishing")
            end),
        },
    },

    State{
        name = "fishing",
        tags = {"canrotate", "fishing"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("fish_loop", true)
            inst.components.fishingrod:WaitForFish()
        end,

        events =
        {
            EventHandler("fishingnibble", function(inst) inst.sg:GoToState("fishing_nibble") end ),
            EventHandler("fishingloserod", function(inst) inst.sg:GoToState("loserod") end),
        },
    },

    State{
        name = "fishing_pst",
        tags = {"canrotate", "fishing"},
        onenter = function(inst)
            inst.AnimState:PushAnimation("fish_loop", true)
            inst.AnimState:PlayAnimation("fish_pst")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "fishing_nibble",
        tags = {"canrotate", "fishing", "nibble"},
        onenter = function(inst)
            inst.AnimState:PushAnimation("fish_loop", true)
            inst.components.fishingrod:Hook()
        end,

        events = 
        {
            EventHandler("fishingstrain", function(inst) inst.sg:GoToState("fishing_strain") end),
        },
    },

    State{
        name = "fishing_strain",
        tags = {"canrotate", "fishing"},
        onenter = function(inst)
            inst.components.fishingrod:Reel()
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
        tags = {"canrotate", "fishing", "catchfish"},
        onenter = function(inst, build)
            inst.AnimState:PlayAnimation("fishcatch")
            inst.AnimState:OverrideSymbol("fish01", build, "fish01")
        end,
        
        timeline = 
        {
            TimeEvent(10*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Merm/whoosh_throw")
            end), 
            TimeEvent(14*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Merm/spear_water")
            end), 
            TimeEvent(34*FRAMES, function(inst) 
                inst.components.fishingrod:Collect()
            end),
        },

        events =
        {
            EventHandler("animover", function(inst) 
                inst.sg:RemoveStateTag("fishing")
                inst.sg:GoToState("idle")
            end),
        },

        onexit = function(inst)
            inst.AnimState:ClearOverrideSymbol("fish01")
        end,
    }, 
}

CommonStates.AddWalkStates(states,
{
	walktimeline = {
		TimeEvent(0*FRAMES, PlayFootstep ),
		TimeEvent(12*FRAMES, PlayFootstep ),
	},
})
CommonStates.AddRunStates(states,
{
	runtimeline = {
		TimeEvent(0*FRAMES, PlayFootstep ),
		TimeEvent(10*FRAMES, PlayFootstep ),
	},
})

CommonStates.AddSleepStates(states,
{
	sleeptimeline = 
	{
		TimeEvent(35*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/merm/sleep") end ),
	},
})

CommonStates.AddCombatStates(states,
{
    attacktimeline = 
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/merm/attack") end),
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh") end),
        TimeEvent(16*FRAMES, function(inst) inst.components.combat:DoAttack() end),
    },
    hittimeline = 
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/merm/hurt") end),
    },
    deathtimeline = 
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/merm/death") end),
    },
})

CommonStates.AddIdle(states)
CommonStates.AddSimpleActionState(states, "gohome", "pig_pickup", 4*FRAMES, {"busy"})
CommonStates.AddSimpleActionState(states, "eat", "eat", 10*FRAMES, {"busy"})
CommonStates.AddFrozenStates(states)

    
return StateGraph("merm", states, events, "idle", actionhandlers)

