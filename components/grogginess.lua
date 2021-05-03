local easing = require("easing")

local Grogginess = Class(function(self, inst)
    self.inst = inst

    self.resistance = 1
    self.grog_amount = 0
    self.wearofftime = nil
    self.wearoffduration = TUNING.GROGGINESS_WEAR_OFF_DURATION
    self.decayrate = TUNING.GROGGINESS_DECAY_RATE

    self.speed_mod = 1

    self:SetDefaultTests()

    self.inst:ListenForEvent("startfoggrog", function(inst, data) self:SetGroggyWeather(true) end, self.inst)
    self.inst:ListenForEvent("stopfoggrog", function(inst, data) self:SetGroggyWeather(false)  end, self.inst)

    self.inst:ListenForEvent("equip", function(inst, data) self:onequip(data)  end, self.inst)


end)

function Grogginess:OnRemoveFromEntity()
    if self.inst:HasTag("groggy") then
        self.inst:RemoveTag("groggy")
        if self.onwearofffn ~= nil then
            self.onwearofffn(self.inst)
        end
    end
end

function DefaultKnockoutTest(inst)
    local self = inst.components.grogginess
    return self.grog_amount >= self.resistance
        and not (inst.components.health ~= nil and inst.components.health.takingfiredamage)
        and not (inst.components.burnable ~= nil and inst.components.burnable:IsBurning())
end

function DefaultComeToTest(inst)
    local self = inst.components.grogginess
    return self.knockouttime > self.knockoutduration and self.grog_amount < self.resistance
end

function DefaultWhileGroggy(inst)
    local self = inst.components.grogginess
    local pct = (self.grog_amount and self.grog_amount < self.resistance) and self.grog_amount / self.resistance or 1
  --  if self.grog_amount then
   --     pct = self.grog_amount < self.resistance and self.grog_amount / self.resistance or 1
   -- end
    self.speed_mod = Remap(pct, 1, 0, TUNING.MIN_GROGGY_SPEED_MOD, TUNING.MAX_GROGGY_SPEED_MOD)
end

function DefaultWhileWearingOff(inst)
    local self = inst.components.grogginess
    local pct = self.wearofftime < TUNING.GROGGINESS_WEAR_OFF_DURATION and easing.inQuad(self.wearofftime / TUNING.GROGGINESS_WEAR_OFF_DURATION, 0, 1, 1) or 1
    self.speed_mod = Remap(pct, 0, 1, TUNING.MAX_GROGGY_SPEED_MOD, 1)    
end

function DefaultOnWearOff(inst)
    local self = inst.components.grogginess
    self.speed_mod = 1
end

function Grogginess:SetDefaultTests()
    self.knockouttestfn = DefaultKnockoutTest
    self.whilegroggyfn = DefaultWhileGroggy
    self.whilewearingofffn = DefaultWhileWearingOff
    self.onwearofffn = DefaultOnWearOff
end

-----------------------------------------------------------------------------------------------------

function Grogginess:SetComeToTest(fn)
    self.cometotestfn = fn
end

function Grogginess:SetKnockOutTest(fn)
    self.knockouttestfn = fn
end

function Grogginess:SetResistance(resist)
    self.resistance = resist
end

function Grogginess:SetDecayRate(rate)
    self.decayrate = rate
end

function Grogginess:SetWearOffDuration(duration)
    self.wearoffduration = duration
end

function Grogginess:IsKnockedOut()
    return self.inst.sg ~= nil and self.inst.sg:HasStateTag("knockout")
end

function Grogginess:IsGroggy()
    return self.grog_amount > 0 and not self:IsKnockedOut()
end

function Grogginess:HasGrogginess()
    return self.grog_amount > 0
end

function Grogginess:GetDebugString()
    local grog = 0
    if self.grog_amount then
        grog = self.grog_amount
    end

    return string.format("Groggy: %d/%d",
           grog,
            self.resistance)
end

function Grogginess:onequip(data)
    if self.groggyweather then
        local hotitems = self:hasoverheatinggear()
        if hotitems and #hotitems > 0 then
            local string = hotitems[1].name        
            if data  then
                string = nil
                for i,item in ipairs(hotitems)do
                    if item == data.item then
                        string = item.name
                    end
                end
            end            
            if string then
                self.inst.components.talker:Say(string.format(GetString(self.inst.prefab, "ANNOUNCE_TOO_HUMID"), string) )  
            end
        end
    end
end

function Grogginess:SetGroggyWeather(groggyweather)
    print("SETTING GROGGY WEATHER", groggyweather)
    self.groggyweather = groggyweather
    if groggyweather and not self.inst:HasTag("groggy") then
        
        self.inst:StartUpdatingComponent(self)

        self:onequip()
    end
end

function Grogginess:AddGrogginess(grogginess)

    if grogginess <= 0 then
        return
    end

    self.grog_amount = self.grog_amount + grogginess
    self.wearofftime = nil

    if not self.inst:HasTag("groggy") then
        self.inst:AddTag("groggy")
        self.inst:StartUpdatingComponent(self)
    end
end

function Grogginess:hasoverheatinggear()
    
    local overheat = false

    if self.inst:HasTag("venting") then
        return false
    end

    local inventory = self.inst.components.inventory
    if inventory then
       
        local headitem = inventory.equipslots[EQUIPSLOTS.HEAD]
        local bodyitem = inventory.equipslots[EQUIPSLOTS.BODY]

        local hotitems = {}
        if bodyitem then
            if not bodyitem:HasTag("vented") then
                table.insert(hotitems,bodyitem)
            end
        end
        if headitem then
            if not headitem:HasTag("vented") then
                table.insert(hotitems,headitem)
            end
        end        
        if #hotitems > 0 then                            
            return hotitems
        else
            if self.inst:HasTag("groggy") then
                self.inst.components.talker:Say(GetString(self.inst.prefab, "ANNOUNCE_DEHUMID")) 
            end                
        end
    end
    
    return false
end

function Grogginess:OnUpdate(dt) 
  
    if self.grog_amount and self.grog_amount >= 0 then
        self.grog_amount = math.max(0, self.grog_amount - self.decayrate)
        if self.grog_amount <= 0 then
            self.grog_amount = nil            
            self.inst:RemoveTag("groggy")
            self.wearofftime = 0
        end    
    end

    if not self.grog_amount then
        if self.groggyweather and self:hasoverheatinggear() and not TheCamera.interior then
            self.wearofftime = nil
            if not self.inst:HasTag("groggy") then
                self.inst:AddTag("groggy")
            end            
        else
            self.inst:RemoveTag("groggy")
            self.wearofftime = 0
        end                
    end

    if self.wearofftime then
        self.wearofftime = math.min(self.wearoffduration, self.wearofftime + dt)
        if self.wearofftime >= self.wearoffduration then            
            self.wearofftime = nil
            if self.onwearofffn ~= nil then
                self.onwearofffn(self.inst)
            end            
            self.inst:StopUpdatingComponent(self)    
        elseif self.whilewearingofffn ~= nil then
            self.whilewearingofffn(self.inst)
        end  
    end

    if self.inst:HasTag("groggy") then
        if self.whilegroggyfn ~= nil then
            self.whilegroggyfn(self.inst)
        end             
    end
end

return Grogginess
