local assets = 
{
   Asset("ANIM", "anim/sea_yard_tools.zip")
}

local function delete(inst, user)
     inst:Remove() 
     if user then
        user.armsfx = nil
    end
end

local function stopfx(inst, user)
    inst.AnimState:PlayAnimation("out")
    inst:ListenForEvent("animover", function() 
        inst.SoundEmitter:KillSound("fix")   
        delete(inst, user) 
    end)   
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()

    anim:SetFinalOffset(10)

    anim:SetBank("sea_yard_tools")
    anim:SetBuild("sea_yard_tools")
    anim:PlayAnimation("in")
    anim:PushAnimation("loop", true)
    inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/splash_medium")
    inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/shipyard/fix_LP", "fix")   

    inst.stopfx = stopfx
    return inst
end

return Prefab( "shipwrecked/sea_yard_arms_fx", fn, assets) 
