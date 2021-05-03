local assets = 
{
	
}

local prefabs =
{
	--"parrot",
	"log",
	"cutgrass",
}

local function doresurrect(inst, dude)
	print("Beach resurrector being told to resurrect")
	inst:AddTag("busy")	
	
	local pos = inst:GetPosition()
	local recipe = GetRecipe("lograft")
	for _, v in pairs(recipe.ingredients) do
		for i = 1, v.amount do
			local offset, check_angle, deflected = FindWalkableOffset(pos, math.random()*2*PI, math.random()*2+2, 8, true, false) -- try to avoid walls
			local item = SpawnPrefab(v.type)
			if offset then
				item.Transform:SetPosition((pos+offset):Get())
			else
				item.Transform:SetPosition(pos:Get())
			end
		end
	end

	dude.components.hunger:Pause()
	TheFrontEnd:Fade(false, 2, nil, 1)

	scheduler:ExecuteInTime(2, function()
		GetClock():MakeNextDay()
		dude.Transform:SetPosition(inst.Transform:GetWorldPosition())
		--dude:Hide()
		TheCamera:SetDistance(12)
	end)

	
	
	
	local item = dude.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
	local wakeUpState = "wakeup" --"amulet_rebirth"
	if item then 
		if item.prefab == "armor_lifejacket" then
			item = dude.components.inventory:RemoveItem(item)
			if item then
				item:Remove()
				item.persists = false
			end

		elseif item.prefab == "amulet" then 
			wakeUpState = "amulet_rebirth"
		end 
	end
	

	-- local parrot = SpawnPrefab("parrot")
	-- parrot.Transform:SetPosition(inst.Transform:GetWorldPosition())

	
	if wakeUpState == "wakeup" then 
		scheduler:ExecuteInTime(4, function()
			TheFrontEnd:Fade(true, 2)		
			if dude.components.hunger then
				dude.components.hunger:SetPercent(2/3)
			end

			if dude.components.health then
				dude.components.health:Respawn(TUNING.RESURRECT_HEALTH)
			end
			
			if dude.components.sanity then
				dude.components.sanity:SetPercent(.75)
			end

			if dude.components.moisture then
				dude.components.moisture.moisture = dude.components.moisture.moistureclamp.max
			end

			if dude.components.temperature then
				dude.components.temperature:SetTemperature(TUNING.STARTING_TEMP)
			end
			
			dude.components.hunger:Resume()
			
			dude.sg:GoToState(wakeUpState)
			
			
			dude:DoTaskInTime(3, function(inst) 
				if dude.HUD then
					dude.HUD:Show()
				end
				TheCamera:SetDefault()
				inst:RemoveTag("busy")
			end)
			
		end)
	elseif wakeUpState == "amulet_rebirth" then 
		scheduler:ExecuteInTime(4, function()
			TheFrontEnd:Fade(true, 2)		
	
			if dude.components.moisture then
				dude.components.moisture.moisture = dude.components.moisture.moistureclamp.max
			end

			dude.components.hunger:Resume()
			
			dude.sg:GoToState(wakeUpState)
			
			dude:DoTaskInTime(3, function(inst) 
				if dude.HUD then
					dude.HUD:Show()
				end
				TheCamera:SetDefault()
				inst:RemoveTag("busy")
			end)
		
		end)	
	end 
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	inst:AddTag("NOBLOCK")
	inst:AddTag("NOCLICK")
	inst.doresurrect = doresurrect

	return inst
end

return Prefab("forest/objects/beachresurrector", fn, assets, prefabs) 
