require("stategraphs/commonstates")

local function onattackedfn(inst, data)
    if inst.components.health and not inst.components.health:IsDead()
    and (not inst.sg:HasStateTag("busy") or inst.sg:HasStateTag("frozen")) then
       inst.sg:GoToState("hit")
    end
end

local function onattackfn(inst)
    if inst.components.health and not inst.components.health:IsDead()
    and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then

        if not inst.CanCharge and not inst.components.timer:TimerExists("Charge") then
            inst.components.timer:StartTimer("Charge", TUNING.TWISTER_CHARGE_COOLDOWN)
        end

        inst.sg:GoToState("attack")
    end
end

local actionhandlers = {}

local events=
{
    CommonHandlers.OnLocomote(true, true),
    CommonHandlers.OnDeath(),
    EventHandler("doattack", onattackfn),
    EventHandler("attacked", onattackedfn),
}

local states=
{

    State{
        name = "idle",
        tags = {"idle"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_loop")
            inst.components.vacuum:SpitItem()
            
            if inst:GetIsOnWater() then
                inst.AnimState:Show("twister_water_fx")
            else
                inst.AnimState:Hide("twister_water_fx")
            end

        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

----------------------COMBAT------------------------

    State{
        name = "hit",
        tags = {"hit", "busy"},
        
        onenter = function(inst, cb)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("hit")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/twister/hit")
        end,
        
        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "attack",
        tags = {"attack", "busy", "canrotate"},
        
        onenter = function(inst)
            inst.SoundEmitter:SetParameter("wind_loop", "intensity", 1)

            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk")
        end,

        onexit = function(inst)
            inst.SoundEmitter:SetParameter("wind_loop", "intensity", 0)
        end,

        timeline =
        {
            TimeEvent(4*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/twister/attack_pre")
            end),

            TimeEvent(31*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/twister/attack_swipe")
            end),

            TimeEvent(33*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/twister/attack_hit")
                inst.components.combat:DoAttack()
            end),
        },

        events=
        {
            EventHandler("animover", function(inst) 
                if inst.CanVacuum then
                    if not inst:GetIsOnWater() then 
                        inst.sg:GoToState("vacuum_antic_pre") 
                    else
                        inst.sg:GoToState("waves_antic_pre")
                    end 
                else 
                    inst.sg:GoToState("idle")  
                end 
            end),
        },
    },

    State{
        name = "vacuum_antic_pre",
        tags = {"attack", "busy"},
        
        onenter = function(inst)
            TheMixer:PushMix("twister")
            inst.SoundEmitter:SetParameter("wind_loop", "intensity", 1)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("vacuum_antic_pre")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/twister/vacuum_antic_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("vacuum_antic_loop") end),
        },
    },

    State{
        name = "vacuum_antic_loop",
        tags = {"attack", "busy"},
        
        onenter = function(inst)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("vacuum_antic_loop", true)
            
            inst.sg:SetTimeout(TUNING.TWISTER_VACUUM_ANTIC_TIME)

            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/twister/vacuum_antic_LP", "vacuum_antic_loop")
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("vacuum_antic_loop")
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("vacuum_pre")
        end,
    },

    State{
        name = "vacuum_pre",
        tags = {"attack", "busy"},
        
        onenter = function(inst)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("vacuum_pre")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/twister/vacuum_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("vacuum_loop") end),
        },
    },

    State{
        name = "vacuum_loop",
        tags = {"attack", "busy"},
        
        onenter = function(inst)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end

            inst.CanVacuum = false
            inst.AnimState:PlayAnimation("vacuum_loop", true)


            inst.components.vacuum.vacuumradius = TUNING.TWISTER_PLAYER_VACUUM_DISTANCE
            inst.components.vacuum.ignoreplayer = false
            inst.sg:SetTimeout(TUNING.TWISTER_VACUUM_TIME)

            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/twister/vacuum_hit")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/twister/vacuum_LP", "vacuum_loop")
        end,

        onexit = function(inst)
            if not inst.components.timer:TimerExists("Vacuum") then
                inst.components.timer:StartTimer("Vacuum", TUNING.TWISTER_VACUUM_COOLDOWN)
            end

            inst.components.vacuum.spitplayer = true 
            inst.components.vacuum.vacuumradius = TUNING.TWISTER_VACUUM_DISTANCE
            inst.components.vacuum.ignoreplayer = true 

            inst.SoundEmitter:KillSound("vacuum_loop")
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("vacuum_pst")
        end,
    },

    State{
        name = "vacuum_pst",
        tags = {"attack", "busy"},
        
        onenter = function(inst)
            TheMixer:PopMix("twister")
        
            inst.SoundEmitter:SetParameter("wind_loop", "intensity", 0)

            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("vacuum_pst")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "waves_antic_pre",
        tags = {"attack", "busy"},
        
        onenter = function(inst)
            TheMixer:PushMix("twister")
            inst.SoundEmitter:SetParameter("wind_loop", "intensity", 1)

            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("vacuum_antic_pre")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/twister/vacuum_antic_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("waves_antic_loop") end),
        },
    },

    State{
        name = "waves_antic_loop",
        tags = {"attack", "busy"},
        
        onenter = function(inst)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("vacuum_antic_loop", true)
            inst.sg:SetTimeout(TUNING.TWISTER_WAVES_ANTIC_TIME)
            
            inst.sg.statemem.maxwaves = 4
            inst.sg.statemem.waves = 1
            inst.sg.statemem.wavetime = FRAMES*30
            inst.sg.statemem.wavetimer = FRAMES*30

            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/twister/vacuum_antic_LP", "vacuum_antic_loop")

        end,

        onupdate = function(inst, dt)
            inst.sg.statemem.wavetimer = inst.sg.statemem.wavetimer + dt
            if inst.sg.statemem.wavetimer >= inst.sg.statemem.wavetime and inst.sg.statemem.waves <= inst.sg.statemem.maxwaves then
                SpawnWaves(inst, math.random(10, 15), 360, 6, "wave_ripple", -25, 1.5)
                inst.sg.statemem.waves = inst.sg.statemem.waves + 1
                inst.sg.statemem.wavetimer = 0
            end
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("vacuum_antic_loop")
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("waves_pre")
        end,
    },

    State{
        name = "waves_pre",
        tags = {"attack", "busy"},
        
        onenter = function(inst)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("vacuum_pre")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/twister/vacuum_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("waves_loop") end),
        },
    },

    State{
        name = "waves_loop",
        tags = {"attack", "busy"},
        
        onenter = function(inst)
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end

            inst.AnimState:PlayAnimation("vacuum_loop", true)

            inst.CanVacuum = false

            inst.sg.statemem.wavetime = FRAMES*24
            inst.sg.statemem.wavetimer = FRAMES*24

            inst.sg:SetTimeout(TUNING.TWISTER_WAVES_TIME)


            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/twister/vacuum_hit")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/twister/vacuum_LP", "vacuum_loop")

        end,

        onexit = function(inst)
            if not inst.components.timer:TimerExists("Vacuum") then
                inst.components.timer:StartTimer("Vacuum", TUNING.TWISTER_VACUUM_COOLDOWN)
            end

            inst.SoundEmitter:KillSound("vacuum_loop")
        end,

        onupdate = function(inst, dt)
            inst.sg.statemem.wavetimer = inst.sg.statemem.wavetimer + dt
            if inst.sg.statemem.wavetimer >= inst.sg.statemem.wavetime then
                SpawnWaves(inst, math.random(11, 12), 360, 12, nil, 3, nil, true)
                inst.sg.statemem.wavetimer = 0
            end
        end,

        ontimeout = function(inst)
            inst.sg:GoToState("waves_pst")
        end,
    },

    State{
        name = "waves_pst",
        tags = {"attack", "busy"},
        
        onenter = function(inst)
            TheMixer:PopMix("twister")

            inst.SoundEmitter:SetParameter("wind_loop", "intensity", 0)

            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
            end
            inst.AnimState:PlayAnimation("vacuum_pst")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "death",  
        tags = {"busy"},
        
        onenter = function(inst)
            TheMixer:PopMix("twister")
            if inst.components.locomotor then
                inst.components.locomotor:StopMoving()
                inst.components.vacuum:TurnOff()
            end

            if inst:GetIsOnWater() then
                inst.AnimState:PlayAnimation("death_water")
            else
                inst.AnimState:PlayAnimation("death")
            end

            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/twister/death")
        end,

        timeline =
        {
            TimeEvent(4*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/twister/seal_fly")
            end),

            TimeEvent(40*FRAMES, function(inst)
                inst.components.inventory:DropEverything(true, true)
                inst.components.lootdropper:DropLoot()
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/twister/seal_groundhit")
            end),

            TimeEvent(25*FRAMES, function(inst)
            end),

            TimeEvent(50*FRAMES, function(inst)
                local seal = SpawnPrefab("twister_seal")
                seal.Transform:SetPosition(inst:GetPosition():Get())
                seal.sg:GoToState("dizzy")
                inst:Remove()
            end),
        },
    },

----------------WALKING---------------

    State{
        name = "walk_start",
        tags = {"moving", "canrotate"},

        onenter = function(inst) 
            inst.AnimState:PlayAnimation("walk_pre")


            if inst:GetIsOnWater() then
                inst.AnimState:Show("twister_water_fx")
            else
                inst.AnimState:Hide("twister_water_fx")
            end

        end,

        events =
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),        
        },
    },
        
    State{            
        name = "walk",
        tags = {"moving", "canrotate"},
        
        onenter = function(inst)
            inst.AnimState:PlayAnimation("walk_loop")
            inst.components.locomotor:WalkForward()
            inst.components.vacuum:SpitItem()


            if inst:GetIsOnWater() then
                inst.AnimState:Show("twister_water_fx")
            else
                inst.AnimState:Hide("twister_water_fx")
            end
        end,

        timeline = 
        {
            TimeEvent(24*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/twister/walk") end)
        },

        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),        
        },
    },
    
    State{            
        name = "walk_stop",
        tags = {"canrotate"},

        onenter = function(inst) 
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("walk_pst")


            if inst:GetIsOnWater() then
                inst.AnimState:Show("twister_water_fx")
            else
                inst.AnimState:Hide("twister_water_fx")
            end
        end,

        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),        
        },
    },

    State{
        name = "run_start",
        tags = {"moving", "running", "atk_pre", "canrotate"},

        onenter = function(inst)
            inst.SoundEmitter:SetParameter("wind_loop", "intensity", 1)

            inst.CanCharge = false
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("charge_pre")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/twister/charge_roar")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/twister/run_charge_up")


            if inst:GetIsOnWater() then
                inst.AnimState:Show("twister_water_fx")
            else
                inst.AnimState:Hide("twister_water_fx")
            end

        end,

        events =
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),        
        },
    },

    State{
        name = "run",
        tags = {"moving", "running"},
        
        onenter = function(inst) 
            inst.components.locomotor:RunForward()
            inst.AnimState:PlayAnimation("charge_roar_loop")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/twister/run_charge_up")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/twister/charge_roar")

            if inst:GetIsOnWater() then
                inst.AnimState:Show("twister_water_fx")
            else
                inst.AnimState:Hide("twister_water_fx")
            end
        end,
       
        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("run") end ),        
        },
    },        
    
    State{
        name = "run_stop",
        tags = {"canrotate"},
        
        onenter = function(inst) 
            inst.SoundEmitter:SetParameter("wind_loop", "intensity", 0)

            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("charge_pst")


            if inst:GetIsOnWater() then
                inst.AnimState:Show("twister_water_fx")
            else
                inst.AnimState:Hide("twister_water_fx")
            end

        end,

        events=
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end ),        
        },
    },
}

return StateGraph("twister", states, events, "idle", actionhandlers)