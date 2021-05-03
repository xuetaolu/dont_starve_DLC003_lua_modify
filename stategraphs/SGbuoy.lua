local actionhandlers = 
{
}

local events=
{
}

local states=
{
	State{
		name = "idle",

		onenter = function(inst)
			inst.AnimState:PlayAnimation("idle", true)
		end,

		timeline=
		{
			TimeEvent(23*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/bouy_bell") end),
			TimeEvent(77*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/bouy_bell") end)
		},

		events =
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
		},
	},

	State{
		name = "hit",

		onenter = function(inst)
			inst.AnimState:PlayAnimation("hit")
			inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/bouy_bell")
		end,

		events =
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
		},
	},

	State{
		name = "place",

		onenter = function(inst)
			inst.AnimState:PlayAnimation("place")
			inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/water_submerge_lrg")
		end,

		events =
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
		},
	},
}

return StateGraph("buoy", states, events, "idle", actionhandlers)