require("stategraphs/commonstates")

local actionhandlers =
{
}

local events =
{
}

local states_west =
{
    State
    {
        name = "idle_west",
        tags = {"idle", "canrotate"},

        onenter = function(inst, playanim)
            inst.components.door:updateDoorVis()
            inst.AnimState:PlayAnimation("west", true)
        end,
    },

    State
    {
        name = "open_west",
        tags = {"moving", "canrotate"},

        onenter = function(inst)
            inst.components.door:sethidden(false)
            inst.components.door:updateDoorVis()
            inst.AnimState:PlayAnimation("west_open", false)
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle_west") end),
        }
    },

    State
    {
        name = "shut_west",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("west_shut", false)
        end,

        events =
        {
            EventHandler("animover",
                function(inst)
                    inst.components.door:sethidden(true)
                    inst.components.door:updateDoorVis()
                    inst.sg:GoToState("idle_west")
                end),
        }
    },
}

return StateGraph("anthilldoor_west",  states_west,  events, "idle_west",  actionhandlers)
