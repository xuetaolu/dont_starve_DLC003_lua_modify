local assets =
{
	Asset("ANIM", "anim/warning_shadow.zip"),
}

local function shrink(inst, time, startsize, endsize)
    inst.AnimState:SetMultColour(1,1,1,0.33)
    inst.Transform:SetScale(startsize, startsize, startsize)
    inst.components.colourtweener:StartTween({1,1,1,0.75}, time)
    inst.components.sizetweener:StartTween(.5, time, inst.Remove)
    inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/bomb_fall")
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
	
    anim:SetBank("warning_shadow")
    anim:SetBuild("warning_shadow")
    anim:PlayAnimation("idle", true)
    anim:SetFinalOffset(-1)
    inst.persists = false
    inst:AddTag("fx")

    inst:AddComponent("sizetweener")
    inst:AddComponent("colourtweener")

    inst.shrink = shrink

    return inst
end

return Prefab("common/fx/warningshadow", fn, assets) 
