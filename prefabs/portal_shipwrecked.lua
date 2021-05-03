local assets =
{
	Asset("ANIM", "anim/portal_shipwrecked.zip"),
	Asset("ANIM", "anim/portal_shipwrecked_build.zip"),
	Asset("ANIM", "anim/wormhole_shipwrecked.zip"),
}
	
local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

	anim:SetBank("boatportal")
	anim:SetBuild("portal_shipwrecked_build")
	anim:PlayAnimation("idle_off")

	MakeObstaclePhysics(inst, 1)

	inst:AddComponent("inspectable")

	inst:DoTaskInTime(0, function()
		local pos = inst:GetPosition()
		local exit = SpawnPrefab("shipwrecked_exit")
		exit.Transform:SetPosition(pos:Get())
		inst:Remove()
	end)
	
	return inst
end

local function wormhole_fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()

	anim:SetBank("teleporter_worm")
	anim:SetBuild("wormhole_shipwrecked")
	anim:PlayAnimation("in")
	anim:PushAnimation("out", false)

	inst:DoTaskInTime(0*FRAMES, function() inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/portal/open") end)
	inst:DoTaskInTime(8*FRAMES, function() inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/portal/jump_in") end)

	inst:ListenForEvent("animqueueover", inst.Remove)
	
	return inst
end

return Prefab( "common/objects/portal_shipwrecked", fn, assets),
Prefab("wormhole_shipwrecked_fx", wormhole_fn, assets)
