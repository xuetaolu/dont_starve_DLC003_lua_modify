local assets =
{
	Asset("ANIM", "anim/rowboat_basic.zip"),
	Asset("ANIM", "anim/waxwell_shadowboat_build.zip"),
}

local prefabs = {}

local function setupcontainer(inst, slots, bank, build, inspectslots, inspectbank, inspectbuild, inspectboatbadgepos, inspectboatequiproot)
	inst:AddComponent("container")
	inst.components.container:SetNumSlots(#slots)
	inst.components.container.type = "boat"
	inst.components.container.side_align_tip = -500
	inst.components.container.canbeopened = false

	inst.components.container.widgetslotpos = slots
	inst.components.container.widgetanimbank = bank
	inst.components.container.widgetanimbuild = build
	inst.components.container.widgetboatbadgepos = Vector3(0, 40, 0)
	inst.components.container.widgetequipslotroot = Vector3(-80, 40, 0)


	local boatwidgetinfo = {}
	boatwidgetinfo.widgetslotpos = inspectslots
	boatwidgetinfo.widgetanimbank = inspectbank
	boatwidgetinfo.widgetanimbuild = inspectbuild
	boatwidgetinfo.widgetboatbadgepos = inspectboatbadgepos
	boatwidgetinfo.widgetpos = Vector3(200, 0, 0)
	boatwidgetinfo.widgetequipslotroot = inspectboatequiproot
	inst.components.container.boatwidgetinfo = boatwidgetinfo
end 

local function boat_perish(inst)
	if inst.components.drivable.driver then
		local driver = inst.components.drivable.driver
		driver.components.driver:OnDismount(true)
		driver.components.health:Kill("drowning")
		inst.SoundEmitter:PlaySound(inst.sinksound)
		inst:Remove()
	end
end

local function candrive(inst, driver)
	return driver and driver.prefab and driver.prefab == "shadowwaxwell"
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	
	trans:SetFourFaced()

	inst:AddTag("shadowboat")

	anim:SetBank("rowboat")
	anim:SetBuild("waxwell_shadowboat_build")
	anim:PlayAnimation("run_loop", true)

	--setupcontainer(inst, {}, "boat_hud_raft", "boat_hud_raft", {}, "boat_inspect_raft", "boat_inspect_raft", {x=0,y=5}, {})

	inst:AddComponent("drivable")
	inst.components.drivable.sanitydrain = TUNING.ROWBOAT_SANITY_DRAIN
	inst.components.drivable.runspeed = TUNING.ROWBOAT_SPEED
	inst.components.drivable.runanimation = "sail_loop"
	inst.components.drivable.prerunanimation = "sail_pre"
	inst.components.drivable.postrunanimation = "sail_pst"
	inst.components.drivable.overridebuild = "waxwell_shadowboat_build"
	inst.components.drivable.flotsambuild = "flotsam_rowboat_build"
	inst.components.drivable.hitfx = "boat_hit_fx_rowboat"
	inst.components.drivable.maprevealbonus = TUNING.MAPREVEAL_ROWBOAT_BONUS
	inst.components.drivable.candrivefn = candrive

	inst.AnimState:SetMultColour(0,0,0,.4)

	-- inst:AddComponent("boathealth")
	-- inst.components.boathealth:SetDepletedFn(boat_perish)
	-- inst.perishtime = TUNING.ROWBOAT_PERISHTIME
	-- inst.components.boathealth:SetHealth(inst.perishtime)

	inst.no_wet_prefix = true

 	return inst
end

return Prefab("shadowwaxwell_boat", fn, assets, prefabs)