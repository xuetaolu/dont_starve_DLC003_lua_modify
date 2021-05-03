local assets =
{
    Asset("ANIM", "anim/firecrackers.zip"),
}

local prefabs =
{
    "explode_firecrackers",
}

local function DoPop(inst, remaining, total, level, hissvol)
    local x, y, z = inst.Transform:GetWorldPosition()
    SpawnPrefab("explode_firecrackers").Transform:SetPosition(x, y, z)

    for i, v in ipairs(TheSim:FindEntities(x, y, z, TUNING.FIRECRACKERS_STARTLE_RANGE)) do
        if v:HasTag("canbestartled") then
            v:PushEvent("startle", { source = inst })
        end
        if v:HasTag("firecrackerdance") then
           v:PushEvent("dance", { source = inst }) 
       end
    end

    if remaining > 1 then
        inst.AnimState:PlayAnimation("spin_loop"..tostring(math.random(3)))

        if hissvol > .5 then
            hissvol = hissvol - .1
            inst.SoundEmitter:SetVolume("hiss", hissvol)
        end

        local newlevel = 8 - math.ceil(8 * remaining / total)
        for i = level + 1, newlevel do
            inst.AnimState:Hide("F"..tostring(i))
        end

        local angle = math.random() * 2 * PI
        local spd = 1.5
        inst.Physics:Teleport(x, math.max(y * .5, .1), z)
        inst.Physics:SetVel(math.cos(angle) * spd, 8, math.sin(angle) * spd)

        --23 frames in spin_loop, so if the delay gets longer, loop the anim
        inst:DoTaskInTime(.3 + .3 * math.random(), DoPop, remaining - 1, total, newlevel, hissvol)
    else
        inst:Remove()
    end
end

local function StartExploding(inst, count)
    inst:AddTag("NOCLICK")
    inst:AddTag("scarytoprey")
    inst.Physics:SetFriction(.2)
    DoPop(inst, count, count, 0, 1)
end

local function StartFuse(inst)
    inst.starttask = nil
    inst:RemoveComponent("burnable")

    inst.AnimState:PlayAnimation("burn")
    inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_fuse_LP", "hiss")

    inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength(), StartExploding, math.floor(33.4 * math.sqrt(inst.components.stackable:StackSize() + 3) - 58.8 + .5))

    inst:RemoveComponent("stackable")
    inst.persists = false
end

local function OnIgniteFn(inst)
    if inst.starttask == nil then
        inst.starttask = inst:DoTaskInTime(0, StartFuse)
    end
    inst.components.inventoryitem.canbepickedup = false
end

local function OnExtinguishFn(inst)
    if inst.starttask ~= nil then
        inst.starttask:Cancel()
        inst.starttask = nil
        inst.components.inventoryitem.canbepickedup = true
    end
end

local function ondepleted(inst)
    if inst.components.inventoryitem and inst.components.inventoryitem.owner then
        --dropthing.
        inst.components.inventoryitem.owner.components.inventory:DropItem(inst, true)
    end
    inst:DoTaskInTime(0,function() OnIgniteFn(inst) end)
end
--[[\
local function addfirefx(inst, owner)
    if not inst.fire then
        inst.SoundEmitter:KillSound("hiss")
        inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/cocnade_fuse_loop", "hiss")
        inst.fire = SpawnPrefab( "torchfire" )
        local follower = inst.fire.entity:AddFollower()
        if owner then
            follower:FollowSymbol( owner.GUID, "swap_object", 40, -140, 1 )
        else
            follower:FollowSymbol( inst.GUID, "swap_flame", 0, 0, 0.1 )
        end
    end
end

]]
local function onsetfuse(inst)
     if inst.components.inventoryitem and inst.components.inventoryitem.owner then 
        inst.components.fuse:StartFuse()
    else
        ondepleted(inst)
    end
    --[[
    if inst.components.equippable:IsEquipped() then
        local owner = inst.components.inventoryitem.owner
        addfirefx(inst, owner)
    elseif not inst.components.inventoryitem:IsHeld() then
        addfirefx(inst)
    end
    ]]
end

local function OnFuseStart(inst)
    inst.components.inventoryitem.canbepickedup = false
end

local function OnDropped(inst)
    if inst.components.fuse and inst.components.fuse.consuming then
        inst.components.fuse:StopFuse()
        ondepleted(inst)
    end
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", inst.swapsymbol, inst.swapbuild)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    if inst.components.burnable:IsBurning() then
        addfirefx(inst, owner)
    end
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_object")
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    removefirefx(inst)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("firecrackers")
    inst.AnimState:SetBuild("firecrackers")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("explosive")
    --inst:AddTag("cant_light_in_inventory")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inventoryitem")
    inst:AddComponent("inspectable")

    inst:AddComponent("fuse")
    inst.components.fuse:SetFuseTime(TUNING.FIRECRACKERS_FUSE)
    inst.components.fuse.onfusedone = ondepleted

    inst:AddComponent("burnable")
    inst.components.burnable:SetOnIgniteFn(onsetfuse) -- DefaultBurnFn
    inst.components.burnable:SetOnExtinguishFn(DefaultExtinguishFn)

    inst.components.burnable:SetBurnTime(nil)
    --inst.components.burnable:SetOnIgniteFn(OnIgniteFn)
    inst.components.burnable:SetOnExtinguishFn(OnExtinguishFn)

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = function() 
        return inst.components.throwable:GetThrowPoint()        
    end
    inst.components.reticule.ease = true

    inst:ListenForEvent("ondropped", function() OnDropped(inst) end)
	inst:ListenForEvent("fusestart", function() OnFuseStart(inst) end)
    return inst
end

return Prefab("firecrackers", fn, assets, prefabs)
