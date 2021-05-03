local assets=
{
	Asset("ANIM", "anim/ink_projectile.zip"),
	Asset("ANIM", "anim/ink_puddle.zip"),
}

local prefabs = {}

local function onthrown(inst, thrower, pt, time_to_target)
    inst.Physics:SetFriction(.2)

    -- local shadow = SpawnPrefab("warningshadow")
    -- shadow.Transform:SetPosition(pt:Get())
    -- shadow:shrink(time_to_target, 1.75, 0.5)

	inst.TrackHeight = inst:DoPeriodicTask(FRAMES, function()
		local pos = inst:GetPosition()

		if pos.y <= 1 then
		    local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 1.5, nil, {"FX", "NOCLICK", "DECOR", "INLIMBO"})

		    for k,v in pairs(ents) do
	            if v.components.combat and v ~= inst and v.prefab ~= "kraken_tentacle" then
	                v.components.combat:GetAttacked(thrower, 50)
	            end
		    end

			local pt = inst:GetPosition()
			if inst:GetIsOnWater() then
				local splash = SpawnPrefab("kraken_ink_splat")
				splash.Transform:SetPosition(pos.x, pos.y, pos.z)

				inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/cannonball_impact")
				inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/splash_large")
			
				local ink = SpawnPrefab("kraken_inkpatch")
				ink.Transform:SetPosition(pos.x, pos.y, pos.z)
			end

			inst:Remove()
		end
	end)
end

local function onremove(inst)
	if inst.TrackHeight then
		inst.TrackHeight:Cancel()
		inst.TrackHeight = nil
	end
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	
	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("ink")
	inst.AnimState:SetBuild("ink_projectile")
	inst.AnimState:PlayAnimation("fly_loop", true)

	inst:AddTag("thrown")
	inst:AddTag("projectile")

	inst:AddComponent("throwable")
	inst.components.throwable.onthrown = onthrown
	inst.components.throwable.random_angle = 0
	inst.components.throwable.max_y = 100
	inst.components.throwable.yOffset = 7

	inst.OnRemoveEntity = onremove

	inst.persists = false

	return inst
end

local lerp_time = 30

local function ink_update(inst, dt)
	inst.ink_timer = inst.ink_timer - dt
	inst.ink_scale = Lerp(0, 1, inst.ink_timer/lerp_time)
	inst.Transform:SetScale(inst.ink_scale, inst.ink_scale, inst.ink_scale)

	if inst.ink_scale <= 0.33 then
		inst.slowing_player = false
		GetPlayer().components.locomotor:RemoveSpeedModifier_Mult("INK")
		inst:Remove()
		return
	end
	
	local pos = inst:GetPosition()
	local dist = pos:Dist(GetPlayer():GetPosition())
	if not inst.slowing_player and dist <= inst.ink_scale * 3.66 then
		inst.slowing_player = true
		GetPlayer().components.locomotor:AddSpeedModifier_Mult("INK", -0.7)
	elseif inst.slowing_player and dist > inst.ink_scale * 3.66 then
		inst.slowing_player = false
		GetPlayer().components.locomotor:RemoveSpeedModifier_Mult("INK")
	end
end

local function inkpatch_fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

    inst.AnimState:SetBuild("ink_puddle")
    inst.AnimState:SetBank("ink_puddle")
    inst.AnimState:PlayAnimation("idle", true)
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(3)

	inst.ink_timer = lerp_time
	inst.ink_scale = 1
	inst.Transform:SetScale(inst.ink_scale,inst.ink_scale,inst.ink_scale)
	local dt = FRAMES * 3

	inst.slowing_player = false

	inst:DoPeriodicTask(dt, function() ink_update(inst, dt) end)

	return inst
end

return Prefab("kraken_projectile", fn, assets, prefabs),
Prefab("kraken_inkpatch", inkpatch_fn)