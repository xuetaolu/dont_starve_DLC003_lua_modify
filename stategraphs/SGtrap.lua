local events=
{
	EventHandler("ondropped", function(inst)
		if inst.components.trap then
			inst.components.trap:Set()
			inst.sg:GoToState("idle")
		end
	end),
	EventHandler("onpickup", function(inst)
		if inst.components.trap then
			inst.components.trap:DropLoot()
			inst.components.trap:Disarm()
		end
	end),
	EventHandler("harvesttrap", function(inst)
		if inst.components.trap then
			inst.components.trap:Disarm()
		end
	end),
}

local states=
{
	State{
		name = "idle",
		onenter = function(inst)
			inst.AnimState:PlayAnimation("idle")
		end,

		events=
		{
			EventHandler("springtrap", function(inst)
				if inst.entity:IsAwake() then
					inst.sg:GoToState("sprung")
				else
					inst.components.trap:DoSpring()
					inst.sg:GoToState("full")
				end
			end),
		}
	},

	State{
		name = "full",
		onenter = function(inst, target)
			local trappedname = inst.components.trap.lootprefabs and inst.components.trap.lootprefabs[1]
			if trappedname == 'doydoy' or trappedname == 'doydoybaby' then
				inst.AnimState:PlayAnimation("trap_loop_doydoy")
			else
				inst.AnimState:PlayAnimation("trap_loop")
			end
			inst.SoundEmitter:PlaySound(inst.sounds.rustle)
		 end,

		events=
		{
			EventHandler("harvesttrap", function(inst) inst.sg:GoToState("idle") end),
			EventHandler("animover", function(inst) inst.sg:GoToState("full") end),
		},
	},

	State{
		name = "empty",
		onenter = function(inst, target)
			inst.AnimState:PlayAnimation("side")
		 end,

		events=
		{
			EventHandler("harvesttrap", function(inst) inst.sg:GoToState("idle") end),
		},
	},

	State{
		name = "sprung",
		onenter = function(inst, target)
			if inst.components and inst.components.trap and inst.components.trap.target and (inst.components.trap.target.prefab == 'doydoy' or inst.components.trap.target.prefab == 'doydoybaby') then
				inst.AnimState:PlayAnimation("trap_pre_doydoy")
			else
				inst.AnimState:PlayAnimation("trap_pre")
			end
		end,

		events=
		{
			EventHandler("animover", function(inst)
				inst.SoundEmitter:PlaySound(inst.sounds.close)
				inst.components.trap:DoSpring()
				if inst.components.trap.lootprefabs then
					inst.sg:GoToState("full")
				else
					inst.sg:GoToState("empty")
				end
			end),
		}
	},

}


return StateGraph("trap", states, events, "idle")

