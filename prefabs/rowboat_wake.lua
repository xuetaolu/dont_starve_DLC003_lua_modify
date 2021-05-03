local assets =
{
	Asset( "ANIM", "anim/rowboat_wake_trail.zip" ),
}

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	--trans:SetFourFaced()
	
	inst.persists = false

    local anim = inst.entity:AddAnimState()

    anim:SetBuild("rowboat_wake_trail")
   	anim:SetBank( "wakeTrail" )
   	anim:SetOrientation( ANIM_ORIENTATION.OnGround )
	anim:SetLayer(LAYER_BACKGROUND )
	anim:SetSortOrder( 3 )
	anim:PlayAnimation( "trail" ) 

	--inst:Hide()
	inst:AddTag( "FX" )
	inst:AddTag( "NOCLICK" )
	inst:ListenForEvent("animover", inst.Remove)
	inst:ListenForEvent("entitysleep", inst.Remove)

	inst:AddComponent("colourtweener")
	inst.components.colourtweener:StartTween({0,0,0,0}, FRAMES*20)

    return inst
end

return Prefab( "common/fx/rowboat_wake", fn, assets ) 
 
