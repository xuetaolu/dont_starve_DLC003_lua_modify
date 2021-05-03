local texture = "fx/hail.tex"
local shader = "shaders/particle.ksh"
local colour_envelope_name = "hailcolourenvelope"
local scale_envelope_name = "hailscaleenvelope"

local assets =
{
	Asset( "IMAGE", texture ),
	Asset( "SHADER", shader ),
}

local prefabs =
{
    "haildrop",
    "hail_ice"
}

local function IntColour( r, g, b, a )
	return { r / 255.0, g / 255.0, b / 255.0, a / 255.0 }
end

local init = false
local function InitEnvelope()
	if EnvelopeManager and not init then
		init = true
		EnvelopeManager:AddColourEnvelope(
			colour_envelope_name,
			{	{ 0,	IntColour( 255, 255, 255, 255 ) },
				{ 1,	IntColour( 255, 255, 255, 255 ) },
			} )

		local max_scale = 0.4
		EnvelopeManager:AddVector2Envelope(
			scale_envelope_name,
			{
				{ 0,	{ max_scale, max_scale } },
				{ 1,	{ max_scale, max_scale } },
			} )
	end
end

local max_lifetime = 2
local min_lifetime = 2

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local emitter = inst.entity:AddParticleEmitter()
	inst:AddTag("FX")
	inst:AddTag("INTERIOR_LIMBO_IMMUNE")

	InitEnvelope()

	emitter:SetRenderResources( texture, shader )
	emitter:SetRotationStatus( true )
	emitter:SetMaxNumParticles( 4800 )
	emitter:SetMaxLifetime( max_lifetime )
	emitter:SetColourEnvelope( colour_envelope_name )
	emitter:SetScaleEnvelope( scale_envelope_name );
	emitter:SetBlendMode( BLENDMODE.Premultiplied )
	emitter:SetSortOrder( 3 )
	emitter:SetDragCoefficient( 0.2 )
	emitter:EnableDepthTest( true )

	-----------------------------------------------------
	local rng = math.random
	local tick_time = TheSim:GetTickTime()

	local desired_particles_per_second = 0--1000
	local desired_splashes_per_second = 0--100

	inst.particles_per_tick = desired_particles_per_second * tick_time
	inst.splashes_per_tick = desired_splashes_per_second * tick_time
	inst.ice_per_tick = 0

	local emitter = inst.ParticleEmitter

	inst.num_particles_to_emit = inst.particles_per_tick
	inst.num_splashes_to_emit = 0
	inst.num_ice_to_emit = 0

	local bx, by, bz = 0, 20, 0
	local emitter_shape = CreateBoxEmitter( bx, by, bz, bx + 20, by, bz + 20 )

	local angle = 0
	local dx = math.cos( angle * PI / 180 )
	emitter:SetAcceleration( dx, -9.80, 1 )

	local emit_fn = function()
		local vy = -2 + UnitRand() * -8
		local vz = 0
		local vx = dx

		local lifetime = min_lifetime + ( max_lifetime - min_lifetime ) * UnitRand()
		local px, py, pz = emitter_shape()

		emitter:AddRotatingParticle(
			lifetime,			-- lifetime
			px, py, pz,			-- position
			vx, 0.125*vy, vz,			-- velocity
			angle, 0			-- angle, angular_velocity
		)
	end
	
	local haildrop_offset = CreateDiscEmitter( 20 )
	
	local updateFunc = function()
		while inst.num_particles_to_emit > 0 do
			emit_fn( emitter )
			inst.num_particles_to_emit = inst.num_particles_to_emit - 1
		end

		if GetWorld().Map ~= nil then
			while inst.num_splashes_to_emit > 0 do
				local x, y, z = GetPlayer().Transform:GetWorldPosition()
				local dx, dz = haildrop_offset()

				x = x + dx
				z = z + dz

				local haildrop = SpawnPrefab( "haildrop" )
				haildrop.Transform:SetPosition( x, y, z )
				
				inst.num_splashes_to_emit = inst.num_splashes_to_emit - 1
			end

			while inst.num_ice_to_emit > 0 do
				local x, y, z = GetPlayer().Transform:GetWorldPosition()
				local dx, dz = haildrop_offset()

				x = x + dx
				z = z + dz

				local hail = SpawnPrefab("hail_ice")
				hail:StartFalling(x, y, z)
				
				inst.num_ice_to_emit = inst.num_ice_to_emit - 1
			end
		end

		inst.num_particles_to_emit = inst.num_particles_to_emit + inst.particles_per_tick
		inst.num_splashes_to_emit = inst.num_splashes_to_emit + inst.splashes_per_tick
		inst.num_ice_to_emit = inst.num_ice_to_emit + inst.ice_per_tick
	end

	EmitterManager:AddEmitter( inst, nil, updateFunc )

    return inst
end

return Prefab( "common/fx/hail", fn, assets, prefabs ) 
