-- sticker as in the poking variety

local Sticker = Class(function(self, inst)
	self.inst = inst
	--self.stickervalue = 1
end)

function Sticker:CollectUseActions(doer, target, actions)
	if target.components.stickable and target.components.stickable.canbesticked then
		table.insert(actions, ACTIONS.STICK)
	end
end


return Sticker
