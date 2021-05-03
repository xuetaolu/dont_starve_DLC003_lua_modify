local assets =
{
    Asset("ANIM", "anim/store_items.zip"),
	Asset("ANIM", "anim/thought_balloon.zip"),
	Asset("SOUND", "sound/common.fsb"),
}

local function SwapPrefab(inst, prefab)
    inst.AnimState:OverrideSymbol("swap_thought", "store_items", prefab)
end 

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    
    
    anim:SetBank("thought_balloon")
    anim:SetBuild("thought_balloon")
    anim:PlayAnimation("idle")

    inst.SwapPrefab = SwapPrefab

    return inst
end

return Prefab( "common/inventory/pigthought", fn, assets) 
