require "stategraphs/SGbermudatriangle"

local assets=
{
	Asset("ANIM", "anim/bermudatriangle.zip"),
	Asset("ANIM", "anim/teleporter_worm.zip"),
	Asset("ANIM", "anim/teleporter_worm_build.zip"),
    Asset("SOUND", "sound/common.fsb"),
}


local function GetStatus(inst)
	if inst.sg.currentstate.name ~= "idle" then
		return "OPEN"
	end
end

local function GetVerb(inst, doer)
	return STRINGS.ACTIONS.JUMPIN.ENTER
end

local function OnActivate(inst, doer, target)
	--print("OnActivated!")
	if doer:HasTag("player") then
        --ProfileStatsSet("wormhole_used", true)
		doer.components.health:SetInvincible(true)
		if TUNING.DO_SEA_DAMAGE_TO_BOAT and (doer.components.driver and doer.components.driver.vehicle and doer.components.driver.vehicle.components.boathealth) then
			doer.components.driver.vehicle.components.boathealth:SetInvincible(true)
		end
		doer.components.playercontroller:Enable(false)
		
		if inst.components.teleporter.targetTeleporter ~= nil then
			DeleteCloseEntsWithTag(inst.components.teleporter.targetTeleporter, "WORM_DANGER", 15)
		end

		GetPlayer().HUD:Hide()
		--TheFrontEnd:SetFadeLevel(1)
        TheCamera:SetTarget(inst)
		TheFrontEnd:Fade(false, 0.5)
		doer:DoTaskInTime(2, function()
            TheCamera:SetTarget(target)
            TheCamera:Snap()
			TheFrontEnd:Fade(true, 0.5)
			GetPlayer().HUD:Show()
			--doer.sg:GoToState("wakeup")
			if doer.components.sanity then
				doer.components.sanity:DoDelta(-TUNING.SANITY_MED)
			end
		end)
		doer:DoTaskInTime(3.5, function()
			TheCamera:SetTarget(GetPlayer())
			doer:PushEvent("bermudatriangleexit")
			doer.components.health:SetInvincible(false)
			if TUNING.DO_SEA_DAMAGE_TO_BOAT and (doer.components.driver and doer.components.driver.vehicle and doer.components.driver.vehicle.components.boathealth) then
				doer.components.driver.vehicle.components.boathealth:SetInvincible(false)
			end
			doer.components.playercontroller:Enable(true)
		end)
		--doer.SoundEmitter:PlaySound("dontstarve_DLC002/common/bermudatriangle_travel", "wormhole_travel")
	elseif doer.SoundEmitter then
		inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/bermudatriangle_spark", "wormhole_swallow")
	end
end

local function OnActivateOther(inst, other, doer)
	other.sg:GoToState("open")
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    
    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "bermudatriangle.png" )
   
    anim:SetBank("bermudatriangle")
    anim:SetBuild("bermudatriangle")
    anim:PlayAnimation("idle_loop", true)
	anim:SetLayer( LAYER_BACKGROUND )
	anim:SetSortOrder( 3 )
	anim:SetOrientation( ANIM_ORIENTATION.OnGround )
    
	local s = 1.3
	inst.Transform:SetScale(s,s,s)

	inst:SetStateGraph("SGbermudatriangle")
    
    inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = GetStatus
	inst.components.inspectable:RecordViews()

	inst:AddComponent("playerprox")
	inst.components.playerprox:SetDist(4,5)
	inst.components.playerprox.onnear = function()
		if inst.components.teleporter.targetTeleporter ~= nil and not inst.sg:HasStateTag("open") then
			inst.sg:GoToState("opening")
		end
	end
	inst.components.playerprox.onfar = function()
		inst.sg:GoToState("closing")
	end

	inst:AddComponent("teleporter")
	inst.components.teleporter.onActivate = OnActivate
	inst.components.teleporter.onActivateOther = OnActivateOther
	inst.components.teleporter.getverb = GetVerb
	inst.components.teleporter.offset = 0

	inst:AddComponent("inventory")

	inst:AddComponent("trader")
	inst.components.trader.onaccept = function(reciever, giver, item)
		-- pass this on to our better half
		reciever.components.inventory:DropItem(item)
		inst.components.teleporter:Activate(item)
	end
	
	--print("Wormhole Spawned!")

    return inst
end

return Prefab( "shipwrecked/objects/bermudatriangle", fn, assets) 
