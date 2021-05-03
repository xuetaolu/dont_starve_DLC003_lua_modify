local MakePlayerCharacter = require "prefabs/player_common"
local assets = 
{
    Asset("ANIM", "anim/warbucks.zip"),
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
}

local prefabs =
{
    "magnifying_glass",
    "ballpein_hammer",
}

local start_inv = 
{ 
    "magnifying_glass",
    "ballpein_hammer",
}

local function ontalk(inst, script, mood)
    if mood == "battlecry" then
        inst.SoundEmitter:PlaySound("dontstarve_DLC003/characters/warbucks/attack") 
    end
end

local function oneat(inst, data)
    -- TODO: say something about the food
    if not data.food:HasTag("preparedfood") then

        local speech = math.random() > 0.45 and "SPOILED" or "PAINFUL"

        inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_EAT", speech))
        inst.components.sanity:DoDelta(-TUNING.SANITY_MED)
    else
        inst.components.talker:Say(GetString(inst.prefab, "ANNOUNCE_EAT", "GENERIC"))
    end
end

local function sanityfn(inst)
    local delta = 0
    local oinc_amount = inst.components.inventory:Count("oinc") + (inst.components.inventory:Count("oinc10") * 10) + (inst.components.inventory:Count("oinc100") * 100)
    
    if oinc_amount >= 200 then
        delta = TUNING.SANITYAURA_MED    
    elseif oinc_amount >= 50 then
        delta = TUNING.SANITYAURA_SMALL         
    elseif oinc_amount >= 20 then
        delta = TUNING.SANITYAURA_TINY * 2 
    elseif oinc_amount >= 10 then
        delta = TUNING.SANITYAURA_TINY  
    end

    return delta
end

local fn = function(inst)
    inst.components.sanity:SetMax(TUNING.WARBUCKS_SANITY)
    inst.components.hunger:SetMax(TUNING.WARBUCKS_HUNGER)
    inst.components.health:SetMaxHealth(TUNING.WARBUCKS_HEALTH)
    inst.soundsname = "warbucks"
    inst.talker_path_override = "dontstarve_DLC003/characters/"
    inst.oneat = oneat
    inst:ListenForEvent("oneatsomething", inst.oneat)
    inst.battlecrysound = true
    inst.components.talker.ontalk = ontalk
    inst.components.sanity.custom_rate_fn = sanityfn


    inst:AddTag("treasure_hunter")
end

return MakePlayerCharacter("warbucks", prefabs, assets, fn, start_inv)