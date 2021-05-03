require("stategraphs/commonstates")

local WALK_SPEED = 5

local actionhandlers =
{
    ActionHandler(ACTIONS.GOHOME, "action"),
    ActionHandler(ACTIONS.POLLINATE, function(inst)
        --[[
		if inst.sg:HasStateTag("landed") then
			return "pollinate"
		else
			return "land"
		end
        ]]
    end),
}

local events=
{
    EventHandler("hatch", function(inst) 
        if inst:HasTag("cocoon") then
            inst.sg:GoToState("cocoon_pst")
        end
    end),
    EventHandler("cocoon", function(inst) 
        if not inst.sg:HasStateTag("busy") then
            inst:RemoveTag("wantstococoon")
            inst.changetococoon(inst,false)           
                       
        end
    end),
    EventHandler("attacked", function(inst) 
        if inst.components.health:GetPercent() > 0 then
            if inst:HasTag("cocoon") then
                inst.sg:GoToState("cocoon_hit") 
            else  
                inst.sg:GoToState("hit") 
            end
        end 
    end),
    EventHandler("doattack", function(inst) if inst.components.health:GetPercent() > 0 and not inst.sg:HasStateTag("busy") then inst.sg:GoToState("attack") end end),
    EventHandler("death", function(inst) 
        if inst:HasTag("cocoon") then
            inst.sg:GoToState("cocoon_death") 
        else
            inst.sg:GoToState("death") 
        end
    end),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),


    EventHandler("locomote", function(inst)
        if not inst.sg:HasStateTag("busy") and not inst:HasTag("cocoon") then
			local wants_to_move = inst.components.locomotor:WantsToMoveForward()
			if not inst.sg:HasStateTag("attack") then
				if wants_to_move then
					inst.sg:GoToState("moving")
				else                    
					inst.sg:GoToState("idle")
				end
			end
        end
    end),
}


local function spawnRabidBeetle(inst)
    local pos = Vector3(inst.Transform:GetWorldPosition() )

    local bug = SpawnPrefab("rabid_beetle")
    if bug then
        bug.Transform:SetPosition(pos.x,pos.y,pos.z)
        bug.sg:GoToState("hatch")
    end 
end

local states=
{


    State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)

			-- inst.SoundEmitter:KillSound("buzz")
			inst.SoundEmitter:PlaySound(inst.sounds.death)

            if inst:HasTag("cocoon") then
                inst.AnimState:PlayAnimation("cocoon_death")
            else
                inst.AnimState:PlayAnimation("death")
            end

			inst.Physics:Stop()
			RemovePhysicsColliders(inst)
			if inst.components.lootdropper then
				inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
			end
        end,

		events=
        {
            EventHandler("animover", function(inst) inst:Remove() end),
        },
    },

    State{
        name = "action",
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle", true)
            inst:PerformBufferedAction()
        end,
        events=
        {
            EventHandler("animover", function (inst)
                inst.sg:GoToState("idle")
            end),
        }
    },

    State{
        name = "moving",
        tags = {"moving", "canrotate"},

        onenter = function(inst)        
            inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("walk_loop", false)
        end,

        timeline=
        {
            TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/glowfly/buzz") end),
            TimeEvent(9*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/glowfly/buzz") end),
            TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/glowfly/buzz") end),
        -- TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/glowfly/buzz") end),
        },        


        events=
        {
            EventHandler("animover", function (inst)
                inst.sg:GoToState("moving")
            end),
        }
        --[[
        ontimeout = function(inst)
			inst.sg:GoToState("moving")
        end,
        ]]
    },


    State{
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst)           
        print("AT IDLE")
            inst.Physics:Stop()
            if inst:HasTag("cocoon") then
                inst.AnimState:PlayAnimation("cocoon_idle_loop", true) 
            else
                inst.AnimState:PlayAnimation("walk_loop", false)            
            end
        end,

        timeline=
        {
            TimeEvent(3*FRAMES, function(inst) if not inst:HasTag("cocoon") then inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/glowfly/buzz") end end),
            TimeEvent(6*FRAMES, function(inst) if not inst:HasTag("cocoon") then inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/glowfly/buzz") end end),
            TimeEvent(9*FRAMES, function(inst) if not inst:HasTag("cocoon") then inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/glowfly/buzz") end end),
            TimeEvent(12*FRAMES, function(inst) if not inst:HasTag("cocoon") then inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/glowfly/buzz") end end),
            TimeEvent(15*FRAMES, function(inst) if not inst:HasTag("cocoon") then inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/glowfly/buzz") end end),
        -- TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/glowfly/buzz") end),
        },        

        events=
        {
            EventHandler("animover", function (inst)
                inst.sg:GoToState("idle")
            end),
        }        
    },

    State{
        name = "attack",
        tags = {"attack"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk")
        end,

        timeline=
        {
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.attack) end),
            TimeEvent(15*FRAMES, function(inst) inst.components.combat:DoAttack() end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "hit",
        tags = {"busy"},

        onenter = function(inst)
            inst.SoundEmitter:PlaySound(inst.sounds.hit)
            inst.AnimState:PlayAnimation("hit")
            inst.Physics:Stop()
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },

    State{
        name = "cocoon_pre",
        tags = {"cocoon","busy"},

        onenter = function(inst)
            print("AT THE STATE")
            -- inst.SoundEmitter:KillSound("buzz")
            inst.Physics:Stop()            
            inst.AnimState:PlayAnimation("cocoon_idle_pre")            
        end,
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },        
    },

    State{
        name = "cocoon_pst",
        tags = {"cocoon","busy"},

        onenter = function(inst)           
            inst.Physics:Stop()
            spawnRabidBeetle(inst)
            inst.AnimState:PlayAnimation("cocoon_idle_pst")            
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst:Remove() end),
        },        
    },

    State{
        name = "cocoon_expire",
        tags = {"cocoon","busy"},

        onenter = function(inst)           
            inst.AnimState:PlayAnimation("cocoon_idle_pst")            
        end,
        
        events=
        {
            EventHandler("animover", function(inst) inst:Remove() end),
        },        
    },

    State{
        name = "cocoon_hit",
        tags = {"cocoon","busy"},

        onenter = function(inst)
            inst.SoundEmitter:PlaySound(inst.sounds.hit)
            inst.AnimState:PlayAnimation("cocoon_hit")
            inst.Physics:Stop()
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },
    },

    State{
        name = "cocoon_death",
        tags = {"cocoon","busy"},

        onenter = function(inst)
            
            inst.AnimState:PlayAnimation("cocoon_death")

            RemovePhysicsColliders(inst)
            if inst.components.lootdropper then
                inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
            end
        end,

        events=
        {
            EventHandler("animover", function(inst) inst:Remove() end),
        },
    },
}
--[[
CommonStates.AddRunStates(states,
{
    runtimeline = {
        TimeEvent(3*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/glowfly/buzz") end),
        TimeEvent(9*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/glowfly/buzz") end),
        TimeEvent(15*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/glowfly/buzz") end),
        -- TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/glowfly/buzz") end),
    },
})
]]
CommonStates.AddSleepStates(states,
{
    starttimeline =
    {
        -- TimeEvent(23*FRAMES, function(inst) inst.SoundEmitter:KillSound("buzz") end)
    },
    waketimeline =
    {
        -- TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.buzz, "buzz") end)
    },
})
CommonStates.AddFrozenStates(states)

return StateGraph("glowfly", states, events, "idle", actionhandlers)

