local assets =
{
	Asset("ANIM", "anim/gunpowder_barrel.zip"),
	Asset("ANIM", "anim/explode.zip"),
	Asset("MINIMAP_IMAGE", "gunpowder_barrel"),
}

local prefabs =
{
	"explode_small"
}

local function OnIgniteFn(inst)
	inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_fuse_LP", "hiss")
end

local function OnExplodeFn(inst)
	inst.SoundEmitter:KillSound("hiss")

	local pos = inst:GetPosition()
	SpawnWaves(inst, 6, 360, 5)
	local splash = SpawnPrefab("bombsplash")
	splash.Transform:SetPosition(pos.x, pos.y, pos.z)

	inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/powderkeg/powderkeg")
	inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/powderkeg/splash_medium")
end

local function OnHitFn(inst)
	if inst.components.burnable then
		inst.components.burnable:Ignite()
	end
	if inst.components.freezable then
		inst.components.freezable:Unfreeze()
	end
	if inst.components.health then
		inst.components.health:DoFireDamage(0)
	end
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("gunpowder_barrel.png")

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("gunpowder_barrel")
	inst.AnimState:SetBuild("gunpowder_barrel")
	inst.AnimState:PlayAnimation("idle_water", true)

	-- MakeInventoryFloatable(inst, "idle_water", "idle_water")
	MakeRipples(inst)

	inst:AddComponent("inspectable")
	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(1000000)

	inst:AddComponent("combat")
	inst.components.combat:SetOnHit(OnHitFn)

	MakeSmallBurnable(inst, 3+math.random()*3)
	MakeSmallPropagator(inst)

	inst:AddComponent("explosive")
	inst.components.explosive:SetOnExplodeFn(OnExplodeFn)
	inst.components.explosive:SetOnIgniteFn(OnIgniteFn)
	inst.components.explosive.explosiverange = TUNING.REDBARREL_RANGE
	inst.components.explosive.explosivedamage = TUNING.REDBARREL_DAMAGE
	inst.components.explosive.buildingdamage = 0

	inst:AddComponent("appeasement")
	inst.components.appeasement.appeasementvalue = TUNING.WRATH_LARGE * 2

	return inst
end

return Prefab( "common/inventory/redbarrel", fn, assets, prefabs)
