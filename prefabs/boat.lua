require "prefabutil"

--The test to see if a boat can be built in a certain position is defined in the builder component Builder:CanBuildAtPoint

local prefabs =
{
	"rowboat_wake",
	"boat_hit_fx",
	"boat_hit_fx_raft_log",
	"boat_hit_fx_raft_bamboo",
	"boat_hit_fx_rowboat",
	"boat_hit_fx_cargoboat",
	"boat_hit_fx_armoured",
	"flotsam_armoured",
	"flotsam_bamboo",
	"flotsam_cargo",
	"flotsam_lograft",
	"flotsam_rowboat",
	"flotsam_surfboard",
	"flotsam_corkboat",
	"woodlegs_boatcannon",
	"woodlegssail",
	"woodlegs_cannonshot",
}

local soundprefix = "researchlab"
local name = "researchlab"

local rowboatassets =
{
	--Asset("ANIM", "anim/researchlab.zip"),
	Asset("ANIM", "anim/rowboat_basic.zip"),
	Asset("ANIM", "anim/rowboat_build.zip"),
	Asset("ANIM", "anim/swap_sail.zip"),
	Asset("ANIM", "anim/swap_lantern_boat.zip"),
	Asset("ANIM", "anim/boat_hud_row.zip"),
	Asset("ANIM", "anim/boat_inspect_row.zip"),
	Asset("ANIM", "anim/flotsam_rowboat_build.zip"),
}

local raftassets =
{
	Asset("ANIM", "anim/raft_basic.zip"),
	Asset("ANIM", "anim/raft_build.zip"),
	Asset("ANIM", "anim/boat_hud_raft.zip"),
	Asset("ANIM", "anim/boat_inspect_raft.zip"),
	Asset("ANIM", "anim/flotsam_bamboo_build.zip"),
}

local surfboardassets =
{
	Asset("ANIM", "anim/raft_basic.zip"),
	Asset("ANIM", "anim/raft_surfboard_build.zip"),
	Asset("ANIM", "anim/boat_hud_raft.zip"),
	Asset("ANIM", "anim/boat_inspect_raft.zip"),
	Asset("ANIM", "anim/flotsam_surfboard_build.zip"),
	Asset("ANIM", "anim/surfboard.zip"),
	Asset("MINIMAP_IMAGE", "surfboard"),
}

local cargoassets =
{
	Asset("ANIM", "anim/rowboat_basic.zip"),
	Asset("ANIM", "anim/rowboat_cargo_build.zip"),
	Asset("ANIM", "anim/swap_sail.zip"),
	Asset("ANIM", "anim/swap_lantern_boat.zip"),
	Asset("ANIM", "anim/boat_hud_cargo.zip"),
	Asset("ANIM", "anim/boat_inspect_cargo.zip"),
	Asset("ANIM", "anim/flotsam_cargo_build.zip"),
	Asset("MINIMAP_IMAGE", "cargo"),
}

local armouredboatassets =
{
	--Asset("ANIM", "anim/researchlab.zip"),
	Asset("ANIM", "anim/rowboat_basic.zip"),
	Asset("ANIM", "anim/rowboat_armored_build.zip"),
	Asset("ANIM", "anim/swap_sail.zip"),
	Asset("ANIM", "anim/swap_lantern_boat.zip"),
	Asset("ANIM", "anim/boat_hud_row.zip"),
	Asset("ANIM", "anim/boat_inspect_row.zip"),
	Asset("ANIM", "anim/flotsam_armoured_build.zip"),
}

local encrustedboatassets =
{
	Asset("ANIM", "anim/rowboat_basic.zip"),
	Asset("ANIM", "anim/rowboat_encrusted_build.zip"),
	Asset("ANIM", "anim/swap_sail.zip"),
	Asset("ANIM", "anim/swap_lantern_boat.zip"),
	Asset("ANIM", "anim/boat_hud_encrusted.zip"),
	Asset("ANIM", "anim/boat_inspect_encrusted.zip"),
	-- TODO: add encrusted flotsam
	Asset("ANIM", "anim/flotsam_armoured_build.zip"),
}

local lograftassets =
{
	Asset("ANIM", "anim/raft_basic.zip"),
	Asset("ANIM", "anim/raft_log_build.zip"),
	Asset("ANIM", "anim/boat_hud_raft.zip"),
	Asset("ANIM", "anim/boat_inspect_raft.zip"),
	Asset("ANIM", "anim/flotsam_lograft_build.zip"),
}

local woodlegsboatassets =
{
	--Asset("ANIM", "anim/researchlab.zip"),
	Asset("ANIM", "anim/rowboat_basic.zip"),
	Asset("ANIM", "anim/pirate_boat_build.zip"),
	Asset("ANIM", "anim/boat_hud_raft.zip"),
	Asset("ANIM", "anim/boat_inspect_raft.zip"),
	Asset("ANIM", "anim/flotsam_rowboat_build.zip"),
	Asset("ANIM", "anim/pirate_boat_placer.zip"),
}


local corkboatassets =
{
	--Asset("ANIM", "anim/researchlab.zip"),
	Asset("ANIM", "anim/rowboat_basic.zip"),
	Asset("ANIM", "anim/corkboat.zip"),	
	Asset("ANIM", "anim/coracle_boat_build.zip"),
	Asset("ANIM", "anim/boat_hud_raft.zip"),
	Asset("ANIM", "anim/boat_inspect_raft.zip"),
	Asset("ANIM", "anim/flotsam_corkboat_build.zip"),
	Asset("ANIM", "anim/pirate_boat_placer.zip"),
	Asset("MINIMAP_IMAGE", "coracle_boat"),
}

local function boat_perish(inst)

	--inst:PushEvent("death", {})
	--GetWorld():PushEvent("entity_death", {inst = inst})

	if inst.components.drivable.driver then

		local driver = inst.components.drivable.driver

		driver.components.driver:OnDismount(true)

		driver.components.health:Kill("drowning")

		inst.SoundEmitter:PlaySound(inst.sinksound)
		--driver:PushEvent("death", {cause="drowning"})
		--GetWorld():PushEvent("entity_death", {inst = driver, cause="drowning"})
		if inst.components.container then
			inst.components.container:DropEverything()
		end
		inst:Remove()
	end
end



local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("hit")
	inst.AnimState:PushAnimation("run_loop", true)
end

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
    if inst.components.container then
        inst.components.container:DropEverything()
    end	
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function onmounted(inst)
	--print("I'm getting mounted!")
	inst:RemoveComponent("workable")
end

local function ondismounted(inst)
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)
end

local function onopen(inst)
	if inst.components.drivable.driver == nil then
		inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/HUD_boat_inventory_open")
	end
end

local function onclose(inst)
	if inst.components.drivable.driver == nil then
		inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/HUD_boat_inventory_close")
	end
end

local function setupcontainer(inst, slots, bank, build, inspectslots, inspectbank, inspectbuild, inspectboatbadgepos, inspectboatequiproot)
	inst:AddComponent("container")
	inst.components.container:SetNumSlots(#slots)
	inst.components.container.type = "boat"
	inst.components.container.side_align_tip = -500
	inst.components.container.canbeopened = false
	inst.components.container.onopenfn = onopen
	inst.components.container.onclosefn = onclose

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




local function commonfn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	trans:SetFourFaced()
	inst.no_wet_prefix = true

	inst:AddTag("boat")

	local anim = inst.entity:AddAnimState()

	inst.entity:AddSoundEmitter()

	inst.entity:AddPhysics()
	inst.Physics:SetCylinder(0.25,2)

	inst:AddComponent("inspectable")
	inst:AddComponent("drivable")

	inst.waveboost = TUNING.WAVEBOOST

	inst.sailmusic = "sailing"

	inst:AddComponent("rowboatwakespawner")

	inst:AddComponent("boathealth")
	inst.components.boathealth:SetDepletedFn(boat_perish)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)

	inst:AddComponent("lootdropper")

    inst:AddComponent("repairable")
    inst.components.repairable.repairmaterial = "boat"

    inst.components.repairable.onrepaired = function(inst, doer, repair_item)
		if inst.SoundEmitter then
			inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/boatrepairkit")
		end
	end

    inst:ListenForEvent("mounted", onmounted)
    inst:ListenForEvent("dismounted", ondismounted)

    inst.onhammered = onhammered
 
 	inst:AddComponent("flotsamspawner")

	return inst
end


local function rowboatfn(sim)
	local inst = commonfn(sim)
	setupcontainer(inst, {}, "boat_hud_row", "boat_hud_row", {}, "boat_inspect_row", "boat_inspect_row", {x=0,y=40}, {x=40, y=-45})

	inst.AnimState:SetBuild("rowboat_build")
	inst.AnimState:SetBank("rowboat")
	inst.AnimState:PlayAnimation("run_loop", true)

	inst.components.container.hasboatequipslots = true

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetPriority( 5 )
	minimap:SetIcon("rowboat.png" )

	inst.perishtime = TUNING.ROWBOAT_PERISHTIME
	inst.components.boathealth.maxhealth = TUNING.ROWBOAT_HEALTH
	inst.components.boathealth:SetHealth(TUNING.ROWBOAT_HEALTH, inst.perishtime)
	inst.components.boathealth.leakinghealth = TUNING.ROWBOAT_LEAKING_HEALTH

	inst.landsound = "dontstarve_DLC002/common/boatjump_land_wood"
	inst.sinksound = "dontstarve_DLC002/common/boat_sinking_rowboat"

	inst.components.boathealth.damagesound = "dontstarve_DLC002/common/boat_damage_rowboat"

	inst.components.drivable.sanitydrain = TUNING.ROWBOAT_SANITY_DRAIN
	inst.components.drivable.runspeed = TUNING.ROWBOAT_SPEED
	inst.components.drivable.runanimation = "row_loop"
	inst.components.drivable.prerunanimation = "row_pre"
	inst.components.drivable.postrunanimation = "row_pst"
	inst.components.drivable.overridebuild = "rowboat_build"
	inst.components.drivable.flotsambuild = "flotsam_rowboat_build"
	inst.components.drivable.hitfx = "boat_hit_fx_rowboat"
	inst.components.drivable.maprevealbonus = TUNING.MAPREVEAL_ROWBOAT_BONUS
	inst.components.drivable.creaksound = "dontstarve_DLC002/common/boat_creaks"

	inst.components.flotsamspawner.flotsamprefab = "flotsam_rowboat"

	return inst
end


local function armouredboatfn(sim)
	local inst = commonfn(sim)

	setupcontainer(inst, {}, "boat_hud_row", "boat_hud_row", {}, "boat_inspect_row", "boat_inspect_row", {x=0,y=40}, {x=40, y=-45})

	inst.AnimState:SetBuild("rowboat_armored_build")
	inst.AnimState:SetBank("rowboat")
	inst.AnimState:PlayAnimation("run_loop", true)

	inst.components.container.hasboatequipslots = true

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetPriority( 5 )
	minimap:SetIcon("armouredboat.png")

	inst.perishtime = TUNING.ARMOUREDBOAT_PERISHTIME
	inst.components.boathealth.maxhealth = TUNING.ARMOUREDBOAT_HEALTH
	inst.components.boathealth:SetHealth(TUNING.ARMOUREDBOAT_HEALTH, inst.perishtime)
	inst.components.boathealth.leakinghealth = TUNING.ARMOUREDBOAT_LEAKING_HEALTH

	inst.landsound = "dontstarve_DLC002/common/boatjump_land_shell"
	inst.sinksound = "dontstarve_DLC002/common/boat_sinking_rowboat"

	inst.components.boathealth.damagesound = "dontstarve_DLC002/common/boat_damage_armoured"


	inst.components.drivable.sanitydrain = TUNING.ARMOUREDBOAT_SANITY_DRAIN
	inst.components.drivable.runspeed = TUNING.ARMOUREDBOAT_SPEED
	inst.components.drivable.runanimation = "row_loop"
	inst.components.drivable.prerunanimation = "row_pre"
	inst.components.drivable.postrunanimation = "row_pst"
	inst.components.drivable.overridebuild = "rowboat_armored_build"
	inst.components.drivable.flotsambuild = "flotsam_armoured_build"
	inst.components.drivable.hitfx = "boat_hit_fx_armoured"
	inst.components.drivable.maprevealbonus = TUNING.MAPREVEAL_ARMOUREDBOAT_BONUS
	inst.components.drivable.creaksound = "dontstarve_DLC002/common/boat_creaks_armoured"
	inst.components.drivable:SetHitImmunity(TUNING.ARMOUREDBOAT_HIT_IMMUNITY)

	inst.components.flotsamspawner.flotsamprefab = "flotsam_armoured"

	return inst
end

local function encrustedboatfn(sim)
	local inst = commonfn(sim)
	inst.waveboost = TUNING.ENCRUSTEDBOAT_WAVEBOOST

	local slotpos = {}
	for i = 2, 1,-1 do
		table.insert(slotpos, Vector3(-13-(80*(i+2)), 40 ,0))
	end

	local inspectslotpos = {}
	for x = 0, 1 do
		table.insert(inspectslotpos, Vector3(-40 + (x*80), 70 + (1*-75),0))
	end

	--setupcontainer(inst, slots, bank, build, inspectslots, inspectbank, inspectbuild, inspectboatbadgepos, inspectboatequiproot)
	setupcontainer(inst, slotpos, "boat_hud_encrusted", "boat_hud_encrusted", inspectslotpos, "boat_inspect_encrusted", "boat_inspect_encrusted", {x=0, y=155}, {x=40, y=70})

	inst.AnimState:SetBuild("rowboat_encrusted_build")
	inst.AnimState:SetBank("rowboat")
	inst.AnimState:PlayAnimation("run_loop", true)

	inst.components.container.hasboatequipslots = true

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetPriority( 5 )
	minimap:SetIcon("encrustedboat.png")

	inst.perishtime = TUNING.ENCRUSTEDBOAT_PERISHTIME
	inst.components.boathealth.maxhealth = TUNING.ENCRUSTEDBOAT_HEALTH
	inst.components.boathealth:SetHealth(TUNING.ENCRUSTEDBOAT_HEALTH, inst.perishtime)
	inst.components.boathealth.leakinghealth = TUNING.ENCRUSTEDBOAT_LEAKING_HEALTH

	inst.landsound = "dontstarve_DLC002/common/boatjump_land_shell"
	inst.sinksound = "dontstarve_DLC002/common/boat_sinking_rowboat"

	inst.components.boathealth.damagesound = "dontstarve_DLC002/common/encrusted_boat/damage"

	inst.components.drivable.sanitydrain = TUNING.ENCRUSTEDBOAT_SANITY_DRAIN
	inst.components.drivable.runspeed = TUNING.ENCRUSTEDBOAT_SPEED
	inst.components.drivable.runanimation = "row_loop"
	inst.components.drivable.prerunanimation = "row_pre"
	inst.components.drivable.postrunanimation = "row_pst"
	inst.components.drivable.overridebuild = "rowboat_encrusted_build"
	inst.components.drivable.flotsambuild = "flotsam_armoured_build"
	inst.components.drivable.hitfx = "boat_hit_fx_armoured"
	inst.components.drivable.maprevealbonus = TUNING.MAPREVEAL_ENCRUSTEDBOAT_BONUS
	inst.components.drivable.creaksound = "dontstarve_DLC002/common/encrusted_boat/boat_creaks"
	inst.components.drivable:SetHitImmunity(TUNING.ENCRUSTEDBOAT_HIT_IMMUNITY)

	inst.components.flotsamspawner.flotsamprefab = "flotsam_armoured"

	return inst
end

local function raftfn(sim)
	local inst = commonfn(sim)

	setupcontainer(inst, {}, "boat_hud_raft", "boat_hud_raft", {}, "boat_inspect_raft", "boat_inspect_raft", {x=0,y=5}, {})

	inst.AnimState:SetBuild("raft_build")
	inst.AnimState:SetBank("raft")
	inst.AnimState:PlayAnimation("run_loop", true)

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetPriority( 5 )
	minimap:SetIcon("raft.png" )
	inst.perishtime = TUNING.RAFT_PERISHTIME
	inst.components.boathealth.maxhealth = TUNING.RAFT_HEALTH
	inst.components.boathealth:SetHealth(TUNING.RAFT_HEALTH, inst.perishtime)
	inst.components.boathealth.leakinghealth = TUNING.RAFT_LEAKING_HEALTH

	inst.landsound = "dontstarve_DLC002/common/boatjump_land_bamboo"
	inst.sinksound = "dontstarve_DLC002/common/boat_sinking_bamboo"

	inst.components.boathealth.damagesound = "dontstarve_DLC002/common/boat_damage_bamboo"

	inst.components.drivable.sanitydrain = TUNING.RAFT_SANITY_DRAIN
	inst.components.drivable.runspeed = TUNING.RAFT_SPEED
	inst.components.drivable.runanimation = "row_loop"
	inst.components.drivable.prerunanimation = "row_pre"
	inst.components.drivable.postrunanimation = "row_pst"
	inst.components.drivable.overridebuild = "raft_build"
	inst.components.drivable.flotsambuild = "flotsam_bamboo_build"
	inst.components.drivable.hitfx = "boat_hit_fx_raft_bamboo"
	inst.components.drivable.maprevealbonus = TUNING.MAPREVEAL_RAFT_BONUS
	inst.components.drivable.creaksound = "dontstarve_DLC002/common/boat_creaks_bamboo"
	inst.components.drivable.hitmoisturerate = TUNING.RAFT_HITMOISTURERATE

	inst.components.flotsamspawner.flotsamprefab = "flotsam_bamboo"

	return inst
end

local function lograftfn(sim)
	local inst = commonfn(sim)

	setupcontainer(inst, {}, "boat_hud_raft", "boat_hud_raft", {}, "boat_inspect_raft", "boat_inspect_raft", {x=0,y=5}, {})

	inst.AnimState:SetBuild("raft_log_build")
	inst.AnimState:SetBank("raft")
	inst.AnimState:PlayAnimation("run_loop", true)

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetPriority( 5 )
	minimap:SetIcon("lograft.png" )
	inst.perishtime = TUNING.LOGRAFT_PERISHTIME
	inst.components.boathealth.maxhealth = TUNING.LOGRAFT_HEALTH
	inst.components.boathealth:SetHealth(TUNING.LOGRAFT_HEALTH, inst.perishtime)
	inst.components.boathealth.leakinghealth = TUNING.LOGRAFT_LEAKING_HEALTH

	inst.landsound = "dontstarve_DLC002/common/boatjump_land_log"
	inst.sinksound = "dontstarve_DLC002/common/boat_sinking_log_cargo"

	inst.components.boathealth.damagesound = "dontstarve_DLC002/common/boat_damage_log"

	inst.components.drivable.sanitydrain = TUNING.LOGRAFT_SANITY_DRAIN
	inst.components.drivable.runspeed = TUNING.LOGRAFT_SPEED
	inst.components.drivable.runanimation = "row_loop"
	inst.components.drivable.prerunanimation = "row_pre"
	inst.components.drivable.postrunanimation = "row_pst"
	inst.components.drivable.overridebuild = "raft_log_build"
	inst.components.drivable.flotsambuild = "flotsam_lograft_build"
	inst.components.drivable.hitfx = "boat_hit_fx_raft_log"
	inst.components.drivable.maprevealbonus = TUNING.MAPREVEAL_LOGRAFT_BONUS
	inst.components.drivable.creaksound = "dontstarve_DLC002/common/boat_creaks_log"
	inst.components.drivable.hitmoisturerate = TUNING.RAFT_HITMOISTURERATE

	inst.components.flotsamspawner.flotsamprefab = "flotsam_lograft"

	return inst
end

local function pickupfn(inst, guy)
	local board = SpawnPrefab("surfboard_item")
	guy.components.inventory:GiveItem(board)
	board.components.pocket:GiveItem("surfboard", inst)

	inst.components.flotsamspawner.inpocket = true	
	return true
end

local function pickupcorkboatfn(inst, guy)
	local boat = SpawnPrefab("corkboat_item")
	guy.components.inventory:GiveItem(boat)
	boat.components.pocket:GiveItem("corkboat", inst)
	inst.components.flotsamspawner.inpocket = true	
	return true
end


local function surfboardfn(sim)
	local inst = commonfn(sim)

	setupcontainer(inst, {}, "boat_hud_raft", "boat_hud_raft", {}, "boat_inspect_raft", "boat_inspect_raft", {x=0,y=5}, {})

	inst.AnimState:SetBank("raft")
	inst.AnimState:SetBuild("raft_surfboard_build")
	inst.AnimState:PlayAnimation("run_loop", true)

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetPriority( 5 )
	minimap:SetIcon("surfboard.png")
	inst.perishtime = TUNING.SURFBOARD_PERISHTIME
	inst.components.boathealth.maxhealth = TUNING.SURFBOARD_HEALTH
	inst.components.boathealth:SetHealth(TUNING.SURFBOARD_HEALTH, inst.perishtime)

	inst.landsound = "dontstarve_DLC002/common/boatjump_land_wood"
	inst.sinksound = "dontstarve_DLC002/common/boat_sinking_log_cargo"
	inst.sailsound = "common/surfboard_sail_LP"
	inst.sailmusic = "surfing"

	inst.components.boathealth.damagesound = "dontstarve_DLC002/common/surfboard_damage"

	inst.components.drivable.sanitydrain = TUNING.SURFBOARD_SANITY_DRAIN
	inst.components.drivable.runspeed = TUNING.SURFBOARD_SPEED
	inst.components.drivable.hitmoisturerate = TUNING.SURFBOARD_HITMOISTURERATE
	inst.components.drivable.maprevealbonus = TUNING.MAPREVEAL_RAFT_BONUS
	inst.components.drivable.sailloopanim = "surf_loop"
	inst.components.drivable.sailstartanim = "surf_pre"
	inst.components.drivable.sailstopanim = "surf_pst"
	inst.components.drivable.overridebuild = "raft_surfboard_build"
	inst.components.drivable.flotsambuild = "flotsam_surfboard_build"
	inst.components.drivable.creaksound = "dontstarve_DLC002/common/boat_creaks"
	inst.components.drivable.alwayssail = true

	inst.components.flotsamspawner.flotsamprefab = "flotsam_surfboard"

	inst.waveboost = TUNING.SURFBOARD_WAVEBOOST
	inst.wavesanityboost = TUNING.SURFBOARD_WAVESANITYBOOST

	inst:AddComponent("characterspecific")
    inst.components.characterspecific:SetOwner("walani")

	inst:AddComponent("pickupable")
	inst.components.pickupable:SetOnPickupFn(pickupfn)
	inst:SetInherentSceneAltAction(ACTIONS.RETRIEVE)

	return inst
end

local function ondeploy(inst, pt, deployer)
	print("ondeploy")	
	local board = inst.components.pocket:RemoveItem("surfboard") or SpawnPrefab("surfboard")

	if board then
		board.components.flotsamspawner.inpocket = false
		pt = Vector3(pt.x, 0, pt.z)
		board.Physics:SetCollides(false)
		board.Physics:Teleport(pt.x, pt.y, pt.z)
		board.Physics:SetCollides(true)
		inst:Remove()
	end
end

local function ondeploycorkboat(inst, pt, deployer)
	print("ondeploy corkboat")	
	local boat = inst.components.pocket:RemoveItem("corkboat") or SpawnPrefab("corkboat")

	if boat then
		boat.components.flotsamspawner.inpocket = false
		pt = Vector3(pt.x, 0, pt.z)
		boat.Physics:SetCollides(false)
		boat.Physics:Teleport(pt.x, pt.y, pt.z)
		boat.Physics:SetCollides(true)
		inst:Remove()
	end
end

local function deploytest(inst, pt)

	------------------------------------------------------
	-- MAKE SURE THIS TEST MATCHES THE BUILDER.LUA TEST --
	------------------------------------------------------
	local ground = GetWorld()
    local tile = GROUND.GRASS
    if ground and ground.Map then
        tile = ground.Map:GetTileAtPoint(pt:Get())
    end

    local onWater = ground.Map:IsWater(tile)

    -- ugly hack for deloying walani's surfboard from a boat
    local boating = GetPlayer().components.driver.driving
    -- local boating = inst.components.inventoryitem and inst.components.inventoryitem.owner
    -- 				and inst.components.inventoryitem.owner.components.driver and inst.components.inventoryitem.owner.components.driver.driving


    if boating then
    	return onWater
	else
    	local x, y, z = pt:Get()
		local testTile = inst:GetCurrentTileType(x, y, z)--ground.Map:GetTileAtPoint(x , y, z)
		local isShore = ground.Map:IsShore(testTile) --testTile == GROUND.OCEAN_SHORE --ground.Map:IsWater(testTile)

		local maxBuffer = 2
		local nearShore = false
		testTile = inst:GetCurrentTileType(x + maxBuffer, y, z)
		nearShore = (not ground.Map:IsWater(testTile)) or nearShore
		testTile = inst:GetCurrentTileType(x - maxBuffer, y, z)
		nearShore = (not ground.Map:IsWater(testTile)) or nearShore
		testTile = inst:GetCurrentTileType(x , y, z + maxBuffer)
		nearShore = (not ground.Map:IsWater(testTile)) or nearShore
		testTile = inst:GetCurrentTileType(x , y, z - maxBuffer)
		nearShore = (not ground.Map:IsWater(testTile)) or nearShore

		testTile = inst:GetCurrentTileType(x + maxBuffer, y, z + maxBuffer)
		nearShore = (not ground.Map:IsWater(testTile)) or nearShore
		testTile = inst:GetCurrentTileType(x - maxBuffer, y, z + maxBuffer)
		nearShore = (not ground.Map:IsWater(testTile)) or nearShore
		testTile = inst:GetCurrentTileType(x + maxBuffer , y, z - maxBuffer)
		nearShore = (not ground.Map:IsWater(testTile)) or nearShore
		testTile = inst:GetCurrentTileType(x - maxBuffer , y, z - maxBuffer)
		nearShore = (not ground.Map:IsWater(testTile)) or nearShore

		local minBuffer = 0.5
		local tooClose = false
		testTile = inst:GetCurrentTileType(x + minBuffer, y, z)
		tooClose = (not ground.Map:IsWater(testTile)) or tooClose
		testTile = inst:GetCurrentTileType(x - minBuffer, y, z)
		tooClose = (not ground.Map:IsWater(testTile)) or tooClose
		testTile = inst:GetCurrentTileType(x , y, z + minBuffer)
		tooClose = (not ground.Map:IsWater(testTile)) or tooClose
		testTile = inst:GetCurrentTileType(x , y, z - minBuffer)
		tooClose = (not ground.Map:IsWater(testTile)) or tooClose

		testTile = inst:GetCurrentTileType(x + minBuffer, y, z + minBuffer)
		tooClose = (not ground.Map:IsWater(testTile)) or tooClose
		testTile = inst:GetCurrentTileType(x - minBuffer, y, z + minBuffer)
		tooClose = (not ground.Map:IsWater(testTile)) or tooClose
		testTile = inst:GetCurrentTileType(x + minBuffer , y, z - minBuffer)
		tooClose = (not ground.Map:IsWater(testTile)) or tooClose
		testTile = inst:GetCurrentTileType(x - minBuffer, y, z - minBuffer)
		tooClose = (not ground.Map:IsWater(testTile)) or tooClose

		return isShore and nearShore and not tooClose
	end
end

local function surfboard_ondropped(inst)
	--If this is a valid place to be deployed, auto deploy yourself.
	if inst.components.deployable and inst.components.deployable:CanDeploy(inst:GetPosition()) then
		inst.components.deployable:Deploy(inst:GetPosition(), inst)
	end
end

local function surfboarditemfn(Sim)
	local inst = CreateEntity()

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetPriority( 5 )
	minimap:SetIcon("surfboard.png")

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	MakeInventoryPhysics(inst)

	inst:AddTag("boat")

	inst.AnimState:SetBank("surfboard")
	inst.AnimState:SetBuild("surfboard")
	inst.AnimState:PlayAnimation("idle")

	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem:SetOnDroppedFn(surfboard_ondropped)

	inst:AddComponent("pocket")

	inst:AddComponent("deployable")
	inst.components.deployable.ondeploy = ondeploy
	inst.components.deployable.placer = "surfboard_placer"
	inst.components.deployable.test = deploytest
	inst.components.deployable.deploydistance = 3


	inst:AddComponent("characterspecific")
    inst.components.characterspecific:SetOwner("walani")

	return inst
end





local function cargofn(sim)
	local inst = commonfn(sim)

	local slotpos = {}
	for i = 6, 1,-1 do
		table.insert(slotpos, Vector3(-13-(80*(i+2)), 40 ,0))
	end

	local inspectslotpos = {}
	for y = 1, 3 do
		for x = 0, 1 do
			table.insert(inspectslotpos, Vector3(-40 + (x*80), 70 + (y*-75),0))
		end
	end
	--inst, slots, bank, build, inspectslots, inspectbank, inspectbuild, inspectboatbadgepos, inspectboatequiproot

	setupcontainer(inst, slotpos, "boat_hud_cargo", "boat_hud_cargo", inspectslotpos, "boat_inspect_cargo", "boat_inspect_cargo", {x=0, y=155}, {x=40, y=70})
	inst.components.container.hasboatequipslots = true

	inst.AnimState:SetBuild("rowboat_cargo_build")
	inst.AnimState:SetBank("rowboat")
	inst.AnimState:PlayAnimation("run_loop", true)


	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetPriority( 5 )
	minimap:SetIcon("cargo.png" )
	inst.perishtime = TUNING.CARGOBOAT_PERISHTIME
	inst.components.boathealth.maxhealth = TUNING.CARGOBOAT_HEALTH
	inst.components.boathealth:SetHealth(TUNING.CARGOBOAT_HEALTH, inst.perishtime)

	inst.landsound = "dontstarve_DLC002/common/boatjump_land_wood"
	inst.sinksound = "dontstarve_DLC002/common/boat_sinking_log_cargo"

	inst.components.boathealth.damagesound = "dontstarve_DLC002/common/boat_damage_cargo"

	inst.components.drivable.sanitydrain = TUNING.CARGOBOAT_SANITY_DRAIN
	inst.components.drivable.runspeed = TUNING.CARGOBOAT_SPEED
	inst.components.drivable.runanimation = "row_loop"
	inst.components.drivable.prerunanimation = "row_pre"
	inst.components.drivable.postrunanimation = "row_pst"
	inst.components.drivable.overridebuild = "rowboat_cargo_build"
	inst.components.drivable.flotsambuild = "flotsam_cargo_build"
	inst.components.drivable.hitfx = "boat_hit_fx_cargoboat"
	inst.components.drivable.maprevealbonus = TUNING.MAPREVEAL_CARGOBOAT_BONUS
	inst.components.drivable.creaksound = "dontstarve_DLC002/common/boat_creaks_cargo"

	inst.components.flotsamspawner.flotsamprefab = "flotsam_cargo"
	return inst
end

local function woodlegsboatfn(sim)
	local inst = commonfn(sim)

	setupcontainer(inst, {}, "boat_hud_raft", "boat_hud_raft", {}, "boat_inspect_raft", "boat_inspect_raft", {x=0,y=5}, {x=40, y=-45})

	inst.AnimState:SetBuild("pirate_boat_build")
	inst.AnimState:SetBank("rowboat")
	inst.AnimState:PlayAnimation("run_loop", true)

	inst.components.container.hasboatequipslots = true
	inst.components.container.enableboatequipslots = false

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetPriority( 5 )
	minimap:SetIcon("woodlegsboat.png")

	inst.perishtime = TUNING.ARMOUREDBOAT_PERISHTIME
	inst.components.boathealth.maxhealth = TUNING.WOODLEGSBOAT_HEALTH
	inst.components.boathealth:SetHealth(TUNING.WOODLEGSBOAT_HEALTH, inst.perishtime)
	inst.components.boathealth.leakinghealth = TUNING.WOODLEGSBOAT_LEAKING_HEALTH

	inst.landsound = "dontstarve_DLC002/common/boatjump_land_shell"
	inst.sinksound = "dontstarve_DLC002/common/boat_sinking_rowboat"

	inst.components.boathealth.damagesound = "dontstarve_DLC002/common/boat_damage_armoured"

	inst.components.drivable.sanitydrain = 0
	inst.components.drivable.runspeed = TUNING.WOODLEGSBOAT_SPEED
	inst.components.drivable.runanimation = "row_loop"
	inst.components.drivable.prerunanimation = "row_pre"
	inst.components.drivable.postrunanimation = "row_pst"
	inst.components.drivable.overridebuild = "pirate_boat_build"
	inst.components.drivable.flotsambuild = "flotsam_armoured_build"
	inst.components.drivable.hitfx = "boat_hit_fx_armoured"
	inst.components.drivable.maprevealbonus = TUNING.MAPREVEAL_WOODLEGSBOAT_BONUS
	inst.components.drivable.creaksound = "dontstarve_DLC002/common/boat_creaks_armoured"
	inst.components.drivable:SetHitImmunity(TUNING.WOODLEGSBOAT_HIT_IMMUNITY)

	inst.components.flotsamspawner.flotsamprefab = "flotsam_rowboat"

	inst:ListenForEvent( "onbuilt", function()
		local sail = SpawnPrefab("woodlegssail")
		local cannon = SpawnPrefab("woodlegs_boatcannon")
		inst.components.container:Equip(sail)
		inst.components.container:Equip(cannon)
	end)

	return inst
end

local function corkboatitemfn(Sim)
	local inst = CreateEntity()

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetPriority( 5 )
	minimap:SetIcon("coracle_boat.png")

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "idle_water", "idle")

	inst:AddTag("boat")

	inst.AnimState:SetBank("corkboat")
	inst.AnimState:SetBuild("corkboat")
	inst.AnimState:PlayAnimation("idle")

	inst:AddComponent("inspectable")
	inst.components.inspectable.nameoverride = "corkboat" 
	inst.name = STRINGS.NAMES.CORKBOAT 

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem:SetOnDroppedFn(surfboard_ondropped)
	inst.components.inventoryitem:ChangeImageName("corkboat")

	inst:AddComponent("pocket")

	inst:AddComponent("deployable")
	inst.components.deployable.ondeploy = ondeploycorkboat
	inst.components.deployable.placer = "corkboat_placer"
	inst.components.deployable.test = deploytest
	inst.components.deployable.deploydistance = 3

	return inst
end

local function corkboatfn(sim)
	local inst = commonfn(sim)
	setupcontainer(inst, {}, "boat_hud_row", "boat_hud_row", {}, "boat_inspect_row", "boat_inspect_row", {x=0,y=40}, {x=40, y=-45})

	inst.AnimState:SetBuild("coracle_boat_build")
	inst.AnimState:SetBank("rowboat")
	inst.AnimState:PlayAnimation("run_loop", true)

	inst.components.container.hasboatequipslots = true

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetPriority( 5 )
	minimap:SetIcon("coracle_boat.png" )

	inst.perishtime = TUNING.CORKBOAT_PERISHTIME
	inst.components.boathealth.maxhealth = TUNING.CORKBOAT_HEALTH
	inst.components.boathealth:SetHealth(TUNING.CORKBOAT_HEALTH, inst.perishtime)
	inst.components.boathealth.leakinghealth = TUNING.CORKBOAT_LEAKING_HEALTH

	inst.landsound = "dontstarve_DLC002/common/boatjump_land_wood"
	inst.sinksound = "dontstarve_DLC002/common/boat_sinking_rowboat"

	inst.components.boathealth.damagesound = "dontstarve_DLC003/common/objects/corkboat/damage"

	inst.components.drivable.sanitydrain = TUNING.CORKBOAT_SANITY_DRAIN
	inst.components.drivable.runspeed = TUNING.CORKBOAT_SPEED
	inst.components.drivable.runanimation = "row_loop"
	inst.components.drivable.prerunanimation = "row_pre"
	inst.components.drivable.postrunanimation = "row_pst"
	inst.components.drivable.overridebuild = "coracle_boat_build"
	inst.components.drivable.flotsambuild = "flotsam_corkboat_build"
	inst.components.drivable.hitfx = "boat_hit_fx_corkboat"
	inst.components.drivable.maprevealbonus = TUNING.MAPREVEAL_NO_BONUS
	inst.components.drivable.creaksound = "dontstarve_DLC003/common/objects/corkboat/creaks"

	inst.components.flotsamspawner.flotsamprefab = "flotsam_corkboat"

	inst:AddComponent("pickupable")
	inst.components.pickupable:SetOnPickupFn(pickupcorkboatfn)
	inst:SetInherentSceneAltAction(ACTIONS.RETRIEVE)

	return inst
end

return Prefab( "common/objects/rowboat", rowboatfn, rowboatassets, prefabs),
	MakePlacer( "common/rowboat_placer", "rowboat", "rowboat_build", "run_loop", false, false, false),
	Prefab( "common/objects/raft", raftfn, raftassets, prefabs),
	MakePlacer( "common/raft_placer", "raft", "raft_build", "run_loop", false, false, false),
	Prefab( "common/objects/lograft", lograftfn, lograftassets, prefabs),
	MakePlacer( "common/lograft_placer", "raft", "raft_log_build", "run_loop", false, false, false),

	Prefab( "common/objects/corkboat", corkboatfn, corkboatassets, prefabs),
	Prefab("common/corkboat_item", corkboatitemfn, corkboatassets, prefabs),
	MakePlacer( "common/corkboat_placer", "rowboat", "coracle_boat_build", "run_loop", false, false, false),

	Prefab( "common/objects/surfboard", surfboardfn, surfboardassets, prefabs),
	Prefab("common/surfboard_item", surfboarditemfn, surfboardassets, prefabs),
	MakePlacer( "common/surfboard_placer", "raft", "raft_surfboard_build", "run_loop", false, false, false, nil, nil, nil, nil, false, true),
	Prefab( "common/objects/cargoboat", cargofn, cargoassets, prefabs),
	MakePlacer( "common/cargoboat_placer", "rowboat", "rowboat_cargo_build", "run_loop", false, false, false),
	Prefab( "common/objects/armouredboat", armouredboatfn, armouredboatassets, prefabs),
	MakePlacer( "common/armouredboat_placer", "rowboat", "rowboat_armored_build", "run_loop", false, false, false),
	Prefab( "common/objects/encrustedboat", encrustedboatfn, encrustedboatassets, prefabs),
	MakePlacer( "common/encrustedboat_placer", "rowboat", "rowboat_encrusted_build", "run_loop", false, false, false),
	Prefab( "common/objects/woodlegsboat", woodlegsboatfn, woodlegsboatassets, prefabs),
	MakePlacer( "common/woodlegsboat_placer", "pirate_boat_placer", "pirate_boat_placer", "idle", false, false, false)