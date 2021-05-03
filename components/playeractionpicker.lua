local PlayerActionPicker = Class(function(self, inst)
    self.inst = inst
    self.pointspecialactionsfn = nil
end)

function PlayerActionPicker:SortActionList(actions, target, useitem)

    if #actions > 0 then
        for v=#actions,1,-1 do  
            if self.inst.components.rider and self.inst.components.rider:IsRiding() and (not actions[v].mount_enabled or actions[v].mount_enabled == false) then
                table.remove(actions,v)
            end
        end
    end

    if #actions > 0 then
        table.sort(actions, function(l, r) return l.priority > r.priority end)
        local ret = {}

        for k,v in ipairs(actions) do
            if not target then
                table.insert(ret, BufferedAction(self.inst, nil, v, useitem))
            elseif target:is_a(EntityScript) then
                table.insert(ret, BufferedAction(self.inst, target, v, useitem))
            elseif target:is_a(Vector3) then
                local quantizedTarget = target 
                local distance = nil 

                --If we're deploying something it might snap to a grid, if so we want to use the quantized position as the target pos 
                if v == ACTIONS.DEPLOY and useitem.components.deployable then 
                    distance = useitem.components.deployable.deploydistance
                    quantizedTarget = useitem.components.deployable:GetQuantizedPosition(target)
                end

                local ba = BufferedAction(self.inst, nil, v, useitem, quantizedTarget)
                if distance then 
                    ba.action.distance = distance 
                end 
                table.insert(ret, ba)
            end
        end
        return ret
    end
end

function PlayerActionPicker:GetSceneActions(targetobject, right)
    local actions = {}
    local cansee = true

    if GetPlayer().components.vision and not GetPlayer().components.vision.focused and not GetPlayer().components.vision:testsight(targetobject) then
        cansee = false
    end
    
    for k,v in pairs(targetobject.components) do        
        if v.CollectSceneActions and (cansee or v.nearsited_ok ) then
            v:CollectSceneActions(self.inst, actions, right)
        end
    end

	if targetobject.inherentsceneaction and not right then
		table.insert(actions, targetobject.inherentsceneaction)
	end

	if targetobject.inherentscenealtaction and right then
		table.insert(actions, targetobject.inherentscenealtaction)
	end

    if #actions == 0 and targetobject.components.inspectable then
        table.insert(actions, ACTIONS.WALKTO)
    end
    return self:SortActionList(actions, targetobject)
end


function PlayerActionPicker:GetUseItemActions(target, useitem, right)
    local actions = {}

    if target.CollectUseActions and target:is_a(EntityScript) then
        target:CollectUseActions(useitem, actions, right)
    else
        for k,v in pairs(useitem.components) do
            if v.CollectUseActions and target:is_a(EntityScript) then
                v:CollectUseActions(self.inst, target, actions, right)
            end
        end
    end

    return self:SortActionList(actions, target, useitem)
end

function PlayerActionPicker:GetPointActions(pos, useitem, right)
    local actions = {}
	local sorted_acts = nil
    if useitem then
		for k,v in pairs(useitem.components) do
			if v.CollectPointActions then
				v:CollectPointActions(self.inst, pos, actions, right)
			end
		end

	   sorted_acts = self:SortActionList(actions, pos, useitem)
	end

	if sorted_acts then
		for k,v in pairs(sorted_acts) do
	        if v.action == ACTIONS.DROP then
				v.options.wholestack = not TheInput:IsKeyDown(KEY_CTRL)
			end
		end
	end

    return sorted_acts
end

function PlayerActionPicker:GetPointSpecialActions(pos, useitem, right)
    return self.pointspecialactionsfn ~= nil and self:SortActionList(self.pointspecialactionsfn(self.inst, pos, useitem, right), pos) or {}
end

function PlayerActionPicker:GetEquippedItemActions(target, useitem, right)
    local actions = {}

    for k,v in pairs(useitem.components) do
        if v.CollectEquippedActions then
            v:CollectEquippedActions(self.inst, target, actions, right)
        end
    end

    return self:SortActionList(actions, target, useitem)
end


function PlayerActionPicker:GetInventoryActions(useitem, right)
    if useitem then
        local actions = {}

        for k,v in pairs(useitem.components) do
            if v.CollectInventoryActions then
                v:CollectInventoryActions(self.inst, actions, right)
            end
        end
        
        local acts = self:SortActionList(actions, nil, useitem)
        if acts ~= nil then
            for k,v in pairs(acts) do
                if v.action == ACTIONS.DROP then
                    v.options.wholestack = not TheInput:IsKeyDown(KEY_CTRL)
                end
            end
        end
        
        return acts
    end
end

function PlayerActionPicker:ShouldForceInspect()
    return TheInput:IsControlPressed(CONTROL_FORCE_INSPECT)
end

function PlayerActionPicker:ShouldForceAttack()
    return TheInput:IsControlPressed(CONTROL_FORCE_ATTACK)
end

function PlayerActionPicker:GetClickActions( target_ent, position )

    local isTargetAquatic = false 
    local isCursorWet = false 
    local isBoating = self.inst.components.driver:GetIsDriving()

    if position then
        isCursorWet = self.inst:GetIsOnWater(position.x, position.y, position.z)
    end 

    local isBoating = self.inst.components.driver:GetIsDriving()
    local interactingWithBoat = false
    
    if target_ent then 
        isTargetAquatic = target_ent:HasTag("aquatic")
    end 

    if self.leftclickoverride then
        return self.leftclickoverride(self.inst, target_ent, position)
    end

    local actions = nil
    local useitem = self.inst.components.inventory:GetActiveItem()
    local equipitem = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    local equipitemhead = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
    local boatitem = self.inst.components.driver and self.inst.components.driver.vehicle and self.inst.components.driver.vehicle.components.container and self.inst.components.driver.vehicle.components.container:GetItemInBoatSlot(BOATEQUIPSLOTS.BOAT_LAMP)

    local passable = true
    if not self.ground then
        self.ground = GetWorld()
    end

    if position and self.ground and self.ground.Map then
        local tile = self.ground.Map:GetTileAtPoint(position.x, position.y, position.z)
        passable = tile ~= GROUND.IMPASSABLE
    end

    --if we're specifically using an item, see if we can use it on the target entity
    if useitem and useitem:IsValid() then

        if target_ent == self.inst then
            actions = self:GetInventoryActions(useitem, false)
        end

		--print ("!", self:ShouldForceDrop() , target_ent == nil , useitem.components.inventoryitem , useitem.components.inventoryitem.owner == self.inst)
        if not actions then
            if target_ent and not target_ent:HasTag("OnFloor") then
                actions = self:GetUseItemActions(target_ent, useitem)
            elseif passable and position then
                actions = self:GetPointActions(position, useitem)
            end
        end
    
    elseif target_ent then

        local target = target_ent
        if target_ent.playerpickerproxy then
            target = target_ent.playerpickerproxy
        end

        --if we're clicking on a scene entity, see if we can use our equipped object on it, or just use it
        if self:ShouldForceInspect() and target.components.inspectable then
            actions = self:SortActionList({ACTIONS.LOOKAT}, target, nil)
        elseif self:ShouldForceAttack() and self.inst.components.combat:CanTarget(target) then
            actions = self:SortActionList({ACTIONS.ATTACK}, target, nil)
        end

        if not actions then
            if (equipitem and equipitem:IsValid()) and not boatitem then
                actions = self:GetEquippedItemActions(target, equipitem)
            elseif (boatitem and boatitem:IsValid()) and not equipitem then
                actions = self:GetEquippedItemActions(target, boatitem)
            elseif (equipitem and equipitem:IsValid()) and (boatitem and boatitem:IsValid()) then
                local equip_act = self:GetEquippedItemActions(target, equipitem)

                if self:ShouldForceAttack() or equip_act == nil then
                    actions = self:GetEquippedItemActions(target, boatitem)
                end

                if not actions or (not self:ShouldForceAttack() and equip_act ~= nil) then
                    actions = self:GetEquippedItemActions(target, equipitem)
                end

            elseif equipitemhead and equipitemhead:IsValid() then
                actions = self:GetEquippedItemActions(target_ent, equipitemhead)                
            end
        end

        if not actions then
            if (equipitemhead and equipitemhead:IsValid()) and not boatitem then
                actions = self:GetEquippedItemActions(target, equipitemhead)
            elseif (boatitem and boatitem:IsValid()) and not equipitemhead then
                actions = self:GetEquippedItemActions(target, boatitem)
            elseif (equipitemhead and equipitemhead:IsValid()) and (boatitem and boatitem:IsValid()) then
                local equip_act = self:GetEquippedItemActions(target, equipitemhead)

                if self:ShouldForceAttack() or equip_act == nil then
                    actions = self:GetEquippedItemActions(target, boatitem)
                end

                if not actions or (not self:ShouldForceAttack() and equip_act ~= nil) then
                    actions = self:GetEquippedItemActions(target, equipitemhead)
                end
            end
        end        

        if target.components.drivable then 
            interactingWithBoat = true 
        end 
        
        if actions == nil or #actions == 0 then
			actions = self:GetSceneActions(target)
        end
    end
    
    --Are we in a boat and hovering over land? 
    if position then
        if(isBoating and not isCursorWet and not TheInput:ControllerAttached() and (target_ent == nil or not target_ent:HasTag("aquatic"))) then 
            if not actions or #actions == 0 or (#actions > 0 and not actions[1].action.instant and not actions[1].crosseswaterboundary) then --Allow instant actions such as inspect 

                if target_ent and target_ent.components.inspectable then 
                    actions = {BufferedAction(self.inst, target_ent,ACTIONS.LOOKAT)}
                else 
                    --Find the landing position, where water meets the land
                    local landingPos = nil--position 

                    local myPos = self.inst:GetPosition()
                    local dir = (position - myPos):GetNormalized()
                    local dist = (position - myPos):Length()
                    local step = 0.25
                    local numSteps = dist/step

                    for i = 0, numSteps, 1 do 
                        local testPos = myPos + dir * step * i 
                        local testTile = GetWorld().Map:GetTileAtPoint(testPos.x , testPos.y, testPos.z) 
                        if not GetWorld().Map:IsWater(testTile) then 
                            landingPos =  myPos + dir * ((step * i)) 
                            break
                        end 
                    end 
                    if landingPos then
                        local testlanding = GetWorld().Map:GetTileAtPoint(landingPos.x , landingPos.y, landingPos.z)
                        if testlanding ~= GROUND.INVALID and testlanding ~= GROUND.IMPASSABLE then
                            landingPos.x, landingPos.y, landingPos.z = GetWorld().Map:GetTileCenterPoint(landingPos.x,0, landingPos.z)
                            local action = BufferedAction(self.inst, nil, ACTIONS.DISMOUNT, nil, landingPos)
                            actions = { action }                         
                        end
                    end
                end
            end
            
        elseif isCursorWet and not isBoating and not TheInput:ControllerAttached()  and not interactingWithBoat  and (target_ent == nil or target_ent:HasTag("aquatic")) then 
            if (not actions or #actions < 1) or (not actions[1].action.instant and not actions[1].action.crosseswaterboundary) then
                if target_ent and target_ent.components.inspectable then 
                    actions = {BufferedAction(self.inst, target_ent,ACTIONS.LOOKAT)}
                else
                    actions = nil
                end 
            end
        end
    end

    if not actions and position and not target_ent and passable then
		--can we use our equipped item at the point?
        if (equipitem and equipitem:IsValid()) and not boatitem then
            actions = self:GetPointActions(position, equipitem)
        elseif (boatitem and boatitem:IsValid()) and not equipitem then
            actions = self:GetPointActions(position, boatitem)
        elseif (equipitem and equipitem:IsValid()) and (boatitem and boatitem:IsValid()) then
            local equip_act = self:GetPointActions(position, equipitem)       

            if self:ShouldForceAttack() or equip_act == nil then
                actions = self:GetPointActions(position, boatitem)
            end

            if not actions or (not self:ShouldForceAttack() and equip_act ~= nil) then
                actions = self:GetPointActions(position, equipitem)
            end
        end
        
        --this is to make it so you don't auto-drop equipped items when you left click the ground. kinda ugly.
        if actions then
            for k,v in ipairs(actions) do
                if v.action == ACTIONS.DROP then
                    table.remove(actions, k)
                    break
                end
            end
        end

		--if we're pointing at open ground, walk
		if not actions or #actions == 0 then
		end
    end

    return actions or {}
end

function PlayerActionPicker:GetRightClickActions( target_ent, position, leftaction )
    local isTargetAquatic = false 
    local isCursorWet = false 
    local isBoating = self.inst.components.driver:GetIsDriving()

    if position then 
        isCursorWet = self.inst:GetIsOnWater(position.x, position.y, position.z)
    end

    local isBoating = self.inst.components.driver:GetIsDriving()
    local interactingWithBoat = false

    if self.rightclickoverride then
        return self.rightclickoverride(self.inst, target_ent, position)
    end

    local actions = nil
    local useitem = self.inst.components.inventory:GetActiveItem()
    local equipitem = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
    local equipitemhead = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
    local boatitem = self.inst.components.driver and self.inst.components.driver.vehicle and self.inst.components.driver.vehicle.components.container and self.inst.components.driver.vehicle.components.container:GetItemInBoatSlot(BOATEQUIPSLOTS.BOAT_LAMP)

    local passable = true
    if not self.ground then
        self.ground = GetWorld()
    end

    if position and self.ground and self.ground.Map then
        local tile = self.ground.Map:GetTileAtPoint(position.x, position.y, position.z)
        passable = tile ~= GROUND.IMPASSABLE
    end

    --if we're specifically using an item, see if we can use it on the target entity
    if useitem and useitem:IsValid() then
        if target_ent == self.inst then
            actions = self:GetInventoryActions(useitem, true)
        end

        if not actions then
            if target_ent then                
                actions = self:GetUseItemActions(target_ent, useitem, true)
            end
            if not actions and passable and position then
                actions = self:GetPointActions(position, useitem, true)
            end
        end

    elseif target_ent then
        --if we're clicking on a scene entity, see if we can use our equipped object on it, or just use it

        if (equipitem and equipitem:IsValid()) and not boatitem then            
            actions = self:GetEquippedItemActions(target_ent, equipitem, true)
        elseif (boatitem and boatitem:IsValid()) and not equipitem then
            actions = self:GetEquippedItemActions(target_ent, boatitem, true)
        elseif (equipitem and equipitem:IsValid()) and (boatitem and boatitem:IsValid()) then
            local equip_act = self:GetEquippedItemActions(target_ent, equipitem, true)

            if self:ShouldForceAttack() or equip_act == nil then
                actions = self:GetEquippedItemActions(target_ent, boatitem, true)
            end

            if not actions or (not self:ShouldForceAttack() and equip_act ~= nil) then
                actions = self:GetEquippedItemActions(target_ent, equipitem, true)
            end                   
        end       

        if not actions then
            actions = self:GetSceneActions(target_ent, true)
        end

        if target_ent.components.drivable then
            interactingWithBoat = true
        end 
    end
    
    if not actions and position and not target_ent and passable then
        --can we use our equipped item at the point?

        if (equipitem and equipitem:IsValid()) and not boatitem then
            actions = self:GetPointActions(position, equipitem, true)
        elseif (boatitem and boatitem:IsValid()) and not equipitem then
            actions = self:GetPointActions(position, boatitem, true)
        elseif (equipitem and equipitem:IsValid()) and (boatitem and boatitem:IsValid()) then
            local equip_act = self:GetPointActions(position, equipitem, true)

            if self:ShouldForceAttack() or equip_act == nil then
                actions = self:GetPointActions(position, boatitem, true)
            end

            if not actions or (not self:ShouldForceAttack() and equip_act ~= nil) then
                actions = self:GetPointActions(position, equipitem, true)
            end
        end
    end

    --this is to make it so you don't auto-drop equipped items when you click the ground. kinda ugly.
    if actions then
        for k,v in ipairs(actions) do
            if v.action == ACTIONS.DROP then
                table.remove(actions, k)
                break
            end
        end
    end

    if target_ent and (not actions or (leftaction and actions and #actions > 0 and actions[1].action == leftaction.action)) then
        -- put head item acton in right button place unless it's already the left button action.
        if equipitemhead and equipitemhead:IsValid() then
            local testactions = self:GetEquippedItemActions(target_ent, equipitemhead)       
            if testactions and #testactions > 0 and testactions[1] ~= leftaction then
                actions = testactions
            end
        end
    end


    if(isBoating and not isCursorWet and not TheInput:ControllerAttached() and (target_ent == nil or not target_ent:HasTag("aquatic"))) then 
        if not actions or #actions == 0 or (#actions > 0 and not actions[1].action.instant and not actions[1].action.crosseswaterboundary) then
                actions = nil
        end
    end

    if isCursorWet and not isBoating and not TheInput:ControllerAttached()  and not interactingWithBoat and (target_ent == nil or target_ent:HasTag("aquatic")) then 
        if not actions or #actions == 0 or (#actions > 0 and not actions[1].action.instant and not actions[1].action.crosseswaterboundary) then
            actions = nil
        end
    end

    if (actions == nil or #actions <= 0) and target_ent == nil and passable then
        actions = self:GetPointSpecialActions(position, useitem, true)
    end

    return actions or {}
end

function PlayerActionPicker:DoGetMouseActions( force_target )
    
    --local highlightdude = nil
    local action = nil
    local second_action = nil
    
    --if true then return end
    local target = TheInput:GetHUDEntityUnderMouse()
	
	if not target then        
		local ents = TheInput:GetAllEntitiesUnderMouse()
		--this should probably eventually turn into a system whereby we calculate actions for ALL of the possible items and then rank them. Until then, just apply a couple of special cases...
		local useitem = self.inst.components.inventory:GetActiveItem()
        
		--this is fugly
		local ignore_player = true
		if useitem then
			if (useitem.components.equippable and not useitem.components.equippable.isequipped )
			   or useitem.components.edible
			   or useitem.components.shaver
			   or useitem.components.instrument
			   or useitem.components.healer
			   or useitem.components.sleepingbag 
               or useitem.components.poisonhealer 
               or (useitem.components.fertilizer and GetPlayer():HasTag("healonfertilize")) then
				ignore_player = false
			end
		end 

		if self.inst.components.catcher and self.inst.components.catcher:CanCatch() then
			ignore_player = false
		end        

		for k,v in pairs(ents) do
			if not ignore_player or not v:HasTag("player") or (v.components.rider and v.components.rider:IsRiding()) and v.Transform then
				target = v
				break
			end
		end
	end
    
    local target_in_light = target and target:IsValid() and target.Transform and TheSim:GetLightAtPoint(target.Transform:GetWorldPosition()) > TUNING.DARK_CUTOFF
    local position = TheInput:GetWorldPosition()

    if ((target and target:IsValid() and target.Transform) and (target:HasTag("player") or target_in_light) ) or (not target and TheSim:GetLightAtPoint(position.x,position.y,position.z) > TUNING.DARK_CUTOFF) then
        do
            local acts = self:GetClickActions(target, position)
            if acts and #acts > 0 then
                action = acts[1]
            end
        end
        
        do
            local acts = self:GetRightClickActions(target, position, action)
            if acts[1] and (not action or acts[1].action ~= action.action) then
                second_action = acts[1]
            end
        end
    end
 
    return action, second_action
end

return PlayerActionPicker