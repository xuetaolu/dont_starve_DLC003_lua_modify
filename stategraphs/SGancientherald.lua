require("stategraphs/commonstates")


local function startaura(inst)
    inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_attack_LP", "angry")
end

local function stopaura(inst)
    inst.SoundEmitter:KillSound("angry")
end


local function setfires(x,y,z, rad)
    for i, v in ipairs(TheSim:FindEntities(x, 0, z, rad, nil, { "laser", "DECOR", "INLIMBO" })) do 
        if v.components.burnable then
            v.components.burnable:Ignite()
        end
    end
end

local function DoDamage(inst, rad)
    local targets = {}
    local x, y, z = inst.Transform:GetWorldPosition()
  
    setfires(x,y,z, rad)
    for i, v in ipairs(TheSim:FindEntities(x, 0, z, rad, nil, { "laser", "DECOR", "INLIMBO" })) do  --  { "_combat", "pickable", "campfire", "CHOP_workable", "HAMMER_workable", "MINE_workable", "DIG_workable" }
        if not targets[v] and v:IsValid() and not v:IsInLimbo() and not (v.components.health ~= nil and v.components.health:IsDead()) and not v:HasTag("laser_immune") then
            local vradius = 0
            if v.Physics then
                vradius = v.Physics:GetRadius()
            end

            local range = rad + vradius
            if v:GetDistanceSqToPoint(Vector3(x, y, z)) < range * range then
                local isworkable = false
                if v.components.workable ~= nil then
                    local work_action = v.components.workable:GetWorkAction()
                    --V2C: nil action for campfires
                    isworkable =
                        (   work_action == nil and v:HasTag("campfire")) or
                        
                            (   work_action == ACTIONS.CHOP or
                                work_action == ACTIONS.HAMMER or
                                work_action == ACTIONS.MINE or
                                work_action == ACTIONS.DIG
                            )
                end
                if isworkable then
                    targets[v] = true
                    v:DoTaskInTime(0.6, function() 
                        if v.components.workable then
                            v.components.workable:Destroy(inst) 
                            local vx,vy,vz = v.Transform:GetWorldPosition()
                            v:DoTaskInTime(0.3, function() setfires(vx,vy,vz,1) end)
                        end
                     end)
                    if v:IsValid() and v:HasTag("stump") then
                       -- v:Remove()
                    end
                elseif v.components.pickable ~= nil
                    and v.components.pickable:CanBePicked()
                    and not v:HasTag("intense") then
                    targets[v] = true
                    local num = v.components.pickable.numtoharvest or 1
                    local product = v.components.pickable.product
                    local x1, y1, z1 = v.Transform:GetWorldPosition()
                    v.components.pickable:Pick(inst) -- only calling this to trigger callbacks on the object
                    if product ~= nil and num > 0 then
                        for i = 1, num do
                            local loot = SpawnPrefab(product)
                            loot.Transform:SetPosition(x1, 0, z1)
                            targets[loot] = true
                        end
                    end

                elseif v.components.health then
                    inst.components.combat:DoAttack(v)
                    if v:IsValid() then
                        if not v.components.health or not v.components.health:IsDead() then
                            if v.components.freezable ~= nil then
                                if v.components.freezable:IsFrozen() then
                                    v.components.freezable:Unfreeze()
                                elseif v.components.freezable.coldness > 0 then
                                    v.components.freezable:AddColdness(-2)
                                end
                            end
                            if v.components.temperature ~= nil then
                                local maxtemp = math.min(v.components.temperature:GetMax(), 10)
                                local curtemp = v.components.temperature:GetCurrent()
                                if maxtemp > curtemp then
                                    v.components.temperature:DoDelta(math.min(10, maxtemp - curtemp))
                                end
                            end
                        end
                    end                   
                end
                if v:IsValid() and v.AnimState then
                    SpawnPrefab("laserhit"):SetTarget(v)
                end
            end
        end
    end
end

local events=
{
    CommonHandlers.OnLocomote(false, true),
    CommonHandlers.OnAttack(),
    EventHandler("startaura",  function(inst) startaura(inst) end),
    EventHandler("stopaura", function(inst) stopaura(inst) end),
    EventHandler("attacked", function(inst)  
            if inst.components.health:GetPercent() > 0 and not inst.sg:HasStateTag("busy") then  
                inst.sg:GoToState("hit") 
            end 
        end),
    EventHandler("death", function(inst) inst.sg:GoToState("death") end),
}

local function getidleanim(inst)
    return "idle"
end

local states =
{
    State
    {
        name = "idle",
        tags = {"idle", "canrotate", "canslide"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation(getidleanim(inst), true)
        end,
    },
    
    State
    {
        name = "appear",
        tags = {"busy"},
        onenter = function(inst)
            inst.AnimState:PlayAnimation("appear")
            inst.SoundEmitter:PlaySound("dontstarve/ghost/ghost_howl")
            TheMixer:PushMix("shadow")

        end,
        
        timeline=
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/ancient_herald/appear") end),
        },
        
        events=
        {
            EventHandler("animover", function(inst, data) 
                inst.sg:GoToState("idle") 
            end)
        },
        
    },    

    State
    {
        name = "taunt",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("taunt")
        end,

        timeline=
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/ancient_herald/taunt") end),
        },
        
        events=
        {
            EventHandler("animover", function(inst, data) inst.sg:GoToState("idle") end)
        },
    },

    State
    {
        name = "summon",
        tags = {"busy"},
        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("summon")
        end,
        
        timeline=
        {
            TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/ancient_herald/summon") end),
            TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/ancient_herald/summon_2d") end),
            TimeEvent(30*FRAMES, function(inst)
                local aporkalypse = GetAporkalypse()
                if aporkalypse then
                    aporkalypse:HeraldSpawnAttack() 
                end
            end)
        },

        events=
        {
            EventHandler("animover", function(inst, data) inst.sg:GoToState("idle") end)
        },
    },
}

CommonStates.AddCombatStates(states,
{
    
    attacktimeline =
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/ancient_herald/attack") end),
        TimeEvent(1*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/ancient_herald/attack_2d") end),
        TimeEvent(20*FRAMES, function(inst)
            local ring = SpawnPrefab("laser_ring")
            ring.Transform:SetPosition(inst.Transform:GetWorldPosition())
            ring.Transform:SetScale(1.1, 1.1, 1.1)
            DoDamage(inst, 6)
        end)
    },
    hittimeline = 
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/ancient_herald/hit") end),
    },
    deathtimeline = 
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/ancient_herald/death") end),
        TimeEvent(32*FRAMES, function(inst) 
            local pt = Vector3(inst.Transform:GetWorldPosition())
            inst.components.lootdropper.speed = 3
            pt.y = 5
            inst.components.lootdropper:DropLootPrefab(SpawnPrefab("ancient_remnant"), pt, math.random()*360)
            inst.components.lootdropper:DropLootPrefab(SpawnPrefab("ancient_remnant"), pt, math.random()*360)
            inst.components.lootdropper:DropLootPrefab(SpawnPrefab("ancient_remnant"), pt, math.random()*360)
            inst.components.lootdropper:DropLootPrefab(SpawnPrefab("ancient_remnant"), pt, math.random()*360)
            inst.components.lootdropper:DropLootPrefab(SpawnPrefab("ancient_remnant"), pt, math.random()*360)

            inst.components.lootdropper.speed = 0
            inst.components.lootdropper:DropLootPrefab(SpawnPrefab("nightmarefuel"), pt, math.random()*360)
            inst.components.lootdropper:DropLootPrefab(SpawnPrefab("nightmarefuel"), pt, math.random()*360)
            inst.components.lootdropper:DropLootPrefab(SpawnPrefab("armorvortexcloak_blueprint"), pt, math.random()*360)

           -- inst.components.lootdropper:ExplodeLoot(pt, 6 + (math.random() * 2)) 
        end),
    },
},

{
    attack = "attack",
})

CommonStates.AddWalkStates(states,
{
    walktimeline = 
    {
        TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/ancient_herald/breath_in") end),
        TimeEvent(17*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/ancient_herald/breath_out") end),   
    }
})
    
return StateGraph("ancient_herald", states, events, "idle")