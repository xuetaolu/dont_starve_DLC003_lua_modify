require("stategraphs/commonstates")

local actionhandlers = 
{
    
    ActionHandler(ACTIONS.CHOP, "work"),
    ActionHandler(ACTIONS.HACK, "work"),
    ActionHandler(ACTIONS.MINE, "work"),
    ActionHandler(ACTIONS.DIG, "work"),
    ActionHandler(ACTIONS.HAMMER, "work"),
    ActionHandler(ACTIONS.EAT, "eat"),
    ActionHandler(ACTIONS.USEDOOR, "usedoor"),
}

local function shoot(inst)
    if inst.fullcharge then

        local player = GetPlayer()
        local rotation = player.Transform:GetRotation()
        local beam = SpawnPrefab("ancient_hulk_orb")
        beam.components.complexprojectile.yOffset = 1
        local pt = Vector3(player.Transform:GetWorldPosition())
        local angle = rotation * DEGREES
        local radius = 2.5
        local offset = Vector3(radius * math.cos( angle ), 0, -radius * math.sin( angle ))
        local newpt = pt+offset

        beam.Transform:SetPosition(newpt.x,newpt.y,newpt.z)
        beam.host = player
        beam.AnimState:PlayAnimation("spin_loop",true)

        local targetpos = TheInput:GetWorldPosition()
        local controller_mode = TheInput:ControllerAttached()
        if controller_mode then
            targetpos = Vector3(player.livingartifact.components.reticule.reticule.Transform:GetWorldPosition())     
        end  
    
        local speed =  60 --  easing.linear(rangesq, 15, 3, maxrange * maxrange)
        beam.components.complexprojectile:SetHorizontalSpeed(speed)
        beam.components.complexprojectile:SetGravity(-1)
        beam.components.complexprojectile:Launch(targetpos, player)
        beam.components.combat.proxy = inst
        beam.owner = inst    
    else
        local player = GetPlayer()
        local rotation = player.Transform:GetRotation()
        local beam = SpawnPrefab("ancient_hulk_orb_small")
        local pt = Vector3(player.Transform:GetWorldPosition())
        local angle = rotation * DEGREES
        local radius = 2.5
        local offset = Vector3(radius * math.cos( angle ), 0, -radius * math.sin( angle ))
        local newpt = pt+offset

        beam.Transform:SetPosition(newpt.x,1,newpt.z)
        beam.host = player
        beam.Transform:SetRotation(rotation)
        beam.AnimState:PlayAnimation("spin_loop",true) 
        beam.components.combat.proxy = inst
    end
end

local events=
{
    CommonHandlers.OnLocomote(true,false),
    CommonHandlers.OnAttack(),
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
    EventHandler("transform_person", function(inst) inst.sg:GoToState("revert") end),
    EventHandler("freeze", 
        function(inst)
            if inst.components.health and inst.components.health:GetPercent() > 0 then
                inst.sg:GoToState("frozen")
            end
        end),    
    EventHandler("beginchargeup", 
        function(inst) 
            if not inst.sg:HasStateTag("busy") then
                inst.sg:GoToState("charge")
            end
        end),
    EventHandler("rightbuttonup", 
        function(inst) 
            --if inst.sg:HasStateTag("waitforbutton") then
                inst.rightbuttonup = true
                inst.rightbuttondown = nil
                print("UP")
            --end
        end),   
    EventHandler("rightbuttondown", 
        function(inst) 
            --if inst.sg:HasStateTag("waitforbutton") then
                inst.rightbuttonup = nil
                inst.rightbuttondown = true
                print("DOWN")
           -- end
        end),   
    EventHandler("ontalk", function(inst, data)
        if inst.sg:HasStateTag("idle") then
            if inst.prefab == "wes" then
                inst.sg:GoToState("mime")
            else
                inst.sg:GoToState("talk", data.noanim)
            end
        end
        
    end),                 
}

local states=
{
    State {
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst, pushanim)
            inst.components.locomotor:StopMoving()
            local anim = "idle_loop"
               
            if pushanim then
                if type(pushanim) == "string" then
                    inst.AnimState:PlayAnimation(pushanim)
                end
                inst.AnimState:PushAnimation(anim, true)
            else
                inst.AnimState:PlayAnimation(anim, true)
            end

            if inst.rightbuttondown then
                inst.sg:GoToState("charge")    
            end
        end,
        
       events=
        {
            EventHandler("animover", function(inst) 
                inst.sg:GoToState("idle")                                    
            end),
        }, 
    },

    State {
        name = "morph",
        tags = {"busy"},
        onenter = function(inst)

            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("morph_idle")
            inst.AnimState:PushAnimation("morph_complete",false)            
        end,
        
        timeline=
        {
            TimeEvent(0*FRAMES, function(inst) 
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/music/iron_lord")
            end),
            TimeEvent(15*FRAMES, function(inst) 
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/iron_lord/morph")
            end),
            TimeEvent(105*FRAMES, function(inst) 
                inst.components.playercontroller:ShakeCamera(inst, "FULL", 0.7, 0.02, .5, 40)
            end),

            TimeEvent(105*FRAMES, function(inst) 
                inst.AnimState:Hide("beard")
            end),

            TimeEvent(152*FRAMES, function(inst) 
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/music/iron_lord_suit", "ironlord_music")
            end),
        },

        
        onexit = function(inst)
            inst.livingartifact.BecomeIronLord_post(inst.livingartifact)
        end,

        events=
        {
            EventHandler("animqueueover", function(inst) 
                inst.sg:GoToState("idle")                                    
            end),
        },         
    },

    State{
        name = "revert",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()            
            inst.AnimState:PlayAnimation("death")
            inst.sg:SetTimeout(3)
            --inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/death_beaver")
            inst.components.beaverness.doing_transform = true
        end,

        -- timeline =
        -- {
        --     TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySoundWithParams ("dontstarve_DLC003/common/crafted/iron_lord/small_explosion", {intesity= .2}) end),
        --     TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySoundWithParams("dontstarve_DLC003/common/crafted/iron_lord/small_explosion", {intesity= .4}) end),
        --     TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySoundWithParams("dontstarve_DLC003/common/crafted/iron_lord/small_explosion", {intesity= .6}) end),
        --     TimeEvent(19*FRAMES, function(inst) inst.SoundEmitter:PlaySoundWithParams("dontstarve_DLC003/common/crafted/iron_lord/small_explosion", {intesity= 1}) end),
        --     TimeEvent(54*FRAMES, function(inst) inst.SoundEmitter:PlaySoundWithParams("dontstarve_DLC003/common/crafted/iron_lord/explosion") end),
        -- },
        
        ontimeout = function(inst) 
            TheFrontEnd:Fade(false,2)
            inst:DoTaskInTime(2, function() 
                
                GetClock():MakeNextDay()
                
                inst.components.beaverness.makeperson(inst)
                inst.components.sanity:SetPercent(.25)
                inst.components.health:SetPercent(.33)
                inst.components.hunger:SetPercent(.25)
                inst.components.beaverness.doing_transform = false
                inst.sg:GoToState("wakeup")
                TheFrontEnd:Fade(true,1)
            end)
        end
    },

    State{
        name = "transform_pst",
        tags = {"busy"},
        onenter = function(inst)
			inst.components.playercontroller:Enable(false)
            inst.Physics:Stop()            
            inst.AnimState:PlayAnimation("transform_pst")
            inst.components.health:SetInvincible(true)
            if TUNING.DO_SEA_DAMAGE_TO_BOAT and (inst.components.driver and inst.components.driver.vehicle and inst.components.driver.vehicle.components.boathealth) then
                inst.components.driver.vehicle.components.boathealth:SetInvincible(true)
            end
        end,
        
        onexit = function(inst)
            inst.components.health:SetInvincible(false)
            if TUNING.DO_SEA_DAMAGE_TO_BOAT and (inst.components.driver and inst.components.driver.vehicle and inst.components.driver.vehicle.components.boathealth) then
                inst.components.driver.vehicle.components.boathealth:SetInvincible(false)
            end
            inst.components.playercontroller:Enable(true)
        end,
        
        events=
        {
            EventHandler("animover", function(inst) TheCamera:SetDistance(30) inst.sg:GoToState("idle") end ),
        },        
    },    

    State{
        name = "work",
        tags = {"busy", "working"},
        
        onenter = function(inst)
            inst.Physics:Stop()            
            inst.AnimState:PlayAnimation("power_punch")
            inst.sg.statemem.action = inst:GetBufferedAction()
        end,
        
        timeline=
        {
            TimeEvent(8*FRAMES, function(inst) 
                inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/iron_lord/punch",nil,.5)
            end),
            TimeEvent(6*FRAMES, function(inst) inst:PerformBufferedAction() end),
            TimeEvent(14*FRAMES, function(inst) inst.sg:RemoveStateTag("working") inst.sg:RemoveStateTag("busy") inst.sg:AddStateTag("idle") end),
            TimeEvent(15*FRAMES, function(inst)
                if (TheInput:IsMouseDown(MOUSEBUTTON_LEFT) or
                   TheInput:IsKeyDown(KEY_SPACE)) and 
                    inst.sg.statemem.action and 
                    inst.sg.statemem.action:IsValid() and 
                    inst.sg.statemem.action.target and 
                    inst.sg.statemem.action.target:IsActionValid(inst.sg.statemem.action.action) and 
                    (inst.sg.statemem.action.target.components.workable or inst.sg.statemem.action.target.components.hackable) then
                        inst:ClearBufferedAction()
                        inst:PushBufferedAction(inst.sg.statemem.action)
                end
            end),            

        },
    },

    State{
        name = "frozen",
        tags = {"busy", "frozen"},
        
        onenter = function(inst)
            inst.components.playercontroller:Enable(false)

            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("frozen")
            inst.SoundEmitter:PlaySound("dontstarve/common/freezecreature")
            inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
        end,
        
        onexit = function(inst)
            inst.components.playercontroller:Enable(true)

            inst.AnimState:ClearOverrideSymbol("swap_frozen")
        end,
        
        events=
        {   
            EventHandler("onthaw", function(inst) inst.sg:GoToState("thaw") end ),        
        },
    },

    State{
        name = "usedoor",
        tags = {"doing", "canrotate"},
        
        onenter = function(inst)
            inst.sg.statemem.action = inst:GetBufferedAction()
            inst.components.locomotor:Stop()
            inst:PerformBufferedAction()
            inst.sg:GoToState("idle") 
        end,
    },

    State{
        name = "charge",
        tags = {"busy", "doing", "waitforbutton"},
        
        onenter = function(inst)            
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("charge_pre")
            inst.AnimState:PushAnimation("charge_grow")
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/iron_lord/charge_up_LP", "chargedup")    
        end,
        onexit = function(inst)
            inst.rightbuttonup = nil
            inst:ClearBufferedAction()
            inst.shoot=nil
            inst.readytoshoot = nil
        end,
        onupdate = function(inst)        
            if inst.rightbuttonup then
                inst.rightbuttonup = nil
                inst.shoot = true                
            end
            if inst.shoot and inst.readytoshoot then
                inst.SoundEmitter:PlaySoundWithParams("dontstarve_DLC003/common/crafted/iron_lord/smallshot", {timeoffset=math.random()})
                inst.SoundEmitter:KillSound("chargedup")
                inst.sg:GoToState("shoot")
            end

            local controller_mode = TheInput:ControllerAttached()
            if controller_mode then
                local reticulepos = Vector3(inst.livingartifact.components.reticule.reticule.Transform:GetWorldPosition())
                inst:ForceFacePoint(reticulepos)        
            else
                local mousepos = TheInput:GetWorldPosition()             
                inst:ForceFacePoint(mousepos)        
            end  
        end,        
        timeline=
        {
            TimeEvent(15*FRAMES, function(inst) inst.readytoshoot = true end),
            TimeEvent(20*FRAMES, function(inst) inst.sg:GoToState("chagefull") end),            
        },        
    },

    State{
        name = "chagefull",
        tags = {"busy", "doing","waitforbutton"},
        
        onenter = function(inst)           
            inst.rightbuttonup = nil 
            inst.components.locomotor:Stop()
            
            inst.AnimState:PlayAnimation("charge_super_pre")
            inst.AnimState:PushAnimation("charge_super_loop",true)
            inst.fullcharge = true

            inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/iron_lord/electro")
            
        end,        

        onexit = function(inst)
            inst.rightbuttonup = nil
            inst:ClearBufferedAction()     
            if not inst.shooting then
                inst.fullcharge = nil
            end
            inst.shoot = nil
            inst.shooting = nil
            inst.SoundEmitter:KillSound("chargedup")
        end,

        onupdate = function(inst)
            if inst.rightbuttonup then
                inst.rightbuttonup = nil
                inst.shoot = true 
            end

            if inst.shoot and inst.readytoshoot then
                inst.shooting = true
                inst.SoundEmitter:PlaySoundWithParams("dontstarve_DLC003/creatures/boss/hulk_metal_robot/laser",  {intensity = math.random(0.7, 1)})---jason can i use a random number from .7 to 1 instead of a static number (.8)?

                inst.sg:GoToState("shoot")
            end

            local controller_mode = TheInput:ControllerAttached()
            if controller_mode then
                local reticulepos = Vector3(inst.livingartifact.components.reticule.reticule.Transform:GetWorldPosition())
                inst:ForceFacePoint(reticulepos)        
            else
                local mousepos = TheInput:GetWorldPosition()             
                inst:ForceFacePoint(mousepos)        
            end    
        end,  
        timeline=
        {
            TimeEvent(5*FRAMES, function(inst) inst.readytoshoot = true end),      
        },  
    },    

    State{
        name = "shoot",
        tags = {"busy"},
        
        onenter = function(inst)       
            inst.components.locomotor:Stop()
            if inst.fullcharge then
                inst.AnimState:PlayAnimation("charge_super_pst")
            else
                inst.AnimState:PlayAnimation("charge_pst")
            end
        end,
        
        timeline=
        {
            TimeEvent(1*FRAMES, function(inst) shoot(inst)  end),   
            TimeEvent(5*FRAMES, function(inst) inst.sg:RemoveStateTag("busy")  end),   
            
        }, 
        
        onexit = function(inst)
            inst.fullcharge = nil   
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },             
    },

    State{
        name = "explode",
        tags = {"busy"},
        
        onenter = function(inst)     
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("suit_destruct")            
        end,
        
        timeline=
        {   ---- death explosion
            TimeEvent(4*FRAMES, function(inst) inst.SoundEmitter:PlaySoundWithParams("dontstarve_DLC003/common/crafted/iron_lord/small_explosion", {intensity= .2}) end),
            TimeEvent(8*FRAMES, function(inst) inst.SoundEmitter:PlaySoundWithParams("dontstarve_DLC003/common/crafted/iron_lord/small_explosion", {intensity= .4}) end),
            TimeEvent(12*FRAMES, function(inst) inst.SoundEmitter:PlaySoundWithParams("dontstarve_DLC003/common/crafted/iron_lord/small_explosion", {intensity= .6}) end),
            TimeEvent(19*FRAMES, function(inst) inst.SoundEmitter:PlaySoundWithParams("dontstarve_DLC003/common/crafted/iron_lord/small_explosion", {intensity= 1}) end),
            TimeEvent(26*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/iron_lord/electro",nil,.5) end),
            TimeEvent(35*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/iron_lord/electro",nil,.5) end),
            TimeEvent(54*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/iron_lord/explosion") end),
            
            TimeEvent(54*FRAMES, function(inst) inst.SoundEmitter:KillSound("ironlord_music") end), --- jason i put the music here and commented out the living_artifact.lua lines                           
            
            TimeEvent(52*FRAMES, function(inst) 
                local explosion = SpawnPrefab("living_suit_explode_fx")
                explosion.Transform:SetPosition(inst.Transform:GetWorldPosition())  
                inst.livingartifact.DoDamage(inst.livingartifact, 5)
            end),
        }, 
        
        onexit = function(inst)
             inst.livingartifact.Revert(inst.livingartifact)
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),
        },             
    },    
}

CommonStates.AddCombatStates(states,
{
    ---- 
    hittimeline =
    {
        -- TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/iron_lord/hit") end),
    },
    
    attacktimeline = 
    {
    
        TimeEvent(0*FRAMES, function(inst) 
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/iron_lord/punch_pre") end),
        TimeEvent(8*FRAMES, function(inst) 
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/iron_lord/punch") end),
        TimeEvent(6*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) end),
        TimeEvent(7*FRAMES, function(inst) inst.sg:RemoveStateTag("attack") inst.sg:RemoveStateTag("busy") inst.sg:AddStateTag("idle") end),
    },

    deathtimeline=
    {
    },
},
{attack="power_punch"})

CommonStates.AddRunStates(states,
{
	runtimeline = {
		TimeEvent(0*FRAMES, PlayFootstep ),
		TimeEvent(10*FRAMES, PlayFootstep ),
	},
})

CommonStates.AddFrozenStates(states)

return StateGraph("ironlord", states, events, "idle", actionhandlers)