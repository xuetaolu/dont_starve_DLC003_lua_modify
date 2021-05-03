local FollowText = require "widgets/followtext"

Line = Class(function(self, message, duration, noanim)
    self.message = message
    self.duration = duration
    self.noanim = noanim
end)


local Talker = Class(function(self, inst)
    self.inst = inst
    self.task = nil
    self.ignoring = false

    self.special_speech = false
end)

function Talker:IgnoreAll()
    self.ignoring = true
end

function Talker:StopIgnoringAll()
    self.ignoring = false
end

local function sayfn(inst, script)
    
    if not inst.components.talker.widget then
		if not GetPlayer().HUD then
			-- this asserts, but I don't see how it gets there, so added some logging
			print("Talker: no HUD!")
			print(debugstack())
		    for k,line in ipairs(script) do
				for i,v in pairs(line) do
					print("",i,v)
				end
				print("-----")
			end
		end
        inst.components.talker.widget = GetPlayer().HUD:AddChild(FollowText(inst.components.talker.font or TALKINGFONT, inst.components.talker.fontsize or 35))
    end

    inst.components.talker.widget.symbol = inst.components.talker.symbol
    inst.components.talker.widget:SetOffset(inst.components.talker.offset or Vector3(0, -400, 0))
    inst.components.talker.widget:SetTarget(inst)

    
    if inst.components.talker.colour then
        inst.components.talker.widget.text:SetColour(inst.components.talker.colour.x, inst.components.talker.colour.y, inst.components.talker.colour.z, 1)
    end

    for k,line in ipairs(script) do
        
        if line.message then
            if inst.components.talker.allcaps then
                inst.components.talker.widget.text:SetString(string.upper(line.message))
            else
                inst.components.talker.widget.text:SetString(line.message)
            end
            inst:PushEvent("ontalk", {noanim = line.noanim})
        else
            inst.components.talker.widget:Hide()
        end
        Sleep(line.duration)
    
    end
    inst.components.talker.widget:Kill()    
    inst.components.talker.widget = nil
    inst:PushEvent("donetalking")

end

function Talker:OnRemoveEntity()
	self:ShutUp()	
end

function Talker:ShutUp()
    if self.task then
        scheduler:KillTask(self.task)
        
        if self.widget then
            self.widget:Kill()
            self.widget = nil
        end
        self.inst:PushEvent("donetalking")
        self.task = nil
    end
end

function Talker:SetSpecialSpeechFn(fn)
    if fn then self.specialspeechfn = fn end
    self.special_speech = true
end

function Talker:Say(script, time, noanim, kill_loop, mood)
    if self.inst.components.health and  self.inst.components.health:IsDead() then
        return
    end
    
    if self.inst.components.sleeper and  self.inst.components.sleeper:IsAsleep() then
        return
    end
    
    if self.ignoring then
        return
    end

    if self.special_speech then
        if self.specialspeechfn then
            script = self.specialspeechfn(self.inst.prefab)
        else
            script = GetSpecialCharacterString(self.inst.prefab)
        end
    end
    
	if self.ontalk then
		self.ontalk(self.inst, script, mood)
	end
    
    local lines = nil
    if type(script) == "string" then
        lines = {Line(script, time or 2.5, noanim)}
    else
        lines = script
    end
    
        if kill_loop then         
        self.inst:DoTaskInTime(time or 2.5, function() 
            self.inst.SoundEmitter:KillSound("talk")
            if self.endspeechsound then
                self.inst.SoundEmitter:PlaySound(self.endspeechsound)
            end
            
        end)
    end

    self:ShutUp()
    if lines then
        self.task = self.inst:StartThread( function() sayfn(self.inst, lines) end)    
    end
end

return Talker