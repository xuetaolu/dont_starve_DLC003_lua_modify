local assets =
{
	Asset("ANIM", "anim/python_trap_door.zip"),
	
  --  Asset("MINIMAP_IMAGE", "pig_ruins_pillar"),        
}

local prefabs =
{
   
}

local STATES = {
   CLOSED = 1,
   OPENING = 2,
   OPEN = 3,
   CLOSNG = 4,
}

local function setart(inst)
    if inst.state == STATES.CLOSED then
        inst.AnimState:PlayAnimation("closed",true)
    elseif inst.state == STATES.OPENING then
        inst.AnimState:PlayAnimation("opening")
    elseif inst.state == STATES.OPEN then
        inst.AnimState:PlayAnimation("open",true)
    elseif inst.state == STATES.CLOSNG then
        inst.AnimState:PlayAnimation("closing")
    end
end

local function actuallyspawnpugalisk(inst)
    local x,y,z = inst.Transform:GetWorldPosition()
    local pug = SpawnPrefab("pugalisk")
    pug.Transform:SetPosition(x,y,z)
    pug.home = TheSim:FindFirstEntityWithTag("pugalisk_fountain")
    pug.sg:GoToState("emerge_taunt")
    pug.wantstotaunt = false   
    inst.doingpugaliskspawn = nil
end

local function spawnpugalisk(inst)
    inst.doingpugaliskspawn = true
    local ent = TheSim:FindFirstEntityWithTag("pugalisk")
    if not ent then
        inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/pugalisk/entrance")             
        
        inst.task, inst.taskinfo = inst:ResumeTask(2,function() 
            actuallyspawnpugalisk(inst)
        end)
    end
end

local function activate(inst, fountain)

    if GetWorld().getworldgenoptions(GetWorld())["pugalisk"] and GetWorld().getworldgenoptions(GetWorld())["pugalisk"] == "never" then
        return
    end    

    if inst.state == STATES.CLOSED then        
        inst.fountain = fountain
        inst.state = STATES.OPENING
        inst.AnimState:PlayAnimation("opening")
        inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/pugalisk/trap_door")        
    
        TheCamera:Shake("FULL", 1, 0.02, 0.2, 40)     
    end
end

local function reactivate(inst)
    if inst.state == STATES.OPEN then
        inst.state = STATES.CLOSING
        inst.AnimState:PlayAnimation("closing")
    end
end

local function onsave(inst, data)    
    local references = {}
    data.rotation = inst.Transform:GetRotation()
    
    if inst.doingpugaliskspawn then
        data.doingpugaliskspawn = true
    end
    if inst.state then
        data.state = inst.state
    end
--[[
    if inst.fountain then
        data.fountain = inst.fountain.GUID
        table.insert(references,inst.fountain.GUID)
    end
]]
    return references
end

local function onload(inst, data)
    if data then
        if data.rotation then
            inst.Transform:SetRotation(data.rotation)
        end    
        if data.state then
            inst.state = data.state
        end
        if data.doingpugaliskspawn then
           spawnpugalisk(inst)
        end
    end
    setart(inst)
end
--[[
local function loadpostpass(inst,ents, data)
    if data.fountain then
        inst.fountain = ents[data.fountain].entity
    end
end
]]
local function fn(Sim)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()

    inst:AddTag("pugalisk_trap_door")

    anim:SetLayer( LAYER_BACKGROUND )
    anim:SetSortOrder( 3 )

    anim:SetBuild("python_trap_door")
    anim:SetBank("python_trap_door")
    anim:PlayAnimation("closed",true)

    inst.OnSave = onsave 
    inst.OnLoad = onload
 --   inst.LoadPostPass = loadpostpass

    inst:AddComponent("inspectable")

    inst.activate = activate
    inst.reactivate = reactivate

    inst.entity:AddSoundEmitter()
    inst.state = STATES.CLOSED


    inst:ListenForEvent("animover", function(inst) 
            if inst.state == STATES.OPENING then
                inst.state = STATES.OPEN
                inst.AnimState:PlayAnimation("open", true)

                inst.SoundEmitter:KillSound( "quake" )                  
                spawnpugalisk(inst)

            elseif inst.state == STATES.CLOSING then
                inst.state = STATES.CLOSED 
                inst.AnimState:PlayAnimation("closed",true)
            end
        end)

    return inst
end

return Prefab("pugalisk_trap_door", fn, assets, prefabs)

