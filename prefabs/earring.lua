local assets=
{
	Asset("ANIM", "anim/earring.zip"),
}

local function shine(inst)
    inst.task = nil

     -- hacky, need to force a floatable anim change
    inst.components.floatable:UpdateAnimations("idle_water", "idle")
    inst.components.floatable:UpdateAnimations("sparkle_water", "sparkle")

    if inst.components.floatable.onwater then
        inst.AnimState:PushAnimation("idle_water")
    else
        inst.AnimState:PushAnimation("idle")
    end
    inst.task = inst:DoTaskInTime(4+math.random()*5, function() shine(inst) end)
end


local function fn(Sim)
    
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddPhysics()

    inst:AddTag("trinket")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")

	inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )    
	
    inst.AnimState:SetBank("earring")
    inst.AnimState:SetBuild("earring")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("stackable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = 3
    inst.components.tradable.dubloonvalue = 12

    inst:AddComponent("appeasement")
      
    inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_HUGE
    
    shine(inst)
    return inst
end

return Prefab( "common/inventory/earring", fn, assets)
