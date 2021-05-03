SpreadOut = Class(BehaviourNode, function(self, inst, spread_dist, others_tags)
	BehaviourNode._ctor(self, "SpreadOut")
	self.inst = inst

	self.spread_dist = spread_dist

	self.others_tags = others_tags

	self.nearby_ents = {}

end)

function SpreadOut:__tostring()
	return "Spread Out"
end

function SpreadOut:GetOthers()

end

function SpreadOut:GetPosition()

end

function SpreadOut:Visit()
	--behaviour is unfinished
 	self.status = FAILED

	--[[
	local pos = self.inst:GetPosition()

	if self.status == READY then
		--Check for nearby self.nearby_ents to spread out with
		local possible_ents = TheSim:FindEntities(pos.x, pos.y, pos.z, self.spread_dist, self.others_tags)

		for k,v in pairs(possible_ents) do
			if v ~= self.inst then
				self.nearby_ents[v] = self.inst:GetDistanceSqToInst(v)
			end
		end

		for k,v in pairs(self.nearby_ents) do
			if v >= (self.spread_dist * self.spread_dist) then
				self.nearby_ents[k] = nil
			end
		end

		if next(self.nearby_ents) ~= nil then
			self.status = RUNNING
		else
			self.status = FAILED
		end
	end

	if self.status == RUNNING then
		if not self.nearby_ents or not next(self.nearby_ents) then
			self.status = FAILED
			return
		end

		local targetinfo = {}
		local direction = Vector3(0,0,0)
		local should_move = false
		for k,v in pairs(self.nearby_ents) do
			local distsq = self.inst:GetDistanceSqToInst(k)

			if distsq <= self.spread_dist * self.spread_dist then
				local totar = self.inst:GetPosition() - k:GetPosition()
				direction = direction + totar:Normalize()
				should_move = true
			end
		end

		direction = direction * 0.5

		-- if self.inst.components.debugger and direction and pos then
		--     self.inst.components.debugger:SetOrigin("debuggy", pos.x, pos.z)
		--     local debugpos = pos + (direction * 2)
		--     self.inst.components.debugger:SetTarget("debuggy", debugpos.x, debugpos.z)
		--     self.inst.components.debugger:SetColour("debuggy", 1, 0, 0, 1)
		-- end

		local angle = math.atan2(direction.z, direction.x) * (180/math.pi)

	    if angle and should_move then
	        self.inst.components.locomotor:RunInDirection(-angle)
		else
            self.status = SUCCESS
            self.inst.components.locomotor:Stop()
	    end

        self:Sleep(1/4)
	end

	--]]
end