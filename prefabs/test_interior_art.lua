require "prefabutil"
	
local assets =
{
	Asset("ANIM", "anim/pig_room_test.zip"),
}

local function SetArt(inst, symbol)
	inst.AnimState:OverrideSymbol(symbol, "pig_room_wood", symbol)
	inst.AnimState:Show(symbol)
	inst.current_art = symbol
end

local function SaveInteriorData(inst, save_data)
	if inst.current_art then
		save_data.current_art = inst.current_art
	end
	
	local sx,sy,sz = inst.Transform:GetScale()
	save_data.sx = sx
	save_data.sy = sy
	save_data.sz = sz
end

local function InitFromInteriorSave(inst, save_data)
	if save_data.current_art then
		SetArt(inst, save_data.current_art)
	end
	
	inst.Transform:SetScale(save_data.sx, save_data.sy, save_data.sz)
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

	anim:SetBank("pig_room")
    anim:SetBuild("pig_room_test")
    anim:PlayAnimation("s", true)

	anim:SetLayer( LAYER_BACKGROUND )
	anim:SetSortOrder( 3 )    
   -- anim:OverrideSymbol("wall_back", "pig_room_wood", "wall_back")
--	anim:Hide("wall_back")
	--anim:Hide("wall_side1")
	--anim:Hide("wall_side2")
	--anim:Hide("floor")
	
--	inst.setArt = SetArt
	inst:AddTag("structure")

	inst.saveInteriorData = SaveInteriorData
	inst.initFromInteriorSave = InitFromInteriorSave
    return inst
end

return Prefab( "common/objects/test_interior_art", fn, assets, {} )  
