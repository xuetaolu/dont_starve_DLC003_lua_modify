require("stategraphs/commonstates")

local actionhandlers = {}

local events = 
{
}

local states = 
{
    State
    {
        name = "turn_on",
        tags = {"idle"},

        onenter = function(inst)
            -- inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_on")
            inst.AnimState:PlayAnimation("activate")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle_on") end),
        }
    },

    State
    {
        name = "turn_off",
        tags = {"idle"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("deactivate")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle_off") end),
        }
    },

    State
    {
        name = "idle_on",
        tags = {"idle"},

        onenter = function(inst)
            --Start some loop sound
            if not inst.SoundEmitter:PlayingSound("firesuppressor_idle") then
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/fan/on_LP", "firesuppressor_idle")
            end
            inst.AnimState:PlayAnimation("idle_loop")
        end,

        -- timeline = 
        -- {
        --     TimeEvent(16*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_chuff") end)
        -- },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle_on") end),
        }
    },

    State
    {
        name = "idle_off",
        tags = {"idle"},

        onenter = function(inst)
            --Stop some loop sound
            inst.SoundEmitter:KillSound("firesuppressor_idle")
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/fan/off")
            inst.AnimState:PlayAnimation("off", true)
        end,
    },

    State
    {
        name = "spin_up",
        tags = {"busy"},

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("launch_pre")
            inst.sg.statemem.data = data
        end,

        events = 
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("shoot", inst.sg.statemem.data) end)
        },
    },

    State
    {
        name = "spin_down",
        tags = {"busy"},

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("launch_pst")

        end,

        events = 
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle_loop") end)
        },
    },

    State
    {  
        name = "place",
        tags = {"busy"},

        onenter = function(inst, data)
            inst.AnimState:PlayAnimation("place")
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/fan/place")
        end,

        timeline = {},

        events = 
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle_loop") end)
        },
    },

    State
    {  
        name = "hit",
        tags = {"busy"},

        onenter = function(inst, data)
            if inst.on then 
                inst.AnimState:PlayAnimation("hit_on")
            else
                inst.AnimState:PlayAnimation("hit_off")
            end
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/fan/hit")
        end,

        timeline = {},

        events = 
        {
            EventHandler("animover", function(inst) 
                if inst.on then 
                    inst.sg:GoToState("idle_loop")
                else
                    inst.sg:GoToState("idle_off")
                end
            end)
        },
    },
}

return StateGraph("basefan", states, events, "idle_off", actionhandlers)