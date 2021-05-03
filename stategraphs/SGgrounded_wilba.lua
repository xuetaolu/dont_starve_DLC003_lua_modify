require("stategraphs/commonstates")

local actionhandlers = 
{
}

local events=
{
    CommonHandlers.OnStep(),
    CommonHandlers.OnLocomote(true,true),
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(true),
    CommonHandlers.OnDeath(),
}

local states=
{
    State{
        name= "alert",
        tags = {"idle"},
        
        onenter = function(inst)
            if inst.alerted then
                inst.sg:GoToState("idle")
            else
                inst.alerted = true                
                inst:DoTaskInTime(120,function(inst) inst.alerted = nil end)

    			inst.Physics:Stop()
                local daytime = not GetClock():IsNight()           
                if daytime then 
                    --inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/city_pig/conversational_talk")
                    if (inst:HasTag("emote_nohat") or math.random() < 0.3) and not inst:HasTag("emote_nocurtsy") then
                        inst.AnimState:PlayAnimation("emote_bow")           
                    else
                        inst.AnimState:PlayAnimation("emote_hat")           
                    end 
                end
            end
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
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/wilba/death_voice")
            inst.AnimState:PlayAnimation("death")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)            
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))            
        end,
        
    },
    
    State{
        name = "attack",
        tags = {"attack", "busy"},
        
        onenter = function(inst)
            local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
            if equip then
                if equip.prefab == "torch" then 
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_firestaff",nil,.5)
                elseif equip.prefab == "halberd" then
                    inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/items/weapon/halberd")
                end
            end
            inst.components.combat:StartAttack()
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("atk")
        end,
        
        timeline=
        {
            TimeEvent(13*FRAMES, function(inst) inst.components.combat:DoAttack() inst.sg:RemoveStateTag("attack") inst.sg:RemoveStateTag("busy") end),
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
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/wilba/hurt",nil,.25)
            if inst:HasTag("guard") then 
                -- inst.SoundEmitter:PlaySound("dontstarve_DLC003/movement/iron_armor/hit")
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/city_pig/guard_alert")
                inst.AnimState:PlayAnimation("hit")
                inst.Physics:Stop()

                inst.components.combat.laststartattacktime = 0
            end
        end,
        
        timeline= 
        {
            
            TimeEvent(12*FRAMES, function (inst) if inst:HasTag("guard") then inst.SoundEmitter:PlaySound("dontstarve_DLC003/movement/iron_armor/foley")end end),

            TimeEvent(13*FRAMES, function (inst) if inst:HasTag("guard") then inst.sg:GoToState("idle") end end),

        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },        
    },

    -- State{
    --     name = "walk_start",
    --     tags = {"moving", "canrotate"},

    --     onenter = function(inst) 
    --         inst.components.locomotor:WalkForward()
    --         inst.AnimState:PlayAnimation("run_pre")
    --     end,

    --     events =
    --     {   
    --         EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),
    --     },
    -- },

    -- State{
    --     name = "walk",
    --     tags = {"moving", "canrotate"},
        
    --     onenter = function(inst) 
    --         inst.components.locomotor:WalkForward()
    --         inst.AnimState:PlayAnimation("run_loop")
    --     end,

    --     events=
    --     {   
    --         EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),        
    --     },
    -- },

    State{
        
        name = "walk_stop",
        tags = {"canrotate"},
        
        onenter = function(inst)            
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("run_pst")
        end,            

        events=
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle")
            end),
        },
    }   
}

CommonStates.AddIdle(states)-- "funnyidle"

return StateGraph("grounded_wilba", states, events, "idle", actionhandlers)