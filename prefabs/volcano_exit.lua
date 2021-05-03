local PopupDialogScreen = require "screens/popupdialog"

local assets=
{
	Asset("ANIM", "anim/volcano_entrance.zip"),
	Asset("MINIMAP_IMAGE", "volcano_entrance")
}


local function GetVerb(inst)
	return STRINGS.ACTIONS.ACTIVATE.DESCEND
end

-- local function onnear(inst)
-- 	inst.AnimState:PlayAnimation("down")
--     inst.AnimState:PushAnimation("idle_loop", true)
--     inst.SoundEmitter:PlaySound("dontstarve/cave/rope_down")
-- end

-- local function onfar(inst)
--     inst.AnimState:PlayAnimation("up")
--     inst.SoundEmitter:PlaySound("dontstarve/cave/rope_up")
-- end



local function OnActivate(inst)

	SetPause(true)
	--local level = GetWorld().topology.level_number or 1
	local function head_upwards()
		SaveGameIndex:GetSaveFollowers(GetPlayer(), EXIT_DESTINATION.WATER )

		local function onsaved()
		    SetPause(false)
		    StartNextInstance({reset_action=RESET_ACTION.LOAD_SLOT, save_slot = SaveGameIndex:GetCurrentSaveSlot()}, true)
		end

		SaveGameIndex:SaveCurrent(function() SaveGameIndex:EnterWorld("shipwrecked", onsaved) end, "descend_volcano")
	end
	GetPlayer().HUD:Hide()
	TheFrontEnd:Fade(false, 2, function()
									head_upwards()
								end)
end


local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    MakeObstaclePhysics(inst, 1)
     
    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "volcano_entrance.png" )
    
    anim:SetBank("volcano_entrance")
    anim:SetBuild("volcano_entrance")
    anim:PlayAnimation("idle")
    anim:SetLayer(LAYER_BACKGROUND)
    anim:SetSortOrder(1)

	inst.entity:AddLight()
	inst.Light:Enable(true)
	inst.Light:SetIntensity(.75)
	inst.Light:SetColour(197/255,197/255,50/255)
	inst.Light:SetFalloff( 0.5 )
	inst.Light:SetRadius( 1 )

    -- inst:AddComponent("playerprox")
    -- inst.components.playerprox:SetDist(5,7)
    -- inst.components.playerprox:SetOnPlayerFar(onfar)
    -- inst.components.playerprox:SetOnPlayerNear(onnear)

    inst:AddComponent("inspectable")

	inst:AddComponent("activatable")
    inst.components.activatable.OnActivate = OnActivate
    inst.components.activatable.inactive = true
    inst.components.activatable.getverb = GetVerb
	inst.components.activatable.quickaction = true

    return inst
end

return Prefab( "common/volcano_exit", fn, assets) 
