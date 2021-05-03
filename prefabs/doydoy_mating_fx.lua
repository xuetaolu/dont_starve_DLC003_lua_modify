local assets=
{
	Asset("ANIM", "anim/doydoy_mate_fx.zip"),
}

local function onremove(inst)
	inst.SoundEmitter:KillSound("voice")
	inst.SoundEmitter:KillSound("mating")
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	
	inst.Transform:SetScale(1.2, 1.2, 1.2)
	
	inst.AnimState:SetBank("doydoy_mate_fx")
	inst.AnimState:SetBuild("doydoy_mate_fx")
	inst.AnimState:SetSortOrder(-1)
	inst:AddTag("NOCLICK")

	inst.AnimState:PlayAnimation("mate_pre")
	inst.AnimState:PushAnimation("mate_loop")
	inst.AnimState:PushAnimation("mate_loop")
	inst.AnimState:PushAnimation("mate_loop")
	inst.AnimState:PushAnimation("mate_pst", false)

	inst:ListenForEvent("animqueueover", function(inst) inst:Remove() end)

	inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/doy_doy/mating_voices_LP", "voice")
	inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/doy_doy/mating_cloud_LP", "mating")

	return inst
end

return Prefab("fx/doydoy_mate_fx", fn, assets)
