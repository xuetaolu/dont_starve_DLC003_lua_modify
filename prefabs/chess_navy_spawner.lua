--sends chessnavy.lua an event on entity wake if activated.

local function OnEntitySleep(inst)
	inst.spawn_point_active = true
end

local function OnEntityWake(inst)
	if inst.spawn_point_active then
		inst:PushEvent("onentitywake")
	end
end

local function OnSave(inst, data)
	data.spawn_point_active = inst.spawn_point_active
end

local function OnLoad(inst, data)
	inst.spawn_point_active = data.spawn_point_active or false
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()

	inst:AddTag("NOCLICK")

	inst.spawn_point_active = false
	inst.OnEntitySleep = OnEntitySleep
	inst.OnEntityWake = OnEntityWake
	inst.OnSave = OnSave
	inst.OnLoad = OnLoad

	return inst
end

return Prefab("chess_navy_spawner", fn)