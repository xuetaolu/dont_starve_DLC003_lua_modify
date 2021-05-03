require "prefabutil"
	
local assets =
{
	Asset("ANIM", "anim/test_floor.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

	anim:SetBuild("test_floor")
	anim:SetBank("floor")
	anim:PlayAnimation("idle", true)
	anim:SetOrientation( ANIM_ORIENTATION.OnGround )
	anim:SetLayer( LAYER_BACKGROUND )
	anim:SetSortOrder( 3 )
	anim:SetScale(1.48, 1.48, 1.48)
	inst:AddTag("structure")

    return inst
end

return Prefab( "common/objects/test_interior_floor", fn, assets, {} )  
