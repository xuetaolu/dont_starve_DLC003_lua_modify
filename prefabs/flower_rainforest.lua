local assets=
{	
    Asset("ANIM", "anim/flowers_rainforest.zip"),    
}


local prefabs =
{
    "petals",
}    


local names = {"f1","f2","f3","f4","f5","f6","f7","f8","f9","f10","f11","f12","f14","f15","f16","f17"}

local function onsave(inst, data)
	data.anim = inst.animname
end

local function onload(inst, data)
    if data and data.anim then
        inst.animname = data.anim
	    inst.AnimState:PlayAnimation(inst.animname)
	end
end

local function onpickedfn(inst, picker)
    if picker:HasTag("plantkin") then
        if picker.killedplantfn then
            picker.killedplantfn(picker)
        end
    else
       if picker and picker.components.sanity then
          picker.components.sanity:DoDelta(TUNING.SANITY_TINY)
       end     
    end
    
    inst:Remove()
end

local function ongustpickfn(inst)
    if inst.components.pickable and inst.components.pickable:CanBePicked() then
        inst.components.pickable:MakeEmpty()
        local x, y, z = inst.Transform:GetWorldPosition()
        local petals = SpawnPrefab(inst.components.pickable.product)
        petals.Transform:SetPosition(x, y, z)
        inst:Remove()
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	
	inst.entity:AddAnimState()
    inst.AnimState:SetBank("flowers_rainforest")
    inst.animname = names[math.random(#names)]
    inst.AnimState:SetBuild("flowers_rainforest")
    inst.AnimState:PlayAnimation(inst.animname)
    inst.AnimState:SetRayTestOnBB(true);
    
   -- inst:AddTag("flower")
    inst:AddTag("flower_rainforest")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("pickable")
    inst.components.pickable.picksound = "dontstarve/wilson/pickup_plants"
    inst.components.pickable:SetUp("petals", 10)
	inst.components.pickable.onpickedfn = onpickedfn
    inst.components.pickable.quickpick = true
    inst.components.pickable.wildfirestarter = true

    inst:AddTag("cattoy")
    
	MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)
    inst.components.burnable:MakeDragonflyBait(1)

--[[
    inst:AddComponent("transformer")
    inst.components.transformer:SetTransformEvent("fullmoon")
    inst.components.transformer:SetRevertEvent("daytime")
    inst.components.transformer:SetOnLoadCheck( function() 
        if not GetWorld():IsCave() then
            return (GetClock():IsNight() and GetClock():GetMoonPhase() == "full")
        end
        return false
    end )
    inst.components.transformer.transformPrefab = "flower_evil"
]]
    inst:AddComponent("blowinwindgust")
    inst.components.blowinwindgust:SetWindSpeedThreshold(TUNING.FLOWER_WINDBLOWN_SPEED)
    inst.components.blowinwindgust:SetDestroyChance(TUNING.FLOWER_WINDBLOWN_FALL_CHANCE)
    inst.components.blowinwindgust:SetDestroyFn(ongustpickfn)
    inst.components.blowinwindgust:Start()


    --------SaveLoad
    inst.OnSave = onsave 
    inst.OnLoad = onload 
    
    return inst
end

return Prefab( "forest/objects/flower_rainforest", fn, assets, prefabs) 
