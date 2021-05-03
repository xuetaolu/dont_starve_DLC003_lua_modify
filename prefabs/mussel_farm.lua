require "prefabutil"
require "tuning"

local assets =
{
	Asset("ANIM", "anim/musselfarm.zip"),
	Asset("MINIMAP_IMAGE", "musselFarm"),
}

local prefabs = 
{
	"mussel",
	"collapse_small",
}

local function getnewpoint(pt)

	local theta = math.random() * 2 * PI
	local radius = 6+math.random()*6
	
	local result_offset = FindValidPositionByFan(theta, radius, 12, function(offset)
		local ground = GetWorld()
		local spawn_point = pt + offset
		if GetGroundTypeAtPosition(spawn_point) == GROUND.OCEAN_SHALLOW then
			return true
		end
		return false
	end)

	if result_offset then
		return pt+result_offset
	end
end

local function movetonewhome(inst, child)
	local pos = Vector3(inst.Transform:GetWorldPosition())
	local spawn_point = getnewpoint(pos)

	if spawn_point then
		child.Transform:SetPosition(spawn_point:Get())
	end
end

local function onpickedfn(inst, picker)

	inst.AnimState:PlayAnimation("picked")


	inst.pickedanimdone = function(inst)
		inst.components.growable:SetStage(1)
		inst:RemoveEventCallback("animover", inst.pickedanimdone)
	end

	inst:ListenForEvent("animover", inst.pickedanimdone)
end

-- for inspect string
local function getstatus(inst)
    if inst.growthstage > 0 then 
        return "STICKPLANTED"
    end
end

local function makeemptyfn(inst)
	-- never called?
end

local function makefullfn(inst)
	inst.AnimState:PlayAnimation("idle_full")
end

-- stage 1
local function SetHidden(inst)
	inst.components.pickable.numtoharvest = 0
	inst.components.pickable.canbepicked = false
	inst.components.blowinwindgust:Stop()
	inst.MiniMapEntity:SetEnabled(false)
	inst.Physics:SetCollides(false)
	inst:Hide()
	inst.components.stickable:UnStuck()
end

-- stage 2
local function SetUnderwater(inst)
	inst.AnimState:PlayAnimation("idle_underwater", true)
	inst.components.pickable.numtoharvest = 0
	inst.components.pickable.canbepicked = false
	inst.components.blowinwindgust:Stop()
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(2)
	inst.MiniMapEntity:SetEnabled(false)
 	inst.Physics:SetCollides(false)
	inst:Show()
	inst.components.stickable:UnStuck()
end

local function SetAboveWater(inst)
	-- common
	inst.AnimState:SetLayer(LAYER_WORLD)
	inst.AnimState:SetSortOrder(0)
	inst.components.blowinwindgust:Start()
	inst.MiniMapEntity:SetEnabled(true)
	inst.Physics:SetCollides(true)
	inst.components.growable:StartGrowing()
	inst:Show()
	inst.components.stickable:Stuck()
end

-- stage 3
local function SetEmpty(inst)
	inst.AnimState:PlayAnimation("idle_empty", true)
	inst.components.pickable.numtoharvest = 0
	inst.components.pickable.canbepicked = false
	inst.components.pickable.hasbeenpicked = false

	SetAboveWater(inst)
end

-- stage 4
local function SetSmall(inst)
	inst.AnimState:PlayAnimation("idle_small", true)
	inst.components.pickable.numtoharvest = TUNING.MUSSEL_CATCH_SMALL
	inst.components.pickable.canbepicked = true
	inst.components.pickable.hasbeenpicked = false

	SetAboveWater(inst)
end

-- stage 5
local function SetMedium(inst)
	-- there's no real animation for this stage
	inst.AnimState:PlayAnimation("idle_small", true)
	inst.components.pickable.numtoharvest = TUNING.MUSSEL_CATCH_MED
	inst.components.pickable.canbepicked = true
	inst.components.pickable.hasbeenpicked = false

	SetAboveWater(inst)
end

-- stage 6
local function SetLarge(inst)
	inst.AnimState:PlayAnimation("idle_full", true)
	inst.components.pickable.numtoharvest = TUNING.MUSSEL_CATCH_LARGE
	inst.components.pickable.canbepicked = true
	inst.components.pickable.hasbeenpicked = false

	SetAboveWater(inst)
end

local function GrowHidden(inst)

end

local function GrowUnderwater(inst)

end

local function GrowEmpty(inst)
	inst.growthstage = 2
	inst.AnimState:PlayAnimation("empty_to_small")
	inst.AnimState:PushAnimation("idle_small", true)
end

local function GrowSmall(inst)
	--inst.AnimState:PlayAnimation("empty_to_small")
	--inst.AnimState:PushAnimation("idle_small", true)
end

local function GrowMedium(inst)
	inst.AnimState:PlayAnimation("small_to_full")
	inst.AnimState:PushAnimation("idle_full", true)
end

local function GrowLarge(inst)

end

local growth_stages =
{
	{
		name = "hidden",
		time = function(inst) 
			return GetRandomWithVariance(TUNING.MUSSEL_CATCH_TIME[1].base, TUNING.MUSSEL_CATCH_TIME[1].random)
		end,
		fn = SetHidden,
		growfn = GrowHidden,
	},
	{
		name = "underwater", -- waiting to be stuck
		time = function(inst) 
			return nil -- this stage doesn't grow automatically
		end,
		fn = SetUnderwater,
		growfn = GrowUnderwater,
	},
	{
		name = "empty", -- the stick is in now
		time = function(inst) 
			return GetRandomWithVariance(TUNING.MUSSEL_CATCH_TIME[2].base, TUNING.MUSSEL_CATCH_TIME[2].random)
		end,
		fn = SetEmpty,
		growfn = GrowEmpty,
	},
	{
		name = "small",
		time = function(inst) 
			return GetRandomWithVariance(TUNING.MUSSEL_CATCH_TIME[3].base, TUNING.MUSSEL_CATCH_TIME[3].random)
		end,
		fn = SetSmall,
		growfn = GrowSmall,
	},
	{
		name = "medium",
		time = function(inst) 
			return GetRandomWithVariance(TUNING.MUSSEL_CATCH_TIME[4].base, TUNING.MUSSEL_CATCH_TIME[4].random)
		end,
		fn = SetMedium,
		growfn = GrowMedium,
	},
	{
		name = "large",
		time = function(inst) 
			return GetRandomWithVariance(TUNING.MUSSEL_CATCH_TIME[5].base, TUNING.MUSSEL_CATCH_TIME[5].random)
		end,
		fn = SetLarge,
		growfn = GrowLarge,
	},
}

local function onpoked(inst, worker, stick)
	inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/plant_mussel")
	inst.components.growable:SetStage(3)
	
	if stick.components.stackable and stick.components.stackable.stacksize > 1 then
		stick = stick.components.stackable:Get()
 	end

	stick:Remove()
end

local function ongustharvest(inst)
	if inst.components.pickable and inst.components.pickable.numtoharvest > 0 then
		for i = 1, inst.components.pickable.numtoharvest, 1 do
			inst.components.lootdropper:SpawnLootPrefab(inst.components.pickable.product)
		end
		onpickedfn(inst, nil)
	end
end

local function fn()
	
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	
	inst.entity:AddSoundEmitter()
	MakeObstaclePhysics(inst, 0.8, 1.2)
 	inst.Physics:SetCollides(false)

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("musselFarm.png")
	minimap:SetEnabled(false) --Not enabled until poked 

	inst.no_wet_prefix = true
	inst.growthstage = 0
	inst.targettime = nil

	inst:AddTag("structure")
	inst:AddTag("mussel_farm")
	inst:AddTag("aquatic")
	
	inst.AnimState:SetBank("musselFarm")
	inst.AnimState:SetBuild("musselFarm")
	inst.AnimState:PlayAnimation("idle_underwater", true)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
    inst.AnimState:SetSortOrder(2)
 	inst.AnimState:SetRayTestOnBB(true)
	

	inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = getstatus

	inst:AddComponent("stickable")
	inst.components.stickable:SetOnPokeCallback(onpoked)

	inst:AddComponent("blowinwindgust")
	inst.components.blowinwindgust:SetWindSpeedThreshold(TUNING.MUSSELFARM_WINDBLOWN_SPEED)
	inst.components.blowinwindgust:SetDestroyChance(TUNING.MUSSELFARM_WINDBLOWN_FALL_CHANCE)
	inst.components.blowinwindgust:SetDestroyFn(ongustharvest)

	inst:AddComponent("pickable")
	inst.components.pickable.picksound = "dontstarve/wilson/harvest_berries"
	inst.components.pickable.canbepicked = false
	inst.components.pickable.hasbeenpicked = false
	inst.components.pickable.product = "mussel"
	inst.components.pickable.numtoharvest = 0
	inst.components.pickable.onpickedfn = onpickedfn
	inst.components.pickable.makeemptyfn = makeemptyfn
	inst.components.pickable.makebarrenfn = makeemptyfn
	inst.components.pickable.makefullfn = makefullfn

	inst:AddComponent("growable")
	inst.components.growable.stages = growth_stages
	inst.components.growable:SetStage(2)
	inst.components.growable.loopstages = false

	inst:AddComponent("lootdropper")

	return inst
end    

return Prefab( "common/objects/mussel_farm", fn, assets, prefabs )
