require 'prefabutil'
local BigPopupDialogScreen = require "screens/bigpopupdialog"

local assets=
{
	Asset("ANIM", "anim/portal_hamlet.zip"),
	Asset("ANIM", "anim/portal_hamlet_build.zip"),
	Asset("ANIM", "anim/wormhole_hamlet.zip"),
	Asset("MINIMAP_IMAGE", "portal_ham"),
}

local prefabs = {}

local modes = {
	survival = {
		title = STRINGS.UI.SAVEINTEGRATION.SURVIVAL,
		body = STRINGS.UI.SAVEINTEGRATION.TRAVEL_SURVIVAL,
		excludeslotswith = "porkland"
	},

	shipwrecked = {
		title = STRINGS.UI.SAVEINTEGRATION.SHIPWRECKED,
		body = STRINGS.UI.SAVEINTEGRATION.TRAVEL_SHIPWRECKED,
		excludeslotswith = "survival",
	},

	porkland = {
		title = STRINGS.UI.SAVEINTEGRATION.PORKLAND,
		body = STRINGS.UI.SAVEINTEGRATION.TRAVEL_PORKLAND,
		--excludeslotswith = "porkland"
	}
}

local portal_event = "porkland_portal"

local function OnActivate(inst)
    SetPause(true)
	local targetmode = nil

	local function cancel()
		SetPause(false)
		inst.components.activatable.inactive = true
	end

	local function startnextmode()
		local SaveIntegrationScreen = require "screens/saveintegrationscreen"
		local NewIntegratedGameScreen = require "screens/newintegratedgamescreen"
		
		TheFrontEnd:PopScreen()
		if not SaveGameIndex:OwnsMode(targetmode) then
			if SaveGameIndex:GetNumberOfSavesForMode(targetmode, modes[targetmode].excludeslotswith) > 0 then
				TheFrontEnd:PushScreen(SaveIntegrationScreen(targetmode, portal_event, cancel))
			else
				TheFrontEnd:PushScreen(NewIntegratedGameScreen(targetmode, portal_event, SaveGameIndex:GetCurrentSaveSlot(), true, cancel))
			end
		else
			TravelBetweenWorlds(targetmode, portal_event, 7.5, {"chester_eyebone", "packim_fishbone", "ro_bin_gizzard_stone","roc_robin_egg"})
		end
	end

	local function selectdestination()
    	local dest_1
    	local dest_2

    	if SaveGameIndex:IsModePorkland() then
    		dest_1 = "shipwrecked"
			dest_2 = "survival"
    	elseif SaveGameIndex:IsModeShipwrecked() then
    		dest_1 = "porkland" 
    		dest_2 = "survival"
    	elseif SaveGameIndex:IsModeSurvival() then
    		dest_1 = "porkland" 
    		dest_2 = "shipwrecked"
    	else
    		-- TODO: something went horribly wrong
    	end

		TheFrontEnd:PushScreen(BigPopupDialogScreen(
			STRINGS.UI.SAVEINTEGRATION.CHOOSE_DEST_TITLE, 
			STRINGS.UI.SAVEINTEGRATION.CHOOSE_DEST_BODY,
			{
				{text=modes[dest_1].title, cb = function() 
					targetmode = dest_1 
					startnextmode()
				end},

				{text=modes[dest_2].title, cb = function()
					targetmode = dest_2
					startnextmode()
				end},

				{text=STRINGS.UI.SAVEINTEGRATION.CANCEL, cb = function()
					TheFrontEnd:PopScreen()
					cancel()
				end }
			}
		))
	end

	local function singledestination()
		local title = modes[targetmode].title
		local body = modes[targetmode].body
		if not SaveGameIndex:OwnsMode(targetmode) then
			title = STRINGS.UI.SAVEINTEGRATION.WARNING
			body = string.format("%s\n%s", STRINGS.UI.SAVEINTEGRATION.EARLY_ACCESS, 
						string.format(STRINGS.UI.SAVEINTEGRATION.MERGE_MOD_WARNING, STRINGS.UI.SAVEINTEGRATION.PORKLAND))
		end

		TheFrontEnd:PushScreen(BigPopupDialogScreen(
			title, body,
			{
				{text=STRINGS.UI.SAVEINTEGRATION.YES, cb = startnextmode},
				{text=STRINGS.UI.SAVEINTEGRATION.NO, cb = function()
					TheFrontEnd:PopScreen()
					cancel()
				end}
			}
		))
	end

	if IsDLCInstalled(CAPY_DLC) then
		selectdestination()
	else
		targetmode = SaveGameIndex:IsModePorkland() and "survival" or "porkland"
		singledestination()
    end
end

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:SetTime(0.65 * inst.AnimState:GetCurrentAnimationLength())
	inst.AnimState:PushAnimation("idle_off")
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeObstaclePhysics(inst, 1)
    local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("portal_ham.png")

    anim:SetBank("hamportal")
    anim:SetBuild("portal_hamlet_build")
    
    anim:PlayAnimation("idle_off", false)

	inst:ListenForEvent( "onbuilt", function()		
		anim:PlayAnimation("place")
		anim:PushAnimation("idle_off")
		print("PLAY dontstarve_DLC003/common/crafted/skyworthy/place")
		inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/crafted/skyworthy/place")				
	end)		


    inst:AddTag("porkland_portal")

    inst:AddComponent("inspectable")

	inst.no_wet_prefix = true

	inst:AddComponent("activatable")
    inst.components.activatable.OnActivate = OnActivate
    inst.components.activatable.inactive = true
	inst.components.activatable.quickaction = true

	inst:AddComponent("lootdropper")
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)			
	
	--this is a hack to make sure these don't show up in adventure mode
	if SaveGameIndex:GetCurrentMode() == "adventure" then
		inst:DoTaskInTime(0, function() inst:Remove() end)
	end

	inst:ListenForEvent( "onbuilt", function()
		anim:PlayAnimation("place")
		anim:PushAnimation("idle_off")		
	end)	

	SaveGameIndex:RegisterWorldEntrance(inst, "porkland_portal")
    inst:ListenForEvent("onremove", function() SaveGameIndex:DeregisterWorldEntrance(inst) end)

    return inst
end

local function wormhole_fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()

	anim:SetBank("teleporter_worm")
	anim:SetBuild("wormhole_hamlet")
	anim:PlayAnimation("in")
	anim:PushAnimation("out", false)

	inst:DoTaskInTime(0*FRAMES, function() inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/portal/open") end)
	inst:DoTaskInTime(8*FRAMES, function() inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/portal/jump_in") end)

	inst:ListenForEvent("animqueueover", inst.Remove)
	
	return inst
end

return Prefab( "common/porkland_entrance", fn, assets, prefabs),
	   MakePlacer("porkland_entrance_placer", "hamportal", "portal_hamlet_build", "idle_off"),
	   Prefab( "wormhole_porkland_fx", wormhole_fn, assets, prefabs)
