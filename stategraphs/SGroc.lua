require("stategraphs/commonstates")

local actionhandlers = 
{

   -- ActionHandler(ACTIONS.GOHOME, "action"),
}

local events =
{
    EventHandler("fly", function(inst) inst.sg:GoToState("fly") end),
    EventHandler("land", function(inst) inst.sg:GoToState("land") end),
    EventHandler("takeoff", function(inst) inst.sg:GoToState("takeoff") end),
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
            inst.AnimState:PlayAnimation("ground_loop")    

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
        name = "land",
        tags = {"busy" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("ground_pre")    
        end,
        
        
        timeline=
        {            
            TimeEvent(30*FRAMES, function(inst) inst.components.roccontroller:Spawnbodyparts() end),
            TimeEvent(5*FRAMES, function(inst) 
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/roc/flap","flaps")
                inst.SoundEmitter:SetParameter("flaps", "intensity", inst.sounddistance)
            end),
            TimeEvent(17*FRAMES, function(inst) 
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/roc/flap","flaps")
                inst.SoundEmitter:SetParameter("flaps", "intensity", inst.sounddistance)
            end),
        },
        
        events =
        {
            EventHandler("animover", function(inst, data)
                inst.sg:GoToState("idle")
            end),
        }
    },


    State
    {
        name = "takeoff",
        tags = {"busy" },

        onenter = function(inst)
            
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("ground_pst")    
        end,

        timeline=
        {            
            TimeEvent(15*FRAMES, function(inst) inst.components.locomotor:RunForward() end),
        },
        

        events =
        {
            EventHandler("animover", function(inst, data)
                inst.sg:GoToState("fly")
            end),
        }
    },


    State
    {
        name = "fly",
        tags = {"moving","canrotate"},

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            inst.sg:SetTimeout(1+2*math.random())
            inst.AnimState:PlayAnimation("shadow")      
        end,
        
        onupdate = function(inst)
           
        end,

        ontimeout=function(inst)
            inst.sg:GoToState("flap")
        end,
    },

    State
    {
        name = "flap",
        tags = {"moving","canrotate"},

        onenter = function(inst)
         inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("shadow_flap_loop")      
        end,

    timeline=
        {
            TimeEvent(16*FRAMES, function(inst) 
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/roc/flap","flaps")
                inst.SoundEmitter:SetParameter("flaps", "intensity", inst.sounddistance)
            end),
            
            TimeEvent(1*FRAMES, function(inst) if math.random() < 0.5 then
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/roc/call","calls") end
                inst.SoundEmitter:SetParameter("calls", "intensity", inst.sounddistance)
            end),
        },
        onupdate = function(inst)
           
        end,

        events=
        {
            EventHandler("animover", function(inst) 
                if not inst.flap then
                    inst.sg:GoToState("flap")
                    inst.flap = true
                else    
                    inst.sg:GoToState("fly")
                    inst.flap = nil
                end

            end),
        },
    },        
}

return StateGraph("roc", states, events, "idle", actionhandlers)

