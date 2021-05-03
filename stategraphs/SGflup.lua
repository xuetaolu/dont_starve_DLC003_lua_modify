require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.GOHOME, "action"),
    ActionHandler(ACTIONS.FLUP_HIDE, "hide_pre"),
}

local function doattackfn(inst, data)
    if not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") then
        if inst.sg:HasStateTag("ambusher") then
            inst.sg:GoToState("hidden_ambush_attack_pre")
        elseif inst:GetDistanceSqToInst(data.target) > TUNING.FLUP_MELEEATTACK_RANGE*TUNING.FLUP_MELEEATTACK_RANGE then
            inst.sg:GoToState("ambush_attack_pre")
        else
            inst.sg:GoToState("attack")
        end
    end
end

local events=
{
    EventHandler("doattack", doattackfn),

    EventHandler("gotosleep", function(inst)
        if inst.components.health and inst.components.health:GetPercent() > 0 then
            if inst.sg:HasStateTag("ambusher") then
                if inst.sg:HasStateTag("sleeping") then
                    inst.sg:GoToState("sleeping_hidden")
                else
                    inst.sg:GoToState("sleep_hidden")
                end
            else
                if inst.sg:HasStateTag("sleeping") then
                    inst.sg:GoToState("sleeping")
                else
                    inst.sg:GoToState("sleep")
                end
            end
        end
    end),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnAttacked(),

    EventHandler("locomote",
        function(inst)
            if not (inst.sg:HasStateTag("idle") and not
                inst.sg:HasStateTag("moving")) or
                inst.sg:HasStateTag("jumping") then return end

            if not inst.components.locomotor:WantsToMoveForward() then
                if not inst.sg:HasStateTag("idle") then
                    inst.sg:GoToState("idle")
                end
            else
                if not inst.sg:HasStateTag("hopping") then
					if inst.components.locomotor:WantsToRun() then
						inst.sg:GoToState("aggressivehop")
					else
						inst.sg:GoToState("hop")
					end
                end
            end
        end),

    EventHandler("newcombattarget", function(inst, data)
        if inst.sg:HasStateTag("idle") and data.target then
            inst.sg:GoToState("look_pre")
        end
    end)
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
                inst.AnimState:PushAnimation("idle", true)
            else
                inst.AnimState:PlayAnimation("idle", true)
            end
            inst.sg:SetTimeout(1*math.random()+.5)
        end,

        ontimeout= function(inst)
            if inst.components.locomotor:WantsToMoveForward() then
                inst.sg:GoToState("hop")
            end
        end,
    },

    State{
        name = "action",
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle", true)
            inst:PerformBufferedAction()
        end,
        events=
        {
            EventHandler("animover", function (inst)
                inst.sg:GoToState("idle")
            end),
        }
    },

    State{
        name = "aggressivehop",
        tags = {"moving", "canrotate", "hopping", "running"},

        timeline=
        {
            TimeEvent(4*FRAMES, function(inst)
                inst.components.locomotor:RunForward()
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/flup/jump")
            end ),
            TimeEvent(15*FRAMES, function(inst)
                inst.Physics:Stop()
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/flup/land")
            end ),
        },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("jump_pre")
            inst.AnimState:PushAnimation("jump")
            inst.AnimState:PushAnimation("jump_pst", false)
        end,

        events=
        {
            EventHandler("animqueueover", function (inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "hop",
        tags = {"moving", "canrotate", "hopping"},


        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("jump_pre")
            inst.AnimState:PushAnimation("jump")
            inst.AnimState:PushAnimation("jump_pst", false)
        end,

        timeline=
        {
            TimeEvent(4*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/flup/jump")
                inst.components.locomotor:WalkForward()
            end ),
            TimeEvent(15*FRAMES, function(inst)
                inst.Physics:Stop()
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/flup/land")
            end ),
        },

        events=
        {
            EventHandler("animqueueover", function (inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "attack",
        tags = {"attack"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PushAnimation("atk", false)
        end,

        timeline=
        {
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/flup/attack") end),
            TimeEvent(16*FRAMES, function(inst) inst.components.combat:DoAttack() end),
        },

        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "fall",
        tags = {"busy"},
        onenter = function(inst)
			inst.Physics:SetDamping(0)
            inst.Physics:SetMotorVel(0,-20+math.random()*10,0)
            inst.AnimState:PlayAnimation("fall_idle", true)
            inst.DynamicShadow:Enable(false)
            ChangeToInventoryPhysics(inst)
        end,

        onupdate = function(inst)
            local pt = Point(inst.Transform:GetWorldPosition())
            if pt.y < 2 then
				inst.Physics:SetMotorVel(0,0,0)
            end

            if pt.y <= .1 then
                pt.y = 0

                inst.Physics:Stop()
				inst.Physics:SetDamping(5)
                inst.Physics:Teleport(pt.x,pt.y,pt.z)
	            inst.DynamicShadow:Enable(true)
                ChangeToCharacterPhysics(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/flup/land")
                inst.sg:GoToState("idle", "jump_pst")
            end
        end,

        onexit = function(inst)
            local pt = inst:GetPosition()
            pt.y = 0
            inst.Transform:SetPosition(pt:Get())
        end,
    },

    State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/flup/death")
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
        end,
    },

    State{
        name = "hide_pre",
        tags = {"ambusher", "idle", "canrotate"},

        onenter = function(inst)
            inst.DynamicShadow:Enable(false)
            ChangeToInventoryPhysics(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hide")
            inst:PerformBufferedAction()
        end,

        onexit = function(inst)
            inst.DynamicShadow:Enable(true)
            ChangeToCharacterPhysics(inst)
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("hide_loop") end)
        },
    },

    State{
        name = "hide_loop",
        tags = {"idle", "ambusher", "invisible"},

        onenter = function(inst)
            inst.DynamicShadow:Enable(false)
            ChangeToInventoryPhysics(inst)
            inst.Physics:Stop()
            --inst:Hide()
            inst.sg:SetTimeout(math.random() * 5 + 5)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("ground_pre")
        end,

        onexit = function(inst)
            --inst:Show()
            inst.DynamicShadow:Enable(true)
            ChangeToCharacterPhysics(inst)
        end,
    },

    State{
        name = "look_pre",
        tags = {"ambusher", "invisible"},

        onenter = function(inst)
            inst.DynamicShadow:Enable(false)
            ChangeToInventoryPhysics(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("look_pre")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/flup/eye_ball")
        end,

        onexit = function(inst)
            inst.DynamicShadow:Enable(true)
            ChangeToCharacterPhysics(inst)
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("look_loop") end)
        },
    },

    State{
        name = "look_loop",

        tags = {"ambusher", "invisible"},

        onenter = function(inst)
            inst.DynamicShadow:Enable(false)
            ChangeToInventoryPhysics(inst)
            inst.Physics:Stop()
            local animnum = 1 --math.random(1,2)
            inst.AnimState:PlayAnimation("look_loop"..animnum, true)

            inst.blinktask = inst:DoTaskInTime(8*FRAMES, function()
                inst.blinktask:Cancel()
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/flup/blink")
                inst.blinktask = inst:DoPeriodicTask(59*FRAMES, function()
                    inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/flup/blink")
                end)
            end)
        end,

        onupdate = function(inst)
            if inst.sg.timeinstate > .75 and inst.components.combat:TryAttack() then
                inst.sg:GoToState("hidden_ambush_attack_pre")
            elseif inst.components.combat.target == nil then
                inst.sg:GoToState("look_pst")
            end
        end,

        onexit = function(inst)
            if inst.blinktask then
                inst.blinktask:Cancel()
            end
            inst.DynamicShadow:Enable(true)
            ChangeToCharacterPhysics(inst)
        end,
    },

    State{
        name = "look_pst",
        tags = {"ambusher", "invisible"},

        onenter = function(inst)
            inst.DynamicShadow:Enable(false)
            ChangeToInventoryPhysics(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("look_pst")
        end,

        onexit = function(inst)
            inst.DynamicShadow:Enable(true)
            ChangeToCharacterPhysics(inst)
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("hide_loop") end)
        },
    },

    State{
        name = "ground_pre",
        tags = {"ambusher", "invisible", "idle"},

        onenter = function(inst)
            inst.DynamicShadow:Enable(false)
            ChangeToInventoryPhysics(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("ground_pre")
        end,

        onexit = function(inst)
            inst.DynamicShadow:Enable(true)
            ChangeToCharacterPhysics(inst)
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("ground_loop") end)
        },
    },

    State{
        name = "ground_loop",
        tags = {"ambusher", "invisible", "idle"},

        onenter = function(inst)
            inst.DynamicShadow:Enable(false)
            ChangeToInventoryPhysics(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("ground_loop", true)
            inst.sg:SetTimeout(math.random() * 3 + 2)
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("ground_pst")
        end,

        onexit = function(inst)
            inst.DynamicShadow:Enable(true)
            ChangeToCharacterPhysics(inst)
        end,
    },

    State{
        name = "ground_pst",
        tags = {"ambusher", "invisible", "idle"},

        onenter = function(inst)
            inst.DynamicShadow:Enable(false)
            ChangeToInventoryPhysics(inst)
            inst.Physics:Stop()
            inst.AnimState:PushAnimation("ground_pst", false)
        end,

        onexit = function(inst)
            inst.DynamicShadow:Enable(true)
            ChangeToCharacterPhysics(inst)
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("hide_loop") end)
        },
    },

    State{
        name = "hidden_ambush_attack_pre",
        tags = {"attack", "canrotate", "busy", "jumping"},

        onenter = function(inst, cb)
            inst.DynamicShadow:Enable(false)
            ChangeToInventoryPhysics(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("jump_atk_ground_pre")
        end,

        onexit = function(inst)
            inst.DynamicShadow:Enable(true)
            ChangeToCharacterPhysics(inst)
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("ambush_attack") end),
        },
    },

    State{
        name = "ambush_attack_pre",
        tags = {"attack", "canrotate", "busy", "jumping"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("jump_atk_pre")
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("ambush_attack") end),
        },
    },

    State{
        name = "ambush_attack",
        tags = {"attack", "canrotate", "busy", "jumping"},

        onenter = function(inst, target)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(false)

            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("jump_atk")
            inst.AnimState:PushAnimation("jump_atk_pst", false)
        end,

        onexit = function(inst)
            inst.components.locomotor:Stop()
            inst.components.locomotor:EnableGroundSpeedMultiplier(true)
        end,

        timeline =
        {
            TimeEvent(0*FRAMES, function(inst) 
                inst.Physics:SetMotorVelOverride(10,0,0)
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/flup/jump")
            end),
            TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/flup/attack") end),
            TimeEvent(10*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) end),
            TimeEvent(17*FRAMES,
                function(inst)
                    inst.Physics:ClearMotorVelOverride()
                    inst.components.locomotor:Stop()
                    inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/flup/land")
                end),
        },

        events=
        {
            EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "hit",
        tags = {"busy", "hit", "canrotate"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/flup/hurt")
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "sleep_hidden",
        tags = {"ambusher", "busy", "sleeping"},
        
        onenter = function(inst) 
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("look_pst")
            inst.DynamicShadow:Enable(false)
        end,

        onexit = function(inst)
            inst.DynamicShadow:Enable(true)
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("sleeping_hidden") end ),        
            EventHandler("onwakeup", function(inst) inst.sg:GoToState("wake_hidden") end),
        },
    },

    State{
            
        name = "sleeping_hidden",
        tags = {"ambusher", "busy", "sleeping"},
        
        onenter = function(inst)
            inst.DynamicShadow:Enable(false)
        end,

        onexit = function(inst)
            inst.DynamicShadow:Enable(true)
        end,
        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("sleeping_hidden") end ),        
            EventHandler("onwakeup", function(inst) inst.sg:GoToState("wake_hidden") end),
        },
    },       

    State{
            
        name = "wake_hidden",
        tags = {"ambusher", "busy", "waking"},
        
        onenter = function(inst) 
            inst.components.locomotor:StopMoving()
            if inst.components.sleeper and inst.components.sleeper:IsAsleep() then
                inst.components.sleeper:WakeUp()
            end
            inst.DynamicShadow:Enable(false)
        end,

        onexit = function(inst)
            inst.DynamicShadow:Enable(true)
        end,

        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("ground_pre") end ),        
        },
    },
}

CommonStates.AddSleepStates(states,
{
    sleeptimeline = {TimeEvent(0, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/flup/sleep") end)},    
})

CommonStates.AddFrozenStates(states)

return StateGraph("flup", states, events, "hide_loop", actionhandlers)