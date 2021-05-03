    
local assets =
{
	Asset("ANIM", "anim/buoy.zip"),
	Asset("MINIMAP_IMAGE", "buoy"),
}

local prefabs = 
{
	"collapse_small",
}

local function onhammered(inst, worker)
	if inst:HasTag("fire") and inst.components.burnable then
		inst.components.burnable:Extinguish()
	end
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal")
	inst:Remove()
end

local function onhit(inst, worker)
	inst.sg:GoToState("hit")
	--if not inst:HasTag("burnt") then
		--inst.AnimState:PlayAnimation("hit")
		--inst.AnimState:PushAnimation("idle", true)
	--end
end

local function onsave(inst, data)
	--if inst:HasTag("burnt") or inst:HasTag("fire") then
    --    data.burnt = true
    --end
end

local function onload(inst, data)
	--if data and data.burnt then
    --    inst.components.burnable.onburnt(inst)
    --end
end

local function onbuilt(inst)
	inst.sg:GoToState("place")
	--inst.AnimState:PlayAnimation("place")
	--inst.AnimState:PushAnimation("idle", true)
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	   
    MakeObstaclePhysics(inst, .2)    
    
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "buoy.png" )
    
    anim:SetBank("buoy")
    anim:SetBuild("buoy")
    anim:PlayAnimation("idle", true)

	inst.entity:AddLight()
	inst.Light:Enable(true)
	inst.Light:SetIntensity(.75)
	inst.Light:SetColour(223/255,246/255,255/255)
	inst.Light:SetFalloff( 0.5 )
	inst.Light:SetRadius( 2 )
    
    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper") 
    
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)
 	MakeSnowCovered(inst, .01)	

 	inst:AddTag("structure")
	--MakeSmallBurnable(inst, nil, nil, true)
	--MakeSmallPropagator(inst)
	inst.OnSave = onsave
	inst.OnLoad = onload

	inst:ListenForEvent( "onbuilt", onbuilt)

	inst:SetStateGraph("SGbuoy")
   
    return inst
end

return Prefab( "shipwrecked/objects/buoy", fn, assets, prefabs),
		MakePlacer( "shipwrecked/buoy_placer", "buoy", "buoy", "idle" ) 
