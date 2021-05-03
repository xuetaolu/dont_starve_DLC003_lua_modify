require("constants")

local assets =
{
	--Asset("ANIM", "anim/flood_tiles.zip"),
	Asset("ANIM", "anim/flood_edge.zip"),
	--Asset("ANIM", "anim/flood_tiles2.zip"),
	Asset("ANIM", "anim/flood_tiles_simple.zip"),
}


local prefabs =
{
}


local depthAnims = {"idle_light", "idle_med", "idle_deep"}

local function setDepth(inst, depth)
	--print("setting depth!", depth)
	inst.depth = depth 
	depth = math.clamp(depth, 0, 9)
	local anim = math.ceil(math.clamp(depth, 0, 9)/3) --anim changes every three depths 

	if depth == 0 then 
		--print("hiding!")
		inst:Hide()
		inst.currentAnimIndex = 0
	elseif anim ~= inst.currentAnimIndex then  
		inst:Show()
		inst.AnimState:PlayAnimation(depthAnims[anim])
		inst.currentAnimIndex = anim
	end 
end 

local function doDepthDelta(inst, delta)
	setDepth(inst, inst.depth + delta)	
end 

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

	anim:SetBank("flood_tiles")
	anim:SetBuild("flood_tiles")
	--anim:PlayAnimation("idle_light")
	anim:SetOrientation( ANIM_ORIENTATION.OnGround )
	
	anim:SetLayer( LAYER_BACKGROUND )
    anim:SetSortOrder( 3 )
    --anim:SetScale(.5,.5)
	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	--inst:AddTag('scarytoprey')

	setDepth(inst,0)

	inst.blocked = false 
  	inst.currentAnimIndex = 0 
	--inst:AddComponent("floodlistener")
	--inst.components.floodlistener.waterlevelchangefn = OnWaterLevelChanged
	--inst.components.floodlistener.waterlevelzerofn = OnWaterLevelZero

	--inst:AddComponent("childspawner")
	--inst.components.childspawner.childname = "mosquito"
	--inst.components.childspawner:SetRareChild("frog", 0.25)
	--inst.components.childspawner:SetRegenPeriod(4 * TUNING.SEG_TIME)
	--inst.components.childspawner:SetSpawnPeriod(1 * TUNING.SEG_TIME)
	--inst.components.childspawner:SetMaxChildren(math.random(4, 8))
	--inst.components.childspawner:StartSpawning()
	--inst.components.childspawner:StartRegen()

	--inst.FloodingEntity:SetRadius(2)
	inst.setDepth = setDepth 
	inst.doDepthDelta = doDepthDelta

	inst.OnSave = function(inst, data)
	end

	inst.OnLoad = function(inst, data)
	end

    return inst
end

return Prefab( "shipwrecked/objects/floodtile", fn, assets, prefabs )
