require "prefabs/roe_fish"
require "prefabutil"
require "tuning"

local assets =
{
	Asset("ANIM", "anim/fish_farm_sign.zip"),	
}

local prefabs = 
{

}

local function determineSign(inst)
    if inst.parent then
        if inst.parent.components.breeder.seeded then
            if inst.parent.components.breeder.harvested then
                return ROE_FISH[inst.parent.components.breeder.product].sign
            else
                return "buoy_sign_1"
            end
        else
            return nil
        end
    end
end

local function resetArt(inst)    
    inst.AnimState:Hide("buoy_sign_1")    
    inst.AnimState:Hide("buoy_sign_2")
    inst.AnimState:Hide("buoy_sign_3")
    inst.AnimState:Hide("buoy_sign_4")
    inst.AnimState:Hide("buoy_sign_5") 

    local sign = determineSign(inst)
    if sign then
        inst.AnimState:Show(sign)   
    end
end

local function onsave(inst, data)

end

local function onload(inst, data)
    inst:Remove()
end

local function onbuilt(inst, sound)

end

local function fn(Sim)
	
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    
    anim:SetBank("fish_farm_sign")
    anim:SetBuild("fish_farm_sign")
    anim:PlayAnimation( "idle",true)

    inst.OnSave = onsave 
    inst.OnLoad = onload        
    
    inst.resetArt = resetArt
	--inst:ListenForEvent("onfishchange", function () resetArt(inst) end)

    return inst

end    

return Prefab( "common/objects/fish_farm_sign", fn, assets, prefabs )
	  
