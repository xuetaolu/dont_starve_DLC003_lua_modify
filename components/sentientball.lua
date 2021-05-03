
local CHAT_TIME_MIN = 60
local CHAT_TIME_MAX = 120


local SentientBall = Class(function(self, inst)
	self.inst = inst
	self.time_to_convo = 10

	-- these prevent saying too much on events
	self.last_say_time = 0
	self.min_say_time = 4

	local dt = 5
	self.inst:DoPeriodicTask(dt, function() self:OnUpdate(dt) end)
	self.warnlevel = 0

end)


function SentientBall:OnDropped()
	self:Say(STRINGS.RAWLING.on_dropped)
end

function SentientBall:OnThrown()
	self:Say(STRINGS.RAWLING.on_thrown)
end

function SentientBall:OnEquipped()
	self:Say(STRINGS.RAWLING.equipped)
end

function SentientBall:OnIgnite()
	self:Say(STRINGS.RAWLING.on_ignite)
end

function SentientBall:OnExtinguish()
	self:Say(STRINGS.RAWLING.on_extinguish)
end


function SentientBall:OnUpdate(dt)
	self.time_to_convo = self.time_to_convo - dt
	if self.time_to_convo <= 0 then
		self:MakeConversation()
	end
end

function SentientBall:Say(list, sound_override)

	if GetTime() > self.last_say_time + self.min_say_time then
		self.sound_override = sound_override
		self.inst.components.talker:Say(list[math.random(#list)])
		self.time_to_convo = math.random(CHAT_TIME_MIN, CHAT_TIME_MAX)
		-- self.time_to_convo = math.random(4, 5)
		self.last_say_time = GetTime()
	end
end


function SentientBall:MakeConversation()
	
	local grand_owner = self.inst.components.inventoryitem:GetGrandOwner()
	local owner = self.inst.components.inventoryitem.owner

	local quiplist = nil
	if owner == GetPlayer() then
		if self.inst.components.equippable and self.inst.components.equippable:IsEquipped() then
			--currently equipped
			quiplist = STRINGS.RAWLING.equipped
		else
			--in player inventory
			quiplist = STRINGS.RAWLING.in_inventory
		end
	elseif owner == nil then
		--on the ground
		quiplist = STRINGS.RAWLING.on_ground
	elseif grand_owner ~= owner and grand_owner == GetPlayer() then
		--in a backpack
		quiplist = STRINGS.RAWLING.in_container
	elseif owner and owner.components.container then
		--in a container
		quiplist = STRINGS.RAWLING.in_container
	else
		--owned by someone else
		quiplist = STRINGS.RAWLING.other_owner
	end

	if quiplist then
		self:Say(quiplist)
	end
end

function SentientBall:CollectSceneActions(doer, actions)
    if self.inst.components.burnable and self.inst.components.burnable:IsBurning() then
    	table.insert(actions, ACTIONS.MANUALEXTINGUISH)
    elseif self.inst.components.burnable and self.inst.components.burnable:IsSmoldering() then
        table.insert(actions, ACTIONS.SMOTHER)
    end
end

return SentientBall
