local assets=
{
	Asset("ANIM", "anim/seataro.zip"),
}

local prefabs=
{
	"seataro",
}

local function onpickedfn(inst)
	inst.AnimState:PlayAnimation("picking")
    inst.AnimState:PushAnimation("picked", true)
end

local function onregenfn(inst)
    inst.AnimState:PlayAnimation("grow")
    inst.AnimState:PushAnimation("idle_plant", true)
    --inst.entity:Show()
end

local function makeemptyfn(inst)
    inst.AnimState:PlayAnimation("picking")
    inst.AnimState:PushAnimation("picked", true)
    --inst.entity:Hide()
end

local function makebarrenfn(inst)
    inst.AnimState:PlayAnimation("picking")
    inst.AnimState:PushAnimation("picked", true)
    --inst.entity:Hide()
end

local function makefullfn(inst)
    inst.AnimState:PlayAnimation("grow")
    inst.AnimState:PushAnimation("idle_plant", true)
    --inst.entity:Show()
end

local function fn(Sim)

	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()

    inst:AddTag("aquatic")

    inst.AnimState:SetBank("seataro")
    inst.AnimState:SetBuild("seataro")
    inst.AnimState:PlayAnimation("idle_plant", true)
	inst.AnimState:OverrideSymbol("water_ripple", "ripple_build", "water_ripple")
	inst.AnimState:OverrideSymbol("water_shadow", "ripple_build", "water_shadow")    

    inst:AddComponent("inspectable")

    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve_DLC002/common/item_wet_harvest"
	inst.components.pickable:SetUp("seataro", TUNING.SEAWEED_REGROW_TIME +  math.random()*TUNING.SEAWEED_REGROW_VARIANCE)
	inst.components.pickable:SetOnPickedFn(onpickedfn)
    inst.components.pickable:SetOnRegenFn(onregenfn)
    inst.components.pickable.makeemptyfn = makeemptyfn
    inst.components.pickable.makebarrenfn = makebarrenfn
    inst.components.pickable.makefullfn = makefullfn
    inst.components.pickable.quickpick = false

    return inst
end

return Prefab( "common/inventory/seataro_planted", fn, assets)
