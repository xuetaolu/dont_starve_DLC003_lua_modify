require("stategraphs/commonstates")

local events=
{
	CommonHandlers.OnStep(),
	CommonHandlers.OnLocomote(false,true),
	CommonHandlers.OnSleep(),
	CommonHandlers.OnFreeze(),

	EventHandler("doattack", function(inst) if not inst.components.health:IsDead() then inst.sg:GoToState("attack") end end),
	EventHandler("death", function(inst) inst.sg:GoToState("death") end),
	EventHandler("attacked", function(inst) if inst.components.health:GetPercent() > 0 and not inst.sg:HasStateTag("attack") then inst.sg:GoToState("hit") end end),
}

local states=
{
	State{
		name = "idle",
		tags = {"idle", "canrotate"},

		onenter = function(inst, pushanim)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("idle", true)
			inst.sg:SetTimeout(2 + 2*math.random())
		end,

		events=
		{
			EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle_loop") end),
		},
	},

	State{
		name = "idle_loop",
		tags = {"idle", "canrotate"},

		onenter = function(inst)
			
		end,


		timeline=
		{
			TimeEvent( 0*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.idle) end),
			TimeEvent(35*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.idle) end),
		},

		events=
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("idle_loop") end),
		},
	},

	State{
		name = "attack",
		tags = {"busy", "attack", "canrotate"},

		onenter = function(inst)
			inst.components.combat:StartAttack()
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("atk_pre")
			inst.AnimState:PushAnimation("atk", false)
		end,


		timeline=
		{
			TimeEvent(11*FRAMES, function(inst)
				if inst.components.combat.target then 
					inst:ForceFacePoint(inst.components.combat.target:GetPosition()) 
				end
				inst.SoundEmitter:PlaySound(inst.sounds.mouth_open)
			end),
			TimeEvent(25*FRAMES, function(inst)
				if inst.components.combat.target then 
					inst:ForceFacePoint(inst.components.combat.target:GetPosition()) 
				end
				SpawnWaves(inst, 2, 20, nil, nil, nil, nil, true)
				inst.components.combat:DoAttack()
				inst.SoundEmitter:PlaySound(inst.sounds.bite_chomp)
				inst.SoundEmitter:PlaySound(inst.sounds.bite)
			end),
		},

		events=
		{
			EventHandler("animqueueover", function(inst) inst.sg:GoToState("idle") end),
		},
	},

	State{
		name = "death",
		tags = {"busy"},

		onenter = function(inst)
			inst.SoundEmitter:PlaySound(inst.sounds.death)
			inst.AnimState:PlayAnimation("death")
			inst.components.locomotor:StopMoving()
			--inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
		end,

		events=
		{
			EventHandler("animqueueover", function(inst)
				local carcass = SpawnPrefab(inst.carcass)
				carcass.Transform:SetPosition(inst.Transform:GetWorldPosition())
			end),
		},
	},

	State{
		name = "walk_start",
		tags = {"moving", "canrotate"},

		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("walk_pre")
		end,

		timeline =
		{

			TimeEvent(12*FRAMES, function(inst)	inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/splash_large") end),
			-- TimeEvent(21*FRAMES, function(inst)	inst.components.locomotor:RunForward() end),
		},

		events =
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),
		},
	},

	State{
		name = "walk",
		tags = {"moving", "canrotate"},

		onenter = function(inst)
			inst.components.locomotor:RunForward()
			inst.AnimState:PlayAnimation("walk_loop")
		end,
		timeline =
		{
			TimeEvent(15*FRAMES, function(inst)
				inst.components.locomotor:WalkForward()
				inst.SoundEmitter:PlaySound(inst.sounds.breach_swim)
				inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/water_swimbreach_lrg")
			end ),
		},
		events=
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),
		},
	},

	State{
		name = "walk_stop",
		tags = {"canrotate"},

		onenter = function(inst)
			inst.components.locomotor:StopMoving()
		end,

		timeline =
		{
			TimeEvent(15*FRAMES, function(inst)
				inst.SoundEmitter:PlaySound(inst.sounds.breach_swim)
				inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/water_swimbreach_lrg")
			end ),
		},

		events=
		{
			EventHandler("animqueueover", function(inst) inst.sg:GoToState("walk_stop_emerge") end ),
		},
	},

	State{
		name = "walk_stop_emerge",
		tags = {"canrotate"},

		onenter = function(inst)
			inst.components.locomotor:StopMoving()
			inst.AnimState:PlayAnimation("walk_pst", false)
		end,

		timeline=
		{
			TimeEvent(11*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/water_emerge_lrg") end),
			TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/splash_large") end),
		},

		events=
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
		},
	},
}

CommonStates.AddSimpleState(states,"hit", "hit")

CommonStates.AddSleepStates(states,
{
	sleeptimeline =
	{
		TimeEvent(30*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.sleep) end)
	},
})
CommonStates.AddFrozenStates(states)

return StateGraph("whale", states, events, "idle")
