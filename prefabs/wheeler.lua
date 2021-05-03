local MakePlayerCharacter = require "prefabs/player_common"

local assets =
{
    Asset("ANIM", "anim/wheeler.zip"),
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("ANIM", "anim/player_actions_roll.zip"),
}

local prefabs =
{
	"trusty_shooter",
	"wheeler_tracker"
}

local start_inv =
{
	"trusty_shooter",
	"wheeler_tracker",
}

local function AllowDodge(inst)
    return (GetTime() - inst.last_dodge_time > TUNING.WHEELER_DODGE_COOLDOWN) and 
            not inst.components.driver:GetIsDriving() and not inst.components.rider:IsRiding()
end

local function GetPointSpecialActions(inst, pos, useitem, right)
    if right then
    	if AllowDodge(inst) then
        	return { ACTIONS.DODGE }
        end
    end
    return {}
end

local function UpdateBonusSpeed(inst)
	inst.components.locomotor:AddSpeedModifier_Mult("wheeler_inventory", 0.05 + (0.01 * inst.components.inventory:GetFreeSlotCount())
)end

local fn = function(inst)
	inst.soundsname = "wheeler"
    inst.talker_path_override = "dontstarve_DLC003/characters/"

	inst.last_dodge_time = GetTime()

	inst.components.health:SetMaxHealth(TUNING.WHEELER_HEALTH)
	inst.components.sanity:SetMax(TUNING.WHEELER_SANITY)
	inst.components.hunger:SetMax(TUNING.WHEELER_HUNGER)
	inst.components.inventory:SetNumSlots(12)

	inst.AnimState:Hide("HAIR_HAT")

	inst.soundsname = "wheeler"
    inst.talker_path_override = "dontstarve_DLC003/characters/"

    inst.components.playeractionpicker.pointspecialactionsfn = GetPointSpecialActions

    inst:ListenForEvent("itemget", UpdateBonusSpeed)
    inst:ListenForEvent("itemlose", UpdateBonusSpeed)

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = function() 
        return Vector3(inst.entity:LocalToWorldSpace(5.5,0,0))
    end

    inst.components.reticule:SetValidateFn(AllowDodge)

    inst.components.reticule.ease = false


	inst:DoTaskInTime(0, function() UpdateBonusSpeed(inst) end)
end

return MakePlayerCharacter("wheeler", prefabs, assets, fn, start_inv)