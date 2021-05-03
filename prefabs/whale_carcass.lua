local assets =
{
	Asset("ANIM", "anim/whale_carcass.zip"),
	Asset("ANIM", "anim/whale_carcass_build.zip"),
	Asset("ANIM", "anim/whale_moby_carcass_build.zip"),
	Asset("MINIMAP_IMAGE", "whale_carcass"),
}

local prefabs =
{
	"fish_raw",
	"boneshard",
	"coconade",
	"tophat",
	"sail",
	"gashat",
	"blowdart_sleep",
	"blowdart_poison",
	"blowdart_fire",
	"cutlass",
	"clothsail",
	"lobster_dead",
	"spear_launcher",
	"coconut",
	"boat_lantern",
	"bottlelantern",
	"telescope",
	"captainhat",
	"piratehat",
	"spear",
	"seatrap",
	"machete",
	"messagebottleempty",
	"fish_raw",
	"boneshard",
	"seaweed",
	"seashell",
	"jellyfish",
	"coral",
	"harpoon",
	"blubber",
	"bamboo",
	"vine",
}

local alwaysloot_blue = {"blubber","blubber","blubber","blubber","fish_raw","fish_raw","fish_raw","fish_raw"}
local alwaysloot_white = {"blubber","blubber","blubber","blubber","fish_raw","fish_raw","fish_raw","fish_raw","harpoon","boneshard"}


local loots = {
	{
		-- low % items, 2 of these are picked
		"coconade",
		--"raft", -- flies away
		"tophat",
		"sail",
		"gashat",
		--"boatcannon",
		"blowdart_sleep",
		"blowdart_poison",
		"blowdart_fire",
		"cutlass",
	},
	{
		--MEDIUM % ITEMS, 3 of these
		"clothsail",
		"lobster_dead",
		"spear_launcher",
		"coconut",
		"boat_lantern",
		"bottlelantern",
		"telescope",
		"captainhat",
		"piratehat",
		"spear",
		"seatrap",
		"machete",
		"messagebottleempty",
	},
	{
		--HIGH % ITEMS, 4 of these
		"blubber",
		"fish_raw",
		"boneshard",
		"seaweed",
		-- "seashell",
		"jellyfish",
		"coral",
		"vine",
		"bamboo",
	},
}


local bluesounds = 
{
	stinks = "dontstarve_DLC002/creatures/blue_whale/bloated_stinks",
	bloated1 = "dontstarve_DLC002/creatures/blue_whale/bloated_plump_1",
	bloated2 = "dontstarve_DLC002/creatures/blue_whale/bloated_plump_2",
	explosion = "dontstarve_DLC002/creatures/blue_whale/whale_explosion",
	hit = "dontstarve_DLC002/creatures/blue_whale/blubber_hit",
}

local whitesounds = 
{
	stinks = "dontstarve_DLC002/creatures/white_whale/bloated_stinks",
	bloated1 = "dontstarve_DLC002/creatures/white_whale/bloated_plump_1",
	bloated2 = "dontstarve_DLC002/creatures/white_whale/bloated_plump_2",
	explosion = "dontstarve_DLC002/creatures/white_whale/whale_explosion",
	hit = "dontstarve_DLC002/creatures/white_whale/blubber_hit",
}

local growth_stages

local function workcallback(inst, worker, workleft)
	inst.SoundEmitter:PlaySound(inst.sounds.hit)
	inst.AnimState:PlayAnimation("idle_trans2_3")
	inst.AnimState:PushAnimation("idle_bloat3",true)
end

local function workfinishedcallback(inst, worker)
	-- inst.components.growable:SetStage(#growth_stages)
	inst.components.growable:DoGrowth()
end

growth_stages =
{
	{
		name = "bloat1",
		time = function(inst)
			return GetRandomWithVariance(TUNING.WHALE_ROT_TIME[1].base, TUNING.WHALE_ROT_TIME[1].random)
		end,
		fn = function (inst)
			inst.sg:GoToState("bloat1_pre")
			inst.components.workable:SetWorkable(false)
		end,
		growfn = function(inst)
		end,
	},
	{
		name = "bloat2",
		time = function(inst)
			return GetRandomWithVariance(TUNING.WHALE_ROT_TIME[1].base, TUNING.WHALE_ROT_TIME[1].random)
		end,
		fn = function (inst)
			inst.sg:GoToState("bloat2_pre")
			inst.components.workable:SetWorkable(false)
		end,
		growfn = function(inst)
		end,
	},
	{
		name = "bloat3",
		time = function(inst)
			return GetRandomWithVariance(TUNING.WHALE_ROT_TIME[2].base, TUNING.WHALE_ROT_TIME[2].random)
		end,
		fn = function (inst)
			inst.sg:GoToState("bloat3_pre")
			inst.components.workable:SetWorkable(true)
		end,
		growfn = function(inst)
		end,
	},
	{
		name = "explode",
		time = function(inst)
			return GetRandomWithVariance(TUNING.WHALE_ROT_TIME[2].base, TUNING.WHALE_ROT_TIME[2].random)
		end,
		fn = function (inst)
			inst.components.workable:SetWorkable(false)
		end,
		growfn = function(inst)
			-- guarding against ending up here multiple times due to F9 testing
			if not inst.alreadyexploding then
				inst.alreadyexploding = true
				inst.AnimState:PlayAnimation("explode", false)
				inst.SoundEmitter:PlaySound(inst.sounds.explosion)
				
				inst:DoTaskInTime(57*FRAMES, function (inst)
					inst.components.explosive:OnBurnt()
				end )

				inst:DoTaskInTime(58*FRAMES, function(inst)

					local i = 1
					for ii = 1, i+1 do
						inst.components.lootdropper.speed = 3 + (math.random() * 8)
						local loot = GetRandomItem(loots[i])
						local newprefab = inst.components.lootdropper:SpawnLootPrefab(loot)
						local vx, vy, vz = newprefab.Physics:GetVelocity()
						newprefab.Physics:SetVel(vx, 20+(math.random() * 5), vz)
					end
				end)
				inst:DoTaskInTime(60*FRAMES, function(inst)

					local i = 2
					for ii = 1, i+1 do
						inst.components.lootdropper.speed = 4 + (math.random() * 8)
						local loot = GetRandomItem(loots[i])
						local newprefab = inst.components.lootdropper:SpawnLootPrefab(loot)
						local vx, vy, vz = newprefab.Physics:GetVelocity()
						newprefab.Physics:SetVel(vx, 25+(math.random() * 5), vz)
					end
				end)
				inst:DoTaskInTime(63*FRAMES, function(inst)

					local i = 3
					for ii = 1, i+1 do
						inst.components.lootdropper.speed = 6 + (math.random() * 8)
						local loot = GetRandomItem(loots[i])
						local newprefab = inst.components.lootdropper:SpawnLootPrefab(loot)
						local vx, vy, vz = newprefab.Physics:GetVelocity()
						newprefab.Physics:SetVel(vx, 30+(math.random() * 5), vz)
					end

					inst.components.lootdropper:DropLoot()
				end)

				inst:ListenForEvent("animqueueover", function (inst)
					inst:Remove()
				end)
			end
		end,
	},
}

local function fn(Sim)
	local inst = CreateEntity()	
	local trans = inst.entity:AddTransform()
	local sound = inst.entity:AddSoundEmitter()
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("whale_carcass.png")

	MakeObstaclePhysics(inst, .7)

	inst.entity:AddAnimState()
	inst.AnimState:SetBank("whalecarcass")
	inst.AnimState:SetBuild("whale_carcass_build")

	inst:AddComponent("inspectable")
	inst:AddComponent("lootdropper")

	inst:AddComponent("growable")
	inst.components.growable.stages = growth_stages

	inst:AddComponent("explosive")

	inst.components.explosive.lightonexplode = false
	inst.components.explosive.noremove = true

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HACK)

	inst.components.workable:SetOnWorkCallback(workcallback)
	inst.components.workable:SetOnFinishCallback(workfinishedcallback)
	inst.components.workable:SetWorkable(false)

	inst:SetStateGraph("SGwhalecarcass")

	return inst
end

local function bluefn(Sim)
	local inst = fn(Sim)

	inst.AnimState:SetBuild("whale_carcass_build")
	inst.components.lootdropper:SetLoot(alwaysloot_blue)

	inst.sounds = bluesounds

	inst.components.growable:SetStage(1)
	inst.components.growable:StartGrowing()

	inst.components.workable:SetWorkLeft(TUNING.WHALE_BLUE_EXPLOSION_HACKS)
	inst.components.workable:SetWorkable(false)
	inst.components.explosive.explosivedamage = TUNING.WHALE_BLUE_EXPLOSION_DAMAGE

	return inst
end

local function whitefn(Sim)
	local inst = fn(Sim)

	inst.Transform:SetScale(1.25, 1.25, 1.25)

	inst.AnimState:SetBuild("whale_moby_carcass_build")

	inst.components.lootdropper:SetLoot(alwaysloot_white)

	inst.sounds = whitesounds

	inst.components.growable:SetStage(1)
	inst.components.growable:StartGrowing()

	inst.components.workable:SetWorkLeft(TUNING.WHALE_WHITE_EXPLOSION_HACKS)
	inst.components.workable:SetWorkable(false)
	inst.components.explosive.explosivedamage = TUNING.WHALE_WHITE_EXPLOSION_DAMAGE

	return inst
end


return Prefab( "common/objects/whale_carcass_blue", bluefn, assets, prefabs),
	   Prefab( "common/objects/whale_carcass_white", whitefn, assets, prefabs)
