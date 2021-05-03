local WALK_SPEED = 4
local RUN_SPEED = 7

require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.EAT, "eat"),
    ActionHandler(ACTIONS.GOHOME, "action"),
}

local events =
{
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("locomote",
        function(inst)
            if not inst.sg:HasStateTag("idle") and not inst.sg:HasStateTag("moving") then return end

            if not inst.components.locomotor:WantsToMoveForward() then
                if not inst.sg:HasStateTag("idle") then
                        inst.sg:GoToState("idle")
                end
            else
                if not inst.sg:HasStateTag("moving") then
                    inst.sg:GoToState("swimming")
                end

            end
        end),
}

local states =
{

    State{
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst, playanim)
            inst.Physics:Stop()
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
            else
                inst.AnimState:PlayAnimation("idle")
            end
        end,

        events=
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "swimming",
        tags = {"moving", "canrotate"},


        onenter = function(inst, skippre)
            if skippre then
                inst.AnimState:PlayAnimation("run")
            else
                inst.AnimState:PlayAnimation("run_pre")
                inst.AnimState:PushAnimation("run")
            end
            inst.components.locomotor:WalkForward()
            --inst.sg:SetTimeout(2*math.random()+.5)
            if math.random() < 0.5 then
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/jellyfish/bubble_short")
            else
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/jellyfish/bubble_long")
            end
        end,

        onupdate= function(inst)
            if not inst.components.locomotor:WantsToMoveForward() then
                inst.sg:GoToState("idle", "run_pst")
            end
        end,

         events=
        {
             EventHandler("animover", function(inst)
               inst.sg:GoToState("swimming", true)
            end),

             EventHandler("animqueueover", function(inst)
               inst.sg:GoToState("swimming", true)
            end)
        },


    },

     State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/jellyfish/death_murder")
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
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("hit")
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
}

CommonStates.AddSleepStates(states)
CommonStates.AddFrozenStates(states)

return StateGraph("rainbowjellyfish", states, events, "idle", actionhandlers)
