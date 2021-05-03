local assets=
{
	Asset("ANIM", "anim/coconut_cannon.zip"),
}

local prefabs = 
{
	"impact",
	"explode_small",
	"bombsplash",
}

local function onthrown(inst, thrower, pt, time_to_target)
    inst.Physics:SetFriction(.2)
	inst.Transform:SetFourFaced()
	inst:FacePoint(pt:Get())
    inst.AnimState:PlayAnimation("throw", true)

    local shadow = SpawnPrefab("warningshadow")
    shadow.Transform:SetPosition(pt:Get())
    shadow:shrink(time_to_target, 2, 0.5)

    local smoke =  SpawnPrefab("collapse_small")
    local x, y, z = inst.Transform:GetWorldPosition()
    y = y + 1

	inst.UpdateTask = inst:DoPeriodicTask(FRAMES, function()
		local pos = inst:GetPosition()
		if pos.y <= 0.3 then
		    local ents = TheSim:FindEntities(pos.x, 0, pos.z, TUNING.KNIGHTBOAT_RADIUS, nil, {"FX", "DECOR", "INLIMBO"})

		    for k,v in pairs(ents) do
	            if v.components.combat and v ~= inst then --For now I want knight boats to kill eachother
	                v.components.combat:GetAttacked(thrower, TUNING.KNIGHTBOAT_DAMAGE)
	            end
		    end
			inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/cannon_ball_hit")

			if inst:GetIsOnWater() then
				local splash = SpawnPrefab("bombsplash")
				splash.Transform:SetPosition(pos.x, pos.y, pos.z)

				inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/cannonball_impact")
				inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/splash_large")

			else
				inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")
				local explode = SpawnPrefab("explode_small")
				explode.Transform:SetPosition(pos.x, pos.y, pos.z)

				explode.AnimState:SetBloomEffectHandle("shaders/anim.ksh" )
				explode.AnimState:SetLightOverride(1)
			end

			inst:Remove()
		end
	end)
end

local function onremove(inst)
	if inst.UpdateTask then
		inst.UpdateTask:Cancel()
	end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

	MakeInventoryPhysics(inst)
	
	inst.AnimState:SetBank("coconut_cannon")
	inst.AnimState:SetBuild("coconut_cannon")
	inst.AnimState:PlayAnimation("throw", true)

	inst:AddTag("thrown")
	inst:AddTag("projectile")

	inst:AddComponent("throwable")
	inst.components.throwable.onthrown = onthrown
	inst.components.throwable.random_angle = 0
	inst.components.throwable.max_y = 50

	inst.persists = false

    inst.OnRemoveEntity = onremove

	return inst
end

return Prefab( "knightboat_cannonshot", fn, assets, prefabs)