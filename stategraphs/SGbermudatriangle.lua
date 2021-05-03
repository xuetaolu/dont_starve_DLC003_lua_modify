require("stategraphs/commonstates")

local actionhandlers=
{

}

local events=
{

}

local states=
{
	State{
		name = "idle",
		tags = {"idle"},
		onenter = function(inst)
			inst.AnimState:PlayAnimation("idle_loop")
		end,

		onexit = function(inst)
			inst.SoundEmitter:SetVolume("idle", 0.0)
		end,

        timeline=
        {
            TimeEvent(14*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/bermudatriangle_sparks_inactive", "idle") end),
        },

		events =
		{
			EventHandler("animover", function(inst)
				inst.sg:GoToState("idle")
			end),
		},
	},

	State{
		name = "open",
		tags = {"idle", "open"},
		onenter = function(inst)
			inst.AnimState:PlayAnimation("open_loop")
			-- since we can jump right to the open state, retrigger this sound.
			inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/bermudatriangle_lp", "wormhole_open")
		end,

		onexit = function(inst)
			inst.SoundEmitter:KillSound("wormhole_open")
		end,

        timeline=
        {
            TimeEvent(2*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/bermudatriangle_sparks_active") end),
            TimeEvent(42*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/bermudatriangle_sparks_active") end),
        },

		events =
		{
			EventHandler("animover", function(inst)
				inst.sg:GoToState("open")
			end),
		},
	},

	State{
		name = "opening",
		tags = {"busy", "open"},
		onenter = function(inst)
			inst.AnimState:PlayAnimation("open_pre")
			inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/bermudatriangle_open", "wormhole_opening")
		end,

		events=
		{
			EventHandler("animover", function(inst)
				inst.sg:GoToState("open")
			end),
		},
	},
		
	State{
		name = "closing",
		tags = {"busy"},
		onenter = function(inst)
			inst.AnimState:PlayAnimation("open_pst")
			inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/bermudatriangle_close", "wormhole_closing")
		end,

		events=
		{
			EventHandler("animover", function(inst)
				inst.sg:GoToState("idle")
			end),
		},
	},
}

return StateGraph("bermudatriangle", states, events, "idle", actionhandlers)
