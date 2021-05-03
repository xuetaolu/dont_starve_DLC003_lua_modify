local FishingRod = Class(function(self, inst)
    self.inst = inst
    self.target = nil
    self.fisherman = nil
    self.hookedfish = nil
    self.caughtfish = nil
    self.minwaittime = 0
    self.maxwaittime = 10
    self.minstraintime = 0
    self.maxstraintime = 6
    self.fishtask = nil

    -- for use with fish prefabs that control the nibbling 
    self.basenibbletime = 5
    self.nibbletimevariance = 5
    self.nibblestealchance = 0 

end)

local function DoNibble(inst)
    local fishingrod = inst.components.fishingrod
    if fishingrod and fishingrod.fisherman then
        inst:PushEvent("fishingnibble")
        fishingrod.fisherman:PushEvent("fishingnibble")
        fishingrod.fishtask = nil
    end
end



local function DoLoseRod(inst)

    local fishingrod = inst.components.fishingrod
    if fishingrod and fishingrod.fisherman then
        inst:PushEvent("fishingloserod")
        fishingrod.fisherman:PushEvent("fishingloserod")
        fishingrod.fishtask = nil
    end

     if fishingrod.target and fishingrod.target.components.fishable and fishingrod.target.components.fishable.controlsnibble then 
        fishingrod.target.components.fishable:OnRodLost(fishingrod)
    end 

end

function FishingRod:GetDebugString()
    local str = string.format("target: %s", tostring(self.target) )
    if self.hookedfish then
        str = str.." hooked: "..tostring(self.hookedfish)
    end
    if self.caughtfish then
        str = str.." caught: "..tostring(self.caughtfish)
    end
    return str
end

function FishingRod:ForceNibble()
    --DoLoseRod(self.inst)
    local rand = math.random(1,100)
    if rand < self.nibblestealchance then 
        DoLoseRod(self.inst)
    else
        DoNibble(self.inst)
    end 
end 

function FishingRod:SetWaitTimes(min, max)
    self.minwaittime = min
    self.maxwaittime = max
end

function FishingRod:SetStrainTimes(min, max)
    self.minstraintime = min
    self.maxstraintime = max
end

function FishingRod:CollectUseActions(doer, target, actions)
    if target.components.fishable and not self:HasCaughtFish() then
		if not target.components.fishable:IsFrozenOver() then
			if target == self.target then
				table.insert(actions, ACTIONS.REEL)
			else
				table.insert(actions, ACTIONS.FISH)
			end
		end
    end

    if target.components.workable and target.components.workable.action == ACTIONS.FISH then
        if not target.components.sinkable or target.components.sinkable.sunken then
            table.insert(actions, ACTIONS.FISH)
        end 
    end

    if target.components.flotsamfisher and not self:HasCaughtFish() then
        if target == self.target then
            table.insert(actions, ACTIONS.REEL)
        else
            table.insert(actions, ACTIONS.FISHOCEAN)
        end
    end

end

function FishingRod:CollectEquippedActions(doer, target, actions)

    if target.components.sinkable and  target.components.sinkable.sunken then
        table.insert(actions, ACTIONS.FISH)
    end

    if target.components.fishable and not self:HasCaughtFish() then
		if not target.components.fishable:IsFrozenOver() then
			if target == self.target then
				table.insert(actions, ACTIONS.REEL)
			else
				table.insert(actions, ACTIONS.FISH)
			end
		end
    end

    if target.components.workable and target.components.workable.action == ACTIONS.FISH then
        if not target.components.sinkable or target.components.sinkable.sunken then
            table.insert(actions, ACTIONS.FISH)
        end 
    end

    if target.components.flotsamfisher and not self:HasCaughtFish() then
        if target == self.target then
            table.insert(actions, ACTIONS.REEL)
        else
            table.insert(actions, ACTIONS.FISHOCEAN)
        end
    end
end

function FishingRod:OnUpdate(dt)
    if self:IsFishing() then
        if not self.fisherman:IsValid()
           or (not self.fisherman.sg:HasStateTag("fishing") and not self.fisherman.sg:HasStateTag("catchfish"))
           or (self.inst.components.equippable and not self.inst.components.equippable.isequipped) then
            self:StopFishing()
        end
    end
end


function FishingRod:IsFishing()
    return self.target ~= nil and self.fisherman ~= nil
end

function FishingRod:HasHookedFish()
    return self.target ~= nil and self.hookedfish ~= nil
end

function FishingRod:HasCaughtFish()
    return self.caughtfish ~= nil
end

function FishingRod:FishIsBiting()
    return self.fisherman and self.fisherman.sg:HasStateTag("nibble")
end

function FishingRod:StartFishing(target, fisherman)
    self:StopFishing()
    if target and target.components.fishable then
        self.target = target
        self.fisherman = fisherman
        self.inst:StartUpdatingComponent(self)
    elseif target and target.components.workable and target.components.workable.action == ACTIONS.FISH then
        self.target = target
        self.fisherman = fisherman
        if target.components.sinkable and fisherman then
            fisherman.sinkablebuild = target.components.sinkable.swapbuild
            fisherman.sinkablesymbol = target.components.sinkable.swapsymbol
        end
    elseif target and target.components.flotsamfisher then
        self.target = target
        self.fisherman = fisherman
    end
end

function FishingRod:WaitForFish()
    if self.target and self.target.components.fishable  then
        self:CancelFishTask()
        if self.target.components.fishable.controlsnibble then 
            self.target.components.fishable:SetWaitingForNibble(self)
        else

            local fishleft = self.target.components.fishable:GetFishPercent()
            local nibbletime = nil
            if fishleft > 0 then
                nibbletime = self.minwaittime + (1.0 - fishleft)*(self.maxwaittime - self.minwaittime)
            end
            if nibbletime then
                self.fishtask = self.inst:DoTaskInTime(nibbletime, DoNibble)
            end
        end 
    end
end

function FishingRod:CancelFishTask()

    if self.fishtask then
        self.fishtask:Cancel()
    end
    if self.target and self.target.components.fishable and self.target.components.fishable.controlsnibble then 
        self.target.components.fishable:CancelWaitingForNibble(self)
    end 

    self.fishtask = nil
end




function FishingRod:StopFishing()
    self:CancelFishTask() --Do this before setting target to nil 
    if self.target and self.fisherman then
        self.inst:PushEvent("fishingcancel")
        self.fisherman:PushEvent("fishingcancel")
        self.target = nil
        self.fisherman = nil
    end
    self.inst:StopUpdatingComponent(self)
    self.hookedfish = nil
    self.caughtfish = nil
end

function FishingRod:Hook()
    if self.target and self.target.components.fishable then
        self.hookedfish = self.target.components.fishable:HookFish()
        if self.inst.components.finiteuses then
            local roddurability = self.inst.components.finiteuses:GetPercent()
            local loserodtime = self.minstraintime + roddurability*(self.maxstraintime - self.minstraintime)
            self.fishtask = self.inst:DoTaskInTime(loserodtime, DoLoseRod)
        end
        self.inst:PushEvent("fishingstrain")
        self.fisherman:PushEvent("fishingstrain")
    end
end

function FishingRod:Release()
    if self.target and self.target.components.fishable and self.hookedfish then
        self.target.components.fishable:ReleaseFish(self.hookedfish)
        self:StopFishing()
    end
end

function FishingRod:Reel()
    
    if self.target and self.target.components.fishable and self.hookedfish then
        self.caughtfish = self.target.components.fishable:RemoveFish(self.hookedfish)
        self.hookedfish = nil
        self:CancelFishTask()
        if self.caughtfish then
            self.inst:PushEvent("fishingcatch", {build = self.caughtfish.build} )
            self.fisherman:PushEvent("fishingcatch", {build = self.caughtfish.build} )
        end
        if self.target and self.target.components.fishable and self.target.components.fishable.controlsnibble then 
            self.target.components.fishable:OnCaught(self)
        end 
    end
end

function FishingRod:Collect()
    if self.caughtfish and self.fisherman then

        --if the player's in a boat we just want to put the fish in their inventory 
        if self.fisherman.sg:HasStateTag("boating") then 
            --print("bargle, I'm boating!")
            self.fisherman.components.inventory:GiveItem(self.caughtfish, nil, Vector3(TheSim:GetScreenPos(self.fisherman.Transform:GetWorldPosition())))
        else 
            local spawnPos = Vector3(self.fisherman.Transform:GetWorldPosition() )
            local offset = spawnPos - Vector3(self.target.Transform:GetWorldPosition() )
            offset = offset:GetNormalized()
            spawnPos = spawnPos + offset
            self.caughtfish.Transform:SetPosition(spawnPos:Get() )
        end
        self.inst:PushEvent("fishingcollect", {fish = self.caughtfish} )
        self.fisherman:PushEvent("fishingcollect", {fish = self.caughtfish} )

        if self.target and self.target.components.fishable then
            self.target.components.fishable:FishCaught()
        end 

        self:StopFishing()
    end
end

function FishingRod:Retrieve()
    local numworks = 1
    if self.fisherman and self.fisherman.components.worker then
        numworks = self.fisherman.components.worker:GetEffectiveness(ACTIONS.FISH)
    end
    if self.target and self.target.components.workable then
        self.target.components.workable:WorkedBy(self.fisherman, numworks)
        self.inst:PushEvent("retrievecollect")
        self.target:PushEvent("retrievecollect")
    end
    if self.target and self.target.components.sinkable then
        self.target:Hide()
    end
end

function FishingRod:CollectFlotsam()
    print'collect flotsam'
    print(self.target)
    print(self.fisherman)
    if self.target and self.target.components.flotsamfisher and self.fisherman then
        print'inside fn'
        self.target.components.flotsamfisher:Fish(self.fisherman)
        self.inst:PushEvent("fishingcollect", {fish = nil} )
        self.fisherman:PushEvent("fishingcollect", {fish = nil} )
        self:StopFishing()
    end
end


return FishingRod