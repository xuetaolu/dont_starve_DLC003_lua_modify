local Fishable = Class(function(self, inst)
    self.inst = inst
    self.fish = {}
    self.maxfish = 10
    self.fishleft = 10
    self.hookedfish = {}
    self.fishrespawntime = nil
    self.respawntask = nil
	self.frozen = false
    
    self.controlsnibble = false
    self.waitingfornibble = nil

end)

function Fishable:GetDebugString()
    local str = string.format("fishleft: %d  maxfish: %d", self.fishleft, self.maxfish)
    if self.waitingfornibble then 
        str = str .. " Has waiting for nibble"
    end 
    return str
end


function Fishable:AddFish(prefab)
    self.fish[prefab] = prefab
end

function Fishable:SetRespawnTime(time)
    self.fishrespawntime = time
end

local function RespawnFish(inst)
    local fishable = inst.components.fishable
    if fishable then
        fishable.respawntask = nil
        if fishable.fishleft < fishable.maxfish then
            fishable:DeltaFish(1)
            if fishable.fishleft < fishable.maxfish then
                fishable:RefreshFish()
            end
        end
    end
end

function Fishable:DeltaFish(delta)
    self.fishleft = self.fishleft + delta

    if self.OnFishDelta then
        self.OnFishDelta(self.inst, delta)
    end
end

function Fishable:HookFish()
    local fishprefab = GetRandomKey(self.fish)
    local fish = SpawnPrefab(fishprefab)
    if fish and self.fishleft > 0 then
        self.hookedfish[fish] = fish
        self.inst:AddChild(fish)
        fish.entity:Hide()
        if fish.Physics then
            fish.Physics:SetActive(false)
        end
    end
    return fish
end

function Fishable:ReleaseFish(fish)
    if self.hookedfish[fish] == fish then
        fish:Remove()
        self.hookedfish[fish] = nil
    end
end

function Fishable:RemoveFish(fish)
    if self.hookedfish[fish] == fish then
        self.hookedfish[fish] = nil
        self.inst:RemoveChild(fish)
        fish.entity:Show()
        if fish.Physics then
            fish.Physics:SetActive(true)
        end
        if not self.respawntask then
            self:RefreshFish()
        end
        return fish
    end
end

function Fishable:FishCaught()
    self:DeltaFish(-1)
    if self.OnFishCaught then 
        self.OnFishCaught(self.inst)
    end 
end 

function Fishable:IsFrozenOver()
	return self.frozen
end

function Fishable:Freeze()
	self.frozen = true
end

function Fishable:Unfreeze()
	self.frozen = false
end


function Fishable:RefreshFish()
    if self.fishrespawntime then
        self.respawntask = self.inst:DoTaskInTime(self.fishrespawntime, RespawnFish)
    end
end

function Fishable:GetFishPercent()
    return self.fishleft / self.maxfish 
end

--I don't think this ever gets called 
function Fishable:FishedBy(fisherman)
    if self.fish then
        local spawnPos = Vector3(fisherman.Transform:GetWorldPosition()) - TheCamera:GetRightVec()
        local fishprefab = GetRandomKey(self.fish)
        local fish = SpawnPrefab(fishprefab)
        if fish then
            fish.Transform:SetPosition(spawnPos:Get() )
        end
    end
end


function Fishable:SetWaitingForNibble(rod)
    self.waitingfornibble = rod
    self.inst:PushEvent("fishingstarted", {fisherman = rod}) 
   -- self:DoNibble()
end 

function Fishable:CancelWaitingForNibble(rod)
  
    if self.waitingfornibble and self.waitingfornibble == rod then 
        self.inst:PushEvent("fishingstopped")
        self.waitingfornibble = nil 
    end 
end 

function Fishable:OnRodLost(rod)
    if self.waitingfornibble and self.waitingfornibble == rod then 
        self.inst:PushEvent("fishingstopped")
        self.waitingfornibble = nil 
    end 

end 

function Fishable:OnCaught(rod)
    --if self.waitingfornibble and self.waitingfornibble == rod then 
    self.inst:PushEvent("fishcaught")
        --self.waitingfornibble = nil 
   -- end 

end 

function Fishable:DoNibble()
    if self.waitingfornibble then 
        --print("Steal rod!")
        --Roll the dice 
        --self.waitingfornibble:OnRodStolen()
        self.waitingfornibble:ForceNibble()
    end 
end

function Fishable:OnSave()
    return {fish = self.fishleft, max = self.maxfish}
end


function Fishable:OnLoad(data)
    if data then
        self.fishleft = data.fish
        self.maxfish = data.max
        self:RefreshFish()
    end
end

return Fishable
