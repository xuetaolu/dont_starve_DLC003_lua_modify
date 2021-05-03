--C:\Don't Starve\Repo\data\DLC0002\anim\swap_coconade.zip  application/octet-stream


local assets=
{
	Asset("ANIM", "anim/coconade.zip"),
	Asset("ANIM", "anim/swap_coconade.zip"),
}

local prefabs = 
{
	"impact",
	"explode_small",
	"bombsplash",
}

local function addfirefx(inst, owner)
    if not inst.fire then
		inst.SoundEmitter:KillSound("hiss")
    	inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_fuse_LP", "hiss")
        inst.fire = SpawnPrefab( "torchfire" )
        inst.fire:AddTag("INTERIOR_LIMBO_IMMUNE")
        local follower = inst.fire.entity:AddFollower()
        if owner then
        	follower:FollowSymbol( owner.GUID, "swap_object", 40, -140, 1 )
        else
        	follower:FollowSymbol( inst.GUID, "swap_flame", 0, 0, 0.1 )
        end
    end
end

local function removefirefx(inst)
    if inst.fire then
        inst.fire:Remove()
        inst.fire = nil
    end
end

local function onthrown(inst, thrower, pt)
	inst.components.burnable:Ignite()
    inst.Physics:SetFriction(.2)
	inst.Transform:SetFourFaced()
	inst:FacePoint(pt:Get())
    inst.AnimState:PlayAnimation("throw", true)

	inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/cannon_fire")

    local smoke =  SpawnPrefab("collapse_small")

    local x, y, z = inst.Transform:GetWorldPosition()
    y = y + 1

    if thrower then 
        smoke.Transform:SetPosition(thrower.AnimState:GetSymbolPosition("swap_lantern", 0, 0, 0))
    else 
        smoke.Transform:SetPosition(x, y, z)
    end 

	inst.LightTask = inst:DoPeriodicTask(FRAMES, function()
		local pos = inst:GetPosition()

		if pos.y <= 0.3 then
			inst.components.explosive:OnBurnt()
		end

		if inst.fire then
    		local rad = math.clamp(Lerp(2, 0, pos.y/6), 0, 2)
    		local intensity = math.clamp(Lerp(0.8, 0.5, pos.y/7), 0.5, 0.8)
    		inst.fire.Light:SetRadius(rad)
    		inst.fire.Light:SetIntensity(intensity)
	    end
	end)
end

local function onexplode(inst)
	local pos = inst:GetPosition()

	inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/cannon_ball_hit")
	if inst:GetIsOnWater() then
		SpawnWaves(inst, 6, 360, 5)
		local splash = SpawnPrefab("bombsplash")
		splash.Transform:SetPosition(pos.x, pos.y, pos.z)

		inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/cannonball_impact")
		inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/volcano/volcano_rock_splash")

	else
		inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/volcano/volcano_rock_smash")
		local explode = SpawnPrefab("explode_small")
		explode.Transform:SetPosition(pos.x, pos.y, pos.z)

		explode.AnimState:SetBloomEffectHandle("shaders/anim.ksh" )
		explode.AnimState:SetLightOverride(1)
	end
end

local function onremove(inst)
	inst.SoundEmitter:KillSound("hiss")
	removefirefx(inst)
	if inst.LightTask then
		inst.LightTask:Cancel()
	end
end

local function onignite(inst)
	addfirefx(inst)
end

local function fn(CANNON_DAMAGE)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

	MakeInventoryPhysics(inst)
	MakeInventoryFloatable(inst, "idle_water", "idle")
	
	inst.AnimState:SetBank("coconade")
	inst.AnimState:SetBuild("coconade")
	inst.AnimState:PlayAnimation("idle")
	
	inst:AddTag("thrown")
	inst:AddTag("projectile")
	inst:AddTag("NOCLICK")
	
	inst:AddComponent("throwable")
	inst.components.throwable.onthrown = onthrown
	inst.components.throwable.maxdistance = 20

	inst:AddComponent("explosive")
	inst.components.explosive:SetOnExplodeFn(onexplode)
	inst.components.explosive.explosivedamage = CANNON_DAMAGE
	inst.components.explosive.explosiverange = TUNING.BOATCANNON_RADIUS
	inst.components.explosive.buildingdamage = TUNING.BOATCANNON_BUILDINGDAMAGE

	inst:AddComponent("burnable")
	inst.components.burnable.onignite = onignite
	inst.components.burnable.nofx = true

	inst.persists = false
    inst.OnRemoveEntity = onremove

    -- they blow themseleves up after 3 seconds incase of stuff like the lily pads. 
    inst:DoTaskInTime(3,function() 
    	local pos = inst:GetPosition()
    	inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/volcano/volcano_rock_smash")
		local explode = SpawnPrefab("explode_small")
		explode.Transform:SetPosition(pos.x, pos.y, pos.z)

		explode.AnimState:SetBloomEffectHandle("shaders/anim.ksh" )
		explode.AnimState:SetLightOverride(1)
		inst:Remove()
	end)

	return inst
end

return Prefab( "common/inventory/cannonshot", function() return fn(TUNING.BOATCANNON_DAMAGE) end, assets, prefabs),
Prefab("woodlegs_cannonshot", function() return fn(TUNING.WOODLEGS_BOATCANNON_DAMAGE) end, assets, prefabs)