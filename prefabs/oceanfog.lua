local texture = "levels/textures/ds_fog1.tex"
local shader = "shaders/particle.ksh"
--local colour_envelope_name = "oceanfogcolourenvelope"
local scale_envelope_name = "oceanfogscaleenvelope"

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
			"oceanfogcolourenvelope",
			{	{ 0,	{ 1, 1, 1, 0 } },
				{ 0.1,	{ 1, 1, 1, 0.24 } },
				{ 0.75,	{ 1, 1, 1, 0.24 } },
				{ 1,	{ 1, 1, 1, 0 } },
			} )

		EnvelopeManager:AddColourEnvelope(
			"volcanofogcolourenvelope",
			{	{ 0,	{ 1, 1, 1, 0 } },
				{ 0.1,	{ 1, 1, 1, 0.12 } },
				{ 0.75,	{ 1, 1, 1, 0.12 } },
				{ 1,	{ 1, 1, 1, 0 } },
			} )

		EnvelopeManager:AddVector2Envelope(
			scale_envelope_name,
			{	{ 0,	{ 6, 6 } },
				{ 1,	{ max_scale, max_scale } },
			} )
	end
end

local max_lifetime = 15
local max_num_particles = 16 * max_lifetime
local ground_height = 0.4
local emitter_radius = 50

--local function area_emitter()
--	return emitter_radius * UnitRand(), emitter_radius * UnitRand()
--end

local function emit_fn(emitter, radius)
	--print("emit....")
	local vx, vy, vz = 0.01 * UnitRand(), 0, 0.01 * UnitRand()
	local lifetime = max_lifetime * ( 0.9 + UnitRand() * 0.1 )
	local px, pz

	local py = ground_height
	
	px, pz = radius * UnitRand(), radius * UnitRand() --area_emitter()
	--print("px", px, "py", py, "pz", pz, "lifetime", lifetime)
	emitter:AddParticle(
		lifetime,			-- lifetime
		px, py, pz,			-- position
		vx, vy, vz			-- velocity
	)
	--print("emit.... complete")
end

local function commonfn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	
	InitEnvelopes()

	local emitter = inst.entity:AddParticleEmitter()
	emitter:SetRenderResources( texture, shader )
	emitter:SetMaxNumParticles( max_num_particles)
	emitter:SetMaxLifetime( max_lifetime )
	emitter:SetSpawnVectors( -1, 0, 1, 1, 0, 1 ) --( config.SV[1].x, config.SV[1].y, config.SV[1].z, config.SV[2].x, config.SV[2].y, config.SV[2].z)
	emitter:SetSortOrder( 3 )
	emitter:SetScaleEnvelope( scale_envelope_name );
	emitter:SetRadius(emitter_radius)

	inst.num_particles_to_emit = 0

    return inst
end

local function oceanfn(Sim)
	local inst = commonfn(Sim)
	inst.ParticleEmitter:SetColourEnvelope("oceanfogcolourenvelope")
	inst.particles_per_tick = 8 * TheSim:GetTickTime()
	
	local function updateFunc()
		--print("emit updateFunc....", inst.num_particles_to_emit)
		local clock = GetClock()
		if clock:IsDay() then
			local t = clock:GetDaySegs() * clock:GetNormEraTime()
			if 0.0 <= t and t <= 2.0 then
				while inst.num_particles_to_emit > 1 do
					emit_fn( inst.ParticleEmitter, emitter_radius )
					inst.num_particles_to_emit = inst.num_particles_to_emit - 1
				end

				inst.num_particles_to_emit = inst.num_particles_to_emit + inst.particles_per_tick
			end
		end
		--print("emit updateFunc.... complete")
	end
	
	EmitterManager:AddEmitter( inst, nil, updateFunc )

	return inst
end

local function gravefn(Sim)
	local inst = commonfn(Sim)
	inst.ParticleEmitter:SetColourEnvelope("oceanfogcolourenvelope")
	inst.particles_per_tick = 1 * TheSim:GetTickTime()
	inst.radius = 2

	inst.ParticleEmitter:SetRadius(inst.radius)

	inst:AddComponent("scenariorunner")
	inst.components.scenariorunner:SetScript("fog_shipgrave")

	inst.SetRadius = function(inst, radius)
		inst.radius = radius
		inst.ParticleEmitter:SetRadius(inst.radius)
	end

	inst.OnSave = function(inst, data)
		data.radius = inst.radius
	end

	inst.OnLoad = function(inst, data)
		if data and data.radius then
			inst:SetRadius(data.radius)
		end
	end
	
	local function updateFunc()
		--print("emit updateFunc....", inst.num_particles_to_emit)
		while inst.num_particles_to_emit > 1 do
			emit_fn( inst.ParticleEmitter, inst.radius )
			inst.num_particles_to_emit = inst.num_particles_to_emit - 1
		end

		inst.num_particles_to_emit = inst.num_particles_to_emit + inst.particles_per_tick
		--print("emit updateFunc.... complete")
	end
	
	EmitterManager:AddEmitter( inst, nil, updateFunc )

	return inst
end

local function volcanofn(Sim)
	local inst = commonfn(Sim)
	inst.ParticleEmitter:SetColourEnvelope("volcanofogcolourenvelope")
	inst.particles_per_tick = 1 * TheSim:GetTickTime()

	local function updateFunc()
		--print("emit updateFunc....", inst.num_particles_to_emit)
		while inst.num_particles_to_emit > 1 do
			emit_fn( inst.ParticleEmitter, emitter_radius )
			inst.num_particles_to_emit = inst.num_particles_to_emit - 1
		end

		inst.num_particles_to_emit = inst.num_particles_to_emit + inst.particles_per_tick
		--print("emit updateFunc.... complete")
	end
	
	EmitterManager:AddEmitter( inst, nil, updateFunc )

	return inst
end

return Prefab( "common/fx/oceanfog", oceanfn, assets),
		Prefab( "common/fx/shipgravefog", gravefn, assets),
		Prefab( "common/fx/volcanofog", volcanofn, assets)
 
