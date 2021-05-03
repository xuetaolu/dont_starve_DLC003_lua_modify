local assets=
{
	Asset("ANIM", "anim/cactus_spike.zip"),
}

local prefabs = 
{
    "impact",
}

local function onhit(inst, attacker, target)
    local impactfx = SpawnPrefab("impact")
    if impactfx and attacker then
        local follower = impactfx.entity:AddFollower()
        follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0 )
        impactfx:FacePoint(attacker.Transform:GetWorldPosition())
    end
    inst:Remove()
end

local function onthrown(inst, data)
    inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
    
    anim:SetBank("cactus_spike")
    anim:SetBuild("cactus_spike")
    anim:PlayAnimation("spike")
    
    inst:AddTag("projectile")
    inst.persists = false
    
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(30)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetHitDist(2)
    inst.components.projectile:SetOnHitFn(onhit)
    inst.components.projectile:SetOnMissFn(onhit)
    inst:ListenForEvent("onthrown", onthrown)
    
    return inst
end

local function firefn()
    local inst = fn()

    inst.AnimState:PlayAnimation("spike_red")
    
    return inst
end

return Prefab( "common/inventory/needle_dart", fn, assets, prefabs),
       Prefab( "common/inventory/needle_dart_fire", firefn, assets, prefabs) 

