require "prefabutil"
local assets =
{
Asset("ANIM", "anim/acorn.zip"),
}

local prefabs = 
{
    "acorn_cooked",
    "spoiled_food"
}

local function describe(inst)
    if inst.growtime then
        return "PLANTED"
    end
end

local function displaynamefn(inst)
    if inst.growtime then
        return STRINGS.NAMES.ACORN_SAPLING
    end
    return STRINGS.NAMES.ACORN
end

local function turnoff(inst, light)
    if light then
        light:Enable(false)
    end   
end

local colors = {
    day = {1,1,1},
    dusk = {1/1.8,1/1.8,1/1.8},
    night = {1/3,1/3,1/3},
    full = {0.8/1.8,0.8/1.8,1/1.8},
}

local phasefunctions = 
{
    day = function(inst)
        inst.Light:Enable(true)       
        inst.components.lighttweener:StartTween(nil, 3,  0.75, 0.5, {colors.day[1],colors.day[2],colors.day[3]}, 2)
    end,

    dusk = function(inst) 
        inst.Light:Enable(true)       
        inst.components.lighttweener:StartTween(nil, 2,  0.75, 0.5, {colors.dusk[1],colors.dusk[2],colors.dusk[3]}, 2)
    end,

    night = function(inst) 
        if GetWorld().components.clock:GetMoonPhase() == "full" then
            inst.components.lighttweener:StartTween(nil, 1,  0.75, 0.5, {colors.full[1],colors.full[2],colors.full[3]}, 4)
        else
            inst.components.lighttweener:StartTween(nil, 0, 0, 1, {0,0,0}, 6, turnoff)
        end    
    end,
}

local function timechange(inst)    
    if GetClock():IsDay() then
        if inst.Light then
            phasefunctions["day"](inst)
        end
    elseif GetClock():IsNight() then
        if inst.Light then
            phasefunctions["night"](inst)
        end
    elseif GetClock():IsDusk() then
        if inst.Light then
            phasefunctions["dusk"](inst)
        end
    end
end


local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("acorn")
    inst.AnimState:SetBuild("acorn")
    inst.AnimState:PlayAnimation("idle")

--[[

    inst.entity:AddLight()
    inst.Light:SetIntensity( 0.75 )
    inst.Light:SetColour( 97/255,197/255,50/255 )
    inst.Light:SetFalloff( 0.5 )
    inst.Light:SetRadius( 3 )   
    inst.Light:Enable(true)
]]
    inst:AddComponent("lighttweener")
    inst.components.lighttweener:StartTween(inst.entity:AddLight(), 3, .75, .5, {197/255,197/255,50/255}, 0)
    inst.Light:Enable(true)
   -- inst:AddComponent("fader")

    inst:ListenForEvent("daytime", function() timechange(inst) end, GetWorld())
    inst:ListenForEvent("dusktime", function() timechange(inst) end, GetWorld())
    inst:ListenForEvent("nighttime", function() timechange(inst) end, GetWorld())   

    inst:AddComponent("tradable")

    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = describe
    
    inst:AddComponent("inventoryitem")

    inst.displaynamefn = displaynamefn


    return inst
end

return Prefab( "common/inventory/acorn_light", fn, assets, prefabs)


