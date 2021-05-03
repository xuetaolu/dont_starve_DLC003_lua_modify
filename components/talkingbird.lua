

local TalkingBird = Class(function(self, inst)
	self.inst = inst
	self.time_to_convo = 10

	self.inst:ListenForEvent("ondropped", function() self:OnDropped() end)
	self.inst:ListenForEvent("mountboat", function() self:OnMounted() end, GetPlayer())
    self.inst:ListenForEvent("dismountboat", function() self:OnDismounted() end, GetPlayer())

	local dt = 5 + math.random()
	self.inst:DoPeriodicTask(dt, function() self:OnUpdate(dt) end)
	self.warnlevel = 0

end)


function TalkingBird:OnDropped()
	self:Say(STRINGS.TALKINGBIRD.on_dropped)
end

function TalkingBird:OnMounted()
	local grand_owner = self.inst.components.inventoryitem:GetGrandOwner()
	local owner = self.inst.components.inventoryitem.owner
	if grand_owner == GetPlayer() or owner == GetPlayer() then
		self:Say(STRINGS.TALKINGBIRD.on_mounted)
	end
end

function TalkingBird:OnDismounted()
	local grand_owner = self.inst.components.inventoryitem:GetGrandOwner()
	local owner = self.inst.components.inventoryitem.owner
	if grand_owner == GetPlayer() or owner == GetPlayer() then
		self:Say(STRINGS.TALKINGBIRD.on_dismounted)
	end
end

function TalkingBird:OnUpdate(dt)
	self.time_to_convo = self.time_to_convo - dt
	if self.time_to_convo <= 0 then
		self:MakeConversation()
	end
end

function TalkingBird:Say(list, sound_override)
	self.sound_override = sound_override
	self.inst.components.talker:Say(list[math.random(#list)])
	self.time_to_convo = math.random(60, 120)
end


function TalkingBird:MakeConversation()
	
	local grand_owner = self.inst.components.inventoryitem:GetGrandOwner()
	local owner = self.inst.components.inventoryitem.owner

	local quiplist = nil
	if owner == GetPlayer() then
		if self.inst.components.equippable and self.inst.components.equippable:IsEquipped() then
			--currently equipped
		else
			--in player inventory
			quiplist = STRINGS.TALKINGBIRD.in_inventory
		end
	elseif owner == nil then
		--on the ground
		-- quiplist = STRINGS.TALKINGBIRD.on_ground
	elseif grand_owner ~= owner and grand_owner == GetPlayer() then
		--in a backpack
		quiplist = STRINGS.TALKINGBIRD.in_container
	elseif owner and owner.components.container then
		--in a container
		quiplist = STRINGS.TALKINGBIRD.in_container
	else
		--owned by someone else
		quiplist = STRINGS.TALKINGBIRD.other_owner
	end

	if quiplist then
		self:Say(quiplist)
	end
end

return TalkingBird
