local assets=
{
    Asset("ANIM", "anim/wind_conch.zip"),
	Asset("ANIM", "anim/swap_wind_conch.zip"),
}

local function onfinished(inst)
    inst:Remove()
end

local function OnPlayed(inst, musician)
    if SaveGameIndex:IsModeShipwrecked() or SaveGameIndex:IsModePorkland() then
        GetWorld().components.seasonmanager:StartHurricaneStorm(TUNING.SEG_TIME * 8)
    else
        GetWorld().components.seasonmanager:ForcePrecip()
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst:AddTag("horn")

    inst.AnimState:SetBank("wind_conch")
    inst.AnimState:SetBuild("wind_conch")
    inst.AnimState:PlayAnimation("idle")

    inst.hornbuild = "swap_wind_conch"
    inst.hornsymbol = "swap_horn"

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")

    inst:AddComponent("inspectable")
    inst:AddComponent("instrument")
    inst.components.instrument.onplayed = OnPlayed
    inst.components.instrument.sound = "dontstarve_DLC002/common/magic_seal_conch"

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.PLAY)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.WIND_CONCH_USES)
    inst.components.finiteuses:SetUses(TUNING.WIND_CONCH_USES)
    inst.components.finiteuses:SetOnFinished(onfinished)
    inst.components.finiteuses:SetConsumption(ACTIONS.PLAY, 1)

    inst:AddComponent("inventoryitem")

    return inst
end

return Prefab("wind_conch", fn, assets) 
