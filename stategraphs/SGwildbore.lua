require("stategraphs/commonstates")

local actionhandlers = 
{
    ActionHandler(ACTIONS.GOHOME, "gohome"),
    ActionHandler(ACTIONS.EAT, "eat"),
    ActionHandler(ACTIONS.CHOP, "chop"),
    ActionHandler(ACTIONS.HACK, "chop"),
    ActionHandler(ACTIONS.PICKUP, "pickup"),
    ActionHandler(ACTIONS.EQUIP, "pickup"),
    ActionHandler(ACTIONS.ADDFUEL, "pickup"),
    ActionHandler(ACTIONS.TAKEITEM, "pickup"),
    ActionHandler(ACTIONS.SPECIAL_ACTION, nil),
}


local events=
{

    EventHandler("locomote", function(inst)
        local is_attacking = inst.sg:HasStateTag("attack") or inst.sg:HasStateTag("chargingattack")
        local is_busy = inst.sg:HasStateTag("busy")
        local is_idling = inst.sg:HasStateTag("idle")
        local is_moving = inst.sg:HasStateTag("moving")
        local is_running = inst.sg:HasStateTag("running") or inst.sg:HasStateTag("chargingattack")
        local should_charge = inst:HasTag("ChaseAndRam")
        local is_charging = inst.sg:HasStateTag("charging")

        if is_attacking or is_busy then return end

        local should_move = inst.components.locomotor:WantsToMoveForward()
        local should_run = inst.components.locomotor:WantsToRun()
        
        if is_moving and not should_move then
            inst.SoundEmitter:KillSound("charge")
            if is_charging then
                inst.sg:GoToState("charge_pst")
            elseif is_running then
                inst.sg:GoToState("run_stop")
            else
                inst.sg:GoToState("walk_stop")
            end
        elseif (not is_moving and should_move) or (is_moving and should_move and is_running ~= should_run) then
            if should_run then
                if should_charge then
                    inst.sg:GoToState("charge_antic_pre")
                else
                    inst.sg:GoToState("run_start")
                end
            else
                inst.sg:GoToState("walk_start")
            end
        end 
    end),

    EventHandler("doattack", function(inst)
        local nstate = "attack"
        if inst.sg:HasStateTag("charging") then
            nstate = "charge_attack"
        end
        if inst.components.health and not inst.components.health:IsDead()
           and not inst.sg:HasStateTag("busy") then
            inst.sg:GoToState(nstate)
        end
    end),


    CommonHandlers.OnStep(),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttacked(true),
    CommonHandlers.OnDeath(),
    EventHandler("transformnormal", function(inst) if inst.components.health:GetPercent() > 0 then inst.sg:GoToState("transformNormal") end end),
    EventHandler("doaction", 
        function(inst, data) 
            if not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") then
                if data.action == ACTIONS.CHOP or data.action == ACTIONS.HACK then
                    inst.sg:GoToState("chop", data.target)
                end
            end
        end),
}

local states=
{
    State{
        name= "funnyidle",
        tags = {"idle"},
        
        onenter = function(inst)
			inst.Physics:Stop()
            local daytime = not GetClock():IsNight()
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/wild_boar/oink")
            
            if inst.components.follower.leader and inst.components.follower:GetLoyaltyPercent() < 0.05 then
                inst.AnimState:PlayAnimation("hungry")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/hungry")
            elseif inst:HasTag("guard") then
                inst.AnimState:PlayAnimation("idle_angry")
            elseif daytime then
                if inst.components.combat.target then
                    inst.AnimState:PlayAnimation("idle_angry")
                elseif inst.components.follower.leader and inst.components.follower:GetLoyaltyPercent() > 0.3 then
                    inst.AnimState:PlayAnimation("idle_happy")
                else
                    inst.AnimState:PlayAnimation("idle_creepy")
                end
            else
                inst.AnimState:PlayAnimation("idle_scared")
            end
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },        
    },
    
    State {
		name = "frozen",
		tags = {"busy"},
		
        onenter = function(inst)
            inst.AnimState:PlayAnimation("frozen")
            inst.Physics:Stop()
            --inst.components.highlight:SetAddColour(Vector3(82/255, 115/255, 124/255))
        end,
    },
    
    State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/wild_boar/grunt")
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)            
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))            
        end,
        
    },

    State{
        name = "daily_gift",
        tags = {"busy"},

        onenter = function(inst)
            inst.components.talker:Say(STRINGS.PIG_TALK_DAILY_GIFTING[math.random(1, #STRINGS.PIG_TALK_DAILY_GIFTING)])
            inst.AnimState:PlayAnimation("pig_take")
            inst.Physics:Stop()
        end,

        timeline=
        {
            TimeEvent(13*FRAMES, 
                function(inst)
                    local resources = { "flint", "log", "rocks", "cutgrass", "seeds", "twigs" }

                    GetPlayer().components.inventory:GiveItem(
                        SpawnPrefab(resources [math.random(1, #resources)]),
                        nil, Vector3(TheSim:GetScreenPos(inst.Transform:GetWorldPosition())))
                end ),
        },
        
        events=
        {
            EventHandler("animover", 
                function(inst) 
                    inst.sg:GoToState("idle") 
                    inst:DoTaskInTime(4, function() inst.daily_gifting = false end)
                end ),
        },
    },
    
    State{
		name = "abandon",
		tags = {"busy"},
		
		onenter = function(inst, leader)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("abandon")
            inst:FacePoint(Vector3(leader.Transform:GetWorldPosition()))
		end,
		
        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },        
    },
    
    State{
		name = "transformNormal",
		tags = {"transform", "busy", "sleeping"},
		
		onenter = function(inst)
			inst.Physics:Stop()
			inst.SoundEmitter:PlaySound("dontstarve/creatures/werepig/transformToPig")
            inst.AnimState:SetBuild("werepig_build")
			inst.AnimState:PlayAnimation("transform_were_pig")
		    inst:RemoveTag("hostile")
			
		end,
		
		onexit = function(inst)
            inst.AnimState:SetBuild(inst.build)
		end,
		
        events=
        {
            EventHandler("animover", function(inst)
				inst.components.sleeper:GoToSleep(15+math.random()*4)
				inst.sg:GoToState("sleeping")
			end ),
        },        
    },
    
    State{
        name = "attack",
        tags = {"attack", "busy"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/wild_boar/attack")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
            inst.components.combat:StartAttack()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk")
        end,
        
        timeline=
        {
            TimeEvent(13*FRAMES, function(inst) inst.components.combat:DoAttack() inst.sg:RemoveStateTag("attack") inst.sg:RemoveStateTag("busy") end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "chop",
        tags = {"chopping"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk")
        end,
        
        timeline=
        {
            
            TimeEvent(13*FRAMES, function(inst) inst:PerformBufferedAction() end ),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
    
    State{
        name = "eat",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.Physics:Stop()            
            inst.AnimState:PlayAnimation("eat")
        end,
        
        timeline=
        {
            TimeEvent(10*FRAMES, function(inst) inst:PerformBufferedAction() end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },        
    },
    State{
        name = "hit",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/wild_boar/oink")
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()            
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },        
    },


    State{
        name = "charge_antic_pre",
        tags = {"moving", "charging", "busy", "atk_pre", "canrotate"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("paw_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("charge_antic_loop") end),
        },
    },

    State{
        name = "charge_antic_loop",
        tags = {"moving", "charging", "busy", "atk_pre", "canrotate"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("paw_loop", true)
            inst.sg:SetTimeout(1.5)
        end,

        ontimeout= function(inst)
            inst.sg:GoToState("charge_pre")
            inst:PushEvent("attackstart" )
        end,
    },

    State{
        name = "charge_pre",
        tags = {"busy", "charging", "moving", "running"},

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("charge_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("charge_loop") end),
        },
    },

    State{
        name = "charge_loop",
        tags = {"charging", "moving", "running"},

        onenter = function(inst)
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("charge_loop")
            inst.components.locomotor.bonusspeed = inst.components.locomotor.bonusspeed + 5
        end,

        onexit = function(inst)
            inst.components.locomotor.bonusspeed = inst.components.locomotor.bonusspeed - 5
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("charge_loop") end),
        },
    },

    State{
        name = "charge_pst",
        tags = {"canrotate", "idle"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("charge_pst")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "charge_attack",
        tags = {"chargingattack"},

        onenter = function(inst)
            inst.components.combat:StartAttack()
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("charge_atk")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/wild_boar/charge_attack")
        end,

        timeline =
        {
            TimeEvent(12*FRAMES, function(inst) 
                inst.components.combat:DoAttack()
                inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("attack") end),
        },
    },


}

CommonStates.AddWalkStates(states,
{
	walktimeline = {
		TimeEvent(0*FRAMES, PlayFootstep ),
		TimeEvent(12*FRAMES, PlayFootstep ),
	},
})
CommonStates.AddRunStates(states,
{
	runtimeline = {
		TimeEvent(0*FRAMES, PlayFootstep ),
		TimeEvent(10*FRAMES, PlayFootstep ),
	},
})

CommonStates.AddSleepStates(states,
{
	sleeptimeline = 
	{
		TimeEvent(35*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/wild_boar/sleep") end ),
	},
})

CommonStates.AddIdle(states,"funnyidle")
CommonStates.AddSimpleState(states,"refuse", "pig_reject", {"busy"})
CommonStates.AddFrozenStates(states)

CommonStates.AddSimpleActionState(states,"pickup", "pig_pickup", 10*FRAMES, {"busy"})

CommonStates.AddSimpleActionState(states, "gohome", "pig_pickup", 4*FRAMES, {"busy"})

    
return StateGraph("wildbore", states, events, "idle", actionhandlers)
