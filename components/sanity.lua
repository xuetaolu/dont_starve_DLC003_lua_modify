local easing = require("easing")

local Sanity = Class(function(self, inst)
    self.inst = inst
    self.max = 100
    self.current = self.max
	
	self.rate = 0
	self.rate_modifiers = {}
	self.sane = true
	self.fxtime = 0
	self.dapperness = 0
	self.inducedinsanity = nil
	self.night_drain_mult = 1
	self.neg_aura_mult = 1
	self.wetnessImmune = false
	self.onInsane = nil

	self.dapperness_mult = 1

	self.penalty = 0

	self.inst:StartUpdatingComponent(self)
	self:Recalc(0)
end)

function Sanity:AddRateModifier(key, mod)
    self.rate_modifiers[key] = mod
end

function Sanity:RemoveRateModifier(key)
    self.rate_modifiers[key] = nil
end

function Sanity:GetRateModifier()
    local mod = 1
    for k,v in pairs(self.rate_modifiers) do
        mod = mod + v
    end
    return mod
end

function Sanity:IsSane()
	if self.inducedinsanity then
		return not self.inducedinsanity
	else
		return self.sane
	end
end

function Sanity:IsCrazy()
	if self.inducedinsanity then
		return self.inducedinsanity
	else
		return not self.sane
	end
end

function Sanity:RecalculatePenalty()
	self.penalty = 0
	for k,v in pairs(Ents) do
		if v.components.sanityaura and v.components.sanityaura.penalty then
			self.penalty = self.penalty + v.components.sanityaura.penalty
		end
	end
	self:DoDelta(0)
end

function Sanity:OnSave()
	return {
	current = self.current, 
	sane = self.sane, 
	penalty = self.penalty > 0 and self.penalty or nil
	}
end

function Sanity:OnLoad(data)

	if data.penalty then
		self.penalty = data.penalty
	end

	if data.sane ~= nil then
		self.sane = data.sane
	end

    if data.current then
        self.current = data.current
        self:DoDelta(0)
    end
    
	if not self.sane then
		if self.onInsane then
			self.onInsane(self.inst)
		end
		self.inst:PushEvent("goinsane", {})
	end
    
end

function Sanity:GetPenaltyPercent()
	return (self.penalty)/ self.max
end

function Sanity:GetMaxSanity()
	return (self.max - self.penalty)
end

function Sanity:GetPercent(usepenalty)
	if self.inducedinsanity then 
		return 0
	elseif usepenalty then
		return self.current/self:GetMaxSanity()
	else
	    return self.current / self.max
	end
end

function Sanity:SetPercent(per)
    local target = per * self.max
    local delta = target - self.current
    self:DoDelta(delta)
end

function Sanity:GetDebugString()
    return string.format("%2.2f / %2.2f at %2.4f. Penalty of %2.2f", self.current, self.max, self.rate, self.penalty)
end

function Sanity:SetMax(amount)
    self.max = amount
    self.current = amount
end

function Sanity:SetNightDrainMultiplier( new_mult )
	self.night_drain_mult = new_mult
end

function Sanity:GetRate()
	return self.rate
end


function Sanity:DoDelta(delta, overtime)

    if self.redirect then
        self.redirect(self.inst, delta, overtime)
        return
    end

    if self.ignore then return end


    local old = self.current
    self.current = self.current + delta
    if self.current < 0 then 
        self.current = 0
    elseif self.current > self:GetMaxSanity() then
        self.current = self:GetMaxSanity()
    end
    
    local oldpercent = old/self.max
    local newpercent = self.current/self.max
    
    self.inst:PushEvent("sanitydelta", {oldpercent = oldpercent, newpercent = newpercent, overtime=overtime})
    
    if self.inst == GetPlayer() then
        if delta > 0 then
            ProfileStatsAdd("sane+", math.floor(delta))
        end
    end

    if self.sane and oldpercent > TUNING.SANITY_BECOME_INSANE_THRESH and newpercent <= TUNING.SANITY_BECOME_INSANE_THRESH then
		self.sane = false
		if self.onInsane then
			self.onInsane(self.inst)
		end
	    self.inst:PushEvent("goinsane", {})
        ProfileStatsSet("went_insane", true)
		
    elseif not self.sane and oldpercent < TUNING.SANITY_BECOME_SANE_THRESH and newpercent >= TUNING.SANITY_BECOME_SANE_THRESH then
		self.sane = true
		
		if self.onSane then
			self.onSane(self.inst)
		end
	    self.inst:PushEvent("gosane", {})
        ProfileStatsSet("went_sane", true)
	end
end


function Sanity:OnUpdate(dt)
	local speed = easing.outQuad( 1 - self:GetPercent(), 0, .2, 1) 
	self.fxtime = self.fxtime + dt*speed
	
	PostProcessor:SetEffectTime(self.fxtime)
	
	local distortion_value = easing.outQuad( self:GetPercent(), 0, 1, 1) 
	--local colour_value = 1 - easing.outQuad( self:GetPercent(), 0, 1, 1) 
	--PostProcessor:SetColourCubeLerp( 1, colour_value )
	PostProcessor:SetDistortionFactor(distortion_value)
	PostProcessor:SetDistortionRadii( 0.5, 0.685 )

	if self.inst.components.health.invincible == true or self.inst.is_teleporting == true then
		return
	end
	
	self:Recalc(dt)	
end

function Sanity:GetMoistureDelta()
	if self.wetnessImmune then 
		return 0 
	else 
		local m = self.inst.components.moisture
		return easing.inSine(m:GetMoisture(), 0, TUNING.MOISTURE_SANITY_PENALTY_MAX, m.moistureclamp.max)
	end 
end

function Sanity:Recalc(dt)
	local total_dapperness = self.dapperness or 0
	local mitigates_rain = false
	
	local empty_slots = 3
	for k,v in pairs (self.inst.components.inventory.equipslots) do
		if v.components.equippable then
			empty_slots = empty_slots - 1
			total_dapperness = total_dapperness + v.components.equippable:GetDapperness(self.inst)
		end		
	end
	
	total_dapperness = total_dapperness * self.dapperness_mult 

	local moisture_delta = self:GetMoistureDelta()

	local dapper_delta = total_dapperness*TUNING.SANITY_DAPPERNESS
	
	local light_delta = 0
	local lightval = self.inst.LightWatcher:GetLightValue()
	
	local day = GetClock():IsDay() and not GetWorld():IsCave()
	
	local isInside = false
	local isInPlayerHouse = false

    if self.inst == GetPlayer() then
    	-- In House - gain sanity 
		-- in other interiors no day/night effect
		-- outside, general day/night drain
		isInside = TheCamera.interior
		isInPlayerHouse = GetInteriorSpawner() and GetInteriorSpawner():InPlayerRoom() or false
	end

	if isInPlayerHouse then
		light_delta = TUNING.SANITY_PLAYERHOUSE_GAIN
	elseif not isInside then
		if day then
			light_delta = TUNING.SANITY_DAY_GAIN
		else
			local highval = TUNING.SANITY_HIGH_LIGHT
			local lowval = TUNING.SANITY_LOW_LIGHT

			if lightval > highval then
				light_delta =  TUNING.SANITY_NIGHT_LIGHT
			elseif lightval < lowval then
				light_delta = TUNING.SANITY_NIGHT_DARK
			else
				light_delta = TUNING.SANITY_NIGHT_MID
			end

			light_delta = light_delta*self.night_drain_mult
		end
	end

	local aura_delta = 0
	local x,y,z = self.inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x,y,z, TUNING.SANITY_EFFECT_RANGE, nil, {"FX", "NOCLICK", "DECOR","INLIMBO"} )
    for k,v in pairs(ents) do 
		if v.components.sanityaura and v ~= self.inst then
			local distsq = self.inst:GetDistanceSqToInst(v)
			local aura_val = v.components.sanityaura:GetAura(self.inst)/math.max(1, distsq)
			if aura_val < 0 then
				aura_val = aura_val * self.neg_aura_mult
			end

			aura_delta = aura_delta + aura_val
		end
    end
 --    	local rain_delta = 0
 --    	if GetSeasonManager() and GetSeasonManager():IsRaining() and not mitigates_rain then
 --    		rain_delta = -TUNING.DAPPERNESS_MED*1.5* GetSeasonManager():GetPrecipitationRate()
 --    	end

 	local drivabledelta = 0 
 	if self.inst.components.driver then 
 		local vehicle = self.inst.components.driver.vehicle
 		if vehicle then 
 			if vehicle.components.drivable then
 				drivabledelta = vehicle.components.drivable:GetSanityDrain()
			elseif vehicle.components.searchable then
				drivabledelta = vehicle.components.searchable:GetSanityDrain()
			end
 		end 
 	end 

 	local poisondelta = 0
 	if self.inst.components.poisonable and self.inst.components.poisonable:IsPoisoned() then
 		poisondelta = -self.inst.components.poisonable.damage_per_interval * TUNING.POISON_SANITY_SCALE
 	end

    local mount = self.inst.components.rider and self.inst.components.rider:IsRiding() and self.inst.components.rider:GetMount() or nil
    if mount and mount.components.sanityaura  then
        local aura_val = mount.components.sanityaura:GetAura(self.inst)
        aura_delta = aura_delta + aura_val
    end

	self.rate = (dapper_delta + moisture_delta + light_delta + aura_delta + drivabledelta + poisondelta)	
	
	if self.custom_rate_fn then
		self.rate = self.rate + self.custom_rate_fn(self.inst)
	end
	self.rate = self.rate * self:GetRateModifier()
	--print (string.format("dapper: %2.2f light: %2.2f aura: %2.2f boat: %2.2f poison: %2.2f TOTAL: %2.2f", dapper_delta, light_delta, aura_delta, drivabledelta, poisondelta, self.rate*dt))
	self:DoDelta(self.rate*dt, true)
end

function Sanity:LongUpdate(dt)
	self:OnUpdate(dt)
end

return Sanity
