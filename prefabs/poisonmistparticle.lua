local assets =
{
	Asset( "ANIM", "anim/mist_fx.zip" )
}

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

    anim:SetBuild( "mist_fx" )
    anim:SetBank( "mist_fx" )
    anim:PlayAnimation( "idle", true )

    local cloudScale = (math.random() * 1.5) + 1.5
    inst.Transform:SetScale(cloudScale, cloudScale, cloudScale)
    inst.AnimState:SetMultColour(0.3, 0.6, 0.2, 1)
    inst:AddTag("NOCLICK")
    anim:SetTime(math.random() * anim:GetCurrentAnimationLength())

    return inst
end

return Prefab( "common/fx/poisonmist", fn, assets) 
 
