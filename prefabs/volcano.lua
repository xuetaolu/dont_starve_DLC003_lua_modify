local BigPopupDialogScreen = require "screens/bigpopupdialog"

local assets =
{
	Asset("ANIM", "anim/volcano.zip"),
    Asset("MINIMAP_IMAGE", "volcano"),
    Asset("MINIMAP_IMAGE", "volcano_active")
}

local prefabs =
{
    "meteor_impact",
}

local function GetVerb()
    return STRINGS.ACTIONS.ACTIVATE.CLIMB
end

local function OnActivate(inst)
    --ProfileStatsSet("portal_used", true)
    SetPause(true)

    local function startvolcano()

        SaveGameIndex:GetSaveFollowers(GetPlayer(),EXIT_DESTINATION.LAND)

        local function onsaved()
            TheFrontEnd:PopScreen()
            SetPause(false)
            StartNextInstance({reset_action=RESET_ACTION.LOAD_SLOT, save_slot = SaveGameIndex:GetCurrentSaveSlot()}, true)
        end

        local function onenter()
            SaveGameIndex:SaveCurrent(function() SaveGameIndex:EnterWorld("volcano", onsaved) end, "ascend_volcano")
        end

        --ProfileStatsSet("portal_accepted", true)
        GetPlayer().HUD:Hide()
        TheFrontEnd:Fade(false, 2, function() onenter() end)
    end

    local function rejectvolcano()
        TheFrontEnd:PopScreen()
        SetPause(false)
        inst.components.activatable.inactive = true
        --ProfileStatsSet("portal_rejected", true)
    end

    TheFrontEnd:PushScreen(BigPopupDialogScreen(STRINGS.UI.STARTVOLCANO.TITLE, STRINGS.UI.STARTVOLCANO.BODY,
            {{text=STRINGS.UI.STARTVOLCANO.YES, cb = startvolcano},
             {text=STRINGS.UI.STARTVOLCANO.NO, cb = rejectvolcano}  }))
end

local function OnSeasonChange(inst)
    if GetSeasonManager():IsDrySeason() then
        inst.sg:GoToState("active")
    else
        inst.sg:GoToState("dormant")
    end
end

local function OnWake(inst)
    inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/volcano/volcano_external_amb", "volcano")
    local state = 1.0
    if inst.sg and inst.sg.currentstate == "dormant" then
        state = 0.0
    end
    inst.SoundEmitter:SetParameter("volcano", "volcano_state", state)
end

local function OnSleep(inst)
    inst.SoundEmitter:KillSound("volcano")
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local minimap = inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()

	inst:AddTag("theVolcano")

    inst.entity:AddLight()
    inst.Light:SetFalloff(0.4)
    inst.Light:SetIntensity(.7)
    inst.Light:SetRadius(10)
    inst.Light:SetColour(249/255, 130/255, 117/255)
    inst.Light:Enable(true)

    minimap:SetIcon("volcano.png")

    inst.entity:AddPhysics()
 	inst.Physics:SetMass(0)
    inst.Physics:SetCollisionGroup(COLLISION.OBSTACLES)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.ITEMS)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
	inst.Physics:CollidesWith(COLLISION.WAVES)
    inst.Physics:SetRectangle(17, 5)
    anim:SetBuild("volcano")
    anim:SetBank("volcano")
    anim:PlayAnimation("dormant_idle", true)

    inst:AddComponent("inspectable")
 	inst:AddComponent("scenariorunner")
    inst.components.scenariorunner:SetScript("camera_volcano")
    inst.components.scenariorunner:Run()

    inst:AddComponent("activatable")
    inst.components.activatable.OnActivate = OnActivate
    inst.components.activatable.inactive = true
    inst.components.activatable.getverb = GetVerb
    inst.components.activatable.quickaction = true

    inst:AddComponent("waveobstacle")

    inst.OnLoadPostPass = function(inst, ents, data)
    	GetWorld().components.volcanomanager:AddVolcano(inst)
	end

    inst.OnRemoveEntity = function(inst)
    	GetWorld().components.volcanomanager:RemoveVolcano(inst)
	end

    inst:ListenForEvent("OnVolcanoEruptionBegin", function (it)
        if inst and inst.sg then
            inst.sg:GoToState("erupt")
        end
        -- print(">>>OnVolcanoEruptionBegin", inst)
    end, GetWorld())

    inst:ListenForEvent("OnVolcanoEruptionEnd", function (it)
        if inst and inst.sg then
            inst.sg:GoToState("rumble")
        end
        -- print(">>>OnVolcanoEruptionEnd", inst)
    end, GetWorld())

    inst:ListenForEvent("OnVolcanoWarningQuake", function (it)
        if inst and inst.sg then
            inst.sg:GoToState("rumble")
        end
        -- print(">>>OnVolcanoEruptionEnd", inst)
    end, GetWorld())

    inst:SetStateGraph("SGvolcano")

    inst:ListenForEvent("seasonChange", OnSeasonChange)

    inst.OnEntityWake = OnWake
    inst.OnEntitySleep = OnSleep

	return inst
end




return Prefab( "shipwrecked/objects/volcano", fn, assets, prefabs)
