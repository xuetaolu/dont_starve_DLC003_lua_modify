local Crop = Class(function(self, inst)
    self.inst = inst
    self.product_prefab = nil
    self.growthpercent = 0
    self.rate = 1/120
    self.task = nil
    self.matured = false
    self.onmatured = nil

    self.witherable = false
    self.withered = false
    self.protected = false

    if SaveGameIndex:GetCurrentMode() == "volcano" or SaveGameIndex:GetCurrentMode() == "shipwrecked" then
        self.wither_temp = math.random(TUNING.SW_MIN_PLANT_WITHER_TEMP, TUNING.SW_MAX_PLANT_WITHER_TEMP)
    else
        self.wither_temp = math.random(TUNING.MIN_PLANT_WITHER_TEMP, TUNING.MAX_PLANT_WITHER_TEMP)
    end
    
    self.inst:ListenForEvent("witherplants", function(it, data) 
        if self.witherable and not self.withered and not self.protected and data.temp > self.wither_temp then
            self:MakeWithered()
        end
    end, GetWorld())
end)

function Crop:SetOnMatureFn(fn)
    self.onmatured = fn
end

function Crop:OnSave()
    local data = 
    {
        prefab = self.product_prefab,
        percent = self.growthpercent,
        rate = self.rate,
        matured = self.matured,
        withered = self.withered,
		hydrofarm = self.inst:HasTag("hydrofarm"),
    }

    return data
end   

function Crop:OnLoad(data)
	if data then
		self.product_prefab = data.prefab or self.product_prefab
		self.growthpercent = data.percent or self.growthpercent
		self.rate = data.rate or self.rate
		self.matured = data.matured or self.matured
        self.withered = data.withered or self.withered
		if data.hydrofarm then
			self.inst:AddTag("hydrofarm")
		end
	end

	if self.inst:HasTag("hydrofarm") == false then
		if self.withered then
			self:MakeWithered()
		else
    		self:DoGrow(0)
			if self.product_prefab and self.matured then
				self.inst.AnimState:PlayAnimation("grow_pst")
				if self.onmatured then
					self.onmatured(self.inst, self.grower)
				end
			end
		end	
	else
		self.inst.AnimState:PlayAnimation("empty")
	end
end  

function Crop:IsWithered()
    return self.withered
end

function Crop:MakeWitherable()
    self.witherable = true
    self.inst:AddTag("witherable")
end

function Crop:MakeWithered()
    self.withered = true
    self.inst:AddTag("withered")
    self.inst:RemoveTag("witherable")
    self.matured = false
    if self.task then 
        self.task:Cancel()
        self.task = nil
    end
    self.product_prefab = "cutgrass"
    self.growthpercent = 0
    self.rate = 0
    if not self.inst.components.burnable then
        MakeMediumBurnable(self.inst)
        MakeSmallPropagator(self.inst)
    end
	if self.inst:HasTag("hydrofarm") then
		self.grower.AnimState:PlayAnimation("picked")
		self.inst.AnimState:PlayAnimation("empty")
	else
	    self.inst.AnimState:PlayAnimation("picked")
	end
end

function Crop:Fertilize(fertilizer)
    if self.inst.components.burnable then
        self.inst.components.burnable:StopSmoldering()
    end
        
    if not (GetSeasonManager():IsWinter() and GetSeasonManager():GetCurrentTemperature() <= 0) then
        self.growthpercent = self.growthpercent + fertilizer.components.fertilizer.fertilizervalue*self.rate

		if self.inst:HasTag("hydrofarm") then
			self.grower.AnimState:SetPercent("grow", self.growthpercent + 0.2)
			self.inst.AnimState:PlayAnimation("empty")
		else
			self.inst.AnimState:SetPercent("grow", self.growthpercent)
		end

        if self.growthpercent >=1 then
			if self.inst:HasTag("hydrofarm") then
	            self.grower.AnimState:PlayAnimation("grow_pst")
				self.inst.AnimState:PlayAnimation("empty")
			else
				self.inst.AnimState:PlayAnimation("grow_pst")
			end
            self:Mature()
            if self.task then
                self.task:Cancel()
                self.task = nil
            end
        end
        if fertilizer.components.finiteuses then
            fertilizer.components.finiteuses:Use()
        else
            fertilizer.components.stackable:Get(1):Remove()
        end
        return true
    end    
end

function Crop:DoGrow(dt)
    if not self.withered then
        local clock = GetClock()
        local season = GetSeasonManager()
        
		if self.inst:HasTag("hydrofarm") then
			self.grower.AnimState:SetPercent("grow", self.growthpercent + 0.2)
			self.inst.AnimState:PlayAnimation("empty")
		else
			self.inst.AnimState:SetPercent("grow", self.growthpercent)
		end
        
        local weather_rate = 1
        
        if season:GetTemperature() < TUNING.MIN_CROP_GROW_TEMP then
    		weather_rate = 0
        else
            --if season:GetTemperature() > TUNING.CROP_BONUS_TEMP then
    		--  weather_rate = weather_rate + TUNING.CROP_HEAT_BONUS
            --end
            if season:IsRaining() then
                weather_rate = weather_rate + TUNING.CROP_RAIN_BONUS*season:GetPrecipitationRate()
            elseif season:IsSpring() or season:IsGreenSeason() then
                weather_rate = weather_rate + (TUNING.SPRING_GROWTH_MODIFIER/3)
            end
        end

        local in_light = TheSim:GetLightAtPoint(self.inst.Transform:GetWorldPosition()) > TUNING.DARK_CUTOFF
        if in_light then
            self.growthpercent = self.growthpercent + dt*self.rate*weather_rate
        end

        if self.growthpercent >= 1 then
			if self.inst:HasTag("hydrofarm") then
				self.grower.AnimState:PlayAnimation("grow_pst")
				self.inst.AnimState:PlayAnimation("empty")
			else
				self.inst.AnimState:PlayAnimation("grow_pst")
			end
            self:Mature()
            if self.task then
                self.task:Cancel()
                self.task = nil
            end
        end
    end
end

function Crop:GetDebugString()
    local s = "[" .. tostring(self.product_prefab) .. "] "
    if self.matured then
        s = s .. "DONE"
    else
        s = s .. string.format("%2.2f%% (done in %2.2f)", self.growthpercent, (1 - self.growthpercent)/self.rate)
    end
    s = s .. " || wither temp: " .. self.wither_temp
    return s
end

function Crop:Resume()
	if self.inst:HasTag("hydrofarm") then
		if self.withered then
			self:MakeWithered()
		else
    		self:DoGrow(0)
			if self.product_prefab and self.matured then
				self.grower.AnimState:PlayAnimation("grow_pst")
				if self.onmatured then
					self.onmatured(self.inst, self.grower)
				end
			end
		end	
	end

	if not self.matured and not self.withered then
    
		if self.task then
			scheduler:KillTask(self.task)
		end

		if self.inst:HasTag("hydrofarm") then
			self.grower.AnimState:SetPercent("grow", self.growthpercent + 0.2)
			self.inst.AnimState:PlayAnimation("empty")
		else
			self.inst.AnimState:SetPercent("grow", self.growthpercent)
		end

		local dt = 2
		self.task = self.inst:DoPeriodicTask(dt, function() self:DoGrow(dt) end)
	end
end

function Crop:StartGrowing(prod, grow_time, grower, percent)
    self.product_prefab = prod
    if self.task then
        scheduler:KillTask(self.task)
    end
    self.rate = 1/ grow_time
    self.growthpercent = percent or 0

	if self.inst:HasTag("hydrofarm") then
		grower.AnimState:SetPercent("grow", self.growthpercent + 0.2)
		self.inst.AnimState:PlayAnimation("empty")
	else
		self.inst.AnimState:SetPercent("grow", self.growthpercent)
	end
    
    local dt = 2
    self.task = self.inst:DoPeriodicTask(dt, function() self:DoGrow(dt) end)
    self.grower = grower
end

function Crop:GetGrower()
    return self.grower
end

function Crop:Harvest(harvester)
    if self.matured or self.withered then
        local product = nil
        if self.grower and self.grower:HasTag("fire") or self.inst:HasTag("fire") then
            local temp = SpawnPrefab(self.product_prefab)
            if temp.components.cookable and temp.components.cookable.product then
                product = SpawnPrefab(temp.components.cookable.product)
            else
                product = SpawnPrefab("seeds_cooked")
            end
            temp:Remove()
        else
            product = SpawnPrefab(self.product_prefab)
        end

        if product then
            self.inst:ApplyInheritedMoisture(product)
        end
        harvester.components.inventory:GiveItem(product, nil, Vector3(TheSim:GetScreenPos(self.inst.Transform:GetWorldPosition())))
        ProfileStatsAdd("grown_"..product.prefab) 
        
        self.matured = false
        self.withered = false
        self.inst:RemoveTag("withered")
        self.growthpercent = 0
        self.product_prefab = nil

        if self.grower and self.grower.components.grower then
            self.grower.components.grower:RemoveCrop(self.inst)
            self.grower = nil
        else
            self.inst:Remove()
        end
        
        return true
    end
end

function Crop:ForceHarvest(harvester)
    if self.matured or self.withered then
        local product = nil
        if self.grower and self.grower:HasTag("fire") or self.inst:HasTag("fire") then
            local temp = SpawnPrefab(self.product_prefab)
            if temp.components.cookable and temp.components.cookable.product then
                product = SpawnPrefab(temp.components.cookable.product)
            else
                product = SpawnPrefab("seeds_cooked")
            end
            temp:Remove()
        else
            product = SpawnPrefab(self.product_prefab)
        end

        if product then
            self.inst:ApplyInheritedMoisture(product)
        end

    	local tookProduct = false
    	if harvester and harvester.components.inventory then
            harvester.components.inventory:GiveItem(product)
    		tookProduct = true
    	else
    		if self.grower and self.grower:IsValid() then
    			product.Transform:SetPosition(self.grower.Transform:GetWorldPosition())
    			if product.components.inventoryitem then
    				product.components.inventoryitem:OnDropped(true)
    			end
     			tookProduct = true            
    		end
        end
    	if not tookProduct then
    		-- nothing to do with our product. What a waste
    		product:Remove()
    	end

        self.matured = false
        self.withered = false
        self.inst:RemoveTag("withered")
        self.growthpercent = 0
        self.product_prefab = nil

        if self.grower then
            if self.grower.components.grower then
                self.grower.components.grower:RemoveCrop(self.inst)            
            else
               self.inst:Remove()
            end
            self.grower = nil
        else 
            self.inst:Remove()
        end
        
        return true
    else
	-- nothing to give up, but pretend we did
        if self.grower then       
            if self.grower.components.grower then
                self.grower.components.grower:RemoveCrop(self.inst)
            end
            self.grower = nil       
        else
            self.inst:Remove()
        end        
    end
end

function Crop:Mature()
    if self.product_prefab and not self.matured and not self.withered then
        self.matured = true
        if self.onmatured then
            self.onmatured(self.inst, self.grower)
        end
    end
end


function Crop:IsReadyForHarvest()
    return ((self.matured == true and self.withered == false) or self.withered == true)
end


function Crop:CollectSceneActions(doer, actions)
    if (self:IsReadyForHarvest() or self:IsWithered()) and doer.components.inventory then
        table.insert(actions, ACTIONS.HARVEST)
    end

end

function Crop:LongUpdate(dt)
	self:DoGrow(dt)		
end


return Crop
