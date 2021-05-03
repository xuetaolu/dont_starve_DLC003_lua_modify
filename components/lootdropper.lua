local LootDropper = Class(function(self, inst)
	self.inst = inst
	self.numrandomloot = nil
	self.externalloot = nil -- Done exclusively to fix instances of SpawnLootPrefab to work with the wheeler_tracker
	self.randomloot = nil
	self.chancerandomloot = nil
	self.totalrandomweight = nil
	self.chanceloot = nil
	self.ifnotchanceloot = nil
	self.droppingchanceloot = false
	self.loot = nil
	self.chanceloottable = nil
	self.trappable = true
	self.speed = nil
end)

LootTables = {}
function SetSharedLootTable(name, table)
	LootTables[name] = table
end

function LootDropper:SetChanceLootTable(name)
	self.chanceloottable = name
end

function LootDropper:SetLoot( loots )
	self.loot = loots
	self.chanceloot = nil
	self.randomloot = nil
	self.numrandomloot = nil
end

function LootDropper:AddLoot(prefab)
	if not self.loot then
		self.loot = {}
	end
	table.insert(self.loot, prefab)
end

function LootDropper:AddExternalLoot(prefab)
	if not self.externalloot then
		self.externalloot = {}
	end
	table.insert(self.externalloot, prefab)
end

function LootDropper:ClearRandomLoot()
	if self.randomloot then
		self.randomloot = {}
		self.totalrandomweight = 0
	end
end

function LootDropper:AddRandomLoot( prefab, weight)
	if not self.randomloot then
		self.randomloot = {}
		self.totalrandomweight = 0
	end
	
	table.insert(self.randomloot, {prefab=prefab,weight=weight} )
	self.totalrandomweight = self.totalrandomweight + weight
end

function LootDropper:AddChanceLoot( prefab, chance)
	if not self.chanceloot then
		self.chanceloot = {}
	end
	table.insert(self.chanceloot, {prefab=prefab,chance=chance} )
end

function LootDropper:AddIfNotChanceLoot(prefab)
	if not self.ifnotchanceloot then
		self.ifnotchanceloot = {}
	end
	table.insert(self.ifnotchanceloot, {prefab=prefab})
end

function LootDropper:PickRandomLoot()
	if self.totalrandomweight and self.totalrandomweight > 0 and self.randomloot then
		local rnd = math.random()*self.totalrandomweight
		for k,v in pairs(self.randomloot) do
			rnd = rnd - v.weight
			if rnd <= 0 then
				return v.prefab
			end
		end
	end
end

function LootDropper:GetPotentialLoot()
	local total_loot = {}

	if self.loot then
		for i,v in ipairs(self.loot) do
			table.insert(total_loot, v)
		end
	end

	if self.externalloot then
		for i,v in ipairs(self.externalloot) do
			table.insert(total_loot, v)
		end
	end

	if self.randomloot then
		for i,v in ipairs(self.randomloot) do
			if v.weight >=  4 * (self.totalrandomweight/10) then -- If the weight is bigger than 80%
				table.insert(total_loot, v.prefab)
			end
		end
	end

	if self.chanceloot then
		for i,v in ipairs(self.chanceloot) do
			if v.chance >= 1 then
				table.insert(total_loot, v.prefab)
			end
		end
	end

	if self.chanceloottable and LootTables[self.chanceloottable] then		
		for k,v in pairs(LootTables[self.chanceloottable]) do
			if v[2] >= 0.8 then -- If the weight is bigger than 80%
				table.insert(total_loot, v[1])
			end
		end
	end	

	return total_loot
end

function LootDropper:GetAllLoot()
	local total_loot = {}

	if self.randomloot then
		for k,v in pairs(self.randomloot) do
			table.insert(total_loot, v.prefab)
		end
	end
	
	if self.chanceloot then
		for k,v in pairs(self.chanceloot) do
			table.insert(total_loot, v.prefab)
		end
	end

	if self.chanceloottable and LootTables[self.chanceloottable] then
		for k,v in pairs(LootTables[self.chanceloottable]) do
			table.insert(total_loot, v[1])
		end
	end
	
	if self.ifnotchanceloot then
		for k,v in pairs(self.ifnotchanceloot) do
			table.insert(total_loot, v.prefab)
		end
	end

	if self.loot then
		for i,v in ipairs(self.loot) do
			table.insert(total_loot, v)
		end
	end
	
	local recipename = self.inst.prefab
	if self.inst.recipeproxy then
		recipename = self.inst.recipeproxy
	end

	local recipe = GetRecipe(recipename)

	if recipe then

		for k,v in ipairs(recipe.ingredients) do
			table.insert(total_loot, v.type)
		end

		if self.inst:HasTag("burnt") then
			table.insert(total_loot, "charcoal") 
		end
	end

	return total_loot
end

function LootDropper:GenerateLoot()
	local loots = {}
	
	if self.numrandomloot and math.random() <= (self.chancerandomloot or 1) then
		for k = 1, self.numrandomloot do
			local loot = self:PickRandomLoot()
			if loot then
				table.insert(loots, loot)
			end
		end
	end
	
	if self.chanceloot then
		for k,v in pairs(self.chanceloot) do
			if math.random() < v.chance then
				table.insert(loots, v.prefab)
				self.droppingchanceloot = true
			end
		end
	end

	if self.chanceloottable then
		local loot_table = LootTables[self.chanceloottable]
		if loot_table then
			for i, entry in ipairs(loot_table) do
				local prefab = entry[1]
				local chance = entry[2]
				if math.random() <= chance then
					table.insert(loots, prefab)
					self.droppingchanceloot = true
				end
			end
		end
	end

	if not self.droppingchanceloot and self.ifnotchanceloot then
		self.inst:PushEvent("ifnotchanceloot")
		for k,v in pairs(self.ifnotchanceloot) do
			table.insert(loots, v.prefab)
		end
	end

	if self.loot then
		for k,v in ipairs(self.loot) do
			table.insert(loots, v)
		end
	end
	
	local recipename = self.inst.prefab
	if self.inst.recipeproxy then
		recipename = self.inst.recipeproxy
	end

	local recipe = GetRecipe(recipename)

	if recipe then
		local percent = 1

		if self.lootpercentoverride then
			percent = self.lootpercentoverride(self.inst)
		elseif self.inst.components.finiteuses then
			percent = self.inst.components.finiteuses:GetPercent()
		end

		for k,v in ipairs(recipe.ingredients) do
			local amt = math.ceil( (v.amount * TUNING.HAMMER_LOOT_PERCENT) * percent)
			if self.inst:HasTag("burnt") then
				amt = math.ceil( (v.amount * TUNING.BURNT_HAMMER_LOOT_PERCENT) * percent)
			end
			for n = 1, amt do
				table.insert(loots, v.type)
			end
		end

		if self.inst:HasTag("burnt") and math.random() < .4 then
			table.insert(loots, "charcoal") -- Add charcoal to loot for burnt structures
		end
	end
	
	return loots
end

function LootDropper:DropLootPrefab(loot, pt, setangle, arc, alwaysinfront, dropdir)
	if loot then
		if not pt then
			pt = Point(self.inst.Transform:GetWorldPosition())
		end

		if self.inst.components.poisonable and self.inst.components.poisonable:IsPoisoned() and loot.components.perishable then
			loot.components.perishable:ReducePercent(TUNING.POISON_PERISH_PENALTY)
		end
		
		loot.Transform:SetPosition(pt.x,pt.y,pt.z)

		self.inst:ApplyInheritedMoisture(loot)
		
		if loot.Physics and not self.nojump then
		
			local angle = math.random()*2*PI

			if setangle and arc then
				arc = arc * DEGREES
				angle = setangle * DEGREES + (math.random()*arc - arc/2)
			elseif setangle then
				angle = setangle / DEGREES
			end

			if alwaysinfront then
			    local down = TheCamera:GetDownVec()				
			    angle = math.atan2(down.z, down.x) + (math.random()*60-30) * DEGREES
			end

			local speed = self.speed or 1
			speed = speed * math.random()
			loot.Physics:SetVel(speed*math.cos(angle), GetRandomWithVariance(8, 4), speed*math.sin(angle))
			if loot and loot.Physics then --and self.inst and self.inst.Physics then
				local dir = nil
				if dropdir then
					dir = dropdir
				else
					dir = Vector3(math.cos(angle), 0, math.sin(angle))
				end
				pt = pt + dir*((loot.Physics:GetRadius() or 1) + (self.inst.Physics and self.inst.Physics:GetRadius() or 0))
				loot.Transform:SetPosition(pt.x,pt.y,pt.z)
			end
		end
		if loot.components.inventoryitem then 
			loot.components.inventoryitem:OnLootDropped()
		end 
		
		return loot
	end
end

function LootDropper:SpawnLootPrefab(lootprefab, pt)
	if lootprefab then
		if GetWorld().getworldgenoptions and  GetWorld().getworldgenoptions(GetWorld())[lootprefab] and GetWorld().getworldgenoptions(GetWorld())[lootprefab] == "never" then
			return
		end
		local loot = SpawnPrefab(lootprefab)
		if self.inst.components.citypossession then
			loot:AddComponent("citypossession")
			loot.components.citypossession:SetCity(self.inst.components.citypossession.cityID)
		end
		return self:DropLootPrefab(loot, pt, self.lootdropangle, self.lootdroparc, self.alwaysinfront, self.dropdir)
	end
end

function LootDropper:CheckBurnable(prefabs)
	-- check burnable
	if not self.inst.components.fueled and self.inst.components.burnable and self.inst.components.burnable:IsBurning() then
		for k,v in pairs(prefabs) do
			local cookedAfter = v.."_cooked"
			local cookedBefore = "cooked"..v
			if PrefabExists(cookedAfter) then
				prefabs[k] = cookedAfter
			elseif PrefabExists(cookedBefore) then
				prefabs[k] = cookedBefore
			else
				prefabs[k] = "ash"
			end
		end
	end	
end

function LootDropper:DropLoot(pt, loots)
	local prefabs = loots
	if prefabs == nil then
		prefabs = self:GenerateLoot()
	end
	self:CheckBurnable(prefabs)
	for k,v in pairs(prefabs) do
		self:SpawnLootPrefab(v, pt)
	end
end

function LootDropper:ExplodeLoot(pt, speed, loots)
	local prefabs = loots
	if prefabs == nil then
		prefabs = self:GenerateLoot()
	end
	self:CheckBurnable(prefabs)
	self.oldspeed = self.speed
	self.speed = speed or 1
	for k,v in pairs(prefabs) do
		local newprefab = self:SpawnLootPrefab(v, pt)
		local vx, vy, vz = newprefab.Physics:GetVelocity()
		newprefab.Physics:SetVel(vx, 35, vz)
	end
	self.speed = self.oldspeed
end

local function SplashOceanLoot(loot, cb)
    if loot.components.inventoryitem == nil or not loot.components.inventoryitem:IsHeld() then
        local x, y, z = loot.Transform:GetWorldPosition()
        if not loot:IsOnValidGround() then
            SpawnPrefab("splash_ocean").Transform:SetPosition(x, y, z)
            if loot:HasTag("irreplaceable") then
                loot.Transform:SetPosition(FindSafeSpawnLocation(x, y, z))
            else
                loot:Remove()
            end
            return
        end
    end
    if cb ~= nil then
        cb(loot)
    end
end

function LootDropper:FlingItem(loot, pt, bouncedcb)
    if loot ~= nil then
        if pt == nil then
            pt = self.inst:GetPosition()
        end

        loot.Transform:SetPosition(pt:Get())

        if loot.Physics ~= nil then
            local angle = self.flingtargetpos ~= nil and GetRandomWithVariance(self.inst:GetAngleToPoint(self.flingtargetpos), self.flingtargetvariance or 0) * DEGREES or math.random() * 2 * PI
            local speed = math.random() * 2
            if loot:IsAsleep() then
                local radius = .5 * speed + (self.inst.Physics ~= nil and loot:GetPhysicsRadius(1) + self.inst:GetPhysicsRadius(1) or 0)
                loot.Transform:SetPosition(
                    pt.x + math.cos(angle) * radius,
                    0,
                    pt.z - math.sin(angle) * radius
                )

                SplashOceanLoot(loot, bouncedcb)
            else
                local sinangle = math.sin(angle)
                local cosangle = math.cos(angle)
                loot.Physics:SetVel(speed * cosangle, GetRandomWithVariance(8, 4), speed * -sinangle)

                if self.inst ~= nil and self.inst.Physics ~= nil then
                    local radius = loot:GetPhysicsRadius(1) + self.inst:GetPhysicsRadius(1)
                    loot.Transform:SetPosition(
                        pt.x + cosangle * radius,
                        pt.y,
                        pt.z - sinangle * radius
                    )
                end

                loot:DoTaskInTime(1, SplashOceanLoot, bouncedcb)
            end
        end
    end
end

return LootDropper
