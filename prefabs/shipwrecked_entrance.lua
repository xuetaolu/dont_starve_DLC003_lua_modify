require 'prefabutil'

local assets=
{
	Asset("ANIM", "anim/portal_shipwrecked.zip"),
	Asset("ANIM", "anim/portal_shipwrecked_build.zip"),
}

local prefabs = {}

local modes = {
	shipwrecked = {
		title = STRINGS.UI.SAVEINTEGRATION.SHIPWRECKED,
		body = STRINGS.UI.SAVEINTEGRATION.TRAVEL_SHIPWRECKED,
		excludeslotswith = "survival",
	},
	survival = {
		title = STRINGS.UI.SAVEINTEGRATION.SURVIVAL,
		body = STRINGS.UI.SAVEINTEGRATION.TRAVEL_SURVIVAL,
		excludeslotswith = "shipwrecked"
	}
}

local portal_event = "shipwrecked_portal"

local function OnActivate(inst)
	if not IsDLCInstalled(CAPY_DLC) then
		GetPlayer().components.talker:Say(GetString(GetPlayer().prefab, "DESCRIBE","PORTAL_SHIPWRECKED"))
		return
	end
    SetPause(true)

	local targetmode = SaveGameIndex:IsModeShipwrecked() and "survival" or "shipwrecked"

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

	local title = modes[targetmode].title
	local body = modes[targetmode].body
	if not SaveGameIndex:OwnsMode(targetmode) then
		title = STRINGS.UI.SAVEINTEGRATION.WARNING
		body = string.format("%s\n%s", STRINGS.UI.SAVEINTEGRATION.EARLY_ACCESS, 
					string.format(STRINGS.UI.SAVEINTEGRATION.MERGE_MOD_WARNING, STRINGS.UI.SAVEINTEGRATION.SHIPWRECKED))
	end

	local BigPopupDialogScreen = require "screens/bigpopupdialog"
	
	TheFrontEnd:PushScreen(BigPopupDialogScreen(
				title, body,
				{
					{text=STRINGS.UI.SAVEINTEGRATION.YES, cb = startnextmode},
					{text=STRINGS.UI.SAVEINTEGRATION.NO, cb = function()
						TheFrontEnd:PopScreen()
						cancel()
					end}
				}))
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
	minimap:SetIcon("shipwrecked_exit.png")

    anim:SetBank("boatportal")
    anim:SetBuild("portal_shipwrecked_build")
    
    anim:PlayAnimation("place")
    anim:PushAnimation("idle_off")

    inst:AddTag(portal_event)

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
		inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/portal/place")
	end)	

	SaveGameIndex:RegisterWorldEntrance(inst, "shipwrecked_portal")
    inst:ListenForEvent("onremove", function() SaveGameIndex:DeregisterWorldEntrance(inst) end)

    return inst
end

-- backwards compatability
local function exit_fn()
	local inst = fn()
	-- for the moment these two prefabs are identical, but leave them as separate prefabs in case
	-- the behaviour ever changes between SW and Forest
	return inst
end

return Prefab( "common/shipwrecked_entrance", fn, assets, prefabs),
	MakePlacer("shipwrecked_entrance_placer", "boatportal", "portal_shipwrecked_build", "idle_off"),
	Prefab( "common/shipwrecked_exit", exit_fn, assets, prefabs)
