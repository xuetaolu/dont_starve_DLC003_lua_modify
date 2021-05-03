require("stategraphs/commonstates")

local actionhandlers = 
{
    ActionHandler(ACTIONS.GOHOME, "gohome"),
    ActionHandler(ACTIONS.EAT, "eat"),
    ActionHandler(ACTIONS.PICKUP, "pickup"),
    ActionHandler(ACTIONS.EQUIP, "pickup"),
    ActionHandler(ACTIONS.ADDFUEL, "pickup"),
}

local events=
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnLocomote(true,true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(true),
    CommonHandlers.OnDeath(),
}

local function beardit(inst, anim)
    return inst.beardlord and "beard_"..anim or anim
end

local states=
{
    State{
        name= "funnyidle",
        tags = {"busy"},
        
        onenter = function(inst)
			inst.Physics:Stop()
            
            if inst.beardlord then
                inst.AnimState:PlayAnimation("beard_taunt")
                -- inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/wererabbit_taunt")
			elseif inst.components.health:GetPercent() < TUNING.BUNNYMAN_PANIC_THRESH then
				inst.AnimState:PlayAnimation("idle_angry")
				-- inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/angry_idle")
            elseif inst.components.follower.leader and inst.components.follower:GetLoyaltyPercent() < 0.05 then
                inst.AnimState:PlayAnimation("hungry")
                inst.SoundEmitter:PlaySound("dontstarve/wilson/hungry")
            elseif inst.components.combat.target then
                inst.AnimState:PlayAnimation("idle_angry")
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/angry_idle")
            elseif inst.components.follower.leader and inst.components.follower:GetLoyaltyPercent() > 0.3 then
                inst.AnimState:PlayAnimation("idle_happy")

                inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/idle_happy")
            else
                inst.AnimState:PlayAnimation("idle_creepy")
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/idle_creepy")
            end
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },        
    },

    State{
        name= "happy",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            
            inst.AnimState:PlayAnimation("idle_happy")
            -- inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/happy")

        end,

        timeline=
        {
            TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/clap") end),
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/clap") end),
            TimeEvent(16*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/clap") end), 
            TimeEvent(22*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/clap") end), 
            TimeEvent(28*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/clap") end), 
            TimeEvent(34*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/clap") end), 
            TimeEvent(40*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/clap") end), 
            TimeEvent(46*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/clap") end), 
            TimeEvent(52*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/clap") end), 
            
        },
        
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
			inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/death")
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)            
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))            
        end,
        
    },
    
    State{
		name = "abandon",
		tags = {"busy"},
		
		onenter = function(inst, leader)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("abandon")
			inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/no")
            inst:FacePoint(Vector3(leader.Transform:GetWorldPosition()))
		end,
		
        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },        
    },
    
    State{
        name = "attack",
        tags = {"attack", "busy"},
        
        onenter = function(inst)
			if inst.beardlord then
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/eat")
            else
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/eat")       
            end

            inst.components.combat:StartAttack()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation(beardit(inst,"atk"))
        end,
        
        timeline=
        {
            TimeEvent(13*FRAMES, function(inst) 
				-- inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/bite")        
				inst.components.combat:DoAttack() inst.sg:RemoveStateTag("attack") 
				inst.sg:RemoveStateTag("busy") 
			end),
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
			inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/eat")            
        end,
        
        timeline=
        {
            TimeEvent(20*FRAMES, function(inst) inst:PerformBufferedAction() end),
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
            
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()            
        end,
        
        timeline=
        {
            TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/hit") end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },        
    },    
}

CommonStates.AddWalkStates(states,
{
	walktimeline = {
		TimeEvent(0*FRAMES, PlayFootstep ),
		TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/hop") end),
        TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/foley") end),
		-- TimeEvent(12*FRAMES, PlayFootstep ),
		-- TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/hop") end),
	},
},
{
    startwalk = function(inst) return beardit(inst,"walk_pre") end,
    walk = function(inst) return beardit(inst,"walk_loop") end,
    stopwalk = function(inst) return beardit(inst,"walk_pst") end,
}, function(inst) return not inst.beardlord end
)

CommonStates.AddRunStates(states,
{
	runtimeline = {
		TimeEvent(0*FRAMES, PlayFootstep ),
		TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/hop") end),
        TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/foley") end),
		-- TimeEvent(12*FRAMES, PlayFootstep ),
		-- TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/elderdrake/hop") end),
	},
},
{
    startrun = function(inst) return beardit(inst,"run_pre") end,
    run = function(inst) return beardit(inst,"run_loop") end,
    stoprun = function(inst) return beardit(inst,"run_pst") end,
}, function(inst) return not inst.beardlord end
)

CommonStates.AddSleepStates(states,
{
	sleeptimeline = 
	{
		TimeEvent(35*FRAMES, function(inst) inst.SoundEmitter:PlaySound("ddontstarve_DLC003/creatures/elderdrake/sleep") end ),
	},
})

CommonStates.AddIdle(states,"funnyidle", function(inst) return beardit(inst,"idle_loop") end, 
{
    -- TimeEvent(0*FRAMES, function(inst) if inst.beardlord then inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/wererabbit_breathin") end end ),
    -- TimeEvent(15*FRAMES, function(inst) if inst.beardlord then inst.SoundEmitter:PlaySound("dontstarve/creatures/bunnyman/wererabbit_idle") end end ),
})

CommonStates.AddSimpleState(states,"refuse", "pig_reject", {"busy"})
CommonStates.AddFrozenStates(states)

CommonStates.AddSimpleActionState(states,"pickup", "pig_pickup", 10*FRAMES, {"busy"})

CommonStates.AddSimpleActionState(states, "gohome", "pig_pickup", 4*FRAMES, {"busy"})

    
return StateGraph("mandrakeman", states, events, "idle", actionhandlers)

