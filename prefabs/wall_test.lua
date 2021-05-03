local assets=
{
    Asset("ANIM", "anim/pig_room_general.zip"),
    Asset("ANIM", "anim/pig_room_wood.zip"),
}

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    anim:SetBank("pig_room")
    anim:SetBuild("pig_room_general")
    anim:PlayAnimation("idle", true)

    anim:OverrideSymbol("wall_side1", "pig_room_wood", "wall_side1")
    anim:Hide("wall_side2")

    return inst
end

return Prefab( "common/wall_test", fn, assets) 
