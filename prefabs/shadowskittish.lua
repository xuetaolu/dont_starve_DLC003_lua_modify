local assets=
{
	Asset("ANIM", "anim/shadow_skittish.zip"),
    Asset("ANIM", "anim/shadow_skittish_ocean.zip"),
}

local function Disappear(inst)
    if inst.deathtask then
        inst.deathtask:Cancel()
        inst.deathtask = nil
    end
    inst.AnimState:PlayAnimation("disappear")
    inst:ListenForEvent("animover", function() inst:Remove() end)
end

local function fn(bank, build)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst:AddTag("NOCLICK")
    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("idle_loop", true)
    inst.AnimState:SetMultColour(1, 1, 1, 0)
    
    inst.deathtask = inst:DoTaskInTime(5 + 10*math.random(), Disappear)
    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(5,8)
    inst.components.playerprox:SetOnPlayerNear(Disappear)
    inst:AddComponent("transparentonsanity")

return inst
end

return Prefab("shadowskittish", function() return fn("shadowcreatures", "shadow_skittish") end, assets),
Prefab("shadowskittish_water", function() return fn("blobbyshadow", "shadow_skittish_ocean") end, assets)
