local assets=
{
	Asset("ANIM", "anim/wormwood_pollen_fx.zip"),
}


local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()

	inst.entity:AddAnimState()

    inst.AnimState:SetBank("wormwood_pollen_fx")
    inst.AnimState:SetBuild("wormwood_pollen_fx")
    inst.AnimState:PlayAnimation("pollen_loop")

    inst.AnimState:Hide("pollen1")
    inst.AnimState:Hide("pollen2")
    inst.AnimState:Hide("pollen3")
    inst.AnimState:Hide("pollen4")
    inst.AnimState:Hide("pollen5")

    inst.AnimState:Show("pollen"..math.random(1,5))
    

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")
    inst:AddTag("wormwood_pollen_fx")
    
    inst.persists = false

    inst:ListenForEvent("animover", function(inst, data)    
        inst:Remove()          
    end)

    return inst
end

return Prefab( "cave/objects/wormwood_pollen_fx", fn, assets) 
