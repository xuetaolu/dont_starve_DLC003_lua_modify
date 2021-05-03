local assets =
{
	Asset("ANIM", "anim/messagebottle.zip"),
	Asset("INV_IMAGE", "messageBottle"),
	Asset("INV_IMAGE", "messageBottleEmpty"),
	Asset("MINIMAP_IMAGE", "messageBottle"),

}

local function revealTreasure(inst)
	if inst.treasure and inst.treasure:IsValid() then
		inst.treasure:Reveal(inst)
		inst.treasure:RevealFog(inst)
	end
end

local function showOnMinimap(treasure, reader)
	if treasure and treasure:IsValid() then
		treasure:FocusMinimap(treasure)
	end
end

local function readfn(inst, reader)

	print("Read Message Bottle", tostring(inst.treasure), tostring(inst.treasureguid))

	if (not inst.treasure and inst.treasureguid) or (not SaveGameIndex:IsModeShipwrecked() 
		or SaveGameIndex:GetCurrentMode() == "volcano" ) then

		reader.components.talker:Say(GetString(reader.prefab, "ANNOUNCE_OTHER_WORLD_TREASURE"))
		return true
	end

	local message
	if inst.treasure then
		--message = GetString(reader.prefab, "ANNOUNCE_TREASURE")
		revealTreasure(inst)
		inst.treasure:DoTaskInTime(0, function() showOnMinimap(inst.treasure, reader) end)
	else
		--reader.components.talker:Say(GetString(reader.prefab, messages[inst.message]))
		message = GetString(reader.prefab, "ANNOUNCE_MESSAGEBOTTLE", inst.message)
	end

	if inst.debugmsg then
		print(inst.debugmsg)
		reader.components.talker:Say(inst.debugmsg)
	elseif message then
		reader.components.talker:Say(message)
	end

	inst.components.inventoryitem:RemoveFromOwner(true)
	inst:Remove()

	reader:DoTaskInTime(3*FRAMES, function() reader.components.inventory:GiveItem(SpawnPrefab("messagebottleempty")) end)
	-- reader.components.inventory:GiveItem(SpawnPrefab("messagebottleempty"))

	return true
end

local function placeBottle(inst)
	--place in deep water
	local world = GetWorld()
	local width, height = world.Map:GetSize()
	local ground = GROUND.INVALID
	local x, y, z = 0, 0, 0
	local edge_dist = 16
	local tries = 0
	while not world.Map:IsWater(ground) and tries < 7 do
		x, z = math.random(edge_dist, width - edge_dist), math.random(edge_dist, height - edge_dist)
		ground = world.Map:GetTile(x, z)
		--print("Place bottle try "..tries.." "..x..","..y..","..z..", ground="..ground)
		tries = tries + 1
	end

	x = (x - width/2.0)*TILE_SCALE
	z = (z - height/2.0)*TILE_SCALE
	inst.Transform:SetPosition(x, y, z)
	inst.components.inventoryitem:OnHitGround()
	--print("Message Bottle placed "..x..","..y..","..z..", ground="..ground)
end

local function commonfn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	
	MakeInventoryPhysics(inst)

    anim:SetBank("messagebottle")
    anim:SetBuild("messagebottle")

    inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")
	--inst.components.inventoryitem:SetOnPickupFn(function(item) revealTreasure(inst) end)

	inst:AddComponent("waterproofer")
	inst.components.waterproofer:SetEffectiveness(0)

	inst.no_wet_prefix = true

	return inst	
end

local function messagebottlefn(Sim)
	local inst = commonfn(Sim)
	local minimap = inst.entity:AddMiniMapEntity() --temp

	-- inst.AnimState:PlayAnimation("idle", true)
	inst:AddTag("messagebottle")
	inst:AddTag("nosteal")

	minimap:SetIcon("messageBottle.png")

    --inst:AddComponent("inspectable")
    --inst:AddComponent("edible")
    inst:AddComponent("book")
    inst.components.book:SetOnReadFn(readfn)
    inst.components.book:SetAction(ACTIONS.READMAP)

    MakeInventoryFloatable(inst, "idle_water", "idle")

	inst.treasure = nil
	inst.treasureguid = nil
	inst.message = math.random(1, #STRINGS.CHARACTERS.GENERIC.ANNOUNCE_MESSAGEBOTTLE)

	--placeBottle(inst)
	inst.PlaceBottle = placeBottle

	inst.OnSave = function(inst, data)
		local refs = {}
		if inst.treasure then
			data.treasure = inst.treasure.GUID
			table.insert(refs, inst.treasure.GUID)
		elseif inst.treasureguid then
			data.treasure = inst.treasureguid
			table.insert(refs, inst.treasureguid)
		end
		data.message = inst.message
		return refs
	end

	inst.OnLoadPostPass = function(inst, ents, data)
		inst.components.inventoryitem:OnHitGround() --this now handles hitting water or land 
		if data then
			if data.treasure then
				if ents[data.treasure] then
					inst.treasure = ents[data.treasure].entity
				end
				inst.treasureguid = data.treasure
			end
			inst.message = data.message
		end
	end	

	return inst
end

local function emptybottlefn(Sim)
	local inst = commonfn(Sim)
	-- inst.AnimState:PlayAnimation("idle_empty", true)
	--inst.components.inventoryitem:ChangeImageName("messageBottleEmpty") --temp

	MakeInventoryFloatable(inst, "idle_water_empty", "idle_empty")

    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

	return inst
end

return Prefab("shipwrecked/objects/messagebottle", messagebottlefn, assets),
		Prefab("shipwrecked/objects/messagebottleempty", emptybottlefn, assets)
