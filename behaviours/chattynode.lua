ChattyNode = Class(BehaviourNode, function(self, inst, chatlines, child, mood)
    BehaviourNode._ctor(self, "ChattyNode", {child})
    
    self.inst = inst
    if chatlines.untranslated then
        self.untranslatedchatlines = chatlines.untranslated 
        self.translationfn = chatlines.translationfn 
        self.chatlines = chatlines.chatlines
    else
        self.chatlines = chatlines
    end    
    self.nextchattime = nil
    self.mood = mood

end)


function ChattyNode:Visit()
    local child = self.children[1]
    
    child:Visit()
    self.status = child.status

    if self.status == RUNNING then
        
        local t = GetTime()
        
        if not self.nextchattime or t > self.nextchattime then
            
            local str = self.chatlines[math.random(#self.chatlines)]
            if self.translationfn then
                if not self.translationfn(self.inst) then
                    str = self.untranslatedchatlines[math.random(#self.untranslatedchatlines)]
                end
            end

            if self.inst.sayline then
                self.inst.sayline(self.inst, str, self.mood)
            else
                self.inst.components.talker:Say(str, nil, nil, nil, self.mood)
            end
            self.nextchattime = t + 10 +math.random()*10
        end
        if self.nextchattime then
            self:Sleep(self.nextchattime - t)
        end
    end    
end

