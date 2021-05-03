local MakePlayerCharacter = require "prefabs/player_common"

local assets = 
{
	Asset("ANIM", "anim/wilbur.zip"),
	Asset("ANIM", "anim/wilbur_run.zip"),
}

local prefabs = {}

local function oneat(inst, data)
	if data and (data.food.prefab == "cave_banana" or data.food.prefab == "cave_banana_cooked") then
		if inst.components.sanity then
			inst.components.sanity:DoDelta(TUNING.SANITY_SMALL)
		end
	end
end

local fn = function(inst)
	inst.soundsname = "wilbur"
	inst.talker_path_override = "dontstarve_DLC002/characters/"

	inst:AddTag("wilbur")
	inst:AddTag("monkey")

	inst.components.health:SetMaxHealth(TUNING.WILBUR_HEALTH)
	inst.components.hunger:SetMax(TUNING.WILBUR_HUNGER)
	inst.components.sanity:SetMax(TUNING.WILBUR_SANITY)

	inst.components.locomotor:AddSpeedModifier_Additive("WILBUR_WALK", TUNING.WILBUR_WALK_SPEED_PENALTY)

	inst:ListenForEvent("oneatsomething", oneat)

    inst:AddComponent("periodicspawner")
    inst.components.periodicspawner:SetPrefab("poop")
    inst.components.periodicspawner:SetRandomTimes(TUNING.TOTAL_DAY_TIME * 2, TUNING.SEG_TIME * 2)
    inst.components.periodicspawner:Start()
end

return MakePlayerCharacter("wilbur", prefabs, assets, fn)