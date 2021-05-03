require("stategraphs/commonstates")

local actionhandlers = 
{
--    ActionHandler(ACTIONS.EAT, "eat"),
--   ActionHandler(ACTIONS.GOHOME, "eat"),
  --  ActionHandler(ACTIONS.INVESTIGATE, "investigate"),
}

local function spawngaze(inst)
    local beam = SpawnPrefab("gaze_beam")
    local pt = Vector3(inst.Transform:GetWorldPosition())
    local angle = inst.Transform:GetRotation() * DEGREES
    local radius = 4 
    local offset = Vector3(radius * math.cos( angle ), 0, -radius * math.sin( angle ))
    local newpt = pt+offset


    beam.Transform:SetPosition(newpt.x,newpt.y,newpt.z)
    beam.host = inst
    beam.Transform:SetRotation(inst.Transform:GetRotation())
end

local function endgaze(inst)
    if inst.gazetask then
        inst.gazetask:Cancel()
        inst.gazetask = nil
    end
end


local function dogaze(inst)
    if inst.gazetask then
        endgaze(inst)
    end
    inst.gazetask = inst:DoPeriodicTask(0.4,function() spawngaze(inst) end) 
end



local events=
{
    EventHandler("tail_should_exit", function(inst) 
        inst.sg:GoToState("tail_exit") 
    end),


    EventHandler("stopgaze", function(inst)
        if inst.sg:HasStateTag("gazing") then 
            inst.sg:GoToState("gaze_pst") 
        end
    end),

    EventHandler("dogaze", function(inst) 
        inst.sg:GoToState("gaze") 
    end),

    EventHandler("attacked", function(inst) 
         --[[
        if not inst.components.health:IsDead() then 
            if inst:HasTag("spider_warrior") or inst:HasTag("spider_spitter") then
                if not inst.sg:HasStateTag("attack") then -- don't interrupt attack or exit shield
                    inst.sg:GoToState("hit") -- can still attack
                end
            elseif not inst.sg:HasStateTag("shield") then
                inst.sg:GoToState("hit_stunlock")  -- can't attack during hit reaction
            end
        end 
        ]]
    end),
    EventHandler("doattack", function(inst, data) 
        if not inst:HasTag("now_segmented") then
            inst.sg:GoToState("attack", data.target) 
        end
         --[[
        if not inst.components.health:IsDead() and not inst.sg:HasStateTag("busy") and data and data.target  then 
            if inst:HasTag("spider_warrior") and
            inst:GetDistanceSqToInst(data.target) > TUNING.SPIDER_WARRIOR_MELEE_RANGE*TUNING.SPIDER_WARRIOR_MELEE_RANGE then
                --Do leap attack
                inst.sg:GoToState("warrior_attack", data.target) 
            elseif inst:HasTag("spider_spitter") and
            inst:GetDistanceSqToInst(data.target) > TUNING.SPIDER_SPITTER_MELEE_RANGE*TUNING.SPIDER_SPITTER_MELEE_RANGE then
                --Do spit attack
                inst.sg:GoToState("spitter_attack", data.target)
            else
                inst.sg:GoToState("attack", data.target) 
            end
        end 
        ]]
    end),
    EventHandler("death", function(inst) 
        if not inst:HasTag("now_segmented") then
            inst.sg:GoToState("death") 
        end
    end),

    EventHandler("backup", function(inst) 
        if not inst.sg:HasStateTag("backup") then
            inst.sg:GoToState("backup") 
        end
    end),

    EventHandler("premove", function(inst) 
        if not inst.sg:HasStateTag("backup") then
            inst.sg:GoToState("startmove") 
        end
    end),
  
    CommonHandlers.OnSleep(),
    CommonHandlers.OnFreeze(),
   
}

local states=
{
    State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
           -- inst.SoundEmitter:PlaySound(SoundPath(inst, "die"))
            if inst:HasTag("tail") then
                inst.AnimState:PlayAnimation("tail_idle_pst")
                inst.AnimState:PushAnimation("dirt_collapse_slow", false)
                
            else
                inst.AnimState:PlayAnimation("death")
            end
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)            
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))            
        end,
    },    
        
    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        
        onenter = function(inst, start_anim)
            inst.Physics:Stop()
            if inst:HasTag("tail") then
                if start_anim then
                    inst.AnimState:PlayAnimation(start_anim)
                    inst.AnimState:PushAnimation("tail_idle_loop", true)
                else
                    inst.AnimState:PlayAnimation("tail_idle_loop", true)
                end
            else
                if start_anim then
                    inst.AnimState:PlayAnimation(start_anim)
                    inst.AnimState:PushAnimation("head_idle_loop", true)
                else
                    inst.AnimState:PlayAnimation("head_idle_loop", true)
                end
            end
        end,

        onupdate = function(inst)
            if not inst:HasTag("tail") then
                if inst.wantstogaze then
                    inst.sg:GoToState("gaze")
                elseif inst.wantstotaunt then
                    inst.sg:GoToState("toung")
                end   
            end
        end,        
    

        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")  
            end),
        },        
    },   


    State{
        name = "toung",
        tags = {"canrotate", "busy"},

        onenter = function(inst, start_anim)
        assert(not inst:HasTag("tail"))
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst.wantstotaunt = nil
        end,

        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")  
            end),
        },        
    },   


    State{
        name = "dirt_collapse",
        tags = {"busy"},

        onenter = function(inst, start_anim)
            inst.Physics:Stop()            
            inst.AnimState:PlayAnimation("dirt_collapse", false)            
        end,

        events=
        {
            EventHandler("animover", function(inst)
                inst:Remove()  
            end),
        },    
    },

    State{
        name = "tail_exit",
        tags = {"busy"},

        onenter = function(inst, start_anim)
            inst.Physics:Stop()            
            inst.AnimState:PlayAnimation("tail_idle_pst")            
        end,

        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("dirt_collapse")
            end),
        },    
    },

    State{
        name = "tail_ready",
        tags = {"busy"},

        onenter = function(inst, start_anim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("tail_idle_pre")
        end,

        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")                
            end),
        },    
    },

    State{
        name = "gaze",
        tags = {"busy"},

        onenter = function(inst, start_anim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("gaze_pre")
        end,

        events=
        {
            EventHandler("animover", function(inst)              
                inst.sg:GoToState("gaze_loop")                
            end),
        },    
    },

    State{
        name = "gaze_loop",
        tags = {"busy","canrotate","gazing"},

        onenter = function(inst, start_anim)   
            dogaze(inst)         
            inst.AnimState:PlayAnimation("gaze_loop", true)
        end,

        timeline =
        {
            TimeEvent(45*FRAMES, function(inst) dogaze(inst) end),
        },

        onupdate = function(inst)
            local target = inst.FindCurrentTarget(inst.host) 
            if not inst.wantstogaze then
                inst.sg:GoToState("gaze_pst")
     --       if not target or not target.components.freezable then
     --           inst.sg:GoToState("gaze_pst")
            else
                local pt = Vector3(target.Transform:GetWorldPosition())
                local angle = inst:GetAngleToPoint(pt)
                inst.Transform:SetRotation(angle)               
            end         
        end,

        onexit = function(inst)
           endgaze(inst)     
        end,

        events=
        {
            EventHandler("animover", function(inst)                
                --inst.sg:GoToState("gaze_pst")                
            end),
        },    
    },

    State{
        name = "gaze_pst",
        tags = {"busy"},

        onenter = function(inst, start_anim)   
                
            inst.AnimState:PlayAnimation("gaze_pst")
        end,

        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")                
            end),
        },    
    },    

    State{
        name = "emerge",
        tags = {"busy"},

        onenter = function(inst, start_anim)
            --inst.emerged =true
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("head_idle_pre")
        end,

        events=
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")                
            end),
        },    
    },

    State{
        name = "startmove",
        tags = {"busy","backup"},

        onenter = function(inst, start_anim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("head_idle_pst")
        end,

        events=
        {
            EventHandler("animover", function(inst)
                inst:AddTag("now_segmented")
               
                inst.Transform:SetRotation(inst.angle/DEGREES)   
                if inst.components.segmented then
                    inst.components.segmented:Start(inst.angle, nil, 0.3)
                end 

                inst.angle = nil

                inst.sg:GoToState("hole")        
            end),
        },    
    },

    State{
        name = "backup",
        tags = {"busy","backup"},

        onenter = function(inst, start_anim)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("head_idle_pst")
        end,

        events=
        {
            EventHandler("animover", function(inst)
                local hole = SpawnPrefab("pugalisk_ground")      
                hole.Transform:SetPosition(inst.Transform:GetWorldPosition())
                hole.AnimState:PlayAnimation("dirt_collapse", false)
                hole:ListenForEvent("animover", function(inst, data)
                        hole:Remove()
                    end)                    
                inst.recoverfrombadangle(inst)
                inst.sg:GoToState("emerge")
            end),
        },    
    },
    
    State{
        name = "hole",
        tags = {"busy"},

        onenter = function(inst, start_anim)
            inst.AnimState:SetBank("giant_snake")
            inst.AnimState:SetBuild("python_test")

            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("dirt_static")
        end,  
    },   

    State{
        name = "attack",
        tags = {"attack", "canrotate", "busy",},
        
        onenter = function(inst, target)
            inst.components.combat:StartAttack()
            if inst:HasTag("tail") then
                inst.AnimState:PlayAnimation("tail_smack")
            else
                inst.AnimState:PlayAnimation("atk")
            end
            inst.sg.statemem.target = target
        end,
        
        timeline =
        {
            TimeEvent(17*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) end),
        },
        
        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },    
     
}

CommonStates.AddSleepStates(states,
{
	starttimeline = {
		TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("fallAsleep") end ),
	},
	sleeptimeline = 
	{
		TimeEvent(35*FRAMES, function(inst) inst.SoundEmitter:PlaySound("sleeping") end ),
	},
	waketimeline = {
		TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("wakeUp") end ),
	},
})
CommonStates.AddFrozenStates(states)

return StateGraph("pugalisk_head", states, events, "idle", actionhandlers)

