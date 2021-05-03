local assets=
{
	Asset("ANIM", "anim/pike_skull.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    MakeObstaclePhysics(inst, 0.25)
     
    anim:SetBank("pike_skull")
    anim:SetBuild("pike_skull")
    anim:PlayAnimation("idle")
    
    return inst
end

return Prefab( "common/pike_skull", fn, assets) 
