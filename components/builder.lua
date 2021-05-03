local Builder = Class(function(self, inst)
    self.inst = inst
    self.recipes = {}
    self.recipe_count = 0
    self.accessible_tech_trees = TECH.NONE
    self.inst:StartUpdatingComponent(self)
    self.current_prototyper = nil
    self.buffered_builds = {}
    self.bonus_tech_level = 0
    self.science_bonus = 0
    self.magic_bonus = 0
    self.ancient_bonus = 0
    self.obsidian_bonus = 0
    self.home_bonus = 0    
    self.city_bonus = 0    
	self.lost_bonus = 0
    self.custom_tabs = {}
    self.ingredientmod = 1
    self.jellybrainhat = false
    
end)

function Builder:ActivateCurrentResearchMachine()
	if self.current_prototyper and 
        self.current_prototyper.components.prototyper and
        self.current_prototyper:IsValid() then 
		self.current_prototyper.components.prototyper:Activate()
	end
end

function Builder:AddRecipeTab(tab)
	table.insert(self.custom_tabs, tab)
end

function Builder:OnSave()
	local data =
	{
		buffered_builds = self.buffered_builds
	}
	
	data.recipes = self.recipes

	return data
end

function Builder:OnLoad(data)
    if data.buffered_builds then
		self.buffered_builds = data.buffered_builds
    end
    
	if data.recipes then
		for k, v in pairs(data.recipes) do
			self:AddRecipe(v)
		end
	end
end

function Builder:IsBuildBuffered(recipe)
	return self.buffered_builds[recipe] ~= nil
end

-- Assing recipies to their recipecategories
-- so we can do some lookups based on that
function Builder:PrepareCategories()
	local recipes = GetAllRecipes()
	local count = 0
	self.categoryMapping = {}
	for _, recipe in pairs(recipes) do
		local tab = recipe.tab
		if tab then
			self.categoryMapping[tab] = self.categoryMapping[tab] or {}
			self.categoryMapping[tab][recipe.name] = recipe
		end
	end
end

function Builder:IsCategoryBuildBuffered(category)
	-- seemed smarter
	assert(self.categoryMapping)
	local categoryRecipes = self.categoryMapping[category]
	if categoryRecipes then
		for _, recipe in pairs(categoryRecipes) do
			if self:IsBuildBuffered(recipe.name) then
				return true
			end
		end
	end
	return false
end

function Builder:IsCategoryResearchable(category)
	assert(self.categoryMapping)

	local current_research_level = self.accessible_tech_trees or NO_TECH
	local categoryRecipes = self.categoryMapping[category]
	if categoryRecipes then
		for _, recipe in pairs(categoryRecipes) do
			local has_researched = self:KnowsRecipe(recipe.name)

			local can_build = self:CanBuild(recipe.name)
			local can_research = not has_researched and can_build and CanPrototypeRecipe(recipe.level, current_research_level)
			if can_research and not recipe.nounlock then
				return true
			end
		end
	end
	return false
end

function Builder:BufferBuild(recipe)
	local mats = self:GetIngredients(recipe)
	local wetLevel = self:GetIngredientWetness(mats)	
	self:RemoveIngredients(mats,recipe)
	self.buffered_builds[recipe] = {}
	self.buffered_builds[recipe].wetLevel = wetLevel
	self.inst:PushEvent("bufferbuild", {recipe = GetRecipe(recipe)})
end

function Builder:OnUpdate(dt)
	self:EvaluateTechTrees()
    self:EvaluateAutoFixers()
end

function Builder:GiveAllRecipes()
    if self.freebuildmode then
    	self.freebuildmode = false
    else
    	self.freebuildmode = true
    end
    self.inst:PushEvent("unlockrecipe")
end

function Builder:UnlockRecipesForTech(tech)
	local propertech = function(recipetree, buildertree)
	    for k, v in pairs(recipetree) do
	        if buildertree[tostring(k)] and recipetree[tostring(k)] and
	        recipetree[tostring(k)] > buildertree[tostring(k)] then
	                return false
	        end
	    end
	    return true
	end

	local recipes = GetAllRecipes()
	for k, v in pairs(recipes) do
		if propertech(v.level, tech) then
			self:UnlockRecipe(v.name)
		end
	end
end

function Builder:CanBuildAtPoint(pt, recipe)

	local ground = GetWorld()
    local tile = GROUND.GRASS
    if ground and ground.Map then
        tile = ground.Map:GetTileAtPoint(pt:Get())
    end

    local onWater = ground.Map:IsWater(tile)
    local boating = self.inst.components.driver and self.inst.components.driver.driving

    local x, y, z = pt:Get()
    if(recipe.aquatic)  then --This thing needs to be built in water 

    	if boating then 
    		local minBuffer = 2
    		local testTile = ground.Map:GetTileAtPoint(x + minBuffer, y, z)
	    	onWater = ground.Map:IsWater(testTile) and onWater
	    	testTile = ground.Map:GetTileAtPoint(x - minBuffer, y, z)
	    	onWater = ground.Map:IsWater(testTile) and onWater
	    	testTile = ground.Map:GetTileAtPoint(x , y, z + minBuffer)
	    	onWater = ground.Map:IsWater(testTile) and onWater
	    	testTile = ground.Map:GetTileAtPoint(x , y, z - minBuffer)
	    	onWater = ground.Map:IsWater(testTile) and onWater
	    	return onWater
    	else 
    		local testTile = self.inst:GetCurrentTileType(x, y, z)--ground.Map:GetTileAtPoint(x , y, z)
    		local isShore = ground.Map:IsShore(testTile) --testTile == GROUND.OCEAN_SHORE --ground.Map:IsWater(testTile)
    		--[[
    		testTile = self.inst:GetCurrentTileType(x + buffer, y, z)--ground.Map:GetTileAtPoint(x , y, z)
    		isShore = isShore and testTile == GROUND.OCEAN_SHORE --ground.Map:IsWater(testTile)
    		testTile = self.inst:GetCurrentTileType(x - buffer, y, z)--ground.Map:GetTileAtPoint(x , y, z)
    		isShore = isShore and testTile == GROUND.OCEAN_SHORE --ground.Map:IsWater(testTile)
    		testTile = self.inst:GetCurrentTileType(x, y, z+ buffer)--ground.Map:GetTileAtPoint(x , y, z)
    		isShore = isShore and testTile == GROUND.OCEAN_SHORE --ground.Map:IsWater(testTile)
    		testTile = self.inst:GetCurrentTileType(x, y, z - buffer)--ground.Map:GetTileAtPoint(x , y, z)
    		isShore = isShore and testTile == GROUND.OCEAN_SHORE --ground.Map:IsWater(testTile)
    		return isShore
    		]]
    		local maxBuffer = 2
    		local nearShore = false 
    		testTile = self.inst:GetCurrentTileType(x + maxBuffer, y, z)
    		nearShore = (not ground.Map:IsWater(testTile)) or nearShore
    		testTile = self.inst:GetCurrentTileType(x - maxBuffer, y, z)
    		nearShore = (not ground.Map:IsWater(testTile)) or nearShore
    		testTile = self.inst:GetCurrentTileType(x , y, z + maxBuffer)
    		nearShore = (not ground.Map:IsWater(testTile)) or nearShore
    		testTile = self.inst:GetCurrentTileType(x , y, z - maxBuffer)
    		nearShore = (not ground.Map:IsWater(testTile)) or nearShore

    		testTile = self.inst:GetCurrentTileType(x + maxBuffer, y, z + maxBuffer)
    		nearShore = (not ground.Map:IsWater(testTile)) or nearShore
    		testTile = self.inst:GetCurrentTileType(x - maxBuffer, y, z + maxBuffer)
    		nearShore = (not ground.Map:IsWater(testTile)) or nearShore
    		testTile = self.inst:GetCurrentTileType(x + maxBuffer , y, z - maxBuffer)
    		nearShore = (not ground.Map:IsWater(testTile)) or nearShore
    		testTile = self.inst:GetCurrentTileType(x - maxBuffer , y, z - maxBuffer)
    		nearShore = (not ground.Map:IsWater(testTile)) or nearShore

    		local minBuffer = 0.5
			if recipe.name == "ballphinhouse" then
				minBuffer = 100
			end

    		local tooClose = false 
    		testTile = self.inst:GetCurrentTileType(x + minBuffer, y, z)
    		tooClose = (not ground.Map:IsWater(testTile)) or tooClose
    		testTile = self.inst:GetCurrentTileType(x - minBuffer, y, z)
    		tooClose = (not ground.Map:IsWater(testTile)) or tooClose
    		testTile = self.inst:GetCurrentTileType(x , y, z + minBuffer)
    		tooClose = (not ground.Map:IsWater(testTile)) or tooClose
    		testTile = self.inst:GetCurrentTileType(x , y, z - minBuffer)
    		tooClose = (not ground.Map:IsWater(testTile)) or tooClose

    		testTile = self.inst:GetCurrentTileType(x + minBuffer, y, z + minBuffer)
    		tooClose = (not ground.Map:IsWater(testTile)) or tooClose
    		testTile = self.inst:GetCurrentTileType(x - minBuffer, y, z + minBuffer)
    		tooClose = (not ground.Map:IsWater(testTile)) or tooClose
    		testTile = self.inst:GetCurrentTileType(x + minBuffer , y, z - minBuffer)
    		tooClose = (not ground.Map:IsWater(testTile)) or tooClose
    		testTile = self.inst:GetCurrentTileType(x - minBuffer, y, z - minBuffer)
    		tooClose = (not ground.Map:IsWater(testTile)) or tooClose

            -- PORKLAND EDIT
            if testTile ==  GROUND.LILYPOND then
                isShore = true
            end

            -- if not (isShore and nearShore and not tooClose) then
            --     print("JAMES_DEBUG: CAN BUILD AT POINT isShore and nearShore and not tooClose")
            -- end

    		return isShore and nearShore and not tooClose
    	end 
                
        --return false
    	--return (boating and ) or testTile == GROUND.OCEAN_SHORE
    end 

    	--[[
    	local x, y, z = pt:Get()
    	local minBuffer = 2
    	--Make sure this position is also surounded by water on each side by the distance of buffer 
    	
    	local testTile = ground.Map:GetTileAtPoint(x + minBuffer, y, z)
    	onWater = ground.Map:IsWater(testTile) and onWater
    	testTile = ground.Map:GetTileAtPoint(x - minBuffer, y, z)
    	onWater = ground.Map:IsWater(testTile) and onWater
    	testTile = ground.Map:GetTileAtPoint(x , y, z + minBuffer)
    	onWater = ground.Map:IsWater(testTile) and onWater
    	testTile = ground.Map:GetTileAtPoint(x , y, z - minBuffer)
    	onWater = ground.Map:IsWater(testTile) and onWater

    	if(not boating) then --If we're not in the boat make sure the build point is close to shore 
    		local maxBuffer = 5
    		local nearShore = false 
    		testTile = ground.Map:GetTileAtPoint(x + maxBuffer, y, z)
    		nearShore = (not ground.Map:IsWater(testTile)) or nearShore
    		testTile = ground.Map:GetTileAtPoint(x - maxBuffer, y, z)
    		nearShore = (not ground.Map:IsWater(testTile)) or nearShore
    		testTile = ground.Map:GetTileAtPoint(x , y, z + maxBuffer)
    		nearShore = (not ground.Map:IsWater(testTile)) or nearShore
    		testTile = ground.Map:GetTileAtPoint(x , y, z - maxBuffer)
    		nearShore = (not ground.Map:IsWater(testTile)) or nearShore

    		if not nearShore then 
    			return false 
    		end 
    	end 
	
    	if not onWater then 
    		return false 
    	end
    elseif onWater then 
    	return false 
    end 
    ]]
    if TheCamera.interior and not recipe.wallitem then
        local interiorSpawner = GetWorld().components.interiorspawner 
        if interiorSpawner.current_interior then
            local originpt = interiorSpawner:getSpawnOrigin()
            local width = interiorSpawner.current_interior.width
            local depth = interiorSpawner.current_interior.depth        
            local dMax = originpt.x + depth/2
            local dMin = originpt.x - depth/2

            local wMax = originpt.z + width/2
            local wMin = originpt.z - width/2 
            local inbounds = true
            
            local dist = 1

            if pt.x < dMin+dist or pt.x > dMax -dist or pt.z < wMin+dist or pt.z > wMax-dist then
                return false
            end
        end
    end

	if tile == GROUND.IMPASSABLE or (boating and not recipe.aquatic) then
		return false
	else
        if recipe.decor then
            return true
        else
    		local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 6, nil, {'player', 'fx', 'NOBLOCK'}) -- or we could include a flag to the search?
    		for k, v in pairs(ents) do
    			if v ~= self.inst and (not v.components.placer) and v.entity:IsVisible() and not (v.components.inventoryitem and v.components.inventoryitem.owner) then
    				local min_rad = recipe.min_spacing or 2+1.2
    				--local rad = (v.Physics and v.Physics:GetRadius() or 1) + 1.25

    				--stupid finalling hack because it's too late to change stuff
    				if recipe.name == "treasurechest" and v.prefab == "pond" then
    					min_rad = min_rad + 1
    				end

    				local dsq = distsq(Vector3(v.Transform:GetWorldPosition()), pt)
    				if dsq <= min_rad*min_rad then
    					return false
    				end
    			end
    		end
        end
	end

	return true
end

function Builder:EvaluateAutoFixers()
    local pos = self.inst:GetPosition()

    local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, TUNING.RESEARCH_MACHINE_DIST, {"autofixer"})

    local old_fixer = self.current_fixer
    self.current_fixer = nil

    local fixer_active = false
    for k, v in pairs(ents) do
        if v.components.autofixer then
            if not fixer_active then
                --activate the first machine in the list. This will be the one you're closest to.
                v.components.autofixer:TurnOn(self.inst)
                fixer_active = true
                self.current_fixer = v

            else
                --you've already activated a machine. Turn all the other machines off.
                v.components.autofixer:TurnOff(self.inst)
            end
        end
    end
    if old_fixer and old_fixer ~= self.current_fixer then
        old_fixer.components.autofixer:TurnOff(self.inst)
    end
end

function Builder:MergeAccessibleTechTrees(tree)
	for i,v in pairs(self.accessible_tech_trees) do
		self.accessible_tech_trees[i] = self.accessible_tech_trees[i] + (tree[i] or 0)
	end
end

function Builder:EvaluateTechTrees()
	local pos = self.inst:GetPosition()
    
    local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, TUNING.RESEARCH_MACHINE_DIST, {"prototyper"},{"INTERIOR_LIMBO"})

    local interiorSpawner = GetWorld().components.interiorspawner

	-- insert our home prototyper in the list since we don't carry it around (and potentially wouldn't hit the radius for FindEntities)
    if interiorSpawner then
        table.insert(ents,interiorSpawner.homeprototyper)
    end

	local old_accessible_tech_trees = deepcopy(self.accessible_tech_trees or TECH.NONE)
	local old_prototyper = self.current_prototyper
	local old_craftingstation = self.current_craftingstation
	self.current_prototyper = nil

	local prototyper_active = false
	local craftingstation_active = false
	local allprototypers = {}

	for k, v in pairs(ents) do
		if v.components.prototyper and v.components.prototyper:CanCurrentlyPrototype() then
			-- the nearest prototyper and the nearest crafting station
			local enabled = false
			if not v.components.prototyper:GetIsDisabled() then
				if v.components.prototyper.craftingstation then
					if not craftingstation_active then
						craftingstation_active = true
						enabled = true
					end
				else
					if not prototyper_active then
						prototyper_active = true
						enabled = true
					end
				end
			end
			allprototypers[v] = enabled
		end
	end

	self.accessible_tech_trees = {}
	--add any character specific bonuses to your current tech levels.
	self.accessible_tech_trees.SCIENCE = self.science_bonus
	self.accessible_tech_trees.MAGIC = self.magic_bonus
	self.accessible_tech_trees.ANCIENT = self.ancient_bonus
	self.accessible_tech_trees.OBSIDIAN = self.obsidian_bonus
	self.accessible_tech_trees.HOME = self.home_bonus
	self.accessible_tech_trees.CITY = self.city_bonus
	self.accessible_tech_trees.LOST = 0

	for entity,enabled in pairs(allprototypers) do
		if enabled then
			self:MergeAccessibleTechTrees(entity.components.prototyper:GetTechTrees())
			if entity.components.prototyper.craftingstation then
				self.current_craftingstation = entity
			else
				self.current_prototyper = entity
			end
			entity.components.prototyper:TurnOn()
		else
			entity.components.prototyper:TurnOff()
		end
	end

	local trees_changed = false
	
	for k, v in pairs(old_accessible_tech_trees) do
		if v ~= self.accessible_tech_trees[k] then 
			trees_changed = true
			break
		end
	end
	if not trees_changed then
		for k, v in pairs(self.accessible_tech_trees) do
			if v ~= old_accessible_tech_trees[k] then 
				trees_changed = true
				break
			end
		end
	end

	if old_prototyper and old_prototyper.components.prototyper and old_prototyper:IsValid() and old_prototyper ~= self.current_prototyper then
		old_prototyper.components.prototyper:TurnOff()
	end
	if old_craftingstation and old_craftingstation.components.prototyper and old_craftingstation:IsValid() and old_craftingstation ~= self.current_craftingstation then
		old_craftingstation.components.prototyper:TurnOff()
	end

	if trees_changed then
		self.inst:PushEvent("techtreechange", {level = self.accessible_tech_trees})
	end
end

function Builder:AddRecipe(rec)
	if table.contains(self.recipes, rec) == false then
	    table.insert(self.recipes, rec)
	    self.recipe_count = self.recipe_count + 1
    end
end

function Builder:UnlockRecipe(recname)
	local recipe = GetRecipe(recname)

	if recipe ~= nil and  not recipe.nounlock and not self.brainjellyhat then
	--print("Unlocking: ", recname)
		if self.inst.components.sanity then
			self.inst.components.sanity:DoDelta(TUNING.SANITY_MED)
		end
		
		self:AddRecipe(recname)
		self.inst:PushEvent("unlockrecipe", {recipe = recname})
	end
end

function Builder:GetIngredientWetness(ingredients)
    local wetness = {}
    for item, ents in pairs(ingredients) do
        if type(ents) == "table" then
        	for k, v in pairs(ents) do
        		if k.components.moisturelistener then
        			table.insert(wetness, {wetness = k.components.moisturelistener.moisture, num = v})
        		else
        			table.insert(wetness, {wetness = 0, num = v})
        		end
        	end
        end
    end

    local totalWetness = 0
    local totalItems = 0
    for k,v in pairs(wetness) do
    	totalWetness = totalWetness + (v.wetness * v.num)
    	totalItems = totalItems + v.num
    end
    if totalItems < 1 then totalItems = 1 end

    return totalWetness/totalItems
end

function Builder:GetIngredients(recname)
	local recipe = GetRecipe(recname)
	if recipe then
		local ingredients = {}
		for k, v in pairs(recipe.ingredients) do
            if v.type == "oinc" then
                local amt = math.max(1, RoundUp(v.amount * self.ingredientmod))                
                ingredients[v.type] = amt
            else
                local amt = math.max(1, RoundUp(v.amount * self.ingredientmod))
                local items = self.inst.components.inventory:GetItemByName(v.type, amt)
                ingredients[v.type] = items
            end
		end
		return ingredients
	end
end

function Builder:RemoveIngredients(ingredients,recname)   
    for item, ents in pairs(ingredients) do    
        if item == "oinc" then
            self.inst.components.shopper:PayMoney(self.inst.components.inventory, ents)
        else
        	for k,v in pairs(ents) do            
        		for i = 1, v do                
                    self.inst.components.inventory:RemoveItem(k, false):Remove()
        		end
        	end
        end
    end

    local recipe = GetAllRecipes()[recname]
    if recipe then
        for k,v in pairs(recipe.character_ingredients) do
            if v.type == CHARACTER_INGREDIENT.HEALTH then
                --Don't die from crafting!
                local delta = math.min(math.max(0, self.inst.components.health.currenthealth - 1), v.amount)
                self.inst:PushEvent("consumehealthcost")                                
                self.inst.components.health:DoDelta(-delta, false, "builder", true, nil, true)
            elseif v.type == CHARACTER_INGREDIENT.MAX_HEALTH then
                self.inst:PushEvent("consumehealthcost")
                self.inst.components.health:DeltaPenalty(v.amount)
            elseif v.type == CHARACTER_INGREDIENT.SANITY then
                self.inst.components.sanity:DoDelta(-v.amount)
            elseif v.type == CHARACTER_INGREDIENT.MAX_SANITY then
                --[[
                    Because we don't have any maxsanity restoring items we want to be more careful
                    with how we remove max sanity. Because of that, this is not handled here.
                    Removal of sanity is actually managed by the entity that is created.
                    See maxwell's pet leash on spawn and pet on death functions for examples.
                --]]
            end
        end
    end    
    self.inst:PushEvent("consumeingredients")
end

function Builder:OnSetProfile(profile)
end

function Builder:HasCharacterIngredient(ingredient)
    if ingredient.type == CHARACTER_INGREDIENT.HEALTH then
        if self.inst.components.health ~= nil then
            --round up health to match UI display
            local current = math.ceil(self.inst.components.health.currenthealth)
            return current >= ingredient.amount, current
        end
    elseif ingredient.type == CHARACTER_INGREDIENT.MAX_HEALTH then
        if self.inst.components.health ~= nil then
            local penalty = self.inst.components.health:GetPenaltyPercent()
            return penalty + ingredient.amount <= TUNING.MAXIMUM_HEALTH_PENALTY, 1 - penalty
        end
    elseif ingredient.type == CHARACTER_INGREDIENT.SANITY then
        if self.inst.components.sanity ~= nil then
            --round up sanity to match UI display
            local current = math.ceil(self.inst.components.sanity.current)
            return current >= ingredient.amount, current
        end
    elseif ingredient.type == CHARACTER_INGREDIENT.MAX_SANITY then
        if self.inst.components.sanity ~= nil then
            local penalty = self.inst.components.sanity:GetPenaltyPercent()
            return penalty + ingredient.amount <= TUNING.MAXIMUM_SANITY_PENALTY, 1 - penalty
        end
    end
    return false, 0
end

function Builder:MakeRecipe(recipe, pt, rot, onsuccess, modifydata)
    
    if recipe then
    	self.inst:PushEvent("makerecipe", {recipe = recipe})
		pt = pt or Point(self.inst.Transform:GetWorldPosition())
		
        if self:IsBuildBuffered(recipe.name) or self:CanBuild(recipe.name) then
			self.inst.components.locomotor:Stop()
			local buffaction = BufferedAction(self.inst, nil, ACTIONS.BUILD, nil, pt, recipe.name, recipe.distance or 1, rot, modifydata)
			if onsuccess then
				buffaction:AddSuccessAction(onsuccess)
			end
			
			self.inst.components.locomotor:PushAction(buffaction, true)
			
			return true
		end
    end
    return false
end

function Builder:DoBuild(recname, pt, rotation, modifydata)
    -- modifydata comes from the placer. Some of the new interior decore items use different prefabs and anim states 
    -- depending on their position to be placed. This data is used to construct the correct prefab when built
    local recipe = GetRecipe(recname)
    local buffered = self:IsBuildBuffered(recname)

    if recipe and self:IsBuildBuffered(recname) or self:CanBuild(recname) then

    	local wetLevel = 0
		if self.buffered_builds[recname] then
			wetLevel = self.buffered_builds[recname].wetLevel
			self.buffered_builds[recname] = nil
        else
        	local mats = self:GetIngredients(recname)
        	wetLevel = self:GetIngredientWetness(mats) or 0
			self:RemoveIngredients(mats,recname)
		end

        local prefab = recipe.product        
        if modifydata and modifydata.prod then
            prefab = modifydata.prod
        end

        if modifydata and modifydata.backwall then
            prefab = recipe.product.."_backwall"
        end

        if modifydata and modifydata.prefab_prefix then
            prefab = modifydata.prefab_prefix .. recipe.product
        end

        if modifydata and modifydata.prefab_suffix then
            prefab = recipe.product..modifydata.prefab_suffix
        end

        local prod = SpawnPrefab(prefab)
        if prod then
        	if prod and prod.components.moisturelistener and wetLevel then                
        		prod.components.moisturelistener.moisture = wetLevel
                prod:DoTaskInTime(0, function()
                        if prod.components.moisturelistener then
                            prod.components.moisturelistener.moisture = wetLevel or 0
                            prod.components.moisturelistener:DoUpdate() 
                        end
                    end)        		
        	end

            if prod.components.inventoryitem then
                if self.inst.components.inventory then
					 
                    --self.inst.components.inventory:GiveItem(prod)
                    self.inst:PushEvent("builditem", {item=prod, recipe = recipe})
                    ProfileStatsAdd("build_"..prod.prefab)


                    if prod.components.equippable and prod.components.equippable.equipslot and not self.inst.components.inventory:GetEquippedItem(prod.components.equippable.equipslot) then
                    	--The item is equippable. Equip it.
						self.inst.components.inventory:Equip(prod)

            			if recipe.numtogive > 1 then
            				--Looks like the recipe gave more than one item! Spawn in the rest and give them to the player.
							for i = 2, recipe.numtogive do
								local addt_prod = SpawnPrefab(recipe.product)
								self.inst.components.inventory:GiveItem(addt_prod, nil, TheInput:GetScreenPosition())
							end
	                    end
                    else
                    	--Should this item just go into a boat equip slot? 
                    	local givenToVehicle = false 
                    	if prod.components.equippable and prod.components.equippable.boatequipslot and self.inst.components.driver and  self.inst.components.driver.vehicle then 
	                		local vehicle = self.inst.components.driver.vehicle
	                		if vehicle.components.container.hasboatequipslots and not vehicle.components.container:GetItemInBoatSlot(prod.components.equippable.boatequipslot) then 
	                			vehicle.components.container:Equip(prod)
	                			givenToVehicle = true 
	                			if recipe.numtogive > 1 then
		            				--Looks like the recipe gave more than one item! Spawn in the rest and give them to the player.
									for i = 2, recipe.numtogive do
										local addt_prod = SpawnPrefab(recipe.product)
										self.inst.components.inventory:GiveItem(addt_prod, nil, TheInput:GetScreenPosition())
									end
			                    end
	                		end 
	                	end  
	                	if not givenToVehicle then 
		                    if recipe.numtogive > 1 and prod.components.stackable then
		                    	--The item is stackable. Just increase the stack size of the original item.
		                    	prod.components.stackable:SetStackSize(recipe.numtogive)
								self.inst.components.inventory:GiveItem(prod, nil, TheInput:GetScreenPosition())
		                    elseif recipe.numtogive > 1 and not prod.components.stackable then
		                    	--We still need to give the player the original product that was spawned, so do that.
								self.inst.components.inventory:GiveItem(prod, nil, TheInput:GetScreenPosition())
								--Now spawn in the rest of the items and give them to the player.
								for i = 2, recipe.numtogive do
									local addt_prod = SpawnPrefab(recipe.product)
									self.inst.components.inventory:GiveItem(addt_prod, nil, TheInput:GetScreenPosition())
								end
		                    else
		                    	--Only the original item is being received.
								self.inst.components.inventory:GiveItem(prod, nil, TheInput:GetScreenPosition())
		                    end
		                end 
                    end

					if self.onBuild then
						self.onBuild(self.inst, prod)
					end	
					prod:OnBuilt(self.inst)
                    
                    return true
                end
            else
                if prod.Transform then
                    pt = pt or Point(self.inst.Transform:GetWorldPosition())
                    if modifydata and modifydata.pos then
                        pt = pos
                    end         
                    --print("rotation before",rotation)
                    if modifydata and modifydata.rotation then
                        rotation = rotation
                        --print("had modfy")
                    end  
                    --print("rotation after",rotation)
				    prod.Transform:SetPosition(pt.x, pt.y, pt.z)
				    prod.Transform:SetRotation(rotation or 0)
                end

                if prod.AnimState and modifydata then                    
                    if not prod.animdata then
                        prod.animdata = {}
                    end
                    if modifydata.build then
                        prod.AnimState:SetBuild(modifydata.build)                        
                        prod.animdata.build = modifydata.build
                    end
                    if modifydata.bank then
                        prod.AnimState:SetBank(modifydata.bank)
                        prod.animdata.bank = modifydata.bank
                    end                    
                    if modifydata.anim then
                        prod.AnimState:PlayAnimation(modifydata.anim, modifydata.animloop)
                        prod.animdata.anim = modifydata.anim
                        prod.animdata.animloop = modifydata.animloop
                    end                     
                end

                self.inst:PushEvent("buildstructure", {item=prod, recipe = recipe})
                prod:PushEvent("onbuilt")
                ProfileStatsAdd("build_"..prod.prefab)
                
				if self.onBuild then
					self.onBuild(self.inst, prod)
				end
				
				prod:OnBuilt(self.inst)

				if buffered then GetPlayer().HUD.controls.crafttabs:UpdateRecipes() end
			      
                if prod.decochildrenToRemove then         
                    for i, child in ipairs(prod.decochildrenToRemove) do      
                        if child then          
                            local ptc = Vector3(prod.Transform:GetWorldPosition())
                            child.Transform:SetPosition( ptc.x ,ptc.y, ptc.z )
                            child.Transform:SetRotation( prod.Transform:GetRotation() )
                        end
                    end
                end

                return true
            end
        end
    end
end

function Builder:KnowsRecipe(recname)
	local recipe = GetRecipe(recname)

	if recipe and recipe.level.ANCIENT <= self.ancient_bonus 
              and recipe.level.MAGIC <= self.magic_bonus 
              and recipe.level.SCIENCE <= self.science_bonus 
              and recipe.level.OBSIDIAN <= self.obsidian_bonus 
              and recipe.level.HOME <= self.home_bonus
              and recipe.level.CITY <= self.city_bonus
              and recipe.level.LOST <= self.lost_bonus then
		return true
	end

    -- if the recipe is from a crafting station, but player is not at the crafting station, cut it out.
    local crafting_station_pass = true
    if recipe then
        for i,level in pairs(recipe.level)do
            if RECIPETABS[i] and RECIPETABS[i].crafting_station and level > 0 then            
                if self.accessible_tech_trees[i] == 0 then
                    crafting_station_pass = false
                end
            end
        end
    end

	return self.freebuildmode or self.jellybrainhat or (self:IsBuildBuffered(recname) or table.contains(self.recipes, recname) and crafting_station_pass)
end


function Builder:CanBuild(recname)

    if self.freebuildmode then
        return true
    end

    local recipe = GetRecipe(recname)

    if recipe then
        for ik, iv in pairs(recipe.ingredients) do
        	local amt = math.max(1, RoundUp(iv.amount * self.ingredientmod))
            if iv.type == "oinc" then
                if self.inst.components.shopper:GetMoney(self.inst.components.inventory) < amt then
                    return false
                end
            else
                if not self.inst.components.inventory:Has(iv.type, amt) then
                    return false
                end
            end
        end

        for i, v in ipairs(recipe.character_ingredients) do
            if not self:HasCharacterIngredient(v) then
                return false
            end
        end        
        return true
    end

    return false
end


return Builder
