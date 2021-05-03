local assets=
{
	Asset("ANIM", "anim/wormwood_plant_fx.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	
    inst.animname = math.random(1,4)

	inst.entity:AddAnimState()

    inst.AnimState:SetBank("wormwood_plant_fx")
    inst.AnimState:SetBuild("wormwood_plant_fx")
    inst.AnimState:PlayAnimation("grow_"..inst.animname)

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")
    inst:AddTag("wormwood_plant_fx")
    
    inst.persists = false
    
    inst:ListenForEvent("animover", function(inst, data)
        if inst.ending then
             inst:Remove()
        else
            if not inst:IsNear(GetPlayer(), 2) then
                inst.ending = true
                inst.AnimState:PlayAnimation("ungrow_"..inst.animname)
            else
                inst.AnimState:PlayAnimation("idle_"..inst.animname)
            end
        end
    end)

    return inst
end

return Prefab( "cave/objects/wormwood_plant_fx", fn, assets) 
