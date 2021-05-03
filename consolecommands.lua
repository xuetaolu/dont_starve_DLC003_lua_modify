

local function Spawn(prefab)
	--TheSim:LoadPrefabs({prefab})
	return SpawnPrefab(prefab)
end

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
-- Console Functions -- These are simple helpers made to be typed at the console.
---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------

-- Spawn At Cursor and select the new ent
-- Has a gimpy short name so it's easier to type from the console
function c_spawn(prefab, count)
	count = count or 1
	local inst = nil
	for i=1,count do
		inst = DebugSpawn(prefab)
		inst.Transform:SetPosition(TheInput:GetWorldPosition():Get())
	end
	SetDebugEntity(inst)
	SuUsed("c_spawn_" .. prefab , true)
	return inst
end

function c_enablecheats()
	require "debugcommands"
	require "debugkeys"
	CHEATS_ENABLED = true
end

-- Get the currently selected entity, so it can be modified etc.
-- Has a gimpy short name so it's easier to type from the console
function c_sel()
	return GetDebugEntity()
end

function c_select(inst)
	return SetDebugEntity(inst)
end

-- Print the (visual) tile under the cursor
function c_tile()
	local s = ""

	local ground = GetWorld()
	local mx, my, mz = TheInput:GetWorldPosition():Get()
	local tx, ty = ground.Map:GetTileCoordsAtPoint(mx,my,mz)
	s = s..string.format("world[%f,%f,%f] tile[%d,%d] ", mx,my,mz, tx,ty)

	local tile = ground.Map:GetTileAtPoint(TheInput:GetWorldPosition():Get())
	for k,v in pairs(GROUND) do
		if v == tile then
			s = s..string.format("ground[%s] ", k)
			break
		end
	end

	print(s)
end

-- Apply a scenario script to the selection and run it.
function c_doscenario(scenario)
	local inst = GetDebugEntity()
	if not inst then
		print("Need to select an entity to apply the scenario to.")
		return
	end
	if inst.components.scenariorunner then
		inst.components.scenariorunner:ClearScenario()
	end

	-- force reload the script -- this is for testing after all!
	package.loaded["scenarios/"..scenario] = nil

	inst:AddComponent("scenariorunner")
	inst.components.scenariorunner:SetScript(scenario)
	inst.components.scenariorunner:Run()
	SuUsed("c_doscenario_"..scenario, true)
end


-- Some helper shortcut functions
function c_season() return GetWorld().components.seasonmanager end
function c_sel_health()
	if c_sel() then
		local health = c_sel().components.health
		if health then
			return health
		else
			print("Gah! Selection doesn't have a health component!")
			return
		end
	else
		print("Gah! Need to select something to access it's components!")
	end
end

function c_sethealth(n)
	SuUsed("c_sethealth", true)
	GetPlayer().components.health:SetPercent(n)
end
function c_setboathealth(n)
	SuUsed("c_setboathealth", true)
	local boat = GetPlayer().components.driver.vehicle
	if boat then
		boat.components.boathealth:SetPercent(1)
	end
end
function c_setminhealth(n)
	SuUsed("c_minhealth", true)
	GetPlayer().components.health:SetMinHealth(n)
end
function c_setsanity(n)
	SuUsed("c_setsanity", true)
	GetPlayer().components.sanity:SetPercent(n)
end
function c_sethunger(n)
	SuUsed("c_sethunger", true)
	GetPlayer().components.hunger:SetPercent(n)
end

-- Put an item(s) in the player's inventory
function c_give(prefab, count)
	count = count or 1

	local MainCharacter = GetPlayer()

	if MainCharacter then
		for i=1,count do
			local inst = Spawn(prefab)
			if inst then
				MainCharacter.components.inventory:GiveItem(inst)
				SuUsed("c_give_" .. inst.prefab)
				c_select(inst)
			end
		end
	end
end

function c_mat(recname)
	local player = GetPlayer()
	local recipe = GetRecipe(recname)
	if player.components.inventory and recipe then
	  for ik, iv in pairs(recipe.ingredients) do
			for i = 1, iv.amount do
				local item = SpawnPrefab(iv.type)
				player.components.inventory:GiveItem(item)
				SuUsed("c_mat_" .. iv.type , true)
			end
		end
	end
end

function c_mats(recname)
	c_mat(recname)
end

function c_material(recname)
	c_mat(recname)
end

function c_materials(recname)
	c_mat(recname)
end

function c_pos(inst)
	return inst and Point(inst.Transform:GetWorldPosition())
end

function c_printpos(inst)
	print(c_pos(inst))
end

function c_teleport(x, y, z, inst)
	inst = inst or GetPlayer()
	inst.Transform:SetPosition(x, y, z)
	SuUsed("c_teleport", true)
end

function c_move(inst)
	inst = inst or c_sel()
	inst.Transform:SetPosition(TheInput:GetWorldPosition():Get())
	SuUsed("c_move", true)
end

function c_goto(dest, inst)
	inst = inst or GetPlayer()
	if dest then
		inst.Transform:SetPosition(dest.Transform:GetWorldPosition())
	end
	SuUsed("c_goto", true)
end

function c_inst(guid)
	return Ents[guid]
end

function c_list(prefab)
	local x,y,z = GetPlayer().Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x,y,z, 9001)
	for k,v in pairs(ents) do
		if v.prefab == prefab then
			print(string.format("%s {%2.2f, %2.2f, %2.2f}", tostring(v), v.Transform:GetWorldPosition()))
		end
	end
end

function c_listtag(tag)
	local tags = {tag}
	local x,y,z = GetPlayer().Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x,y,z, 9001, tags)
	for k,v in pairs(ents) do
		print(string.format("%s {%2.2f, %2.2f, %2.2f}", tostring(v), v.Transform:GetWorldPosition()))
	end
end

local lastfound = -1
function c_findnext(prefab, radius, inst)
	inst = inst or GetPlayer()
	radius = radius or 9001

	local trans = inst.Transform
	local found = nil
	local foundlowestid = nil
	local reallowest = nil
	local reallowestid = nil

	print("Finding a ", prefab)

	local x,y,z = trans:GetWorldPosition()
	local ents = TheSim:FindEntities(x,y,z, radius)
	for k,v in pairs(ents) do
		if v ~= inst and v.prefab == prefab then
			--print(v.GUID,lastfound,foundlowestid )
			if v.GUID > lastfound and (foundlowestid == nil or v.GUID < foundlowestid) then
				found = v
				foundlowestid = v.GUID
			end
			if not reallowestid or v.GUID < reallowestid then
				reallowest = v
				reallowestid = v.GUID
			end
		end
	end
	if not found then
		found = reallowest
	end
	if found then
		lastfound = found.GUID
	end
	return found
end

function c_godmode()
	local player = GetPlayer()
	if player then
		local godmode = player.components.health:IsInvincible()
		godmode = not godmode

		player.components.health:SetInvincible(godmode)
		if TUNING.DO_SEA_DAMAGE_TO_BOAT 
			and player.components.driver 
			and player.components.driver.vehicle 
			and player.components.driver.vehicle.components.boathealth then
				player.components.driver.vehicle.components.boathealth:SetInvincible(godmode)
		end
		SuUsed("c_godmode", true)
		print("God mode: ",godmode)
	end
end

function c_supergodmode()
	c_sethunger(1)
	c_setsanity(1)
	c_sethealth(1)
	c_setboathealth(1)
	c_godmode()
end

function c_exploration()
	c_give("minerhat")
	c_give("gunpowder", 20)
	c_give("goldenmachete")
	c_give("firestaff")
	c_gonext("pig_ruins_entrance5")
end

function c_housing()
	c_gonext("playerhouse_city")
	c_give("deed")
	c_give("construction_permit", 8)
	c_give("oinc100", 10)
	c_give("demolition_permit", 4)
end

function c_revealmap()
	GetWorld().minimap.MiniMap:ShowArea(0,0,0,10000)
end

function c_find(prefab, radius, inst)
	inst = inst or GetPlayer()
	radius = radius or 9001

	local trans = inst.Transform
	local found = nil
	local founddistsq = nil

	local x,y,z = trans:GetWorldPosition()
	local ents = TheSim:FindEntities(x,y,z, radius)
	for k,v in pairs(ents) do
		if v ~= inst and v.prefab == prefab then
			if not founddistsq or inst:GetDistanceSqToInst(v) < founddistsq then
				found = v
				founddistsq = inst:GetDistanceSqToInst(v)
			end
		end
	end
	return found
end

function c_findtag(tag, radius, inst)
	return GetClosestInstWithTag(tag, inst or GetPlayer(), radius or 1000)
end

local last_tag_found = nil
function c_gonexttag(tag, radius, inst)
	c_goto(GetClosestInstWithTag(tag, inst or GetPlayer(), radius or 9001))
end

function c_gonext(name)
	c_goto(c_findnext(name))
end

function c_gonear(name)
	local inst = c_findnext(name)

	local pt = Vector3(inst.Transform:GetWorldPosition())
    local theta = math.random() * 2 * PI
    local radius = 10

	local offset = FindWalkableOffset(pt, theta, radius, 12, true)
	if offset then
		pt = pt + offset
	end
	c_teleport(pt.x, pt.y, pt.z)
end

function c_printtextureinfo( filename )
	TheSim:PrintTextureInfo( filename )
end

function c_simphase(phase)
	GetWorld():PushEvent("phasechange", {newphase = phase})
end

function c_anim(animname, loop)
	if GetDebugEntity() then
		GetDebugEntity().AnimState:PlayAnimation(animname, loop or false)
	else
		print("No DebugEntity selected")
	end
end

function c_light(c1, c2, c3)
	TheSim:SetAmbientColour(c1, c2 or c1, c3 or c1)
end

function c_spawn_ds(prefab, scenario)
	local inst = c_spawn(prefab)
	if not inst then
		print("Need to select an entity to apply the scenario to.")
		return
	end

	if inst.components.scenariorunner then
		inst.components.scenariorunner:ClearScenario()
	end

	-- force reload the script -- this is for testing after all!
	package.loaded["scenarios/"..scenario] = nil

	inst:AddComponent("scenariorunner")
	inst.components.scenariorunner:SetScript(scenario)
	inst.components.scenariorunner:Run()
end


function c_hats()
	c_give("strawhat")
	c_give("tophat")
	c_give("beefalohat")
	c_give("featherhat")
	c_give("beehat")
	c_give("minerhat")
	c_give("spiderhat")
	c_give("footballhat")
	c_give("earmuffshat")
	c_give("winterhat")
	c_give("bushhat")
	c_give("flowerhat")
	c_give("walrushat")
	c_give("slurtlehat")
	c_give("ruinshat")
	c_give("wathgrithrhat")
	c_give("icehat")
	c_give("molehat")
	c_give("bathat")
	c_give("hayfeverhat")
	c_give("rainhat")
	c_give("catcoonhat")
	c_give("watermelonhat")
	c_give("eyebrellahat")
	c_give("captainhat")
	c_give("snakeskinhat")
	c_give("piratehat")
	c_give("gashat")
	c_give("aerodynamichat")
	c_give("double_umbrellahat")
	c_give("shark_teethhat")
	c_give("brainjellyhat")
	c_give("woodlegshat")
	c_give("oxhat")
	c_give("peagawkfeatherhat")
	c_give("antmaskhat")
	c_give("pigcrownhat")
	c_give("gasmaskhat")
	c_give("pithhat")
	c_give("bandithat")
	c_give("candlehat")
	c_give("thunderhat")
	c_give("metalplatehat")
	c_give("disguisehat")
end

function c_countprefabs(prefab, noprint)
	local count = 0
	local asleep = 0
	for k,v in pairs(Ents) do
		if v.prefab == prefab then
			count = count + 1
			if v:IsAsleep() then
				asleep = asleep + 1
			end
		end
	end
	if not noprint then
		print(string.format("There are %d %s's in the world (%d asleep).", count, prefab, asleep))
	end
	return count
end

function c_countprefabsinrange(prefab, radius, noprint)
	local x,y,z = GetPlayer().Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x,y,z, radius)

	local count = 0
	local asleep = 0

	for i,v in pairs(ents) do
		if v.prefab == prefab then
			count = count + 1
			if v:IsAsleep() then
				asleep = asleep + 1
			end
		end
	end

	if not noprint then
		print(string.format("There are %d %s's in the world (%d asleep).", count, prefab, asleep))
	end
	return count
end

function c_replacewith(prefabfrom, prefabto, radius)
	local x,y,z = GetPlayer().Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x,y,z, radius)
	for i,v in pairs(ents) do
		if v.prefab == prefabfrom then
			local x,y,z = v.Transform:GetWorldPosition()
			v:Remove()
			local ent = SpawnPrefab(prefabto)
			ent.Transform:SetPosition(x,y,z)
		end
	end
end

function c_countallprefabs()
	local counted = {}
	for k,v in pairs(Ents) do
		if v.prefab and not table.findfield(counted, v.prefab) then
			local num = c_countprefabs(v.prefab, true)
			counted[v.prefab] = num
		end
	end

	local function pairsByKeys (t, f)
	  local a = {}
	  for n in pairs(t) do table.insert(a, n) end
	  table.sort(a, f)
	  local i = 0      -- iterator variable
	  local iter = function ()   -- iterator function
		i = i + 1
		if a[i] == nil then return nil
		else return a[i], t[a[i]]
		end
	  end
	  return iter
	end

	for k,v in pairsByKeys(counted) do
		print(k, v)
	end

	print("There are ", GetTableSize(counted), " different prefabs in the world.")
end

function c_speed(speed)
	GetPlayer().components.locomotor.bonusspeed = speed
end

function c_forcecrash(unique)
    local path = "a"
    if unique then
        path = string.random(10, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUV")
    end

    if GetWorld() then
        GetWorld():DoTaskInTime(0,function() _G[path].b = 0 end)
    elseif TheFrontEnd then
        TheFrontEnd.screenroot.inst:DoTaskInTime(0,function() _G[path].b = 0 end)
    end
end

function c_testruins()
	GetPlayer().components.builder:UnlockRecipesForTech({SCIENCE = 2, MAGIC = 2})
	c_give("log", 20)
	c_give("flint", 20)
	c_give("twigs", 20)
	c_give("cutgrass", 20)
	c_give("lightbulb", 5)
	c_give("healingsalve", 5)
	c_give("batbat")
	c_give("icestaff")
	c_give("firestaff")
	c_give("tentaclespike")
	c_give("slurtlehat")
	c_give("armorwood")
	c_give("minerhat")
	c_give("lantern")
	c_give("backpack")
end


function c_teststate(state)
	c_sel().sg:GoToState(state)
end

function c_poison()
	local poisonable = GetPlayer().components.poisonable
	if poisonable:IsPoisoned() then
		poisonable:DonePoisoning()
	else
		poisonable:Poison()
	end
end

function c_testpoison()
	c_give("blowdart_poison", 20)
	c_give("spear_poison")
	c_give("speargun_poison", 20)
	c_give("mandrakesoup", 10)
	c_give("antivenom", 10)
	c_give("ash", 2)
	c_give("rocks", 1)
	c_give("venomgland", 1)
	c_give("devtool")
	c_give("armorseashell")
	-- c_spawn("spider_warrior", 3)
	-- c_spawn("snake_poison", 3)
	-- c_spawn("frog_poison", 3)
	-- c_spawn("mosquito_poison", 3)
	-- c_spawn("pigman", 5)
	-- c_spawn("spider", 5)
end

function c_testfire()
	c_give("obsidianaxe")
	c_give("obsidianmachete")
	c_give("spear_obsidian")
	c_give("obsidianspeargun", 20)
	c_give("armorobsidian")
	c_spawn("primeape",3)
end

function c_testcrockpot()
	local x, y, z = GetPlayer().Transform:GetWorldPosition()
	local n = 12
	local sector = 2*math.pi/n
	for i = 1, n, 1 do
		local p = SpawnPrefab("cookpot")
		if p then
			p.Transform:SetPosition(x + 8 * math.cos(i * sector), y, z + 8 * math.sin(i * sector))
		end
	end
	c_give("limpets", 20)
	c_give("fish_raw", 20)
	c_give("jellyfish", 1)
	c_give("seaweed", 20)
	c_give("ice", 20)
	c_give("cave_banana", 20)
	c_give("twigs", 20)
	c_give("meat", 20)
	c_give("shark_fin", 10)
	c_give("coffeebeans_cooked", 10)
	c_give("butter", 10)
	c_give("lobster", 2)
	c_give("crab", 2)
end

function c_givepreparedfood()
	local foods = require("preparedfoods")
	for k, v in pairs(foods) do
		c_give(k)
	end
end

-- Whoops, this is exactly the same as c_gonext()
function c_warp(dest)
	c_gonext(dest)
end

function c_testdoydoy()
	c_give('birdtrap',2)
	c_give('berries',2)
	c_spawn('doydoy')
end

function c_testcage()
	c_spawn('woodlegs_cage')
	c_give('woodlegs_key1')
	c_give('woodlegs_key2')
	c_give('woodlegs_key3')
end

function c_holdingdevtool()
	local item = GetPlayer().components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if item and item.prefab == "devtool" then
		return true
	end

	return false
end

function c_wetseason(skipPlayer)
	if skipPlayer == nil then 
		skipPlayer = true 
	end

	if c_holdingdevtool() then
		skipPlayer = false
	end

	local sm = GetSeasonManager()
	local cycles = GetClock():GetNumCycles()
	local days = sm:GetSeasonLength(SEASONS.MILD)
	if cycles < days then
		LongUpdate(TUNING.TOTAL_DAY_TIME * (days - cycles), skipPlayer)
	end
end

function c_greenseason(skipPlayer)
	if skipPlayer == nil then 
		skipPlayer = true 
	end
	
	if c_holdingdevtool() then
		skipPlayer = false
	end

	local sm = GetSeasonManager()
	local cycles = GetClock():GetNumCycles()
	local days = sm:GetSeasonLength(SEASONS.MILD) + sm:GetSeasonLength(SEASONS.WET)
	if cycles < days then
		LongUpdate(TUNING.TOTAL_DAY_TIME * (days - cycles), skipPlayer)
	end
end

function c_dryseason(skipPlayer)
	if skipPlayer == nil then 
		skipPlayer = true 
	end

	if c_holdingdevtool() then
		skipPlayer = false
	end

	local sm = GetSeasonManager()
	local cycles = GetClock():GetNumCycles()
	local days = sm:GetSeasonLength(SEASONS.MILD) + sm:GetSeasonLength(SEASONS.WET) + sm:GetSeasonLength(SEASONS.GREEN)
	if cycles < days then
		LongUpdate(TUNING.TOTAL_DAY_TIME * (days - cycles), skipPlayer)
	end
end

function c_nextseason(skipPlayer)
	if skipPlayer == nil then 
		skipPlayer = true 
	end

	if c_holdingdevtool() then
		skipPlayer = false
	end

	local sm = c_season()
	local time_left = (1-sm.percent_season) * sm:GetSeasonLength()
	print("% DONE SEASON: ", sm.percent_season)
	print("ADVANCING WORLD # OF DAYS:", time_left)
	LongUpdate(time_left*TUNING.TOTAL_DAY_TIME, skipPlayer)
end

function c_givetreasuremaps()
	local player = GetPlayer()
	local x,y,z = player.Transform:GetWorldPosition()
	local treasures = TheSim:FindEntities(x, y, z, 10000, {"buriedtreasure"}, {"linktreasure"})
	print("Found " .. #treasures .. " treasures")
	if treasures and type(treasures) == "table" and #treasures > 0 then
		for i = 1, #treasures, 1 do
		local bottle = SpawnPrefab("messagebottle")
		bottle.Transform:SetPosition(x, y, z)
		bottle.treasure = treasures[i]
		if bottle.treasure.debugname then
			bottle.debugmsg = "It's a map to '" .. bottle.treasure.debugname .. "'"
		end
		player.components.inventory:GiveItem(bottle)
		end
	end
end

function c_revealtreasure()
	local player = GetPlayer()
	local x,y,z = player.Transform:GetWorldPosition()
	local treasures = TheSim:FindEntities(x, y, z, 10000, {"buriedtreasure"})
	print("Found " .. #treasures .. " treasures")
	if treasures and type(treasures) == "table" and #treasures > 0 then
		for i = 1, #treasures, 1 do
			treasures[i]:Reveal(treasures[i])
			treasures[i]:RevealFog(treasures[i])
		end
	end
end

function c_erupt()
	local vm = GetWorld().components.volcanomanager
	if vm then
		vm:StartEruption(60.0, 60.0, 60.0, 1 / 8)
	end
end

function c_nexterupt()
	local sm = GetSeasonManager()
	local vm = GetWorld().components.volcanomanager

	if not sm:IsDrySeason() then
		c_dryseason()
	end

	if vm then
		local segs = vm:GetNumSegmentsUntilEruption() or 0
		if segs > 0 then
			print("Skipping", segs)
			LongUpdate(TUNING.SEG_TIME * segs, true)
		end
	end
end

function c_hurricane()
	local sm = GetSeasonManager()
	if sm then
		sm:StartHurricaneStorm()
	end
end

function c_prefabexists(prefab)
	if not PrefabExists(prefab) then
		print(prefab, "doest not exist!")
		return false
	end
	return true
end

function c_treasuretest()
	local l = GetTreasureLootDefinitionTable()

	for name, data in pairs(l) do
		if type(data) == "table" then

			if type(data.loot) == "table" then
				for k, _ in pairs(data.loot) do
					c_prefabexists(k)
				end
			end
			if type(data.random_loot) == "table" then
				for k, _ in pairs(data.random_loot) do
					c_prefabexists(k)
				end
			end
			if type(data.chance_loot) == "table" then
				for k, _ in pairs(data.chance_loot) do
					c_prefabexists(k)
				end
			end
		end
	end

	local t = GetTreasureDefinitionTable()
	local obj_layout = require("map/object_layout")

	for name, data in pairs(t) do
		if type(data) == "table" then
			for i, stage in ipairs(data) do
				if type(stage) == "table" then
					if stage.treasure_set_piece then
						obj_layout.LayoutForDefinition(stage.treasure_set_piece)
					end
					if stage.treasure_prefab then
						c_prefabexists(stage.treasure_prefab)
					end
					if stage.map_set_piece then
						obj_layout.LayoutForDefinition(stage.map_set_piece)
					end
					if stage.map_prefab then
						c_prefabexists(stage.map_prefab)
					end
					if stage.tier == nil then
						if stage.loot == nil then
							print("missing loot!", name)
						elseif l[stage.loot] == nil then
							print("missing loot!", name, stage.loot)
						end
					end
				end
			end
		end
	end
end

function c_spawntreasure(name)
	local x = c_spawn("buriedtreasure")
	x:Reveal()
	if name then
		x.loot = name
	else
		local treasures = GetTreasureLootDefinitionTable()
		local treasure = GetRandomKey(treasures)
		x.loot = treasure
	end
end

function c_floats()

	-- for i = 1, NUM_TRINKETS do
	--     c_give("trinket_"..tostring(i))
	-- end

	c_give("bell")
	c_give("fish")
	c_give("lantern")

end

function c_octoking()
	c_spawn('octopusking')
	c_give('trinket_23', 5)
	c_give('trinket_22', 5)
	c_give('trinket_21', 5)
	c_give('californiaroll', 3)
	c_give('seafoodgumbo', 3)
	c_give('bisque', 3)
	c_give('jellyopop', 3)
	c_give('ceviche', 3)
	c_give('surfnturf', 3)
	c_give('lobsterbisque', 3)
	c_give('lobsterdinner', 3)
end

function c_sounddebug ( filter )
	if not package.loaded["debugsounds"] then
		require "debugsounds"
	end

	SOUNDDEBUG_ENABLED = true
	TheSim:SetDebugRenderEnabled(true)

	SetSoundDebug()

	if filter then
		SetEventSoundFilter(filter)
	end
end

-- CS stands for sounddebug
function cs_on(filter)
	c_sounddebug(filter)
end

function cs_off()
	SOUNDDEBUG_ENABLED = false
	ResetSoundDebug()
end

function cs_toggle()
	if SOUNDDEBUG_ENABLED then
		cs_off()
	else
		cs_on()
	end
end

function cs_prefab ( prefab )
	SetPrefabSoundFilter( prefab )
end

function cs_filter (filter)
	SetEventSoundFilter( filter )
end

function cs_entity (guid)
	SetEntitySoundFilter(guid)
end

function cs_sel()
	if c_sel() then
		cs_entity(c_sel().entity:GetGUID())
	end
end

function c_repeatlastcommand()
    local history = GetConsoleHistory()
    if #history > 0 then
        if history[#history] == "c_repeatlastcommand()" then
            -- top command is this one, so we want the second last command
            history[#history] = nil
        end
        ExecuteConsoleCommand(history[#history])
    end
end

function c_packim()
	c_warp('packim_fishbone')
	c_give('fish', 12)
	c_give('obsidian', 40)
end

function c_mapstats()
	local map = GetWorld().Map
	local ground = {}

	for k,v in pairs(GROUND) do
		ground[v] = 0
	end

	local width, height = map:GetSize()
	for y = 0, height, 1 do
		for x = 0, width, 1 do
			local g = map:GetTile(x, y)
			if ground[g] then
				ground[g] = ground[g] + 1
			end
		end
	end

	local totaltiles = width * height
	local totalwater = 0
	local totalland = 0
	for k,v in pairs(ground) do
		if map:IsWater(k) then
			totalwater = totalwater + ground[k]
		else
			totalland = totalland + ground[k]
		end
	end

	print("Map Stats")
	print(string.format("  Shallow    \t%d\t(%4.4f%%)", ground[GROUND.OCEAN_SHALLOW], ground[GROUND.OCEAN_SHALLOW] / totaltiles * 100))
	print(string.format("  Shore      \t%d\t(%4.4f%%)", ground[GROUND.OCEAN_SHORE], ground[GROUND.OCEAN_SHORE] / totaltiles * 100))
	print(string.format("  Medium     \t%d\t(%4.4f%%)", ground[GROUND.OCEAN_MEDIUM], ground[GROUND.OCEAN_MEDIUM] / totaltiles * 100))
	print(string.format("  Deep       \t%d\t(%4.4f%%)", ground[GROUND.OCEAN_DEEP], ground[GROUND.OCEAN_DEEP] / totaltiles * 100))
	print(string.format("  Coral      \t%d\t(%4.4f%%)", ground[GROUND.OCEAN_CORAL], ground[GROUND.OCEAN_CORAL] / totaltiles * 100))
	print(string.format("  Coral Shore\t%d\t(%4.4f%%)", ground[GROUND.OCEAN_CORAL_SHORE], ground[GROUND.OCEAN_CORAL_SHORE] / totaltiles * 100))
	print(string.format("  Mangrove   \t%d\t(%4.4f%%)", ground[GROUND.MANGROVE], ground[GROUND.MANGROVE] / totaltiles * 100))
	print(string.format("  Mangrove Sh\t%d\t(%4.4f%%)", ground[GROUND.MANGROVE_SHORE], ground[GROUND.MANGROVE_SHORE] / totaltiles * 100))
	print(string.format("  Impassible \t%d\t(%4.4f%%)", ground[GROUND.IMPASSABLE], ground[GROUND.IMPASSABLE] / totaltiles * 100))
	print(string.format("  Total water\t%d\t(%4.4f%%)", totalwater, totalwater / totaltiles * 100))
	print(string.format("  Total land \t%d\t(%4.4f%%)", totalland, totalland / totaltiles * 100))
	print(string.format("  Total tiles\t%d", totaltiles))
end

function c_playslots()
	c_warp('slotmachine')
	c_give('dubloon',30)
end

function c_regenwater(data)
	print("Water regen...")
	local map = GetWorld().Map
	local width, height = map:GetSize()

	--clear water
	for y = 0, height, 1 do
		for x = 0, width, 1 do
			local tile = map:GetTile(x, y)
			if tile == GROUND.MANGROVE_SHORE then
				map:SetTile(x, y, GROUND.MANGROVE)
			elseif map:IsWater(tile) and tile ~= GROUND.MANGROVE then
				map:SetTile(x, y, GROUND.IMPASSABLE)
			end
		end
	end

	WorldSim:SetTileMap(map:GetTileMap()) --so so hacky

	require("map/water")
	if type(data) == "table" then
		ConvertImpassibleToWater(width, height, data)
	elseif type(data) == "string" then
		ConvertImpassibleToWater(width, height, require(data))
		package.loaded[data] = nil
	else
		ConvertImpassibleToWater(width, height, require("map/watergen"))
		package.loaded["map/watergen"] = nil
	end

	AddShoreline(width, height)

	print("Rebuild...")

	local tiles =
	{
		GROUND.OCEAN_SHALLOW, GROUND.OCEAN_MEDIUM, GROUND.OCEAN_DEEP, GROUND.OCEAN_CORAL, GROUND.MANGROVE,
		GROUND.OCEAN_SHIPGRAVEYARD, GROUND.JUNGLE, GROUND.BEACH, GROUND.MAGMAFIELD, GROUND.TIDALMARSH,
		GROUND.MEADOW, GROUND.IMPASSABLE
	}
	map:Finalize(1, COLLISION_TYPE.WATER)
	
	local minimap = TheSim:FindFirstEntityWithTag("minimap")
	if minimap then
		for i = 1, #tiles, 1 do
			minimap.MiniMap:RebuildLayer( tiles[i], 2, 2 )
		end
	end

	c_mapstats()

	WorldSim:SetTileMap(nil)

	print("Water regen done.")
end

function c_selectnear(prefab, rad)
    local player = GetPlayer()
    local x,y,z = player.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, rad or 30)
    local closest = nil
    local closeness = nil
    for k,v in pairs(ents) do
        if v.prefab == prefab then
            if closest == nil or player:GetDistanceSqToInst(v) < closeness then
                closest = v
                closeness = player:GetDistanceSqToInst(v)
            end
        end
    end
    if closest then
        c_select(closest)
    end
end

function c_skipdays(num)
	LongUpdate(TUNING.TOTAL_DAY_TIME * num, true)
end

function c_setlightningflashenabled(enabled)
	GetWorld().components.clock:SetLightningFlashEnabled(enabled)
end 

function c_kraken()
	GetPlayer().components.krakener:DoKrakenEvent(true)
end

function c_removeallwithtags(...)
    local count = 0
    for k,ent in pairs(Ents) do
        for i,tag in ipairs(arg) do
            if ent:HasTag(tag) then
                ent:Remove()
                count = count + 1
                break
            end
        end
    end
    print("removed",count)
end

function c_removeall(name)
    local count = 0
    for k,ent in pairs(Ents) do
        if ent.prefab == name then
            ent:Remove()
            count = count + 1
        end
    end
    print("removed",count)
end


function c_tryexitblackroom()
	local world = GetWorld()
	if world and world.components and world.components.interiorspawner then
		local room = world.components.interiorspawner.current_interior
		if room then
			local roomname = room.dungeon_name
			local doorname = room.dungeon_name.."_door"
			local alt_doorname = room.dungeon_name.."_ENTRANCE1"
			for i,v in pairs(Ents) do
				if v.components and v.components.door then
					if v.components.door.door_id == doorname or v.components.door.door_id == alt_doorname then
						world.components.interiorspawner:PlayTransition(GetPlayer(), nil, nil, v)	
						break
					end
				end
			end
		end
	end
end

function StopHammerTime()
	local removeFromGround = {SUBURB = true, FIELDS = true, FOUNDATION = true, COBBLEROAD = true, LAWN = true, INVALID = true}
	local removed = 0
	local ignored = 0
	print("Removing stray hammers")
	for i,v in pairs(Ents) do
		if v.prefab == "hammer" and not v:IsInLimbo() then
			local floor = GetGroundTypeAtPosition(v:GetPosition())
			for i,v in pairs(GROUND) do
				if v == floor then
					floor = i
					break
				end
			end
			if removeFromGround[floor] then
				print("   Removing hammer ",v,"on groundtype",floor,"at position",v:GetPosition())
				v:Remove()
				removed = removed + 1
			else
				print("   Ignoring hammer ",v,"on groundtype",floor,"at position",v:GetPosition())
				--print(i, v, floor, v:GetPosition())
				ignored = ignored + 1
			end
		end
	end
	print(string.format("Removed %d hammers, kept %d.",removed, ignored))
end

function SubmitProfile()
    TheFrontEnd.consoletext.closeonrun = true
    local runner = GetWorld() or TheFrontEnd.screenroot.inst
    if runner then
        runner:DoTaskInTime(0, ShowBugReportPopup)
    end
end

function ListAwakeEntities()
	local count = 0
	local counts = {}
	for i,v in pairs(Ents) do
		if v.entity:IsAwake() then
			if v.prefab then
				counts[v.prefab] = (counts[v.prefab] or 0) + 1
				--count = count + 1
				--print(count,i,v)
			end
		end
	end
	for i,v in pairs(counts) do
		print(i,v)
	end
end

function c_unlockdoor()
	local player = GetPlayer()
	if player then
		local pt = player:GetPosition()
		print("pt = ",pt)
		local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 5, {"lockable_door"})
		local door = ents[1]
		if door and door.prefab == "prop_door" then
			door:opendoor(true)
		end
	end
end

function c_interiorinfo()
	local interiorSpawner = GetInteriorSpawner()
	local currentInterior = interiorSpawner.current_interior
	if currentInterior then
		local interior = interiorSpawner.interiors[currentInterior.unique_name]
		print("Current interior:",interior.unique_name)
		print("Current dungeon:", interior.dungeon_name)
		if interiorSpawner.player_homes[interior.dungeon_name] then
			local roomInfo = interiorSpawner.player_homes[interior.dungeon_name][interior.unique_name] 
			print("grid position:",roomInfo.x, roomInfo.y)
		end
	end
end

-- Nuke any controller mappings, for when people get in a hairy situation with a controller mapping that is totally busted.
function ResetControllersAndQuitGame()
    print("ResetControllersAndQuitGame requested")
    if not InGamePlay() then
	-- Nuke any controller configurations from our profile
	-- and clear the setting in the ini file
	TheSim:SetSetting("misc", "controller_popup", tostring(nil))
	Profile:SetValue("controller_popup",nil)
	Profile:SetValue("controls",{})
	Profile:Save()
	-- And quit the game, we want a restart
	RequestShutdown()	
    else
	print("ResetControllersAndQuitGame can only be called from the frontend")
    end
end
