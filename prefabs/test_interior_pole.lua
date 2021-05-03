require "prefabutil"
	
local assets =
{
	Asset("ANIM", "anim/test_pillar.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

	anim:SetBuild("test_pillar")
	anim:SetBank("pillar")
	anim:PlayAnimation("idle", true)
	inst:AddTag("structure")

    return inst
end

return Prefab( "common/objects/test_interior_pole", fn, assets, {} )  
