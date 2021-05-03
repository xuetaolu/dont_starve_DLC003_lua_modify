
local assets = 
{
	Asset("ANIM", "anim/woodlegs_cage.zip"),
    Asset("MINIMAP_IMAGE", "woodlegs_key1"),
    Asset("MINIMAP_IMAGE", "woodlegs_key2"),
    Asset("MINIMAP_IMAGE", "woodlegs_key3"),
}

local prefabs = 
{
	"collapse_big",
	"log",
	"boards",
	"rocks",
	"vine",
	"woodlegs_unlock",
}

local loot = 
{
	"log",
	"log",
	"boards",
	"boards",
	"rocks",
	"vine",
}

local function GetStatus(inst)
	-- ProfileStatsSet("teleportato_inspected", true)
	local keysCount = 0
	for key, found in pairs(inst.collectedKeys) do
		if found == true then
			keysCount = keysCount + 1
		end
	end

	return "KEYS"..tostring(keysCount)
end

local function ItemTradeTest(inst, item)
	return item:HasTag("woodlegs_key")
end

local function Unlock(inst)
	-- ProfileStatsSet("teleportato_powerup", true)
	inst.AnimState:PlayAnimation("unlocked", false)

	-- unlock woodlegs
	local player = GetPlayer()
	player.profile:UnlockCharacter("woodlegs")
	player.profile.dirty = true
	player.profile:Save()

	inst.SoundEmitter:PlaySound("dontstarve_DLC002/characters/woodlegs/unlock")
	inst.SoundEmitter:PlaySound("dontstarve_DLC002/characters/woodlegs/tree_destroy")
	
	inst:DoTaskInTime(0.5, function(inst)
		SpawnPrefab("collapse_big").Transform:SetPosition(inst.Transform:GetWorldPosition())

		inst.components.lootdropper:DropLoot()
	end)

	inst:ListenForEvent("animover", function(inst)
		inst.AnimState:ClearOverrideBuild("woodlegs")

		local unlock = SpawnPrefab("woodlegs_unlock")
		unlock.Transform:SetPosition(inst:GetPosition():Get())
		
		local time_to_erode = 1
		local tick_time = TheSim:GetTickTime()
		inst:StartThread( function()
			local ticks = 0
			while ticks * tick_time < time_to_erode do
				local erode_amount = ticks * tick_time / time_to_erode
				inst.AnimState:SetErosionParams( erode_amount, 0.1, 1.0 )
				ticks = ticks + 1
				Yield()
			end
			inst:Remove()
		end)
	end)
end

local keySymbols = { woodlegs_key1 = "KEY1", woodlegs_key2 = "KEY2", woodlegs_key3 = "KEY3" }

local function TestForUnlock(inst)
	local allKeys = true
	for key, found in pairs(inst.collectedKeys) do
		if found == false then
			inst.AnimState:Hide(keySymbols[key])
			allKeys = false
		else
			inst.AnimState:Show(keySymbols[key])
		end
	end

	if allKeys == true then		
		inst.components.trader:Disable()
		inst:DoTaskInTime(0.5, Unlock)
	end
end

local function ItemGet(inst, giver, item)
	if inst.collectedKeys[item.prefab] ~= nil then
		inst.collectedKeys[item.prefab] = true
		if item.prefab == "woodlegs_key1" then
			inst.SoundEmitter:PlaySound("dontstarve_DLC002/characters/woodlegs/key_1", "key_1")
		elseif item.prefab == "woodlegs_key2" then
			inst.SoundEmitter:PlaySound("dontstarve_DLC002/characters/woodlegs/key_2", "key_2")
		else
			inst.SoundEmitter:PlaySound("dontstarve_DLC002/characters/woodlegs/key_3", "key_3")
		end
		TestForUnlock(inst)
	end
end

local function MakeComplete(inst)
	print("Made Complete")
	inst.collectedKeys = {woodlegs_key1 = true, woodlegs_key2 = true, woodlegs_key3 = true}
end

local function OnLoad(inst, data)
	if data then
		if data.makecomplete == 1 then
			print("has make complete data")
			MakeComplete(inst)
			TestForUnlock(inst)
		end
		if data.collectedKeys then
			inst.collectedKeys = data.collectedKeys
			TestForUnlock(inst)
		end
	end
end

local function ItemTest(inst, item, slot)
	return item:HasTag("woodlegs_key")
end

local function OnSave(inst, data)
	data.collectedKeys = inst.collectedKeys
	data.action = inst.action
	if inst.teleportpos then
		data.teleportposx = inst.teleportpos.x
		data.teleportposz = inst.teleportpos.z
	end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

	anim:SetBank("woodlegs_cage")
	anim:SetBuild("woodlegs_cage")
	
	anim:PlayAnimation("idle_swing", true)

	MakeObstaclePhysics(inst, 1.1)

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("woodlegs_cage.png")
	
	inst.entity:AddSoundEmitter()
	
	inst:AddComponent("inspectable")	
	inst.components.inspectable.getstatus = GetStatus
	inst.components.inspectable:RecordViews()

	inst:AddComponent("trader")
	inst.components.trader:SetAcceptTest(ItemTradeTest)
	inst.components.trader.onaccept = ItemGet

	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot(loot)

	inst.AnimState:AddOverrideBuild("woodlegs")

	inst.collectedKeys = {woodlegs_key1 = false, woodlegs_key2 = false, woodlegs_key3 = false}
	for key, symbol in pairs(keySymbols) do
		inst.AnimState:Hide(symbol)
	end

	inst.OnSave = OnSave
	inst.OnLoad = OnLoad

	if Profile:IsCharacterUnlocked("woodlegs") then
		inst:Remove()
	end
	
	return inst
end

return Prefab( "common/objects/woodlegs_cage", fn, assets, prefabs )
