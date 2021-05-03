require("stategraphs/commonstates")

local actionhandlers = 
{
   -- ActionHandler(ACTIONS.GOHOME, "action"),
}

SHAKE_DIST = 40

local events =
{
    EventHandler("enter", function(inst) if not inst.sg:HasStateTag("grab") then inst.sg:GoToState("enter") end end),
    EventHandler("exit", function(inst) if not inst.sg:HasStateTag("grab") then inst.sg:GoToState("exit") end end),    
    EventHandler("bash", function(inst) if not inst.sg:HasStateTag("grab") then inst.sg:GoToState("bash") end end),     
    EventHandler("gobble", function(inst) if not inst.sg:HasStateTag("grab") then inst.sg:GoToState("grab") end end), 
    EventHandler("taunt", function(inst) if not inst.sg:HasStateTag("grab") then inst.sg:GoToState("taunt") end end),  -- assert(not inst.sg:HasStateTag("grab"))
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

local function DoGrab(inst)                                      
    local controller = inst.controller

    if controller.target and controller.target:HasTag("isinventoryitem") then
        controller:EatSomething(controller.target)   
    elseif controller.target == GetPlayer() then  
        local dist = inst:GetDistanceSqToInst(controller.target) 
        if dist < 2 then
            controller:playergrabbed()
            inst.triggerliftoff = true
        end        
    end
    controller.target = nil
end

local states =
{
    State
    {
        name = "idle",
        tags = {"idle" },

        onenter = function(inst,pushanim)
            if pushanim then
                inst.AnimState:PlayAnimation(pushanim)           
                inst.AnimState:PushAnimation("idle_loop")           
            else
                inst.AnimState:PlayAnimation("idle_loop")           
            end
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
        name = "bash",
        tags = {"busy" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("bash_pre")           
            inst.AnimState:PushAnimation("bash_loop",false)           
            inst.AnimState:PushAnimation("bash_pst",false)           
        end,
        

        timeline =
        {
            TimeEvent(37*FRAMES, function(inst) 
                inst.components.groundpounder:GroundPound()

                local player = GetClosestInstWithTag("player", inst, SHAKE_DIST)
                if player then
                    player.components.playercontroller:ShakeCamera(inst, "VERTICAL", 0.5, 0.03, 2, SHAKE_DIST)
                end
            end)
        },

        events =
        {
            EventHandler("animqueueover", function(inst, data)
                inst.sg:GoToState("idle")
            end),
        }
    },


    State
    {
        name = "grab",
        tags = {"busy", "grab" },

        onenter = function(inst)
            inst.AnimState:PlayAnimation("grab_pre")           
            inst.AnimState:PushAnimation("grab_loop",false)           
            inst.AnimState:PushAnimation("grab_pst",false)           
        end,
        
        timeline =
        {
            TimeEvent(14*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/roc/attack_1") end),
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/roc/attack_2") end),
            TimeEvent(24*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/roc/attack_3") end),
            TimeEvent(42*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/roc/close_whoosh") end),
            TimeEvent(54*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/roc/close") end),
            TimeEvent(31*FRAMES, function(inst) 
                DoGrab(inst)
            end)
        },

        onexit = function(inst)
            if inst.triggerliftoff then           
                inst.triggerliftoff = nil
                inst.body:PushEvent("liftoff")           
            end
            if inst:HasTag("HasPlayer") then
                inst.controller:UnchildPlayer(inst)
            end
        end,

        events =
        {
            EventHandler("animqueueover", function(inst, data)
                inst.sg:GoToState("idle")
            end),
        }
    },

    State
    {
        name = "enter",
        tags = {"idle","canrotate","busy"},

        onenter = function(inst)    
            inst.AnimState:PlayAnimation("idle_pre")
        end,
    
        events =
        {
            EventHandler("animover", function(inst, data)
                inst.sg:GoToState("taunt")
            end),
        }
    },

    State
    {
        name = "taunt",
        tags = {"idle","canrotate","busy"},

        onenter = function(inst)    
            inst.AnimState:PlayAnimation("taunt")
        end,
        
        timeline=
        {
            TimeEvent(14*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/roc/attack_1") end),
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/roc/attack_2") end),
            TimeEvent(24*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/roc/attack_3") end),
            TimeEvent(36*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/roc/close_whoosh") end),
            TimeEvent(48*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/roc/close") end),
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
        name = "exit",
        tags = {"idle","canrotate"},

        onenter = function(inst)    
            inst.AnimState:PlayAnimation("idle_pst")
        end,

        events =
        {
            EventHandler("animover", function(inst, data)
                print("REMOVING ROCK HEAD")            
                inst:Remove()
            end),
        }
    },        
}

return StateGraph("roc_head", states, events, "idle", actionhandlers)

