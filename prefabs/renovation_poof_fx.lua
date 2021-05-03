local assets=
{
	Asset("ANIM", "anim/structure_collapse_fx.zip"),
}

local function kill(inst)
	inst:Remove()
end

local function fx(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	
	inst.entity:AddSoundEmitter()
    inst.AnimState:SetBank("collapse")
    inst.AnimState:SetBuild("structure_collapse_fx")
    inst:AddTag("NOCLICK")

    inst.AnimState:PlayAnimation("collapse_large")
    inst:DoTaskInTime(1, kill)
    --inst.SoundEmitter:PlaySound("dontstarve/common/destroy_smoke")
    return inst
end

return Prefab( "fx/renovation_poof_fx", fx, assets)
