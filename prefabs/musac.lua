require "prefabutil"
local assets =
{
}

local prefabs = 
{
}

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()

    inst:Hide()
    
    inst.SoundEmitter:PlaySound( "dontstarve_DLC003/music/shop_enter", "musac")

    return inst
end

return Prefab( "common/inventory/musac", fn, assets, prefabs)