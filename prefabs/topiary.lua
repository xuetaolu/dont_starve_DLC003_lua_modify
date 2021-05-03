local assets =
{
	Asset("ANIM", "anim/topiary.zip"),
    Asset("ANIM", "anim/topiary_pigman_build.zip"),
    Asset("ANIM", "anim/topiary_werepig_build.zip"),
    Asset("ANIM", "anim/topiary_beefalo_build.zip"),
    Asset("ANIM", "anim/topiary_pigking_build.zip"),
    Asset("MINIMAP_IMAGE", "topiary_1"),
    Asset("MINIMAP_IMAGE", "topiary_2"),
    Asset("MINIMAP_IMAGE", "topiary_3"),
    Asset("MINIMAP_IMAGE", "topiary_4"),
}

local prefabs = 
{
    "ash",
    "collapse_small",
}
    

local function onhammered(inst, worker)
    --inst.components.lootdropper:DropLoot()
    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    if not inst.components.fixable then
        inst.components.lootdropper:DropLoot()
    end    
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
    inst:Remove()
end

local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("hit")
	inst.AnimState:PushAnimation("idle", false)
end

local function OnSave(inst, data)

end

local function OnLoad(inst, data)

end

local function getstatus(inst)

end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle")
end

local function makeitem(name, build, frame)
    local function fn(Sim)
        local inst = CreateEntity()
        local trans = inst.entity:AddTransform()
        local anim = inst.entity:AddAnimState() 

        inst.entity:AddPhysics() 
        MakeObstaclePhysics(inst, .25)         
     
        local minimap = inst.entity:AddMiniMapEntity()
        minimap:SetIcon( "topiary_".. frame ..".png" )

        inst.entity:AddSoundEmitter()
        inst:AddTag("structure")

        anim:SetBank("topiary")
        anim:SetBuild(build)

        anim:PlayAnimation("idle",true)

        inst:AddComponent("lootdropper")

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(4)
        inst.components.workable:SetOnFinishCallback(onhammered)
        inst.components.workable:SetOnWorkCallback(onhit)
        
        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = getstatus
        
        MakeSnowCovered(inst, .01)
        --inst:ListenForEvent( "onbuilt", onbuilt)

        inst:AddComponent("fixable")
        inst.components.fixable:AddRecinstructionStageData("burnt","topiary",build)


        inst:SetPrefabNameOverride("topiary")

        inst.OnSave = OnSave
        inst.OnLoad = OnLoad
        return inst
    end

    return Prefab( name, fn, assets, prefabs)
end

return makeitem( "topiary_1", "topiary_pigman_build", "1" ),
       makeitem( "topiary_2", "topiary_werepig_build", "2" ),
       makeitem( "topiary_3", "topiary_beefalo_build", "3" ),
       makeitem( "topiary_4", "topiary_pigking_build", "4" )     

	   --MakePlacer("common/lightning_rod_placer", "lightning_rod", "lightning_rod", "idle")  
