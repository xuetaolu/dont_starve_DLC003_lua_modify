local assets =
{
    Asset("ANIM", "anim/explode_firecracker.zip")
}

local function MakeExplosion(data)
    local function PlayExplodeAnim(proxy)
        local inst = CreateEntity()

        inst:AddTag("FX")
        inst.entity:SetCanSleep(false)
        inst.persists = false

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()

        --inst.Transform:SetFromProxy(proxy.GUID)
        inst.Transform:SetPosition(proxy.Transform:GetWorldPosition())

        if data ~= nil and data.scale ~= nil then
            inst.Transform:SetScale(data.scale, data.scale, data.scale)
        end

        inst.AnimState:SetBank("explode")
        inst.AnimState:SetBuild("explode_firecracker")
        inst.AnimState:PlayAnimation(data ~= nil and data.anim or "small")
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        inst.AnimState:SetLightOverride(1)

        if data ~= nil and type(data.sound) == "function" then
            data.sound(inst)
        else
            inst.SoundEmitter:PlaySound(data ~= nil and data.sound or "dontstarve/common/blackpowder_explo")
        end

        inst:ListenForEvent("animover", inst.Remove)
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()

        inst:DoTaskInTime(0, PlayExplodeAnim)

        inst.Transform:SetFourFaced()

        inst:AddTag("FX")

        inst.persists = false
        inst:DoTaskInTime(1, inst.Remove)

        return inst
    end

    return fn
end

local extras =
{
    firecrackers =
    {
        anim = "small_firecrackers",
        sound = function(inst)
            inst.SoundEmitter:PlaySoundWithParams("dontstarve_DLC003/common/objects/fire_cracker", { start = math.random() })
        end,
        scale = .5,
    },
}

return Prefab("explode_firecrackers", MakeExplosion(extras.firecrackers), assets)
	
