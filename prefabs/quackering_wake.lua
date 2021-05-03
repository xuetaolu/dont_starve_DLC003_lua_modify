local assets =
{
	Asset( "ANIM", "anim/quackering_ram_splash.zip" ),
}

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	--trans:SetFourFaced()

    local anim = inst.entity:AddAnimState()

    anim:SetBuild("quackering_ram_splash")
   	anim:SetBank( "fx" )
   	--anim:SetOrientation( ANIM_ORIENTATION.OnGround )
	anim:SetLayer(LAYER_BACKGROUND )
	anim:SetSortOrder( 3 )
	inst:DoTaskInTime(6 * FRAMES, function() anim:PlayAnimation( inst.idleanimation ) end)

	--inst:Hide()
	inst:AddTag( "FX" )
	inst:AddTag( "NOCLICK" )
	inst:ListenForEvent( "animover", function(inst) inst:Remove() end )

	inst:AddComponent("colourtweener")
	inst.components.colourtweener:StartTween({0,0,0,0}, FRAMES*30)

    return inst
end

return Prefab( "common/fx/quackering_wake", fn, assets ) 
 
