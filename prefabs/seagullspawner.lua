local assets =
{
	Asset("ANIM", "anim/seagull_shadow.zip"),
	Asset("ANIM", "anim/seagull.zip"),
	Asset("ANIM", "anim/seagull_water.zip"),
}

local prefabs =
{
	"seagull_water",
}


local function RemoveShadow(inst, shadow)
	shadow.components.colourtweener:StartTween({1,1,1,0}, 3, function() shadow:Remove() inst.seagulls[shadow] = nil end)
end

local function SpawnSeagullShadow(inst)
	local seagull = SpawnPrefab("circlingseagull")
	seagull.components.circler:SetCircleTarget(inst)
	seagull.components.circler:Start()
	inst.seagulls[seagull] = seagull
end

local function OnAddChild(inst, num)
	for i = 1, num or 1 do
		SpawnSeagullShadow(inst)
	end
end

local function OnSpawn(inst, child)
	for k,v in pairs(inst.seagulls) do
		if k and k:IsValid() then
			local dist = v.components.circler.distance
			local angle = v.components.circler.angleRad
			local offset = FindWalkableOffset(inst:GetPosition(), angle, dist, 8, false) or Vector3(0,0,0)
			offset.y = 30
			child.Transform:SetPosition((inst:GetPosition() + offset):Get())
			child.sg:GoToState("glide")
			RemoveShadow(inst, k)		
			break
		end
	end
end

local function SpawnSeagull(inst)
	if not inst.components.childspawner:CanSpawn() or GetClock():IsNight() then 
		return
	end

	local pt = inst:GetPosition()
    local seagull = inst.components.childspawner:SpawnChild()
    if seagull then
		seagull.Transform:SetPosition(pt.x + math.random(-10.5, 10.5), 30, pt.z + math.random(-10.5, 10.5))
	end
end

local function OnEntitySleep(inst)
	for k,v in pairs(inst.seagulls) do
		k:Remove()
		k = nil
	end
	if inst.spawntask then
		inst.spawntask:Cancel()
		inst.spawntask = nil
	end
end

local function OnEntityWake(inst)
	inst:DoTaskInTime(0.5, function() 
		if not inst:IsAsleep() then 
			for i = 1, inst.components.childspawner.childreninside do
				SpawnSeagullShadow(inst)
			end
		end
	end)
	inst.spawntask = inst:DoPeriodicTask(math.random()+2, SpawnSeagull)
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()

	inst.OnEntityWake = OnEntityWake
	inst.OnEntitySleep = OnEntitySleep

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("seagull.png")

	inst:AddTag("seagullspawner")
	inst:AddTag("NOCLICK")

	inst:AddComponent( "childspawner" )
	inst.components.childspawner.childname = "seagull_water"
	inst.components.childspawner:SetSpawnedFn(OnSpawn)
	inst.components.childspawner:SetOnAddChildFn(OnAddChild)
	inst.components.childspawner:SetMaxChildren(math.random(2, 4))
	inst.components.childspawner:SetSpawnPeriod(math.random(2, 3))
	inst.components.childspawner:SetRegenPeriod(5)

	inst:ListenForEvent("daytime", function()
	    if not GetSeasonManager() or not GetSeasonManager():IsWetSeason() then
		    inst.components.childspawner:StartSpawning()
			inst.components.childspawner:StopRegen()
		end
	end, GetWorld())

	inst:ListenForEvent("nighttime", function() 
		inst.components.childspawner:StopSpawning()
		inst.components.childspawner:StartRegen()
	end, GetWorld())
	
	inst.seagulls = {}

	return inst
end

local function circlingseagullfn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

    anim:SetBank("seagull_shadow")
    anim:SetBuild("seagull_shadow")
    anim:PlayAnimation("shadow", true)
	anim:SetOrientation( ANIM_ORIENTATION.OnGround )
	anim:SetLayer( LAYER_BACKGROUND )
	anim:SetSortOrder( 3 )

	inst:AddComponent("circler")

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

	inst.AnimState:SetMultColour(1,1,1,0)
	inst:AddComponent("colourtweener")
	if not GetClock():IsNight() then
		inst.components.colourtweener:StartTween({1,1,1,1}, 3)
	end

	inst.persists = false

	inst:ListenForEvent("daytime", function()
	    if not GetSeasonManager() or not GetSeasonManager():IsWetSeason() then
			inst.components.colourtweener:StartTween({1,1,1,1}, 3)
		end
	end, GetWorld())

	inst:ListenForEvent("nighttime", function() 
			inst.components.colourtweener:StartTween({1,1,1,0}, 3)
	end, GetWorld())

	inst:DoPeriodicTask(math.random(3,5), function() 
		if math.random() > 0.66 then 
			local numFlaps = math.random(3, 6)
			inst.AnimState:PlayAnimation("shadow_flap_loop") 

			for i = 2, numFlaps do
				inst.AnimState:PushAnimation("shadow_flap_loop") 
			end

			inst.AnimState:PushAnimation("shadow") 
		end 
	end)

	return inst
end

return Prefab( "badlands/objects/seagullspawner", fn, assets, prefabs),
Prefab("badlands/objects/circlingseagull", circlingseagullfn, assets, prefabs)
