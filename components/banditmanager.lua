	local BAT_SPAWN_DIST = 5



local Banditmanager = Class(function(self, inst)
    self.inst = inst    
	self.tickperiod = 10
   	self.bandit = nil
   	self.deathtimeMax = 30 * 16 * 1.5
   	self.deathtime = 0   
   	self.loot = {}
    self.task = self.inst:DoPeriodicTask(self.tickperiod, function() self:OnPeriodicUpdate() end)
    self.disabled = false
    self.diffmod = 1
end)


function Banditmanager:OnSave()	
	local refs = {}
	local data = {}

	if self.disabled then
		data.disabled = self.disabled
	end
	if self.banditactive then
		data.banditactive = self.banditactive
	end
	if self.deathtime then
		data.deathtime = self.deathtime
	end
	if self.bandit then
		data.bandit = self.bandit.GUID
		table.insert(refs,self.bandit.GUID)
	end

	if self.loot then
		data.loot = self.loot
	end

	--if self.treasure then
--		data.treasure = self.treasure.GUID
		--table.insert(refs,self.treasure.GUID)
	--end
	return data, refs
end 

function Banditmanager:OnLoad(data)
	if data.disabled then
		self.disabled = data.disabled
	end
	if data.banditactive then
		self.banditactive = data.banditactive
	end
	if data.deathtime then
		self.deathtime = data.deathtime
	end
	if data.loot then
		self.loot = data.loot
	end
end 

function Banditmanager:LoadPostPass(ents, data)
	if data.bandit and ents[data.bandit] then
		self.bandit = ents[data.bandit].entity
	end
	--if data.treasure then
--		self.treasure = ents[data.treasure].entity
	--end	
end

function Banditmanager:deactivatebandit(bandit,killed)
	self.banditactive = nil

	local loot = bandit.components.inventory:GetItems(function(k,v) 
			local ok = false
			if v.oincvalue then
				ok = true
			end
			return ok
		end)

	if killed then 
		--self.loot = {}
		self.deathtime = self.deathtimeMax
		self.bandit = nil
	else
		bandit.components.health:SetPercent(1)
		bandit.attacked = nil
		for i,item in ipairs(loot)do
			bandit.components.inventory:RemoveItem(item,true)
			if not self.loot[item.prefab] then
				if item.components.stackable then
					self.loot[item.prefab] = item.components.stackable:StackSize()
				else
					self.loot[item.prefab] = 1
				end
			else
				if item.components.stackable then
					self.loot[item.prefab] = self.loot[item.prefab] + item.components.stackable:StackSize()
				else
					self.loot[item.prefab] = self.loot[item.prefab] + 1
				end
			end			
		end
	end
end


function Banditmanager:GetLoot()
	local temploot = {}

	local treasurelist = {
		{	
			weight = 5,
			loot = {
				tunacan = 4,
				oinc10 = 1,
				meat_dried = 2,		
			},
		},
		
		{	
			weight = 3,
			loot = {
				goldnugget = 4,
				alloy = 1,
				meat_dried = 2,
				oinc = 5,
			},
		},

		{	
			weight = 3,
			loot = {
				trinket_17 = 1,
				oinc = 5,
				sewing_kit = 1,		
				telescope = 1,
				meat_dried = 1,
			},
		},	

		{	
			weight = 2,
			loot = {
				meat_dried = 2,
				oinc = 15,	
				drumstick = 2,
				oinc10 = 1,				
			},
		},

		{	
			weight = 2,
			loot = {
				armor_metalplate = 1,
				halberd = 1,	
				metalplatehat = 1,
				oinc = 15,	
			},
		},

		{	
			weight = 1,
			loot = {
				drumstick = 2,
				oinc = 15,	
				oinc10 = 2,
				tunacan = 1,
				monstermeat = 1,
			},
		},						
	}	

	local range = 0

	for i,set in ipairs(treasurelist) do
		range = range + set.weight
	end

	local final = math.random(1,range)
	print("BANDIT MAP", range,final)
	range = 0
	for i,set in ipairs(treasurelist) do

		range = range + set.weight
		print("range",range)
		if range >= final then
			for p,n in pairs(set.loot) do
				if not temploot[p] then
					temploot[p] = n
				else
					temploot[p] = temploot[p] +n
				end
			end
			break
		end
	end	

	for p, n in pairs(self.loot) do		
		if not temploot[p] then			
			temploot[p] = n
		else
			temploot[p] = temploot[p] +n
		end
	end
	return temploot 
end

function Banditmanager:SpawnTreasureChest(pt)
	
		local chest = SpawnPrefab("treasurechest")
		if chest then
			chest.Transform:SetPosition(pt.x, pt.y, pt.z)
			SpawnPrefab("collapse_small").Transform:SetPosition(pt.x, pt.y, pt.z)

			if chest.components.container then
				
				local player = GetPlayer()
				local lootprefabs = self:GetLoot()

				for p, n in pairs(lootprefabs) do
					for i = 1, n, 1 do
						local loot = SpawnPrefab(p)
						if loot.components.inventoryitem and not loot.components.container then
							chest.components.container:GiveItem(loot, nil, nil, true, false)
						else
							local pos = Vector3(pt.x, pt.y, pt.z)
							local start_angle = math.random()*PI*2
							local rad = 1
							if chest.Physics then
								rad = rad + chest.Physics:GetRadius()
							end
							local offset = FindWalkableOffset(pos, start_angle, rad, 8, false)
							if offset == nil then
								return
							end

							pos = pos + offset

							loot.Transform:SetPosition(pos.x, pos.y, pos.z)
							-- attacker?
							if loot.components.combat then
								loot.components.combat:SuggestTarget(player)
							end
						end
					end
				end
			else
				SpawnTreasureLoot(name, lootdropper, pt)
			end
		end
		self.loot = {}
end

function Banditmanager:GenerateTreasure(bandit)
	local pos = GetPlayer():GetPosition()
	local offset = FindGroundOffset(pos, math.random() * 2 * math.pi, math.random(120, 200), 18)

	if offset then
		print("OFFSET FOUND")
		local spawn_pos = pos + offset
	    local tile = GetVisualTileType(spawn_pos:Get())
		local is_water = GetMap():IsWater(tile)
		local treasure = SpawnPrefab("bandittreasure")

		self.treasure = treasure

		treasure.Transform:SetPosition(spawn_pos:Get())
		--treasure:SetRandomTreasure()

		local map = SpawnPrefab("banditmap")
		map.treasure = treasure
		map.treasureguid = treasure.GUID

		bandit.components.inventory:GiveItem(map)
	end
end

function Banditmanager:HandleManualSpawn(inst)
	if self.bandit then
		local map = self.bandit.components.inventory:FindItem(function(item)
				return item.prefab == "banditmap"
			end)

		if map then
			inst.components.inventory:GiveItem(map)
		end
		self.bandit:Remove()
		self.bandit = nil

		self.bandit = inst
	else
		self.bandit = inst
		self:GenerateTreasure(inst)
	end
	self.banditactive = true
end

function Banditmanager:CreateBanditAndTreasurePrefab()
	local bandit = SpawnPrefab("pigbandit")

	self:GenerateTreasure(bandit)

	return bandit
end

function Banditmanager:spawnbandit()

	local x,y,z = GetPlayer().Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x,y,z, 40,{"bandit_cover"})

	if #ents > 0 then
		print("FINDING COVER")
		local cover = ents[math.random(1,#ents)]
		--[[
		local cover = nil
		local finaldist = 9999999
		for i, ent in ipairs(ents)do
			local dist = GetPlayer():GetDistanceSqToInst(ent)			
			if dist < finaldist then
				cover = ent
				finaldist = dist
			end
		end
		]]
		if cover then

			self.banditactive = true
			if not self.bandit then
				self.bandit = self:CreateBanditAndTreasurePrefab()
			else
				self.bandit:ReturnToScene()
			end
			local x,y,z = cover.Transform:GetWorldPosition()

	        local angle = TheCamera.headingtarget         
	        x = x - 1*math.cos(angle)
	        z = z - 1*math.sin(angle)

			self.bandit.Transform:SetPosition(x,0,z)
		end
	end
end

function Banditmanager:SetDiffMod(diff)
	self.diffmod = diff
end

function Banditmanager:LongUpdate(dt)
	local cycles = math.floor(dt/self.tickperiod)
	local remainder = dt%self.tickperiod

	if cycles > 0 then
		for i=1,cycles do
			self:OnPeriodicUpdate()
		end
	end
	if remainder > 0 then
		self:OnPeriodicUpdate(remainder)
	end
end

function Banditmanager:OnPeriodicUpdate(dt)
	if not self.disabled then		
		if self.deathtime > 0 then
			local time = dt or self.tickperiod
			self.deathtime = self.deathtime - self.tickperiod
			print("DEATH TIME REMAINING",self.deathtime)
		else 
			if not self.banditactive then
				local player = GetPlayer()

				local pt = Vector3(player.Transform:GetWorldPosition())
				local tiletype = GetGroundTypeAtPosition(pt)
				if tiletype == GROUND.SUBURB or tiletype == GROUND.COBBLEROAD or tiletype == GROUND.FOUNDATION or tiletype == GROUND.LAWN then	

					local value = 0
					if player.components.inventory then
						for k,item in pairs(player.components.inventory.itemslots) do						
							local mult = 1
							if item.components.stackable then
								mult = item.components.stackable:StackSize()
							end
							if item.oincvalue then
								value = value + (item.oincvalue * mult)
							end
						end

					    if player.components.inventory.overflow and player.components.inventory.overflow.components.container then
					        for k,item in pairs(player.components.inventory.overflow.components.container.slots) do
								local mult = 1
								if item.components.stackable then
									mult = item.components.stackable:StackSize()
								end
								if item.oincvalue then
									value = value + (item.oincvalue * mult)
								end
					        end					        
					    end

					end

					if GetWorld().components.clock:IsDusk() then
						value = value *1.5
					end
					if GetWorld().components.clock:IsNight() then
						value = value *3
					end		

					local chance = 1/100
					if value >= 150 then
						chance = 1/5
					elseif value >= 100 then
						chance = 1/10
					elseif value >= 50 then
						chance = 1/20
					elseif value >= 10 then
						chance = 1/40
					elseif value == 0 then
						chance = 0					
					end

					local roll = math.random()
					chance = chance * self.diffmod
					print("CHANCE", chance, roll, value)
					if roll < chance then
						self:spawnbandit()				
					end
				end
			end 
		end
	end
end  

return Banditmanager