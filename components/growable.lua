local Growable = Class(function(self, inst)
    self.inst = inst
    self.stages = nil
    self.stage = 1
    self.loopstages = false
    self.growonly = false
    self.springgrowth = false
    self.ongrowthfn = nil
    self.growoffscreen = nil
end)

--[[local waiting_for_growth = {}
local function GrowableUpdate(dt)
	local tick = TheSim:GetTick()
	if waiting_for_growth[tick] then
		for k,v in pairs(waiting_for_growth[tick]) do
			if v:IsValid() and v.components.growable then
				v.components.growable:DoGrowth()
			end
		end
		waiting_for_growth[tick] = nil
	end	
end

local function GrowableLongUpdate(dt)
	
end
--]]

function Growable:SetOnGrowthFn(fn)
    self.ongrowthfn = fn
end

function Growable:OnRemoveEntity()
	self:StopGrowing()
end

function Growable:GetDebugString()
	if self.targettime then
		return string.format("Growing! stage %d, timeleft %2.2fs", self.stage, self.targettime - GetTime())
	end
	return "Not Growing"
end

local function ongrow(inst)
	inst.components.growable:DoGrowth()
end

function Growable:StartGrowing(time)
	--if true then return end

    if #self.stages == 0 then
        print "Growable component: Trying to grow without setting the stages table"
        return
    end
    
    if self.stage <= #self.stages then
        self:StopGrowing()
        
        local timeToGrow = 10
        if time then
			timeToGrow = time
        elseif self.stages[self.stage].time then
			timeToGrow = self.stages[self.stage].time(self.inst, self.stage)
		end
		--print ("growing ", time, self.stage, timeToGrow)

        if timeToGrow then
            if self.springgrowth and GetSeasonManager() and (GetSeasonManager():IsSpring() or GetSeasonManager():IsGreenSeason()) then
                timeToGrow = timeToGrow * TUNING.SPRING_GROWTH_MODIFIER
            end

            local aporkalypse = GetAporkalypse()
            if aporkalypse and aporkalypse:IsActive() then
                timeToGrow = timeToGrow * TUNING.APORKALYPSE_GROWTH_MODIFIER
            end

			self.targettime = GetTime() + timeToGrow
            
            if not self.inst:IsAsleep() and not self.growoffscreen then
				if self.task then
					self.task:Cancel()
					self.task = nil
				end
				self.task = self.inst:DoTaskInTime(timeToGrow, ongrow)
			end
        end
    end
end

function Growable:GetNextStage()
    local stage = self.stage + 1
    if stage > #self.stages then
        if self.loopstages then
            stage = 1
        else
            stage = #self.stages
        end
    end
    return stage
end

function Growable:DoGrowth()

    if self.task then
        self.task:Cancel()
        self.task = nil
    end

    local stage = self:GetNextStage()

    local lastStage = self.stage

    if not self.growonly then
        self:SetStage(stage)
    end
    
    if self.stages[stage] and self.stages[stage].growfn then
        self.stages[stage].growfn(self.inst)
    end

    if self.ongrowthfn then
        self.ongrowthfn(self.inst, lastStage, stage)
    end
    
    if stage < #self.stages or self.loopstages then 
		self:StartGrowing()
    end
end

function Growable:StopGrowing()
    
	self.targettime = nil
	
	--[[if self.targettick and waiting_for_growth[self.targettick] then
		waiting_for_growth[self.targettick][self.inst] = nil
    end
    self.targettick = nil
    --]]

	if self.task then
		self.task:Cancel()
		self.task = nil
	end
	
end

function Growable:Pause()
    local time = GetTime()
    if self.targettime and self.targettime > time then
        self.pausedremaining = math.floor(self.targettime - time)
    end
    self:StopGrowing()
end

function Growable:Resume()
    if self.pausedremaining then
        self:StartGrowing(self.pausedremaining)
        self.pausedremaining = nil
    end
end

function Growable:SetStage(stage)
    if stage > #self.stages then
        stage = #self.stages
    end
    
    self.stage = stage
    
    if self.stages[stage] and self.stages[stage].fn then
        self.stages[stage].fn(self.inst)
    end
end

function Growable:SetStagePlanted()

	local stage = 0
	for i=1, #self.stages do
		if self.stages[i].name == "planted" then
			stage = i
			break
		end
	end

	if stage == 0 then
		print("Planted stage not found")
		return
	end

    self.stage = stage
    
    if self.stages[self.stage] and self.stages[self.stage].fn then
        self.stages[self.stage].fn(self.inst)
    end
end

function Growable:GetCurrentStageData()
    return self.stages[self.stage]
end

function Growable:OnSave()
    local data = 
    {
        --stage = self.stage ~= 1 and self.stage or nil --1 is kind of by default
        stage = self.stage --Coral starts on stage 3 so we can't assume that stage 1 is default anymore
    }
    local time = GetTime()
    if self.targettime and self.targettime > time then
        data.time = math.floor(self.targettime - time)
    end
    return data
end   
   
function Growable:OnLoad(data)
    if data then    
        self:SetStage(data.stage or self.stage)
        if data.time then
            self:StartGrowing(data.time)
        end
    end
end

function Growable:OnRemoveFromEntity()
    self:StopGrowing()
end


function Growable:LongUpdate(dt)
	if self.targettime then
		local time_from_now = (self.targettime - dt) - GetTime()

        -- this used to max time_from_now to 0 but in order the for the wake up to process multiple stages, it can't
        -- OLD: time_from_now = math.max(0, time_from_now)		

        self:StartGrowing(time_from_now)
	end
end

function Growable:OnEntitySleep()
	if self.task then
		self.task:Cancel()
		self.task = nil
	end
end

function Growable:OnEntityWake()

	if self.targettime then
        if self.targettime < GetTime() then
            local timeblock = GetTime() - self.targettime
			self.targettime = nil
            self:DoGrowth()   

            -- grow through more stages if there are any.
            if self.targettime then               
                while self.targettime and timeblock>0 do                       
                    timeblock = timeblock - self.targettime                    
                    if timeblock >= 0 then
						self.targettime = nil
                        self:DoGrowth()
                    else
                        self:StartGrowing(math.abs(timeblock))
                    end                               
                end
            end

        elseif not self.growoffscreen then
            if self.task then
                self.task:Cancel()
                self.task = nil
            end
            self.task = self.inst:DoTaskInTime(self.targettime - GetTime(), ongrow)
		end
	end
end

--RegisterStaticComponentUpdate("growable", GrowableUpdate)
--RegisterStaticComponentLongUpdate("growable", GrowableLongUpdate)

return Growable
