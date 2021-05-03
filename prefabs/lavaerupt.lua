local erupt_assets =
{
	Asset("ANIM", "anim/lava_erupt.zip"),
}

local bubble_assets =
{
	Asset("ANIM", "anim/lava_erupt.zip"),
	Asset("ANIM", "anim/lava_bubbling.zip"),
}

local function OnEntitySleep(inst)
	inst:Remove()
end

local function commonfn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	inst:AddTag("FX")

	inst.OnEntitySleep = OnEntitySleep

	inst:ListenForEvent( "animover", function(inst) inst:Remove() end )

	return inst	
end

local function eruptfn(Sim)
	local inst = commonfn(Sim)
	inst.AnimState:SetBank("lava_erupt")
	inst.AnimState:SetBuild("lava_erupt")
	inst.AnimState:PlayAnimation("idle")
	inst.SoundEmitter:PlaySound("dontstarve_DLC002/volcano_amb/volcano_rock_launch")
	return inst
end

local function bubblefn(Sim)
	local inst = commonfn(Sim)
	inst.AnimState:SetBank("lava_bubbling")
	inst.AnimState:SetBuild("lava_erupt")
	inst.AnimState:PlayAnimation("idle")
	inst.SoundEmitter:PlaySound("dontstarve_DLC002/volcano_amb/lava_bubbling")
	return inst
end

return Prefab("common/volcano/lava_erupt", eruptfn, erupt_assets),
		Prefab("common/volcano/lava_bubbling", bubblefn, bubble_assets)