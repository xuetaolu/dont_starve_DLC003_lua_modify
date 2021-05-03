require("stategraphs/commonstates")

local actionhandlers = {}

local events = 
{
	-- EventHandler("lightningstrike", function(inst) 
	--     if not inst.EggHatched then
	--         inst.sg:GoToState("crack")
	--     end
	-- end),
}


local states =
{   
	State{
		name = "bloat1_pre",
		tags = {"busy"},

		onenter = function(inst)
			inst.AnimState:PlayAnimation("idle_pre")
		end,

		-- timeline = {},

		events = {
			EventHandler("animover", function(inst) inst.sg:GoToState("bloat1") end)
		},
	},

	State{
		name = "bloat1",
		tags = {"idle"},
		
		onenter = function(inst)
			inst.AnimState:PlayAnimation("idle_bloat1")
		end,

		events = {
            EventHandler("animover", function(inst) inst.sg:GoToState("bloat1") end),
        }
	},

	State{
		name = "bloat2_pre",
		tags = {"busy"},
		
		onenter = function(inst)
			inst.AnimState:PlayAnimation("idle_trans1_2")
			inst.SoundEmitter:PlaySound(inst.sounds.bloated1)
		end,

		events = {
            EventHandler("animover", function(inst) inst.sg:GoToState("bloat2") end),
        }
	},

	State{
		name = "bloat2",
		tags = {"idle"},
		
		onenter = function(inst)
			inst.AnimState:PlayAnimation("idle_bloat2")
		end,

			-- inst.SoundEmitter:PlaySound(inst.sounds.stinks, "whalestinks")
		events = {
            EventHandler("animover", function(inst) inst.sg:GoToState("bloat2") end),
        }
	},

	State{
		name = "bloat3_pre",
		tags = {"busy"},
		
		onenter = function(inst)
			inst.AnimState:PlayAnimation("idle_trans2_3")
			inst.SoundEmitter:PlaySound(inst.sounds.bloated2)
		end,

		events = {
            EventHandler("animover", function(inst) inst.sg:GoToState("bloat3") end),
        }
	},

	State{
		name = "bloat3",
		tags = {"idle"},
		
		onenter = function(inst)
			inst.AnimState:PlayAnimation("idle_bloat3")
		end,

		timeline = 
		{
			TimeEvent( 0*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.stinks) end),
			TimeEvent(18*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.stinks) end),
			TimeEvent(48*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.stinks) end),
		},

		events = {
            EventHandler("animover", function(inst) inst.sg:GoToState("bloat3") end),
        }
	},

	State{
		name = "explode",
		tags = {"busy"},

		onenter = function(inst)
			inst.AnimState:PlayAnimation("explode", false)
			inst.SoundEmitter:PlaySound(inst.sounds.explosion)
		end,
	},
}
	
return StateGraph("whalecarcass", states, events, "bloat1_pre", actionhandlers)
