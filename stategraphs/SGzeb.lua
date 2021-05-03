require("stategraphs/commonstates")

local actionhandlers = 
{
}


local events=
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
                inst.AnimState:PushAnimation("idle_loop", true)
            else
                inst.AnimState:PlayAnimation("idle_loop", true)
            end
        end,
        
        timeline = 
        {
		    TimeEvent(21*FRAMES, function(inst)  inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/zeb/idle")  end ), 
        },
        
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
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/zeb/taunt")
        end,
        
        timeline = 
        {
		    TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/knight/pawground") end ),
		    TimeEvent(28*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/knight/pawground") end ),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    }
}

CommonStates.AddWalkStates(states,
{
    starttimeline = 
    {
	    TimeEvent(0*FRAMES, function(inst) inst.Physics:Stop() end ),
    },
	walktimeline = {
          TimeEvent(0*FRAMES, function(inst) inst.Physics:Stop() end ),
          TimeEvent(7*FRAMES, function(inst) 
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/zeb/jump")
                inst.components.locomotor:WalkForward()
          end ),
          TimeEvent(20*FRAMES, function(inst) PlayFootstep(inst)

                inst.Physics:Stop()
            end ),
	},
}, nil,true)

CommonStates.AddSleepStates(states,
{
    starttimeline = 
    {
		--TimeEvent(11*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/creatures/knight/liedown") end ),
    },
    
	sleeptimeline = {
        TimeEvent(18*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/zeb/sleep") end),
	},
})

CommonStates.AddCombatStates(states,
{
    attacktimeline = 
    {
        TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/zeb/attack") end),
        TimeEvent(17*FRAMES, function(inst) inst.components.combat:DoAttack() end),
    },
    hittimeline = 
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/zeb/sleep") end),
    },
    deathtimeline = 
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/zeb/death") end),
    },
})

CommonStates.AddFrozenStates(states)

    
return StateGraph("zeb", states, events, "idle", actionhandlers)

