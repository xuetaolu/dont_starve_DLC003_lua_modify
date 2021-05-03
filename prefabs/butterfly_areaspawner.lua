
local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()

	inst:AddTag("NOCLICK")
	inst:AddTag("NOBLOCK")
	-- local minimap = inst.entity:AddMiniMapEntity()
	-- minimap:SetIcon( "accomplishment_shrine.png" )

	inst:AddComponent("butterflyspawner")
	inst.components.butterflyspawner.followplayer = false
	inst.components.butterflyspawner:SpawnModeVeryHeavy()

	return inst
end

return Prefab("shipwrecked/objects/butterfly_areaspawner", fn)
