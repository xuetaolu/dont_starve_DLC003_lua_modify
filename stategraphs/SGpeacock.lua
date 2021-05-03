require("stategraphs/commonstates")

local actionhandlers = 
{
    ActionHandler(ACTIONS.GOHOME, "gohome"),
    ActionHandler(ACTIONS.EAT, "eat"),
    ActionHandler(ACTIONS.PICK, "pick"),
}


local events=
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnLocomote(true,true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    EventHandler("attacked", function(inst) if inst.components.health:GetPercent() > 0 and not inst.sg:HasStateTag("transform") then inst.sg:GoToState("hit") end end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("doattack", function(inst) if inst.components.health:GetPercent() > 0 and not inst.sg:HasStateTag("transform") then inst.sg:GoToState("attack") end end),
}

local function Gobble(inst)
    inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Peakcock/idle")
    inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Peakcock/hide")

end

local states=
{
    State{
        name= "gobble_idle",
        tags = {"idle"},
        
        onenter = function(inst)
			inst.Physics:Stop()
            Gobble(inst)
            
            inst.AnimState:PlayAnimation("idle_loop")
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },        
    },
    
    
	State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Peakcock/death")
            inst.AnimState:PlayAnimation("death")
            inst.components.locomotor:StopMoving()
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
            RemovePhysicsColliders(inst)            
        end,
        
    },

    
    State{
        name = "appear",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Peakcock/appear")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Peakcock/appear_pop")
            inst.Physics:Stop()	
            inst.AnimState:PlayAnimation("appear")
        end,
        
        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
    
    State{
        name = "attack",
        tags = {"attack"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Peakcock/attack")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_whoosh")
            inst.components.combat:StartAttack()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk")
        end,
        
        timeline =
        {
            TimeEvent(20*FRAMES, function(inst) inst.components.combat:DoAttack() end),
        },
        
        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },
    
    State{
        name = "eat",
        
        tags = {"busy"},
        
        onenter = function(inst)
        	inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Peakcock/eat")
            inst.AnimState:PlayAnimation("eat")
            inst.Physics:Stop()            
        end,
        
        timeline=
        {
            TimeEvent(10*FRAMES, function(inst)
                inst:PerformBufferedAction()
                inst.sg:RemoveStateTag("busy")
                inst.sg:AddStateTag("idle")
            end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },        
    },
    
    --State{
        --name = "pick",
        --
        --tags = {"busy"},
        --
        --onenter = function(inst)
            --inst.AnimState:PlayAnimation("take")
            --inst.Physics:Stop()            
        --end,
        --
        --timeline=
        --{
            --TimeEvent(9*FRAMES, function(inst)
                --inst:PerformBufferedAction()
                --inst.sg:RemoveStateTag("busy")
                --inst.sg:AddStateTag("idle")
            --end),
        --},
        --
        --events=
        --{
            --EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        --},        
    --},
    State{
        name = "hit",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Peakcock/hurt")
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },        
    },    
}

CommonStates.AddWalkStates(states,
{
    starttimeline = 
    {
		TimeEvent(0*FRAMES, Gobble),
    },
    
	walktimeline = {
		TimeEvent(0*FRAMES, PlayFootstep ),
		TimeEvent(12*FRAMES, PlayFootstep ),
	},
})
CommonStates.AddRunStates(states,
{
    starttimeline = 
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Peakcock/attack") end ),
    },
    
	runtimeline = {
		TimeEvent(0*FRAMES, PlayFootstep ),
		TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Peakcock/move") end ),
		TimeEvent(10*FRAMES, PlayFootstep ),
	},
})

CommonStates.AddSleepStates(states,
{
    starttimeline = 
    {
		TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Peakcock/sleep") end ),
    },
    
	sleeptimeline = {
        TimeEvent(40*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/Peakcock/sleep") end),
	},
})

CommonStates.AddIdle(states,"gobble_idle")

CommonStates.AddSimpleActionState(states, "gohome", "hit", 4*FRAMES, {"busy"})
CommonStates.AddSimpleActionState(states, "pick", "take", 9*FRAMES, {"busy"})
CommonStates.AddFrozenStates(states)

    
return StateGraph("Peakcock", states, events, "idle", actionhandlers)

