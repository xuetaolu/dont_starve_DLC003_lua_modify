require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.GOHOME, "gohome"),
    ActionHandler(ACTIONS.EAT, "eat"),
    ActionHandler(ACTIONS.PICKUP, "pickup"),
    ActionHandler(ACTIONS.EQUIP, "pickup"),
    ActionHandler(ACTIONS.TAKEITEM, "pickup"),
	ActionHandler(ACTIONS.MINE, "mine"),
}


local events=
{
	CommonHandlers.OnSleep(),
	CommonHandlers.OnLocomote(false,true),
	CommonHandlers.OnAttacked(true),
	CommonHandlers.OnAttack(),
	CommonHandlers.OnFreeze(),
	CommonHandlers.OnDeath(),
}

local states=
{

	State{

		name = "idle",
		tags = {"idle", "canrotate"},
		onenter = function(inst, playanim)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("idle", true)
			inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/balphin/idle_swim")

            inst.sg:SetTimeout(4 + math.random()*3)
		end,

		ontimeout = function(inst)
			inst.sg:GoToState("flip")
		end,
	},

	State{

		name = "flip",
		tags = {"busy", "canrotate"},
		onenter = function(inst, playanim)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("jump")
			inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/balphin/emerge")
		end,

		timeline=
		{
			TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/water_emerge_sml") end),
			TimeEvent(24*FRAMES, function(inst)
				--if math.random() < .4 then
				--	inst:Hide()
				--	inst.Physics:Stop()
				--	local splash = SpawnPrefab("splash_water")
				--	local pos = inst:GetPosition()
				--	splash.Transform:SetPosition(pos.x, pos.y, pos.z)
				--	inst.sg:GoToState("hiding")
				--end
			 end),
		},

		events=
		{
			EventHandler("animover", function(inst)
				inst.sg:GoToState("idle")
			end),
		},
	},

	State{

		name = "hiding",
		tags = {"busy", "invisible"},
		onenter = function(inst, playanim)
		end,

		timeline=
		{
			TimeEvent(TUNING.SEG_TIME, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/water_emerge_sml")  inst.AnimState:PlayAnimation("leap") inst:Show() end),
			TimeEvent(TUNING.SEG_TIME + 14*FRAMES, function(inst) inst.sg:GoToState("idle") end),
		},
	},

    State{

		name = "searching",
		tags = {"busy", "invisible"},
		onexit = function(inst, playanim)
            if inst.components.follower and inst.components.follower.leader then
                local leader = inst.components.follower.leader
                if leader.components.searchable.OnSearchEnd ~= nil then
                    leader.components.searchable.OnSearchEnd(leader, inst)
                    leader.sg:GoToState("dismount")
                end

                inst.components.follower.leader = GetPlayer()
            end

		end,

		timeline=
		{
			TimeEvent(100*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/water_emerge_sml")  inst.AnimState:PlayAnimation("leap") inst:Show() end),
			TimeEvent(100*FRAMES + 14*FRAMES, function(inst) inst.sg:GoToState("idle") end),
		},
	},
    
    State{
        name = "mine",
        tags = {"mining"},
        
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
            inst.AnimState:PlayAnimation("sleep_pre")
            inst.AnimState:PushAnimation("sleep_loop", false)
        end,

        timeline=
        {
            TimeEvent(10*FRAMES, function(inst) inst:PerformBufferedAction() end),
            TimeEvent(60*FRAMES, function(inst) inst.sg:GoToState("idle") end),
        },
    },

	State{
		name = "walk_start",
		tags = {"moving", "canrotate"},

		onenter = function(inst)
			inst.AnimState:PlayAnimation("walk_pre")
		end,

		events =
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),
		},
	},

	State{
		name = "walk",
		tags = {"moving", "canrotate"},

		onenter = function(inst)
			inst.components.locomotor:WalkForward()
			if math.random() < 0.8 then
				inst.AnimState:PlayAnimation("walk_loop")
			else
				inst.AnimState:PlayAnimation("leap")
			end
		end,

        onupdate = function(inst)
            if inst.components.follower and inst.components.follower.leader then
                local leader = inst.components.follower.leader
                local ent_pos = Vector3(inst.Transform:GetWorldPosition())
            end
        end,

		timeline=
		{
			TimeEvent(21*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/water_swimbreach_sml") end),
			TimeEvent(48*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/water_swimbreach_sml") end),
		},
		events=
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),
		},
	},

	State{
		name = "leap",
		tags = {},
		onenter = function(inst)

		end,
	},

	State{
		name = "walk_stop",
		tags = {"canrotate"},

		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("walk_pst")
		end,

		timeline=
		{
			TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/water_emerge_sml") end),
			TimeEvent(9*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/balphin/emerge") end),
		},

		events=
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
		},
	},

	State{
		name = "death",
		tags = {"busy"},

		onenter = function(inst)
			inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/balphin/death")
			inst.AnimState:PlayAnimation("death")
			inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
		end,

	},

	State{
		name = "hit",
		tags = {"busy", "hit"},

		onenter = function(inst, cb)
			inst.AnimState:SetOrientation(ANIM_ORIENTATION.Default )
			inst.AnimState:PlayAnimation("hit")
			inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/balphin/hit")
		end,

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
			inst.AnimState:PlayAnimation("atk", false)
			inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/balphin/attack")
		end,

		onexit = function(inst)
		end,

		timeline=
		{
			TimeEvent(16*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) end),
		},

		events=
		{
			EventHandler("animqueueover",  function(inst) inst.sg:GoToState("idle") end),
		},
	},

	State{
		name = "taunt",
		tags = {"busy"},

		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("taunt")
			inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/balphin/taunt")
		end,

		events=
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
		},
	},
}

CommonStates.AddSleepStates(states,
{
	sleeptimeline =
	{
		TimeEvent(1, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/balphin/sleep") end)
	},
})

CommonStates.AddFrozenStates(states)
CommonStates.AddSimpleActionState(states,"pickup", "jump", 10*FRAMES, {"busy"})
CommonStates.AddSimpleActionState(states, "gohome", "jump", 4*FRAMES, {"busy"})

return StateGraph("ballphin", states, events, "idle", actionhandlers)
