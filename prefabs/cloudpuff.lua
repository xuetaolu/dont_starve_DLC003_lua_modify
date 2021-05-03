local assets =
{
	Asset( "ANIM", "anim/cloud_puff_soft.zip" )
}

local function onSleep(inst)
	inst:Remove()
end 

local function SetAnim(inst)
	inst.AnimState:PlayAnimation("poofanim", false)
	local x, y, z = inst.Transform:GetWorldPosition()

	local map = GetWorld().Map

	local tx, ty = map:GetTileXYAtPoint(x, y, z)

	local left = map:IsLand(map:GetTile(tx, ty)) and map:IsWater(map:GetTile(tx, ty))
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()

	inst.persists = false

    anim:SetBuild( "cloud_puff_soft" )
    anim:SetBank( "splash_clouds_drop" )
    anim:PlayAnimation( "idle_sink" )

	inst:AddTag( "FX" )
	inst:AddTag( "NOCLICK" )
	inst.OnEntitySleep = onSleep
	--swap comments on these lines:
	inst:ListenForEvent( "animover", function(inst) inst:Remove() end )

	-- inst.SetAnim = SetAnim

    return inst
end

return Prefab( "common/fx/cloudpuff", fn, assets )
