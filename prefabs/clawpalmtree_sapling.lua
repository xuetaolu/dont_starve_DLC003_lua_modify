require "prefabutil"
local assets =
{
Asset("ANIM", "anim/clawling.zip"),
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
	local tree = SpawnPrefab("clawpalmtree") 
    if tree then 
		tree.Transform:SetPosition(inst.Transform:GetWorldPosition() ) 
        tree:growfromseed()--PushEvent("growfromseed")
        inst:Remove()
	end
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
	local tiletype = GetGroundTypeAtPosition(pt)
	local ground_OK = tiletype ~= GROUND.INTERIOR and tiletype ~= GROUND.GASJUNGLE and 
                      tiletype ~= GROUND.COBBLEROAD and tiletype ~= GROUND.FOUNDATION and 
                      tiletype ~= GROUND.ROCKY and tiletype ~= GROUND.ROAD and tiletype ~= GROUND.IMPASSABLE and
						tiletype ~= GROUND.UNDERROCK and tiletype ~= GROUND.WOODFLOOR and 
						tiletype ~= GROUND.CARPET and tiletype ~= GROUND.CHECKER and tiletype < GROUND.UNDERGROUND
	
	if ground_OK then
	    local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 4, nil, notags) -- or we could include a flag to the search?
		local min_spacing = 2

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

local function placeTestFn(inst, pt)
  
    return test_ground(inst, pt)
end

local function describe(inst)
    if inst.growtime then
        return "PLANTED"
    end
end

local function displaynamefn(inst)
    return STRINGS.NAMES.CLAWPALMTREE_SAPLING
end

local function OnSave(inst, data)
    if inst.growtime then
        data.growtime = inst.growtime - GetTime()
    end
end

local function OnLoad(inst, data)
    if data and data.growtime then
        inst.growtask = inst:DoTaskInTime(data.growtime, growtree)        
    end
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.MEDIUM, TUNING.WINDBLOWN_SCALE_MAX.MEDIUM)

    inst.AnimState:SetBank("clawling")
    inst.AnimState:SetBuild("clawling")
    inst.AnimState:PlayAnimation("idle_planted")

    MakeInventoryFloatable(inst, "idle_water", "idle")

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = describe

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    
    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    inst:ListenForEvent("onignite", stopgrowing)
    inst:ListenForEvent("onextinguish", restartgrowing)
    MakeSmallPropagator(inst)

    inst.displaynamefn = displaynamefn

    RemovePhysicsColliders(inst)
    RemoveBlowInHurricane(inst)

    inst.SoundEmitter:PlaySound("dontstarve/wilson/plant_tree")
    local growtime = GetRandomWithVariance(TUNING.ACORN_GROWTIME.base, TUNING.ACORN_GROWTIME.random)
    inst.growtime = GetTime() + growtime
    inst.growtask = inst:DoTaskInTime(growtime, growtree)

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    if GetPlayer():HasTag("plantkin") then
        if GetPlayer().growplantfn then
            GetPlayer().growplantfn(GetPlayer())
        end
    end

    return inst
end


return Prefab( "common/inventory/clawpalmtree_sapling", fn, assets, prefabs),
	   MakePlacer( "common/clawpalmtree_sapling_placer", "clawling", "clawling", "idle_planted",nil, nil, nil, nil, nil, nil, nil, nil, nil, placeTestFn ) 


