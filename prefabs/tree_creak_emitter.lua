
local function OnGustStart(inst, windspeed)
	inst.timer = 0.25 * math.random()
	inst.components.spotemitter:Start()
end

local function OnGustEnd(inst, windspeed)
	inst.timer = 0.0
	inst.components.spotemitter:Stop()
end

local function OnUpdate(inst, dt)
	inst.timer = inst.timer - dt
	if inst.timer <= 0.0 then
		inst.timer = 0.5 * math.random()
		inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/wind_tree_creak")
	end
end

local function OnSleep(inst)
	inst.components.spotemitter:RemoveAll()
	inst:Remove()
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddSoundEmitter()

	inst:AddTag("treeherd")
	inst:AddTag("NOCLICK")
	inst:AddTag("FX")

	inst:AddComponent("spotemitter")
	inst.components.spotemitter:SetMax(6)
	inst.components.spotemitter:SetOnUpdateFn(OnUpdate)
	inst.components.spotemitter:SetOnEmptyFn(function(inst) inst:Remove() end)

	inst:AddComponent("blowinwindgust")
	inst.components.blowinwindgust:SetWindSpeedThreshold(TUNING.TREE_CREAK_WINDBLOWN_SPEED)
	inst.components.blowinwindgust:SetGustStartFn(OnGustStart)
	inst.components.blowinwindgust:SetGustEndFn(OnGustEnd)
	inst.components.blowinwindgust:Start()

	inst.OnEntitySleep = OnSleep
	inst.timer = 0

	return inst
end

return Prefab("shipwrecked/objects/tree_creak_emitter", fn)