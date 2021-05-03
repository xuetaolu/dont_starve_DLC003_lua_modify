require("stategraphs/commonstates")

local actionhandlers =
{
	ActionHandler(ACTIONS.GOHOME, "action"),
}

local events=
{
	-- EventHandler("locomote", function(inst)

 --        local is_moving = inst.sg:HasStateTag("moving")
 --        local is_flying = not inst.sg:HasStateTag("swimming")
 --        local is_idling = inst.sg:HasStateTag("idle")
 --        local is_flying_forward = inst.sg:HasStateTag("running")

 --        local should_move = inst.components.locomotor:WantsToMoveForward()
 --        local should_fly = inst.components.locomotor:WantsToRun()

 --        if is_moving and not should_move then
 --        	if is_flying then
 --        		inst.sg:GoToState("idle")
 --        	else
 --        		inst.sg:GoToState("swim_stop")
 --        	end
 --        elseif (is_idling and should_move) or (is_moving and should_move and is_flying ~= should_fly) then
 --        	if should_fly and not is_flying then
 --        		inst.sg:GoToState("emerge")
 --        	elseif should_move and (is_flying and not should_fly) then
 --        		inst.sg:GoToState("submerge")
 --        	elseif should_move and not is_flying then
 --        		inst.sg:GoToState("swim_start")
 --    		elseif should_fly and is_flying then
 --    			inst.sg:GoToState("fly")
 --    		end
 --        end

	-- 	-- if not inst.sg:HasStateTag("idle") and not inst.sg:HasStateTag("moving") then return end

	-- 	-- if not inst.components.locomotor:WantsToMoveForward() then
	-- 	-- 	if not inst.sg:HasStateTag("idle") then
	-- 	-- 		if inst.sg:HasStateTag("swimming") then
	-- 	-- 			inst.sg:GoToState("swim_idle")
	-- 	-- 		else
	-- 	-- 			inst.sg:GoToState("idle")
	-- 	-- 		end
	-- 	-- 	end
	-- 	-- elseif inst.components.locomotor:WantsToRun() then
	-- 	-- 	if inst.sg:HasStateTag("swimming") then
	-- 	-- 		inst.sg:GoToState("emerge")
	-- 	-- 	else
	-- 	-- 		inst.sg:GoToState("run")
	-- 	-- 	end
	-- 	-- elseif inst.components.locomotor:WantsToMoveForward() then
	-- 	-- 	if inst.sg:HasStateTag("swimming") then
	-- 	-- 		inst.sg:GoToState("swim_start")
	-- 	-- 	else
	-- 	-- 		inst.sg:GoToState("submerge")
	-- 	-- 	end
	-- 	-- end
	-- end),
	CommonHandlers.OnLocomote(true, true),
	CommonHandlers.OnFreeze(),
	CommonHandlers.OnAttack(),
	CommonHandlers.OnAttacked(),
	CommonHandlers.OnDeath(),
	CommonHandlers.OnSleep(),
	-- EventHandler("gotosleep", function(inst)
	-- 	-- print('gotosleep')
	-- 	if inst.components.health and inst.components.health:GetPercent() > 0 then
	-- 		if inst.sg:HasStateTag("sleeping") then
	-- 			-- print('has sleeping')
	-- 			if inst.sg:HasStateTag("swimming") then
	-- 				inst.sg:GoToState("swim_sleep")
	-- 			else
	-- 				inst.sg:GoToState("sleeping")
	-- 			end
	-- 		else
	-- 			-- print('has no sleeping')
	-- 			if inst.sg:HasStateTag("swimming") then
	-- 				-- print('swim_sleep')
	-- 				inst.sg:GoToState("swim_sleep")
	-- 			else
	-- 				-- print('sleep')
	-- 				inst.sg:GoToState("sleep")
	-- 			end
	-- 		end
	-- 	end
	-- end),
}

local function GoToLocoState(inst, state)
	if inst:IsLocoState(state) then
		return true
	end
	inst.sg:GoToState("goto"..string.lower(state), {endstate = inst.sg.currentstate.name})
end

local states =
{

	State{
		name = "gotoswim",
		tags = {"busy", "swimming"},
		onenter = function(inst, data)
			inst.AnimState:PlayAnimation("submerge")
			inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/water_submerge_sml")
			inst.Physics:Stop()
            inst.sg.statemem.endstate = data.endstate

            --[[
			local splash = SpawnPrefab("splash_water")
			local pos = inst:GetPosition()
			splash.Transform:SetPosition(pos.x, pos.y, pos.z)
			--]]
		end,

		onexit = function(inst)
			inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
			inst.Transform:SetNoFaced()
			inst.DynamicShadow:Enable(false)
			inst:SetLocoState("swim")
		end,

		events=
		{
			EventHandler("animover", function(inst)
				inst.Transform:SetScale(inst.scale_water, inst.scale_water, inst.scale_water)
				inst.sg:GoToState(inst.sg.statemem.endstate)
			end),
		},
	},

	State{
		name = "gotofly",
		tags = {"busy"},
		onenter = function(inst, data)
			inst.AnimState:SetOrientation(ANIM_ORIENTATION.Default)
			inst.Transform:SetFourFaced()
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("emerge")
			inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/water_emerge_sml")
	        inst.sg.statemem.endstate = data.endstate
	        inst.DynamicShadow:Enable(true)

	        inst.Transform:SetScale(inst.scale_flying, inst.scale_flying, inst.scale_flying)

			--[[
			local splash = SpawnPrefab("splash_water")
			local pos = inst:GetPosition()
			splash.Transform:SetPosition(pos.x, pos.y, pos.z)
			--]]
		end,

		onexit = function(inst)
			inst:SetLocoState("fly")
		end,

		events=
		{
			EventHandler("animover", function(inst)
				inst.sg:GoToState(inst.sg.statemem.endstate)
			end),
		},
	},

	State{
		name = "idle",
		tags = {"idle", "canrotate"},
		onenter = function(inst, playanim)
			if GoToLocoState(inst, "fly") then
				inst.Physics:Stop()
				inst.AnimState:PlayAnimation("fly_loop", true)
				inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Stinkray/idle")
			end
		end,

		timeline =
		{
			TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Stinkray/wingflap")  end ),
			TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Stinkray/wingflap")  end ),
		},

		events=
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
		},
	},

	State{
		name = "action",
		onenter = function(inst)
			if GoToLocoState(inst, "fly") then
				inst.Physics:Stop()
				inst.AnimState:PlayAnimation("fly_loop", true)
				inst:PerformBufferedAction()
			end
		end,

		timeline =
		{
			TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Stinkray/wingflap")  end ),
			TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Stinkray/wingflap")  end ),
		},

		events=
		{
			EventHandler("animover", function (inst)
				inst.sg:GoToState("idle")
			end),
		}
	},

	State{
		name = "taunt",
		tags = {"busy"},

		onenter = function(inst)
			if GoToLocoState(inst, "fly") then
				inst.Physics:Stop()
				inst.AnimState:PlayAnimation("taunt")
			end
		end,

		timeline =
		{
			TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Stinkray/taunt") end ),
			-- TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Stinkray/wingflap") end ),
		},

		events=
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
		},
	},

	 State{ --This state isn't really necessary but I'm including it to make the default "OnLocomote" work
        name = "run_start",
        tags = {"moving", "running", "canrotate"},

        onenter = function(inst)
			if GoToLocoState(inst, "fly") then
				inst.components.locomotor:RunForward()
				inst.AnimState:PlayAnimation("fly_loop")
			end
        end,

        timeline =
		{
			TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Stinkray/wingflap")  end ),
			TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Stinkray/wingflap")  end ),
		},

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),
        },
    },

	State{
		name = "run",
		tags = {"moving", "canrotate", "running"},

		onenter = function(inst)
			if GoToLocoState(inst, "fly") then
				inst.components.locomotor:RunForward()
				inst.AnimState:PlayAnimation("fly_loop")
			end
		end,

		timeline =
		{
			TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Stinkray/wingflap")  end ),
			TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Stinkray/wingflap")  end ),
		},

		events=
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),
		},
	},

	State{ --This state isn't really necessary but I'm including it to make the default "OnLocomote" work
        name = "run_stop",
        tags = {"idle"},

        onenter = function(inst)
			if GoToLocoState(inst, "fly") then
				inst.components.locomotor:StopMoving()
				--We don't need to play an animation here because it is the same animation as
				--the "run" state. Just let that one finish playing.
			end
        end,

        timeline =
		{
			TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Stinkray/wingflap")  end ),
			TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Stinkray/wingflap")  end ),
		},

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },

	State{
		name = "swim_idle",
		tags = {"idle", "canrotate", "swimming"},
		onenter = function(inst)
			if GoToLocoState(inst, "swim") then
				inst.Physics:Stop()
				inst.AnimState:PlayAnimation("shadow", true)
			end
		end,

		events=
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("swim_idle") end),
		},
	},

	State{
		name = "walk_start",
		tags = {"moving", "canrotate", "swimming"},

		onenter = function(inst)
			if GoToLocoState(inst, "swim") then
				inst.components.locomotor:WalkForward()
				inst.AnimState:PlayAnimation("shadow")
			end
		end,

		events =
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),
		},
	},

	State{
		name = "walk",
		tags = {"moving", "canrotate", "swimming"},

		onenter = function(inst)
			if GoToLocoState(inst, "swim") then
				inst.components.locomotor:WalkForward()
				inst.AnimState:PlayAnimation("shadow")
			end
		end,

		events=
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),
		},
	},

	State{
		name = "walk_stop",
		tags = {"canrotate", "swimming"},

		onenter = function(inst)
			if GoToLocoState(inst, "swim") then
				inst.components.locomotor:StopMoving()
				inst.AnimState:PlayAnimation("shadow")
			end
		end,

		events=
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("swim_idle") end ),
		},
	},

    State{
        name = "sleep",
        tags = {"busy", "sleeping"},

        onenter = function(inst)
            if GoToLocoState(inst, "fly") then
            	inst.components.locomotor:StopMoving()
            	inst.AnimState:PlayAnimation("sleep_pre")
        	end
        end,

        timeine =
        {
        	TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Stinkray/sleep") end),
        	-- TimeEvent(9*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Stinkray/sleep") end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("sleeping") end ),
            EventHandler("onwakeup", function(inst) inst.sg:GoToState("wake") end),
        },
    },

    State{

        name = "sleeping",
        tags = {"busy", "sleeping"},

        onenter = function(inst)
            if GoToLocoState(inst, "fly") then
            	inst.AnimState:PlayAnimation("sleep_loop")
            end
        end,

        timeine =
        {
			TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Stinkray/sleep") end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("sleeping") end ),
            EventHandler("onwakeup", function(inst) inst.sg:GoToState("wake") end),
        },
    },

    State{
        name = "wake",
        tags = {"busy", "waking"},

        onenter = function(inst)
            if GoToLocoState(inst, "fly") then
	            inst.components.locomotor:StopMoving()
	            inst.AnimState:PlayAnimation("sleep_pst")
	            if inst.components.sleeper and inst.components.sleeper:IsAsleep() then
	                inst.components.sleeper:WakeUp()
	            end
	        end
        end,

        timeine =
        {
        	TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Stinkray/wingflap") end ),
			TimeEvent(9*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Stinkray/wingflap") end ),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },

    State{
        name = "frozen",
        tags = {"busy", "frozen"},

        onenter = function(inst)
	        if GoToLocoState(inst, "fly") then
	            if inst.components.locomotor then
	                inst.components.locomotor:StopMoving()
	            end
	            inst.AnimState:PlayAnimation("frozen_loop", true)
	            inst.SoundEmitter:PlaySound("dontstarve/common/freezecreature")
	            inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
	        end
        end,

        onexit = function(inst)
            inst.AnimState:ClearOverrideSymbol("swap_frozen")
        end,

        events=
        {
            EventHandler("onthaw", function(inst) inst.sg:GoToState("thaw") end ),
        },
    },

    State{
        name = "thaw",
        tags = {"busy", "thawing"},

        onenter = function(inst)
        	if GoToLocoState(inst, "fly") then
	            if inst.components.locomotor then
	                inst.components.locomotor:StopMoving()
	            end
	            inst.AnimState:PlayAnimation("frozen_loop_pst", true)
	            inst.SoundEmitter:PlaySound("dontstarve/common/freezethaw", "thawing")
	            inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
	        end
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("thawing")
            inst.AnimState:ClearOverrideSymbol("swap_frozen")
        end,

        events =
        {
            EventHandler("unfreeze", function(inst)
                if inst.sg.sg.states.hit then
                    inst.sg:GoToState("hit")
                else
                    inst.sg:GoToState("idle")
                end
            end ),
        },
    },

    State{
        name = "hit",
        tags = {"hit", "busy"},

        onenter = function(inst)
        	if GoToLocoState(inst, "fly") then
	            inst.components.locomotor:StopMoving()
	            inst.AnimState:PlayAnimation("hit")
	        end
        end,

        timeline =
        {
			TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Stinkray/hurt") end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "attack",
        tags = {"attack", "busy"},

        onenter = function(inst, target)
        	if GoToLocoState(inst, "fly") then
	            inst.components.locomotor:StopMoving()
	            inst.components.combat:StartAttack()
	            inst.AnimState:PlayAnimation("atk")
	        end
        end,

        timeline =
        {
        	TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Stinkray/wingflap") end ),
        	TimeEvent(7*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Stinkray/wingflap") end ),
			TimeEvent(8* FRAMES, function(inst)
				inst.components.combat:DoAttack()
				inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Stinkray/attack")
			end),
        	TimeEvent(19*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Stinkray/wingflap") end ),
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
        	if GoToLocoState(inst, "fly") then
	            inst.AnimState:PlayAnimation("death")
                inst.components.locomotor:StopMoving()
				inst.Physics:ClearCollisionMask()
	            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
	        end
        end,

        timeline =
        {
			TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Stinkray/death") end),
			-- I need a splash sound here...
			--TimeEvent(17*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Stinkray/wingflap") end ),
        },
    },

}

return StateGraph("stungray", states, events, "swim_idle", actionhandlers)
