require "class"

local Deployable = Class(function(self, inst)
    self.inst = inst
    self.min_spacing = 2
    self.quantizefn = nil 
    self.deploydistance = 0
end)



local notags = {'NOBLOCK', 'player', 'FX'}
local function default_test(inst, pt, atdeploy)
	local ground_OK = inst:GetIsOnLand(pt.x, pt.y, pt.z)
	if ground_OK then
        if not atdeploy then
    		local MouseCharacter = TheInput:GetWorldEntityUnderMouse()
    		if MouseCharacter and not MouseCharacter:HasTag("player") then
    			return false
    		end
        end
	    local ents = TheSim:FindEntities(pt.x,pt.y,pt.z, 4, nil, notags) -- or we could include a flag to the search?
		local min_spacing = inst.components.deployable.min_spacing or 2

	    for k, v in pairs(ents) do
			if v ~= inst and v:IsValid() and v.entity:IsVisible() and not v.components.placer and v.parent == nil then
				if distsq( Vector3(v.Transform:GetWorldPosition()), pt) < min_spacing*min_spacing then
					return false
				end
			end
		end
		return true
	end
	return false
end

function Deployable:IsDeployable(deployer)

    if deployer and self.userrequiredtags then
        local ok = false
        for i,tag in ipairs(self.userrequiredtags) do
            if deployer:HasTag(tag) then
                ok = true
            end
        end
        if not ok then return end
    end    
	return true
end

function Deployable:SetQuantizeFunction(fn) 
    self.quantizefn = fn 
end 

function Deployable:GetQuantizedPosition(pt)
    if self.quantizefn then 
        return self.quantizefn(pt)
    end 
    return pt
end 

function Deployable:CanDeploy(pt, atdeploy)
   -- return self.test and self.test(self.inst, pt) or default_test(self.inst, pt) --DH: Doing it this way falls back on default test if self.test returns false, that can't be right?
    if self.test then 
   		return self.test(self.inst, pt)
   	else 
   		return default_test(self.inst, pt, atdeploy)
   	end 
end

function Deployable:Deploy(pt, deployer)
    if not self.test or self.test(self.inst, pt, deployer) then
		if self.ondeploy then
	        self.ondeploy(self.inst, pt, deployer)
		end
        if self.inst:HasTag("plant") and deployer:HasTag("plantkin") then
            if deployer.growplantfn then
                deployer.growplantfn(deployer)
            end
        end
		return true
	end
end

function Deployable:CollectPointActions(doer, pos, actions, right)

    if right and self:CanDeploy(pos) then
    	if self.inst:HasTag("boat") then
        	table.insert(actions, ACTIONS.LAUNCH)
        else
            if self.deployatrange then
                table.insert(actions, ACTIONS.DEPLOY_AT_RANGE)
            else
            	table.insert(actions, ACTIONS.DEPLOY)
            end
        end
    end
end

function Deployable:CollectInventoryActions(doer, actions, right)
    local player = GetPlayer()

    if player and self.userrequiredtags then
        local ok = false
        for i,tag in ipairs(self.userrequiredtags) do
            if player:HasTag(tag) then
                ok = true
            end
        end
        if not ok then return end
    end
    
    if player and self.inst.components.inventoryitem and self.inst.components.inventoryitem:GetGrandOwner() == player then
        local playercontroller = player.components.playercontroller
        if playercontroller then
            if not playercontroller.deploy_mode then
                table.insert(actions, ACTIONS.TOGGLE_DEPLOY_MODE)
            end
        end
    end
end

return Deployable

