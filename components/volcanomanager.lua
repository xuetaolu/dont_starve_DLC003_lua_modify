
local WARN_QUAKE_DURATION = 0.7

-- waits 'delay' frames before actually listening for the event
local function EventLoader(inst, delay)
	if delay > 0 then
		inst:DoTaskInTime(0, EventLoader, delay-1)
	else
		inst:ListenForEvent("seasonChange", function(it, data)
			if data.season == SEASONS.DRY then
				inst.components.volcanomanager:StartDrySeason()
			end
		end)
	end
end

local VolcanoManager = Class(function(self, inst)
	self.inst = inst
	self.volcanoes = {}
	self.schedule = {}
	self.schedulesegs = {} --segments in the sechdule
	self.highest_schedule_seg = 0
	self.appeasesegs = 0
	self.staffstartseg = 0
	self.firerain_timer = 0
	self.firerain_delay = 0
	self.firerain_duration = 0
	self.firerain_spawn_rate = 0
	self.firerain_spawn_per_sec = 0
	self.firerain_intensity = 1.0
	self.smoke_timer = 0
	self.smoke_delay = 0
	self.smoke_duration = 0
	self.ash_timer = 0
	self.ash_delay = 0
	self.ash_duration = 0
	self.ash = nil
	self.intensity = 1.0 -- 1.0 = normal
	self.waserupting = false 

	-- gjans: We can't distinguish between loading events from the season manager and actual organic season changes, and since we use
	-- that event to "reset" the schedule, we'll just not listen for events until after loading (and the first DoTaskInTime(0,..) from 
	-- seasonmanager) have finished.
	EventLoader(self.inst, 2)
end)

function VolcanoManager:DoWarnQuake(duration, speed, scale)
	duration = duration or WARN_QUAKE_DURATION
	speed = speed or 0.02
	scale = scale or .75
	TheCamera:Shake("FULL", duration, speed, scale)
	self.inst.SoundEmitter:PlaySound("dontstarve/cave/earthquake", "earthquake")
	self.inst.SoundEmitter:SetParameter("earthquake", "intensity", 0.08)
	self.inst:DoTaskInTime(duration, function() self.inst.SoundEmitter:KillSound("earthquake") end)

	local player = GetPlayer()
	player.components.talker:Say(GetString(player.prefab, "ANNOUNCE_QUAKE"))
end

function VolcanoManager:DoEruptQuake(duration, speed, scale)
	duration = duration or 4.0
	speed = speed or 0.02
	scale = scale or 2.0
	TheCamera:Shake("FULL", duration, speed, scale)

	local player = GetPlayer()
	player.components.talker:Say(GetString(player.prefab, "ANNOUNCE_VOLCANO_ERUPT"))
	self.inst:PushEvent("OnVolcanoWarningQuake")
end

function VolcanoManager:DoEruption(data)
	if not data then
		print("DoEruption no data!")
		return
	end

	self:DoEruptQuake()
	self:StartSmoke(data.smoke_duration, data.smoke_delay)
	self:StartAshRain(data.ash_duration, data.ash_delay)
	self:StartFireRain(data.firerain_duration, data.firerain_delay, data.firerain_per_sec)
	self.waserupting = true 
	self.inst.SoundEmitter:PlaySound("dontstarve/cave/earthquake", "earthquake")
	self.inst.SoundEmitter:SetParameter("earthquake", "intensity", 0.08)
	self.inst:DoTaskInTime(data.firerain_duration + data.firerain_delay, function() self.inst.SoundEmitter:KillSound("earthquake") end)

	self.inst:PushEvent("OnVolcanoEruptionBegin")
end

function VolcanoManager:SpawnFireRain(x, y, z)
	local firerain
	if math.random() <= TUNING.VOLCANO_DRAGOONEGG_CHANCE then
		firerain = SpawnPrefab("dragoonegg_falling")
	else
		firerain = SpawnPrefab("firerain")
	end
	firerain.Transform:SetPosition(x, y, z)
	firerain:StartStep()
end

function VolcanoManager:RebuildDrySchedule()
	if self.intensity > 0.0 then
		print("VolcanoManager rebuilding schedule")
		local volcanoschedule = require("map/volcanoschedule")
		self.schedule[1], self.schedulesegs[1] = self:BuildSchedule(volcanoschedule.DrySeasonSchedule, self.highest_schedule_seg)
		self.inst:DoTaskInTime(1, function() self:SetActiveIcon() end)
		self.inst:StartUpdatingComponent(self)
	end
end

function VolcanoManager:StartDrySeason()
	print("VolcanoManager starting dry season")
	self.highest_schedule_seg = 0
	self:RebuildDrySchedule()
end

function VolcanoManager:StartEruption(smoke_duration, ash_duration, firerain_duration, firerain_spawn_per_sec)
	print("VolcanoManager start eruption", smoke_duration, ash_duration, firerain_duration, firerain_spawn_per_sec)
	local data =
	{
		firerain_delay=0, firerain_duration=firerain_duration, firerain_per_sec=firerain_spawn_per_sec,
		smoke_delay=0, smoke_duration=smoke_duration,
		ash_delay=0, ash_duration=ash_duration
	}
	self:DoEruption(data)
	self.inst:StartUpdatingComponent(self)
end

function VolcanoManager:ResumeStaffTrap(startsegs)
	print("VolcanoManager resume staff trap", startsegs)
	local volcanoschedule = require("map/volcanoschedule")
	self.staffstartseg = startsegs
	self.schedule[2], self.schedulesegs[2] = self:BuildSchedule(volcanoschedule.StaffTrapSchedule, self:GetCurrentStaffScheduleSegment())
	--self:Appease(self.schedulesegs[2]) --treat staff trap as appeasement to delay dry schedule
	self.inst:DoTaskInTime(1, function() self:SetActiveIcon() end)
	self.inst:StartUpdatingComponent(self)
end

function VolcanoManager:StartStaffTrap()
	print("VolcanoManager start staff trap")
	--self:DoWarnQuake()
	self:ResumeStaffTrap(math.floor(16 * (GetClock():GetNumCycles() + GetClock():GetNormTime())))
end

function VolcanoManager:StartStaffEffect(ash_timer)
	print("VolcanoManager start staff effect")
	self:DoEruptQuake()
	self:StartAshRain(ash_timer, 0)
	self.inst:StartUpdatingComponent(self)
end

function VolcanoManager:Stop()
	print("VolcanoManager stop")

	self.inst.SoundEmitter:KillSound("earthquake")
	self.appeasesegs = 0
	self:StopAshRain()
	self:StopFireRain()
	self.inst:StopUpdatingComponent(self)
end

function VolcanoManager:StartFireRain(firerain_duration, firerain_delay, firerain_spawn_per_sec)
	self.firerain_delay = firerain_delay
	self.firerain_duration = firerain_duration
	self.firerain_timer = self.firerain_delay + self.firerain_duration
	self.firerain_spawn_rate = 0.0
	self.firerain_spawn_per_sec = firerain_spawn_per_sec
end

function VolcanoManager:StopFireRain()
	self.firerain_timer = 0.0
	self.firerain_spawn_rate = 0.0
	self.firerain_spawn_per_sec = 0.0
end

function VolcanoManager:StartAshRain(ash_duration, ash_delay)
	self.ash_delay = ash_delay
	self.ash_duration = ash_duration
	self.ash_timer = self.ash_delay + self.ash_duration
	self.inst:PushEvent("ashstart")
end

function VolcanoManager:StopAshRain()
	if self.ash then
		self.ash:Remove()
	end
	self.ash = nil
	self.ash_timer = 0.0
	self.ash_delay = 0.0
	self.ash_duration = 0.0
	self.inst:PushEvent("ashstop")
end

function VolcanoManager:StartSmoke(smoke_duration, smoke_delay)
	self.smoke_delay = smoke_delay
	self.smoke_duration = smoke_duration
	self.smoke_timer = self.smoke_delay + self.smoke_duration
end

function VolcanoManager:StopSmoke()
	self.smoke_timer = 0.0
	self.smoke_delay = 0.0
	self.smoke_duration = 0.0
end

function VolcanoManager:RunSchedule(schedule, segs)
	if schedule and schedule[segs] then
		for i = 1, #schedule[segs], 1 do
			schedule[segs][i].fn(self, schedule[segs][i].data)
		end
		schedule[segs] = {}
	end
	self.highest_schedule_seg = math.max(self.highest_schedule_seg, segs)
end

function VolcanoManager:GetCurrentScheduleSegment()
	local sm = GetSeasonManager()
	local cycles = sm:GetPercentSeason() * sm:GetSeasonLength(SEASONS.DRY)
	local normTime = GetClock():GetNormTime()
	return math.floor(16 * (cycles + normTime)) - self.appeasesegs
end

function VolcanoManager:GetCurrentStaffScheduleSegment()
	return math.floor(16 * (GetClock():GetNumCycles() + GetClock():GetNormTime())) - self.staffstartseg
end

function VolcanoManager:GetDebugString()
	local sm = GetSeasonManager()
	local clock = GetClock()
	local cycles = clock:GetNumCycles()
	local normtime = clock:GetNormTime()
	local cursegs = math.floor(16 * (cycles + normtime))
	local str = "Volcano\n"
	
	if self.schedule[1] then
		str = str .. string.format("  dry segs %d, season %4.2f\n", self:GetCurrentScheduleSegment(), sm:GetPercentSeason())
	end
	if self.schedule[2] then
		str = str .. string.format("  staff segs %d, start seg %d\n", cursegs - self.staffstartseg, self.staffstartseg)
	end

	str = str .. string.format("  next quake %d, next eruption %d\n  cycles %d, normtime %f, cursegs %d\n  firerain timer %4.2f, delay %4.2f, dur %4.2f, int %4.2f, rate %4.2f, %4.2f/s\n  ash timer %4.2f, delay %4.2f, dur %4.2f, %d particles/tick\n  smoke timer %4.2f, delay %4.2f, dur %4.2f, rate %4.2f\n  appease segs %4.2f\n",
		self:GetNumSegmentsUntilQuake() or 0, self:GetNumSegmentsUntilEruption() or 0,
		cycles, normtime, cursegs,
		self.firerain_timer, self.firerain_delay, self.firerain_duration, self.firerain_intensity, self.firerain_spawn_rate, self.firerain_spawn_per_sec,
		self.ash_timer, self.ash_delay, self.ash_duration, (self.ash and self.ash.particles_per_tick) or 0,
		self.smoke_timer, self.smoke_delay, self.smoke_duration, self:GetSmokeRate(),
		self.appeasesegs)

	return str
end

function VolcanoManager:OnUpdate( dt )
	--print(self:GetDebugString())

	if self.schedule[1] then
		if GetSeasonManager():IsDrySeason() then
			local segs = self:GetCurrentScheduleSegment() 
			--print(string.format("segs %d (%d), %f, %f\n", segs, get_segs(), GetSeasonManager():GetPercentSeason(), GetClock():GetNormTime()))
			self:RunSchedule(self.schedule[1], segs)
			if segs > self.schedulesegs[1] then
				self:SetDormantIcon()
				self.schedule[1] = {}
			end
		else
			self:SetDormantIcon()
			self.schedule[1] = {}
		end
	end

	if self.schedule[2] then
		--local cursegs = math.floor(16 * (GetClock():GetNumCycles() + GetClock():GetNormTime()))
		local segs = self:GetCurrentStaffScheduleSegment() --cursegs - self.staffstartseg
		--print(string.format("segs %f, cursegs %f, cycles %d, normtime %f", segs, cursegs, GetClock():GetNumCycles(), GetClock():GetNormTime()))
		self:RunSchedule(self.schedule[2], segs)
		if segs > self.schedulesegs[2] then
			self:SetDormantIcon()
			self.schedule[2] = {}
		end
	end

	--update fire rain
	if self.firerain_timer > 0.0 and self.firerain_intensity > 0.0 then
		self.firerain_timer = self.firerain_timer - dt
		if self.firerain_timer <= self.firerain_duration then
			self.firerain_spawn_rate = self.firerain_spawn_rate + self.firerain_spawn_per_sec * self.firerain_intensity * dt
			while self.firerain_spawn_rate > 1.0 do
				local interiorSpawner =GetInteriorSpawner() 
				
				local px, py, pz = GetPlayer().Transform:GetWorldPosition()
				if interiorSpawner:IsPlayerConsideredInside() then
					px, py, pz = interiorSpawner:GetInteriorEntryPosition()				
				end

			    local x, y, z = TUNING.VOLCANO_FIRERAIN_RADIUS * UnitRand() + px, py, TUNING.VOLCANO_FIRERAIN_RADIUS * UnitRand() + pz
			    self:SpawnFireRain(x, y, z)
				self.firerain_spawn_rate = self.firerain_spawn_rate - 1.0
			end
		end
		if self.firerain_timer <= 0.0 then
			self.inst:PushEvent("OnVolcanoFireRainEnd")
		end
	end

	--update ash rain
	if self.ash_timer > 0.0 then
		self.ash_timer = self.ash_timer - dt
		if self.ash_timer <= self.ash_duration then
			if not self.ash then
				self.ash = SpawnPrefab( "ashfx" )
				self.ash.entity:SetParent( GetPlayer().entity )
			end
			self.ash.particles_per_tick = 20 * math.min(self.ash_timer / self.ash_duration, 1.0)
		elseif self.ash then
			self.ash.particles_per_tick = 0
		end
	elseif self.ash then
		self.ash.particles_per_tick = 0
	end

	if GetInteriorSpawner():IsPlayerConsideredInside() then
		if self.ash then		
			self.ash.particles_per_tick = 0
		end
	end

	if self.smoke_timer > 0.0 then
		self.smoke_timer = self.smoke_timer - dt
	end

	if self.waserupting and not self:IsErupting() then 
		self.waserupting = false
		self.inst:PushEvent("OnVolcanoEruptionEnd")
	end 

	if self:IsDormant() or self.intensity <= 0.0 then
		self:Stop()
	end
end

function VolcanoManager:LongUpdate(dt)
	--self:OnUpdate(dt)
end

function VolcanoManager:OnSave()
	return
	{
		appeasesegs = self.appeasesegs,
		staffstartseg = self.staffstartseg,
		highest_schedule_seg = self.highest_schedule_seg,
		firerain_timer = self.firerain_timer,
		firerain_delay = self.firerain_delay,
		firerain_duration = self.firerain_duration,
		firerain_spawn_per_sec = self.firerain_spawn_per_sec,
		firerain_intensity = self.firerain_intensity,
		smoke_timer = self.smoke_timer,
		smoke_delay = self.smoke_delay,
		smoke_duration = self.smoke_duration,
		ash_timer = self.ash_timer,
		ash_delay = self.ash_delay,
		ash_duration = self.ash_duration,
		erupting = self.waserupting,
		intensity = self.intensity,
		dry = self.schedule[1] ~= nil,
		staff = self.schedule[2] ~= nil
	}
end

function VolcanoManager:OnLoad(data)
	if data then
		self.appeasesegs = data.appeasesegs or self.appeasesegs
		self.staffstartseg = data.staffstartseg or self.staffstartseg
		self.highest_schedule_seg = data.highest_schedule_seg or self:GetCurrentScheduleSegment()
		self.firerain_timer = data.firerain_timer or self.firerain_timer
		self.firerain_delay = data.firerain_delay or self.firerain_delay
		self.firerain_duration = data.firerain_duration or self.firerain_duration
		self.firerain_spawn_per_sec = data.firerain_spawn_per_sec or self.firerain_spawn_per_sec
		self.firerain_intensity = data.firerain_intensity or self.firerain_intensity
		self.smoke_timer = data.smoke_timer or self.smoke_timer
		self.smoke_delay = data.smoke_delay or self.smoke_delay
		self.smoke_duration = data.smoke_duration or self.smoke_duration
		self.ash_timer = data.ash_timer or self.ash_timer
		self.ash_delay = data.ash_delay or self.ash_delay
		self.ash_duration = data.ash_duration or self.ash_duration
		self.waserupting = data.erupting or self.waserupting
		self.intensity = data.intensity or self.intensity
		local dry = data and data.dry
		local staff = data and data.staff

		if dry then
			print("restart dry schedule")
			self:RebuildDrySchedule()
		end
		if staff then
			print("restart staff schedule", self.staffstartseg)
			self:ResumeStaffTrap(self.staffstartseg)
		end
		if self.smoke_timer > 0 or self.ash_timer > 0 or self.firerain_timer > 0 then
			print("restart eruption")
			self.inst:StartUpdatingComponent(self)
			if self.firerain_timer < self.firerain_duration then 
				self.inst.SoundEmitter:PlaySound("dontstarve/cave/earthquake", "earthquake")
				self.inst.SoundEmitter:SetParameter("earthquake", "intensity", 0.08)
				self.inst:DoTaskInTime(self.firerain_timer, function() self.inst.SoundEmitter:KillSound("earthquake") end)
			end 
		end
	end
end

function VolcanoManager:AddVolcano(inst)
	self.volcanoes[inst] = inst
end

function VolcanoManager:RemoveVolcano(inst)
	self.volcanoes[inst] = nil
end

function VolcanoManager:SetActiveIcon()
	for k, v in pairs(self.volcanoes) do
		if v.MiniMapEntity then
			v.MiniMapEntity:SetIcon("volcano_active.png")
		end
	end
end

function VolcanoManager:SetDormantIcon()
	for k, v in pairs(self.volcanoes) do
		if v.MiniMapEntity then
			v.MiniMapEntity:SetIcon("volcano.png")
		end
	end
end

function VolcanoManager:GetClosestVolcano()
	local closest = nil 
	local closestdistsq = nil
	for k,v in pairs(self.volcanoes) do
		if v then
			local x, y, z = GetPlayer().Transform:GetWorldPosition()
			local vx, vy, vz = v.Transform:GetWorldPosition()
			local dx, dy, dz = x - vx, y - vy, z - vz
			local distSq = dx * dx + dy * dy + dz * dz
			if closest == nil or distSq < closestdistsq then 
				closestdistsq = distSq
				closest = v
			end 
		end
	end
	return closest

end 

function VolcanoManager:GetDistanceFromVolcano(x, y, z)
	local dist = 100000000
	for k,v in pairs(self.volcanoes) do
		if v then
			local x, y, z = GetPlayer().Transform:GetWorldPosition()
			local vx, vy, vz = v.Transform:GetWorldPosition()
			local dx, dy, dz = x - vx, y - vy, z - vz
			local distSq = dx * dx + dy * dy + dz * dz
			dist = math.sqrt(math.min(dist, distSq))
		end
	end
	return dist
end

function VolcanoManager:GetSmokeRate()
	if GetInteriorSpawner():IsPlayerConsideredInside() then 
		return 0.0
	end
	if 0.0 < self.smoke_timer and self.smoke_timer <= self.smoke_duration then
		return self.smoke_timer / self.smoke_duration
	end
	return 0.0
end

function VolcanoManager:SetIntensity(intensity)
	self.intensity = intensity
end

function VolcanoManager:SetFirerainIntensity(intensity)
	self.firerain_intensity = intensity
end

function VolcanoManager:IsActive()
	--return not self:IsDormant()
	return (self.schedule[1] ~= nil and GetSeasonManager():IsDrySeason()) or self.schedule[2] ~= nil
end

function VolcanoManager:IsFireRaining()
	return self.firerain_timer > 0
end

function VolcanoManager:IsErupting()
	--return self.state == STATE_ERUPT
	--return self.firerain_timer > 0.0
	return self.smoke_timer > 0 or self.ash_timer > 0 or self:IsFireRaining()
end

function VolcanoManager:IsDormant()
	--return self.firerain_timer <= 0.0
	return not self:IsActive() and not self:IsErupting()
end

local warnquake =
{
	["small"] = {duration = 0.7/2, speed = 0.02, scale = 0.75/2},
	["med"] = {duration = 0.7, speed = 0.02, scale = 0.75},
	["large"] = {duration = 2*0.7, speed = 0.02, scale = 2*0.75},
}

local function DoWarnQuake(inst, data)
	print("Warn Quake")
	if data and data.size and warnquake[data.size] then
		inst:DoWarnQuake(warnquake[data.size].duration, warnquake[data.size].speed, warnquake[data.size].scale)
	else
		inst:DoWarnQuake()
	end
end

local function DoEruption(inst, data)
	print("Erupt!")
	inst:DoEruption(data) --(60.0, 60.0, 60.0, 1 / 8)
end

function VolcanoManager:BuildSchedule(scheduledef, startseg)
	local newschedule = {}

	startseg = startseg or 0

	local lasterupt = 0
	local segs = 0
	for i = 1, #scheduledef, 1 do
		local erupt = scheduledef[i]
		segs = segs + 16 * (erupt.days or 0) + (erupt.segs or 0)
		if segs > startseg then
			if erupt.warnquake then
				for j = 1, #erupt.warnquake, 1 do
					local quakesegs = segs - erupt.warnquake[j].segsprev
					if quakesegs >= 0 and quakesegs >= startseg then
						if newschedule[quakesegs] == nil then
							newschedule[quakesegs] = {}
						end
						--print(string.format("warnquake %d", quakesegs))
						table.insert(newschedule[quakesegs], {fn=DoWarnQuake, data={size=erupt.warnquake[j].size}})
					end
				end
			end
			if newschedule[segs] == nil then
				newschedule[segs] = {}
			end

			local data = {}
			if erupt.data == nil then
				erupt.data = {}
			end
			local seg_time = TUNING.SEG_TIME
			data.firerain_delay = (erupt.data.firerain_delay or 0) * seg_time
			data.firerain_duration = (erupt.data.firerain_duration or 1) * seg_time
			data.firerain_per_sec = erupt.data.firerain_per_sec or 0.125
			data.ash_delay = (erupt.data.ash_delay or 0) * seg_time
			data.ash_duration = (erupt.data.ash_duration or 1) * seg_time
			data.smoke_delay = (erupt.data.smoke_delay or 0) * seg_time
			data.smoke_duration = (erupt.data.smoke_duration or 1) * seg_time
			data.total_segs = segs - lasterupt

			lasterupt = segs + (erupt.data.firerain_delay or 0) + (erupt.data.firerain_duration or 1)

			--print(string.format("erupt %d, %d, %4.2f", segs, data.total_segs, math.max(math.max(data.firerain_delay + data.firerain_duration, data.ash_delay + data.ash_duration), data.smoke_delay + data.smoke_duration) / seg_time))
			table.insert(newschedule[segs], {fn=DoEruption, data=data})
		else
			if erupt.data == nil then
				erupt.data = {}
			end
			lasterupt = segs + (erupt.data.firerain_delay or 0) + (erupt.data.firerain_duration or 1)
		end
	end

	--[[print("Volcano Schedule: segs", segs)
	for k, v in pairs(newschedule) do
		for i = 1, #v, 1 do
			--print(string.format("   %d %s\n", k, tostring(v[i])))
		end
	end]]

	return newschedule, segs
end

local function segs_until_event(eventfn, schedule, currentSeg)
	if schedule then
		local earliest = nil
		local ev = nil

		for k, v in pairs(schedule) do
			for i = 1, #v, 1 do
				if v[i].fn == eventfn then
					local seg = k 
					if earliest == nil or (seg > currentSeg and seg < earliest) then
						earliest = seg
						ev = v[i]
					end
				end
			end
		end
		if earliest then
			return earliest - currentSeg, ev
		end
	end
	return nil, nil
end

function VolcanoManager:GetNumSegmentsUntilEvent(eventfn)
	local dry, dryev = segs_until_event(eventfn, self.schedule[1], self:GetCurrentScheduleSegment())
	local staff, staffev = segs_until_event(eventfn, self.schedule[2], self:GetCurrentStaffScheduleSegment())
	if not dry and not staff then
		return nil
	end
	return math.min(dry or math.huge, staff or math.huge)
end 

function VolcanoManager:GetNumSegmentsUntilEruption()
	return self:GetNumSegmentsUntilEvent(DoEruption)
end 

function VolcanoManager:GetNumSegmentsUntilQuake()
	return self:GetNumSegmentsUntilEvent(DoWarnQuake)
end 

function VolcanoManager:GetNumSegmentsOfEruption()
	local dry, dryev = segs_until_event(DoEruption, self.schedule[1], self:GetCurrentScheduleSegment())
	if dry and dryev and dryev.data and dryev.data.total_segs then
		return dryev.data.total_segs
	end
	return 66
end

function VolcanoManager:GetNextEruptionEvent()
	local ev = nil
	local dry, dryev = segs_until_event(DoEruption, self.schedule[1], self:GetCurrentScheduleSegment())
	local staff, staffev = segs_until_event(DoEruption, self.schedule[2], self:GetCurrentStaffScheduleSegment())
	if dryev and staffev then
		if dry < staff then
			ev = dryev
		else
			ev = staffev
		end
	elseif dryev then
		ev = dryev
	elseif staffev then
		ev = staffev
	end
	return ev
end

function VolcanoManager:Appease(segs)
	if segs < 0 then --Schedule is getting pushed forward from a wrath item 
		local numSegs = math.abs(segs)
		local doquake = false 
		local doerupt = false 
		
		local segsuntilquake = self:GetNumSegmentsUntilQuake() 
		local segsuntilerupt = self:GetNumSegmentsUntilEruption()

		if segsuntilquake and segsuntilquake < numSegs then 
			doquake = true 
		end 

		if segsuntilerupt and segsuntilerupt < numSegs then 
			doerupt = true 
		end 

		if doquake then 
			print("Wrath causing warn quake")
			DoWarnQuake(self)
			if doerupt then 
				print("and eruption")
				self.inst:DoTaskInTime(WARN_QUAKE_DURATION + 1.0 , function()
					local erupt = self:GetNextEruptionEvent()
					DoEruption(self, erupt.data)
				end)
			end 
		elseif doerupt then 
			print("Wrath causing eruption")
			DoEruption(self)
		end 

	end 
	self.appeasesegs = self.appeasesegs + segs
end

return VolcanoManager
