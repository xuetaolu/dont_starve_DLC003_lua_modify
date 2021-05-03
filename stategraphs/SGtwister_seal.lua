require("stategraphs/commonstates")

local events = {
    CommonHandlers.OnAttacked(),
    CommonHandlers.OnDeath(),
}

local states =
{
    State{
        name = "dizzy",
        tags = {"idle"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            local anim = (inst:GetIsOnWater() and "seal_idle_water") or "seal_idle"
            inst.AnimState:PlayAnimation(anim, true)
            inst.sg:SetTimeout(5)
        end,

        timeline = 
        {
            TimeEvent(1*FRAMES, function(inst)
                local anim = (inst:GetIsOnWater() and "seal_idle_water") or "seal_idle"
                if not inst.AnimState:IsCurrentAnimation(anim) then
                    inst.AnimState:PlayAnimation(anim, true)
                end
            end),
        },

        ontimeout = function(inst)
            inst.sg:GoToState("dizzy_pst")
        end,
    },

    State{
        name = "dizzy_pst",
        tags = {"idle"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            local anim = (inst:GetIsOnWater() and "seal_idle_pst_water") or "seal_idle_pst"
            inst.AnimState:PlayAnimation(anim)
        end,

        timeline =
        {
            TimeEvent(13*FRAMES, function(inst) 
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/twister/seal_headshake") 
            end)
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("cower")
            end)
        }
    },

    State{
        name = "cower",
        tags = {"idle", "canrotate"},

        onenter = function(inst)
            inst.Physics:Stop()
            local anim = (inst:GetIsOnWater() and "seal_cower_water") or "seal_cower"
            inst.AnimState:PlayAnimation(anim)
        end,

        timeline = 
        {
            TimeEvent(1*FRAMES, function(inst)
                local anim = (inst:GetIsOnWater() and "seal_cower_water") or "seal_cower"
                if not inst.AnimState:IsCurrentAnimation(anim) then
                    inst.AnimState:PlayAnimation(anim, true)
                end
            end),

            TimeEvent(4*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/twister/seal_cower")
            end),
            TimeEvent(27*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/twister/seal_cower")
            end),
            TimeEvent(32*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/twister/seal_cower")
            end),
            TimeEvent(67*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/twister/seal_cower")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("cower") end)
        },

    },

    State{
        name = "hit",
        tags = {"hit", "busy"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            local anim = (inst:GetIsOnWater() and "seal_hit_water") or "seal_hit"
            inst.AnimState:PlayAnimation(anim)
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/twister/seal_hit")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("cower")
            end)
        },
    },

    State{
        name = "death",
        tags = {"busy"},
        
        onenter = function(inst)
            inst.Physics:Stop()
            local on_water = inst:GetIsOnWater()
            if on_water then
                inst.AnimState:PlayAnimation("seal_death_water")
                inst.AnimState:PushAnimation("seal_death_water_loop", true)
            else
                inst.AnimState:PlayAnimation("seal_death")
            end
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/twister/seal_death")
    		inst.components.lootdropper:DropLoot()
        end,

     --    events =
     --    {
     --        EventHandler("animover", function(inst)
     --    	end),
    	-- },
    },
}

return StateGraph('twister_seal', states, events, 'cower')