
local Combat = Class(function(self, inst)
	self.inst = inst
	self.nextbattlecrytime = nil
	self.attackrange = 3
	self.hitrange = 3
	self.areahitrange = nil
	self.areahitdamagepercent = nil
	self.defaultdamage = 0
	self.playerdamagepercent = 1
	self.min_attack_period = 4
	self.onhitfn = nil
	self.onhitotherfn = nil
	self.laststartattacktime = 0
	self.keeptargetfn = nil
	self.keeptargettimeout = 0
	self.hiteffectsymbol = "marker"
	self.canattack = true
	self.lasttargetGUID = nil
	self.inst:AddTag("hascombatcomponent")
	self.inst:AddTag("combat")
	self.forcefacing = true
	self.battlecryenabled = true
	self.poisonous = nil
	self.gasattack = nil
	self.excludeTarget = nil 

	self.attack_period_modifiers = {} -- % modifiers on self.min_attack_period
	self.attack_damage_modifiers = {} -- % modifiers on self:CalcDamage()

end)

function Combat:AddPeriodModifier(key, mod)
	self.attack_period_modifiers[key] = mod
end

function Combat:RemovePeriodModifier(key)
	self.attack_period_modifiers[key] = nil
end

function Combat:GetPeriodModifier()
	local mod = 0
	for k,v in pairs(self.attack_period_modifiers) do
		mod = mod + v
	end
	return mod
end

function Combat:AddDamageModifier(key, mod)
	self.attack_damage_modifiers[key] = mod
end

function Combat:RemoveDamageModifier(key)
	self.attack_damage_modifiers[key] = nil
end

function Combat:GetDamageModifier()
	local mod = 1
	for k,v in pairs(self.attack_damage_modifiers) do
		mod = mod + v
	end
	return mod
end

function Combat:SetAttackPeriod(period)
	self.min_attack_period = period
end

function Combat:InCooldown()
	if self.laststartattacktime then
		local time_since_doattack = GetTime() - self.laststartattacktime
		
		if time_since_doattack < self.min_attack_period + (self:GetPeriodModifier() * self.min_attack_period) then
			return true
		end
	end
	return false
end

function Combat:ResetCooldown()
    self.laststartattacktime = 0
end

function Combat:SetRange(attack, hit)
	self.attackrange = attack
	self.hitrange = hit or self.attackrange
end

function Combat:SetAreaDamage(range, percent)
	self.areahitrange = range
	if self.areahitrange then
		self.areahitdamagepercent = percent or 1
	else
		self.areahitdamagepercent = nil
	end
end

function Combat:BlankOutAttacks(fortime, return_fn)
	self.canattack = false
	
	if self.blanktask then
		self.blanktask:Cancel()
	end

	self.blanktask = self.inst:DoTaskInTime(fortime, function() 
		self.canattack = true 
		self.blanktask = nil 

		if return_fn then
			return_fn(self.inst)
		end
	end)
end


function Combat:ShareTarget(target, range, fn, maxnum)
	--print("Combat:ShareTarget", self.inst, target)

	local x,y,z = self.inst.Transform:GetWorldPosition()
	local ents = nil
	if GetSeasonManager() and (GetSeasonManager():IsSpring() or GetSeasonManager():IsGreenSeason()) then
		ents = TheSim:FindEntities(x,y,z, range * TUNING.SPRING_COMBAT_MOD, nil, {"falling", "FX", "NOCLICK", "DECOR", "INLIMBO"})
	else
		ents = TheSim:FindEntities(x,y,z, range, nil, {"falling", "FX", "NOCLICK", "DECOR", "INLIMBO"})
	end
	
	if ents then
		local num_helpers = 0
		for k,v in pairs(ents) do
			if v ~= self.inst and v.components.combat and not (v.components.health and v.components.health:IsDead()) and fn(v) then
				--print("    share with", v)
				if v.components.combat:SuggestTarget(target) then
					num_helpers = num_helpers + 1
				end
			end
			
			if num_helpers >= maxnum then
				break
			end     
		end
	end
end

function Combat:SetDefaultDamage(damage)
	self.defaultdamage = damage
end

function Combat:SetOnHit(fn)
	self.onhitfn = fn
end

function Combat:SetOnHitOther(fn)
	self.onhitotherfn = fn
end

function Combat:SuggestTarget(target)
	--[[
	if self.target then
		print("TARGET",self.target.prefab)
	else
		print("no target")
	end
]]
	if not self.target and target ~= nil then
		--print("Combat:SuggestTarget", self.inst, target)

		local sneaky = false
		
		if target:HasTag("sneaky") then
			if self.inst:GetDistanceSqToInst(target) >	6*6 then
				sneaky = true
			end
		end

		if not sneaky then
			self:SetTarget(target)
			return true
		end
	end
end

function Combat:ExcludeTarget(target)
	self.excludeTarget = target
end

function Combat:SetKeepTargetFunction(fn)
	self.keeptargetfn = fn
end

function tryretarget(inst)
	inst.components.combat:TryRetarget()
end

function Combat:TryRetarget()
	if self.targetfn then
		if not (self.inst.components.health and self.inst.components.health:IsDead() )
		   and not (self.inst.components.sleeper and self.inst.components.sleeper:IsInDeepSleep()) then
			local newtarget = self.targetfn(self.inst)
			if newtarget and newtarget ~= self.target and not newtarget:HasTag("notarget") then
				if self.target and self.target:HasTag("structure") and not newtarget:HasTag("structure") then
					self:SetTarget(newtarget)
				else
					self:SuggestTarget(newtarget)
				end			
			end
		end
	end
end

function Combat:SetRetargetFunction(period, fn)
	self.targetfn = fn
	self.retargetperiod = period
	
	if self.retargettask then
		self.retargettask:Cancel()
		self.retargettask = nil
	end
	
	
	if period and fn then
		self.retargettask = self.inst:DoPeriodicTask(period, tryretarget)
	end
end

function Combat:OnEntitySleep()
	if self.retargettask then
		self.retargettask:Cancel()
		self.retargettask = nil
	end
end

function Combat:OnEntityWake()
	if self.retargettask then
		self.retargettask:Cancel()
		self.retargettask = nil
	end


	if self.retargetperiod then
		self.retargettask = self.inst:DoPeriodicTask(self.retargetperiod, tryretarget)
	end
end

function Combat:OnUpdate(dt)
	if not self.target then
		self.inst:StopUpdatingComponent(self)
		return
	end
	
	if self.keeptargetfn then
		self.keeptargettimeout = self.keeptargettimeout - dt
		if self.keeptargettimeout < 0 then
            if self.inst:IsAsleep() then
                self.inst:StopUpdatingComponent(self)
                return
            end
			self.keeptargettimeout = 1
			if not self.target:IsValid() or 
				not self.keeptargetfn(self.inst, self.target) or not 
				(self.target and self.target.components.combat and self.target.components.combat:CanBeAttacked(self.inst)) then    
				self.inst:PushEvent("losttarget")            
				self:SetTarget(nil)
			end
		end
	end
end

function Combat:IsRecentTarget(target)
	return target and (target == self.target or target.GUID == self.lasttargetGUID)
end

function Combat:TargetIs(target)
	return self.target and self.target == target
end

function Combat:SetTarget(target)
	local new = target ~= self.target
	local player = GetPlayer()
	
	if new and (not target or self:IsValidTarget(target) ) and not (target and target.sg and target.sg:HasStateTag("hiding") and target:HasTag("player")) then
		if METRICS_ENABLED and self.target == player and new ~= player then
			FightStat_GaveUp(self.inst)
		end

		if self.target then
        	self:StopTrackingTarget(self.target)
			self.lasttargetGUID = self.target.GUID
		else
			self.lasttargetGUID = nil
		end
		
		local oldtarget = self.target
		self.target = target
		self.inst:PushEvent("newcombattarget", {target=target, oldtarget=oldtarget})

		if METRICS_ENABLED and (player == target or target and target.components.follower and target.components.follower.leader == player) then
			FightStat_Targeted(self.inst)
		end
		
		if target and self.keeptargetfn then
			self.inst:StartUpdatingComponent(self)
		else
			self.inst:StopUpdatingComponent(self)
		end
		
		if target and self.inst.components.follower and self.inst.components.follower.leader == target and self.inst.components.follower.leader.components.leader then
			self.inst.components.follower.leader.components.leader:RemoveFollower(self.inst)
		end

		self:StartTrackingTarget(target)
	end
end

function Combat:StopTrackingTarget(target)
    if self.losetargetcallback then
	    self.inst:RemoveEventCallback("enterlimbo", self.losetargetcallback, target)
	    self.inst:RemoveEventCallback("onremove", self.losetargetcallback, target)
    else
        print("*** Warning: Stopped tracking target without it being explicitly set")
	print("    target:",target)
        print("    from entity:",self.inst)
        print(debugstack())
    end
    self.losetargetcallback = nil
end

function Combat:StartTrackingTarget(target)
    if target then
        self.losetargetcallback = function() 
            self.target = nil
        end
        self.inst:ListenForEvent("enterlimbo", self.losetargetcallback, target)
        self.inst:ListenForEvent("onremove", self.losetargetcallback, target)
    end
end

function Combat:IsValidTarget(target)

    local player = false
	if target and target:HasTag("player") then
		--print("checking if player is valid target")
		player = true
	elseif not target then
        --print("there is no target")
    end
	
	if target == self.excludeTarget then
		return false
	end

	if target 
	   and target.components.burnable
	   and target.components.burnable.canlight
	   and not target.components.burnable:IsBurning() 
	   and not target:HasTag("burnt")
	   and self:GetWeapon() and self:GetWeapon():HasTag("rangedlighter") then
		return true
	elseif target 
	   and target.components.burnable
	   and (target.components.burnable:IsSmoldering() or target.components.burnable:IsBurning())
	   and self:GetWeapon() and self:GetWeapon():HasTag("extinguisher") then
		return true
	elseif not target 
	   or not target:IsValid()
	   or not target.components
	   or not target.components.combat
	   or not target.entity:IsVisible()
	   or not target.components.health
	   or target == self.inst
	   or target.components.health:IsDead()
	   or (target:HasTag("shadow") and not self.inst.components.sanity)
	   or Vector3(target.Transform:GetWorldPosition()).y > self.attackrange then
       
        if player then
			--print("player is no longer valid target")
		end
        
		return false
	else
		if self.notags then
			for i,v in pairs(self.notags) do
				if target:HasTag(v) then
                    if player then
                        --print("player is no longer valid target")
                    end
                    return false
				end
			end
			return true
		else
			return true
		end
	end
end

function Combat:ValidateTarget()
	if self.target then
		if self:IsValidTarget(self.target) then
			return true
		else
			self:SetTarget(nil)
		end
	end
end

function Combat:GetDebugString()
	
	local str = string.format("target:%s, damage:%d", tostring(self.target), self.defaultdamage or 0 )
	if self.target and self.target:IsValid() then
		local dist = math.sqrt(self.inst:GetDistanceSqToInst(self.target)) or 0
		local atkrange = math.sqrt(self:CalcAttackRangeSq()) or 0
		str = str .. string.format(" dist/range: %2.2f/%2.2f", dist, atkrange)
	end
	if self.targetfn and self.retargetperiod then
		str = str.. " Retarget set"
	end
	str = str..string.format(" can attack:%s", tostring(self:CanAttack(self.target)))

	str = str..string.format(" can be attacked: %s", tostring(self:CanBeAttacked()))
	
	return str
end

function Combat:GetGiveUpString(target)
	return nil
end

function Combat:GiveUp()
	if self.inst.components.talker then
		local str = self:GetGiveUpString(self.target)
		if str then
			self.inst.components.talker:Say(str)
		end
		
	end

	if METRICS_ENABLED and GetPlayer() == self.target then
		FightStat_GaveUp(self.inst)
	end

    --print("Giving up on target")
	self.inst:PushEvent("giveuptarget", {target = self.target})
	if self.target then
		self.lasttargetGUID = self.target.GUID
	end
	self.target = nil
	
end

function Combat:GetBattleCryString(target)
	return nil
end

function Combat:BattleCry()

	if self.battlecryenabled and (not self.nextbattlecrytime or GetTime() > self.nextbattlecrytime) then
		self.nextbattlecrytime = GetTime() + (self.battlecryinterval and self.battlecryinterval or 5)+math.random()*3
		if self.inst.components.talker then            
			local cry = self:GetBattleCryString(self.target)
			local mood = self.inst.battlecrysound and "battlecry" or nil
			if cry then
				self.inst.components.talker:Say({Line(cry, 2)},nil,nil,nil,mood)
			end
		elseif self.inst.sg.sg.states.taunt and not self.inst.sg:HasStateTag("busy") then
			self.inst.sg:GoToState("taunt")
		end
	end
end

function Combat:SetHurtSound(sound)
	self.hurtsound = sound
end

function Combat:GetAttacked(attacker, damage, weapon, stimuli)
	--print ("ATTACKED", self.inst, attacker, damage)

	local blocked = false
	local player = GetPlayer()
	local init_damage = damage
	local poisonAttack = false 
	local poisonGasAttack = false 
	local damageredirecttarget = self.redirectdamagefn and self.redirectdamagefn(self.inst, attacker, damage, weapon, stimuli) or nil

	if self.inst:HasTag("poisonable") and attacker then 
		if (attacker.components.combat and attacker.components.combat.poisonous) or 
			((attacker.components.poisonable and attacker.components.poisonable:IsPoisoned() and attacker.components.poisonable.transfer_poison_on_attack) 
			and (attacker.components.combat and not attacker.components.combat:GetWeapon())) then
			
			poisonAttack = true 
			if (attacker.components.combat and attacker.components.combat.poisonous and attacker.components.combat.gasattack) then 
				poisonGasAttack = true 
			end 
		end 
	end 
				
	self.lastattacker = attacker

	if poisonGasAttack and self.inst.components.poisonable then 
		self.inst.components.poisonable:Poison(true)
		return
	end

	if TUNING.DO_SEA_DAMAGE_TO_BOAT and damage and (self.inst.components.driver and self.inst.components.driver.vehicle and self.inst.components.driver.vehicle.components.boathealth) then
		local boathealth = self.inst.components.driver.vehicle.components.boathealth
		if damage > 0 and boathealth:IsInvincible() == false then
			boathealth:DoDelta(-damage, "combat", attacker and attacker.prefab or "NIL")
			-- if boathealth:GetPercent() <= 0 then
			-- 	if attacker then
			-- 		attacker:PushEvent("killed", {victim = self.inst})
			-- 	end

			-- 	if METRICS_ENABLED and attacker and attacker == GetPlayer() then
			-- 		ProfileStatsAdd("kill_"..self.inst.prefab)
			-- 		FightStat_AddKill(self.inst,damage,weapon)
			-- 	end
			-- 	if METRICS_ENABLED and attacker and attacker.components.follower and attacker.components.follower.leader == GetPlayer() then
			-- 		ProfileStatsAdd("kill_by_minion"..self.inst.prefab)
			-- 		FightStat_AddKillByFollower(self.inst,damage,weapon)
			-- 	end
			-- 	if METRICS_ENABLED and attacker and attacker.components.mine then
			-- 		ProfileStatsAdd("kill_by_trap_"..self.inst.prefab)
			-- 		FightStat_AddKillByMine(self.inst,damage)
			-- 	end
				
			-- 	if self.onkilledbyother then
			-- 		self.onkilledbyother(self.inst, attacker)
			-- 	end
			-- end
		else
			blocked = true
		end
	elseif self.inst.components.health and damage and not damageredirecttarget then   
		if self.inst.components.inventory then
			damage = self.inst.components.inventory:ApplyDamage(damage, attacker)
		end
		if METRICS_ENABLED and GetPlayer() == self.inst then
			local prefab = (attacker and (attacker.prefab or attacker.inst.prefab)) or "NIL"
			ProfileStatsAdd("hitsby_"..prefab,math.floor(damage))
			FightStat_AttackedBy(attacker,damage,init_damage-damage)
		end
		if damage > 0 and self.inst.components.health:IsInvincible() == false then
			self.inst.components.health:DoDelta(-damage, nil, attacker and attacker.prefab or "NIL")
			if self.inst.components.health:GetPercent() <= 0 then
				if attacker then
					attacker:PushEvent("killed", {victim = self.inst})
				end

				if METRICS_ENABLED and attacker and attacker == GetPlayer() then
					ProfileStatsAdd("kill_"..self.inst.prefab)
					FightStat_AddKill(self.inst,damage,weapon)
				end
				if METRICS_ENABLED and attacker and attacker.components.follower and attacker.components.follower.leader == GetPlayer() then
					ProfileStatsAdd("kill_by_minion"..self.inst.prefab)
					FightStat_AddKillByFollower(self.inst,damage,weapon)
				end
				if METRICS_ENABLED and attacker and attacker.components.mine then
					ProfileStatsAdd("kill_by_trap_"..self.inst.prefab)
					FightStat_AddKillByMine(self.inst,damage)
				end
				
				if self.onkilledbyother then
					self.onkilledbyother(self.inst, attacker)
				end
			end
		else			
			blocked = true
		end
	end

    local redirect_combat = damageredirecttarget ~= nil and damageredirecttarget.components.combat or nil
    if redirect_combat and not blocked then
        redirect_combat:GetAttacked(attacker, damage, weapon, stimuli)
 		if self.inst == GetPlayer() then
 			GetPlayer():PushEvent("mountattacked") 			 		
 			GetPlayer():PushEvent("mounthurt") 			 			
 		end		

 		local atksource = attacker
 		while atksource and atksource.components.combat and atksource.components.combat.proxy do		 			
 			atksource = atksource.components.combat.proxy
 		end	
 		
 		self.inst:PushEvent("attacked", {attacker = atksource, damage = damage, weapon = weapon, redirected=true}) 
        if redirect_combat and redirect_combat.hurtsound then
            self.inst.SoundEmitter:PlaySound(redirect_combat.hurtsound)
        end		
 		blocked = true
    end	
		
	local boating = false 
	if self.inst.components.driver and self.inst.components.driver:GetIsDriving() then 
		boating = true 
	end 
	--Don't play the impact the sounds when boating, it's actually the boat that takes the damage and the sound are played in the boat health component 
	if self.inst.SoundEmitter and not boating then
		local hitsound = self:GetImpactSound(self.inst, weapon)
		if hitsound then
			self.inst.SoundEmitter:PlaySound(hitsound)
			--print (hitsound)
		end
		if self.hurtsound then
			self.inst.SoundEmitter:PlaySound(self.hurtsound)
		end
	end
	
	if not blocked then

		if TUNING.DO_SEA_DAMAGE_TO_BOAT and (self.inst.components.driver and self.inst.components.driver.vehicle and self.inst.components.driver.vehicle.components.boathealth) then
			self.inst:PushEvent("boatattacked", {attacker = attacker, damage = damage, weapon = weapon, stimuli = stimuli})
		else
			if not self.inst:HasTag("noflinch") then

		 		local atksource = attacker
		 		while atksource and atksource.components.combat and atksource.components.combat.proxy do		 			
		 			atksource = atksource.components.combat.proxy
		 		end					 		
				self.inst:PushEvent("attacked", {attacker = atksource, damage = damage, weapon = weapon, stimuli = stimuli})
			end
		end
	
		if self.onhitfn then
			self.onhitfn(self.inst, attacker, damage)
		end
		
		if attacker then
			attacker:PushEvent("onhitother", {target = self.inst, damage = damage, stimuli = stimuli})
			if attacker.components.combat and attacker.components.combat.onhitotherfn then
				attacker.components.combat.onhitotherfn(attacker, self.inst, damage, stimuli)
			end
			if poisonAttack then 
				if self.inst.components.poisonable then
					self.inst.components.poisonable:Poison()
				end
			end
		end
	else
		self.inst:PushEvent("blocked", {attacker = attacker, weapon = weapon})		
	end

	return not blocked
end

function Combat:GetImpactSound(target, weapon)
	if not target then
		return
	end
	


	local hitsound = "dontstarve/impacts/impact_"
	local specialtype = nil
	if target.components.inventory and target.components.inventory:IsWearingArmor() then
		if target.components.inventory:ArmorHasTag("grass") then
			hitsound = hitsound.."straw_"
		elseif target.components.inventory:ArmorHasTag("vortex_cloak") then	
			return "dontstarve_DLC003/common/crafted/vortex_armour/hit"
		elseif target.components.inventory:ArmorHasTag("forcefield") then
			hitsound = hitsound.."forcefield_"        
		elseif target.components.inventory:ArmorHasTag("sanity") then
			hitsound = hitsound.."sanity_"
		elseif target.components.inventory:ArmorHasTag("marble") then
			hitsound = hitsound.."marble_"
		elseif target.components.inventory:ArmorHasTag("shell") then
			hitsound = hitsound.."shell_"                
		elseif target.components.inventory:ArmorHasTag("fur") then
			hitsound = hitsound.."fur_"
		elseif target.components.inventory:ArmorHasTag("metal") then
			hitsound = hitsound.."metal_"
		else
			hitsound = hitsound.."wood_"
		end
		specialtype = "armour"
	elseif target:HasTag("wall") then
		if target:HasTag("grass") then
			hitsound = hitsound.."straw_"
		elseif target:HasTag("stone") then
			hitsound = hitsound.."stone_"
		elseif target:HasTag("marble") then
			hitsound = hitsound.."marble_"
		else
			hitsound = hitsound.."wood_"
		end
		specialtype = "wall"   
	elseif target:HasTag("object") then
		if target:HasTag("clay") then
			hitsound = hitsound.."clay_"
		elseif target:HasTag("stone") then
			hitsound = hitsound.."stone_"
		end
		specialtype = "object"
	elseif target:HasTag("hive") or target:HasTag("eyeturret") or target:HasTag("houndmound") then
		hitsound = hitsound.."hive_"
	elseif target:HasTag("ghost") then
		hitsound = hitsound.."ghost_"
	elseif target:HasTag("insect") or target:HasTag("spider") then
		hitsound = hitsound.."insect_"
	elseif target:HasTag("chess") or target:HasTag("mech") then
		hitsound = hitsound.."mech_"
	elseif target:HasTag("mound") then
		hitsound = hitsound.."mound_"
	elseif target:HasTag("shadow") then
		hitsound = hitsound.."shadow_"
	elseif target:HasTag("tree") then
		hitsound = hitsound.."tree_"
	elseif target:HasTag("veggie") then
		hitsound = hitsound.."vegetable_"
	elseif target:HasTag("shell") then
		hitsound = hitsound.."shell_"
	elseif target:HasTag("rocky") then
		hitsound = hitsound.."stone_"
	else
		hitsound = hitsound.."flesh_"
	end

	if specialtype then
		hitsound = hitsound..specialtype.."_"
	elseif target:HasTag("smallcreature") or target:HasTag("small") then
		hitsound = hitsound.."sml_"
	elseif target:HasTag("largecreature") or target:HasTag("epic") or target:HasTag("large") then
		hitsound = hitsound.."lrg_"
	elseif target:HasTag("wet") then
		hitsound = hitsound.."wet_"
	else
		hitsound = hitsound.."med_"
	end
	
	if weapon and weapon:HasTag("sharp") then
		hitsound = hitsound.."sharp"
	else
		hitsound = hitsound.."dull"
	end

	if target:HasTag("avoidonhit") then
		hitsound = nil
	end


	return hitsound
end

function Combat:StartAttack()
	if self.target and self.forcefacing then
		self.inst:ForceFacePoint(self.target:GetPosition())
	end
	self.laststartattacktime = GetTime()
end

function Combat:CanTarget(target)
	
	return target and 
		(not self.panic_thresh or self.inst.components.health:GetPercent() >= self.panic_thresh) and
		target:IsValid() and
		not target:IsInLimbo() and
		target.components.combat and 
		not (target.sg and target.sg:HasStateTag("invisible")) and
		target.components.health and
		not target.components.health:IsDead()
		and self.inst.components.combat:IsValidTarget(target)
		and target.components.combat:CanBeAttacked(self.inst)
end

function Combat:IsTarget( inst )
    return self.target and self.target == inst
end

function Combat:CanAttack(target)

	if not target then
		return false
	end

	if not self.canattack then 
		return false 
	end
	
	if self.laststartattacktime then
		local time_since_doattack = GetTime() - self.laststartattacktime
		
		if time_since_doattack < self.min_attack_period + (self:GetPeriodModifier() * self.min_attack_period) then
			return false
		end
	end

	if not self:IsValidTarget(target) then
		return false
	end
	
	if self.inst.sg and self.inst.sg:HasStateTag("busy") then
		return false
	end

	local tpos = Point(target.Transform:GetWorldPosition())
	local pos = Point(self.inst.Transform:GetWorldPosition())
	if distsq(tpos,pos) <= self:CalcAttackRangeSq(target) then
		return true
	else
		return false
	end
end


function Combat:TryAttack(target)
	
	local target = target or self.target 
    if target and target:HasTag("player") then
        --print("TryAttack player")
    end
	
	local is_attacking = self.inst.sg:HasStateTag("attack")
	if is_attacking then
		return true
	end
	
	if self:CanAttack(target) then
		self.inst:PushEvent("doattack", {target = target})
		return true
	end
	
	return false
end

function Combat:ForceAttack()
	if self.target and self:TryAttack() then
		return true
	else
		self.inst:PushEvent("doattack")
	end
end


function Combat:GetWeapon()
	if self.inst.components.inventory then
		local item = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
		if item and item.components.weapon then
			return item
		end
        item = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
        if item and item.components.weapon then
            return item
        end		
	end
end


function Combat:CalcDamage(target, weapon, multiplier)

	if target:HasTag("alwaysblock") then
		return 0
	end
	local multiplier = multiplier or 1

	multiplier = multiplier * self:GetDamageModifier()

	local basedamage = self.defaultdamage or 0
	local bonus = self.damagebonus or 0

	if weapon then
		local weapondamage = 0

		if weapon.components.weapon.variedmodefn then
			local d = weapon.components.weapon.variedmodefn(weapon)
			weapondamage = d.damage        
		else
			weapondamage = weapon.components.weapon:GetDamage()
		end

		if not weapondamage then weapondamage = 0 end

		return weapondamage*multiplier + bonus
	else		
 		if self.inst.components.rider and self.inst.components.rider:IsRiding() then
            local mount = self.inst.components.rider:GetMount()
            if mount and mount.components.combat then
                basedamage = mount.components.combat.defaultdamage
                bonus = mount.components.combat.damagebonus or 0
            end
            local saddle = self.inst.components.rider:GetSaddle()
            if saddle ~= nil and saddle.components.saddler ~= nil then
                basedamage = basedamage + saddle.components.saddler:GetBonusDamage()
            end
        end
	end

	if target and target:HasTag("player") then
		return basedamage * self.playerdamagepercent * multiplier + bonus
	end
	
	return basedamage * multiplier + bonus
end

function Combat:GetAttackRange()
	local range = self.attackrange
	local weapon = self:GetWeapon()

	if weapon and weapon.components.weapon.variedmodefn then
		local weaponrange = weapon.components.weapon.variedmodefn(weapon)
		range = range + weaponrange.attackrange
	elseif weapon and weapon.components.weapon.attackrange then
		range = range + weapon.components.weapon.attackrange
	end

	return range
end

function Combat:CalcAttackRangeSq(target)
	target = target or self.target
	local range = self:GetAttackRange() + (target.Physics and target.Physics:GetRadius() or 0)
	return range*range
end

function Combat:CanAttackTarget(targ, weapon)
	if targ and targ:IsValid() and not targ:IsInLimbo() then
		local rangesq = self:CalcAttackRangeSq(targ)
		if targ.components.combat and self.inst:GetDistanceSqToInst(targ) <= rangesq then
			return true
		end
		if weapon and weapon.components.projectile then
			local range = weapon.components.projectile.hitdist + (targ.Physics and targ.Physics:GetRadius() or 0)
			if weapon:GetDistanceSqToInst(targ) < range*range then
				return true
			end
		end
	end
end

function Combat:GetHitRange()
	local range = self.hitrange
	local weapon = self:GetWeapon()
	if weapon and weapon.components.weapon.variedmodefn then
		local weaponrange = weapon.components.weapon.variedmodefn(weapon)
		range = range + weaponrange.hitrange
	elseif weapon and weapon.components.weapon.hitrange then
		range = range + weapon.components.weapon.hitrange
	end
	--print("GetHitRange", self.inst, self.hitrange, range)
return range
end

function Combat:CalcHitRangeSq(target)
	target = target or self.target
	local range = self:GetHitRange() + (target.Physics and target.Physics:GetRadius() or 0)
	return range*range
end

function Combat:CanHitTarget(targ, weapon)
	--print("CanHitTarget", self.inst)
	local specialcase_target = false
	if targ and targ.components.burnable and (targ.components.burnable:IsSmoldering() or targ.components.burnable:IsBurning()) 
	  and self:GetWeapon() and self:GetWeapon():HasTag("extinguisher") then
		specialcase_target = true
	end
	if not specialcase_target and targ and targ.components.burnable and targ.components.burnable.canlight and not targ.components.burnable:IsBurning() and not targ:HasTag("burnt")
	  and self:GetWeapon() and self:GetWeapon():HasTag("rangedlighter") then
		specialcase_target = true
	end
	if self.inst and self.inst:IsValid() and targ and targ:IsValid() and not targ:IsInLimbo() and (specialcase_target or (targ.components.combat and targ.components.combat:CanBeAttacked(self.inst))) then
		local rangesq = self:CalcHitRangeSq(targ)
		if (specialcase_target or targ.components.combat) and self.inst:GetDistanceSqToInst(targ) <= rangesq then
			return true
		end
		if weapon and weapon.components.projectile then
			local range = weapon.components.projectile.hitdist + (targ.Physics and targ.Physics:GetRadius() or 0)
			if weapon:GetDistanceSqToInst(targ) < range*range then
				return true
			end
		end	
	end
end

function Combat:CanAreaHitTarget(targ)
	if self:IsValidTarget(targ) then
		return true
	end
end

function Combat:DoAttack(target_override, weapon, projectile, stimuli, instancemult)
	
	local targ = target_override or self.target
	local weapon = weapon or self:GetWeapon()
	if self:CanHitTarget(targ, weapon) then

		self.inst:PushEvent("onattackother", {target = targ, weapon = weapon, projectile = projectile, stimuli = stimuli})
		if weapon and weapon.components.projectile and not projectile then
			local projectile = self.inst.components.inventory:DropItem(weapon, false, nil, nil, true) 
			if projectile then
				projectile.components.projectile:Throw(self.inst, targ)
			end
		elseif weapon and weapon.components.complexprojectile and not projectile then 			
			local projectile = self.inst.components.inventory:DropItem(weapon, false, nil, nil, true)
			if projectile then
				local targetPos = targ:GetPosition()                
				projectile.components.complexprojectile:Launch(targetPos)
			end
		elseif weapon and weapon.components.weapon:CanRangedAttack() and not projectile then
			weapon.components.weapon:LaunchProjectile(self.inst, targ)
		else
			local mult = 1
			if stimuli == "electric" or (weapon and weapon.components.weapon and weapon.components.weapon.stimuli == "electric") then
				if not targ:HasTag("electricdamageimmune") and (not targ.components.inventory or (targ.components.inventory and not targ.components.inventory:IsInsulated())) then
					mult = TUNING.ELECTRIC_DAMAGE_MULT
					if targ.components.moisture then
						mult = mult + (TUNING.ELECTRIC_WET_DAMAGE_MULT * targ.components.moisture:GetMoisturePercent())
					elseif targ.components.moisturelistener and targ.components.moisturelistener:IsWet() then
						mult = mult + TUNING.ELECTRIC_WET_DAMAGE_MULT 
					elseif GetWorld() and GetWorld().components.moisturemanager and GetWorld().components.moisturemanager:IsEntityWet(targ) then
						mult = mult + TUNING.ELECTRIC_WET_DAMAGE_MULT
					end
				end
			end
			local damage = self:CalcDamage(targ, weapon, mult)
			if instancemult then damage = damage * instancemult end
			if targ.components.combat then targ.components.combat:GetAttacked(self.inst, damage, weapon, stimuli) end

			if METRICS_ENABLED and self.inst:HasTag( "player" ) then
				ProfileStatsAdd("hitson_"..targ.prefab,math.floor(damage))
				FightStat_Attack(targ,weapon,projectile,damage)
			end
			if METRICS_ENABLED and self.inst.components.follower
					and self.inst.components.follower.leader == GetPlayer() then
				FightStat_AttackByFollower(targ,weapon,projectile,damage)
			end
			
			if weapon then
				weapon.components.weapon:OnAttack(self.inst, targ, projectile)
			end
			if self.areahitrange then
				self:DoAreaAttack(targ, self.areahitrange, weapon, nil, stimuli)
			end
			self.lastdoattacktime = GetTime()
		end
	else
		self.inst:PushEvent("onmissother", {target = targ, weapon = weapon})
		if self.areahitrange then
			local epicentre = projectile or self.inst
			self:DoAreaAttack(epicentre, self.areahitrange, weapon, nil, stimuli)
		end
	end
	if weapon and weapon:HasTag("Shockwhenwet") then
		if self.inst.components.moisture:GetMoisture()>0 then
			self:GetAttacked(nil, TUNING.HEALING_MEDSMALL, nil, "electric")
		end
	end

end

function Combat:DoAreaAttack(target, range, weapon, validfn, stimuli)
	local hitcount = 0
	local pt = Vector3(target.Transform:GetWorldPosition() )
	local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, range, nil, {"falling", "FX", "NOCLICK", "DECOR", "INLIMBO"})
	for i,ent in ipairs(ents) do
		if ent.components.combat 
			and ent ~= target 
			and ent ~= self.inst 
			and self:CanAreaHitTarget(ent) 
			and (not validfn or validfn(ent)) then
				self.inst:PushEvent("onareaattackother", {target = target, weapon = weapon, stimuli = stimuli})
				ent.components.combat:GetAttacked(self.inst, self:CalcDamage(ent, weapon, self.areahitdamagepercent), weapon, stimuli)
				hitcount = hitcount + 1
		end
	end
	return hitcount
end

function Combat:IsAlly(guy)
	return  (guy == self.inst) or
			(self.inst.components.leader and self.inst.components.leader:IsFollower(guy)) or
			(guy.components.leader and guy.components.leader:IsFollower(self.inst)) or 
			(self.inst:HasTag("player") and guy:HasTag("companion"))
end

function Combat:CanBeAttacked(attacker)
	local can_be_attacked = true
	if self.canbeattackedfn then
		can_be_attacked = self.canbeattackedfn(self.inst, attacker)
	end
	return can_be_attacked
end
--[[
function Combat:CollectSceneActions(doer, actions)
	if doer:CanDoAction(ACTIONS.ATTACK) and not self.inst.components.health:IsDead() then
		
		if self:CanBeAttacked(attacker) then
			table.insert(actions, ACTIONS.ATTACK)
		end
	end
end
]]
function Combat:OnSave()
	if self.target then
		return { target = self.target.GUID }, {self.target.GUID}
	end
end

function Combat:LoadPostPass(newents, data)
	if data.target then
		local target = newents[data.target]
		if target then
			self:SetTarget(target.entity)
		end
	end
end

function Combat:OnRemoveFromEntity()
	self.inst:RemoveTag("hascombatcomponent")    
	self.inst:RemoveTag("combat")
end

return Combat
