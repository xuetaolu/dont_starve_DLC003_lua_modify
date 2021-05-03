local assets =
{
	Asset("ANIM", "anim/topiary.zip"),

    Asset("ANIM", "anim/topiary01_build.zip"),    
    Asset("ANIM", "anim/topiary02_build.zip"),    
    Asset("ANIM", "anim/topiary03_build.zip"),    
    Asset("ANIM", "anim/topiary04_build.zip"),    
    Asset("ANIM", "anim/topiary05_build.zip"),    
    Asset("ANIM", "anim/topiary06_build.zip"),    
    Asset("ANIM", "anim/topiary07_build.zip"),    

    Asset("MINIMAP_IMAGE", "lawnornaments_1"),  
    Asset("MINIMAP_IMAGE", "lawnornaments_2"),  
    Asset("MINIMAP_IMAGE", "lawnornaments_3"),  
    Asset("MINIMAP_IMAGE", "lawnornaments_4"),  
    Asset("MINIMAP_IMAGE", "lawnornaments_5"),  
    Asset("MINIMAP_IMAGE", "lawnornaments_6"),  
    Asset("MINIMAP_IMAGE", "lawnornaments_7"),  

    Asset("INV_IMAGE", "lawnornament_1"),  
    Asset("INV_IMAGE", "lawnornament_2"),  
    Asset("INV_IMAGE", "lawnornament_3"),  
    Asset("INV_IMAGE", "lawnornament_4"),  
    Asset("INV_IMAGE", "lawnornament_5"),  
    Asset("INV_IMAGE", "lawnornament_6"),  
    Asset("INV_IMAGE", "lawnornament_7"),      
}

local prefabs = 
{
    "ash",
    "collapse_small",
}

local function onhammered(inst, worker)	
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    if not inst.components.fixable then
        inst.components.lootdropper:DropLoot()
    end    
	inst:Remove()
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
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
	inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/objects/lawnornaments/repair")
end

local function makeitem(name, frame)
    local function fn(Sim)
        local inst = CreateEntity()
        local trans = inst.entity:AddTransform()
        local anim = inst.entity:AddAnimState() 
     
        inst.entity:AddPhysics() 
        MakeObstaclePhysics(inst, .5) 

        local minimap = inst.entity:AddMiniMapEntity()
        minimap:SetIcon( "lawnornament_"..frame..".png" )


        inst.entity:AddSoundEmitter()
        inst:AddTag("structure")

        anim:SetBank("topiary")
        anim:SetBuild("topiary0".. frame .."_build")

        anim:PlayAnimation("idle",true)

        inst:AddComponent("lootdropper")
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(2)
        inst.components.workable:SetOnFinishCallback(onhammered)
        inst.components.workable:SetOnWorkCallback(onhit)
        
        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = getstatus
        
        --MakeSnowCovered(inst, .01)        
        inst.AnimState:Hide("SNOW") -- temp until anim can be fixed

        inst:ListenForEvent( "onbuilt", onbuilt)

        inst:SetPrefabNameOverride("lawnornament")

        inst:AddComponent("fixable")
        inst.components.fixable:AddRecinstructionStageData("burnt","topiary","topiary0".. frame .."_build")
        inst.components.fixable:SetPrefabName("lawnornament")

        MakeSmallBurnable(inst, nil, nil, true)
        MakeSmallPropagator(inst)

        inst:AddComponent("gridnudger")

        inst:ListenForEvent("burntup", function(inst)
            inst:Remove()
        end)        

        inst.OnSave = OnSave
        inst.OnLoad = OnLoad
        return inst
    end

    return Prefab( name, fn, assets, prefabs)
end

local function placetestfn(inst)    
    inst.AnimState:Hide("SNOW")
    return true
end

return makeitem( "lawnornament_1", "1" ),
       makeitem( "lawnornament_2", "2" ),
       makeitem( "lawnornament_3", "3" ),
       makeitem( "lawnornament_4", "4" ),
       makeitem( "lawnornament_5", "5" ),
       makeitem( "lawnornament_6", "6" ),
       makeitem( "lawnornament_7", "7" ),

       MakePlacer("common/lawnornament_1_placer", "topiary", "topiary01_build", "idle", nil, nil, true, nil, nil, nil, nil, nil, nil, placetestfn),
       MakePlacer("common/lawnornament_2_placer", "topiary", "topiary02_build", "idle", nil, nil, true, nil, nil, nil, nil, nil, nil, placetestfn),
       MakePlacer("common/lawnornament_3_placer", "topiary", "topiary03_build", "idle", nil, nil, true, nil, nil, nil, nil, nil, nil, placetestfn),
       MakePlacer("common/lawnornament_4_placer", "topiary", "topiary04_build", "idle", nil, nil, true, nil, nil, nil, nil, nil, nil, placetestfn),
       MakePlacer("common/lawnornament_5_placer", "topiary", "topiary05_build", "idle", nil, nil, true, nil, nil, nil, nil, nil, nil, placetestfn),
       MakePlacer("common/lawnornament_6_placer", "topiary", "topiary06_build", "idle", nil, nil, true, nil, nil, nil, nil, nil, nil, placetestfn),
       MakePlacer("common/lawnornament_7_placer", "topiary", "topiary07_build", "idle", nil, nil, true, nil, nil, nil, nil, nil, nil, placetestfn)

	   --MakePlacer("common/lightning_rod_placer", "lightning_rod", "lightning_rod", "idle")  