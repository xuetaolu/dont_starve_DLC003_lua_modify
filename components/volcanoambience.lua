
local VolcanoAmbience = Class(function(self, inst)
	self.inst = inst
	self.quake_timer = 0
	self.ash = nil

	self.inst:StartUpdatingComponent(self)
end)

function VolcanoAmbience:GetDebugString()
	return string.format("quake %4.2f", self.quake_timer)
end

function VolcanoAmbience:MiniQuake()
	local duration = 0.7

	self.inst.SoundEmitter:PlaySound("dontstarve/cave/earthquake", "miniearthquake")
	self.inst.SoundEmitter:SetParameter("miniearthquake", "intensity", 0.08)
	TheCamera:Shake("FULL", duration, 0.02, .2)

	self.inst:DoTaskInTime(duration, function() self.inst.SoundEmitter:KillSound("miniearthquake") end)
end

function VolcanoAmbience:WarnQuake()
	local duration = 1.0
	
	self.inst.SoundEmitter:PlaySound("dontstarve/cave/earthquake", "earthquake")
	self.inst.SoundEmitter:SetParameter("earthquake", "intensity", 1)
	TheCamera:Shake("FULL", duration, 0.02, .75)

	self.inst:DoTaskInTime(duration, function() self.inst.SoundEmitter:KillSound("earthquake") end)
end

function VolcanoAmbience:OnUpdate(dt)
	local vm = GetWorld().components.volcanomanager

	--[[if self.quake_timer > 0 then
		self.quake_timer = self.quake_timer - dt
		if self.quake_timer <= 0 then
			if vm:IsActive() then
				self:WarnQuake()
			elseif vm:IsDormant() then
				self:MiniQuake()
			end
		end
	else
		if vm:IsActive() then
			self.quake_timer = 5
		elseif vm:IsDormant() then
			self.quake_timer = 20
		end
	end]]

	if not self.ash then
		self.ash = SpawnPrefab("ashfx")
		self.ash.entity:SetParent( GetPlayer().entity )
	end

	if vm:IsActive() then
		self.ash.particles_per_tick = 6
	elseif vm:IsDormant() then
		self.ash.particles_per_tick = 1
	else
		self.ash.particles_per_tick = 0
	end
end

return VolcanoAmbience