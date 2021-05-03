local Leader = Class(function(self, inst)
    self.inst = inst
    self.followers = {}
    self.numfollowers = 0
    
    self.inst:ListenForEvent("newcombattarget", function(inst, data) self:OnNewTarget(data.target) end)
    self.inst:ListenForEvent("attacked", function(inst, data) self:OnAttacked(data.attacker) end)  
    self.inst:ListenForEvent("death", function(inst) self:RemoveAllFollowers() end)

end)

function Leader:IsFollower(guy)
    return self.followers[guy] ~= nil
end

function Leader:OnAttacked(attacker)
    if not self:IsFollower(attacker) and self.inst ~= attacker then
        for k,v in pairs(self.followers) do
            if k.components.combat and k.components.follower and k.components.follower.canaccepttarget then
                k.components.combat:SuggestTarget(attacker)
            end
        end
    end
end

function Leader:CountFollowers(tag)
    if not tag then
        return self.numfollowers
    else
        local count = 0
        for k,v in pairs(self.followers) do
            if k:HasTag(tag) then
                count = count + 1
            end
        end
        return count
    end
end

function Leader:OnNewTarget(target)
    for k,v in pairs(self.followers) do
        if k.components.combat and k.components.follower and k.components.follower.canaccepttarget then          
            k.components.combat:SuggestTarget(target)
        end
    end
end

function Leader:RemoveFollower(follower)
    if follower and self.followers[follower] then
        follower:PushEvent("stopfollowing", {leader = self.inst} )
        self.followers[follower] = nil
        self.numfollowers = self.numfollowers - 1
        follower.components.follower:SetLeader(nil)
        if self.onremovefollower then
            self.onremovefollower(self.inst, follower)
        end
    end
end

function Leader:AddFollower(follower)

    print ("ADDING FOLLOWER ", follower.prefab)

    if self.followers[follower] == nil and follower.components.follower then
        self.followers[follower] = true
        self.numfollowers = self.numfollowers + 1
        follower.components.follower:SetLeader(self.inst)
        follower:PushEvent("startfollowing", {leader = self.inst} )
       
		follower:ListenForEvent("death", function(inst, data) self:RemoveFollower(follower) end, self.inst)
        self.inst:ListenForEvent("death", function(inst, data) self:RemoveFollower(follower) end, follower)

	    if self.inst:HasTag( "player" ) and follower.prefab then
		    ProfileStatsAdd("befriend_"..follower.prefab)
	    end

	end
end

function Leader:RemoveFollowersByTag(tag, validateremovefn)
    for k,v in pairs(self.followers) do
        if k:HasTag(tag) then
            if validateremovefn then
                if validateremovefn(k) then
                    self:RemoveFollower(k)
                end
            else
                self:RemoveFollower(k)
            end
        end
    end
end

function Leader:HibernateFollower(follower, hibernate)
	if follower.components.follower then
		follower.components.follower:HibernateLeader(hibernate)
	end
end 

function Leader:HibernateLandFollowers(hibernate)
	for k,v in pairs(self.followers) do
        if not k:HasTag("aquatic") and not k:HasTag("amphibious") then
			self:HibernateFollower(k, hibernate)
        end
    end
end 

function Leader:HibernateWaterFollowers(hibernate)
	for k,v in pairs(self.followers) do
        if k:HasTag("aquatic") and not k:HasTag("amphibious") then
            self:HibernateFollower(k, hibernate)
        end
    end
end

-- function Leader:SetRoBinFlight( fly )
--     local eyebone = self.inst.components.inventory:GetSingleItemByName("ro_bin_gizzard_stone")
--     if eyebone then
--         -- print_table (eyebone.components.leader.followers)
--         for follower, v in pairs(eyebone.components.leader.followers) do
--             if fly then
--                 follower:Fly()
--             else
--                 follower:Land()
--             end
--         end
--     end
-- end

function Leader:RemoveAllFollowers()
    for k,v in pairs(self.followers) do
        self:RemoveFollower(k)
    end
end

function Leader:IsBeingFollowedBy(prefabName)
    for k,v in pairs(self.followers) do
        if k.prefab == prefabName then
            return true
        end
    end
    return false
end


function Leader:OnSave()
    
    local saved = false
    local followers = {}
    for k,v in pairs(self.followers) do
        saved = true
        table.insert(followers, k.GUID)
    end
    
    if saved then
        return {followers = followers}, followers
    end
    
end

function Leader:LoadPostPass(newents, savedata)
    if savedata and savedata.followers then
        for k,v in pairs(savedata.followers) do
            local targ = newents[v]
            if targ and targ.entity.components.follower then
                self:AddFollower(targ.entity)
            end
        end
    end
end

function Leader:OnRemoveEntity()
	self:RemoveAllFollowers()
end

return Leader
