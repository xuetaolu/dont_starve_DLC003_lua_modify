require "prefabutil"
local assets =
{
Asset("ANIM", "anim/teatree_nut.zip"),
}

local prefabs = 
{
  --  "acorn_cooked",
    "spoiled_food"
}

local function growtree(inst)
	print ("GROWTREE")
    inst.growtask = nil
    inst.growtime = nil
	local tree = SpawnPrefab("teatree") 
    if tree then 
		tree.Transform:SetPosition(inst.Transform:GetWorldPosition() ) 
        tree:growfromseed()--PushEvent("growfromseed")
        inst:Remove()
	end
end

local function plant(inst, growtime)

    inst:RemoveComponent("inventoryitem")
    inst:RemoveComponent("locomotor")
    RemovePhysicsColliders(inst)
    RemoveBlowInHurricane(inst)
    inst.AnimState:PlayAnimation("idle_planted")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/plant_tree")
    inst.growtime = GetTime() + growtime
    if inst.components.edible then
        inst:RemoveComponent("edible")
    end
    print ("PLANT", growtime)

      inst.growtask = inst:DoTaskInTime(growtime, growtree)
end

local function ondeploy (inst, pt) 
    inst = inst.components.stackable:Get()
    inst.Transform:SetPosition(pt:Get() )

    if not SaveGameIndex:IsModeShipwrecked() then
        inst:RemoveComponent("perishable")
    end
    
    local timeToGrow = GetRandomWithVariance(TUNING.ACORN_GROWTIME.base, TUNING.ACORN_GROWTIME.random)
    plant(inst, timeToGrow)	
end

local function stopgrowing(inst)
    if inst.growtask then
        inst.growtask:Cancel()
        inst.growtask = nil
    end
    inst.growtime = nil
end

local function restartgrowing(inst)
    if inst and not inst.growtask then
        local growtime = GetRandomWithVariance(TUNING.ACORN_GROWTIME.base, TUNING.ACORN_GROWTIME.random)
        inst.growtime = GetTime() + growtime
        inst.growtask = inst:DoTaskInTime(growtime, growtree)
    end
end


local notags = {'NOBLOCK', 'player', 'FX'}
local function test_ground(inst, pt)
	local ground_OK = inst:GetIsOnLand(pt.x, pt.y, pt.z)
	local tiletype = GetGroundTypeAtPosition(pt)
	ground_OK = ground_OK and
					tiletype ~= GROUND.ROCKY and tiletype ~= GROUND.ROAD and tiletype ~= GROUND.IMPASSABLE and tiletype ~= GROUND.INTERIOR and
					tiletype ~= GROUND.UNDERROCK and tiletype ~= GROUND.WOODFLOOR and 
					tiletype ~= GROUND.CARPET and tiletype ~= GROUND.CHECKER and tiletype < GROUND.UNDERGROUND
	
	if ground_OK then
	    local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 4, nil, notags) -- or we could include a flag to the search?
		local min_spacing = inst.components.deployable.min_spacing or 2

	    for k, v in pairs(ents) do
			if v ~= inst and v:IsValid() and v.entity:IsVisible() and not v.components.placer and v.parent == nil then
				if distsq( Vector3(v.Transform:GetWorldPosition()), pt) < min_spacing*min_spacing then
					return false
				end
			end
		end
		return true
	end
	return false
end

local function describe(inst)
    if inst.growtime then
        return "PLANTED"
    end
end

local function displaynamefn(inst)
    if inst.growtime then
        return STRINGS.NAMES.TEATREE_SAPLING
    end
    return STRINGS.NAMES.TEATREE_NUT
end

local function OnSave(inst, data)
    if inst.growtime then
        data.growtime = inst.growtime - GetTime()
    end
end

local function OnLoad(inst, data)
    if data and data.growtime then
        plant(inst, data.growtime)
    end
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.MEDIUM, TUNING.WINDBLOWN_SCALE_MAX.MEDIUM)

    inst.AnimState:SetBank("teatree_nut")
    inst.AnimState:SetBuild("teatree_nut")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst, "idle_water", "idle")

    inst:AddComponent("cookable")
    inst.components.cookable.product = "teatree_nut_cooked"
    inst:AddTag("plant")
    inst:AddTag("icebox_valid")
    inst:AddTag("cattoy")
    inst:AddComponent("tradable")

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_PRESERVED)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"
    inst:AddTag("show_spoilage")

    inst:AddComponent("edible")
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY
    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.antihistamine = 60
    inst.components.edible.foodtype = "SEEDS"
    inst.components.edible.foodstate = "RAW"

    inst:AddComponent("bait")

    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = describe
    
	MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
	inst:ListenForEvent("onignite", stopgrowing)
    inst:ListenForEvent("onextinguish", restartgrowing)
    MakeSmallPropagator(inst)
    inst.components.burnable:MakeDragonflyBait(3)
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("deployable")
    inst.components.deployable.test = test_ground
    inst.components.deployable.ondeploy = ondeploy

    inst.displaynamefn = displaynamefn
    
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

local function cooked()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("teatree_nut")
    inst.AnimState:SetBuild("teatree_nut")
    inst.AnimState:PlayAnimation("cooked")

    MakeInventoryFloatable(inst, "cooked_water", "cooked")

    inst:AddComponent("edible")
    inst.components.edible.foodstate = "COOKED"
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY
    inst.components.edible.healthvalue = TUNING.HEALING_SMALL
    inst.components.edible.antihistamine = 120
    inst.components.edible.foodtype = "SEEDS"

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
    
    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    
    inst:AddComponent("inventoryitem")

    return inst
end

return Prefab( "common/inventory/teatree_nut", fn, assets, prefabs),
       Prefab("common/inventory/teatree_nut_cooked", cooked, assets),
	   MakePlacer( "common/teatree_nut_placer", "teatree_nut", "teatree_nut", "idle_planted" ) 


