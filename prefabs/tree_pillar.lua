
local prefabs = 
{
    "glowfly",
}

local assets =
{
    Asset("ANIM", "anim/pillar_tree.zip"),
    Asset("SOUND", "sound/tentacle.fsb"),
    Asset("MINIMAP_IMAGE", "pillar_tree"),
}

local function spawncocoons(inst)
    if math.random() < 0.4 then
        local pt = inst:GetPosition()
        local range = 5 + math.random()*10
        local angle =  math.random() * 2 * PI
        local offset = FindWalkableOffset(pt,angle, range, 10)

        if offset then
            local newpoint = pt+offset
            if GetPlayer():GetDistanceSqToPoint(newpoint) > 40*40 then
                for i=1, math.random(6,10) do
                    range = math.random()*8
                    angle =  math.random() * 2 * PI
                    local suboffset = FindWalkableOffset(newpoint,angle, range, 10)
                    local cocoon = SpawnPrefab("glowfly")
                    local spawnpt = newpoint + suboffset
                    cocoon.Physics:Teleport(spawnpt.x,spawnpt.y,spawnpt.z)                    
                    cocoon:AddTag("cocoonspawn")
                    cocoon.forceCocoon(cocoon)     
                end
            end
        end
    end
end

local function filterspawn(inst)

    if not inst:HasTag("filtered") then   
        inst:AddTag("filtered")
        local x,y,z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x,y,z, 20, {"tree_pillar"})    

        for i,ent in ipairs(ents)do
            if ent == inst then
                table.remove(ents,i)
                break
            end
        end
        if #ents > 0 then        
            inst:Remove()
        end
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    MakeObstaclePhysics(inst, 3, 24)

    -- THIS WAS COMMENTED OUT BECAUSE THE ROC WAS BUMPING INTO IT. BUT I'M NOT SURE WHY IT WAS SET THAT WAY TO BEGIN WITH.
    --inst.Physics:SetCollisionGroup(COLLISION.GROUND)
    trans:SetScale(1,1,1)
    inst:AddTag("tree_pillar")    

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "pillar_tree.png" )

	anim:SetBank("pillar_tree")-- flash animation .fla 
	anim:SetBuild("pillar_tree")   -- art files
    -- anim:SetMultColour(.2, 1, .2, 1.0)

    anim:PlayAnimation("idle",true)
    inst:AddComponent("inspectable")
    -------------------

   -- inst:DoTaskInTime(0,function()  filterspawn(inst)  end)

    inst.spawncocoons = spawncocoons

    if GetWorld().components.glowflyspawner then
        GetWorld():ListenForEvent("spawncocoons", function() spawncocoons(inst) end)
    end
    
   return inst
end

return Prefab( "cave/monsters/tree_pillar", fn, assets, prefabs )
