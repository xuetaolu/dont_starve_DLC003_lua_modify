local assets =
{
	Asset("ANIM", "anim/shipwreck.zip"),
	Asset("MINIMAP_IMAGE", "wreck"),
}

local prefabs =
{
	"limpets",
	"boards",
	"collapse_big",
	"pirateghost"
}

local MAST = 1
local BOW = 2
local MIDSHIP = 3
local STERN = 4

local anims =
{
	mast =
	{
		full = "idle_full1",
		empty = "idle_empty1",
		grow = "grow1",
		picked = "picked1",
		hitfull = "hit_full1",
		hitempty = "hit_empty1"
	},
	bow =
	{
		full = "idle_full2",
		empty = "idle_empty2",
		grow = "grow2",
		picked = "picked2",
		hitfull = "hit_full2",
		hitempty = "hit_empty2"
	},
	midship =
	{
		full = "idle_full3",
		empty = "idle_empty3",
		grow = "grow3",
		picked = "picked3",
		hitfull = "hit_full3",
		hitempty = "hit_empty3"
	},
	stern =
	{
		full = "idle_full4",
		empty = "idle_empty4",
		grow = "grow4",
		picked = "picked4",
		hitfull = "hit_full4",
		hitempty = "hit_empty4"
	},
}

local sizes =
{
	mast = 0.1,
	bow = 0.9, --1.6,
	midship = 0.9, --1.5,
	stern = 0.9 --1.5
}

local sounds =
{
	mast = "dontstarve_DLC002/common/graveyard_shipwreck/shipwreck_1",
	bow = "dontstarve_DLC002/common/graveyard_shipwreck/shipwreck_2",
	midship = "dontstarve_DLC002/common/graveyard_shipwreck/shipwreck_3",
	stern = "dontstarve_DLC002/common/graveyard_shipwreck/shipwreck_4"
}

local function makeemptyfn(inst)
	inst.AnimState:PlayAnimation(anims[inst.wrecktype].empty, true)
end

local function makebarrenfn(inst)
end

local function onpickedfn(inst, picker)
	if inst.components.pickable then
		inst.AnimState:PlayAnimation(anims[inst.wrecktype].picked)
		inst.AnimState:PushAnimation(anims[inst.wrecktype].empty, true)
	end
end

local function getregentimefn(inst)
	return TUNING.LIMPET_REGROW_TIME
end

local function makefullfn(inst)
	inst.AnimState:PlayAnimation(anims[inst.wrecktype].grow)
	inst.AnimState:PushAnimation(anims[inst.wrecktype].full, true)
end

local function onworked(inst, worker, workleft)
	if inst.components.pickable:CanBePicked() then
		inst.AnimState:PlayAnimation(anims[inst.wrecktype].hitfull)
		inst.AnimState:PushAnimation(anims[inst.wrecktype].full)
	else
		inst.AnimState:PlayAnimation(anims[inst.wrecktype].hitempty)
		inst.AnimState:PushAnimation(anims[inst.wrecktype].empty)
	end
end

local function onhammered(inst, worker)
	if inst:HasTag("fire") and inst.components.burnable then
		inst.components.burnable:Extinguish()
	end
	if inst.haunted and inst.haunted == true and math.random() < 0.5 then
		local ghost = SpawnPrefab("pirateghost")
		if ghost then
			local pos = Point(inst.Transform:GetWorldPosition())
			ghost.Transform:SetPosition(pos.x - .3, pos.y, pos.z - .3)
		end
	end
	if inst.components.pickable and inst.components.pickable:CanBePicked() then
		for i = 1, inst.components.pickable.numtoharvest do
			inst.components.lootdropper:AddLoot(inst.components.pickable.product)
		end
	end
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_big").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function settype(inst, wrecktype)
	if type(wrecktype) == "number" or wrecktype == "random" then
		local types = {"mast", "bow", "midship", "stern"}
		inst.wrecktype = types[math.random(1, #types)]
	elseif wrecktype == "hull" then
		local hulls = {"bow", "midship", "stern"}
		inst.wrecktype = hulls[math.random(1, #hulls)]
	else
		inst.wrecktype = wrecktype
	end
	inst.AnimState:PlayAnimation(anims[inst.wrecktype].full, true)
	inst.Physics:SetCapsule(sizes[inst.wrecktype], 2.0)
end

local function makenamed(inst)
	if inst.components.named == nil then
		inst:AddComponent("named")
		inst.components.named.nameformat = STRINGS.NAMES.WRECKOF
		inst.components.named.possiblenames = STRINGS.SHIPNAMES
		inst.components.named:PickNewName()
	end
end

local function makehaunted(inst)
	inst.haunted = true
end

local function onpreload(inst, data)
	if data and data.named and inst.components.named == nil then
		inst:AddComponent("named") --doing this so named gets loaded
	end
end

local function onsave(inst, data)
	data.wrecktype = inst.wrecktype
	data.haunted = inst.haunted
end

local function onload(inst, data)
	if data then
		if data.wrecktype then
			settype(inst, data.wrecktype)
		end
		if data.isnamed and data.isnamed == true then
			makenamed(inst)
		end
		if data.haunted and data.haunted == true then
			makehaunted(inst)
		end
	end
end

local function onwake(inst)
	inst.SoundEmitter:PlaySound(sounds[inst.wrecktype], "amb")
end

local function onsleep(inst)
	inst.SoundEmitter:KillSound("amb")
end

local function wreckfn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local minimap  =inst.entity:AddMiniMapEntity()

	anim:SetBank("shipwreck")
	anim:SetBuild("shipwreck")
	--anim:PlayAnimation(anims[inst.wrecktype].full, true)

	minimap:SetIcon("wreck.png")

	inst:AddComponent("pickable")
	inst.components.pickable.picksound = "dontstarve_DLC002/common/limpet_harvest"
	inst.components.pickable:SetUp("limpets", TUNING.LIMPET_REGROW_TIME)
	inst.components.pickable.getregentimefn = getregentimefn
	inst.components.pickable.onpickedfn = onpickedfn
	inst.components.pickable.makeemptyfn = makeemptyfn
	inst.components.pickable.makebarrenfn = makebarrenfn
	inst.components.pickable.makefullfn = makefullfn
	inst.components.pickable.numtoharvest = math.random(2, 3)
	inst.components.pickable.witherable = false

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(3)
	inst.components.workable:SetOnWorkCallback(onworked)
	inst.components.workable:SetOnFinishCallback(onhammered)

	inst:AddComponent("inspectable")
	inst:AddComponent("waveobstacle")

	inst:AddComponent("lootdropper")
	inst.components.lootdropper:AddLoot("boards")

	MakeObstaclePhysics(inst, 0.1)

	settype(inst, "random")

	inst.OnPreLoad = onpreload
	inst.OnSave = onsave
	inst.OnLoad = onload
	inst.OnEntityWake = onwake
	inst.OnEntitySleep = onsleep

	return inst
end

return Prefab( "shipwrecked/obstacle/wreck", wreckfn, assets, prefabs)