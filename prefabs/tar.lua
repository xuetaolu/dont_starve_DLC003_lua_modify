local itemassets =
{
	Asset("ANIM", "anim/tar.zip"),
}

local assets =
{
    Asset("ANIM", "anim/tar_trap.zip"),
}


local itemprefabs=
{
    "tar_trap",
}

local function findFloodGridNum(num)
    -- the flood grid is is the center of a 2x2 tile pattern. So 1,3,5,7..
    if math.mod(num, 2) == 0 then
        num = num +1
    end
    return num
end

local function quantizepos(pt)
    local x, y, z = pt:Get()
    y = 0    

    local nx = findFloodGridNum(math.floor(x))
    local ny = 0
    local nz = findFloodGridNum(math.floor(z))

    return Vector3(nx,ny,nz)
end

local function onRemove(inst)
    for i,slowedinst in pairs( inst.slowed_objects ) do
        i.slowing_objects[inst] = nil      
    end
end

local function updateslowdowners(inst)

    local ground = GetWorld()
    local x,y,z = inst.Transform:GetWorldPosition() 
    local slowdowns = TheSim:FindEntities(x,y,z, 1.5, {"locomotor"})
    local tempSlowedObjects = {}

    for i=#slowdowns,1,-1 do
        if not slowdowns[i].sg or not slowdowns[i].sg:HasStateTag("moving") then
            table.remove(slowdowns,i)
        end            
    end

    if #slowdowns > 0 then
        if not next(inst.slowed_objects) then
            inst.components.fueled:StartConsuming()
        end
    elseif next(inst.slowed_objects) then
        inst.components.fueled:StopConsuming()
    end

    for i,slowinst in ipairs(slowdowns)do
        if not slowinst.slowing_objects then
            slowinst.slowing_objects  = {}
        end

        slowinst.slowing_objects[inst] = true                    

        tempSlowedObjects[slowinst] = true
    end

    for i,slowedinst in pairs( inst.slowed_objects ) do
        if not tempSlowedObjects[i] then
            i.slowing_objects[inst] = nil
        end       
    end

    inst.slowed_objects = tempSlowedObjects

    inst:DoTaskInTime(2/30,function(inst) updateslowdowners(inst) end)
end

local function updateAnim(inst,section)
    if section == 1 then
        inst.AnimState:PlayAnimation("idle_25")
    elseif section == 2 then
        inst.AnimState:PlayAnimation("idle_50")
    elseif section == 3 then
        inst.AnimState:PlayAnimation("idle_75")                
    elseif section == 4 then
        inst.AnimState:PlayAnimation("idle_full")                
    end
end

local function ontakefuelfn(inst)
  --  inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/machine_fuel")
  updateAnim(inst,inst.components.fueled:GetCurrentSection())
end


local function onBuilt(inst)
    inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/poop_splat")
end

local function fn(Sim)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)

    inst.AnimState:SetLayer( LAYER_BACKGROUND )
    inst.AnimState:SetSortOrder( 3 )
   
    inst:AddTag("tar_trap")
    inst:AddTag("locomotor_slowdown")
    
    --MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.LIGHT, TUNING.WINDBLOWN_SCALE_MAX.LIGHT)

    inst.AnimState:SetBank("tar_trap")
    inst.AnimState:SetBuild("tar_trap")

    inst.AnimState:PlayAnimation("idle_full")
    
    inst:AddComponent("inspectable")

    MakeLargeBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeLargePropagator(inst)
    inst.components.burnable:MakeDragonflyBait(3)

    inst.slowdowners = {}

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "TAR"
    inst.components.fueled.accepting = true
    inst.components.fueled.ontakefuelfn = ontakefuelfn
    inst.components.fueled:SetSections(4)    
    inst.components.fueled:InitializeFuelLevel(TUNING.TAR_TRAP_TIME/2)
    inst.components.fueled:SetDepletedFn(function(inst) inst:Remove() end)
    inst.components.fueled:SetSectionCallback(
        function(section)
            if section == 0 then
                --when we burn out
                if inst.components.burnable then 
                    inst.components.burnable:Extinguish() 
                end            
            else
                updateAnim(inst,section)
            end
        end)        

    onBuilt(inst)

    inst.slowed_objects = {}
    inst.OnRemoveEntity = onRemove
    inst:DoTaskInTime(1/30,function(inst) updateslowdowners(inst) end)

    return inst
end


local function test_wall(inst, pt)
    local map = GetWorld().Map
    local tiletype = GetGroundTypeAtPosition(pt)
    local ground_OK = tiletype ~= GROUND.IMPASSABLE and not map:IsWater(tiletype)
        
    if ground_OK then
        local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 2, nil, {"NOBLOCK", "player", "FX", "INLIMBO","tar_trap"}) -- or we could include a flag to the search?

        for k, v in pairs(ents) do
            if v ~= inst and v:IsValid() and v.entity:IsVisible() and not v.components.placer and v.parent == nil then
                local dsq = distsq( Vector3(v.Transform:GetWorldPosition()), pt)
                if  dsq< 1 then 
                    return false 
                end
            end
        end

        return true

    end
    return false
    
end

local function ondeploy(inst, pt, deployer)
    --[[
    local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 0.2, {"tar_trap"}) -- or we could include a flag to the search?
    for i, ent in ipairs(ents) do
        ent:Remove()
    end
]]
    local wall = SpawnPrefab("tar_trap") 
    wall.AnimState:PlayAnimation("place")
    wall.AnimState:PushAnimation("idle_full")
    local ground = GetWorld()
    
    if wall then
   --     pt = quantizepos(pt)
        wall.Transform:SetPosition(pt.x,0,pt.z) 
    end
    inst:Remove()

end

local function itemfn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.LIGHT, TUNING.WINDBLOWN_SCALE_MAX.LIGHT)

    inst.AnimState:SetBank("tar")
    inst.AnimState:SetBuild("tar")

    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("tradable")

    inst:AddComponent("inspectable")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL
    inst.components.fuel.secondaryfueltype = "TAR"
    
	MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)
    inst.components.burnable:MakeDragonflyBait(3)
        
    inst:AddComponent("inventoryitem")

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy
    inst.components.deployable.min_spacing = 0
    --inst.components.deployable.placer = "gridplacer"  
    inst.components.deployable.test = test_wall
    inst.components.deployable.placer = "tar_trap_placer"
    inst.components.deployable:SetQuantizeFunction(quantizepos)
    inst.components.deployable.deploydistance = 2    

    return inst
end

return Prefab( "shipwrecked/inventory/tar", itemfn, itemassets, itemprefabs),
    Prefab("shipwrecked/tar_trap", fn, assets),
    MakePlacer("shipwrecked/tar_trap_placer",  "tar_trap", "tar_trap", "idle_full", false, false, false, 1.0, true, nil, nil, true) 

