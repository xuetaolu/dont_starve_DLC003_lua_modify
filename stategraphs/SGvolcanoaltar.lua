require("stategraphs/commonstates")

local actionhandlers = 
{
}

local events=
{
}

local states=
{
	State{
		name = "open",

		onenter = function(inst)
			inst.AnimState:PlayAnimation("open")
		end,

		timeline=
		{
			TimeEvent(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/volcano_alter/slide_open") end),
			TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/volcano_alter/open") end)
		},

		events =
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("opened") end)
		},
	},

	State{
		name = "opened",

		onenter = function(inst)
			inst.AnimState:PlayAnimation("idle_open", true)
		end,
	},

	State{
		name = "close",

		onenter = function(inst)
			inst.AnimState:PlayAnimation("close")
		end,

		timeline=
		{
			TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/volcano_alter/slide_close") end),
			TimeEvent(22*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/volcano_alter/close") end)
		},

		events =
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("closed") end)
		},
	},

	State{
		name = "closed",

		onenter = function(inst)
			inst.AnimState:PlayAnimation("idle_close", true)
		end,
	},

	State{
		name = "appeased",

		onenter = function(inst)
			inst.AnimState:PlayAnimation("appeased_pre")
			inst.AnimState:PushAnimation("appeased")
			inst.AnimState:PushAnimation("appeased_pst", false)
			inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/volcano_alter/splash")
			inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/volcano_alter/appeased")
		end,

		events =
		{
			EventHandler("animqueueover", function(inst)
				--if inst.appeasements < TUNING.VOLCANO_ALTAR_MAXAPPEASEMENTS then
				if inst:FullAppeased() then
					inst.sg:GoToState("close")
				else
					inst.sg:GoToState("opened")
				end
			end)
		},
	},

	State{
		name = "unappeased",

		onenter = function(inst)
			inst.AnimState:PlayAnimation("unappeased", false)
			inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/volcano_alter/splash")
			inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/volcano_alter/unappeased")
		end,

		events =
		{
			EventHandler("animover", function(inst)
				--if inst.appeasements < TUNING.VOLCANO_ALTAR_MAXAPPEASEMENTS then
					inst.sg:GoToState("opened")
				--else
				--	inst.sg:GoToState("close")
				--end
			end)
		},
	},
}

return StateGraph("volcanoaltar", states, events, "closed", actionhandlers)
