require("stategraphs/commonstates")

local function onattack(inst, data)
    if inst.components.health:GetPercent() > 0 and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then
        local dist = inst:GetDistanceSqToInst(data.target)
        if dist > 25 then
            inst.sg:GoToState("throw", data.target)
        end
    end
end

local events = 
{
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    EventHandler("doattack", onattack),
    EventHandler("move", function(inst, data)
        if not inst.sg:HasStateTag("move") then
            inst.sg:GoToState("move", data.pos)
        end
    end),
}

local actionhandlers = {}

local states = 
{
    State{
        name = "throw",
        tags = {"attack", "busy"},

        onenter = function(inst)
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("spit")
        end,

        timeline=
        {

            TimeEvent(13*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/quacken/spit_puke")
            end),                
            TimeEvent(56*FRAMES, function(inst) 
                inst.components.combat:DoAttack() 
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/quacken/spit")
            end),
            TimeEvent(57*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("taunt") end),
        },
    },

    State{
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("idle_loop", true)
        end,
    },

    State{
        name = "hit",
        tags = {"busy", "hit"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/quacken/hit")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "move",
        tags = {"busy", "move"},

        onenter = function(inst, pos)
            inst.components.health:SetInvincible(true)
            inst.AnimState:PlayAnimation("taunt")
            inst.AnimState:PushAnimation("exit", false)
            inst.sg.statemem.pos = pos
            inst.components.minionspawner:DespawnAll()
            inst.components.minionspawner.minionpositions = nil
            inst.sg:SetTimeout(4)
        end,

        timeline =
        {
            TimeEvent(20*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/quacken/taunt")
            end),
            
            TimeEvent(62*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/quacken/exit")
            end),

            TimeEvent(83*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/quacken/quacken_submerge")
                inst.SoundEmitter:KillSound("quacken_lp_1")
                inst.SoundEmitter:KillSound("quacken_lp_2")
            end),
        },

        onexit = function(inst)
            inst.components.health:SetInvincible(false)
            inst.Transform:SetPosition(inst.sg.statemem.pos:Get())
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("spawn")
        end,
    },

    State{
        name = "spawn",
        tags = {"busy"},

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/quacken/enter")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/quacken/quacken_emerge")
            
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/quacken/head_drone_rnd_LP", "quacken_lp_1")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/quacken/head_drone_LP", "quacken_lp_2")

            inst.AnimState:PlayAnimation("enter")
        end,

        timeline =
        {
            TimeEvent(5*FRAMES, function(inst) inst.components.minionspawner:SpawnAll() end),
            TimeEvent(35*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/quacken/enter") end)
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
        },
    },



    State{
        name = "death",  
        tags = {"busy"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("death")
            inst.components.minionspawner:DespawnAll()
            inst.components.minionspawner.minionpositions = nil
        end,

        timeline =
        {
            TimeEvent(2*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/quacken/death")
            end),

            TimeEvent(38*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/quacken/quacken_submerge")
                inst.SoundEmitter:KillSound("quacken_lp_1")
                inst.SoundEmitter:KillSound("quacken_lp_2")
            end),

            TimeEvent(90*FRAMES, function(inst)
                inst.components.lootdropper:DropLoot()
            end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst:Remove() end),
        },
    },

    State{
        name = "taunt",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("taunt")
        end,
        
        timeline = 
        {
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/quacken/taunt") end)
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
}

return StateGraph("kraken", states, events, "idle", actionhandlers)