local Pickupable = Class(function(self, inst)
	self.inst = inst
	self.onpickupfn = nil    
end)

--function Pickupable:GetDebugString()
--	--return "inventory image name set to: " ..tostring(self.imagename)
--end

function Pickupable:SetOnPickupFn(fn)
	self.onpickupfn = fn
end

function Pickupable:CanPickUp()
	if self.canpickupfn then
		return self.canpickupfn(self.inst)
	end

	return self.canbepickedup
end

-- If this function retrns true then it has destroyed itself and you shouldnt give it to the player
function Pickupable:OnPickup(pickupguy)
	
	if self.inst.components.burnable and self.inst.components.burnable:IsSmoldering() then
		self.inst.components.burnable:StopSmoldering()
		if pickupguy.components.health then
			pickupguy.components.health:DoFireDamage(TUNING.SMOTHER_DAMAGE, nil, true)
			pickupguy:PushEvent("burnt")
		end
	end

	self.inst.Transform:SetPosition(0,0,0)
	self.inst:PushEvent("onpickup", {owner = pickupguy})
	if self.onpickupfn and type(self.onpickupfn) == "function" then
		return self.onpickupfn(self.inst, pickupguy)
	end
end

function Pickupable:CollectSceneActions(doer, actions, right)
	if right and self:CanPickUp() and doer.components.inventory and not (self.inst.components.burnable and self.inst.components.burnable:IsBurning()) then
		if self.inst:HasTag("aquatic") then
			table.insert(actions, ACTIONS.RETRIEVE)
		else
			table.insert(actions, ACTIONS.PICKUP)
		end
	end
end


return Pickupable
