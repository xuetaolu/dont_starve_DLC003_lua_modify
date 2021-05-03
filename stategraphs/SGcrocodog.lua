require("stategraphs/commonstates")

local actionhandlers =
{
	ActionHandler(ACTIONS.EAT, "eat"),
    ActionHandler(ACTIONS.HARVEST, "eat"),
}

local events=
{
    EventHandler("attacked", function(inst) if not inst.components.health:IsDead() and not inst.sg:HasStateTag("attack") then inst.sg:GoToState("hit") end end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("doattack", function(inst, data) if not inst.components.health:IsDead() and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then inst.sg:GoToState("attack", data.target) end end),
    
    EventHandler("locomote", function(inst)
        local is_moving = inst.sg:HasStateTag("moving")
        local is_running = inst.sg:HasStateTag("running")
        
        local is_idling = inst.sg:HasStateTag("idle")
        local can_run = true 
        local can_walk = true 
        
        local should_move = inst.components.locomotor:WantsToMoveForward()
        local should_run = inst.components.locomotor:WantsToRun()
        if is_moving and not should_move then
            if is_running then
                inst.sg:GoToState("idle")
            else
                inst.sg:GoToState("idle")
            end
        elseif (is_idling and should_move) or (is_moving and should_move and is_running ~= should_run and can_run and can_walk) then
            if can_run and (should_run or not can_walk) then
                inst.sg:GoToState("run")
            elseif can_walk then
                inst.sg:GoToState("walk")
            end
        end
    end),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
}

local states=
{

    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst, playanim)
            --inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/crocodog/idle")
            inst.Physics:Stop()
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation("idle", true)
            else
                inst.AnimState:PlayAnimation("idle", true)
            end
            
            if math.random() < .333 and inst:HasTag("enable_shake") then
                if GetWorld().components.flooding and GetWorld().components.flooding.mode == "flood"  then
                    inst.sg:GoToState("shake")
                end
            end
        end,

        timeline=
        {
            TimeEvent(13*FRAMES, 
			function(inst) 
				if inst.components.tiletracker.onwater == false then
					inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/crocodog/idle") 
				else
					inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/thrust") 
				end
			end),
        },

    },

    State{
        name = "shake",
        tags = {"busy"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("shake")

			local sm = GetSeasonManager()
			if sm:IsGreenSeason() and sm:GetPercentSeason() > 0.25 then
				local x,y,z = inst.Transform:GetWorldPosition()
				local currentLevel = GetWorld().Flooding:GetTargetDepth()
				if currentLevel < 1 then
					GetWorld().Flooding:SetTargetDepth(1)	
				end

				GetWorld().Flooding:SetPositionPuddleSource(x,0,z)
			end
	
        end,

		timeline=
        {
			TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/crocodog/shake") end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "attack",
        tags = {"attack", "busy"},
        
        onenter = function(inst, target)
            inst.sg.statemem.target = target
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk_pre")
			inst.AnimState:PushAnimation("atk", false)
        end,

        timeline=
        {
			TimeEvent(5*FRAMES, function(inst) 
				if inst.components.tiletracker.onwater == false then
					inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/crocodog/bark")
				end
			end),
			TimeEvent(18*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/crocodog/bite") end),
            TimeEvent(20*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) end),
        },

        events=
        {
            EventHandler("animqueueover", function(inst) if math.random() < .1 then inst.components.combat:SetTarget(nil) inst.sg:GoToState("taunt") else inst.sg:GoToState("idle", "atk_pst") end end),
        },
    },

	State{
        name = "eat",
        tags = {"busy"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PushAnimation("atk", false)
        end,

		timeline=
        {
			TimeEvent(14*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/crocodog/bite") end),
        },

        events=
        {
			EventHandler("animqueueover", function(inst) if inst:PerformBufferedAction() then inst.components.combat:SetTarget(nil) inst.sg:GoToState("taunt") else inst.sg:GoToState("idle", "atk_pst") end end),
        },
    },

	State{
		name = "hit",
        tags = {"busy", "hit"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hit")
        end,

		timeline=
        {
            TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/crocodog/hit") end),
        },

        events=
        {
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },


    State{
        name = "taunt",
        tags = {"busy"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
	        inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/crocodog/taunt")

        end,

        timeline=
        {
            TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/crocodog/taunt") end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
			inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/crocodog/death")
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)            
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))     
			
			local sm = GetSeasonManager()
			if inst:HasTag("enable_shake") and sm:IsGreenSeason() and sm:GetPercentSeason() > 0.25 then
				local x,y,z = inst.Transform:GetWorldPosition()
				local currentLevel = GetWorld().Flooding:GetTargetDepth()
				if currentLevel < 1 then
					GetWorld().Flooding:SetTargetDepth(1)	
				end

				GetWorld().Flooding:SetPositionPuddleSource(x,0,z)
			end       
        end,

    },

    State{
            
        name = "run",
        tags = {"moving", "running", "canrotate"},
        
        onenter = function(inst) 
        
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("run_loop")
			inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/crocodog/run")

        end,
        
		timeline=
        {
            TimeEvent(0, function(inst) PlayFootstep(inst) end),
            TimeEvent(3*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(5*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(7*FRAMES, function(inst) PlayFootstep(inst) end),
        },

        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),        
        },
          
    }, 

     State{
            
        name = "walk",
        tags = {"moving", "canrotate"},
        
        onenter = function(inst) 
            inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("run_loop")
			inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/crocodog/bark")
        end,
        
		timeline=
        {
            TimeEvent(0, function(inst) PlayFootstep(inst) end),
            TimeEvent(3*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(5*FRAMES, function(inst) PlayFootstep(inst) end),
            TimeEvent(7*FRAMES, function(inst) PlayFootstep(inst) end),
        },

        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),        
        },
    }
}

CommonStates.AddFrozenStates(states)
CommonStates.AddSleepStates(states,
	{
		sleeptimeline = {
	        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/crocodog/sleep") end),
			TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/crocodog/sleep") end),
		},
	})

return StateGraph("crocodog", states, events, "idle", actionhandlers)

