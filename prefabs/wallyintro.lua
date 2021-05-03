local assets =
{
    Asset("ANIM", "anim/parrot_pirate_intro.zip"),
    --Asset("SOUND", "sound/updates.fsb"),
}

local prefabs = {
    "wallyintro_bird",
    "wallyintro_debris_1",
    "wallyintro_debris_2",
    "wallyintro_debris_3",
    "wallyintro_shipmast",
}

local function TakeOff(inst)
    local bird = SpawnPrefab("wallyintro_bird")
    bird.Transform:SetPosition(inst:GetPosition():Get())
    bird.Transform:SetRotation(inst.Transform:GetRotation())
    bird.AnimState:PlayAnimation("takeoff_diagonal_pre")
    local toplayer = (GetPlayer():GetPosition() - inst:GetPosition()):Normalize()

    bird.animoverfn = function()
        bird:RemoveEventCallback("animover", bird.animoverfn)

        bird.AnimState:PlayAnimation("takeoff_diagonal_loop", true)

        bird:DoTaskInTime(2, function() bird:Remove() end)

        bird:DoPeriodicTask(7 * FRAMES, function()
            bird.SoundEmitter:PlaySound("dontstarve/birds/flyin")
        end)

        bird:DoPeriodicTask(0, function()
            local currentpos = bird:GetPosition()
            local flightspeed = 7.5
            local posdelta = Vector3(toplayer.x * flightspeed, flightspeed, toplayer.z * flightspeed) * FRAMES
            local newpos = currentpos + posdelta
            bird.Transform:SetPosition(newpos:Get())
        end)
    end

    bird:ListenForEvent("animover", bird.animoverfn)
    
    local mast = SpawnPrefab("wallyintro_shipmast")
    mast.Transform:SetPosition(inst:GetPosition():Get())
    mast.Transform:SetRotation(inst.Transform:GetRotation())
    
    inst:Remove()
end

local PlayPecks = nil
PlayPecks = function(inst)
    inst:RemoveEventCallback("animover", PlayPecks)
    local peckfn = function() 
        if inst then 
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/parrot/peck") 
        end
    end
    inst:DoTaskInTime(6*FRAMES, peckfn)
    inst:DoTaskInTime(11*FRAMES, peckfn)
end

local SPEECH =
{
    NULL_SPEECH=
    {
        voice = "dontstarve/maxwell/talk_LP",
        appearanim = "idle_peck",
        idleanim= "idle",
        --dialogpreanim = "dialog_pre",
        dialoganim="speak",
        --dialogpostanim = "dialog_pst",
        disappearanim = TakeOff,
        disableplayer = true,
        skippable = true,
        {
            string = "There is no speech number.", --The string maxwell will say
            wait = 2, --The time this segment will last for
            anim = nil, --If there's a different animation, the animation maxwell will play
            sound = nil, --if there's an extra sound, the sound that will play
        },
        {
            string = nil, 
            wait = 0.5, 
            anim = "smoke", 
            sound = "dontstarve/common/destroy_metal", 
        },
        {
            string = "Go set one.", 
            wait = 2, 
            anim = nil, 
            sound = nil, 
        },
        {
            string = "Goodbye", 
            wait = 1,
            anim = nil,
            sound = "dontstarve/common/destroy_metal",
        },
    
    },

    SHIPWRECKED_1 =
    {
        voice = "dontstarve_DLC002/creatures/parrot/chirp",
        idleanim= "idle",
        dialoganim="speak",
        disappearanim = TakeOff,
        disableplayer = true,
        skippable = true,
        {
            string = nil,
            wait = 1,
            anim = "idle",
            pushanim = true,
            sound = nil,
        },
        {
            string = STRINGS.WALLY_SANDBOXINTROS.ONE,
            wait = 1,
            anim = nil,
            sound = nil,
        },
        {
            string = nil,
            wait = 3,
            anim = "idle_peck",
            pushanim = true,
            sectionfn = function(inst)
                inst:ListenForEvent("animover", PlayPecks)
            end,
        },
        {
            string = STRINGS.WALLY_SANDBOXINTROS.TWO, 
            wait = 0.5, 
            anim = nil, 
            sound = nil,
        },
    },
}

local function onhammered(inst, worker)
    if inst:HasTag("fire") and inst.components.burnable then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
    inst:Remove()
end

local function onworked(inst, hitanim, anim)
    inst.AnimState:PlayAnimation(hitanim)
    inst.AnimState:PushAnimation(anim)
end

local function fn()  
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.Transform:SetTwoFaced()

    inst.AnimState:SetBank("parrot_pirate_intro")
    inst.AnimState:SetBuild("parrot_pirate_intro")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("notarget")
    inst:AddTag("wallyintro")

    inst:AddComponent("talker")
    inst.components.talker.fontsize = 40
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.offset = Vector3(0,-550,0)
    
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(onhammered)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:AddLoot("log")

    inst:AddComponent("maxwelltalker")
    inst.components.maxwelltalker.speeches = SPEECH
    inst.components.maxwelltalker.cleartrees = true 

    return inst
end

local function bird_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    inst.Transform:SetTwoFaced()

    inst.AnimState:SetBank("parrot_pirate_intro")
    inst.AnimState:SetBuild("parrot_pirate_intro")
    inst.AnimState:PlayAnimation("takeoff_diagonal_pre")

    inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = "wallyintro"
    inst.displaynamefn = function(inst) return STRINGS.NAMES["WALLYINTRO"] end

    inst.persists = false

    return inst
end


local function debris_fn(anim, hitanim, workoverride, lootoverride, collision)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    inst.Transform:SetTwoFaced()

    if collision then
        MakeObstaclePhysics(inst, .1)
    end

    inst.AnimState:SetBank("parrot_pirate_intro")
    inst.AnimState:SetBuild("parrot_pirate_intro")
    inst.AnimState:PlayAnimation(anim)

    inst:AddComponent("inspectable")

    inst.components.inspectable.nameoverride = "wallyintro_debris"
    inst.displaynamefn = function(inst) return STRINGS.NAMES["WALLYINTRO_DEBRIS"] end

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(workoverride or 1)
    if workoverride and workoverride > 1 then
        inst.components.workable:SetOnWorkCallback(function() onworked(inst, hitanim, anim) end)
    end
    inst.components.workable:SetOnFinishCallback(onhammered)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:AddLoot(lootoverride or "log")

    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)

    return inst
end

return Prefab("wallyintro", fn, assets, prefabs),
Prefab("wallyintro_bird", bird_fn, assets),
Prefab("wallyintro_debris_1", function() return debris_fn("debris_1") end, assets),
Prefab("wallyintro_debris_2", function() return debris_fn("debris_2") end, assets),
Prefab("wallyintro_debris_3", function() return debris_fn("debris_3") end, assets),
Prefab("wallyintro_shipmast", function() return debris_fn("idle_empty", "hit", 4, "boatrepairkit", true) end, assets)