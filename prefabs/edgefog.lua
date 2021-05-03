require("tuning")

local texture = "levels/textures/ds_fog1.tex"
local shader = "shaders/particle.ksh"
local colour_envelope_name = "edgefogcolourenvelope"
local scale_envelope_name = "edgefogscaleenvelope"

local assets =
{
	Asset( "IMAGE", texture ),
	Asset( "SHADER", shader ),
}

local max_scale = 10

local init = false
local function InitEnvelopes()
	if EnvelopeManager and not init then
		init = true
		EnvelopeManager:AddColourEnvelope(
			colour_envelope_name,
			{	{ 0,	{ 1, 1, 1, 0 } },
				{ 0.1,	{ 1, 1, 1, 1 } },
				{ 0.75,	{ 1, 1, 1, 1 } },
				{ 1,	{ 1, 1, 1, 0 } },
			} )

		EnvelopeManager:AddVector2Envelope(
			scale_envelope_name,
			{	{ 0,	{ 6, 6 } },
				{ 1,	{ max_scale, max_scale } },
			} )
	end
end

local function area_emitter()
	local px, py, pz = GetPlayer().Transform:GetWorldPosition()
	local map = GetWorld().Map
	local w, h = map:GetSize()
	local halfw, halfh = 0.5 * w * TILE_SCALE, 0.5 * h * TILE_SCALE
	local distx = math.min(halfw + px, halfw - px)
	local distz = math.min(halfh + pz, halfh - pz)
	local cloud_range = TUNING.MAPWRAPPER_EDGEFOG_RANGE * TILE_SCALE
	local min_range = cloud_range + 100
	local range = 10 * TILE_SCALE

	local getx = function(distx)
		local x, z = 0, math.random(-range, range)
		if px < 0 then
			x = -halfw + math.random(0, cloud_range) - px
		else
			x = halfw - math.random(0, cloud_range) - px
		end
		return x, z
	end

	local getz = function(distz)
		local x, z = math.random(-range, range), 0
		if pz < 0 then
			z = -halfh + math.random(0, cloud_range) - pz
		else
			z = halfh - math.random(0, cloud_range) - pz
		end
		return x, z
	end

	local x, z = 0, 0
	if distx <= min_range and distz <= min_range then
		if math.random() < 0.5 then
			x, z = getx(distx)
		else
			x, z = getz(distz)
		end
	elseif distx <= min_range then
		x, z = getx(distx)
	else
		x, z = getz(distz)
	end

	--print(string.format("\nplayer (%4.2f, %4.2f), dist (%4.2f, %4.2f) (%4.2f, %4.2f)", px, pz, distx, distz, x, z))

	return x, z
end

local max_num_particles = 1000
local max_lifetime = 5
local ground_height = 0.4
local emitter_radius = 25

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	inst:AddTag("FX")

	inst.entity:SetParent(GetPlayer().entity)
	
	InitEnvelopes()

	local emitter = inst.entity:AddParticleEmitter()
	emitter:SetRenderResources( texture, shader )
	emitter:SetMaxNumParticles( max_num_particles)
	emitter:SetMaxLifetime( max_lifetime )
	emitter:SetSpawnVectors( -1, 0, 1, 1, 0, 1 ) --( config.SV[1].x, config.SV[1].y, config.SV[1].z, config.SV[2].x, config.SV[2].y, config.SV[2].z)
	emitter:SetSortOrder( 3 )
	emitter:SetColourEnvelope( colour_envelope_name )
	emitter:SetScaleEnvelope( scale_envelope_name );
	emitter:SetRadius(emitter_radius)

	local tick_time = TheSim:GetTickTime()
	local desired_particles_per_second = 20

	inst.num_particles_to_emit = 0
	inst.particles_per_tick = desired_particles_per_second * tick_time

	local emit_fn = function()
		--print("emit....")
		local vx, vy, vz = 0.01 * UnitRand(), 0, 0.01 * UnitRand()
		local lifetime = max_lifetime * ( 0.9 + UnitRand() * 0.1 )
		local px, pz

		local py = ground_height
		
		px, pz = area_emitter()
		--print("px", px, "py", py, "pz", pz, "lifetime", lifetime)
		emitter:AddParticle(
			lifetime,			-- lifetime
			px, py, pz,			-- position
			vx, vy, vz			-- velocity
		)
		--print("emit.... complete")
	end
	
	local updateFunc = function()
		--print("emit updateFunc....", inst.num_particles_to_emit)
		while inst.num_particles_to_emit > 1 do
			emit_fn( emitter )
			inst.num_particles_to_emit = inst.num_particles_to_emit - 1
		end

		inst.num_particles_to_emit = inst.num_particles_to_emit + inst.particles_per_tick
		--print("emit updateFunc.... complete")
	end
	
	EmitterManager:AddEmitter( inst, nil, updateFunc )

    return inst
end

return Prefab( "common/fx/edgefog", fn, assets) 
 
