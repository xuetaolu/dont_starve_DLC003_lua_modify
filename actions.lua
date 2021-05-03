require "class"
require "bufferedaction"


Action = Class(function(self, data, priority, instant, rmb, distance, crosseswaterboundary, overrides_direct_walk)
--Action = Class(function(self, priority, instant, rmb, distance, crosseswaterboundary) 
	self.priority = priority or 0
	self.fn = function() return false end
	self.strfn = nil
	self.testfn = nil
	self.instant = instant or false
	self.rmb = rmb or nil
	self.distance = distance or nil
	self.crosseswaterboundary = crosseswaterboundary or false
	self.mount_enabled = data.mount_enabled or false
	self.overrides_direct_walk = overrides_direct_walk
end)

ACTIONS=
{
	FIX = Action({},nil, nil, nil, 2), -- for pigs reparing broken pig town structures
	REPAIR = Action({mount_enabled=true}),
	REPAIRBOAT = Action({},nil, nil, nil, 3),
	READ = Action({mount_enabled=true}),
	READMAP = Action({mount_enabled=true}),
	DROP = Action({mount_enabled=true},-1),
	TRAVEL = Action({}, 2),
	CHOP = Action({},nil, nil, nil, 2),
	ATTACK = Action({mount_enabled=true},2, true),
	WHACK = Action({mount_enabled=true},2, true),
	FORCEATTACK = Action({mount_enabled=true},2, true),
	EAT = Action({mount_enabled=true}),
	PICK = Action({}),
	PICKUP = Action({},2),
	MINE = Action({}),
	DIG = Action({},nil, nil, true),
	GIVE = Action({mount_enabled=true}),
	COOK = Action({},2),
	DRY = Action({}),
	ADDFUEL = Action({mount_enabled=true},0.5),
	SHOP = Action({}), 	
	ADDWETFUEL = Action({mount_enabled=true}),
	LIGHT = Action({},-4),
	EXTINGUISH = Action({},0),
	LOOKAT = Action({mount_enabled=true},-3, true),
	TALKTO = Action({mount_enabled=true},3, true),
	WALKTO = Action({mount_enabled=true},-4),
	DODGE = Action({},-5, nil, nil, 2, nil, true),
	BAIT = Action({}),	
	CHECKTRAP = Action({},2),
	BUILD = Action({mount_enabled=true}),
	PLANT = Action({}),
	PLANTONGROWABLE = Action({}),
	HARVEST = Action({}), 
	GOHOME = Action({}),
	SLEEPIN = Action({}),
	EQUIP = Action({mount_enabled=true},0,true),
	UNEQUIP = Action({mount_enabled=true},-2,true),
	--OPEN_SHOP = Action(),
	SHAVE = Action({mount_enabled=true}),
	STORE = Action({}),
	RUMMAGE = Action({mount_enabled=true},1,nil,true,2),
	DEPLOY = Action({},0),
	DEPLOY_AT_RANGE = Action({},0, nil, nil, 1),
	LAUNCH = Action({},nil, nil, nil, 3, true),
	RETRIEVE = Action({},1, nil, nil, 3, true),
	PLAY = Action({mount_enabled=true}),
	NET = Action({},3),
	CATCH = Action({mount_enabled=true},3, true),
    FISHOCEAN = Action({},0, false, false, 8),	
	FISH = Action({}),
	REEL = Action({},0, true),
	POLLINATE = Action({}),
	FERTILIZE = Action({},-1),
	BUILD_ROOM = Action({}),
	DEMOLISH_ROOM = Action({}),
	BUILD_ROOM = Action({}),
	SMOTHER = Action({}),
	MANUALEXTINGUISH = Action({}),
	RANGEDSMOTHER = Action({},0, true),
	RANGEDLIGHT = Action({mount_enabled=true},-4, true),
	LAYEGG = Action({}),
	HAMMER = Action({},3, nil, nil, 2),
	TERRAFORM = Action({}),
	JUMPIN = Action({}),
	USEDOOR = Action({}),
	RESETMINE = Action({},3),
	ACTIVATE = Action({}),
	MURDER = Action({mount_enabled=true},0),
	HEAL = Action({mount_enabled=true}),
	CUREPOISON = Action({mount_enabled=true}),
	INVESTIGATE = Action({mount_enabled=true}),
	UNLOCK = Action({}),
	TEACH = Action({mount_enabled=true}),
	TURNON = Action({},2.5),
	TURNOFF = Action({},2),
	SEW = Action({mount_enabled=true}),
	STEAL = Action({}),
	USEITEM = Action({},1, true),
	TAKEITEM = Action({}),
	MAKEBALLOON = Action({mount_enabled=true}),
	CASTSPELL = Action({mount_enabled=true},-1, false, true, 20),
	BLINK = Action({mount_enabled=true},10, false, true, 36),
	PEER = Action({mount_enabled=true},0, false, true, 40, true),
	COMBINESTACK = Action({mount_enabled=true}),
	TOGGLE_DEPLOY_MODE = Action({},1, true),

	SUMMONGUARDIAN = Action({},0, false, false, 5),
	LAVASPIT = Action({},0, false, false, 2),
	HAIRBALL = Action({},0, false, false, 3),
	CATPLAYGROUND = Action({},0, false, false, 1),
	CATPLAYAIR = Action({},0, false, false, 2),
	STEALMOLEBAIT = Action({},0, false, false, .75),
	MAKEMOLEHILL = Action({},4, false, false, 0),
	MOLEPEEK = Action({},0, false, false, 1),
	BURY = Action({},0, false, false),
	FEED = Action({mount_enabled=true},0, false, true),
	FAN = Action({mount_enabled=true},0, false, true),
	UPGRADE = Action({},0, false, true),
	MOUNT = Action({},1, nil, nil, 6), 
	SEARCH = Action({},1, nil, nil, 4), --  OLD unused SW action
	DISMOUNT = Action({mount_enabled=true},1,nil, nil, 2.5),
	HACK = Action({},nil, nil, nil, 1.75),
	SHEAR = Action({},nil, nil, nil, 1.75),
	SPY = Action({mount_enabled=true},nil ,nil, nil, 2.0),
	NIBBLE = Action({},0, nil, nil, 3), 
	TOGGLEON = Action({mount_enabled=true},2), --For equipped items 
	TOGGLEOFF = Action({mount_enabled=true},2),--For equipped itmes

	STICK = Action({}),
	MATE = Action({}),
	CRAB_HIDE = Action({}),
	DRINK = Action({mount_enabled=true}), -- Don't know where this comes from
	TIGERSHARK_FEED = Action({}),
	FLUP_HIDE = Action({}),	
	PEAGAWK_TRANSFORM = Action({}),
	THROW = Action({mount_enabled=true},0, false, true, 20, true),  -- CHECK
	LAUNCH_THROWABLE = Action({},0, false, true, 20, true), -- CHECK
	DIGDUNG = Action({mount_enabled=true}),
	MOUNTDUNG = Action({}),
	STOCK = Action({}),

	SPECIAL_ACTION = Action({},nil, nil, nil, 1.2),
	SPECIAL_ACTION2 = Action({},nil, nil, nil, 1.2),
	RENOVATE = Action({}),
	DISARM = Action({},1,nil,nil,1.5),
	REARM = Action({},1,nil,nil,1.5),
	WEIGHDOWN = Action({},nil,nil,nil,1.5),
	DISLODGE = Action({}),
	BARK = Action({},nil,nil,nil, 3),
	RANSACK = Action({},nil,nil,nil, 0.5),	
	PAN = Action({},nil, nil, nil, 1),
	INFEST = Action({},nil, nil, nil, 0.5),
	GAS = Action({mount_enabled=true},nil,nil,nil, 1.5),	

	RIDE_MOUNT = Action({},1),  -- made distict from MOUNT due to the range problem of MOUNT
	BRUSH = Action({},3),
	SADDLE = Action({},1),
    UNSADDLE = Action({},3),
	BLANK = Action({}),

	BUNDLE = Action({},2, nil, true),
    BUNDLESTORE = Action({},nil, true ),
    WRAPBUNDLE = Action({},nil, true ),
    UNWRAP = Action({},2, nil, true),
    
    DRAW = Action({}),
    UNPIN = Action({}),	
    CHARGE_UP = Action({},2,true),	
}


for k,v in pairs(ACTIONS) do
	v.str = STRINGS.ACTIONS[k] or "ACTION"
	v.id = k
end

----set up the action functions!

ACTIONS.RENOVATE.fn = function(act)
	if act.target:HasTag("renovatable") then

		if act.invobject.components.renovator then
			act.invobject.components.renovator:Renovate(act.target)			
		end

		act.invobject:Remove()
		
		return true
	end
end

ACTIONS.SPECIAL_ACTION.fn = function(act)
	if act.doer.special_action then
		act.doer.special_action(act)
		return true
	end
end
ACTIONS.SPECIAL_ACTION2.fn = function(act)
	if act.doer.special_action2 then
		act.doer.special_action2(act)
		return true
	end
end

ACTIONS.DIGDUNG.fn = function(act)
	act.target.components.workable:WorkedBy(act.doer, 1)
end

ACTIONS.MOUNTDUNG.fn = function(act)
	act.doer.dung_target:Remove()
    act.doer:AddTag("hasdung") 
    act.doer.dung_target = nil
end


ACTIONS.RIDE_MOUNT.fn = function(act)
	local obj = act.target
    if obj.components.combat and obj.components.combat.target then
        return false, "TARGETINCOMBAT"
    elseif obj.components.rideable == nil
        or not obj.components.rideable.canride
        or (obj.components.health ~= nil and
            obj.components.health:IsDead())
        or (obj.components.freezable and
            obj.components.freezable:IsFrozen()) then
        return false
    elseif obj.components.rideable:IsBeingRidden() then
        return false, "INUSE"
    end
    act.doer.components.rider:Mount(act.target)
    return true
end

ACTIONS.MOUNT.strfn = function(act)
	local obj = act.target
	if obj.prefab == "surfboard" then
		return "SURF"
	end
end 

ACTIONS.MOUNT.fn = function(act)
	local obj = act.target

	if act.doer.components.driver.vehicle then --already driving 
		act.doer.components.driver:OnDismount()
	end
	 
	if act.doer.components.driver and obj.components.drivable then
		act.doer.components.driver:OnMount(obj) 
		obj.components.drivable:OnMounted(act.doer)
		return true
	end

end

ACTIONS.DISMOUNT.strfn = function(act)
	local obj = act.target
	if obj and obj.components.rider then
		return "DISMOUNT"
	end
end 

ACTIONS.DISMOUNT.fn = function(act)
    if act.doer == act.target and act.doer.components.rider and act.doer.components.rider:IsRiding() then
        act.doer.components.rider:Dismount()
        return true
    end
	if act.doer.components.driver then --and obj.components.drivable then
		act.doer.components.driver:OnDismount(false, act.pos)
		return true
	end
end

ACTIONS.SEARCH.strfn = function(act)
	local obj = act.target
	if obj.components.searchable then
		return "SEARCH"
	end
end 

ACTIONS.SEARCH.fn = function(act)
	local obj = act.target
	if act.doer.components.driver.vehicle then --already driving 
		act.doer.components.driver:OnDismount()
	end
	 
	if act.doer.components.driver and obj.components.searchable then
		act.doer.components.driver:OnSearch(obj) 
		obj.components.searchable:OnMounted(act.doer)
		return true
	end
end

ACTIONS.EAT.fn = function(act)
	local obj = act.target or act.invobject
	if act.doer.components.eater and obj and obj.components.edible then

		if obj.components.inventoryitem and  obj.bookshelf then
        	obj.components.inventoryitem:TakeOffShelf()
    	end

		return act.doer.components.eater:Eat(obj) 
	end
end

ACTIONS.STEAL.fn = function(act)
	local obj = act.target
	local attack = false
	if act.attack then attack = act.attack end    

	if (obj.components.inventoryitem and obj.components.inventoryitem:IsHeld()) then

		if obj.components.inventoryitem and obj.bookshelf then
        	obj.components.inventoryitem:TakeOffShelf()
    	end

		return act.doer.components.thief:StealItem(obj.components.inventoryitem.owner, obj, attack)
	end
end

ACTIONS.MAKEBALLOON.fn = function(act)
	if act.doer and act.invobject and act.invobject.components.balloonmaker then
		if act.doer.components.sanity then
			act.doer.components.sanity:DoDelta(-TUNING.SANITY_TINY)
		end
		local x,y,z = act.doer.Transform:GetWorldPosition()
		local angle = TheCamera.headingtarget + math.random()*10*DEGREES-5*DEGREES
		x = x + .5*math.cos(angle)
		z = z + .5*math.sin(angle)
		act.invobject.components.balloonmaker:MakeBalloon(x,y,z)
	end
	return true
end

ACTIONS.EQUIP.fn = function(act)
	if act.doer.components.inventory and act.invobject.components.equippable.equipslot then
		if act.invobject.components.inventoryitem and act.invobject.bookshelf then
        	act.invobject.components.inventoryitem:TakeOffShelf()
    	end		
		return act.doer.components.inventory:Equip(act.invobject)
	end
	--Boat equip slots 
	if act.doer.components.driver and act.doer.components.driver.vehicle and act.invobject.components.equippable.boatequipslot then 
		local vehicle = act.doer.components.driver.vehicle
		if vehicle.components.container and vehicle.components.container.hasboatequipslots then 
			if act.invobject.components.inventoryitem and act.invobject.bookshelf then
	        	act.invobject.components.inventoryitem:TakeOffShelf()
	    	end				
			vehicle.components.container:Equip(act.invobject)
		end 
	end 
end

ACTIONS.UNEQUIP.strfn = function(act)
	local targ = act.target or act.invobject
	if targ and targ:HasTag("trawlnet") then
		return "TRAWLNET"
	end
end

ACTIONS.UNEQUIP.fn = function(act)
	if act.doer.components.driver and act.doer.components.driver.vehicle and act.invobject.components.equippable.boatequipslot then 
		local vehicle = act.doer.components.driver.vehicle
		if vehicle.components.container then 
			vehicle.components.container:Unequip(act.invobject.components.equippable.boatequipslot)
			act.doer.components.inventory:GiveItem(act.invobject)
		end 
		return true
	elseif act.doer.components.inventory and act.invobject and act.invobject.components.inventoryitem.cangoincontainer then
		act.doer.components.inventory:GiveItem(act.invobject)
		--return act.doer.components.inventory:Unequip(act.invobject)
		return true
	elseif act.doer.components.inventory and act.invobject and not act.invobject.components.inventoryitem.cangoincontainer then
		act.doer.components.inventory:DropItem(act.invobject, true, true)
		return true
	end
end


ACTIONS.PICKUP.blanktarget = function(act)
	if act.target and act.target:HasTag("cost_one_oinc") and act.target.components.shelfer and not act.target.components.shelfer.shelf:HasTag("playercrafted") then
		return true
	end
	return false
end

ACTIONS.PICKUP.stroverridefn = function(act)
	if act.target and act.target:HasTag("cost_one_oinc") then

		if act.target.components.shelfer and not act.target.components.shelfer.shelf:HasTag("playercrafted") then

			local wantitem = nil --STRINGS.NAMES[string.upper(act.target.prefab)]
			if act.target.prefab == "shelf_slot" and act.target.components.shelfer:GetGift() then			
				wantitem = STRINGS.NAMES[string.upper(act.target.components.shelfer:GetGift().prefab)]
			end

			if wantitem then
				if GetPlayer().components.shopper:IsWatching(act.target) then
					local payitem = STRINGS.NAMES[string.upper("oinc")]
					local qty = "1"
					return subfmt(STRINGS.ACTIONS.SHOP_LONG, { wantitem = wantitem, qty=qty, payitem = payitem })
				else								    
					return subfmt(STRINGS.ACTIONS.SHOP_TAKE, { wantitem = wantitem })
				end
			end

		end
	end
end

ACTIONS.PICKUP.fn = function(act)
	-- this code translates the shelf_slot items into the item they contain.. and handles the shopping of it.
	if act.target and act.target.components.inventoryitem and act.target.components.shelfer then
		if not act.target.components.shelfer:GetGift() then
			print(act.doer.prefab,act.doer.GUID,"tried to grab item on shelf",act.target.prefab,act.target.GUID)
			return false
		else
			print(act.doer.prefab,act.doer.GUID,"grabbed item on shelf",act.target.prefab,act.target.GUID,act.target.components.shelfer:GetGift().prefab)
		end
		local item  = act.target.components.shelfer:GetGift()
		
		item:AddTag("cost_one_oinc")
		if not act.target.components.shelfer.shelf:HasTag("playercrafted") then
			if act.doer.components.shopper:IsWatching(item) then 
				if act.doer.components.shopper:CanPayFor(item) then 
					act.doer.components.shopper:PayFor(item)
				else 			
					return false, "CANTPAY"
				end
			else
				if act.target.components.shelfer.shelf.curse then
					act.target.components.shelfer.shelf.curse(act.target)
				end
			end
		end
		item:RemoveTag("cost_one_oinc")

		local px,py,pz = act.target.Transform:GetWorldPosition()
		act.target = act.target.components.shelfer:GiveGift()		
		if act.target and act.target.Transform then
			act.target.Transform:SetPosition(px, py, pz)
		end
	end

	if act.doer.components.inventory and act.target and act.target.components.inventoryitem and not act.target:IsInLimbo() then  
		if act.target.components.citypossession and act.target.components.citypossession.enabled and  act.target.components.citypossession.cityID then
			local world = GetWorld()
			if world.components.cityalarms then
				world.components.cityalarms:ChangeStatus(act.target.components.citypossession.cityID, true, act.doer)		
			end
			act.target.components.citypossession:Disable()	
		end

		if act.doer:HasTag("player") and act.doer.components.shopper then
			if act.doer.components.shopper:IsWatching(act.target) then 
				if act.doer.components.shopper:CanPayFor(act.target) then 
					act.doer.components.shopper:PayFor(act.target)
				else 			
					return false, "CANTPAY"
				end
			end 
		end

		act.doer:PushEvent("onpickup", {item = act.target})

		--special case for trying to carry two backpacks
		if not act.target.components.inventoryitem.cangoincontainer and act.target.components.equippable and act.doer.components.inventory:GetEquippedItem(act.target.components.equippable.equipslot) then


			local item = act.doer.components.inventory:GetEquippedItem(act.target.components.equippable.equipslot)
			if not item.components.equippable.un_unequipable then
				if item.components.inventoryitem and item.components.inventoryitem.cangoincontainer then
					
					--act.doer.components.inventory:SelectActiveItemFromEquipSlot(act.target.components.equippable.equipslot)
					act.doer.components.inventory:GiveItem(act.doer.components.inventory:Unequip(act.target.components.equippable.equipslot))
				else
					act.doer.components.inventory:DropItem(act.doer.components.inventory:GetEquippedItem(act.target.components.equippable.equipslot))
				end
			end
			
			if act.target.components.inventoryitem and  act.target.bookshelf then
	        	act.target.components.inventoryitem:TakeOffShelf()
	    	end			

			act.doer.components.inventory:Equip(act.target)
			return true
		end

		if act.doer:HasTag("player") and act.target.components.equippable and act.target.components.equippable.equipslot 
		and not act.doer.components.inventory:GetEquippedItem(act.target.components.equippable.equipslot) then

			if act.target.components.inventoryitem and  act.target.bookshelf then
	        	act.target.components.inventoryitem:TakeOffShelf()
	    	end		
			act.doer.components.inventory:Equip(act.target)
		else
		   act.doer.components.inventory:GiveItem(act.target, nil, Vector3(TheSim:GetScreenPos(act.target.Transform:GetWorldPosition())))
		end

		return true 
	end

	if act.doer.components.inventory and act.target and act.target.components.pickupable and not act.target:IsInLimbo() then

		if act.target.components.inventoryitem and  act.target.bookshelf then
        	act.target.components.inventoryitem:TakeOffShelf()
    	end

		act.doer:PushEvent("onpickup", {item = act.target})
		return act.target.components.pickupable:OnPickup(act.doer)
	end
end

ACTIONS.RETRIEVE.fn = function(act)
	if act.doer.components.inventory and act.target and act.target.components.inventoryitem and not act.target:IsInLimbo() then    
		act.doer:PushEvent("onpickup", {item = act.target})

		--special case for trying to carry two backpacks
		if not act.target.components.inventoryitem.cangoincontainer and act.target.components.equippable and act.doer.components.inventory:GetEquippedItem(act.target.components.equippable.equipslot) then
			local item = act.doer.components.inventory:GetEquippedItem(act.target.components.equippable.equipslot)
			if item.components.inventoryitem and item.components.inventoryitem.cangoincontainer then
				
				--act.doer.components.inventory:SelectActiveItemFromEquipSlot(act.target.components.equippable.equipslot)
				act.doer.components.inventory:GiveItem(act.doer.components.inventory:Unequip(act.target.components.equippable.equipslot))
			else
				act.doer.components.inventory:DropItem(act.doer.components.inventory:GetEquippedItem(act.target.components.equippable.equipslot))
			end
			act.doer.components.inventory:Equip(act.target)
			return true
		end

		if act.doer:HasTag("player") and act.target.components.equippable and act.target.components.equippable.equipslot 
		and not act.doer.components.inventory:GetEquippedItem(act.target.components.equippable.equipslot) then
			act.doer.components.inventory:Equip(act.target)
		else
		   act.doer.components.inventory:GiveItem(act.target, nil, Vector3(TheSim:GetScreenPos(act.target.Transform:GetWorldPosition())))
		end
		return true 
	end

	if act.doer.components.inventory and act.target and act.target.components.pickupable and not act.target:IsInLimbo() then    

		if act.target.components.inventoryitem and  act.target.bookshelf then
        	act.target.components.inventoryitem:TakeOffShelf()
    	end

		act.doer:PushEvent("onpickup", {item = act.target})
		return act.target.components.pickupable:OnPickup(act.doer)
	end
end

ACTIONS.FIX.fn = function(act)
	if act.target then
		local target = act.target
		local numworks = 1
		target.components.workable:WorkedBy(act.doer, numworks)
	--	return target:fix(act.doer)		
	end
end

ACTIONS.REPAIR.fn = function(act)
	if act.target and act.target.components.repairable and act.invobject and act.invobject.components.repairer then
		return act.target.components.repairable:Repair(act.doer, act.invobject)
	end
end

ACTIONS.REPAIRBOAT.fn = function(act)
	if act.target and act.target ~= act.invobject and act.target.components.repairable and act.invobject and act.invobject.components.repairer then
		return act.target.components.repairable:Repair(act.doer, act.invobject)
	elseif act.doer.components.driver and act.doer.components.driver.vehicle and act.doer.components.driver.vehicle.components.repairable and act.invobject and act.invobject.components.repairer then
		return act.doer.components.driver.vehicle.components.repairable:Repair(act.doer, act.invobject)
	end
end

ACTIONS.SEW.fn = function(act)
	if act.target and act.target.components.fueled and act.invobject and act.invobject.components.sewing then
		return act.invobject.components.sewing:DoSewing(act.target, act.doer)
	end
end

ACTIONS.DISARM.fn = function(act)
	if act.target and act.target.components.disarmable and act.invobject and act.invobject.components.disarming then

		return  act.invobject.components.disarming:DoDisarming(act.target, act.doer)
	end
end

ACTIONS.REARM.fn = function(act)
	if act.target and act.target.components.disarmable and not act.target.components.disarmable.armed and act.target.components.disarmable.rearmable then

		return  act.target.components.disarmable:DoRearming(act.target, act.doer)
	end
end

ACTIONS.WEIGHDOWN.fn = function(act)
	local pos = Vector3(act.target.Transform:GetWorldPosition())
	if act.doer.components.inventory then	
		return act.doer.components.inventory:DropItem(act.invobject, false, false, pos) 
	end
end

ACTIONS.DISLODGE.fn = function(act)
	if act.target.components.dislodgeable then
		act.target.components.dislodgeable:Dislodge(act.doer)
		-- action with inventory object already explicitly calls OnUsedAsItem
		if not act.invobject and act.doer and act.doer.components.inventory and act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
			local invobject = act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
			if invobject.components.finiteuses then
				invobject.components.finiteuses:OnUsedAsItem(ACTIONS.DISLODGE)
			end
		end
		return true
	end
end

ACTIONS.RUMMAGE.fn = function(act)
	local targ = act.target or act.invobject
	
	if act.doer.HUD and targ.components.container and ((targ.components.container.canbeopened and targ.components.container.numslots > 1) or targ.components.container.type == "boat") then
		if targ.components.container:IsOpen() then
			targ.components.container:Close(act.doer)
			act.doer:PushEvent("closecontainer", {container=targ})
		else
			act.doer:PushEvent("opencontainer", {container=targ})
			targ.components.container:Open(act.doer)
		end
		return true
	end
end

ACTIONS.RUMMAGE.strfn = function(act)
	local targ = act.target or act.invobject
	
	-- is this is a shelf
	if targ and targ.components.container and targ.components.container.isshelf then
		if targ.components.container:IsOpen() then
			return "DONE"
		else
			return "RUMMAGE"
		end
	end

	if targ and targ.components.container and targ.components.container.type == "boat" then
		if targ.components.container:IsOpen() then
			return "CLOSE"
		else
			return "INSPECT"
		end
	end
	
	if targ and targ.components.container and targ.components.container:IsOpen() then
		return "CLOSE"
	end
end

--BUNDLE STUFF
ACTIONS.BUNDLE.fn = function(act)
    local target = act.invobject or act.target
    if target ~= nil and
        act.doer ~= nil and
        act.doer.components.bundler ~= nil and
        act.doer.components.bundler:CanStartBundling() then
        --Silent fail for bundling in the dark
        if CanEntitySeeTarget(act.doer, act.doer) then
            return act.doer.components.bundler:StartBundling(target)
        end
        return true
    end
end

-- TODO: do we really need this?
ACTIONS.BUNDLESTORE.strfn = function(act)
    -- return act.target ~= nil
    --     and act.doer ~= nil
    --     and act.doer.components.constructionbuilderuidata ~= nil
    --     and (act.doer.components.constructionbuilderuidata:GetContainer() == act.target or
    --         act.doer.components.constructionbuilderuidata:GetTarget() == act.target)
    --     and "CONSTRUCT"
    --     or nil
   	return "CONSTRUCT"
end

ACTIONS.WRAPBUNDLE.fn = function(act)
    if act.doer ~= nil and
        act.doer.components.bundler ~= nil and
        act.doer.components.bundler:IsBundling(act.target) then
        if act.target.components.container ~= nil and not act.target.components.container:IsEmpty() then
            return act.doer.components.bundler:FinishBundling()
        elseif act.doer.components.talker ~= nil then
            act.doer.components.talker:Say(GetActionFailString(act.doer, "WRAPBUNDLE", "EMPTY"))
        end
        return true
    end
end

ACTIONS.UNWRAP.fn = function(act)
    local target = act.target or act.invobject
    if target ~= nil and
        target.components.unwrappable ~= nil and
        target.components.unwrappable.canbeunwrapped then
        target.components.unwrappable:Unwrap(act.doer)
        return true
    end
end

ACTIONS.DROP.fn = function(act) 
	if act.doer.components.inventory then		
		local wholestack = act.options.wholestack
		if act.invobject and act.invobject.components.stackable and act.invobject.components.stackable.forcedropsingle then
			wholestack = false	
		end
		return act.doer.components.inventory:DropItem(act.invobject, wholestack, false, act.pos) 
	end
end

ACTIONS.DROP.strfn = function(act)
	if act.invobject and act.invobject.components.trap then
		if act.invobject:GetIsOnWater(act.pos.x, act.pos.y, act.pos.z) then
			if act.invobject.components.trap.water then
				return "SETTRAP"
			end
		else
			if not act.invobject.components.trap.water then
				return "SETTRAP"
			end
		end
	elseif act.invobject and act.invobject:HasTag("mine") then
		return "SETMINE"
	elseif act.invobject and act.invobject.prefab == "pumpkin_lantern" then
		return "PLACELANTERN"
	end
end

ACTIONS.WALKTO.strfn = function(act)
	if act.doer.components.driver and act.doer.components.driver:GetIsDriving() then 
		local boat = act.doer.components.driver.vehicle
		if boat.prefab == "surfboard" then
			return "SURFTO"
		elseif boat.components.drivable then
			if boat.components.drivable:GetIsSailEquipped() then 
				return "SAILTO"
			else
				return "ROWTO"
			end
		else
			return "SWIMTO"
		end 
	end 
end

ACTIONS.LOOKAT.fn = function(act)
	local targ = act.target or act.invobject
	if targ and targ.components.inspectable then
		local desc = targ.components.inspectable:GetDescription(act.doer)
		if desc then
			act.doer.components.locomotor:Stop()

			act.doer.components.talker:Say(desc, 2.5, targ.components.inspectable.noanim)
			return true
		end
	end
end

ACTIONS.READ.testfn = function(act)
	local targ = act.target or act.invobject
	if targ and targ.components.book and act.doer and act.doer.components.reader then
		return targ.components.book:CanRead(act.doer)
	end
end

ACTIONS.READ.fn = function(act)
	local targ = act.target or act.invobject
	if targ and targ.components.book and act.doer and act.doer.components.reader then
		return act.doer.components.reader:Read(targ)
	end
end

ACTIONS.READMAP.fn = function(act)
	local targ = act.target or act.invobject
	if targ and targ.components.book and act.doer and act.doer.components.reader then
		return act.doer.components.reader:Read(targ)
	end
end

ACTIONS.TALKTO.fn = function(act)
	local targ = act.target or act.invobject
	if targ and targ.components.talkable then
		act.doer.components.locomotor:Stop()

		if act.target.components.maxwelltalker then
			if not act.target.components.maxwelltalker:IsTalking() then
				act.target:PushEvent("talkedto")
				act.target.task = act.target:StartThread(function() act.target.components.maxwelltalker:DoTalk(act.target) end)
			end
		end
		return true
	end
end

ACTIONS.BAIT.fn = function(act)
	if act.target.components.trap then
		act.target.components.trap:SetBait(act.doer.components.inventory:RemoveItem(act.invobject))
		return true
	end	
end

ACTIONS.DEPLOY.fn = function(act)
	if act.invobject and act.invobject.components.deployable and act.invobject.components.deployable:CanDeploy(act.pos, true) then
		local obj = (act.doer.components.inventory and act.doer.components.inventory:RemoveItem(act.invobject)) or 
		(act.doer.components.container and act.doer.components.container:RemoveItem(act.invobject))
		if obj then
			if obj.components.deployable:Deploy(act.pos, act.doer) then
				return true
			else
				act.doer.components.inventory:GiveItem(obj)
			end
		end
	end
end

ACTIONS.DEPLOY.strfn = function(act)
	if act.invobject and act.invobject:HasTag("groundtile") then
	return "GROUNDTILE"
	elseif act.invobject and act.invobject:HasTag("wallbuilder") then
		return "WALL"
	elseif act.invobject and act.invobject:HasTag("eyeturret") then
		return "TURRET"
	elseif act.invobject and act.invobject:HasTag("boat") then
		return "PLACE"
	end
end

ACTIONS.DEPLOY_AT_RANGE.fn = ACTIONS.DEPLOY.fn 


ACTIONS.DEPLOY_AT_RANGE.strfn = ACTIONS.DEPLOY.strfn


ACTIONS.TOGGLE_DEPLOY_MODE.strfn = function(act)
	if act.invobject and act.invobject:HasTag("groundtile") then
		return "GROUNDTILE"
	elseif act.invobject and act.invobject:HasTag("wallbuilder") then
		return "WALL"
	elseif act.invobject and act.invobject:HasTag("eyeturret") then
		return "TURRET"
	elseif act.invobject and act.invobject:HasTag("boat") then
		return "PLACE"
	end
end

ACTIONS.LAUNCH.fn = function(act)
	if act.invobject and act.invobject.components.deployable and act.invobject.components.deployable:CanDeploy(act.pos) then
		local obj = (act.doer.components.inventory and act.doer.components.inventory:RemoveItem(act.invobject)) or 
		(act.doer.components.container and act.doer.components.container:RemoveItem(act.invobject))
		if obj then
			if obj.components.deployable:Deploy(act.pos, act.doer) then
				return true
			else
				act.doer.components.inventory:GiveItem(obj)
			end
		end
	end
end

ACTIONS.CHECKTRAP.fn = function(act)
	if act.target.components.trap then
		act.target.components.trap:Harvest(act.doer)
		return true
	end
end

ACTIONS.CHOP.fn = function(act)
	if act.target.components.workable and act.target.components.workable.action == ACTIONS.CHOP then
		local numworks = 1

		if act.invobject and act.invobject.components.tool then
			numworks = act.invobject.components.tool:GetEffectiveness(ACTIONS.CHOP)
		elseif act.doer and act.doer.components.worker then
			numworks = act.doer.components.worker:GetEffectiveness(ACTIONS.CHOP)
		end
		if act.invobject and act.invobject.components.obsidiantool then
			act.invobject.components.obsidiantool:Use(act.doer, act.target)
		end
		act.target.components.workable:WorkedBy(act.doer, numworks)

		if act.target.components.citypossession and act.target.components.citypossession.enabled then
			local world = GetWorld()
			if world.components.cityalarms then
				world.components.cityalarms:ChangeStatus(act.target.components.citypossession.cityID,true, act.doer)			
			end
		end			
	end

	return true
end

ACTIONS.FERTILIZE.fn = function(act)
--[[
	dumptable(act,1,1,1)	
	if act.target then
		print("TARGET",act.target.prefab)
	else
		print("NO TARGET")
	end	
	print("DOER healonfertilize",act.doer:HasTag("healonfertilize"))
	if act.invobject then
		print("INV OBJ",act.invobject.prefab)
	else
		print("NO INV OBJ")
	end
	]]
	if not act.target and act.doer:HasTag("healonfertilize") and act.invobject then

		if  act.doer.components.health then
		    act.doer.components.health:DoDelta(2,false,"fertilize")
		    
		    if act.invobject.components.stackable and act.invobject.components.stackable.stacksize > 1 then
		        act.invobject.components.stackable:Get():Remove()
		    else
		    	if act.invobject.components.finiteuses then
		    		act.invobject.components.finiteuses:Use(2)
		    	else
		        	act.invobject:Remove()
		    	end
		    end
		    
		    return true
		end

	elseif act.invobject and act.invobject.components.fertilizer then
		if act.target and act.target.components.crop and not act.target.components.crop:IsReadyForHarvest() and not act.target.components.crop:IsWithered() then
			local obj = act.invobject

			if act.target.components.crop:Fertilize(obj) then
				return true
			else
				return false
			end
		elseif act.target.components.grower and act.target.components.grower:IsEmpty() then
			local obj = act.invobject
			act.target.components.grower:Fertilize(obj)
			return true
		elseif act.target.components.pickable and act.target.components.pickable:CanBeFertilized() then

			if act.target.components.pickable and act.target.components.pickable.pickydirt then
				local pt = Vector3(act.target.Transform:GetWorldPosition())
				local tile = GetWorld().Map:GetTileAtPoint(pt.x, pt.y, pt.z)
				local okdirt = false
				for i,tiletype in ipairs(act.target.components.pickable.pickydirt)do
					if tile == tiletype then
						okdirt = true
					end
				end
				if not okdirt then
					return false, "WRONGDIRT"
				end
			end

			local obj = act.invobject
			act.target.components.pickable:Fertilize(obj)
			return true		
		elseif act.target.components.hackable and act.target.components.hackable:CanBeFertilized() then
			local obj = act.invobject
			act.target.components.hackable:Fertilize(obj)
			return true     
		end
	end
end

ACTIONS.BUILD_ROOM.fn = function(act)
	if act.invobject.components.roombuilder and act.target:HasTag("predoor") then
		
		local interior_spawner = GetInteriorSpawner()
		local current_interior = interior_spawner.current_interior

		local function CreateNewRoom(dir)
			local name = current_interior.dungeon_name
			local ID = interior_spawner:GetNewID()
			ID = "p" .. ID -- Added the "p" so it doesn't trigger FixDoors on the InteriorSpawner

            local floortexture = "levels/textures/noise_woodfloor.tex"
            local walltexture = "levels/textures/interiors/shop_wall_woodwall.tex"
            local minimaptexture = "levels/textures/map_interior/mini_ruins_slab.tex"
            local colorcube = "images/colour_cubes/pigshop_interior_cc.tex"

            local addprops = {
                { name = "deco_roomglow", x_offset = 0, z_offset = 0 }, 

                { name = "deco_antiquities_cornerbeam",  x_offset = -5, z_offset =  -15/2, rotation = 90, flip=true, addtags={"playercrafted"} },
                { name = "deco_antiquities_cornerbeam",  x_offset = -5, z_offset =   15/2, rotation = 90,            addtags={"playercrafted"} },      
                { name = "deco_antiquities_cornerbeam2", x_offset = 4.7, z_offset = -15/2, rotation = 90, flip=true, addtags={"playercrafted"} },
                { name = "deco_antiquities_cornerbeam2", x_offset = 4.7, z_offset =  15/2, rotation = 90,            addtags={"playercrafted"} },  

                { name = "swinging_light_rope_1", x_offset = -2, z_offset =  0, rotation = -90,                      addtags={"playercrafted"} },
            }

            local room_exits = {}
			
            local width = 15
            local depth = 10

			room_exits[player_interior_exit_dir_data[dir].opposing_exit_dir] = {
				target_room = current_interior.unique_name,
				bank =  "player_house_doors",
				build = "player_house_doors",
				room = ID,
				prefab_name = act.target.prefab,
				house_door = true,
			}

			-- Adds the player room def to the interior_spawner so we can find the adjacent rooms
			interior_spawner:AddPlayerRoom(name, ID, current_interior.unique_name, dir)
			
			local doors_to_activate = {}
			-- Finds all the rooms surrounding the newly built room
			local surrounding_rooms = interior_spawner:GetSurroundingPlayerRooms(name, ID, player_interior_exit_dir_data[dir].op_dir)

			if next(surrounding_rooms) ~= nil then
				-- Goes through all the adjacent rooms, checks if they have a pre built door and adds them to doors_to_activate
				for direction, room_id in pairs(surrounding_rooms) do
					local found_room = interior_spawner:GetInteriorByName(room_id)

					if found_room.visited then
						for _, obj in pairs(found_room.object_list) do

							local op_dir = player_interior_exit_dir_data[direction] and player_interior_exit_dir_data[direction].op_dir
							if obj:HasTag("predoor") and obj.baseanimname and obj.baseanimname == op_dir then
								room_exits[player_interior_exit_dir_data[op_dir].opposing_exit_dir] = {
									target_room = found_room.unique_name,
									bank =  "player_house_doors",
									build = "player_house_doors",
									room = ID,
									prefab_name = obj.prefab,
									house_door = true,
								}

								doors_to_activate[obj] = found_room
							end
						end
					end
				end
			end

			-- Actually creates the room
            interior_spawner:CreateRoom("generic_interior", width, nil, depth, name, ID, addprops, room_exits, walltexture, floortexture, minimaptexture, nil, colorcube, nil, true, "inside", "HOUSE","WOOD")

            -- Activates all the doors in the adjacent rooms
            for door_to_activate, found_room in pairs(doors_to_activate) do
            	print ("################## ACTIVATING FOUND DOOR")
            	door_to_activate.ActivateSelf(door_to_activate, ID, found_room)
            end

            -- If there are already built doors in the same direction as the door being used to build, activate them
            local pt = interior_spawner:getSpawnOrigin()
            local other_doors = TheSim:FindEntities(pt.x, pt.y, pt.z, 50, {"predoor"}, {"INTERIOR_LIMBO", "INLIMBO"})
            for _, other_door in ipairs(other_doors) do
            	if other_door ~= act.target and other_door.baseanimname and other_door.baseanimname == act.target.baseanimname then
            		print ("############### ACTIVATING DOOR")
            		other_door.ActivateSelf(other_door, ID, current_interior)
            	end
            end

			act.target.components.door:checkDisableDoor(false, "house_prop")
			
	        local door_def =
	        {
	        	my_interior_name = current_interior.unique_name,
	        	my_door_id = current_interior.unique_name .. player_interior_exit_dir_data[dir].my_door_id_dir,
	        	target_interior = ID,
	        	target_door_id = ID .. player_interior_exit_dir_data[dir].target_door_id_dir
	    	}

	        interior_spawner:AddDoor(act.target, door_def)
	        act.target.InitHouseDoor(act.target, dir)
        end

		local dir = GetInteriorSpawner():GetExitDirection(act.target)
        CreateNewRoom(dir)

        act.target:AddTag("interior_door")
		act.target:RemoveTag("predoor")
		act.invobject:Remove()
		return true
	end

	return false
end

ACTIONS.DEMOLISH_ROOM.fn = function(act)
	if act.invobject.components.roomdemolisher and act.target:HasTag("house_door") and act.target:HasTag("interior_door") then
		

		local interior_spawner = GetInteriorSpawner()
		local target_interior = interior_spawner:GetInteriorByName(act.target.components.door.target_interior)
		local index_x, index_y = interior_spawner:GetPlayerRoomIndex(target_interior.dungeon_name, target_interior.unique_name)
		
		-- inst.doorcanberemoved
		-- inst.roomcanberemoved

		if act.target.doorcanberemoved and act.target.roomcanberemoved and not (index_x == 0 and index_y == 0) then
			local total_loot = {}

			if target_interior.visited then
				for _, object in pairs(target_interior.object_list) do
				 	if object.components.inventoryitem then
				 		
				 		object:ReturnToScene()
				 		object.components.inventoryitem:ClearOwner()
					    object.components.inventoryitem:WakeLivingItem()
					    object:RemoveTag("INTERIOR_LIMBO")

				 		table.insert(total_loot, object)

				 	else
					 	if object.components.container then
					 		local container_objs = object.components.container:RemoveAllItems()
					 		for i,obj in ipairs(container_objs) do
					 			table.insert(total_loot, obj)
					 		end
					 	end

					 	if object.components.lootdropper then
					 		local smash_loot = object.components.lootdropper:GenerateLoot()
					 		for i,obj in ipairs(smash_loot) do
					 			table.insert(total_loot, SpawnPrefab(obj))
					 		end
					 	end
				 	end
				end

				-- Removes the found loot from the interior so it doesn't get deleted by the next for
				for _, loot in ipairs(total_loot) do
					print ("Removing ", loot.prefab)
					interior_spawner:removeprefab(loot, target_interior.unique_name)
				end

				-- Deletes all of the interior with a reverse for
				local obj_count = #target_interior.object_list
				for i = obj_count, 1, -1 do

					local current_obj = target_interior.object_list[i]
					if current_obj and current_obj.prefab ~= "generic_wall_back" and current_obj.prefab ~= "generic_wall_side" then
						
						if current_obj:HasTag("house_door") then
							local connected_door = interior_spawner:GetDoorInst(current_obj.components.door.target_door_id)
							if connected_door and connected_door ~= act.target then
								connected_door.DeactivateSelf(connected_door)
							end
						end

						current_obj:Remove()
					end
				end
			else
				table.insert(total_loot, SpawnPrefab("oinc"))
				if act.target.components.lootdropper then
					local smash_loot = act.target.components.lootdropper:GenerateLoot()
					for i,obj in ipairs(smash_loot) do
			 			table.insert(total_loot, SpawnPrefab(obj))
			 		end
				end
			end

			for _, loot in ipairs(total_loot) do
				local pos = Vector3(act.target.Transform:GetWorldPosition())
				loot.Transform:SetPosition(pos:Get())
				if loot.components.inventoryitem then
					loot.components.inventoryitem:OnDropped(true)
				end
			end

			act.target:DeactivateSelf(act.target)
			interior_spawner:RemoveInterior(target_interior.unique_name)
			interior_spawner:RemovePlayerRoom(target_interior.dungeon_name, target_interior.unique_name)

			SpawnPrefab("collapse_small").Transform:SetPosition(act.target.Transform:GetWorldPosition())
		    if act.target.SoundEmitter then
		        act.target.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
		    end

			GetWorld():PushEvent("roomremoved")
			act.invobject:Remove()

		else
			GetPlayer().components.talker:Say(GetString(GetPlayer().prefab, "ANNOUNCE_ROOM_STUCK"))
		end

		return true
	end
end

ACTIONS.SMOTHER.fn = function(act)
	if act.target.components.burnable and act.target.components.burnable:IsSmoldering() then
		local smotherer = act.invobject or act.doer
		act.target.components.burnable:SmotherSmolder(smotherer)
		return true
	end
end

ACTIONS.MANUALEXTINGUISH.fn = function(act)
	if act.doer:HasTag("extinguisher") then
		if act.target.components.burnable and act.target.components.burnable:IsBurning() then
			act.target.components.burnable:Extinguish()
			return true
		end
	elseif act.target.components.sentientball then
		act.target.components.burnable:Extinguish()
		-- damage player?
		return true
	elseif act.invobject:HasTag("frozen") and act.target.components.burnable and act.target.components.burnable:IsBurning() then
		act.target.components.burnable:Extinguish(true, TUNING.SMOTHERER_EXTINGUISH_HEAT_PERCENT, act.invobject)
		return true
	end
end

ACTIONS.RANGEDSMOTHER.fn = function(act)
	if act.target.components.burnable and 
		(act.target.components.burnable:IsSmoldering() or act.target.components.burnable:IsBurning()) then

		act.doer.components.combat:SetTarget(act.target)
		return true
	end
end

ACTIONS.RANGEDLIGHT.fn = function(act)
	if act.target.components.burnable and not act.target.components.burnable:IsBurning() and not act.target:HasTag("burnt") then
		act.doer.components.combat:SetTarget(act.target)
		return true
	end
end

ACTIONS.MINE.fn = function(act)
	if act.target.components.workable and act.target.components.workable.action == ACTIONS.MINE then
		local numworks = 1

		if act.invobject and act.invobject.components.tool then
			numworks = act.invobject.components.tool:GetEffectiveness(ACTIONS.MINE)
		elseif act.doer and act.doer.components.worker then
			numworks = act.doer.components.worker:GetEffectiveness(ACTIONS.MINE)
		end
		if act.invobject and act.invobject.components.obsidiantool then
			act.invobject.components.obsidiantool:Use(act.doer, act.target)
		end
		act.target.components.workable:WorkedBy(act.doer, numworks)

		if act.target.components.citypossession and act.target.components.citypossession.enabled and act.target.components.workable.workleft < 1 then
			local world = GetWorld()
			if world.components.cityalarms then
				world.components.cityalarms:ChangeStatus(act.target.components.citypossession.cityID,true, act.doer)			
			end
		end		
	end
	return true
end

ACTIONS.HAMMER.fn = function(act)
	if act.target.components.workable and act.target.components.workable.action == ACTIONS.HAMMER then
		local numworks = 1

		if act.invobject and act.invobject.components.tool then
			numworks = act.invobject.components.tool:GetEffectiveness(ACTIONS.HAMMER)
		elseif act.doer and act.doer.components.worker then
			numworks = act.doer.components.worker:GetEffectiveness(ACTIONS.HAMMER)
		end
		if act.invobject and act.invobject.components.obsidiantool then
			act.invobject.components.obsidiantool:Use(act.doer, act.target)
		end
		act.target.components.workable:WorkedBy(act.doer, numworks)


		if act.target.components.citypossession and act.target.components.citypossession.enabled and act.target.components.workable.workleft < 1 then
			local world = GetWorld()
			if world.components.cityalarms then
				world.components.cityalarms:ChangeStatus(act.target.components.citypossession.cityID,true, act.doer)			
			end
		end
	end
	return true
end

ACTIONS.NET.fn = function(act)
	if act.target.components.workable and act.target.components.workable.action == ACTIONS.NET then
		act.target.components.workable:WorkedBy(act.doer)
	end
	return true
end

ACTIONS.CATCH.fn = function(act)
	if act.doer.components.catcher then
		act.doer.components.catcher:PrepareToCatch()
	elseif act.target.components.catcher then
		act.target.components.catcher:PrepareToCatch()
	end
	return true
end

ACTIONS.FISHOCEAN.fn = function(act)
    local fishingrod = act.invobject.components.fishingrod
    if fishingrod then
        fishingrod:StartFishing(act.target, act.doer)
    end
    return true
end

ACTIONS.FISH.fn = function(act)
	local fishingrod = (act.invobject and act.invobject.components.fishingrod) or (act.doer and act.doer.components.fishingrod)
	if fishingrod then
		fishingrod:StartFishing(act.target, act.doer)
	end
	return true
end

ACTIONS.FISH.strfn = function(act)
	if act.target and (act.target.components.workable or act.target.components.sinkable) then
		return "RETRIEVE"
	end
end

ACTIONS.REEL.fn = function(act)
	local fishingrod = act.invobject.components.fishingrod
	if fishingrod and fishingrod:IsFishing() then
		if fishingrod:HasHookedFish() then
			fishingrod:Reel()
		elseif fishingrod:FishIsBiting() then
			fishingrod:Hook()
		else
			fishingrod:StopFishing()
		end
	end
	return true
end

ACTIONS.REEL.strfn = function(act)
	local fishingrod = act.invobject.components.fishingrod
	if fishingrod and fishingrod:IsFishing() then
		if fishingrod:HasHookedFish() then
			return "REEL"
		elseif fishingrod:FishIsBiting() then
			return "HOOK"
		else
			return "CANCEL"
		end
	end
end

ACTIONS.DIG.fn = function(act)
	if act.target.components.workable and act.target.components.workable.action == ACTIONS.DIG then
		local numworks = 1

		if act.invobject and act.invobject.components.tool then
			numworks = act.invobject.components.tool:GetEffectiveness(ACTIONS.DIG)
		elseif act.doer and act.doer.components.worker then
			numworks = act.doer.components.worker:GetEffectiveness(ACTIONS.DIG)
		end
		if act.invobject and act.invobject.components.obsidiantool then
			act.invobject.components.obsidiantool:Use(act.doer, act.target)
		end
		act.target.components.workable:WorkedBy(act.doer, numworks)

		if act.target.components.citypossession and act.target.components.citypossession.enabled and act.target.components.citypossession.cityID then
			local world = GetWorld()
			if world.components.cityalarms then
				world.components.cityalarms:ChangeStatus(act.target.components.citypossession.cityID,true, act.doer)		
			end
			--act.target.components.citypossession:Disable()	
		end		
	end
	return true
end

ACTIONS.PICK.strfn = function(act)
	local obj = act.target
	if obj:HasTag("pick_digin") then
		return "DIGIN"
	end
	if obj:HasTag("flippable") then
		return "FLIP"
	end
end

ACTIONS.PICK.fn = function(act)
	if act.target.components.pickable then
		act.target.components.pickable:Pick(act.doer)


		if act.target.components.citypossession and act.target.components.citypossession.enabled and act.target.components.citypossession.cityID then
			local world = GetWorld()
			if world.components.cityalarms then
				world.components.cityalarms:ChangeStatus(act.target.components.citypossession.cityID,true, act.doer)		
			end
			--act.target.components.citypossession:Disable()	
		end

		return true
	end
end

ACTIONS.FORCEATTACK.fn = function(act)
	act.doer.components.combat:SetTarget(act.target) 
	act.doer.components.combat:ForceAttack()
	return true
end

ACTIONS.ATTACK.fn = function(act)
	if act.target.components.combat then
		act.doer.components.combat:SetTarget(act.target)
		--act.doer.components.combat:TryAttack()
		return true
	end
end

ACTIONS.WHACK.fn = function(act)
	if act.target.components.combat then
		act.doer.components.combat:SetTarget(act.target)
		--act.doer.components.combat:TryAttack()
		return true
	end
end

ACTIONS.ATTACK.strfn = function(act)
	local targ = act.target or act.invobject
	
	if targ and targ:HasTag("smashable") then
		return "SMASHABLE"
	end
end

ACTIONS.COOK.strfn = function(act)
	local obj = act.target
	if obj.components.melter then
		return "SMELT"
	end
end 

ACTIONS.COOK.fn = function(act)
	if act.target.components.cooker then
		local ingredient = act.doer.components.inventory:RemoveItem(act.invobject)
		
		if ingredient.components.health and ingredient.components.combat then
			act.doer:PushEvent("killed", {victim = ingredient})
		end
		
		local product = act.target.components.cooker:CookItem(ingredient, act.doer)
		if product then
			act.doer.components.inventory:GiveItem(product,nil, Vector3(TheSim:GetScreenPos(act.target.Transform:GetWorldPosition()) ))
			return true
		end
	elseif act.target.components.melter then
		act.target.components.melter:StartCooking()
		return true
	elseif act.target.components.stewer then
		act.target.components.stewer:StartCooking()
		return true
	end
end

ACTIONS.DRY.fn = function(act)
	if act.target.components.dryer then
		local ingredient = act.doer.components.inventory:RemoveItem(act.invobject)
		
		if not act.target.components.dryer:StartDrying(ingredient) then
			act.doer.components.inventory:GiveItem(ingredient,nil, Vector3(TheSim:GetScreenPos(act.target.Transform:GetWorldPosition()) ))
			return false
		end
		return true
	end
end

ACTIONS.ADDFUEL.fn = function(act)
	if act.doer.components.inventory then
		local fuel = act.doer.components.inventory:RemoveItem(act.invobject)
		if fuel then
			if act.target.components.fueled:TakeFuelItem(fuel) then
				return true
			else
				print("False")
				act.doer.components.inventory:GiveItem(fuel)
			end
		end
	end
end

ACTIONS.SHOP.stroverridefn = function(act)
	if not act.target or not act.target.costprefab or not act.target.components.shopdispenser:GetItem() then
		return nil
	else

		local blueprint = false

		local item = act.target.components.shopdispenser:GetItem()
		local blueprintstart= string.find(item,"_blueprint")
		if blueprintstart then
			item = string.sub(item,1,blueprintstart-1)
			blueprint = true
		end

		local wantitem = STRINGS.NAMES[string.upper(item)]
		if blueprint then
			wantitem = string.format(STRINGS.BLUEPRINT_ITEM,wantitem)
		end
		if not wantitem then
			local temp = SpawnPrefab(item)
			if temp.displaynamefn then
				wantitem = temp.displaynamefn(temp)
			else
				wantitem = item
			end
			temp:Remove()
		end
		local payitem = STRINGS.NAMES[string.upper(act.target.costprefab)]
		local qty = ""
		if act.target.costprefab == "oinc" then		
			qty = act.target.cost		
			if act.target.cost > 1 then
				payitem = STRINGS.NAMES.OINC_PL
			end
		end

		if act.doer.components.shopper:IsWatching(act.target) then		
			return subfmt(STRINGS.ACTIONS.SHOP_LONG, { wantitem = wantitem, qty=qty, payitem = payitem })
		else
			return subfmt(STRINGS.ACTIONS.SHOP_TAKE, { wantitem = wantitem })
		end
	end
end 

ACTIONS.SHOP.fn = function(act)
	if act.doer.components.inventory then
		if act.doer:HasTag("player") and act.doer.components.shopper then 

			if act.doer.components.shopper:IsWatching(act.target) then 

				local sell = true
				local reason = nil

				if act.target:HasTag("shopclosed") or GetClock():IsNight() then
					reason = "closed"
					sell = false
				elseif not act.doer.components.shopper:CanPayFor(act.target) then 
					local prefab_wanted = act.target.costprefab
					if prefab_wanted == "oinc" then
						reason = "money"
					else
						reason = "goods"
					end
					sell = false
				end
				
				if sell then
					act.doer.components.shopper:PayFor(act.target)

					if act.target and act.target.shopkeeper_speech then
						act.target.shopkeeper_speech(act.target,STRINGS.CITY_PIG_SHOPKEEPER_SALE[math.random(1,#STRINGS.CITY_PIG_SHOPKEEPER_SALE)])
					end

					return true 
				else 
					if reason == "money" then
						if act.target and act.target.shopkeeper_speech then
							act.target.shopkeeper_speech(act.target,STRINGS.CITY_PIG_SHOPKEEPER_NOT_ENOUGH[math.random(1,#STRINGS.CITY_PIG_SHOPKEEPER_NOT_ENOUGH)])
						end
					elseif reason == "goods" then
						if act.target and act.target.shopkeeper_speech then
							act.target.shopkeeper_speech(act.target,STRINGS.CITY_PIG_SHOPKEEPER_DONT_HAVE[math.random(1,#STRINGS.CITY_PIG_SHOPKEEPER_DONT_HAVE)])
						end						
					elseif reason == "closed" then
						if act.target and act.target.shopkeeper_speech then
							act.target.shopkeeper_speech(act.target,STRINGS.CITY_PIG_SHOPKEEPER_CLOSING[math.random(1,#STRINGS.CITY_PIG_SHOPKEEPER_CLOSING)])
						end						
					end
					return true
				end		
			else
				act.doer.components.shopper:Take(act.target)
				-- THIS IS WHAT HAPPENS IF ISWATCHING IS FALSE
				return true 
			end 
		end
	end
end

ACTIONS.ADDWETFUEL.fn = function(act)
	if act.doer.components.inventory then
		local fuel = act.doer.components.inventory:RemoveItem(act.invobject)
		if fuel then
			if act.target.components.fueled:TakeFuelItem(fuel) then
				return true
			else
				print("False")
				act.doer.components.inventory:GiveItem(fuel)
			end
		end
	end
end

ACTIONS.GIVE.fn = function(act)
	print("TEST 1")
	if act.invobject.components.tradable then
		print("TEST 2")
		if act.target.components.trader then
			act.target.components.trader:AcceptGift(act.doer, act.invobject)
			return true
		end
	end
	if act.invobject.components.inventoryitem then
		print("TEST 3")
		if act.target.components.shelfer then
			act.target.components.shelfer:AcceptGift(act.doer, act.invobject)
			return true
		end
	end 	
	if act.invobject.components.appeasement then
		print("TEST 4")
		if act.target.components.appeasable then
			act.target.components.appeasable:AcceptGift(act.doer, act.invobject)
			return true
		end 
	end 
	if act.invobject.components.currency then
		print("TEST 5")
		if act.target.components.payable then
			act.target.components.payable:AcceptCurrency(act.doer, act.invobject)
			return true
		end 
	end 
end

ACTIONS.GIVE.strfn = function(act)
	local targ = act.target or act.invobject
	
	if targ.prefab == "doydoynest" or targ.components.shelfer then
		return "PLACE"
	end
	if targ and targ:HasTag("altar") then
		if targ.enabled then
			return "READY"
		else
			return "NOTREADY"
		end
	end
	if targ.components.payable and act.invobject.components.currency then 
		return "CURRENCY"
	end
	if targ.components.weapon then
		return "LOAD"
	end
end

ACTIONS.STORE.fn = function(act)
	if act.target.components.container and act.invobject.components.inventoryitem and act.doer.components.inventory then
		
		if not act.target.components.container:CanTakeItemInSlot(act.invobject) then
			return false, "NOTALLOWED"
		end

		local item = act.invobject.components.inventoryitem:RemoveFromOwner(act.target.components.container.acceptsstacks)
		if item then
			if not act.target.components.inventoryitem then
				act.target.components.container:Open(act.doer)
			end
			
			if not act.target.components.container:GiveItem(item,nil,nil,false) then
				if TheInput:ControllerAttached() then
					act.doer.components.inventory:GiveItem(item)
				else
					act.doer.components.inventory:GiveActiveItem(item)
				end
				return false
			end
			return true            
		end
	elseif act.target.components.occupiable and act.invobject and act.invobject.components.occupier and act.target.components.occupiable:CanOccupy(act.invobject) then
		local item = act.invobject.components.inventoryitem:RemoveFromOwner()
		act.target.components.occupiable:Occupy(item)
		return true
	end
end

ACTIONS.BUNDLESTORE.fn = ACTIONS.STORE.fn

ACTIONS.STORE.strfn = function(act)
	if act.target and act.target.components.stewer then
		return "COOK"
	elseif act.target and act.target.components.occupiable then
		return "IMPRISON"
	end
end


ACTIONS.BUILD.fn = function(act)
	if act.doer.components.rider and act.doer.components.rider:IsRiding() then
		return false, "MOUNTED"
	else
		if act.doer.components.builder then
			if act.doer.components.builder:DoBuild(act.recipe, act.pos, act.rotation, act.modifydata) then
				return true
			end
		end
	end
end


ACTIONS.PLANT.strfn = function(act)
	if act.target.components.breeder then 
		return "STOCK"
	end
	return nil
end

ACTIONS.PLANT.fn = function(act)
	if act.doer.components.inventory then
		local seed = act.doer.components.inventory:RemoveItem(act.invobject)
		if seed then		    
			if act.target.components.grower and act.target.components.grower:PlantItem(seed) then

				if act.doer:HasTag("plantkin") then
			        if act.doer.growplantfn then
			            act.doer.growplantfn(act.doer)
			        end
			    end 

				return true
			elseif act.target.components.breeder and act.target.components.breeder:Seed(seed) then
				return true
			else
				act.doer.components.inventory:GiveItem(seed)
			end
		end
   end
end

ACTIONS.PLANTONGROWABLE.fn = function(act)
	if act.doer.components.inventory then
		local seed = act.doer.components.inventory:RemoveItem(act.invobject)
		if seed then
			if act.target.components.growable then
				act.target.components.growable:SetStagePlanted()
				return true
			else
				act.doer.components.inventory:GiveItem(seed)
			end
		end
   end
end

ACTIONS.HARVEST.fn = function(act)

	if act.target.components.citypossession and act.target.components.citypossession.enabled and  act.target.components.citypossession.cityID then
		local world = GetWorld()
		if world.components.cityalarms then
			world.components.cityalarms:ChangeStatus(act.target.components.citypossession.cityID, true, act.doer)		
		end
		--act.target.components.citypossession:Disable()	
	end

	if act.target.components.breeder then
		return act.target.components.breeder:Harvest(act.doer)
	elseif act.target.components.crop then
		return act.target.components.crop:Harvest(act.doer)
	elseif act.target.components.harvestable then
		return act.target.components.harvestable:Harvest(act.doer)
    elseif act.target.components.melter then
        return act.target.components.melter:Harvest(act.doer)		
	elseif act.target.components.stewer then
		return act.target.components.stewer:Harvest(act.doer)
	elseif act.target.components.dryer then
		return act.target.components.dryer:Harvest(act.doer)
	elseif act.target.components.occupiable and act.target.components.occupiable:IsOccupied() then
		local item =act.target.components.occupiable:Harvest(act.doer)
		if item then
			act.doer.components.inventory:GiveItem(item)
			return true
		end
	end
end

ACTIONS.HARVEST.strfn = function(act)
	if act.target and act.target.components.occupiable then
		return "FREE"
	end
	if act.target and act.target.components.crop and act.target.components.crop:IsWithered() then
		return "WITHERED"
	end
end


ACTIONS.LIGHT.fn = function(act)
	if act.invobject and act.invobject.components.lighter then
		act.invobject.components.lighter:Light(act.target)
		if act.target and act.target.components.citypossession and act.target.components.citypossession.enabled then
			local world = GetWorld()
			if world.components.cityalarms then
				world.components.cityalarms:ChangeStatus(act.target.components.citypossession.cityID,true, act.doer)
			end
		end

		return true
	end
end

ACTIONS.SLEEPIN.fn = function(act)

	local bag = nil
	if act.target and act.target.components.sleepingbag then bag = act.target end
	if act.invobject and act.invobject.components.sleepingbag then bag = act.invobject end
	
	if bag and act.doer then
		bag.components.sleepingbag:DoSleep(act.doer)
		return true
	end
	
--		TheFrontEnd:Fade(true,2)
--		act.target.components.sleepingbag:DoSleep(act.doer)
--	elseif act.doer and act.invobject and act.invobject.components.sleepingbag then
--		return true
	--end
end

ACTIONS.SHAVE.testfn = function(act)
	if act.doer and not  act.doer.components.rider or not  act.doer.components.rider:IsRiding() then
		if act.invobject and act.invobject.components.shaver then
			local shavee = act.target or act.doer
			if shavee and shavee.components.beard then
				return shavee.components.beard:ShouldTryToShave(act.doer, act.invobject)
			end
			if shavee and shavee.shaveable then
				return true
			end
		end
	else
		return false,"RIDING"
	end
end

ACTIONS.SHAVE.fn = function(act)
	
	if act.invobject and act.invobject.components.shaver then
		local shavee = act.target or act.doer
		if shavee and shavee.components.beard then
			return shavee.components.beard:Shave(act.doer, act.invobject)
		end
		if shavee and shavee.shaveable then
			shavee.shave(shavee, act.doer)
			return true
		end		
	end
end

ACTIONS.PLAY.fn = function(act)
	if act.invobject and act.invobject.components.instrument then
		return act.invobject.components.instrument:Play(act.doer)
	end
end

ACTIONS.POLLINATE.fn = function(act)
	if act.doer.components.pollinator then
		if act.target then
			return act.doer.components.pollinator:Pollinate(act.target)
		else
			return act.doer.components.pollinator:CreateFlower()
		end
	end
end

ACTIONS.TERRAFORM.fn = function(act)
	if act.invobject and act.invobject.components.terraformer then
		local tile = GetWorld().Map:GetTileAtPoint(act.pos.x, act.pos.y, act.pos.z)

		if tile == GROUND.GASJUNGLE then
			act.invobject.components.finiteuses:SetUses(0)
			GetPlayer().components.talker:Say(GetString(GetPlayer().prefab, "ANNOUNCE_TOOLCORRODED"))
			return true
		elseif tile == GROUND.DEEPRAINFOREST then
			GetPlayer().components.talker:Say(GetString(GetPlayer().prefab, "ANNOUNCE_TURFTOOHARD"))
			return true
		else
			return act.invobject.components.terraformer:Terraform(act.pos)
		end
	end
end

ACTIONS.EXTINGUISH.fn = function(act)
	if act.target.components.burnable
	   and act.target.components.burnable:IsBurning() then
		if act.target.components.fueled and not act.target.components.fueled:IsEmpty() then
			act.target.components.fueled:ChangeSection(-1)
		else
			act.target.components.burnable:Extinguish()
		end
		return true
	end
end

ACTIONS.LAYEGG.fn = function(act)
	if act.target.components.pickable and not act.target.components.pickable.canbepicked then
		return act.target.components.pickable:Regen()
	end
end

ACTIONS.INVESTIGATE.fn = function(act)
	local investigatePos = act.doer.components.knownlocations and act.doer.components.knownlocations:GetLocation("investigate")
	if investigatePos then
		act.doer.components.knownlocations:RememberLocation("investigate", nil)
		--try to get a nearby target
		if act.doer.components.combat then
			act.doer.components.combat:TryRetarget()
		end
		return true
	end
end


ACTIONS.GOHOME.fn = function(act)
	--this is gross. make it better later.
	if act.doer.force_onwenthome_message then
		act.doer:PushEvent("onwenthome")
	end
	if act.target.components.spawner then
		return act.target.components.spawner:GoHome(act.doer)
	elseif act.target.components.childspawner then
		return act.target.components.childspawner:GoHome(act.doer)
	elseif act.pos then
		if act.target then
			act.target:PushEvent("onwenthome", {doer = act.doer})
		end
		act.doer:Remove()
		return true
	end
end

ACTIONS.NIBBLE.fn = function(act)
	if act.doer.components.fishable.waitingfornibble then 
		act.doer.components.fishable:DoNibble()
		return true
	end 
end 

ACTIONS.JUMPIN.fn = function(act)
	if act.target.components.teleporter then
		act.target.components.teleporter:Activate(act.doer)
		return true
	end
end

ACTIONS.JUMPIN.strfn = function(act)
	if act.target.components.teleporter.getverb then
		return act.target.components.teleporter.getverb(act.target, act.doer)
	end
end

ACTIONS.USEDOOR.fn = function(act)
	if act.target:HasTag("secret_room") or act.target:HasTag("predoor") then
		return false
	end

	if act.target.components.door and not act.target.components.door.disabled then
		act.target.components.door:Activate(act.doer)
		return true
	elseif act.target.components.door and act.target.components.door.disabled then
		return false, "LOCKED"
	end
end

ACTIONS.USEDOOR.strfn = function(act)
	if act.target.components.door.getverb then
		return act.target.components.door.getverb(act.target, act.doer)
	end
end

ACTIONS.RESETMINE.fn = function(act)
	if act.target.components.mine then
		act.target.components.mine:Reset()
		return true
	end
end

ACTIONS.ACTIVATE.fn = function(act)
	if act.target.components.activatable then
		act.target.components.activatable:DoActivate(act.doer)
		return true
	end
end

ACTIONS.ACTIVATE.strfn = function(act)
	if act.target.components.activatable.getverb then
		return act.target.components.activatable.getverb(act.target, act.doer)
	end
end

ACTIONS.MURDER.fn = function(act)
	local murdered = act.invobject or act.target
	if murdered and murdered.components.health then
				
		murdered.components.inventoryitem:RemoveFromOwner(true)

		if murdered.components.health.murdersound then
			act.doer.SoundEmitter:PlaySound(murdered.components.health.murdersound)
		end

		local stacksize = 1
		if murdered.components.stackable then
			stacksize = murdered.components.stackable.stacksize
		end

		if murdered.components.lootdropper then
			for i = 1, stacksize do
				local loots = murdered.components.lootdropper:GenerateLoot()
				for k, v in pairs(loots) do
					local loot = SpawnPrefab(v)
					act.doer.components.inventory:GiveItem(loot)
				end      
			end
		end

		act.doer:PushEvent("killed", {victim = murdered})
		murdered:Remove()

		return true
	end
end

ACTIONS.HEAL.fn = function(act)
	if act.invobject and act.invobject.components.healer then
		local target = act.target or act.doer
		return act.invobject.components.healer:Heal(target)
	end
end

ACTIONS.CUREPOISON.strfn = function(act)
	if act.invobject and act.invobject:HasTag("venomgland") then
		return "GLAND"
	end
end

ACTIONS.CUREPOISON.fn = function(act)
	if act.invobject and act.invobject.components.poisonhealer then
		local target = act.target or act.doer
		return act.invobject.components.poisonhealer:Cure(target)
	end
end

ACTIONS.UNLOCK.fn = function(act)
	if act.target.components.lock then
		if act.target.components.lock:IsLocked() then
			act.target.components.lock:Unlock(act.invobject, act.doer)
		--else
			--act.target.components.lock:Lock(act.doer)
		end
		return true
	end
end

--ACTIONS.UNLOCK.strfn = function(act)
	--if act.target.components.lock and not act.target.components.lock:IsLocked() then
		--return "LOCK"
	--end
--end

ACTIONS.TEACH.fn = function(act)
	if act.invobject and act.invobject.components.teacher then
		local target = act.target or act.doer
		return act.invobject.components.teacher:Teach(target)
	end
end

ACTIONS.TURNON.fn = function(act)
	local tar = act.target or act.invobject
	if tar and tar.components.machine and not tar.components.machine:IsOn() then
		tar.components.machine:TurnOn(tar)
		return true
	end
end

ACTIONS.TURNOFF.fn = function(act)
	local tar = act.target or act.invobject
	if tar and tar.components.machine and tar.components.machine:IsOn() then
			tar.components.machine:TurnOff(tar)
		return true
	end
end

ACTIONS.TOGGLEON.fn = function(act)
	local tar = act.target or act.invobject
	if tar and tar.components.equippable and tar.components.equippable:CanToggle() and not tar.components.equippable:IsToggledOn() then

		if tar and tar.components.inventoryitem and tar.bookshelf then
        	tar.components.inventoryitem:TakeOffShelf()
    	end				
		tar.components.equippable:ToggleOn()
		return true
	end
end

ACTIONS.TOGGLEOFF.fn = function(act)
	local tar = act.target or act.invobject
	if tar and tar.components.equippable and tar.components.equippable:CanToggle() and tar.components.equippable:IsToggledOn() then

			if tar.components.inventoryitem and tar.bookshelf then
        		tar.components.inventoryitem:TakeOffShelf()
    		end	
			tar.components.equippable:ToggleOff()
		return true
	end
end

ACTIONS.USEITEM.strfn = function(act)
	if act.invobject and act.invobject.components.useableitem then
		return act.invobject.components.useableitem.verb
	end
end

ACTIONS.USEITEM.fn = function(act)
	if act.invobject and act.invobject.components.useableitem then
		if act.invobject.components.useableitem:CanInteract() then
			act.invobject.components.useableitem:StartUsingItem()
		end
	end
end

ACTIONS.TAKEITEM.fn = function(act)
--Use this for taking a specific item as opposed to having an item be generated as it is in Pick/ Harvest
	if act.target and act.target.components.shelf and act.target.components.shelf.cantakeitem then
		act.target.components.shelf:TakeItem(act.doer)
		return true
	end
end

ACTIONS.STOCK.fn = function(act)
	if act.target then		
		act.target.restock(act.target,true)
		act.doer.changestock = nil
		return true
	end
end

ACTIONS.CASTSPELL.strfn = function(act)
	local targ = act.invobject
	
	if targ and targ.components.spellcaster then
		return targ.components.spellcaster.actiontype
	end
end

ACTIONS.CASTSPELL.fn = function(act)
	--For use with magical staffs
	local staff = act.invobject or act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

	if staff and staff.components.spellcaster and staff.components.spellcaster:CanCast(act.doer, act.target, act.pos) then
		staff.components.spellcaster:CastSpell(act.target, act.pos)
		return true
	end
end


ACTIONS.BLINK.fn = function(act)
	if act.invobject and act.invobject.components.blinkstaff then
		return act.invobject.components.blinkstaff:Blink(act.pos, act.doer)
	end
end

ACTIONS.PEER.fn = function(act)
	--For use telescopes and the spellcaster component
	local telescope = act.invobject or act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)

	if telescope and telescope.components.spellcaster and telescope.components.spellcaster:CanCast(act.doer, act.target, act.pos) then
		telescope.components.spellcaster:CastSpell(act.target, act.pos)
		return true
	end
end

ACTIONS.COMBINESTACK.fn = function(act)
	local target = act.target
	local invobj = act.invobject
	if invobj and target and invobj.prefab == target.prefab and target.components.stackable and not target.components.stackable:IsFull()
	and target.components.inventoryitem and target.components.inventoryitem.canbepickedup then
		target.components.stackable:Put(invobj)
		return true
	end 
end

ACTIONS.TRAVEL.fn = function(act)
	if act.target and act.target.travel_action_fn then
		act.target.travel_action_fn(act.doer)
		return true
	end
end

ACTIONS.SUMMONGUARDIAN.fn = function(act)
	if act.doer and act.target and act.target.components.guardian then
		act.target.components.guardian:Call()
	end
end

ACTIONS.LAVASPIT.fn = function(act)
	if act.doer and act.target and act.doer.prefab == "dragonfly" then
		local spit = SpawnPrefab("lavaspit")
		local x,y,z = act.doer.Transform:GetWorldPosition()
		local downvec = TheCamera:GetDownVec()
		local offsetangle = math.atan2(downvec.z, downvec.x) * (180/math.pi)
		if act.doer.AnimState:GetCurrentFacing() == 0 then --Facing right
			offsetangle = offsetangle + 70
		else --Facing left
			offsetangle = offsetangle - 70
		end
		while offsetangle > 180 do offsetangle = offsetangle - 360 end
		while offsetangle < -180 do offsetangle = offsetangle + 360 end
		local offsetvec = Vector3(math.cos(offsetangle*DEGREES), -.3, math.sin(offsetangle*DEGREES)) * 1.7
		spit.Transform:SetPosition(x+offsetvec.x, y+offsetvec.y, z+offsetvec.z)
		spit.Transform:SetRotation(act.doer.Transform:GetRotation())
	end
	if act.doer and act.target and act.doer.prefab == "dragoon" then
		local spit = SpawnPrefab("dragoonspit")
		local x,y,z = act.doer.Transform:GetWorldPosition()
		local downvec = TheCamera:GetDownVec()
		local offsetangle = math.atan2(downvec.z, downvec.x) * (180/math.pi)
		
		while offsetangle > 180 do offsetangle = offsetangle - 360 end
		while offsetangle < -180 do offsetangle = offsetangle + 360 end
		local offsetvec = Vector3(math.cos(offsetangle*DEGREES), -.3, math.sin(offsetangle*DEGREES)) * 1.7
		spit.Transform:SetPosition(x+offsetvec.x, y+offsetvec.y, z+offsetvec.z)
		spit.Transform:SetRotation(act.doer.Transform:GetRotation())
	end
end

ACTIONS.HAIRBALL.fn = function(act)
	if act.doer and act.doer.prefab == "catcoon" then
		return true
	end
end

ACTIONS.CATPLAYGROUND.fn = function(act)
	if act.doer and act.doer.prefab == "catcoon" then
		if act.target then
			if math.random() < TUNING.CATCOON_ATTACK_CONNECT_CHANCE and act.target.components.health and act.target.components.health.maxhealth <= TUNING.PENGUIN_HEALTH and -- Only bother attacking if it's a penguin or weaker
			act.target.components.combat and act.target.components.combat:CanBeAttacked(act.doer) and
			not (act.doer.components.follower and act.target.components.follower and act.doer.components.follower.leader ~= nil and act.doer.components.follower.leader == act.target.components.follower.leader) and
			not (act.doer.components.follower and act.target.components.follower and act.doer.components.follower.leader ~= nil and act.target.components.follower.leader and act.target.components.follower.leader.components.inventoryitem and act.target.components.follower.leader.components.inventoryitem.owner and act.doer.components.follower.leader == act.target.components.follower.leader.components.inventoryitem.owner) and
			act.target ~= GetPlayer() then
				act.doer.components.combat:DoAttack(act.target, nil, nil, nil, 2) --2*25 dmg
			elseif math.random() < TUNING.CATCOON_PICKUP_ITEM_CHANCE and act.target.components.inventoryitem and act.target.components.inventoryitem.canbepickedup then
				act.target:Remove()
			end
		end
		return true
	end
end

ACTIONS.CATPLAYAIR.fn = function(act)
	if act.doer and act.doer.prefab == "catcoon" then
		if act.target and math.random() < TUNING.CATCOON_ATTACK_CONNECT_CHANCE and 
		act.target.components.health and act.target.components.health.maxhealth <= TUNING.PENGUIN_HEALTH and -- Only bother attacking if it's a penguin or weaker
		act.target.components.combat and act.target.components.combat:CanBeAttacked(act.doer) and
		not (act.doer.components.follower and act.target.components.follower and act.doer.components.follower.leader ~= nil and act.doer.components.follower.leader == act.target.components.follower.leader) and
		not (act.doer.components.follower and act.target.components.follower and act.doer.components.follower.leader ~= nil and act.target.components.follower.leader and act.target.components.follower.leader.components.inventoryitem and act.target.components.follower.leader.components.inventoryitem.owner and act.doer.components.follower.leader == act.target.components.follower.leader.components.inventoryitem.owner) then
			act.doer.components.combat:DoAttack(act.target, nil, nil, nil, 2) --2*25 dmg
		end
		act.doer.last_play_air_time = GetTime()
		return true
	end
end

ACTIONS.STEALMOLEBAIT.fn = function(act)
	if act.doer and act.target and act.doer.prefab == "mole" then
		act.target.selectedasmoletarget = false
		act.target:PushEvent("onstolen", {thief=act.doer})
		return true
	end
end

ACTIONS.MAKEMOLEHILL.fn = function(act)
	if act.doer and act.doer.prefab == "mole" then
		local molehill = SpawnPrefab("molehill")
		local pt = act.doer:GetPosition()
		molehill.Transform:SetPosition(pt.x, pt.y, pt.z)
		molehill:PushEvent("confignewhome", {mole=act.doer})
		act.doer.needs_home_time = nil
		return true
	end
end

ACTIONS.MOLEPEEK.fn = function(act)
	if act.doer and act.doer.prefab == "mole" then
		act.doer:PushEvent("peek")
		return true
	end
end

ACTIONS.BURY.fn = function(act)
	if act.doer and act.target and act.target.components.hole and act.target.components.hole.canbury then
		act.invobject.components.buryable:OnBury(act.target, act.doer)
		return true
	end
end

ACTIONS.FEED.fn = function(act)
	if act.doer and act.target and act.target.components.eater and act.target.components.eater:CanEat(act.invobject) then
		act.target.components.eater:Eat(act.invobject)
		return true
	end
end

ACTIONS.FAN.fn = function(act)
	if act.invobject and act.invobject.components.fan then
		local target = act.target or act.doer
		return act.invobject.components.fan:Fan(target)
	end
end

ACTIONS.UPGRADE.fn = function(act)
	if act.invobject and act.target then
		return act.target.components.upgradeable:Upgrade(act.invobject)
	end
end

ACTIONS.HACK.fn = function(act)
	local numworks = 1
	if act.invobject and act.invobject.components.tool then
		numworks = act.invobject.components.tool:GetEffectiveness(ACTIONS.HACK)
	elseif act.doer and act.doer.components.worker then
		numworks = act.doer.components.worker:GetEffectiveness(ACTIONS.HACK)
	end
	if act.invobject and act.invobject.components.obsidiantool then
		act.invobject.components.obsidiantool:Use(act.doer, act.target)
	end
	if act.target and act.target.components.hackable then
		act.target.components.hackable:Hack(act.doer, numworks)
		return true
	end
	if act.target and act.target.components.workable and act.target.components.workable.action == ACTIONS.HACK then
		act.target.components.workable:WorkedBy(act.doer, numworks)
		return true
	end
end

ACTIONS.SHEAR.fn = function (act)
	if act.target and act.target.components.shearable then
		act.target.components.shearable:Shear(act.doer)
		return true
	end

	if act.target and act.target.components.workable and act.target.components.workable.action == ACTIONS.SHEAR then
		act.target.components.workable:WorkedBy(act.doer, numworks)
		return true
	end
end

ACTIONS.SPY.fn = function(act)
	if act.target and act.target.components.mystery then
		act.target.components.mystery:Investigate(act.doer)
		return true
	elseif act.target and act.target.components.mystery_door then
		act.target.components.mystery_door:Investigate(act.doer)
		return true
	end
end

ACTIONS.STICK.fn = function(act)
	if act.target.components.stickable then
		act.target.components.stickable:PokedBy(act.doer, act.invobject)
		return true
	end
end

ACTIONS.MATE.fn = function(act)
	-- print("ACTIONS.MATE.fn")
	if act.target == act.doer then
		return false
	end

	if act.doer.components.mateable then
		act.doer.components.mateable:Mate()
		return true
	end
end

ACTIONS.CRAB_HIDE.fn = function(act)
	--Dummy action for crab.
end

ACTIONS.TIGERSHARK_FEED.fn = function(act)
	--Drop some gross food near your kittens
	local doer = act.doer
	if doer and doer.components.lootdropper then
		doer.components.lootdropper:SpawnLootPrefab("mysterymeat")
	end
end

ACTIONS.FLUP_HIDE.fn = function(act)
	--Dummy action for flup hiding
end

ACTIONS.PEAGAWK_TRANSFORM.fn = function(act)
	--Dummy action for flup hiding
end

ACTIONS.THROW.fn = function(act)
	local thrown = act.invobject or act.doer.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if act.target and not act.pos then
		act.pos = act.target:GetPosition()
	end
	if thrown and thrown.components.throwable then
		thrown.components.throwable:Throw(act.pos, act.doer)
		return true
	end
end

ACTIONS.LAUNCH_THROWABLE.fn = function(act)
	if act.target and not act.pos then
		act.pos = act.target:GetPosition()
	end
	act.invobject.components.thrower:Throw(act.pos)
	return true
end

ACTIONS.BARK.fn = function(act)
	return true
end

ACTIONS.RANSACK.fn = function(act)
	return true
end

ACTIONS.PAN.fn = function(act)
	if act.target.components.workable and act.target.components.workable.action == ACTIONS.PAN then
		local numworks = 1

		if act.invobject and act.invobject.components.tool then
			numworks = act.invobject.components.tool:GetEffectiveness(ACTIONS.PAN)
		elseif act.doer and act.doer.components.worker then
			numworks = act.doer.components.worker:GetEffectiveness(ACTIONS.PAN)
		end
		act.target.components.workable:WorkedBy(act.doer, numworks)

		if act.target.components.citypossession and act.target.components.citypossession.enabled then
			local world = GetWorld()
			if world.components.cityalarms then
				world.components.cityalarms:ChangeStatus(act.target.components.citypossession.cityID,true, act.doer)			
			end				
		end			
	end
	return true
end

ACTIONS.INFEST.fn = function(act)

	if not act.doer.infesting then
		act.doer.components.infester:Infest(act.target)
	end

	return true
end

ACTIONS.GAS.fn = function(act)
	if act.invobject and act.invobject.components.gasser then
		local tile = GetWorld().Map:GetTileAtPoint(act.pos.x, act.pos.y, act.pos.z)
		act.invobject.components.gasser:Gas(act.pos)

		return true
	end
end

ACTIONS.BRUSH.fn = function(act)
    if act.target.components.combat and act.target.components.combat.target then
        return false, "TARGETINCOMBAT"
    elseif act.target.components.brushable then
        act.target.components.brushable:Brush(act.doer, act.invobject)
        return true
    end
end

ACTIONS.SADDLE.fn = function(act) 
	if act.target.components.combat and act.target.components.combat.target then
        return false, "TARGETINCOMBAT"
    elseif act.target.components.rideable then
        act.doer:PushEvent("saddle", { target = act.target })
        act.doer.components.inventory:RemoveItem(act.invobject)
        act.target.components.rideable:SetSaddle(act.doer, act.invobject)
        return true
    end
end

ACTIONS.UNSADDLE.fn = function(act)
    if act.target.components.combat and act.target.components.combat.target then
        return false, "TARGETINCOMBAT"
    elseif act.target.components.rideable then
        act.doer:PushEvent("saddle", { target = act.target })
        act.target.components.rideable:SetSaddle(act.doer, nil)
        return true
    end
end

require("components/drawingtool")
ACTIONS.DRAW.stroverridefn = function(act)
    local item = FindEntityToDraw(act.target, act.invobject)
    return item ~= nil
        and subfmt(STRINGS.ACTIONS.DRAWITEM, { item = item.drawnameoverride or item:GetDisplayName() })
        or nil
end

ACTIONS.DRAW.fn = function(act)	 
    if act.invobject ~= nil and
        act.target ~= nil and
        act.invobject.components.drawingtool ~= nil and
        act.target.components.drawable ~= nil and
        act.target.components.drawable:CanDraw() then
        local image, src = act.invobject.components.drawingtool:GetImageToDraw(act.target)
        if image == nil then
            return false, "NOIMAGE"
        end
        act.invobject.components.drawingtool:Draw(act.target, image, src)
        return true
    end
end

ACTIONS.UNPIN.fn = function(act)
    if act.doer ~= act.target and act.target.components.pinnable and act.target.components.pinnable:IsStuck() then
        act.target:PushEvent("unpinned")
        return true
    end
end

ACTIONS.CHARGE_UP.fn = function(act)
 	act.doer:PushEvent("beginchargeup")
end