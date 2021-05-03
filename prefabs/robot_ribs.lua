require "brains/ancientrobotbrain"
require "stategraphs/SGAncientRobot"

local UPDATETIME = 5

local assets=
{
	Asset("ANIM", "anim/metal_spider.zip"),
    Asset("MINIMAP_IMAGE", "metal_spider"),    
}

local prefabs =
{
    "iron",
    "sparks_fx",
    "sparks_green_fx",
}

SetSharedLootTable( 'anchientrobot',
{
    {'iron',            1.00},
    {'iron',            1.00},
    {'iron',            1.00},
    {'iron',            0.33},
    {'iron',            0.33},
    {'iron',            0.33},
    {'gears',           1.00},
    {'gears',           0.33},
})

local function Retarget(inst)
    return FindEntity(inst, TUNING.ROBOT_TARGET_DIST, function(guy)
            return not guy:HasTag("ancient_robot") and 
					inst.components.combat:CanTarget(guy) and 
					not guy:HasTag("wall")
        end)   
end

local function KeepTarget(inst, target)
    return true
end

local function periodicupdate(inst)
    if inst.lifetime and inst.lifetime > 0 then
        inst.lifetime = inst.lifetime - UPDATETIME
    else       
        inst.wantstodeactivate = true
        inst.updatetask:Cancel()
        inst.updatetask = nil
    end
end

local function OnLightning(inst, data)
    inst.lifetime = 300
    if inst:HasTag("dormant") then
        inst.wantstodeactivate = nil
        inst:RemoveTag("dormant")         
        inst:PushEvent("shock")        
        if not inst.updatetask then
            inst.updatetask = inst:DoPeriodicTask(UPDATETIME, periodicupdate)
        end
    end
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)

    local fx = SpawnPrefab("sparks_green_fx")
    local x, y, z= inst.Transform:GetWorldPosition()
    fx.Transform:SetPosition(x,y+1,z)     
end

local function GetStatus(inst)

end

local function OnSave(inst,data)
    local refs = {}
    if inst.hits then
        data.hits = inst.hits
    end
    if inst:HasTag("dormant") then
        data.dormant = true
    end
    if inst:HasTag("mossy") then
        data.mossy = true
    end
    if inst.lifetime then
        data.lifetime = inst.lifetime
    end
    if inst.spawned then
        data.spawned = true
    end
    if refs and #refs >0 then
        return refs
    end
end

local function OnLoad(inst,data)
    if data then
        if data.hits then
            inst.hits = data.hits        
        end
        if data.dormant then
            inst:AddTag("dormant")
        end
        if data.mossy then
            inst:AddTag("mossy")
        end
        if data.spawned then
            inst.spawned = true
        end
        if data.lifetime then
            inst.lifetime = data.lifetime            
            inst.updatetask = inst:DoPeriodicTask(UPDATETIME, periodicupdate)
        end
    end
    if inst:HasTag("dormant") then
        inst.sg:GoToState("idle_dormant")
    end
end

local function OnLoadPostPass(inst,data)
    if inst.spawned then
        if inst.spawntask then
            inst.spawntask:Cancel()
            inst.spawntask = nil            
        end
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 6, 2 )
    --  inst.Transform:SetSixFaced()
    inst.Transform:SetFourFaced()

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("metal_spider.png")


    --  MakeCharacterPhysics(inst, 100, 2)
    MakeObstaclePhysics(inst, 2)

    inst:AddTag("lightningrod")

    inst:AddTag("laser_immune")    
    inst:AddTag("ancient_robot")
    inst:AddTag("mech")
    inst:AddTag("monster")

    anim:SetBank("metal_spider")
    anim:SetBuild("metal_spider")    
    anim:PlayAnimation("idle", true)
    
    --  inst:AddTag("largecreature")

    inst:AddComponent("timer")
    
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "body01"
    inst.components.combat:SetDefaultDamage(TUNING.ROBOT_RIBS_DAMAGE)
    inst.components.combat:SetRetargetFunction(1, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
     
    --  inst:AddComponent("health")
    --  inst.components.health:SetMaxHealth(TUNING.ROBOT_RIBS_HEALTH)
    --  inst.components.health.destroytime = 5    
    --  inst.components.health:StartRegen(1000, 5)

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnWorkCallback(
        function(inst, worker, workleft)
            OnAttacked(inst, {attacker=worker})
            inst.components.workable:SetWorkLeft(1)     
            inst:PushEvent("attacked")      
        end)    

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('anchientrobot')    
    
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus
    
    inst:AddComponent("knownlocations")
    
    --  inst:ListenForEvent("attacked", OnAttacked)
    inst.lightningpriority = 1
    inst:ListenForEvent("lightningstrike", OnLightning)
    
    --  MakeLargeFreezableCharacter(inst, "beefalo_body")

    inst.entity:AddLight()
    inst.Light:SetIntensity(.6)
    inst.Light:SetRadius(5)
    inst.Light:SetFalloff(3)
    inst.Light:SetColour(1, 0, 0)
    inst.Light:Enable(false)
    
    inst.periodicupdate = periodicupdate
    inst.UPDATETIME = UPDATETIME
    inst.hits = 0
    
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.OnLoadPostPass = OnLoadPostPass

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 2
    inst.components.locomotor.runspeed = 2
    
    local brain = require "brains/ancientrobotbrain"
    inst:SetBrain(brain)
    inst:SetStateGraph("SGAncientRobot")

    inst.spawntask = inst:DoTaskInTime(0,function()         
            inst:AddTag("mossy")
            inst:AddTag("dormant")            
            inst.sg:GoToState("idle_dormant")
            inst.spawned = true
            --inst:PushEvent("deactivate") 
        end)
    return inst
end

return Prefab( "forest/animals/ancient_robot_ribs_OLD", fn, assets, prefabs) 
