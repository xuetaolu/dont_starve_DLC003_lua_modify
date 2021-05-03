require("stategraphs/commonstates")

local events = 
{
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    EventHandler("despawn", function(inst) inst.sg:GoToState("despawn") end),
}

local actionhandlers = {}

local states = 
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_slow")
        end,

        events =
        {
            EventHandler("animover", function(inst) 
                if math.random() < 0.75 then
                    inst.sg:GoToState("waves")
                else
                    inst.sg:GoToState("idle")
                end
            end)
        },
    },

    State{
        name = "waves",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("shake")
            inst.AnimState:PushAnimation("idle", false)
            SpawnWaves(inst, math.random(4,6), 360, math.random(4,7), nil, nil, 2, true, true)
        end,

        timeline = 
        {
            TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/quacken/shake") end),
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/quacken/shake") end),
            TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/quacken/shake") end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "spawn",
        tags = {"busy"},

        onenter = function(inst, playanim)
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/quacken/tentacle_emerge")
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("enter")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "despawn",
        tags = {"busy"},

        onenter = function(inst, playanim)
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/quacken/tentacle_submerge")
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("exit")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst:Remove() end),
        },
    },

	State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("exit")
            if inst.components.lootdropper then
                inst.components.lootdropper:DropLoot()
            end
        end,
    },

    State{
        name = "hit",
        tags = {"busy", "hit"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/quacken/hit")
        end,
        
        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
    	name = "attack",
    	tags = {"busy", "attack", "canrotate"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("attack")
            inst.components.combat:StartAttack()
        end,

        timeline =
        {
			TimeEvent(17*FRAMES, function(inst) 
                inst.components.combat:DoAttack() 
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/quacken/attack")
            end),
            TimeEvent(20*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
	},
}

return StateGraph("krakententacle", states, events, "idle", actionhandlers)