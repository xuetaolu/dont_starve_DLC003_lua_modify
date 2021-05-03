require("brains/doydoybrain")
require "stategraphs/SGdoydoy"

local assets_baby =
{

	Asset("ANIM", "anim/doydoy.zip"),
	Asset("ANIM", "anim/doydoy_baby.zip"),
	Asset("ANIM", "anim/doydoy_baby_build.zip"),
	Asset("ANIM", "anim/doydoy_teen_build.zip"),
	Asset("INV_IMAGE", "doydoy_baby"),
	Asset("INV_IMAGE", "doydoy_teen"),
}

local assets =
{
	Asset("ANIM", "anim/doydoy.zip"),
	Asset("ANIM", "anim/doydoy_adult_build.zip"),
}

local prefabs_baby =
{
	"doydoyfeather",
	"drumstick",
}

local prefabs =
{
	"doydoyfeather",
	"drumstick",
	"doydoy_mate_fx",
}

local babyloot = {"smallmeat","doydoyfeather"}
local teenloot = {"drumstick","doydoyfeather","doydoyfeather"}
local adultloot = {'meat', 'drumstick', 'drumstick', 'doydoyfeather', 'doydoyfeather'}

local babyfoodprefs = {"SEEDS"}
local teenfoodprefs = {"SEEDS", "VEGGIE"}
local adultfoodprefs = {"MEAT", "VEGGIE", "SEEDS", "ELEMENTAL", "WOOD"}

local babysounds = 
{
	eat_pre = "dontstarve_DLC002/creatures/baby_doy_doy/eat_pre",
	swallow = "dontstarve_DLC002/creatures/baby_doy_doy/swallow",
	hatch = "dontstarve_DLC002/creatures/baby_doy_doy/hatch",
	death = "dontstarve_DLC002/creatures/baby_doy_doy/death",
	jump = "dontstarve_DLC002/creatures/baby_doy_doy/jump",
	peck = "dontstarve_DLC002/creatures/teen_doy_doy/peck",
}

local teensounds = 
{
	idle = "dontstarve_DLC002/creatures/teen_doy_doy/idle",
	eat_pre = "dontstarve_DLC002/creatures/teen_doy_doy/eat_pre",
	swallow = "dontstarve_DLC002/creatures/teen_doy_doy/swallow",
	hatch = "dontstarve_DLC002/creatures/teen_doy_doy/hatch",
	death = "dontstarve_DLC002/creatures/teen_doy_doy/death",
	jump = "dontstarve_DLC002/creatures/baby_doy_doy/jump",
	peck = "dontstarve_DLC002/creatures/teen_doy_doy/peck",
}

local function TrackInSpawner(inst)
	local ground = GetWorld()
	if ground and ground.components.doydoyspawner then
		ground.components.doydoyspawner:StartTracking(inst)
	end
end

local function StopTrackingInSpawner(inst)
	local ground = GetWorld()
	if ground and ground.components.doydoyspawner then
		ground.components.doydoyspawner:StopTracking(inst)
	end
end

local function SetBaby(inst)
	
	inst:AddTag("baby")
	inst:RemoveTag("teen")

	inst.AnimState:SetBank("doydoy_baby")
	inst.AnimState:SetBuild("doydoy_baby_build")
	inst.AnimState:PlayAnimation("idle", true)

	inst.sounds = babysounds
	inst.components.combat:SetHurtSound("dontstarve_DLC002/creatures/baby_doy_doy/hit")

	inst.Transform:SetScale(1, 1, 1)

	inst.components.health:SetMaxHealth(TUNING.DOYDOY_BABY_HEALTH)
	inst.components.locomotor.walkspeed = TUNING.DOYDOY_BABY_WALK_SPEED
	inst.components.locomotor.runspeed = TUNING.DOYDOY_BABY_WALK_SPEED
	inst.components.lootdropper:SetLoot(babyloot)
	inst.components.eater.foodprefs = babyfoodprefs

	inst.components.inventoryitem:ChangeImageName("doydoy_baby")

	inst.components.named:SetName(STRINGS.NAMES["DOYDOYBABY"])
end

local function SetTeen(inst)
	inst:AddTag("teen")
	inst:RemoveTag("baby")

	inst.AnimState:SetBank("doydoy")
	inst.AnimState:SetBuild("doydoy_teen_build")
	inst.AnimState:PlayAnimation("idle", true)

	inst.sounds = teensounds
	inst.components.combat:SetHurtSound("dontstarve_DLC002/creatures/doy_doy/hit")

	local scale = TUNING.DOYDOY_TEEN_SCALE
	inst.Transform:SetScale(scale, scale, scale)

	inst.components.health:SetMaxHealth(TUNING.DOYDOY_TEEN_HEALTH)
	inst.components.locomotor.walkspeed = TUNING.DOYDOY_TEEN_WALK_SPEED
	inst.components.locomotor.runspeed = TUNING.DOYDOY_TEEN_WALK_SPEED
	inst.components.lootdropper:SetLoot(teenloot)
	inst.components.eater.foodprefs = teenfoodprefs

	inst.components.inventoryitem:ChangeImageName("doydoy_teen")

	inst.components.named:SetName(STRINGS.NAMES["DOYDOYTEEN"])
end

local function SetFullyGrown(inst)
	inst.needtogrowup = true
end

local function GetBabyGrowTime()
	return TUNING.DOYDOY_BABY_GROW_TIME
end

local function GetTeenGrowTime()
	return TUNING.DOYDOY_TEEN_GROW_TIME
end

local growth_stages =
{
	{name="baby", time = GetBabyGrowTime, fn = SetBaby},
	{name="teen", time = GetTeenGrowTime, fn = SetTeen},
	{name="grown", time = GetTeenGrowTime, fn = SetFullyGrown},
}

local function OnEntitySleep(inst)
	if inst.shouldGoAway then
		inst:Remove()
	end
end

local function OnEntityWake(inst)
	inst:ClearBufferedAction()

	if inst.needtogrowup then
		local grown = SpawnPrefab("doydoy")
		grown.Transform:SetPosition(inst.Transform:GetWorldPosition() )
		grown.Transform:SetRotation(inst.Transform:GetRotation() )
		
		inst:Remove()
	end
end

local function CanEatFn(inst, food)
	return food.prefab ~= "doydoyegg" and food.prefab ~= "doydoyegg_cooked" and food.prefab ~= "doydoyegg_cracked"
end

local function OnInventory(inst)
	inst:ClearBufferedAction()
	inst:AddTag("mating")
end

local function OnDropped(inst)
	inst.components.sleeper:GoToSleep()
	inst:AddTag("mating")
end

local function OnMate(inst, partner)
	
end

local function commonfn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()

	shadow:SetSize(1.5, 0.8)
	
	inst.Transform:SetFourFaced()
	
	MakePoisonableCharacter(inst)
	MakeCharacterPhysics(inst, 50, .5)

	inst.AnimState:SetBank("doydoy")
	inst.AnimState:SetBuild("doydoy_adult_build")
	inst.AnimState:PlayAnimation("idle", true)
	
	inst:AddTag("doydoy")
	inst:AddTag("companion")
	inst:AddTag("animal")	
	
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.nobounce = true
	inst.components.inventoryitem.canbepickedup = false
	inst.components.inventoryitem.longpickup = true

	inst:AddComponent("appeasement")
    inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_LARGE
	
	inst:AddComponent("health")
	inst:AddComponent("sizetweener")
	inst:AddComponent("sleeper")

	inst:AddComponent("lootdropper")
	
	inst:AddComponent("inspectable")

	inst:AddComponent("inventory")
	inst:AddComponent("entitytracker")
	
	inst:AddComponent("eater")
	inst.components.eater:SetCanEatTestFn(CanEatFn)

	inst:ListenForEvent("entitysleep", OnEntitySleep)
	inst:ListenForEvent("entitywake", OnEntityWake)

	MakeSmallBurnableCharacter(inst, "swap_fire")
	MakeSmallFreezableCharacter(inst, "mossling_body")


	inst:AddComponent("locomotor")

	inst:AddComponent("mateable")
	inst.components.mateable:SetOnMateCallback(OnMate)

	inst:AddComponent("combat")
	
	TrackInSpawner(inst)
	inst:ListenForEvent("onremove", StopTrackingInSpawner)

	inst:ListenForEvent("gotosleep", function(inst) inst.components.inventoryitem.canbepickedup = true end)
    inst:ListenForEvent("onwakeup", function(inst) 
    	inst.components.inventoryitem.canbepickedup = false
    	inst:RemoveTag("mating")
    end)

    inst:ListenForEvent("death", function(inst, data) 
    	--If the doydoy is held drop items.
		local owner = inst.components.inventoryitem:GetGrandOwner()

		if inst.components.lootdropper and owner then
			local loots = inst.components.lootdropper:GenerateLoot()
			inst:Remove()
			for k, v in pairs(loots) do
				local loot = SpawnPrefab(v)
				owner.components.inventory:GiveItem(loot)
			end
		end
	end)
	
	MakeFeedablePet(inst, TUNING.TOTAL_DAY_TIME, OnInventory, OnDropped)

	return inst
end

local function babyfn(Sim)
	local inst = commonfn(Sim)

	inst.AnimState:SetBank("doydoy_baby")
	inst.AnimState:SetBuild("doydoy_baby_build")
	inst.AnimState:PlayAnimation("idle", true)

	inst:AddTag("baby")

	inst.sounds = babysounds
	
	inst.components.combat:SetHurtSound("dontstarve_DLC002/creatures/baby_doy_doy/hit")
	inst:AddComponent("named")
	
	inst.components.health:SetMaxHealth(TUNING.DOYDOY_BABY_HEALTH)
	inst.components.locomotor.walkspeed = TUNING.DOYDOY_BABY_WALK_SPEED
	inst.components.locomotor.runspeed = TUNING.DOYDOY_BABY_WALK_SPEED
	inst.components.lootdropper:SetLoot(babyloot)

	inst.components.inventoryitem:ChangeImageName("doydoy_baby")

	inst.components.eater.foodprefs = babyfoodprefs

	inst:SetStateGraph("SGdoydoybaby")
	local brain = require("brains/doydoybrain")
	inst:SetBrain(brain)

	inst:AddComponent("growable")
	inst.components.growable.stages = growth_stages
	-- inst.components.growable.growonly = true
	inst.components.growable:SetStage(1)
	inst.components.growable.growoffscreen = true
	inst.components.growable:StartGrowing()

	return inst
end

local function adultfn(Sim)
	local inst = commonfn(Sim)

	inst.AnimState:SetBank("doydoy")
	inst.AnimState:SetBuild("doydoy_adult_build")
	inst.AnimState:PlayAnimation("idle", true)

	inst.components.combat:SetHurtSound("dontstarve_DLC002/creatures/doy_doy/hit")

	inst.components.health:SetMaxHealth(TUNING.DOYDOY_HEALTH)
	inst.components.locomotor.walkspeed = TUNING.DOYDOY_WALK_SPEED
	inst.components.lootdropper:SetLoot(adultloot)

	inst.components.eater.foodprefs = adultfoodprefs
	
	inst:SetStateGraph("SGdoydoy")
	local brain = require("brains/doydoybrain")
	inst:SetBrain(brain)

	return inst
end

return  Prefab("common/monsters/doydoybaby", babyfn, assets_baby, prefabs_baby),
		Prefab("common/monsters/doydoy", adultfn, assets, prefabs)
