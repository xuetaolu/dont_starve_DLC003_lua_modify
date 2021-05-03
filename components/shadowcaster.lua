
--local SHADE = 0.3

function unshadow(guid,data)

	local inst = Ents[guid]

	if inst == GetPlayer() then
		inst:RemoveTag("under_shadowcaster")
	else
		GetWorld().components.shadowmanager:PopShadow(inst)
	end
end

function shadow(guid)

	local inst = Ents[guid]

	if inst == GetPlayer() then
		inst:AddTag("under_shadowcaster")
	else
		GetWorld().components.shadowmanager:PushShadow(inst)
	end
end

local Shadowcaster = Class(function(self, inst)
	self.inst = inst
	self.effected = {}
	self.inst:StartUpdatingComponent(self)
	self.inst:ListenForEvent("onremove", function() self:OnRemoved() end, self.inst )	
	self.range = 12
end)

function Shadowcaster:setrange(range)	
	self.range = range
end

function Shadowcaster:OnRemoved()
	for i, data in pairs(self.effected)do
		unshadow(i,data)			
	end	
end

function Shadowcaster:OnUpdate(dt)
	local x,y,z = self.inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x,y,z,self.range,nil,{"INLIMBO","roc_body"})

	for i,ent in pairs(self.effected)do
		ent.shadowed = nil
	end

	for i,ent in ipairs(ents) do
		if self.effected[ent.GUID] then
			self.effected[ent.GUID].shadowed = true
		end
	end

	for i, data in pairs(self.effected)do
		if not data.shadowed then			
			unshadow(i,data)
			self.effected[i] = nil
		end
	end

	for i,ent in ipairs(ents) do
		if not self.effected[ent.GUID] then
			
			local r,g,b,a = shadow(ent.GUID)
			self.effected[ent.GUID] = {shadowed = true, r=r,g=g,b=b,a=a}
		end
	end
--[[
	for i, data in pairs(self.effected)do
		local ent = Ents[i]
		if data.r ~= data.targetr then
			local color_r,color_g,color_b,color_a = ent.AnimState:GetMultColour()
	    	inst.AnimState:SetMultColour(data1-r, data2-g, data3-b, data4)
		end		
	end
	]]
end

return Shadowcaster