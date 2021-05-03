--Creates & Launches "throwable" items.
local Thrower = Class(function(self, inst)
	self.inst = inst
	self.throwable_prefab = "coconade"
	self.range = 15
	self.onthrowfn = nil
end)

function Thrower:CanThrowAtPoint(pt)
	if self.canthrowatpointfn then
		return self.canthrowatpointfn(self.inst, pt)
	end

	return true
end

function Thrower:GetThrowPoint()
	--For use with controller.
	local owner = self.inst.components.inventoryitem.owner
	if not owner then return end
	local pt = nil
	local rotation = owner.Transform:GetRotation()*DEGREES
	local pos = owner:GetPosition()

	for r = self.range, 1, -1 do
        local numtries = 2*PI*r
		pt = FindValidPositionByFan(rotation, r, numtries, function() return true end) --TODO: #BDOIG Might not need to be walkable?
		if pt then
			return pt + pos
		end
	end
end

function Thrower:CollectPointActions(doer, pos, actions, right)
    if right then
    	if self.target_position then
    		pos = self.target_position
    	end
		if self:CanThrowAtPoint(pos) then
			table.insert(actions, ACTIONS.LAUNCH_THROWABLE)
		end
	end
end

function Thrower:CollectEquippedActions(doer, target, actions, right)
	if right and self:CanThrowAtPoint(target:GetPosition()) and not target.components.machine then
		table.insert(actions, ACTIONS.LAUNCH_THROWABLE)
	end
end

function Thrower:Throw(pt)
	local thrown = SpawnPrefab(self.throwable_prefab)
	thrown.Transform:SetPosition(self.inst:GetPosition():Get())
	thrown.components.throwable:Throw(pt, self.inst)

	if self.onthrowfn then
		self.onthrowfn(self.inst, thrown, pt)
	end
end

return Thrower