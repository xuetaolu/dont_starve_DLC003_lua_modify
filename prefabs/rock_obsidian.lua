local assets_obsidian =
{
	Asset("ANIM", "anim/rock_obsidian.zip"),
	Asset("MINIMAP_IMAGE", "rock_obsidian"),
}

local assets_charcoal =
{
	Asset("ANIM", "anim/rock_charcoal.zip"),
	Asset("MINIMAP_IMAGE", "rock_charcoal"),
}

local prefabs_obsidian =
{
	"obsidian"
}

local prefabs_charcoal =
{
	"charcoal",
	"flint"
}

SetSharedLootTable("rock_obsidian",
{
	{"obsidian", 1.0},
	{"obsidian", 1.0},
	{"obsidian", 0.5},
	{"obsidian", 0.25},
	{"obsidian", 0.25},
})

SetSharedLootTable("rock_charcoal",
{
	{"charcoal", 1.0},
	{"charcoal", 1.0},
	{"charcoal", 0.5},
	{"charcoal", 0.25},
	{"charcoal", 0.25},
	{"flint", 0.5},
})

local function onwork(inst, worker, workleft)
	if workleft < TUNING.ROCKS_MINE*(1/3) then
		inst.AnimState:PlayAnimation("low")
	elseif workleft < TUNING.ROCKS_MINE*(2/3) then
		inst.AnimState:PlayAnimation("med")
	else
		inst.AnimState:PlayAnimation("full")
	end
end

local function onfinish_obsidian(inst, worker)
	local pt = Point(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/obsidian_explode")
	inst.components.lootdropper:ExplodeLoot(pt, 6 + (math.random() * 8))
	inst.components.growable:SetStage(1)
	--inst:Remove()
end

local function onfinish_charcoal(inst, worker)
	local pt = Point(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")
	inst.components.lootdropper:DropLoot(pt)
	inst.components.growable:SetStage(1)
	--inst:Remove()
end

local function SetEmpty(inst)
	local sm = GetSeasonManager()
	local days = sm:GetSeasonLength(SEASONS.MILD) + sm:GetSeasonLength(SEASONS.WET) + sm:GetSeasonLength(SEASONS.GREEN) + sm:GetSeasonLength(SEASONS.DRY)
	inst.components.growable:StartGrowing(days * TUNING.TOTAL_DAY_TIME)
	inst.Physics:SetCollides(false)
	inst:AddTag("NOCLICK")
	inst.MiniMapEntity:SetEnabled(false)
	inst:Hide()
end

local function SetFull(inst)
	inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE)
	inst.components.growable:StopGrowing()
	inst.Physics:SetCollides(true)
	inst:RemoveTag("NOCLICK")
	inst:Show()
	inst.MiniMapEntity:SetEnabled(true)
end

local function ongrowthfn(inst, last, current)
	inst.AnimState:PlayAnimation(inst.components.growable.stages[current].anim)
end

local grow_stages =
{
	{name="empty", fn=SetEmpty},
	{name="full", fn=SetFull, anim="full"},
}

local function commonfn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local minimap = inst.entity:AddMiniMapEntity()

	MakeObstaclePhysics(inst, 1)

	inst:AddComponent("lootdropper")
	inst:AddComponent("inspectable")
	
	inst:AddComponent("workable")
	inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE)
	inst.components.workable:SetOnWorkCallback(onwork)

	inst:AddComponent("growable")
	inst.components.growable.stages = grow_stages
	inst.components.growable:SetStage(2)
	inst.components.growable:SetOnGrowthFn(ongrowthfn)
	inst.components.growable.loopstages = false
	inst.components.growable.growonly = false
	inst.components.growable.springgrowth = false
	inst.components.growable.growoffscreen = true

	return inst	
end

local function obsidianfn(Sim)
	local inst = commonfn(Sim)
	inst.AnimState:SetBank("rock_obsidian")
	inst.AnimState:SetBuild("rock_obsidian")
	inst.AnimState:PlayAnimation("full")
	inst.MiniMapEntity:SetIcon("rock_obsidian.png")

	inst.components.workable:SetWorkAction(nil)
	inst.components.workable:SetOnFinishCallback(onfinish_obsidian)
	inst.components.lootdropper:SetChanceLootTable("rock_obsidian")
	return inst
end

local function charcoalfn(Sim)
	local inst = commonfn(Sim)
	inst.AnimState:SetBank("rock_charcoal")
	inst.AnimState:SetBuild("rock_charcoal")
	inst.AnimState:PlayAnimation("full")
	inst.MiniMapEntity:SetIcon("rock_charcoal.png")

	inst.components.workable:SetWorkAction(ACTIONS.MINE)
	inst.components.workable:SetOnFinishCallback(onfinish_charcoal)
	inst.components.lootdropper:SetChanceLootTable("rock_charcoal")
	return inst
end

return Prefab("shipwrecked/objects/rock_obsidian", obsidianfn, assets_obsidian, prefabs_obsidian),
	Prefab("shipwrecked/objects/rock_charcoal", charcoalfn, assets_charcoal, prefabs_charcoal)