local assets=
{
	Asset("ANIM", "anim/disarm_kit.zip"),	
}

local function onfinished(inst)
	inst:Remove()
end



local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	
	MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "idle_water", "idle")

	inst.AnimState:SetBank("disarm_kit")
	inst.AnimState:SetBuild("disarm_kit")
	inst.AnimState:PlayAnimation("idle")
	
	inst:AddComponent("finiteuses")

	local uses = TUNING.SEWINGKIT_USES
    local player = GetPlayer()
    if player and player:HasTag("treasure_hunter") then
        uses = uses * 2
    end

	inst.components.finiteuses:SetMaxUses(uses)
	inst.components.finiteuses:SetUses(uses)
	inst.components.finiteuses:SetOnFinished( onfinished )
	inst.components.finiteuses:SetConsumption(ACTIONS.DISARM, 1)
	
	---------------------       
	
	inst:AddComponent("disarming")
	
	inst:AddComponent("inspectable")
	
	inst:AddComponent("inventoryitem")

	return inst
end

return Prefab( "common/inventory/disarming_kit", fn, assets) 

