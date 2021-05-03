require "stategraphs/SGtrap"

local assets=
{
	Asset("ANIM", "anim/trap.zip"),
	Asset("SOUND", "sound/common.fsb"),
}

local sea_assets=
{
	Asset("ANIM", "anim/trap_sea.zip"),
	Asset("SOUND", "sound/common.fsb"),
	Asset("MINIMAP_IMAGE", "trap_sea"),
}

local sounds =
{
	close = "dontstarve/common/trap_close",
	rustle = "dontstarve/common/trap_rustle",
}

local seasounds =
{
	close = "dontstarve/common/trap_close",
	rustle = "dontstarve/common/trap_rustle",
}

local function onfinished(inst)
	inst:Remove()
end

local function onharvested(inst)
	if inst.components.finiteuses then
		inst.components.finiteuses:Use(1)
	end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	MakeInventoryPhysics(inst)

	anim:SetBank("trap")
	anim:SetBuild("trap")
	anim:PlayAnimation("idle")
	inst.sounds = sounds

	inst:AddTag("trap")

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")

	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetMaxUses(TUNING.TRAP_USES)
	inst.components.finiteuses:SetUses(TUNING.TRAP_USES)
	inst.components.finiteuses:SetOnFinished( onfinished )

	inst:AddComponent("trap")
	inst.components.trap.targettag = "canbetrapped"
	inst.components.trap:SetOnHarvestFn(onharvested)

	return inst
end

local function commonfn(Sim)
	local inst = fn(Sim)

	MakeInventoryFloatable(inst, "idle_water", "idle")

	inst.entity:AddMiniMapEntity()
	inst.MiniMapEntity:SetIcon("rabbittrap.png")
	inst.components.trap.baitsortorder = 1
	inst:SetStateGraph("SGtrap")

	return inst
end

local function sea_onbaited(inst, bait)
	inst:PushEvent("baited")
	bait:Hide()
end

local function sea_onpickup(inst, doer)
	if inst.components.trap and inst.components.trap.bait and doer.components.inventory then
		inst.components.trap.bait:Show()
		doer.components.inventory:GiveItem(inst.components.trap.bait)
	end
end

local function seafn(Sim)
	local inst = fn(Sim)

	inst.entity:AddMiniMapEntity()
	inst.MiniMapEntity:SetIcon("rabbittrap.png")

	inst.AnimState:SetBank("trap_sea")
	inst.AnimState:SetBuild("trap_sea")
	inst.AnimState:PlayAnimation("idle")

	inst.components.trap.water = true
	inst.components.trap.onbaited = sea_onbaited
	inst.components.trap.range = 2

	inst.components.inventoryitem.nobounce = true
	inst.components.inventoryitem:SetOnPickupFn(sea_onpickup)

	MakeInventoryFloatable(inst, "idle_water", "idle")
	
	inst.no_wet_prefix = true

	inst:SetStateGraph("SGseatrap")

	inst.sounds = seasounds

	return inst
end

return Prefab("common/inventory/trap", commonfn, assets),
	   Prefab("common/inventory/seatrap", seafn, sea_assets)
