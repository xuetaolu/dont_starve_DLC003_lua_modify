local assets =
{
	Asset( "ANIM", "anim/wave_shimmer.zip" ),
	Asset( "ANIM", "anim/wave_shimmer_med.zip" ),
	Asset( "ANIM", "anim/wave_shimmer_deep.zip" ),
	Asset( "ANIM", "anim/wave_shimmer_flood.zip" ),
	Asset( "ANIM", "anim/wave_hurricane.zip" )
}

local function onSleep(inst)
	inst:Remove()
end

local function animover(inst)
	inst:Remove()
end

local function commonfn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()

	inst.persists = false

    anim:SetLayer(LAYER_BACKGROUND)
    anim:SetSortOrder(3)

	inst:AddTag( "FX" )
	inst:AddTag( "NOCLICK" )
	inst.OnEntitySleep = onSleep    
	--swap comments on these lines:
	inst:ListenForEvent( "animover", animover )

    return inst
end

local function shallowfn(Sim)
	local inst = commonfn(Sim)
	if GetSeasonManager():IsWetSeason() then
		local ocean = GetWorld().components.ocean
		inst.Transform:SetRotation(-ocean:GetCurrentAngle())
		inst.Transform:SetTwoFaced()
	    inst.AnimState:SetBuild( "wave_hurricane" )
	    inst.AnimState:SetBank( "wave_hurricane" )
	    inst.AnimState:PlayAnimation( "idle_small", false )
	else
	    inst.AnimState:SetBuild( "wave_shimmer" )
	    inst.AnimState:SetBank( "shimmer" )
	    inst.AnimState:PlayAnimation( "idle", false )
	end
	return inst
end

local function medfn(Sim)
	local inst = commonfn(Sim)
	if GetSeasonManager():IsWetSeason() then
		local ocean = GetWorld().components.ocean
		inst.Transform:SetRotation(-ocean:GetCurrentAngle())
		inst.Transform:SetTwoFaced()
	    inst.AnimState:SetBuild( "wave_hurricane" )
	    inst.AnimState:SetBank( "wave_hurricane" )
	    inst.AnimState:PlayAnimation( "idle_med", false )
	else
	    inst.AnimState:SetBuild( "wave_shimmer_med" )
	    inst.AnimState:SetBank( "shimmer" )
	    inst.AnimState:PlayAnimation( "idle", false )
	end
	return inst
end

local function deepfn(Sim)
	local inst = commonfn(Sim)
	if GetSeasonManager():IsWetSeason() then
		local ocean = GetWorld().components.ocean
		inst.Transform:SetRotation(-ocean:GetCurrentAngle())
		inst.Transform:SetTwoFaced()
	    inst.AnimState:SetBuild( "wave_hurricane" )
	    inst.AnimState:SetBank( "wave_hurricane" )
	    inst.AnimState:PlayAnimation( "idle_deep", false )
	else
	    inst.AnimState:SetBuild( "wave_shimmer_deep" )
	    inst.AnimState:SetBank( "shimmer_deep" )
	    inst.AnimState:PlayAnimation( "idle", false )
	end
	return inst
end

local function floodfn(Sim)
	local inst = commonfn(Sim)
    inst.AnimState:SetBuild( "wave_shimmer_flood" )
    inst.AnimState:SetBank( "wave_shimmer_flood" )
    inst.AnimState:PlayAnimation( "idle", false )
	return inst
end

return Prefab( "common/fx/wave_shimmer", shallowfn, assets ),
		Prefab( "common/fx/wave_shimmer_med", medfn, assets ),
		Prefab( "common/fx/wave_shimmer_deep", deepfn, assets ),
		Prefab( "common/fx/wave_shimmer_flood", floodfn, assets )
