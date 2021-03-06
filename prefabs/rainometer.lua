require "prefabutil"

local function onhammered(inst, worker)
	if inst:HasTag("fire") and inst.components.burnable then
		inst.components.burnable:Extinguish()
	end
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function CheckRain(inst)
	if not inst:HasTag("burnt") then
	    if not inst.task then
		    inst.task = inst:DoPeriodicTask(1, CheckRain)
		end
		if inst:HasTag("flooded") then 
			inst.AnimState:SetPercent("meter", math.random())
		else 
			inst.AnimState:SetPercent("meter", GetSeasonManager():GetPOP())
		end 
	end
end

local function onhit(inst, worker)
    if inst.task then
        inst.task:Cancel()
        inst.task = nil
    end
	inst.AnimState:PlayAnimation("hit")
	--the global animover handler will restart the check task
end


local assets = 
{
	Asset("ANIM", "anim/rain_meter.zip"),
}

local prefabs =
{
	"collapse_small",
}

local function onbuilt(inst)
    if inst.task then
        inst.task:Cancel()
        inst.task = nil
    end
	inst.AnimState:PlayAnimation("place")
	inst.SoundEmitter:PlaySound("dontstarve/common/craftable/rain_meter")
	--the global animover handler will restart the check task
end

local function makeburnt(inst)
	if inst.task then
		inst.task:Cancel()
		inst.task = nil
	end
end

local function onsave(inst, data)
	if inst:HasTag("burnt") or inst:HasTag("fire") then
        data.burnt = true
    end
end

local function onload(inst, data)
	if data and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "rainometer.png" )
    
	MakeObstaclePhysics(inst, .4)
    
	anim:SetBank("rain_meter")
	anim:SetBuild("rain_meter")
	anim:SetPercent("meter", 0)

	inst:AddComponent("inspectable")
	
	inst:AddComponent("lootdropper")
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)		
	MakeSnowCovered(inst, .01)
	inst:ListenForEvent("onbuilt", onbuilt)
	inst:ListenForEvent("animover", CheckRain)

	inst:AddComponent("floodable")
	inst.components.floodable.floodEffect = "shock_machines_fx"
	inst.components.floodable.floodSound = "dontstarve_DLC002/creatures/jellyfish/electric_land"

	CheckRain(inst)

	inst:AddTag("structure")
	MakeMediumBurnable(inst, nil, nil, true)
	MakeSmallPropagator(inst)
	inst.OnSave = onsave
	inst.OnLoad = onload
	inst:ListenForEvent("burntup", makeburnt)
	
	return inst
end
return Prefab( "common/objects/rainometer", fn, assets, prefabs),
	   MakePlacer("common/rainometer_placer", "rain_meter", "rain_meter", "idle" ) 


