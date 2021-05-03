local assets=
{
	Asset("ANIM", "anim/interior_floor.zip"),
}

local prefabs =
{

}    

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst:AddTag("interior")

	inst.entity:AddAnimState()
    inst.AnimState:SetBank("interior_floor")
    inst.AnimState:SetBuild("interior_floor")
    inst.AnimState:PlayAnimation("idle",true)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)

    inst.AnimState:SetLayer( LAYER_BACKGROUND )
    inst.AnimState:SetSortOrder( 3 )      
    inst.AnimState:SetScale(2,2,2 )      
    --inst.AnimState:SetRayTestOnBB(true);

    return inst
end

return Prefab( "interior/objects/floor_interior", fn, assets, prefabs)
