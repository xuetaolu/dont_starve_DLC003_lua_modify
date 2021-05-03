    
local assets =
{
	Asset("ANIM", "anim/sign_home.zip"),
	Asset("MINIMAP_IMAGE", "sign"),
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
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function onhit(inst, worker)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("hit")
		inst.AnimState:PushAnimation("idle")
	end
end

local function onsave(inst, data)
	if inst:HasTag("burnt") or inst:HasTag("fire") then
        data.burnt = true
    end
    if inst.debugtext then
    	data.debugtext = inst.debugtext
    end
end

local function onload(inst, data)
	if data and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
    if data and data.text then
    	if GetPlayer().prefab ~= "wilbur" then
    		inst.components.inspectable:SetDescription(data.text)
    	end
	end
	if data and data.debugtext then
		if GetPlayer().prefab ~= "wilbur" then
			inst.components.inspectable:SetDescription(data.debugtext)
		end
		inst.debugtext = data.debugtext
	end
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle")
	inst.SoundEmitter:PlaySound("dontstarve/common/craftable/sign/place")
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	   
    MakeObstaclePhysics(inst, .2)    
    
	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "sign.png" )
    
    anim:SetBank("sign_home")
    anim:SetBuild("sign_home")
    anim:PlayAnimation("idle")
    
    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper") 
    
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)
 	MakeSnowCovered(inst, .01)	

 	inst:AddTag("structure")
	MakeSmallBurnable(inst, nil, nil, true)
	MakeSmallPropagator(inst)
	inst.OnSave = onsave
	inst.OnLoad = onload

	inst:ListenForEvent( "onbuilt", onbuilt)
   
    return inst
end

return Prefab( "common/objects/homesign", fn, assets, prefabs),
		MakePlacer( "common/homesign_placer", "sign_home", "sign_home", "idle" ) 
