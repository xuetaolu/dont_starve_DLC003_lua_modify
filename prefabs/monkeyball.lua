local assets=
{
	Asset("ANIM", "anim/monkey_ball.zip"),
	Asset("ANIM", "anim/swap_monkeyball.zip"),
}

local prefabs=
{
}

local function unclaim(inst)
	inst.claimed = nil
end

local function onequip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_monkeyball", "swap_monkeyball")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
	owner.AnimState:ClearOverrideSymbol("swap_object")
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
end

local function onputininventory(inst)
	-- print('monkeyball in invnentory')
	inst.claimed = true
    inst.Physics:SetFriction(.1)
end

local function onthrown(inst, thrower, pt)

	inst.unclaimtask = inst:DoTaskInTime(1, unclaim)

    inst.Physics:SetFriction(.2)
	inst.Transform:SetFourFaced()
	inst:FacePoint(pt:Get())
    inst.components.floatable:UpdateAnimations("idle_water", "throw")
    inst.AnimState:PlayAnimation("throw", true)
    inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/coconade_throw")

    -- inst.components.inventoryitem.canbepickedup = false
end

local function onhitground(inst)
	if inst.unclaimtask then
		inst.unclaimtask:Cancel()
		inst.unclaimtask = nil
	end
	unclaim(inst)
    inst.components.floatable:UpdateAnimations("idle_water", "idle")
end

local function oncollision(inst, other)
	if inst.Physics:GetVelocity() ~= 0 then
		inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/monkey_ball/bounce")
	end
end

local function pop(inst)
	inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/monkey_ball/pop")
	SpawnPrefab("small_puff_light").Transform:SetPosition(inst.Transform:GetWorldPosition())
	SpawnPrefab("coconut_chunks").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst:Remove()
end

local function onfinished(inst)
	inst.components.floatable:SetOnHitLandFn(pop)
	inst.components.floatable:SetOnHitWaterFn(pop)
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

	inst.AnimState:SetBank("monkeyball")
	inst.AnimState:SetBuild("monkey_ball")
	inst.AnimState:PlayAnimation("idle")

    MakeSmallBurnable(inst)
	MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "idle_water", "idle")

	inst.components.floatable:SetOnHitLandFn(onhitground)
	inst.components.floatable:SetOnHitWaterFn(onhitground)

	inst:AddTag("thrown")
	inst:AddTag("projectile")
	inst:AddTag("monkeybait")

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(onputininventory)
	inst.components.inventoryitem.bouncesound = "dontstarve_DLC002/common/monkey_ball/bounce"

	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)
	inst.components.equippable.equipstack = true

	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(TUNING.MONKEYBALL_USES)
	inst.components.finiteuses:SetUses(TUNING.MONKEYBALL_USES)
	inst.components.finiteuses:SetOnFinished(onfinished)
	inst.components.finiteuses:SetConsumption(ACTIONS.THROW, 1)

	inst:AddComponent("throwable")
	inst.components.throwable.onthrown = onthrown

	inst:AddComponent("reticule")
    inst.components.reticule.targetfn = function() 
        return inst.components.throwable:GetThrowPoint()
    end
    inst.components.reticule.ease = true

    inst.Physics:SetCollisionCallback(oncollision)

	return inst
end

return Prefab("common/inventory/monkeyball", fn, assets, prefabs)
