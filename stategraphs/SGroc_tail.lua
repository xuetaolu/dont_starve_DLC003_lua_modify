require("stategraphs/commonstates")

local actionhandlers = 
{

   -- ActionHandler(ACTIONS.GOHOME, "action"),
}

local events =
{

    EventHandler("enter", function(inst) inst.sg:GoToState("enter") end),
    EventHandler("exit", function(inst) inst.sg:GoToState("exit") end),    
    --[[
    EventHandler("attacked", function(inst) if inst.components.health:GetPercent() > 0 then inst.sg:GoToState("hit") end end),
    EventHandler("doattack", function(inst, data) if not inst.components.health:IsDead() and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then inst.sg:GoToState("attack", data.target) end end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
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
                if not inst.sg:HasStateTag("hopping") then
                    inst.sg:GoToState("hop")
                end
            end
        end),
        ]]
}

local function DoStep(inst)
    local player = GetPlayer()
    local distToPlayer = inst:GetPosition():Dist(player:GetPosition())
    local power = Lerp(3, 1, distToPlayer/180)
    player.components.playercontroller:ShakeCamera(player, "VERTICAL", 0.5, 0.03, power, 40) 
    inst.components.groundpounder:GroundPound()
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/glommer/foot_ground")
    GetWorld():PushEvent("bigfootstep")
end

local states =
{
    State
    {
        name = "idle",
        tags = {"idle" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("tail_loop")           
        end,
        
        events =
        {
            EventHandler("animover", function(inst, data)
                inst.sg:GoToState("idle")
            end),
        }
    },

    State
    {
        name = "enter",
        tags = {"idle","canrotate"},

        onenter = function(inst)    
            inst.AnimState:PlayAnimation("tail_pre")
        end,
    
        events =
        {
            EventHandler("animover", function(inst, data)
                print("test")
                inst.sg:GoToState("idle")
            end),
        }
    },  

    State
    {
        name = "exit",
        tags = {"idle","canrotate"},

        onenter = function(inst)    
            inst.AnimState:PlayAnimation("tail_pst")
        end,

        events =
        {
            EventHandler("animover", function(inst, data)            
                inst:Remove()
            end),
        }
    },     
}

return StateGraph("roc_tail", states, events, "idle", actionhandlers)

