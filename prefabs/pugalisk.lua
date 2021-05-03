require("brains/pugalisk_headbrain")
require("brains/pugalisk_tailbrain")
require "stategraphs/SGpugalisk_head"

local pu = require ("prefabs/pugalisk_util")

local assets =
{	
    Asset("ANIM", "anim/python.zip"),
    Asset("ANIM", "anim/python_test.zip"),
    Asset("ANIM", "anim/python_segment_broken02_build.zip"),    
    Asset("ANIM", "anim/python_segment_broken_build.zip"),    
    Asset("ANIM", "anim/python_segment_build.zip"),                            
    Asset("ANIM", "anim/python_segment_tail02_build.zip"), 
    Asset("ANIM", "anim/python_segment_tail_build.zip"),     
}

local prefabs =
{
    "snake_bone",
    "monstermeat",
    "gaze_beam",
    "pugalisk_body",
    "pugalisk_skull",
}

SetSharedLootTable( 'pugalisk',
{
    {'monstermeat',             1.00},
    {'monstermeat',             1.00},
    {'monstermeat',             1.00},
})
 
local SHAKE_DIST = 40

local function redirecthealth(inst, amount, overtime, cause, ignore_invincible)

    local originalinst = inst

    if inst.startpt then
        inst = inst.startpt
    end

    if amount < 0 and( (inst.components.segmented and inst.components.segmented.vulnerablesegments == 0) or inst:HasTag("tail") or inst:HasTag("head") ) then
        print("invulnerable",cause,GetPlayer().prefab)
        if cause == GetPlayer().prefab then
            GetPlayer().components.talker:Say(GetString(GetPlayer().prefab, "ANNOUNCE_PUGALISK_INVULNERABLE"))        
        end
        inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal",nil,.25)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/hit_metal")

    elseif amount and inst.host then

        local fx = SpawnPrefab("snake_scales_fx")
        fx.Transform:SetScale(1.5,1.5,1.5)
        local pt= Vector3(originalinst.Transform:GetWorldPosition())
        fx.Transform:SetPosition(pt.x,pt.y + 2 + math.random()*2,pt.z)

        inst:PushEvent("dohitanim")
        inst.host.components.health:DoDelta(amount, overtime, cause, ignore_invincible, true)
        inst.host:PushEvent("attacked")
    end    
end


local function RetargetTailFn(inst)  

    local targetDist = TUNING.PUGALISK_TAIL_TARGET_DIST

    local notags = {"FX", "NOCLICK","INLIMBO"}
    return FindEntity(inst, targetDist, function(guy)
        return (guy:HasTag("character") or guy:HasTag("animal") or guy:HasTag("monster") and not guy:HasTag("pugalisk")) 
               and inst.components.combat:CanTarget(guy)
    end, nil, notags)
end

local function RetargetFn(inst)  

    local targetDist = TUNING.PUGALISK_TARGET_DIST

    local notags = {"FX", "NOCLICK","INLIMBO"}
    return FindEntity(inst, targetDist, function(guy)
        return (guy:HasTag("character") or guy:HasTag("animal") or guy:HasTag("monster") and not guy:HasTag("pugalisk")) 
               and inst.components.combat:CanTarget(guy)
    end, nil, notags)

end

local function OnHit(inst, attacker)    
    local host = inst
    if inst.host then
        host = inst.host      
    end    

    if attacker and (not inst.target or inst.target == GetPlayer()) then
        host.target = attacker 
        host.components.combat:SetTarget(attacker)
    end
    
end

local function segmentfn(Sim)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()

    local s = 1.5
    trans:SetScale(s,s,s)
    inst.Transform:SetEightFaced()

    inst.AnimState:SetFinalOffset( -10 )
    
    anim:SetBank("giant_snake")
    anim:SetBuild("python_test")
    anim:PlayAnimation("test_segment")

    inst:AddTag("pugalisk")
    inst:AddTag("groundpoundimmune")
    inst:AddTag("noteleport")

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(0)
    inst.components.combat.hiteffectsymbol = "test_segments"-- "wormmovefx"
    inst.components.combat.onhitfn = OnHit    

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(9999)
    inst.components.health.destroytime = 5
    inst.components.health.redirect = redirecthealth
    --inst.components.health:StartRegen(1, 2)
--[[
    inst:ListenForEvent("death", function(inst, data)
        onhostdeath(inst.playerpickerproxy.host)
    end)
]]
    inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = "pugalisk"  
    inst.name = STRINGS.NAMES.PUGALISK  

    inst:AddComponent("lootdropper")
    inst.components.lootdropper.lootdropangle = 360
    inst.components.lootdropper.speed = 3 + (math.random()*3)

    inst.AnimState:Hide("broken01")
    inst.AnimState:Hide("broken02")

    inst.persists = false

    return inst
end

--======================================================================

local function segment_deathfn(segment)

    segment.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/pugalisk/explode")

    local pt= Vector3(segment.Transform:GetWorldPosition())

    local bone = segment.components.lootdropper:SpawnLootPrefab("snake_bone",pt)
       
    if math.random()<0.6 then
        local bone = segment.components.lootdropper:SpawnLootPrefab("boneshard",pt)
    end        
    if math.random()<0.2 then
        local bone = segment.components.lootdropper:SpawnLootPrefab("monstermeat",pt)
    end
    if math.random()<0.005 then
        local bone = segment.components.lootdropper:SpawnLootPrefab("redgem", pt)
    end
    if math.random()<0.005 then
        local bone = segment.components.lootdropper:SpawnLootPrefab("bluegem", pt)
    end
    if math.random()<0.05 then
        local bone = segment.components.lootdropper:SpawnLootPrefab("spoiled_fish", pt)
    end
    
    local fx = SpawnPrefab("snake_scales_fx")    
    fx.Transform:SetScale(1.5,1.5,1.5)
    fx.Transform:SetPosition(pt.x,pt.y + 2 + math.random()*2,pt.z)
end

local function bodyfn(Sim)

    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()

    inst.Transform:SetSixFaced()
    
    local s = 1.5
    trans:SetScale(s,s,s)
    
    MakeObstaclePhysics(inst, 1)

    anim:SetBank("giant_snake") 
    anim:SetBuild("python_test")
    anim:PlayAnimation("dirt_static")

    anim:Hide("broken01")
    anim:Hide("broken02")

    inst.AnimState:SetFinalOffset( 0 )

    inst.name = STRINGS.NAMES.PUGALISK
    inst.invulnerable = true

    ------------------------------------------

    inst:AddTag("epic")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("pugalisk")
    inst:AddTag("scarytoprey")
    inst:AddTag("largecreature")
    inst:AddTag("groundpoundimmune")
    inst:AddTag("noteleport")

    ------------------
    
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(9999)
    inst.components.health.destroytime = 5
    inst.components.health.redirect = redirecthealth


    inst:ListenForEvent("death", function(inst, data)
        
    end)

    ------------------

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.PUGALISK_DAMAGE)
    inst.components.combat.playerdamagepercent = 0.75

    inst.components.combat.hiteffectsymbol = "hit_target"
    inst.components.combat.onhitfn = OnHit
    
    ------------------------------------------

    inst:AddComponent("lootdropper")

    ------------------------------------------

    inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = "pugalisk"
    ------------------------------------------

    inst:AddComponent("knownlocations")

    ------------------------------------------

    inst:AddComponent("groundpounder")
    inst.components.groundpounder.destroyer = true
    inst.components.groundpounder.damageRings = 2
    inst.components.groundpounder.destructionRings = 1
    inst.components.groundpounder.numRings = 2
    inst.components.groundpounder.groundpounddamagemult = 30/TUNING.PUGALISK_DAMAGE
    inst.components.groundpounder.groundpoundfx= "groundpound_nosound_fx"

    ------------------------------------------

    inst:AddComponent("segmented")
    inst.components.segmented.segment_deathfn = segment_deathfn

    inst:ListenForEvent("bodycomplete", function() 
                if inst.exitpt then
                    inst.exitpt.AnimState:SetBank("giant_snake")
                    inst.exitpt.AnimState:SetBuild("python_test")
                    inst.exitpt.AnimState:PlayAnimation("dirt_static")  

                    local player = GetClosestInstWithTag("player", inst, SHAKE_DIST)
                    if player then
                        player.components.playercontroller:ShakeCamera(inst, "VERTICAL", 0.5, 0.03, 2, SHAKE_DIST)
                    end

                    --TheCamera:Shake("VERTICAL", 0.5, 0.05, 0.1)
                    inst.exitpt.Physics:SetActive(true)
                    inst.exitpt.components.groundpounder:GroundPound()   

                    inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/pugalisk/emerge","emerge")
                    inst.SoundEmitter:SetParameter( "emerge", "start", math.random() )

                    if inst.host then   
                        inst.host:PushEvent("bodycomplete",{ pos=Vector3(inst.exitpt.Transform:GetWorldPosition()), angle = inst.angle })                            
                    end                                     
                end
            end) 

    inst:ListenForEvent("bodyfinished", function() 
                if inst.host then  
                    inst.host:PushEvent("bodyfinished",{ body=inst })                                                
                end                      
                inst:Remove()               
            end)

    inst.persists = false

    inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/pugalisk/movement_LP", "speed")
    inst.SoundEmitter:SetParameter("speed", "intensity", 0)

    ------------------------------------------

    return inst
end

--===========================================================

local function tailfn(Sim)

    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()

    inst.Transform:SetSixFaced()
    
    local s = 1.5
    trans:SetScale(s,s,s)
    
    MakeObstaclePhysics(inst, 1)

    anim:SetBank("giant_snake")
    anim:SetBuild("python_test") 
    anim:PlayAnimation("tail_idle_loop", true)

    anim:Hide("broken01")
    anim:Hide("broken02")

    inst.AnimState:SetFinalOffset( 0 )

    inst.name = STRINGS.NAMES.PUGALISK
    inst.invulnerable = true

    ------------------------------------------

    inst:AddTag("tail")
    inst:AddTag("epic")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("pugalisk")
    inst:AddTag("scarytoprey")
    inst:AddTag("largecreature")
    inst:AddTag("groundpoundimmune")
    inst:AddTag("noteleport")

    ------------------------------------------
    
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(9999)
    inst.components.health.destroytime = 5
    inst.components.health.redirect = redirecthealth

    ------------------------------------------  

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.PUGALISK_DAMAGE/2)
    inst.components.combat.playerdamagepercent = 0.5
    inst.components.combat:SetRange(TUNING.PUGALISK_MELEE_RANGE, TUNING.PUGALISK_MELEE_RANGE)
    inst.components.combat.hiteffectsymbol = "hit_target" -- "wormmovefx"
    inst.components.combat:SetAttackPeriod(TUNING.PUGALISK_ATTACK_PERIOD/2)
    inst.components.combat:SetRetargetFunction(0.5, RetargetTailFn)
    inst.components.combat.onhitfn = OnHit

    ------------------------------------------

    inst:AddComponent("locomotor")

    ------------------------------------------

    inst:AddComponent("lootdropper")

    ------------------------------------------

    inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = "pugalisk"

    ------------------------------------------

    inst.persists = false

    ------------------------------------------
    inst:SetStateGraph("SGpugalisk_head")

    local brain = require "brains/pugalisk_tailbrain"
    inst:SetBrain(brain)    

    return inst
end

--===========================================================

local function keeptargetfn(inst,target)    
    return target
          and target.components.combat
          and target.components.health
          and not target.components.health:IsDead()
end

local function CalcSanityAura(inst, observer)
    return -TUNING.SANITYAURA_LARGE
end

local function onhostdeath(inst)

    TheCamera:Shake("FULL",3, 0.05, .2)
    local mb = inst.components.multibody
    for i,body in ipairs(mb.bodies)do
        body.components.health:Kill()
    end
    if mb.tail then
        mb.tail.components.health:Kill()
    end 

    if inst.home and inst.home.reactivate then
        inst.home.reactivate(inst.home)
    end    
    mb:Kill()

    local ent = TheSim:FindFirstEntityWithTag("pugalisk_trap_door")
    if ent and ent.reactivate then
        ent.reactivate(ent)
    end
end

local function OnSave(inst, data)
    
    local refs = {} 
    if inst.home then
        data.home = inst.home.GUID
        table.insert(refs,inst.home.GUID)
    end
    return refs
end

local function OnLoadPostPass(inst, newents, data)
    if data and data.home then
        local home = newents[data.home].entity
        if home then
            print("FOUND HOME, RELOADING IT")
            inst.home = home
        end
    end
end

local function fn(Sim)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()

    inst.Transform:SetSixFaced()

    MakeObstaclePhysics(inst, 1)

    local s = 1.5
    trans:SetScale(s,s,s)

    anim:SetBank("giant_snake")
    anim:SetBuild("python_test") --"python"
    anim:PushAnimation("head_idle_loop", true)

    inst.AnimState:SetFinalOffset( 0 )

    ------------------------------------------

    inst:AddTag("epic")
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("pugalisk")
    inst:AddTag("scarytoprey")
    inst:AddTag("largecreature")
    inst:AddTag("groundpoundimmune")    
    inst:AddTag("head")    
    inst:AddTag("noflinch")
    inst:AddTag("noteleport")

    ------------------------------------------  

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aurafn = CalcSanityAura

    ------------------------------------------   

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(TUNING.PUGALISK_DAMAGE)
    inst.components.combat.playerdamagepercent = 0.75
    inst.components.combat:SetRange(TUNING.BEARGER_ATTACK_RANGE, TUNING.PUGALISK_MELEE_RANGE)
    inst.components.combat.hiteffectsymbol = "hit_target" -- "wormmovefx"
    inst.components.combat:SetAttackPeriod(TUNING.PUGALISK_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(0.5, RetargetFn)
    inst.components.combat.onhitfn = OnHit

    ------------------------------------------

    inst:AddComponent("lootdropper")
    
    ------------------------------------------    
--[[    
    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(4)
    ]]
    ------------------------------------------       

    inst:AddComponent("inspectable")
    inst.components.inspectable.nameoverride = "pugalisk"
    inst.name = STRINGS.NAMES.PUGALISK
    
    ------------------------------------------

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.PUGALISK_HEALTH)
    inst.components.health.destroytime = 5
    inst.components.health:StartRegen(1, 2)
    inst.components.health.redirect = redirecthealth

    ------------------------------------------

    inst:AddComponent("knownlocations")
    
    ------------------------------------------
    
    inst:AddComponent("locomotor")

    ------------------------------------------

    inst:AddComponent("groundpounder")
    inst.components.groundpounder.destroyer = true
    inst.components.groundpounder.damageRings = 2
    inst.components.groundpounder.destructionRings = 1
    inst.components.groundpounder.numRings = 2
    inst.components.groundpounder.groundpounddamagemult = 30/TUNING.PUGALISK_DAMAGE
    inst.components.groundpounder.groundpoundfx= "groundpound_nosound_fx"

    ------------------------------------------
    
    inst:AddComponent("multibody")    
    inst.components.multibody:Setup(5,"pugalisk_body")   
    
    ------------------------------------------    

    inst:ListenForEvent("healthdelta", function(inst, data)
        print("TOOK DAMAGE",inst.components.health.currenthealth)
    end)

    inst:ListenForEvent("bodycomplete", function(inst, data) 
        local pt = pu.findsafelocation( data.pos , data.angle/DEGREES )
        inst.Transform:SetPosition(pt.x,0,pt.z)
        inst:DoTaskInTime(0.75, function() 

            local player = GetClosestInstWithTag("player", inst, SHAKE_DIST)
            if player then                                   
                player.components.playercontroller:ShakeCamera(inst, "VERTICAL", 0.3, 0.03, 1, SHAKE_DIST)
            end            
            inst.components.groundpounder:GroundPound()
            
            inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/pugalisk/emerge","emerge")
            inst.SoundEmitter:SetParameter( "emerge", "start", math.random() )
            
            pu.DetermineAction(inst)
        end)
    end)     
    
    inst:ListenForEvent("bodyfinished", function(inst, data) 
            inst.components.multibody:RemoveBody(data.body)
        end)

    inst:ListenForEvent("death", function(inst, data)        
        onhostdeath(inst)        
    end)

    inst.spawntask = inst:DoTaskInTime(0,function() 
            inst.spawned = true
        end)
    
    inst:SetStateGraph("SGpugalisk_head")

    local brain = require "brains/pugalisk_headbrain"
    inst:SetBrain(brain)

    inst.OnSave = OnSave 
    --inst.OnLoad = onload
    inst.OnLoadPostPass = OnLoadPostPass

    return inst
end

--===========================================================

local function onfinishcallback(inst, worker)

    inst.MiniMapEntity:SetEnabled(false)
    inst:RemoveComponent("workable")
    inst.components.hole.canbury = true

    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())

    if worker then
        -- figure out which side to drop the loot
        local pt = Vector3(inst.Transform:GetWorldPosition())
        local hispos = Vector3(worker.Transform:GetWorldPosition())

        local he_right = ((hispos - pt):Dot(TheCamera:GetRightVec()) > 0)
        
        if he_right then
            inst.components.lootdropper:DropLoot(pt - (TheCamera:GetRightVec()*(math.random()+1)))           
        else
            inst.components.lootdropper:DropLoot(pt + (TheCamera:GetRightVec()*(math.random()+1)))            
        end        
        
        inst:Remove()
    end 
end


local function corpsefn(Sim)

    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "xspot.png" )

    inst.Transform:SetSixFaced()
    
    local s = 1.5
    trans:SetScale(s,s,s)
    
    MakeObstaclePhysics(inst, 1)

    anim:SetBank("giant_snake")
    anim:SetBuild("python_test") 
    anim:PlayAnimation("death_idle", true)

    inst:AddComponent("lootdropper")

    ------------------------------------------

    inst:AddComponent("hole")

    inst:AddComponent("inspectable")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetWorkLeft(1)
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"pugalisk_skull"})    
    inst.components.workable:SetOnFinishCallback(onfinishcallback)

    return inst
end

return  Prefab( "common/monsters/pugalisk", fn, assets, prefabs),
        Prefab( "common/monsters/pugalisk_body", bodyfn, assets, prefabs),
        Prefab( "common/monsters/pugalisk_tail", tailfn, assets, prefabs),
        Prefab( "common/monsters/pugalisk_segment", segmentfn, assets, prefabs),
        Prefab( "common/monsters/pugalisk_corpse", corpsefn, assets, prefabs)