local RespondToPlayer = Class(function(self, inst)
    self.inst = inst
    self.approachfn = nil 
    self.dist = 5

    self.inst:StartUpdatingComponent(self)
end)

function RespondToPlayer:OnUpdate(dt)
	local hunter = FindEntity(self.inst, self.dist, nil, {'player'}, {'notarget'} )

	if hunter then 
		self.approachfn(self.inst, hunter)
	end 
end 

return RespondToPlayer

