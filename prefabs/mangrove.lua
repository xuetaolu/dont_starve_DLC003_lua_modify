local assets =
{
	Asset("ANIM", "anim/tree_mangrove_build.zip"),
	Asset("ANIM", "anim/tree_mangrove_normal.zip"),
	Asset("ANIM", "anim/tree_mangrove_short.zip"),
	Asset("ANIM", "anim/tree_mangrove_tall.zip"),
	Asset("ANIM", "anim/dust_fx.zip"),
	Asset("SOUND", "sound/forest.fsb"),
	Asset("MINIMAP_IMAGE", "mangrove"),
}

local prefabs =
{
	"log",
	"twigs",
	"charcoal",
	"treeguard",
	"mangrove_chop",
	"mangrove_fall"
}

local builds =
{
	normal = {
		file="tree_mangrove_build",
		prefab_name="mangrovetree",
		normal_loot = {"log", "twigs", "twigs"},
		short_loot = {"log", "twigs"},
		tall_loot = {"log", "log", "twigs", "twigs", "twigs"},

		leif="treeguard",
	}
}

local function makeanims(stage)
	return {
		idle="idle_"..stage,
		sway1="sway1_loop_"..stage,
		sway2="sway2_loop_"..stage,
		chop="chop_"..stage,
		fallleft="fallleft_"..stage,
		fallright="fallright_"..stage,
		stump="stump_"..stage,
		burning="burning_loop_"..stage,
		burnt="burnt_"..stage,
		chop_burnt="chop_burnt_"..stage,
		idle_chop_burnt="idle_chop_burnt_"..stage,
		blown1="blown_loop_"..stage.."1",
		blown2="blown_loop_"..stage.."2",
		blown_pre="blown_pre_"..stage,
		blown_pst="blown_pst_"..stage,
	}
end

local short_anims = makeanims("short")
local tall_anims = makeanims("tall")
local normal_anims = makeanims("normal")
local grow_stump_anims =
{
	"grow_stump_short_to_short",
	"grow_stump_short_to_short",
	"grow_stump_normal_to_short",
	"grow_stump_tall_to_short"
}

local make_tree
local make_stump

local function chop_down_burnt_tree(inst, chopper)
	inst:RemoveComponent("workable")
	inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble")
	inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")
	inst.AnimState:PlayAnimation(inst.anims.chop_burnt)
	RemovePhysicsColliders(inst)
	inst:ListenForEvent("animover", function() inst:Remove() end)
	inst.components.lootdropper:SpawnLootPrefab("charcoal")
	inst.components.lootdropper:DropLoot()
	if inst.pineconetask then
		inst.pineconetask:Cancel()
		inst.pineconetask = nil
	end
end

local function GetBuild(inst)
	local build = builds[inst.build]
	if build == nil then
		return builds["normal"]
	end
	return build
end

local burnt_highlight_override = {.5,.5,.5}
local function OnBurnt(inst, imm)

	local function changes()
		if inst.components.burnable then
			inst.components.burnable:Extinguish()
		end
		inst:RemoveComponent("burnable")
		inst:RemoveComponent("propagator")
		inst:RemoveComponent("growable")
		inst:RemoveComponent("blowinwindgust")
		inst:RemoveTag("shelter")
		inst:RemoveTag("dragonflybait_lowprio")
		inst:RemoveTag("fire")
		--inst:RemoveTag("gustable")

		inst.components.lootdropper:SetLoot({})

		if inst.components.workable then
			inst.components.workable:SetWorkLeft(1)
			inst.components.workable:SetOnWorkCallback(nil)
			inst.components.workable:SetOnFinishCallback(chop_down_burnt_tree)
		end
	end

	if imm then
		changes()
	else
		inst:DoTaskInTime( 0.5, changes)
	end
	inst.AnimState:PlayAnimation(inst.anims.burnt, true)
	--inst.AnimState:SetRayTestOnBB(true);
	inst:AddTag("burnt")

	inst.highlight_override = burnt_highlight_override
end

local function PushSway(inst)
	if math.random() > .5 then
		inst.AnimState:PushAnimation(inst.anims.sway1, true)
	else
		inst.AnimState:PushAnimation(inst.anims.sway2, true)
	end
end

local function Sway(inst)
	if math.random() > .5 then
		inst.AnimState:PlayAnimation(inst.anims.sway1, true)
	else
		inst.AnimState:PlayAnimation(inst.anims.sway2, true)
	end
	inst.AnimState:SetTime(math.random()*2)
end

local function SetShort(inst)
	inst.anims = short_anims

	if inst.components.workable then
		inst.components.workable:SetWorkLeft(TUNING.MANGROVETREE_CHOPS_SMALL)
	end
	-- if inst:HasTag("shelter") then inst:RemoveTag("shelter") end

	inst.components.lootdropper:SetLoot(GetBuild(inst).short_loot)
	--[[if math.random() < 0.5 then
		for i = 1, TUNING.SNAKE_MANGROVETREE_AMOUNT_SMALL do
			if math.random() < 0.5 and GetClock():GetNumCycles() >= TUNING.SNAKE_POISON_START_DAY then
				inst.components.lootdropper:AddChanceLoot("snake_poison", TUNING.SNAKE_MANGROVETREE_POISON_CHANCE)
			else
				inst.components.lootdropper:AddChanceLoot("snake", TUNING.SNAKE_MANGROVETREE_CHANCE)
			end
		end
	end]]

	Sway(inst)
end

local function GrowShort(inst)
	if inst:HasTag("stump") then
		inst.AnimState:PlayAnimation(inst.anim_grow_stump)
	else
		inst.AnimState:PlayAnimation("grow_tall_to_short")
	end
	inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrowFromWilt")
	PushSway(inst)
end

local function SetNormal(inst)
	inst.anims = normal_anims

	if inst.components.workable then
		inst.components.workable:SetWorkLeft(TUNING.MANGROVETREE_CHOPS_NORMAL)
	end
	-- if inst:HasTag("shelter") then inst:RemoveTag("shelter") end

	inst.components.lootdropper:SetLoot(GetBuild(inst).normal_loot)

	--[[if math.random() < 0.5 then
		for i = 1, TUNING.SNAKE_MANGROVETREE_AMOUNT_MED do
			if math.random() < 0.5 and GetClock():GetNumCycles() >= TUNING.SNAKE_POISON_START_DAY then
				inst.components.lootdropper:AddChanceLoot("snake_poison", TUNING.SNAKE_MANGROVETREE_POISON_CHANCE)
			else
				inst.components.lootdropper:AddChanceLoot("snake", TUNING.SNAKE_MANGROVETREE_CHANCE)
			end
		end
	else
		inst.components.lootdropper:AddChanceLoot("bird_egg", 1.0)
	end]]

	Sway(inst)
end

local function GrowNormal(inst)
	inst.AnimState:PlayAnimation("grow_short_to_normal")
	inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
	PushSway(inst)
end

local function SetTall(inst)
	inst.anims = tall_anims
	if inst.components.workable then
		inst.components.workable:SetWorkLeft(TUNING.MANGROVETREE_CHOPS_TALL)
	end
	-- inst:AddTag("shelter")
	inst.components.lootdropper:SetLoot(GetBuild(inst).tall_loot)

	--[[if math.random() < 0.5 then
		for i = 1, TUNING.SNAKE_MANGROVETREE_AMOUNT_TALL do
			if math.random() < 0.5 and GetClock():GetNumCycles() >= TUNING.SNAKE_POISON_START_DAY then
				inst.components.lootdropper:AddChanceLoot("snake_poison", TUNING.SNAKE_MANGROVETREE_POISON_CHANCE)
			else
				inst.components.lootdropper:AddChanceLoot("snake", TUNING.SNAKE_MANGROVETREE_CHANCE)
			end
		end
	else
		if math.random() < 0.5 then
			inst.components.lootdropper:AddChanceLoot("bird_egg", 1.0)
		else
			inst.components.lootdropper:AddChanceLoot("cave_banana", 1.0)
		end
	end]]

	Sway(inst)
end

local function GrowTall(inst)
	inst.AnimState:PlayAnimation("grow_normal_to_tall")
	inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
	PushSway(inst)
end

local function SetStump(inst)
	if inst.anims == nil then
		inst.anims = normal_anims
	end
end

local function GrowStump(inst)
	inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
end

local function inspect_tree(inst)
	if inst:HasTag("burnt") then
		return "BURNT"
	elseif inst:HasTag("stump") then
		return "CHOPPED"
	end
end

local growth_stages =
{
	{name="stump", time = function(inst) return GetRandomWithVariance(TUNING.MANGROVETREE_GROW_TIME[4].base, TUNING.MANGROVETREE_GROW_TIME[4].random) end, fn = function(inst) SetStump(inst) end, growfn = function(inst) GrowStump(inst) end, leifscale=1 },
	{name="short", time = function(inst) return GetRandomWithVariance(TUNING.MANGROVETREE_GROW_TIME[1].base, TUNING.MANGROVETREE_GROW_TIME[1].random) end, fn = function(inst) SetShort(inst) end,  growfn = function(inst) GrowShort(inst) end , leifscale=.7 },
	{name="normal", time = function(inst) return GetRandomWithVariance(TUNING.MANGROVETREE_GROW_TIME[2].base, TUNING.MANGROVETREE_GROW_TIME[2].random) end, fn = function(inst) SetNormal(inst) end, growfn = function(inst) GrowNormal(inst) end, leifscale=1 },
	{name="tall", time = function(inst) return GetRandomWithVariance(TUNING.MANGROVETREE_GROW_TIME[3].base, TUNING.MANGROVETREE_GROW_TIME[3].random) end, fn = function(inst) SetTall(inst) end, growfn = function(inst) GrowTall(inst) end, leifscale=1.25 },	
}

local function growthfn(inst, last, current)
	--print("grow", last, current)
	if last == 1 then
		make_tree(inst)
	end
	if current == 4 then
		inst.components.growable:SetStage(1)
		inst.components.growable:StartGrowing()
	end
	inst.anim_grow_stump = grow_stump_anims[current]
end

local function chop_tree(inst, chopper, chops)

	if chopper and chopper.components.beaverness and chopper.components.beaverness:IsBeaver() then
		inst.SoundEmitter:PlaySound("dontstarve/characters/woodie/beaver_chop_tree")
	else
		inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")
	end

	local fx = SpawnPrefab("mangrove_chop")
	local x, y, z= inst.Transform:GetWorldPosition()
	fx.Transform:SetPosition(x,y + 2 + math.random()*2,z)

	inst.AnimState:PlayAnimation(inst.anims.chop)
	inst.AnimState:PushAnimation(inst.anims.sway1, true)

	--tell any nearby leifs to wake up
	local pt = Vector3(inst.Transform:GetWorldPosition())
	local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, TUNING.PALMTREEGUARD_REAWAKEN_RADIUS, {"treeguard"})
	for k,v in pairs(ents) do
		if v.components.sleeper and v.components.sleeper:IsAsleep() then
			v:DoTaskInTime(math.random(), function() v.components.sleeper:WakeUp() end)
		end
		v.components.combat:SuggestTarget(chopper)
	end
end

local function chop_down_tree(inst, chopper)
	
	
	inst.SoundEmitter:PlaySound("dontstarve/forest/treefall")
	local pt = Vector3(inst.Transform:GetWorldPosition())
	local hispos = Vector3(chopper.Transform:GetWorldPosition())

	local he_right = (hispos - pt):Dot(TheCamera:GetRightVec()) > 0
	if he_right then
		inst.components.lootdropper:DropLoot(pt - TheCamera:GetRightVec())
	else
		inst.components.lootdropper:DropLoot(pt + TheCamera:GetRightVec())
	end

	make_stump(inst)

	if he_right then
		inst.AnimState:PlayAnimation(inst.anims.fallleft)
	else
		inst.AnimState:PlayAnimation(inst.anims.fallright)
	end
	

	local fx = SpawnPrefab("mangrove_fall")
	local x, y, z= inst.Transform:GetWorldPosition()
	fx.Transform:SetPosition(x,y + 2 + math.random()*2,z)

	-- make snakes attack
	--[[local x,y,z = inst.Transform:GetWorldPosition()
	local snakes = TheSim:FindEntities(x,y,z, 2, {"snake"})
	for k, v in pairs(snakes) do
		if v.components.combat then
			v.components.combat:SetTarget(chopper)
		end
	end]]

	inst:DoTaskInTime(.4, function()
		local sz = (inst.components.growable and inst.components.growable.stage > 2) and .5 or .25
		GetPlayer().components.playercontroller:ShakeCamera(inst, "FULL", 0.25, 0.03, sz, 6)
	end)

	--RemovePhysicsColliders(inst)
	inst.AnimState:PushAnimation(inst.anims.stump)

	inst:AddTag("NOCLICK")
	inst:DoTaskInTime(2, function() inst:RemoveTag("NOCLICK") end)
end

local function chop_down_tree_leif(inst, chopper)
	chop_down_tree(inst, chopper)

	--[[local days_survived = GetClock().numcycles
	if days_survived >= TUNING.LEIF_MIN_DAY then
		if math.random() <= TUNING.LEIF_PERCENT_CHANCE then

			local numleifs = 1
			if days_survived > 30 then
				numleifs = math.random(2)
			elseif days_survived > 80 then
				numleifs = math.random(3)
			end

			for k = 1,numleifs do

				local target = FindEntity(inst, TUNING.LEIF_MAXSPAWNDIST,
					function(item)
						if item.components.growable and item.components.growable.stage <= 3 then
							return item:HasTag("tree") and (not item:HasTag("stump")) and (not item:HasTag("burnt")) and not item.noleif
						end
						return false
					end)

				if target  then
					target.noleif = true
					target.leifscale = growth_stages[target.components.growable.stage].leifscale or 1
					target:DoTaskInTime(1 + math.random()*3, function()
						if target and not target:HasTag("stump") and not target:HasTag("burnt") and
							target.components.growable and target.components.growable.stage <= 3 then
							local target = target
							if builds[target.build] and builds[target.build].leif then
								local leif = SpawnPrefab(builds[target.build].leif)
								if leif then
									local scale = target.leifscale
									local r,g,b,a = target.AnimState:GetMultColour()
									leif.AnimState:SetMultColour(r,g,b,a)

									--we should serialize this?
									leif.components.locomotor.walkspeed = leif.components.locomotor.walkspeed*scale
									leif.components.combat.defaultdamage = leif.components.combat.defaultdamage*scale
									leif.components.health.maxhealth = leif.components.health.maxhealth*scale
									leif.components.health.currenthealth = leif.components.health.currenthealth*scale
									leif.components.combat.hitrange = leif.components.combat.hitrange*scale
									leif.components.combat.attackrange = leif.components.combat.attackrange*scale

									leif.Transform:SetScale(scale,scale,scale)
									leif.components.combat:SuggestTarget(chopper)
									leif.sg:GoToState("spawn")
									target:Remove()

									leif.Transform:SetPosition(target.Transform:GetWorldPosition())
								end
							end
						end
					end)
				end
			end
		end
	end]]
end

local function tree_burnt(inst)
	OnBurnt(inst)
	inst.pineconetask = inst:DoTaskInTime(10,
		function()
			local pt = Vector3(inst.Transform:GetWorldPosition())
			if math.random(0, 1) == 1 then
				pt = pt + TheCamera:GetRightVec()
			else
				pt = pt - TheCamera:GetRightVec()
			end
			inst.components.lootdropper:DropLoot(pt)
			inst.pineconetask = nil
		end)
end

local function onsave(inst, data)
	if inst:HasTag("burnt") or inst:HasTag("fire") then
		data.burnt = true
	end

	if inst:HasTag("stump") then
		data.stump = true
	end

	if inst.build ~= "normal" then
		data.build = inst.build
	end
end

local function onload(inst, data)
	if data then
		if not data.build or builds[data.build] == nil then
			inst.build = "normal"
		else
			inst.build = data.build
		end

		if data.burnt then
			inst:AddTag("fire") -- Add the fire tag here: OnEntityWake will handle it actually doing burnt logic
		elseif data.stump then
			make_stump(inst)
			inst.AnimState:PlayAnimation(inst.anims.stump)
		end
	end
end

local function OnEntitySleep(inst)
	local fire = false
	if inst:HasTag("fire") then
		fire = true
	end
	inst:RemoveComponent("burnable")
	inst:RemoveComponent("propagator")
	inst:RemoveComponent("inspectable")
	if fire then
		inst:AddTag("fire")
	end
end

local function OnEntityWake(inst)

	if not inst:HasTag("burnt") and not inst:HasTag("fire") then
		if not inst.components.burnable then
			if inst:HasTag("stump") then
				MakeSmallBurnable(inst)
			else
				MakeLargeBurnable(inst)
				inst.components.burnable:SetFXLevel(5)
				inst.components.burnable:SetOnBurntFn(tree_burnt)
			end
		end

		if not inst.components.propagator then
			if inst:HasTag("stump") then
				MakeSmallPropagator(inst)
			else
				MakeLargePropagator(inst)
			end
		end
	elseif not inst:HasTag("burnt") and inst:HasTag("fire") then
		OnBurnt(inst, true)
	end

	if not inst.components.inspectable then
		inst:AddComponent("inspectable")
		inst.components.inspectable.getstatus = inspect_tree
	end
end

local function OnGustAnimDone(inst)
	if inst:HasTag("stump") or inst:HasTag("burnt") then
		inst:RemoveEventCallback("animover", OnGustAnimDone)
		return
	end
	if inst.components.blowinwindgust and inst.components.blowinwindgust:IsGusting() then
		local anim = math.random(1,2)
		inst.AnimState:PlayAnimation(inst.anims["blown"..tostring(anim)], false)
	else
		inst:RemoveEventCallback("animover", OnGustAnimDone)
		inst.AnimState:PlayAnimation(inst.anims.blown_pst, false)
		PushSway(inst)
	end
end

local function OnGustStart(inst, windspeed)
	if inst:HasTag("stump") or inst:HasTag("burnt") then
		return
	end
	if inst.spotemitter == nil then
		AddToNearSpotEmitter(inst, "treeherd", "tree_creak_emitter", TUNING.TREE_CREAK_RANGE)
	end
	inst.AnimState:PlayAnimation(inst.anims.blown_pre, false)
	inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/wind_tree_creak")
	inst:ListenForEvent("animover", OnGustAnimDone)
end

local function OnGustFall(inst)
	if inst:HasTag("burnt") then
		chop_down_burnt_tree(inst, GetPlayer())
	else
		chop_down_tree(inst, GetPlayer())
	end
end

make_tree = function(inst)
	inst:AddTag("plant")
	inst:AddTag("tree")
	inst:AddTag("workable")
	inst:AddTag("shelter")
	inst:RemoveTag("stump")

	-------------------
	inst:RemoveComponent("burnable")
	MakeLargeBurnable(inst)
	inst.components.burnable:SetFXLevel(5)
	inst.components.burnable:SetOnBurntFn(tree_burnt)
	inst.components.burnable:MakeDragonflyBait(1)

	inst:RemoveComponent("propagator")
	MakeLargePropagator(inst)

	-------------------
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.CHOP)
	inst.components.workable:SetOnWorkCallback(chop_tree)
	inst.components.workable:SetOnFinishCallback(chop_down_tree_leif)

	inst:AddComponent("blowinwindgust")
	inst.components.blowinwindgust:SetWindSpeedThreshold(TUNING.MANGROVETREE_WINDBLOWN_SPEED)
	inst.components.blowinwindgust:SetDestroyChance(TUNING.MANGROVETREE_WINDBLOWN_FALL_CHANCE)
	inst.components.blowinwindgust:SetGustStartFn(OnGustStart)
	inst.components.blowinwindgust:SetDestroyFn(OnGustFall)
	inst.components.blowinwindgust:Start()

	inst:AddComponent("waveobstacle")
	inst.components.waveobstacle:SetOnDestroyFn(OnGustFall)
	inst.components.waveobstacle:SetDestroyChance(0.1)
end

make_stump = function(inst)
	inst:AddTag("stump")
	inst:RemoveTag("tree")
	inst:RemoveTag("workable")
	inst:RemoveTag("shelter")

	inst.components.growable:SetStage(1)

	inst:RemoveComponent("burnable")
	MakeSmallBurnable(inst)
	inst:RemoveComponent("workable")
	inst:RemoveComponent("propagator")
	MakeSmallPropagator(inst)
	inst:RemoveComponent("blowinwindgust")
	inst:RemoveComponent("waveobstacle")

	--RemovePhysicsColliders(inst)
	inst.AnimState:PlayAnimation(inst.anims.stump, true)
end

local function makefn(build, stage, data)

	local function fn(Sim)
		local l_stage = stage
		if l_stage == 0 then
			l_stage = math.random(2,4)
		end

		local inst = CreateEntity()
		local trans = inst.entity:AddTransform()
		local anim = inst.entity:AddAnimState()

		local sound = inst.entity:AddSoundEmitter()

		MakeObstaclePhysics(inst, 0.9)

		local minimap = inst.entity:AddMiniMapEntity()
		minimap:SetIcon("mangrove.png")

		minimap:SetPriority(-1)

		inst.build = build
		anim:SetBuild(GetBuild(inst).file)
		anim:SetBank("tree_mangrove")
		--local color = 0.5 + math.random() * 0.5
		--anim:SetMultColour(color, color, color, 1)

		inst.anim_grow_stump = grow_stump_anims[l_stage]

		-------------------
		inst:AddComponent("inspectable")
		inst.components.inspectable.getstatus = inspect_tree

		-------------------
		inst:AddComponent("lootdropper")
		---------------------
		inst:AddComponent("growable")
		inst.components.growable.stages = growth_stages
		inst.components.growable:SetStage(l_stage)
		inst.components.growable.loopstages = false
		inst.components.growable.springgrowth = true
		inst.components.growable:SetOnGrowthFn(growthfn)
		inst.components.growable:StartGrowing()

		---------------------
		inst.AnimState:SetTime(math.random()*2)

		---------------------

		inst.OnSave = onsave
		inst.OnLoad = onload

		MakeSnowCovered(inst, .01)
		---------------------

		inst:SetPrefabName( GetBuild(inst).prefab_name )

		if data =="burnt"  then
			OnBurnt(inst)
		elseif data =="stump" or l_stage == 1 then
			make_stump(inst)
		else
			make_tree(inst)
		end

		inst.OnEntitySleep = OnEntitySleep
		inst.OnEntityWake = OnEntityWake


		return inst
	end
	return fn
end

local function tree(name, build, stage, data)
	return Prefab("forest/objects/trees/"..name, makefn(build, stage, data), assets, prefabs)
end

return tree("mangrovetree", "normal", 0),
		tree("mangrovetree_normal", "normal", 2),
		tree("mangrovetree_tall", "normal", 3),
		tree("mangrovetree_short", "normal", 1),
		tree("mangrovetree_burnt", "normal", 0, "burnt"),
		tree("mangrovetree_stump", "normal", 0, "stump")
