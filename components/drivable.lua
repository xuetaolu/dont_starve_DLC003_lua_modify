local Drivable = Class(function(self, inst)
    self.inst = inst
    self.sanitydrain = 0
    self.runspeed = 6
    self.runanimation = "row_loop"
    self.overridebuild = "rowboat_build"
    self.creaksound = "dontstarve_DLC002/common/boat_creaks"
    self.hitmoisturerate = 1.0
    self.candrivefn = nil
    self.hit_immunity = 0.66 --time in seconds the boat is immune to hit state reactions after being hit.
    self.next_hit_time = 0
end)

function Drivable:OnSave()
    local data = {}
    local refs = {}

    if self.driver then 
        table.insert(refs, self.driver.GUID)
        data.driver = self.driver.GUID
    end 
    return data, refs
end   

function Drivable:LoadPostPass(ents, data)
    if data.driver and ents[data.driver] then 
        local driver = ents[data.driver].entity
        self:OnMounted(driver)
        driver.components.driver:OnMount(self.inst)
        --print("being mounted by driver!")
    end
end 

function Drivable:OnLoad(data)
	
end   
  
function Drivable:GetSeatOffset()

end

function Drivable:OnUpdate(dt)
    if self.inst:HasTag("boat") then

        local tile = self.inst:GetCurrentTileType()
    
        if tile and not GetMap():IsWater(tile) then
            if self.driver then
                self.driver.components.driver:OnDismount(nil, self.inst:GetPosition())
            end
            self.inst:onhammered(self.inst)
        end

    end
end

function Drivable:CanDoHit()
    return self.next_hit_time <= GetTime()
end

function Drivable:GetHit()
    self.next_hit_time = GetTime() + self.hit_immunity
end

function Drivable:SetHitImmunity(time)
    self.hit_immunity = time
end

function Drivable:GetIsSailEquipped()
    if self.alwayssail then return true end
    
    if self.inst.components.container then 
        local equipped = self.inst.components.container:GetItemInBoatSlot(BOATEQUIPSLOTS.BOAT_SAIL)
        if equipped and equipped:HasTag("sail") then 
            return true
        end 
    end 
    return false 
end 

function Drivable:OnMounted(mounter)
    --print("drivable getting mounted")
    self.driver = mounter
    if self.inst.components.boathealth then
        self.inst.components.boathealth:StartConsuming()
    elseif self.inst.components.fueled then 
        self.inst.components.fueled:StartConsuming()
    end 
    self.inst:PushEvent("mounted", {driver=mounter})
    self.inst:AddTag("NOCLICK")

    if self.inst.components.workable then
        self.inst.components.workable.workable = false
    end
    self.inst:StartUpdatingComponent(self)
end

function Drivable:OnDismounted(dismounter)
    --print("drivable getting dismounted")
    if self.driver == dismounter then 
        self.driver = nil 
        self.inst:StopUpdatingComponent(self)
    end
    if self.inst.components.boathealth then
        self.inst.components.boathealth:StopConsuming()
        self.inst.components.boathealth:SetIsMoving(false)
    elseif self.inst.components.fueled then 
        self.inst.components.fueled:StopConsuming()
    end 
    self.inst:PushEvent("dismounted", {driver=dismounter})
    self.inst:RemoveTag("NOCLICK")

    if self.inst.components.workable then
        self.inst.components.workable.workable = true
    end
end

function Drivable:GetSanityDrain()
    return self.sanitydrain
end 

function Drivable:GetHitMoistureRate()
    return self.hitmoisturerate
end

function Drivable:CanDrive(driver)
    return self.candrivefn == nil or self.candrivefn(self.inst, driver)
end

function Drivable:CollectSceneActions(doer, actions)
    if not doer.components.rider or not doer.components.rider:IsRiding() then
        if doer.components.driver then 
            if self.driver == nil and self:CanDrive(doer) then 
                table.insert(actions, ACTIONS.MOUNT)
           -- elseif self.driver == doer then
           --     table.insert(actions, ACTIONS.DISMOUNT)
            end
        end
    end
end


return Drivable
