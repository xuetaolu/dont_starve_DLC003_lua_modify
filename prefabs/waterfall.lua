local assets =
{
	Asset("SOUND", "sound/rabbit.fsb"),
}

local prefabs =
{
}

local WATERFALL_DIST = 16
local WATERFALL_DIST_SQ = WATERFALL_DIST * WATERFALL_DIST

local function UpdateAudio(inst)
	local player = GetPlayer()

	local instPosition = Vector3(inst.Transform:GetWorldPosition())
	local playerPosition = Vector3(player.Transform:GetWorldPosition())
	local waterfallIsNearby = (distsq(playerPosition, instPosition) < WATERFALL_DIST_SQ)

	if waterfallIsNearby and not inst.SoundEmitter:PlayingSound("WATERFALL") then
		inst.SoundEmitter:PlaySound("dontstarve_DLC003/amb/Waterfall/LP_1", "WATERFALL")
	elseif not waterfallIsNearby and inst.SoundEmitter:PlayingSound("WATERFALL") then
		inst.SoundEmitter:KillSound("WATERFALL")
	end
end

local function OnEntitySleep(inst)
	if inst.audiotask then
		inst.audiotask:Cancel()
		inst.audiotask = nil
	end
end

local function OnEntityWake(inst)
	if inst.audiotask then
		inst.audiotask:Cancel()
	end
	inst.audiotask = inst:DoPeriodicTask(1.0, function() UpdateAudio(inst) end, math.random())
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local sound = inst.entity:AddSoundEmitter()

	inst.audiotask = inst:DoPeriodicTask(1.0, function() UpdateAudio(inst) end, math.random())

    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

	inst.persists = false

	return inst
end

return Prefab("map/waterfall", fn, assets, prefabs)
