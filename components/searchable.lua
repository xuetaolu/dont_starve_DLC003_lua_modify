local Searchable = Class(function(self, inst, searchcb)
    self.inst = inst
    self.OnSearchStart = nil
    self.OnSearchEnd = searchcb
	self.sanitydrain = 0
    self.maxsearch = -1
    self.searchleft = 1
    self.rechargetime = -1
	self.overridebuild = "rowboat_build"
    self.creaksound = "dontstarve_DLC002/common/boat_creaks"
end)

function Searchable:SetSearchStartAction(searchcb)
    self.OnSearchStart = searchcb
end

function Searchable:SetSearchEndAction(searchcb)
    self.OnSearchEnd = searchcb
end

function Searchable:SetSearchCount(search)
    self.maxsearch = search
    self.searchleft = search
end

function Searchable:OnSave()
    local data = {}
    local refs = {}

    if self.driver then 
        table.insert(refs, self.driver.GUID)
        data.driver = self.driver.GUID
    end 

    data.maxsearch = self.maxsearch
    data.searchleft = self.searchleft

    return data, refs
end   

function Searchable:LoadPostPass(ents, data)
    if data.driver and ents[data.driver] then 
        local driver = ents[data.driver].entity
        self:OnMounted(driver)
        driver.components.driver:OnSearch(self.inst)
    end
end 

function Searchable:OnLoad(data)
	self.searchleft = data.searchleft or self.searchleft
    self.maxsearch = data.maxsearch or self.maxsearch
end   

function Searchable:OnUpdate(dt)

end

function Searchable:CanDoHit()
    return self.next_hit_time <= GetTime()
end

function Searchable:GetHit()
    self.next_hit_time = GetTime() + self.hit_immunity
end

function Searchable:SetHitImmunity(time)
    self.hit_immunity = time
end

function Searchable:OnMounted(mounter)
    self.driver = mounter
    self.inst:PushEvent("mounted", {driver=mounter})
    self.inst:AddTag("NOCLICK")

    if self.OnSearchStart ~= nil then
		self.OnSearchStart(self.inst, mounter)
	end

    if mounter.components.sanity then
        mounter.components.sanity:DoDelta(-self.sanitydrain)
    end
end

function Searchable:OnDismounted(dismounter)
    if self.driver == dismounter then 
        self.driver = nil 
    end
    
    self.inst:PushEvent("dismounted", {driver=dismounter})
    self.inst:RemoveTag("NOCLICK")

    if self.OnSearchEnd ~= nil then
		self.OnSearchEnd(self.inst, dismounter)
	end

    if self.searchleft > 0 then
        self.searchleft = self.searchleft - 1
    elseif self.rechargetime > 0 and self.maxsearch > 0 then
        self.inst:DoTaskInTime(self.rechargetime, function() self.searchleft = self.maxsearch end)
    end
end

function Searchable:GetSanityDrain()
    return self.sanitydrain
end 

function Searchable:CanDrive(driver)
    return self.candrivefn == nil or self.candrivefn(self.inst, driver)
end

function Searchable:CollectSceneActions(doer, actions)
    if self.searchleft > 0 and doer.components.driver ~= nil then 
        if self.driver == nil and self:CanDrive(doer) then 
            if doer:HasTag("player") then
                local hat = doer.components.inventory and doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
                if hat and hat.name == "Diving Helmet" then
                    table.insert(actions, ACTIONS.SEARCH)
                end
            else
                table.insert(actions, ACTIONS.SEARCH)
            end
        end
    end
end


return Searchable
