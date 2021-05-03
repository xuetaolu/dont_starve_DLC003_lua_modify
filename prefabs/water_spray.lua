local assets =
{
	Asset("ANIM", "anim/sprinkler_fx.zip")
}

local prefabs =
{
}

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()

	anim:SetBank("sprinkler_fx")
	anim:SetBuild("sprinkler_fx")
	anim:PlayAnimation("spray_loop", true)

	return inst
end

return Prefab("water_spray", fn, assets, prefabs)