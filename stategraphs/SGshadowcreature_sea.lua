require("stategraphs/commonstates")

local actionhandlers =
{
    ActionHandler(ACTIONS.GOHOME, "action"),
}

local events=
{
    EventHandler("attacked", function(inst) if not inst.components.health:IsDead() and not inst.sg:HasStateTag("attack") then inst.sg:GoToState("hit") end end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
    EventHandler("doattack", function(inst, data) if not inst.components.health:IsDead() and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then inst.sg:GoToState("attack", data.target) end end),
    CommonHandlers.OnLocomote(false,true),
}

local function GetVolume(inst)
	if inst.components.transparentonsanity then
		return inst.components.transparentonsanity:GetPercent()
	end
	return 1
end

local states=
{
    State{
        name = "attack",
        tags = {"attack", "busy"},

        onenter = function(inst, target)
            inst.sg.statemem.target = target
            inst.Physics:Stop()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("atk")
            inst.SoundEmitter:PlaySound(inst.sounds.attack_grunt, nil, GetVolume(inst))
        end,

        timeline=
        {
			TimeEvent(23*FRAMES, function(inst) inst.SoundEmitter:PlaySound(inst.sounds.attack, nil, GetVolume(inst)) end),
            TimeEvent(25*FRAMES, function(inst) inst.components.combat:DoAttack(inst.sg.statemem.target) end),
        },

        events=
        {
            EventHandler("animqueueover", function(inst)
                if math.random() < .333 then
                    inst.components.combat:SetTarget(nil)
                    inst.sg:GoToState("taunt")
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

	State{
		name = "hit",
        tags = {"busy", "hit"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("disappear")
            inst.components.health:SetInvincible(true)
        end,

        onexit = function(inst)
            inst.components.health:SetInvincible(false)
        end,

        events=
        {
			EventHandler("animover", function(inst)
                local offset = FindWaterOffset(inst:GetPosition(), 2*math.pi*math.random(), 10, 12)
                local pos = inst:GetPosition()

                if offset then
                    pos = pos + offset
                    inst.Transform:SetPosition(pos:Get())
                end

				inst.sg:GoToState("appear")
			end),
        },
    },

	State{
		name = "taunt",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
            inst.SoundEmitter:PlaySound(inst.sounds.taunt, nil, GetVolume(inst))
        end,

        events=
        {
			EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "appear",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("appear")
            inst.Physics:Stop()
            inst.SoundEmitter:PlaySound(inst.sounds.appear, nil, GetVolume(inst))
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
        },
    },

    State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
			inst.SoundEmitter:PlaySound(inst.sounds.death, nil, GetVolume(inst))
            inst.AnimState:PlayAnimation("disappear")
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot()
        end,
    },

	State{
        name = "disappear",
        tags = {"busy"},

        onenter = function(inst)
			inst.persists = false
			inst.SoundEmitter:PlaySound(inst.sounds.death, nil, GetVolume(inst))
            inst.AnimState:PlayAnimation("disappear")
            inst.Physics:Stop()
        end,

        events =
        {
            EventHandler("animover", function(inst)
				inst:Remove()
			end ),
        },
    },

    State{

        name = "action",
        onenter = function(inst, playanim)
            inst.Physics:Stop()
            inst:PerformBufferedAction()
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
        },
    },

    State{
        name = "idle",
        tags = {"idle", "canrotate"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle", true)
        end,
    },
}

CommonStates.AddWalkStates(states)

return StateGraph("shadowcreature_sea", states, events, "appear", actionhandlers)