require("stategraphs/commonstates")

local actionhandlers = 
{
	ActionHandler(ACTIONS.EAT, "eat"),
	ActionHandler(ACTIONS.GOHOME, "gohome"),
}

local events=
{
	CommonHandlers.OnSleep(),
	CommonHandlers.OnFreeze(),
	CommonHandlers.OnDeath(),
	CommonHandlers.OnAttacked(),
	CommonHandlers.OnLocomote(true, true),
	EventHandler("trapped", function(inst) inst.sg:GoToState("trapped") end),
}

local states=
{
	State{
		
		name = "idle",
		tags = {"idle", "canrotate"},
		onenter = function(inst, playanim)
			inst.Physics:Stop()
			if playanim then
				inst.AnimState:PlayAnimation(playanim)
				inst.AnimState:PushAnimation("idle", true)
			else
				inst.AnimState:PlayAnimation("idle", true)
			end
		end,
	},
	
	State{
		
		name = "gohome",
		tags = {"busy"},
		onenter = function(inst, playanim)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("burrow")
			inst.components.health:SetInvincible(true)
			inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/lobster/burrow")
		end,
		events=
		{
			EventHandler("animover", function (inst, data) 
				inst:PerformBufferedAction()
				inst.sg:GoToState("idle")
			end),
		},
		onexit = function(inst)
			inst.components.health:SetInvincible(false)
		end,
	},
	
	State{
		name = "eat",
		-- TEMP ART!!!!
		onenter = function(inst)
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("sleep_pre", false)
			inst.AnimState:PushAnimation("sleep_loop", true)
			inst.sg:SetTimeout(2+math.random()*4)
		end,
		
		ontimeout= function(inst)
			inst:PerformBufferedAction()
			inst.sg:GoToState("idle", "sleep_pst")
		end,
	},    

	State{
		name = "death",
		tags = {"busy"},
		
		onenter = function(inst)
			inst.AnimState:PlayAnimation("death")
			inst.Physics:Stop()
			RemovePhysicsColliders(inst)
			inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/lobster/death")
		end,

		events =
		{
			EventHandler("animover", function(inst) inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition())) end)
		},

	}, 

	State{
		name = "fall",
		tags = {"busy", "stunned"},
		onenter = function(inst)
			inst.Physics:SetDamping(0)
			inst.Physics:SetMotorVel(0,-20+math.random()*10,0)
			inst.AnimState:PlayAnimation("stunned_loop", true)
			inst:CheckTransformState()
		end,
		
		onupdate = function(inst)
			local pt = Point(inst.Transform:GetWorldPosition())
			if pt.y < 2 then
				inst.Physics:SetMotorVel(0,0,0)
			end
			
			if pt.y <= .1 then
				pt.y = 0

				inst.Physics:Stop()
				inst.Physics:SetDamping(5)
				inst.Physics:Teleport(pt.x,pt.y,pt.z)
				inst.DynamicShadow:Enable(true)
				inst.sg:GoToState("stunned")
			end
		end,

		onexit = function(inst)
			local pt = inst:GetPosition()
			pt.y = 0
			inst.Transform:SetPosition(pt:Get())
		end,
	},    
	
	State{
		name = "stunned",
		tags = {"busy", "stunned"},
		
		onenter = function(inst) 
			inst.Physics:Stop()
			inst.AnimState:PlayAnimation("stunned_loop", true)
			if inst.components.inventoryitem then
				inst.components.inventoryitem.canbepickedup = true
			end
		end,
		
		onexit = function(inst)
			if inst.components.inventoryitem then
				inst.components.inventoryitem.canbepickedup = false
			end
		end,
		
		ontimeout = function(inst) inst.sg:GoToState("idle") end,
	},
	
	State{
		name = "trapped",
		tags = {"busy", "trapped"},
		
		onenter = function(inst) 
			inst.Physics:Stop()
			inst:ClearBufferedAction()
			inst.AnimState:PlayAnimation("idle", true)
			inst.sg:SetTimeout(2)
		end,
		
		ontimeout = function(inst) inst.sg:GoToState("idle") end,
	},
	State{
		name = "hit",
		tags = {"busy"},
		
		onenter = function(inst)
			inst.AnimState:PlayAnimation("hit")
			inst.Physics:Stop()            
		end,
		
		events=
		{
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
		},        
	},    

}
CommonStates.AddWalkStates(states, {
	starttimeline =
	{
		TimeEvent(0, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/lobster/walk") end)
	},

	walktimeline =
	{
		TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/lobster/walk") end),
		TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/lobster/walk") end),
		TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/lobster/walk") end),
	},

	endtimeline = 
	{
		TimeEvent(0, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/lobster/walk") end)
	},
}, {walk = "walk"})
CommonStates.AddRunStates(states, {
	starttimeline =
	{
		TimeEvent(0, function(inst) 
			inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/lobster/run") 
			inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/lobster/scared") 
		end)
	},

	runtimeline =
	{
		TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/lobster/run") end),
		TimeEvent(2*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/lobster/run") end),
		TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/lobster/run") end),
		TimeEvent(6*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/lobster/run") end),
	},

	endtimeline = 
	{
		TimeEvent(0, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/lobster/run") end)
	},
}, {run = "run", stoprun = "idle"})
CommonStates.AddSleepStates(states)
CommonStates.AddFrozenStates(states)

  
return StateGraph("lobster", states, events, "idle", actionhandlers)