local assets =
{
	Asset("ANIM", "anim/hat_propeller_fx.zip")
}

local function UpdateRotation(inst)
	inst.Transform:SetRotation(GetPlayer().Transform:GetRotation())
end

local function fn(Sim)
	local inst = CreateEntity()
	inst:AddTag("FX")
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

	inst.Transform:SetFourFaced()

	anim:SetBank("hat_propeller_fx")
	anim:SetBuild("hat_propeller_fx")
	anim:PlayAnimation("on", true)

	inst.rotateTask = inst:DoPeriodicTask(1/30, UpdateRotation)

    return inst
end

return Prefab("common/fx/hatpropeller", fn, assets) 
