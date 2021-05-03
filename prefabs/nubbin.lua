require "prefabutil"
local assets =
{
Asset("ANIM", "anim/nubbin.zip"),
}

local prefabs =
{
    "spoiled_food"
}

local function growcoral(inst)
	inst.growtask:Cancel()
    inst.growtask = nil
    inst.growtime = nil
	local tree = SpawnPrefab("coralreef")
	tree.Transform:SetPosition(inst.Transform:GetWorldPosition() )
    tree:growfromseed()
    inst:Remove()
end

local function ondeploy (inst, pt)
    local coral = SpawnPrefab("coralreef")
    coral.components.growable:SetStage(1)
    coral.Transform:SetPosition(pt:Get() )
    coral.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/splash_medium")
    inst:Remove()
end

local function stopgrowing(inst)
    if inst.growtask then
        inst.growtask:Cancel()
        inst.growtask = nil
    end
    inst.growtime = nil
end

local notags = {'NOBLOCK', 'player', 'FX'}
local function test_ground(inst, pt)
	local tiletype = GetGroundTypeAtPosition(pt)
    local ground_OK = GetWorld().Map:IsBuildableWater(tiletype)

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
        return STRINGS.NAMES.NUBBIN
    end
    return STRINGS.NAMES.NUBBIN
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

    inst.AnimState:SetBank("nubbin")
    inst.AnimState:SetBuild("nubbin")
    inst.AnimState:PlayAnimation("idle", true)

    MakeInventoryFloatable(inst, "idle_water", "idle")

    inst:AddTag("icebox_valid")
    inst:AddTag("cattoy")
    inst:AddComponent("tradable")

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.PERISH_PRESERVED)
    inst.components.perishable:StartPerishing()
    inst.components.perishable.onperishreplacement = "spoiled_food"
    inst:AddTag("show_spoilage")

    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = describe

    MakeSmallPropagator(inst)

    inst:AddComponent("inventoryitem")

    inst:AddComponent("deployable")
    inst.components.deployable.test = test_ground
    inst.components.deployable.ondeploy = ondeploy
    inst.components.deployable.min_spacing = 250
    inst.components.deployable.deploydistance = 4

    inst.displaynamefn = displaynamefn

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end


return Prefab( "common/inventory/nubbin", fn, assets, prefabs),
	   MakePlacer( "common/nubbin_placer", "coral_rock", "coral_rock", "low1" )
