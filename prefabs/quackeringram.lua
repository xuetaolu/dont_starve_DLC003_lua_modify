local assets=
{
    Asset("ANIM", "anim/swap_quackeringram.zip"),
}

local prefabs =
{
    "quackering_wave"
}

-- from PIL: utility to check for item in list
local function Set(list)
	local set = {}
	for _, l in ipairs(list) do set[l] = true end
	return set
  end


local function onmounted(boat,data)
	local item = boat.components.container:GetItemInBoatSlot(BOATEQUIPSLOTS.BOAT_LAMP)
	if item and item.equippedby then
		data.driver.AnimState:OverrideSymbol("swap_lantern", "swap_quackeringram", "swap_quackeringram")
	end
end

local function ondismounted(boat,data)
	local item = boat.components.container:GetItemInBoatSlot(BOATEQUIPSLOTS.BOAT_LAMP)
	if item and item.equippedby then
		data.driver.AnimState:ClearOverrideSymbol("swap_lantern")
		item.windFX:HideEffect()
		item.SoundEmitter:KillSound("ram_LP")
	end
end


local function onequip(inst, owner)
    --print("equip, override on owner " ..tostring(owner))
    owner.AnimState:OverrideSymbol("swap_lantern", "swap_quackeringram", "swap_quackeringram")
    if owner.components.drivable.driver then
        --print("equip, override on driver " ..tostring(owner.components.drivable.driver))
        owner.components.drivable.driver.AnimState:OverrideSymbol("swap_lantern", "swap_quackeringram", "swap_quackeringram")
    end

    inst.equippedby = owner

    --print("Listening for mount/dismount from " ..tostring(owner))
    inst:ListenForEvent("mounted", onmounted, owner)
    inst:ListenForEvent("dismounted", ondismounted, owner)

end

local function onunequip(inst, owner)
    --print("onunequip, clear on owner " ..tostring(owner))
    owner.AnimState:ClearOverrideSymbol("swap_lantern")
	if owner.components.drivable.driver then
        --print("onunequip, clear on driver " ..tostring(owner.components.drivable.driver))
        owner.components.drivable.driver.AnimState:ClearOverrideSymbol("swap_lantern")
    end

    inst.equippedby = nil

    --print("Removing EventCallbacks for mount/dismount from " ..tostring(owner))
    inst:RemoveEventCallback("mounted", onmounted, owner)
    inst:RemoveEventCallback("dismounted", ondismounted, owner)

end

local function onfinished(inst)
     if inst.equippedby then
        inst.equippedby.AnimState:ClearOverrideSymbol("swap_lantern")
        if inst.equippedby.components.drivable.driver then
            inst.equippedby.components.drivable.driver.AnimState:ClearOverrideSymbol("swap_lantern")

			if inst.equippedby.components.drivable.driver.wakeTask then 
				print("clearing wake task")
				inst.equippedby.components.drivable.driver.wakeTask:Cancel() 
				inst.equippedby.components.drivable.driver.wakeTask = nil 
			end 
        end
    end

    if inst.windFX then
        inst.windFX:Remove()
    end

    inst:Remove()
end

local function spawnWake(driver)
	local wake = SpawnPrefab("quackering_wake")
	if driver.wakeLeft == true then
		wake.idleanimation = "idle"
		driver.wakeLeft = false
	else
		wake.idleanimation = "idle_2"
		driver.wakeLeft = true
	end
	local x, y, z = driver.Transform:GetWorldPosition()
    wake.Transform:SetPosition( x, y, z )
    wake.Transform:SetRotation(driver.Transform:GetRotation())
	--print("Spawning wake at:"..x..","..z)

	if driver.wakeTask then 
		driver.wakeTask:Cancel() 
		driver.wakeTask = nil 
	end 

	driver.wakeTask = driver:DoTaskInTime(5 * FRAMES, function() spawnWake(driver) end)
end

local function onPotentialRamHit(inst, target)

	local function performRamFX(inst, target)
		local quackeringRamFX = "boat_hit_fx_quackeringram"
		for i=1, 5, 1 do
			local impactFX = SpawnPrefab(quackeringRamFX)

			local dx = math.random(-3, 3)
			local dz = math.random(-3, 3)

			local x, y, z = target.Transform:GetWorldPosition()

			impactFX.Transform:SetPosition(x + dx, y, z + dz)
		end

        local driver = inst.components.rammer:FindDriver()
		if driver then
			local currentSpeed = driver.Physics:GetMotorSpeed()
			local boost = 25

			inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/quackering_ram/impact")
			driver.Physics:SetMotorVel(currentSpeed + boost, 0, 0)
			driver.wakeLeft = true
			driver.wakeTask = spawnWake(driver)
			driver:DoTaskInTime(40 * FRAMES, 
				function()
					if driver and driver.wakeTask then 
						driver.wakeTask:Cancel() 
						driver.wakeTask = nil 
					end 
				end)
		end

		-- minor camera shake on hit
		--function PlayerController:ShakeCamera(inst, shakeType, duration, speed, maxShake, maxDist)
		local player = GetPlayer()
		player.components.playercontroller:ShakeCamera(target, "VERTICAL", 0.2, 0.025, .35, 40)

	end

	local hitTarget = false
    local inpocket = target.components.inventoryitem and target.components.inventoryitem:IsHeld()
    local player = GetPlayer()
    local isfriend = (target == player) or target:HasTag("companion") or (target.components.follower and target.components.follower.leader == player)
        
    if not inpocket and not isfriend then 
        if target.components.combat then
            hitTarget = true
            local driver = inst.components.rammer:FindDriver()
            if driver then
				if driver.components.inventory then
					driver.components.inventory.insulated = true
				end

	            target.components.combat:GetAttacked(driver, TUNING.QUACKERINGRAM_DAMAGE, inst)

				if driver.components.inventory then
					driver.components.inventory.insulated = false
				end
			end
        elseif target.components.workable and not target:HasTag("busy") then --Haaaaaaack!
            hitTarget = true
            target.components.workable:Destroy(inst)
        end
    end

	-- common tasks when hitting a target
	if hitTarget then
		-- show fx
		performRamFX(inst, target)

		-- use up a charge
        inst.components.finiteuses:Use()

		-- cooldown, avoid double hits
		inst.components.rammer:StartCooldown()
	end

end

local function updateWindFX(inst)
	local driver = inst.components.rammer:FindDriver()

    local sortOrder = -1

	if driver ~= nil then
        local facing = driver.AnimState:GetCurrentFacing()
        inst.windFX:ChangeDirection(facing)

        -- when facing up, let the wind effect be behind the boat
        if facing == 1 then
            sortOrder = 3
        end
    end

    inst.windFX.AnimState:SetSortOrder(sortOrder)

    -- keep attached to ram
    local p = Vector3(inst.Transform:GetWorldPosition())
    inst.windFX.Transform:SetPosition(p.x, p.y, p.z)
end

local function fn(Sim)

    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.Transform:SetFourFaced()

    inst.entity:AddAnimState()

    -- used for collision checks in boat.lua
    inst:AddTag("quackeringram")

    inst.AnimState:SetBuild("swap_quackeringram")
    inst.AnimState:SetBank("quackeringram")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable.boatequipslot = BOATEQUIPSLOTS.BOAT_LAMP
    inst.components.equippable.equipslot = nil
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.QUACKERINGRAM_USE_COUNT)
    inst.components.finiteuses:SetUses(TUNING.QUACKERINGRAM_USE_COUNT)
    inst.components.finiteuses:SetOnFinished(onfinished)

	-- wind fx
	inst.windFX = SpawnPrefab("quackering_wave")
	inst.windFX:HideEffect()
	inst.SoundEmitter:KillSound("ram_LP")

	inst:AddComponent("rammer")
	inst.components.rammer.minSpeed = 2.5
	inst.components.rammer.onRamTarget = onPotentialRamHit
	inst.components.rammer.onUpdate = function(dt)
        if inst.components.rammer:IsActive() then
			--print("updating wind effect")
            updateWindFX(inst)
        end
	end

	inst.components.rammer.onActivate = function()
		--print("show effect")
        local driver = inst.components.rammer:FindDriver()

		local facing = driver.AnimState:GetCurrentFacing()
        inst.windFX:ShowEffect(facing)
		inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/quackering_ram/impact")
		inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/quackering_ram/ram_LP", "ram_LP")

		local currentSpeed = driver.Physics:GetMotorSpeed()
		local boost = 8
		driver.Physics:SetMotorVel(currentSpeed + boost, 0, 0)
	end

	inst.components.rammer.onDeactivate = function()
		--print("hide effect")
		inst.windFX:HideEffect()
		inst.SoundEmitter:KillSound("ram_LP")
	end

    return inst
end

return Prefab( "common/inventory/quackeringram", fn, assets, prefabs)
