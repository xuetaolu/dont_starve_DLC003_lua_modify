local dogfish_assets=
{
	Asset("ANIM", "anim/fish_dogfish.zip"),
	Asset("INV_IMAGE", "fish_dogfish"),
}

local swordfish_assets=
{
	Asset("ANIM", "anim/fish_swordfish.zip"), 	
}

local spoiledfish_assets = 
{
	Asset("ANIM", "anim/spoiled_fish.zip")
}

local cooked_assets = 
{
	Asset("ANIM", "anim/fish_med_cooked.zip")
}

local raw_assets = 
{
	Asset("ANIM", "anim/fish_raw.zip")
}

local small_assets =
{
	Asset("ANIM", "anim/fish_meat_small.zip")
}

local lobster_assets =
{
	Asset("ANIM", "anim/lobster_build_color.zip"),
	Asset("ANIM", "anim/lobster.zip"),
}

local prefabs =
{
	"fish_med_cooked",
	"spoiled_fish",
	"spoiled_food",
}

SetSharedLootTable( 'spoiledfish',
	{
		{'boneshard',    1.00},
		{'boneshard',    1.00},
	})

local function stopkicking(inst)
	inst.AnimState:PlayAnimation("dead")
end


local function makefish_med(bank, build, inventoryimage, dryablesymbol)

	local function commonfn()
		local inst = CreateEntity()
		inst.entity:AddTransform()
		
		MakeInventoryPhysics(inst)
		
		inst.entity:AddAnimState()
		inst.AnimState:SetBank(bank)
		inst.AnimState:SetBuild(build)
		inst.build = build --This is used within SGwilson, sent from an event in fishingrod.lua
		
		inst:AddTag("catfood")


		inst:AddComponent("edible")
		inst.components.edible.ismeat = true
		inst.components.edible.foodtype = "MEAT"
		
		inst:AddComponent("stackable")
		inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

		inst:AddComponent("perishable")
		inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
		inst.components.perishable:StartPerishing()
		inst.components.perishable.onperishreplacement = "spoiled_fish"
				
		inst:AddComponent("inspectable")
		
		inst:AddComponent("inventoryitem")
		inst.components.inventoryitem:ChangeImageName(inventoryimage)
		
		inst:AddComponent("tradable")
		inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
    	inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD
		inst.data = {}

		inst:AddComponent("appeasement")
		inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_SMALL

		return inst
	end

	local function rawfn()
		local inst = commonfn(build)

		MakeInventoryFloatable(inst, "idle_water", "dead")
		inst.AnimState:PlayAnimation("dead")


		inst.components.edible.healthvalue = TUNING.HEALING_TINY
		inst.components.edible.hungervalue = TUNING.CALORIES_MED
		inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
		
		inst:AddComponent("cookable")
		inst.components.cookable.product = "fish_med_cooked"
		inst:AddComponent("dryable")
		inst.components.dryable:SetProduct("meat_dried")
		inst.components.dryable:SetDryTime(TUNING.DRY_FAST)
		if dryablesymbol then
			inst.components.dryable:SetOverrideSymbol(dryablesymbol)
		end
		
		inst:AddTag("spoiledbypackim")
		inst:AddTag("meat")
		inst:AddTag("fishmeat")
		
		return inst
	end

   
	return rawfn
end

local function onspoiledhammered(inst, worker)
	local inLimbo = inst:IsInLimbo()
	local to_hammer = (inst.components.stackable and inst.components.stackable:Get(1)) or inst
	if to_hammer == inst then
		to_hammer.components.inventoryitem:RemoveFromOwner(true)
	end
	if inLimbo then
		to_hammer:ReturnToScene()
		if worker and worker:IsValid() then
			to_hammer.Transform:SetPosition(worker.Transform:GetWorldPosition())
		end
	end

	to_hammer.Transform:SetPosition(inst:GetPosition():Get())
	to_hammer.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(to_hammer.Transform:GetWorldPosition())
	to_hammer.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")

	inst.components.workable:SetWorkLeft(1)
	
	to_hammer:Remove()
end

local function spoiledfn()

	local inst = CreateEntity()
	inst.entity:AddTransform()
	
	MakeInventoryPhysics(inst)
	
	inst.entity:AddAnimState()
	inst.AnimState:SetBank("spoiled_fish")
	inst.AnimState:SetBuild("spoiled_fish")
	inst.AnimState:PlayAnimation("idle", true)

	inst.entity:AddSoundEmitter()
	
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("inspectable")
	
	inst:AddComponent("inventoryitem")

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(1)
	inst.components.workable:SetOnFinishCallback(onspoiledhammered)

	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot({"boneshard", "boneshard"})

	inst:AddComponent("floatable")
	inst.components.floatable:SetOnHitWaterFn(function(inst) inst.AnimState:PlayAnimation("idle_water", true) end)
	inst.components.floatable:SetOnHitLandFn(function(inst) inst.AnimState:PlayAnimation("idle", true) end)

	inst:RemoveComponent("appeasement")
	
	return inst

end 

local function cookedfn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	
	MakeInventoryPhysics(inst)
	
	inst.entity:AddAnimState()
	inst.AnimState:SetBank("fish_med_cooked")
	inst.AnimState:SetBuild("fish_med_cooked")
	inst.AnimState:PlayAnimation("cooked", true)

	MakeInventoryFloatable(inst, "idle_cooked_water", "cooked")

	inst:AddTag("meat")
	inst:AddTag("fishmeat")
	inst:AddTag("catfood")
	inst:AddTag("packimfood")

	inst:AddComponent("edible")
	inst.components.edible.ismeat = true
	inst.components.edible.foodtype = "MEAT"
	inst.components.edible.foodstate = "COOKED"
	inst.components.edible.healthvalue = TUNING.HEALING_MED
	inst.components.edible.hungervalue = TUNING.CALORIES_MED
	
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food" 
	
	inst:AddComponent("inspectable")
	
	inst:AddComponent("inventoryitem")
	
	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
    inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD
	inst.data = {}
	inst:AddComponent("bait")

	return inst
end

local function fish_raw_fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	
	MakeInventoryPhysics(inst)
	
	inst.entity:AddAnimState()
	inst.AnimState:SetBank("fish_raw")
	inst.AnimState:SetBuild("fish_raw")
	inst.AnimState:PlayAnimation("idle")
	
	MakeInventoryFloatable(inst, "idle_water", "idle")

	inst:AddTag("catfood")
	inst:AddTag("fishmeat")
	inst:AddTag("packimfood")
	inst:AddTag("meat")

	inst:AddComponent("edible")
	inst.components.edible.ismeat = true
	inst.components.edible.foodtype = "MEAT"
	
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"
			
	inst:AddComponent("inspectable")
	
	inst:AddComponent("inventoryitem")
	
	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
    inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD
	inst.data = {}

	inst:AddComponent("appeasement")
	inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_SMALL

	inst.components.edible.healthvalue = TUNING.HEALING_TINY
	inst.components.edible.hungervalue = TUNING.CALORIES_MED
	
	inst:AddComponent("cookable")
	inst.components.cookable.product = "fish_med_cooked"
	inst:AddComponent("dryable")
	inst.components.dryable:SetProduct("meat_dried")
	inst.components.dryable:SetDryTime(TUNING.DRY_FAST)
--	inst.components.dryable:SetOverrideSymbol("fishraw")

	inst:AddComponent("bait")

	return inst
end

local function fish_raw_small_fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	
	MakeInventoryPhysics(inst)
	
	inst.entity:AddAnimState()
	inst.AnimState:SetBank("fish_meat_small")
	inst.AnimState:SetBuild("fish_meat_small")
	inst.AnimState:PlayAnimation("raw")
	
	MakeInventoryFloatable(inst, "raw_water", "raw")

	inst:AddTag("catfood")
	inst:AddTag("fishmeat")
	inst:AddTag("packimfood")
	inst:AddTag("meat")

	inst:AddComponent("edible")
	inst.components.edible.ismeat = true
	inst.components.edible.foodtype = "MEAT"
	
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	inst:AddComponent("inspectable")
	
	inst:AddComponent("inventoryitem")
	
	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
    inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD
	inst.data = {}

	inst:AddComponent("appeasement")
	inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_SMALL

	inst.components.edible.healthvalue = TUNING.HEALING_TINY
	inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
	
	inst:AddComponent("cookable")
	inst.components.cookable.product = "fish_raw_small_cooked"

	inst:AddComponent("dryable")
	inst.components.dryable:SetProduct("smallmeat_dried")
	inst.components.dryable:SetDryTime(TUNING.DRY_FAST)
--	inst.components.dryable:SetOverrideSymbol("fishraw_small")

	inst:AddComponent("bait")

	return inst
end

local function fish_raw_small_cooked_fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	
	MakeInventoryPhysics(inst)
	
	inst.entity:AddAnimState()
	inst.AnimState:SetBank("fish_meat_small")
	inst.AnimState:SetBuild("fish_meat_small")
	inst.AnimState:PlayAnimation("cooked", true)

	MakeInventoryFloatable(inst, "cooked_water", "cooked")

	inst:AddTag("meat")
	inst:AddTag("fishmeat")
	inst:AddTag("catfood")
	inst:AddTag("packimfood")

	inst:AddComponent("edible")
	inst.components.edible.ismeat = true
	inst.components.edible.foodtype = "MEAT"
	inst.components.edible.foodstate = "COOKED"
	inst.components.edible.healthvalue = TUNING.HEALING_TINY
	inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
	
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food" 
	
	inst:AddComponent("inspectable")
	
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem:ChangeImageName("fishtropical_cooked")
	
	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
    inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD
	inst.data = {}
	inst:AddComponent("bait")

	return inst
end

local function lobster_dead_fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst.AnimState:SetBank("lobster")
	inst.AnimState:SetBuild("lobster_build_color")
	inst.AnimState:PlayAnimation("idle_dead")

	MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "idle_dead_water", "idle_dead")

	inst:AddTag("meat")
	inst:AddTag("fishmeat")
	inst:AddTag("catfood")
	inst:AddTag("packimfood")

	inst:AddComponent("inspectable")

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	inst:AddComponent("inventoryitem")

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

	inst:AddComponent("edible")
	inst.components.edible.ismeat = true
	inst.components.edible.foodtype = "MEAT"
	inst.components.edible.healthvalue = TUNING.HEALING_TINY
	inst.components.edible.hungervalue = TUNING.CALORIES_SMALL

	inst:AddComponent("cookable")
	inst.components.cookable.product = "lobster_dead_cooked"

	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
    inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD

	return inst
end

local function lobster_dead_cooked_fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

	inst.AnimState:SetBank("lobster")
	inst.AnimState:SetBuild("lobster_build_color")
	inst.AnimState:PlayAnimation("idle_cooked")

	MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "idle_cooked_water", "idle_cooked")

	inst:AddTag("meat")
	inst:AddTag("fishmeat")
	inst:AddTag("catfood")
	
	inst:AddTag("packimfood")

	inst:AddComponent("inspectable")

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

	inst:AddComponent("inventoryitem")

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM

	inst:AddComponent("edible")
	inst.components.edible.ismeat = true
	inst.components.edible.foodtype = "MEAT"
	inst.components.edible.foodstate = "COOKED"
	inst.components.edible.healthvalue = TUNING.HEALING_TINY
	inst.components.edible.hungervalue = TUNING.CALORIES_SMALL

	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
    inst.components.tradable.dubloonvalue = TUNING.DUBLOON_VALUES.SEAFOOD

	return inst
end

local rawmed = makefish_med("dogfish", "fish_dogfish", "fish_dogfish", "dogfish")
local rawsword = makefish_med("swordfish", "fish_swordfish", "dead_swordfish", "swordfish")

return Prefab( "common/inventory/fish_med", rawmed, dogfish_assets, prefabs), 
	   Prefab( "common/inventory/dead_swordfish", rawsword, swordfish_assets, prefabs), 
	   Prefab( "common/inventory/fish_raw", fish_raw_fn, raw_assets),
	   Prefab( "common/inventory/spoiled_fish", spoiledfn,spoiledfish_assets), 
	   Prefab( "common/inventory/fish_med_cooked", cookedfn, cooked_assets),
	   Prefab( "common/inventory/fish_raw_small", fish_raw_small_fn, small_assets),
	   Prefab( "common/inventory/fish_raw_small_cooked", fish_raw_small_cooked_fn, small_assets),
	   Prefab( "common/inventory/lobster_dead", lobster_dead_fn, lobster_assets),
	   Prefab( "common/inventory/lobster_dead_cooked", lobster_dead_cooked_fn, lobster_assets)
