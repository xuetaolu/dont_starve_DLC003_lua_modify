local assets =
{
	Asset("ANIM", "anim/basketball.zip"),
	Asset("ANIM", "anim/swap_basketball.zip"),
}

local prefabs =
{

}

local function onputininventory(inst)
	inst.claimed = true
    inst.Physics:SetFriction(.1)
end

local function onthrown(inst, thrower, pt)

	inst:DoTaskInTime(0.3, function(inst)
		inst.claimed = nil
		inst.components.sentientball:OnThrown()
	end)

    inst.Physics:SetFriction(.2)
	inst.Transform:SetFourFaced()
	inst:FacePoint(pt:Get())
    inst.components.floatable:UpdateAnimations("idle_water", "throw")
    inst.AnimState:PlayAnimation("throw", true)
    inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/coconade_throw")

    if thrower.components.sanity then
    	thrower.components.sanity:DoDelta(TUNING.SANITY_SUPERTINY)
    end
end

local function onhitground(inst)
    inst.components.floatable:UpdateAnimations("idle_water", "idle")
end

local function oncollision(inst, other)
	inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/monkey_ball/bounce")
end

local function onequip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_basketball", "swap_basketball")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")

	inst.components.sentientball:OnEquipped()
end

local function onunequip(inst, owner)
	owner.AnimState:ClearOverrideSymbol("swap_object")
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	
	inst.AnimState:SetBank("basketball")
	inst.AnimState:SetBuild("basketball")
	inst.AnimState:PlayAnimation("idle")
	
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "rawling.png" )

	MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "idle_water", "idle")
	inst.components.floatable:SetOnHitLandFn(onhitground)
	inst.components.floatable:SetOnHitWaterFn(onhitground)

	MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.MEDIUM, TUNING.WINDBLOWN_SCALE_MAX.MEDIUM)

	inst:AddComponent("inspectable")
	
	inst:AddTag("nopunch")

	inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(onputininventory)
	inst.components.inventoryitem.bouncesound = "dontstarve_DLC002/common/monkey_ball/bounce"

	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)
	inst.components.equippable.equipstack = true
	inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED

	inst:AddComponent("talker")
	inst.components.talker.fontsize = 28
	inst.components.talker.font = TALKINGFONT
	inst.components.talker.colour = Vector3(.9, .4, .4, 1)
	inst.components.talker.offset = Vector3(0,100,0)
	inst.components.talker.symbol = "swap_object"

	inst:AddComponent("sentientball")
	
	MakeSmallBurnable(inst, TUNING.LARGE_BURNTIME)
	MakeSmallPropagator(inst)
	
	inst:AddComponent("throwable")
	inst.components.throwable.onthrown = onthrown

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = function() 
        return inst.components.throwable:GetThrowPoint()
    end
    inst.components.reticule.ease = true

	inst:ListenForEvent("donetalking", function() inst.SoundEmitter:KillSound("talk") end)
	inst:ListenForEvent("ontalk", function() 
		if inst.components.sentientball.sound_override then
			inst.SoundEmitter:KillSound("talk")
			inst.SoundEmitter:PlaySound(inst.components.sentientball.sound_override, "special")
		else
			if not inst.SoundEmitter:PlayingSound("special") then
				inst.SoundEmitter:PlaySound("dontstarve_DLC002/characters/rawling/talk_LP", "talk") 
			end
		end
	end)

	inst:ListenForEvent("onignite", function()
		inst.components.sentientball:OnIgnite()
	end)

	inst:ListenForEvent("onextinguish", function()
		inst.components.sentientball:OnExtinguish()
	end)

	inst.Physics:SetCollisionCallback(oncollision)
	
	return inst
end

return Prefab( "common/inventory/rawling", fn, assets, prefabs)
