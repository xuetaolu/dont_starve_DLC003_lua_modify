require "prefabutil"


local prefabs =
{
	"armormarble",
	"armor_sanity",
	"armorsnurtleshell",
	"resurrectionstatue",
	"icestaff",
	"firestaff",
	"telestaff",
	"thulecite",
	"orangestaff",
	"greenstaff",
	"yellowstaff",
	"amulet",
	"blueamulet",
	"purpleamulet",
	"orangeamulet",
	"greenamulet",
	"yellowamulet",
	"redgem",
	"bluegem",
	"orangegem",
	"greengem",
	"purplegem",
	"stafflight",
	"gears",
	"collapse_small",
}


-- A weighted average list of prizes, the bigger the number, the more likely it is.
-- It's based off altar_prototyper.lua
local goodspawns = 
{
--	log = 50,
--	twigs =50,
--	cutgrass = 50,
--	berries = 50,
--	limpets = 50,
--	meat = 50,
--	monstermeat = 50,
--	fish = 50,
--	meat_dried = 30,
--	seaweed = 50,
--	jellyfish = 20,
--	dubloon = 50, 
--	redgem = 10,
--	bluegem = 10,
--	purplegem = 10,
--	goldnugget = 50,
--	snakeskin = 20,
--	spidergland = 20,
--	torch = 50,
--	coconut = 50,

	-- Best Slot Loot List
	slot_goldy = 1,
	slot_10dubloons = 1,
	slot_honeypot = 1,
	slot_warrior1 = 1,
	slot_warrior2 = 1,
	slot_warrior3 = 1,
	slot_warrior4 = 1,
	slot_scientist = 1,
	slot_walker = 1,
	slot_gemmy = 1,
	slot_bestgem = 1,
	slot_lifegiver = 1,
	slot_chilledamulet = 1,
	slot_icestaff = 1,
	slot_firestaff = 1,
	slot_coolasice = 1,
	slot_gunpowder = 1,
	slot_firedart = 1,
	slot_sleepdart = 1,
	slot_blowdart = 1,
	slot_speargun = 1,
	slot_coconades = 1,
	slot_obsidian = 1,
	slot_thuleciteclub = 1,
	slot_ultimatewarrior = 1,
	slot_goldenaxe = 1,
	staydry = 1,
	cooloff = 1,
	birders = 1,
	gears =1,
	slot_seafoodsurprise = 1,
	slot_fisherman = 1,
	slot_camper = 1,
	slot_spiderboon = 1,
	slot_dapper = 1,
	slot_speed = 1,
	slot_tailor = 5,
}

local okspawns =
{
	-- OK slot List - Food and Resrouces 
	slot_anotherspin = 5,
	firestarter = 5,
	geologist = 5,
	cutgrassbunch = 5,
	logbunch = 5,
	twigsbunch = 5,
--	torch = 5,
	slot_torched = 5,
	slot_jelly = 5,
	slot_handyman = 5,
	slot_poop = 5,
	slot_berry = 5,
	slot_limpets = 5,
	slot_bushy = 5,
	slot_bamboozled = 5,
	slot_grassy = 5,
	slot_prettyflowers = 5,
	slot_witchcraft = 5,
	slot_bugexpert = 5,
	slot_flinty = 5,
	slot_fibre = 5,
	slot_drumstick = 5,
	slot_ropey = 5,
	slot_jerky = 5,
	slot_coconutty = 5,
	slot_bonesharded = 5,
	



}

local badspawns =
{
	-- Bad prizes
--	snake = 1,
--	spider_hider = 1,
	slot_spiderattack = 1,
	slot_mosquitoattack = 1,
	slot_snakeattack = 1,
	slot_monkeysurprise = 1,
	slot_poisonsnakes = 1,
	slot_hounds = 1,


	-- Old
	--nothing = 100,
	--trinket = 100,
}

-- weighted_random_choice for bad, ok, good prize lists 
local prizevalues =
{
	bad = 2,
	ok = 3,
	good = 1,
}

local prizevalues_nondubloon =
{
	bad = 3,
	ok = 2,
	good = 1,
}


-- actions to perform for the spawns
local actions =
{
	-- if there's a cnt, then it'll spawn that many
	--trinket = { cnt = 2, },
--	spider_hider = { cnt = 3, },
--	snake = { cnt = 3, },

	-- Prizes based of TreasureLoot table in map/treasurehunt.lua
	-- treasure = <the name in the TreasureLoot table>
	-- overrides all other things


	firestarter = { treasure = "firestarter", },
	geologist = { treasure = "geologist", },
	cutgrassbunch = { treasure = "3cutgrass", },
	logbunch = { treasure = "3logs", },
	twigsbunch = { treasure = "3twigs", },
	slot_torched = { treasure = "slot_torched", },
	slot_jelly = { treasure = "slot_jelly", },
	slot_handyman = { treasure = "slot_handyman", },
	slot_poop = { treasure = "slot_poop", },
	slot_berry = { treasure = "slot_berry", },
	slot_limpets = { treasure = "slot_limpets", },
	slot_seafoodsurprise = { treasure = "slot_seafoodsurprise", },
	slot_bushy = { treasure = "slot_bushy", },
	slot_bamboozled = { treasure = "slot_bamboozled", },
	slot_grassy = { treasure = "slot_grassy", },
	slot_prettyflowers = { treasure = "slot_prettyflowers", },
	slot_witchcraft = { treasure = "slot_witchcraft", },
	slot_bugexpert = { treasure = "slot_bugexpert", },
	slot_flinty = { treasure = "slot_flinty", },
	slot_fibre = { treasure = "slot_fibre", },
	slot_drumstick = { treasure = "slot_drumstick", },
	slot_fisherman = { treasure = "slot_fisherman", },
	slot_dapper = { treasure = "slot_dapper", },
	slot_speed = { treasure = "slot_speed", },




	slot_anotherspin = { treasure = "slot_anotherspin", },
	slot_goldy = { treasure = "slot_goldy", },
	slot_honeypot = { treasure = "slot_honeypot", },
	slot_warrior1 = { treasure = "slot_warrior1", },
	slot_warrior2 = { treasure = "slot_warrior2", },
	slot_warrior3 = { treasure = "slot_warrior3", },
	slot_warrior4 = { treasure = "slot_warrior4", },
	slot_scientist = { treasure = "slot_scientist", },
	slot_walker = { treasure = "slot_walker", },
	slot_gemmy = { treasure = "slot_gemmy", },
	slot_bestgem = { treasure = "slot_bestgem", },
	slot_lifegiver = { treasure = "slot_lifegiver", },
	slot_chilledamulet = { treasure = "slot_chilledamulet", },
	slot_icestaff = { treasure = "slot_icestaff", },
	slot_firestaff = { treasure = "slot_firestaff", },
	slot_coolasice = { treasure = "slot_coolasice", },
	slot_gunpowder = { treasure = "slot_gunpowder", },
	slot_firedart = { treasure = "slot_firedart", },
	slot_sleepdart = { treasure = "slot_sleepdart", },
	slot_blowdart = { treasure = "slot_blowdart", },
	slot_speargun = { treasure = "slot_speargun", },
	slot_coconades = { treasure = "slot_coconades", },
	slot_obsidian = { treasure = "slot_obsidian", },
	slot_thuleciteclub = { treasure = "slot_thuleciteclub", },
	slot_ultimatewarrior = { treasure = "slot_ultimatewarrior", },
	slot_goldenaxe = { treasure = "slot_goldenaxe", },
	staydry = { treasure = "staydry", },
	cooloff = { treasure = "cooloff", },
	birders = { treasure = "birders", },
	slot_monkeyball = { treasure = "slot_monkeyball", },


	slot_bonesharded = { treasure = "slot_bonesharded", },
	slot_jerky = { treasure = "slot_jerky", },
	slot_coconutty = { treasure = "slot_coconutty", },
	slot_camper = { treasure = "slot_camper", },
	slot_ropey = { treasure = "slot_ropey", },
	slot_tailor = { treasure = "slot_tailor", },
	slot_spiderboon = { treasure = "slot_spiderboon", },
	slot_3dubloons = { treasure = "3dubloons", },
	slot_10dubloons = { treasure = "10dubloons", },
	

	slot_spiderattack = { treasure = "slot_spiderattack", },
	slot_mosquitoattack = { treasure = "slot_mosquitoattack", },
	slot_snakeattack = { treasure = "slot_snakeattack", },
	slot_monkeysurprise = { treasure = "slot_monkeysurprise", },
	slot_poisonsnakes = { treasure = "slot_poisonsnakes", },
	slot_hounds = { treasure = "slot_hounds", },


				slot_snakeattack = { treasure = "slot_snakeattack", },
					slot_snakeattack = { treasure = "slot_snakeattack", },
						slot_snakeattack = { treasure = "slot_snakeattack", },

}

local sounds = 
{
	ok = "dontstarve_DLC002/common/slotmachine_mediumresult",
	good = "dontstarve_DLC002/common/slotmachine_goodresult",
	bad = "dontstarve_DLC002/common/slotmachine_badresult",
}

local function SpawnCritter(inst, critter, lootdropper, pt, delay)
	delay = delay or GetRandomWithVariance(1,0.8)
	inst:DoTaskInTime(delay, function() 
		SpawnPrefab("collapse_small").Transform:SetPosition(pt:Get())
		local spawn = lootdropper:SpawnLootPrefab(critter, pt)
		if spawn and spawn.components.combat then
			spawn.components.combat:SetTarget(GetPlayer())
		end
	end)
end

local function SpawnReward(inst, reward, lootdropper, pt, delay)
	delay = delay or GetRandomWithVariance(1,0.8)

	local loots = GetTreasureLootList(reward)
	for k, v in pairs(loots) do
		for i = 1, v, 1 do

			inst:DoTaskInTime(delay, function(inst) 
				local down = TheCamera:GetDownVec()
				local spawnangle = math.atan2(down.z, down.x)
				local angle = math.atan2(down.z, down.x) + (math.random()*90-45)*DEGREES
				local sp = math.random()*3+2
				
				local item = SpawnPrefab(k)

				if item.components.inventoryitem and not item.components.health then
					local pt = Vector3(inst.Transform:GetWorldPosition()) + Vector3(2*math.cos(spawnangle), 3, 2*math.sin(spawnangle))
					inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/slotmachine_reward")
					item.Transform:SetPosition(pt:Get())
					item.Physics:SetVel(sp*math.cos(angle), math.random()*2+9, sp*math.sin(angle))
					item.components.inventoryitem:OnStartFalling()
				else
					local pt = Vector3(inst.Transform:GetWorldPosition()) + Vector3(2*math.cos(spawnangle), 0, 2*math.sin(spawnangle))
					pt = pt + Vector3(sp*math.cos(angle), 0, sp*math.sin(angle))
					item.Transform:SetPosition(pt:Get())
					SpawnPrefab("collapse_small").Transform:SetPosition(pt:Get())
				end
				
			end)
			delay = delay + 0.25
		end
	end
end



local function PickPrize(inst,item)

	inst.busy = true
	local prizevalue = weighted_random_choice(prizevalues)

	if item.prefab ~= "dubloon" then
		prizevalue =weighted_random_choice(prizevalues_nondubloon)
	end
	-- print("slotmachine prizevalue", prizevalue)
	if prizevalue == "ok" then
		inst.prize = weighted_random_choice(okspawns)
	elseif prizevalue == "good" then
		inst.prize = weighted_random_choice(goodspawns)
	elseif prizevalue == "bad" then
		inst.prize = weighted_random_choice(badspawns)
	else
		-- impossible!
		-- print("impossible slot machine prizevalue!", prizevalue)
	end

	inst.prizevalue = prizevalue
end

local function DoneSpinning(inst)

	local pos = inst:GetPosition()
	local item = inst.prize
	local doaction = actions[item]

	local cnt = (doaction and doaction.cnt) or 1
	local func = (doaction and doaction.callback) or nil
	local radius = (doaction and doaction.radius) or 4
	local treasure = (doaction and doaction.treasure) or nil

	if doaction and doaction.var then
		cnt = GetRandomWithVariance(cnt,doaction.var)
		if cnt < 0 then cnt = 0 end
	end

	if cnt == 0 and func then
		func(inst,item,doaction)
	end

	for i=1,cnt do
		local offset, check_angle, deflected = FindWalkableOffset(pos, math.random()*2*PI, radius , 8, true, false) -- try to avoid walls
		if offset then
			if treasure then
				-- print("Slot machine treasure "..tostring(treasure))
				-- SpawnTreasureLoot(treasure, inst.components.lootdropper, pos+offset)
				-- SpawnPrefab("collapse_small").Transform:SetPosition((pos+offset):Get())
				SpawnReward(inst, treasure)
			elseif func then
				func(inst,item,doaction)
			elseif item == "trinket" then
				SpawnCritter(inst, "trinket_"..tostring(math.random(NUM_TRINKETS)), inst.components.lootdropper, pos+offset)
			elseif item == "nothing" then
				-- do nothing
				-- print("Slot machine says you lose.")
			else
				-- print("Slot machine item "..tostring(item))
				SpawnCritter(inst, item, inst.components.lootdropper, pos+offset)
			end
		end
	end

	-- the slot machine collected more coins
	inst.coins = inst.coins + 1

	--inst.AnimState:PlayAnimation("idle")
	inst.busy = false
	inst.prize = nil
	inst.prizevalue = nil
	
	-- print("Slot machine has "..tostring(inst.coins).." dubloons.")
end

local function StartSpinning(inst)

	inst.sg:GoToState("spinning")
end

local function ShouldAcceptItem(inst, item)
	
	if not inst.busy and (item.prefab == "dubloon" or item.prefab == "oinc" or item.prefab == "oinc10" or item.prefab == "oinc100") then
		return true
	else
		return false
	end
end

local function OnGetItemFromPlayer(inst, giver, item)

	-- print("Slot machine takes your dubloon.")
	giver.components.sanity:DoDelta(-TUNING.SANITY_TINY)

	PickPrize(inst,item)
	StartSpinning(inst)
end

local function OnRefuseItem(inst, item)
	-- print("Slot machine refuses "..tostring(item.prefab))
end

local function OnLoad(inst,data)
	if not data then
		return
	end
	
	inst.coins = data.coins or 0
	inst.prize = data.prize
	inst.prizevalue = data.prizevalue

	if inst.prize ~= nil then
		StartSpinning(inst)
	end
end

local function OnSave(inst,data)
	data.coins = inst.coins
	data.prize = inst.prize
	data.prizevalue = inst.prizevalue
end

local function OnFloodedStart(inst)
	inst.components.payable:Disable()
end

local function OnFloodedEnd(inst)
	inst.components.payable:Enable()
end

local function CalcSanityAura(inst, observer)
	return -(TUNING.SANITYAURA_MED*(1+(inst.coins/100)))
end

local function CreateSlotMachine(name)
	
	local assets = 
	{
		Asset("ANIM", "anim/slot_machine.zip"),
		Asset("MINIMAP_IMAGE", "slot_machine"),
	}


	local function InitFn(Sim)
		local inst = CreateEntity()
		inst.OnSave = OnSave
		inst.OnLoad = OnLoad

		inst.DoneSpinning = DoneSpinning
		inst.busy = false
		inst.sounds = sounds

		local trans = inst.entity:AddTransform()
		local anim = inst.entity:AddAnimState()
		inst.entity:AddSoundEmitter()
		
		local minimap = inst.entity:AddMiniMapEntity()
		minimap:SetPriority( 5 )
		minimap:SetIcon( "slot_machine.png" )
				
		MakeObstaclePhysics(inst, 0.8, 1.2)
		

		anim:SetBank("slot_machine")
		anim:SetBuild("slot_machine")
		anim:PlayAnimation("idle")

		-- keeps track of how many dubloons have been added
		inst.coins = 0
		
		inst:AddComponent("inspectable")
		inst.components.inspectable.getstatus = function(inst)
			return "WORKING"
		end

		inst:AddComponent("lootdropper")

		inst:AddComponent("payable")
		inst.components.payable:SetAcceptTest(ShouldAcceptItem)
		inst.components.payable.onaccept = OnGetItemFromPlayer
		inst.components.payable.onrefuse = OnRefuseItem

		inst:AddComponent("sanityaura")
    	inst.components.sanityaura.aurafn = CalcSanityAura

		inst:AddComponent("floodable")
		inst.components.floodable.onStartFlooded = OnFloodedStart
		inst.components.floodable.onStopFlooded = OnFloodedEnd
		inst.components.floodable.floodEffect = "shock_machines_fx"
		inst.components.floodable.floodSound = "dontstarve_DLC002/creatures/jellyfish/electric_land"

		inst:SetStateGraph("SGslotmachine")

		return inst
	end

	return Prefab( "common/objects/slotmachine", InitFn, assets, prefabs)

end

return CreateSlotMachine()

