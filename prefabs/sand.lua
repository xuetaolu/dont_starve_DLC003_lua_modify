local assets =
{
	Asset("ANIM", "anim/sandhill.zip")
}

local function ongustblowawayfn(inst)
	if not inst.components.inventoryitem or not inst.components.inventoryitem.owner then 
		inst:RemoveComponent("inventoryitem")
		inst:RemoveComponent("inspectable")
		inst.SoundEmitter:PlaySound("dontstarve/common/dust_blowaway")
		inst.AnimState:PlayAnimation("disappear")
		inst:ListenForEvent("animover", function() inst:Remove() end)
	end 
end

local function sandfn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	MakeInventoryPhysics(inst)

	anim:SetBuild( "sandhill" )
	anim:SetBank( "sandhill" )
	anim:PlayAnimation("idle")

	inst:AddComponent("inspectable")
	-----------------
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	----------------------
	
	inst:AddComponent("inventoryitem")

	inst:AddComponent("blowinwindgust")
	inst.components.blowinwindgust:SetWindSpeedThreshold(TUNING.SAND_WINDBLOWN_SPEED)
	inst.components.blowinwindgust:SetDestroyChance(TUNING.SAND_WINDBLOWN_FALL_CHANCE)
	inst.components.blowinwindgust:SetDestroyFn(ongustblowawayfn)
	
	return inst
end

return Prefab( "common/inventory/sand", sandfn, assets)
