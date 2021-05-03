require("map/network")
require("map/lockandkey")
require("map/stack")
require("map/terrain")
local MapTags = require("map/maptags")

function print_lockandkey_ex(...)
--	print(...)
end
function print_lockandkey(...)
--	print(...)
end

--[[ 

Example story for DS

Goals: 
	Kill ALL the Spiders (The pig village is in trouble, can you defend it and remove the threat?)
	
	1. To get to the pig village you must first pass through a mountain pass
		LOCK: 	Bolder blocks your path
		KEY:		You must build a pickaxe 
	
	2. You must gather enough meat for the pigs so that they have time to help you with the spiders
		LOCK: 	Pig friendship (Pig village)
		KEY:		Meat

Requirements:
	1. 	LOCK: 	Narrow area that can be blocked with boulders
		KEY:		Rocks on the ground, Twigs/grass, time to dig through the boulders
	2.	LOCK: 	Pig village with pigs and fireplace
		KEY:		Sources of meat and ways to get it; Carrots & Rabbits, wandering spiders
	
So working backwards: (create a random number of empty nodes between each)

Area 0
	1. Create evil spider dens
	2. Create pig village far enough away from spider dens, but close enough to annoy them
	3. Create Meat source close enough to pig village (this includes wood/etc to stay safe at night) it probably wants to stay away from spiders
	4. Lock all this behind LOCK 1
Area 1
	1. Add rock source
	2. Add twigs/grass source
	3. Add Starting position
--]]

Story = Class(function(self, id, tasks, terrain, gen_params, level)
	self.id = id
	self.loop_blanks = 1
	self.gen_params = gen_params
	self.impassible_value = gen_params.impassible_value or GROUND.IMPASSABLE
	self.level = level

	self.tasks = {}
	for k,task in pairs(tasks) do
		self.tasks[task.id] = task
	end
	self.GlobalTags = {}
	self.TERRAIN = {}
	self.terrain = terrain
	
	self.rootNode = Graph(id.."_root", {})
	self.startNode = nil
	self.finalNode = nil

	self.map_tags = MapTags()

	self.water_content = {}
end)

function Story:GenerationPipeline()
	self:GenerateNodesFromTasks()

	local min_bg = self.level.background_node_range and self.level.background_node_range[1] or 0
	local max_bg = self.level.background_node_range and self.level.background_node_range[2] or 2
	self:AddBGNodes(min_bg, max_bg)
	self:InsertAdditionalSetPieces()
	self:InsertAdditionalTreasures()
	self:ProcessExtraTags()
	self:ProcessWaterContent()
end

function Story:ModRoom(roomname, room)
	local modfns = ModManager:GetPostInitFns("RoomPreInit", roomname)
	for i,modfn in ipairs(modfns) do
		print("Applying mod to room '"..roomname.."'")
		modfn(room)
	end
	
end

function Story:GetRoom(roomname)
	local newroom = deepcopy(self.terrain.rooms[roomname])
	self:ModRoom(roomname, newroom)
	return newroom
end

function Story:ProcessWaterContent()
	if self.level.water_content then
		if self.water_content == nil then
			self.water_content = {}
		end

		for room, v in pairs(self.level.water_content) do
			local data = self:GetRoom(room)
			if data then
				table.insert(self.water_content, {checkFn = v.checkFn, data = data})
			end
		end
	end
end

function Story:InsertWaterSetPieces()
	if self.water_content and self.level.water_setpieces then
		for k,v in ipairs(self.level.water_setpieces) do
			local choicekeys = shuffledKeys(self.water_content)
			local content = self.water_content[math.random(1, #self.water_content)]
			--if content.data.type == "water" or WorldSim:IsWater(content.data.value) then
				if content.data.contents.countstaticlayouts == nil then
					content.data.contents.countstaticlayouts = {}
				end
				if content.data.contents.countstaticlayouts[v] == nil then
					content.data.contents.countstaticlayouts[v] = 0
				end
				content.data.contents.countstaticlayouts[v] = content.data.contents.countstaticlayouts[v] + 1
			--end
		end
	end
end

function Story:PlaceTeleportatoParts()
	local RemoveExitTag = function(node)
		local newtags = {}
		for i,tag in ipairs(node.data.tags) do
			if tag ~= "ExitPiece" then
				table.insert(newtags, tag)
			end
		end
		node.data.tags = newtags
	end

	local IsNodeAnExit = function(node)
		if not node.data.tags then
			return false
		end
		for i,tag in ipairs(node.data.tags) do
			if tag == "ExitPiece" then
				return true
			end
		end
		return false
	end

	local iswaternode = function(node)
		local water_node = node.data.type == "water" or WorldSim:IsWater(node.data.value)
		return water_node
		--return ((setpiece_data.restrict_to == nil or setpiece_data.restrict_to ~= "water") and room.data.type ~= "water") or (setpiece_data.restrict_to and setpiece_data.restrict_to == "water" and (room.data.type == "water" or WorldSim:IsWater(room.data.value)))
	end

	local AddPartToTask = function(part, task)
		local nodeNames = shuffledKeys(task.nodes)
		for i,name in ipairs(nodeNames) do		
			if IsNodeAnExit(task.nodes[name]) and not iswaternode(task.nodes[name]) then
				local extra = task.nodes[name].data.terrain_contents_extra
				if not extra then
					extra = {}
				end
				if not extra.static_layouts then
					extra.static_layouts = {}
				end
				table.insert(extra.static_layouts, part)
				RemoveExitTag(task.nodes[name])
				return true
			end
		end
		return false
	end


	local InsertPartnumIntoATask = function(targetDepth, part, tasks)
		for id,task in pairs(tasks) do
			 if task.story_depth == targetDepth then
				local success = AddPartToTask(part, task)
				-- Not sure why we need this, was causeing crash
				--assert( success or task.id == "TEST_TASK"or task.id == "MaxHome", "Could not add an exit part to task "..task.id)
				return success
			end
		end
		return false
	end

	local parts = self.level.ordered_story_setpieces or {}
	local maxdepth = -1
	
	for id,task in pairs(self.rootNode:GetChildren()) do
		if task.story_depth > maxdepth then
			maxdepth = task.story_depth
		end
	end
	

	local partSpread = maxdepth/#parts
	local range = math.ceil(maxdepth/10)
	local plusminus = math.ceil(range/2)

	for partnum = 1,#parts do
		--local minDepth = partnum*partSpread - plusminus
		--local maxDepth = partnum*partSpread + plusminus 
		local targetDepth = math.ceil(partnum*partSpread)
		local success = InsertPartnumIntoATask(targetDepth, parts[partnum], self.rootNode:GetChildren())
		if success == false then 
			for i = 1, plusminus do 
				local tryDepth = targetDepth - i 
				if InsertPartnumIntoATask(tryDepth, parts[partnum], self.rootNode:GetChildren()) then 
					break 
				end 
				tryDepth = targetDepth + i
				if InsertPartnumIntoATask(tryDepth, parts[partnum], self.rootNode:GetChildren()) then 
					break 
				end 
			end 
		end 
	end
end

function Story:ProcessExtraTags()
	self:PlaceTeleportatoParts()
end


function Story:InsertAdditionalSetPieces()
	local obj_layout = require("map/object_layout")

	local function is_water_ok(room, layout)
		local water_room = room.data.type == "water" or WorldSim:IsWater(room.data.value)
		local water_layout = layout and layout.water == true
		return (water_room and water_layout) or (not water_room and not water_layout)
		--return ((setpiece_data.restrict_to == nil or setpiece_data.restrict_to ~= "water") and room.data.type ~= "water") or (setpiece_data.restrict_to and setpiece_data.restrict_to == "water" and (room.data.type == "water" or WorldSim:IsWater(room.data.value)))
	end

	local tasks = self.rootNode:GetChildren()
	for id, task in pairs(tasks) do
		if task.set_pieces ~= nil and #task.set_pieces >0 then
			for i,setpiece_data  in ipairs(task.set_pieces) do
				local is_entrance = function(room)
					-- return true if the room is an entrance
					return room.data.entrance ~= nil and room.data.entrance == true
				end
				local is_background_ok = function(room)
					-- return true if the piece is not backround restricted, or if it is but we are on a background
					return setpiece_data.restrict_to ~= "background" or room.data.type == "background"
				end
				local isnt_blank = function(room)
					return room.data.type ~= "blank"
				end

				local layout = obj_layout.LayoutForDefinition(setpiece_data.name)
				local choicekeys = shuffledKeys(task.nodes)
				local choice = nil
				for i, choicekey in ipairs(choicekeys) do
					if not is_entrance(task.nodes[choicekey]) and is_background_ok(task.nodes[choicekey]) and is_water_ok(task.nodes[choicekey], layout) and isnt_blank(task.nodes[choicekey]) then
						choice = choicekey
						break
					end
				end

				if choice == nil then
					print("Warning! Couldn't find a spot in "..task.id.." for "..setpiece_data.name)
					break
				end

				--print("Placing "..setpiece_data.name.." in "..task.id..":"..task.nodes[choice].id)

				if task.nodes[choice].data.terrain_contents.countstaticlayouts == nil then
					task.nodes[choice].data.terrain_contents.countstaticlayouts = {}
				end
				--print ("Set peice", name, choice, room_choices._et[choice].contents, room_choices._et[choice].contents.countstaticlayouts[name])
				task.nodes[choice].data.terrain_contents.countstaticlayouts[setpiece_data.name] = 1
			end		
		end
		if task.random_set_pieces ~= nil and #task.random_set_pieces > 0 then
			for k,v in ipairs(task.random_set_pieces) do
				local layout = obj_layout.LayoutForDefinition(v)
				local choicekeys = shuffledKeys(task.nodes)
				local choice = nil
				for i, choicekey in ipairs(choicekeys) do
					local is_entrance = function(room)
						-- return true if the room is an entrance
						return room.data.entrance ~= nil and room.data.entrance == true
					end
					local isnt_blank = function(room)
						return room.data.type ~= "blank"
					end

					if not is_entrance(task.nodes[choicekey]) and isnt_blank(task.nodes[choicekey]) and is_water_ok(task.nodes[choicekey], layout) then
						choice = choicekey
						break
					end
				end

				if choice == nil then
					print("Warning! Couldn't find a spot in "..task.id.." for "..v)
					break
				end

				--print("Placing "..setpiece_data.name.." in "..task.id..":"..task.nodes[choice].id)

				if task.nodes[choice].data.terrain_contents.countstaticlayouts == nil then
					task.nodes[choice].data.terrain_contents.countstaticlayouts = {}
				end
				--print ("Set peice", name, choice, room_choices._et[choice].contents, room_choices._et[choice].contents.countstaticlayouts[name])
				task.nodes[choice].data.terrain_contents.countstaticlayouts[v] = 1
			end
		end
	end
end

function Story:InsertAdditionalTreasures()
	local is_entrance = function(room)
		-- return true if the room is an entrance
		return room.data.entrance ~= nil and room.data.entrance == true
	end
	local is_background_ok = function(room, restrict_to)
		-- return true if the piece is not backround restricted, or if it is but we are on a background
		return restrict_to ~= "background" or room.data.type == "background"
	end
	local is_beach_ok = function(room, restrict_to)
		--print("is_beach_ok", restrict_to, room.data.type, room.data.value, GROUND.BEACH)
		return restrict_to ~= "beach" or room.data.value == GROUND.BEACH
	end
	local is_water_ok = function(room, layout)
		local water_room = room.data.type == "water" or WorldSim:IsWater(room.data.value)
		local water_layout = layout and layout.water == true
		--print("is_water_ok", tostring(water_room), tostring(water_layout))
		return (water_room and water_layout) or (not water_room and not water_layout)
		--return ((restrict_to == nil or restrict_to ~= "water") and room.data.type ~= "water") or (restrict_to and restrict_to == "water" and (room.data.type == "water" or WorldSim:IsWater(room.data.value)))
	end
	local isnt_blank = function(room)
		return room.data.type ~= "blank"
	end
	local inst_dup = function(node, id)
		--for the rare case the same treasure stage is on the same node
		return node.data.terrain_contents == nil or node.data.terrain_contents.treasure_data == nil or node.data.terrain_contents.treasure_data[id] == nil
	end

	local obj_layout = require("map/object_layout")
	local min_treasure_id = 1200

	local add_treasure_stage = function(name, stage, task, treasureid, restrict_to)
		if task == nil then
			return
		end

		local treasure = GetTreasureDefinition(name)
		local layout = (treasure[stage].treasure_set_piece and obj_layout.LayoutForDefinition(treasure[stage].treasure_set_piece)) or nil
		local choicekeys = shuffledKeys(task.nodes)
		local choice = nil
		for i, choicekey in ipairs(choicekeys) do
			if not is_entrance(task.nodes[choicekey]) and is_beach_ok(task.nodes[choicekey], restrict_to) and is_background_ok(task.nodes[choicekey], restrict_to) and is_water_ok(task.nodes[choicekey], layout) and isnt_blank(task.nodes[choicekey]) and inst_dup(task.nodes[choicekey], treasureid) then
				choice = choicekey
				break
			end
		end

		if choice == nil then
			print("Warning! Couldn't find a spot in "..task.id.." for "..name)
			return nil
		end

		local node = task.nodes[choice]

		--print(string.format("Placing %s, stage %d, id %d in %s:%s\n", name, stage, treasureid, task.id, node.id))

		if node.data.terrain_contents == nil then
			node.data.terrain_contents = {}
		end

		if node.data.terrain_contents.treasure_data == nil then
			node.data.terrain_contents.treasure_data = {}
		end

		node.data.terrain_contents.treasure_data[treasureid] = {name = name, stage = stage}
	end

	local add_treasure = function(name, tasklist, task, restrict_to)
		local treasure = GetTreasureDefinition(name)
		local stagetask = task
		if treasure then
			for i = 1, #treasure, 1 do
				add_treasure_stage(name, i, stagetask, min_treasure_id, restrict_to)
				stagetask = tasklist[math.random(1, #tasklist)]
			end
			min_treasure_id = min_treasure_id + 1
		end
	end

	local tasks = self.rootNode:GetChildren()
	local tasklist = {}
	for id, task in pairs(tasks) do
		table.insert(tasklist, task)
	end

	for id, task in pairs(tasks) do
		if task.treasures ~= nil and #task.treasures >0 then
			for i,treasure_data  in ipairs(task.treasures) do
				add_treasure(treasure_data.name, tasklist, task, treasure_data.restrict_to)
			end		
		end
		if task.random_treasures ~= nil and #task.random_treasures > 0 then
			for k,v in ipairs(task.random_treasures) do
				add_treasure(v, tasklist, task, nil)
			end
		end
	end
end

function Story:RestrictNodesByKey(startParentNode, unusedTasks)
	print("##############################RestrictNodesByKey")

	local lastNode = startParentNode
		print("Startparent node:",startParentNode.id)
	local usedTasks = {}
	usedTasks[startParentNode.id] = startParentNode
	startParentNode.story_depth = 0
	local story_depth = 1
	local currentNode = nil

    local last_parent = 1 -- this is a desperate attempt to distribute the nodes better

    local function FindAttachNodes(taskid, node, target_tasks)

        local unlockingNodes = {}

        for target_taskid, target_node in pairs(target_tasks) do

            local locks = {}
            for i,v in ipairs(self.tasks[taskid].locks) do
                local lock = {keys=LOCKS_KEYS[v], unlocked = false}
                locks[v] = lock
            end

            local availableKeys = {} --What are we allowed to connect to this task?

            for i, v in ipairs(self.tasks[target_taskid].keys_given) do --Get the keys that the last area we generated gives
                availableKeys[v] = {}
                table.insert(availableKeys[v], target_node)
            end

            for lock, lockData in pairs(locks) do 						--For each lock:
                for key, keyNodes in pairs(availableKeys) do 			--Do we have a key...
                    for reqKeyIdx, reqKey in ipairs(lockData.keys) do 	--...for this lock?
                        if reqKey == key then 							--If yes, get the nodes
                            lockData.unlocked = true 					--Unlock the lock.
                        end
                    end
                end
            end

            local unlocked = true
            for lock, lockData in pairs(locks) do
                if lockData.unlocked == false then
                    unlocked = false
                    break
                end
            end

            if unlocked then
                unlockingNodes[target_taskid] = target_node
            else
            end
        end

        return unlockingNodes
    end

    while GetTableSize(unusedTasks) > 0 do
        local effectiveLastNode = lastNode
        print_lockandkey_ex("\n\n_______Attempting new connection_______")

        local candidateTasks = {}

        print_lockandkey_ex("Gathering new batch:")

        for taskid, node in pairs(unusedTasks) do
            local unlockingNodes = FindAttachNodes(taskid, node, usedTasks)

            if GetTableSize(unlockingNodes) > 0 then
                print_lockandkey_ex(taskid, GetTableSize(unlockingNodes))
                candidateTasks[taskid] = unlockingNodes
            end
        end

        local function AppendNode(in_node, parents)

            print_lockandkey_ex("#############Success! Making connection.#############")
            print_lockandkey_ex(string.format("Trying to connect %s", in_node.id))
            currentNode = in_node

            local lowest = {i = 999, node = nil}
            local highest = {i = -1, node = nil}
            for id, node in pairs(parents) do
                if node.story_depth >= highest.i then
                    highest.i = node.story_depth
                    highest.node = node
                end
                if node.story_depth < lowest.i then
                    lowest.i = node.story_depth
                    lowest.node = node
                end
            end

            if self.gen_params.branching == nil or self.gen_params.branching == "default" then
                last_parent = ((last_parent-1) % GetTableSize(parents)) + 1
                local parent_i = 1
                for k,v in pairs(parents) do
                    if parent_i < last_parent then
                        parent_i = parent_i + 1
                    else
                        last_parent = last_parent + 1
                        effectiveLastNode = v
                        break
                    end
                end
                 print_lockandkey_ex("\tAttaching "..currentNode.id.." to next key", effectiveLastNode.id)
            elseif self.gen_params.branching == "most" then
                effectiveLastNode = lowest.node
                 print_lockandkey_ex("\tAttaching "..currentNode.id.." to lowest key", effectiveLastNode.id)
            elseif self.gen_params.branching == "least" then
                effectiveLastNode = highest.node
                 print_lockandkey_ex("\tAttaching "..currentNode.id.." to highest key", effectiveLastNode.id)
            elseif self.gen_params.branching == "never" then
                effectiveLastNode = lastNode
                 print_lockandkey_ex("\tAttaching "..currentNode.id.." to end of chain", effectiveLastNode.id)
            end

            print_lockandkey_ex(string.format("Connected it to %s", effectiveLastNode.id))

            currentNode.story_depth = story_depth
            story_depth = story_depth + 1

            local lastNodeExit = effectiveLastNode:GetRandomNode()
            local currentNodeEntrance = currentNode:GetRandomNode()
            if currentNode.entrancenode then
                currentNodeEntrance = currentNode.entrancenode
            end

            assert(lastNodeExit)
            assert(currentNodeEntrance)

            if self.gen_params.island_percent ~= nil 
                and self.gen_params.island_percent >= math.random()
                and currentNodeEntrance.data.entrance == false then
                self:SeperateStoryByBlanks(lastNodeExit, currentNodeEntrance)
            else
                self.rootNode:LockGraph(effectiveLastNode.id..'->'..currentNode.id, lastNodeExit, currentNodeEntrance, {type="none", key=self.tasks[currentNode.id].locks, node=nil})
            end		

            -- print_lockandkey_ex("\t\tAdding keys to keyring:")
            -- for i,v in ipairs(self.tasks[currentNode.id].keys_given) do
            -- 	if availableKeys[v] == nil then
            -- 		availableKeys[v] = {}
            -- 	end
            -- 	table.insert(availableKeys[v], currentNode)
            -- 	print_lockandkey_ex("\t\t",KEYS_ARRAY[v])
            -- end

            unusedTasks[currentNode.id] = nil
            usedTasks[currentNode.id] = currentNode
            lastNode = currentNode
            currentNode = nil

        end

        if next(candidateTasks) == nil then
            print_lockandkey_ex("We aint found nothin'!! Making a random connection :( -- ")
            AppendNode( self:GetRandomNodeFromTasks(unusedTasks), usedTasks )
        else
            for taskid, unlockingNodes in pairs(candidateTasks) do
                print_lockandkey_ex("PARENTS:")
                for k,v in pairs(unlockingNodes) do
                    print_lockandkey_ex("\t",k)
                end
                AppendNode( unusedTasks[taskid], unlockingNodes )
            end
        end


    end

	return lastNode:GetRandomNode()
end

function Story:LinkNodesByKeys(startParentNode, unusedTasks)
	print_lockandkey_ex("\n\n### START PARENT NODE:",startParentNode.id)
	local lastNode = startParentNode
	local availableKeys = {}
	for i,v in ipairs(self.tasks[startParentNode.id].keys_given) do
		availableKeys[v] = {}
		table.insert(availableKeys[v], startParentNode)
	end
	local usedTasks = {}

	startParentNode.story_depth = 0
	local story_depth = 1
	local currentNode = nil
	
	while GetTableSize(unusedTasks) > 0 do
		local effectiveLastNode = lastNode

		print_lockandkey_ex("\n\n### About to insert a node. Last node:", lastNode.id)

		print_lockandkey_ex("\tHave Keys:")
		for key, keyNodes in pairs(availableKeys) do
			print_lockandkey_ex("\t\t",KEYS_ARRAY[key], GetTableSize(keyNodes))
		end

		for taskid, node in pairs(unusedTasks) do

			print_lockandkey_ex("  TASK: "..taskid)
			print_lockandkey_ex("\t Locks:")

			local locks = {}
			for i,v in ipairs(self.tasks[taskid].locks) do
				local lock = {keys=LOCKS_KEYS[v], unlocked=false}
				locks[v] = lock
				print_lockandkey_ex("\t\tLock:",LOCKS_ARRAY[v],tabletoliststring(lock.keys, function(x) return KEYS_ARRAY[x] end))
			end


			local unlockingNodes = {}

			for lock,lockData in pairs(locks) do						-- For each lock:
				print_lockandkey_ex("\tUnlocking",LOCKS_ARRAY[lock])
				for key, keyNodes in pairs(availableKeys) do			-- Do we have any key for
					for reqKeyIdx,reqKey in ipairs(lockData.keys) do	   -- this lock?
						if reqKey == key then							-- If yes, get the nodes with
																		   -- that key so that we
							for i,node in ipairs(keyNodes) do			   -- can potentially attach
								unlockingNodes[node.id] = node			   -- to one.
							end
							lockData.unlocked = true					-- Also unlock the lock
							print_lockandkey_ex("\t\t\tUnlocked!", KEYS_ARRAY[key])
						end
					end
				end
			end

			local unlocked = true
			for lock,lockData in pairs(locks) do
				print_lockandkey_ex("\tDid we unlock ", LOCKS_ARRAY[lock])
				if lockData.unlocked == false then
					print_lockandkey_ex("\t\tno.")
					unlocked = false
					break
				end
			end

			if unlocked then
				-- this task is presently unlockable!
				currentNode = node
				print_lockandkey_ex ("StartParentNode",startParentNode.id,"currentNode",currentNode.id)

				local lowest = {i=999,node=nil}
				local highest = {i=-1,node=nil}
				for id,node in pairs(unlockingNodes) do
					if node.story_depth >= highest.i then
						highest.i = node.story_depth
						highest.node = node
					end
					if node.story_depth < lowest.i then
						lowest.i = node.story_depth
						lowest.node = node
					end
				end

				if self.gen_params.branching == nil or self.gen_params.branching == "default" then
					effectiveLastNode = GetRandomItem(unlockingNodes)
					print_lockandkey("\tAttaching "..currentNode.id.." to random key", effectiveLastNode.id)
				elseif self.gen_params.branching == "most" then
					effectiveLastNode = lowest.node
					print_lockandkey("\tAttaching "..currentNode.id.." to lowest key", effectiveLastNode.id)
				elseif self.gen_params.branching == "least" then
					effectiveLastNode = highest.node
					print_lockandkey("\tAttaching "..currentNode.id.." to highest key", effectiveLastNode.id)
				elseif self.gen_params.branching == "never" then
					effectiveLastNode = lastNode
					print_lockandkey("\tAttaching "..currentNode.id.." to end of chain", effectiveLastNode.id)
				end

				break
			end

		end

		if currentNode == nil then
			currentNode = self:GetRandomNodeFromTasks(unusedTasks)
			print_lockandkey("\t\tAttaching random node "..currentNode.id.." to last node", effectiveLastNode.id)
		end

		currentNode.story_depth = story_depth
		story_depth = story_depth + 1

		local lastNodeExit = effectiveLastNode:GetRandomNode()
		local currentNodeEntrance = currentNode:GetRandomNode()
		if currentNode.entrancenode then
			currentNodeEntrance = currentNode.entrancenode
		end

		assert(lastNodeExit)
		assert(currentNodeEntrance)

		if self.gen_params.island_percent ~= nil and self.gen_params.island_percent >= math.random() and currentNodeEntrance.data.entrance == false then
			self:SeperateStoryByBlanks(lastNodeExit, currentNodeEntrance )
		else
			self.rootNode:LockGraph(effectiveLastNode.id..'->'..currentNode.id, lastNodeExit, currentNodeEntrance, {type="none", key=self.tasks[currentNode.id].locks, node=nil})
		end		

		print_lockandkey_ex("\t\tAdding keys to keyring:")
		for i,v in ipairs(self.tasks[currentNode.id].keys_given) do
			if availableKeys[v] == nil then
				availableKeys[v] = {}
			end
			table.insert(availableKeys[v], currentNode)
			print_lockandkey_ex("\t\t",KEYS_ARRAY[v])
		end

		unusedTasks[currentNode.id] = nil
		usedTasks[currentNode.id] = currentNode
		lastNode = currentNode
		currentNode = nil
	end

	return lastNode:GetRandomNode()
end

function Story:LinkIslandsByKeys(startParentTask, unusedTasks)
	local lastNode = startParentTask

	startParentTask.story_depth = 0
	local story_depth = 1

	--build a table of task graphs
	local layout = {}
	local layoutdepth = 1

	--depth 0 is always the start task
	layout[1] = {}
	--print("Start task " .. startParentTask.id)
	table.insert(layout[1], startParentTask)
	unusedTasks[startParentTask.id] = nil

	local locks = {}
	for l,k in pairs(LOCKS_KEYS) do
		local lock = {keys=k, unlocked=false}
		locks[l] = lock
	end
	locks[LOCKS.NONE].unlocked = true

	local unlockEverything = false

	while GetTableSize(unusedTasks) > 0 do
		--print("Unused tasks " .. GetTableSize(unusedTasks))
		--unlock every lock we can at the current depth
		for lock, lockData in pairs(locks) do
			for i, taskgraph in ipairs(layout[layoutdepth]) do
				--print("\tUnlocking",LOCKS_ARRAY[lock])
				for j, reqKey in pairs(self.tasks[taskgraph.id].keys_given) do
					for k, key in pairs(lockData.keys) do
						if reqKey == key then
							--print("Task " .. taskgraph.id)
							--print("\t\t\tUnlocked!", KEYS_ARRAY[key])
							lockData.unlocked = true
						end
					end
				end
			end
		end

		layoutdepth = layoutdepth + 1
		layout[layoutdepth] = {}

		local addedtasks = 0

		--add every unlocked task to this depth
		for taskid, taskgraph in pairs(unusedTasks) do
			local addtask = false
			for i, lock in pairs(self.tasks[taskid].locks) do
				if locks[lock].unlocked == true then
					addtask = true
				else
					--print("Can't add " .. taskid .. " " .. LOCKS_ARRAY[lock] .. " locked")
				end
			end
			if addtask == true or unlockEverything == true then
				taskgraph.story_depth = story_depth
				story_depth = story_depth + 1
				table.insert(layout[layoutdepth], taskgraph)
				unusedTasks[taskid] = nil
				addedtasks = addedtasks + 1
			end
		end

		--after 1 loop without adding anything unlock everything
		if addedtasks == 0 then
			--print("Added no tasks unlock everything")
			for lock, lockData in pairs(locks) do
				lockData.unlocked = true
			end
			unlockEverything = true
			layoutdepth = layoutdepth - 1
		else
			--print("Added " .. #layout[layoutdepth] .. " tasks at depth " .. layoutdepth)
		end
	end

	--link tasks and seperate by ocean
	print("Linking " .. #layout .. " depths")

	local sprawling = true
	if sprawling == true then
		--random, sprawling
		for depth = #layout, 2, -1 do
			--print("Linking " .. #layout[depth] .. " at depth " .. depth)
			for i, taskgraph in pairs(layout[depth]) do
				--link each task at this depth with a random task in the previous depth
				local taskgraph2 = layout[depth - 1][math.random(1, #layout[depth - 1])]
				local curNode = taskgraph:GetRandomNode()
				local prevDepthNode = taskgraph2:GetRandomNode()

				--print("Linking " .. taskgraph.id .. " -> ".. taskgraph2.id)
				--self:SeperateStoryByBlanks(prevDepthNode, curNode)
				self:SeperateIslandsByOcean(prevDepthNode, curNode, math.random(3, 5)) --CM was 6,10
				--self.rootNode:LockGraph(prevDepthNode.id..'->'..curNode.id, prevDepthNode, curNode, {type="none", key=self.tasks[curNode.id].locks, node=nil})
			end
		end
	else
		--interconnected web
		for depth = #layout, 2, -1 do
			--print("Linking " .. #layout[depth] .. " at depth " .. depth)
			for i, taskgraph in pairs(layout[depth]) do
				--link each task at this depth with a random task in the previous depth
				local node = math.floor(#layout[depth - 1] * ((i - 1) / #layout[depth]) + 1)
				print(node .. " = " .. #layout[depth - 1] .. ", " .. i .. ", " .. #layout[depth])
				assert(1 <= node and node <= #layout[depth - 1])
				local taskgraph2 = layout[depth - 1][node]
				local curNode = taskgraph:GetRandomNode()
				local prevDepthNode = taskgraph2:GetRandomNode()

				--print("Linking " .. taskgraph.id .. " -> ".. taskgraph2.id)
				--self:SeperateStoryByBlanks(prevDepthNode, curNode)
				self:SeperateIslandsByOcean(prevDepthNode, curNode, math.random(5, 15))
				--self.rootNode:LockGraph(prevDepthNode.id..'->'..curNode.id, prevDepthNode, curNode, {type="none", key=self.tasks[curNode.id].locks, node=nil})
			end

			for i = 1, #layout[depth] - 1, 1 do
				local node1 = layout[depth][i]:GetRandomNode()
				local node2 = layout[depth][i + 1]:GetRandomNode()
				self:SeperateIslandsByOcean(node1, node2, 5)
			end
			self:SeperateIslandsByOcean(layout[depth][ #layout[depth] ]:GetRandomNode(), layout[depth][1]:GetRandomNode(), 5)
		end
	end

	return lastNode
end

function Story:GetRandomNodeFromTasks(taskSet)
	local sz = GetTableSize(taskSet)
	local task = nil
	if sz > 0 then
		local choice = math.random(sz) -1

		
		for taskid,_ in pairs(taskSet) do -- special order
			task = taskid
			if choice<= 0 then
				break
			end
			choice = choice -1
		end
	end
	--print("G2 task ", task)
	return self.TERRAIN[task]
end

local function RestrictNodesByKey(story, startParentNode, unusedTasks)
	print("RestrictNodesByKey")
	return story:RestrictNodesByKey(startParentNode, unusedTasks)
end


local function linkIslandsByKeys(story, startParentNode, unusedTasks)
	print("LinkIslandsByKeys")
	return story:LinkIslandsByKeys(startParentNode, unusedTasks)
end

local function linkNodesByLocksOrKeys(story, startParentNode, unusedTasks)
	--[[local finalNode = startParentNode
	if math.random()>0.8 then
		print("LinkNodesByLocks")
		finalNode = story:LinkNodesByLocks(startParentNode, unusedTasks)
	else
		print("LinkNodesByKeys")
		finalNode = story:LinkNodesByKeys(startParentNode, unusedTasks)
	end	
	print("Setting start node")
	return finalNode]]
	print("LinkNodesByKeys")
	return story:LinkNodesByKeys(startParentNode, unusedTasks)
end

function Story:GenerateNodesFromTasks(linkFn)	
	--print("Story:GenerateNodesFromTasks creating stories")

	local unusedTasks = {}
	
	-- Generate all the TERRAIN
	for k,task in pairs(self.tasks) do
		--print("Story:GenerateNodesFromTasks k,task",k,task,  GetTableSize(self.TERRAIN))
		local node = nil
		if task.gen_method == "lagoon" then
			node = self:GenerateIslandFromTask(task, false)
		elseif task.gen_method == "volcano" then
			node = self:GenerateIslandFromTask(task, true)
		else
			node = self:GenerateNodesFromTask(task, task.crosslink_factor or 1)--0.5)
		end
		self.TERRAIN[task.id] = node
		unusedTasks[task.id] = node
	end
		
	--print("Story:GenerateNodesFromTasks lock terrain")
	
	local startTasks = {}
	if self.gen_params.start_task ~= nil and self.TERRAIN[self.gen_params.start_task] then
		print("Story:GenerateNodesFromTasks start_task " .. self.gen_params.start_task)
		startTasks[self.gen_params.start_task] = self.TERRAIN[self.gen_params.start_task]
	else
		for k,task in pairs(self.tasks) do
			if #task.locks == 0 or task.locks[1] == LOCKS.NONE then
				startTasks[task.id] = self.TERRAIN[task.id]
			end
		end
	end
	
	--print("Story:GenerateNodesFromTasks finding start parent node")

	local startParentNode = GetRandomItem(self.TERRAIN)
	if  GetTableSize(startTasks) > 0 then
		startParentNode = GetRandomItem(startTasks)
	end

	unusedTasks[startParentNode.id] = nil
	
    --print("Lock and Key")	

	self.finalNode = linkFn(self, startParentNode, unusedTasks) --startParentNode
	--print("LinkIslandsByKeys")
	--finalNode = self:LinkIslandsByKeys(startParentNode, unusedTasks)


--[[
	local finalNode = startParentNode
    assert(self.gen_params.layout_mode ~= nil, "Must specify a layout mode for your level.")
    if string.upper(self.gen_params.layout_mode) == string.upper("RestrictNodesByKey") then

        print("RestrictNodesByKey")
        finalNode = self:RestrictNodesByKey(startParentNode, unusedTasks)
    else
        print("LinkNodesByKeys")
        finalNode = self:LinkNodesByKeys(startParentNode, unusedTasks)
    end
]]



	local randomStartNode = startParentNode:GetRandomNode()
	
	local start_node_data = {id="START"}

	if self.gen_params.start_node ~= nil then
		start_node_data.data = self:GetRoom(self.gen_params.start_node)
		start_node_data.data.terrain_contents = start_node_data.data.contents		
	else
		start_node_data.data = {
								value = GROUND.GRASS,								
								terrain_contents={
									countprefabs = {
										spawnpoint=1,
										sapling=1,
										flint=1,
										berrybush=1, 
										grass=function () return 2 + math.random(2) end
									} 
								}
							 }
	end

	start_node_data.data.type = "START"
	start_node_data.data.colour = {r=0,g=1,b=1,a=.80}
	
	if self.gen_params.start_setpeice ~= nil then
		start_node_data.data.terrain_contents.countstaticlayouts = {}
		start_node_data.data.terrain_contents.countstaticlayouts[self.gen_params.start_setpeice] = 1
		
		if start_node_data.data.terrain_contents.countprefabs ~= nil then
			start_node_data.data.terrain_contents.countprefabs.spawnpoint = nil
		end
	end

	self.startNode = startParentNode:AddNode(start_node_data)
											
	--print("Story:GenerateNodesFromTasks adding start node link", self.startNode.id.." -> "..randomStartNode.id)
	startParentNode:AddEdge({node1id=self.startNode.id, node2id=randomStartNode.id})	
end

--Gen nodes without adding a start node, it should be part of the level def
function Story:GenerateNodesFromTasksInlineStart(linkFn)
	--print("Story:GenerateNodesFromTasksInlineStart creating stories")

	local unusedTasks = {}
	
	-- Generate all the TERRAIN
	for k,task in pairs(self.tasks) do
		--print("Story:GenerateNodesFromTasksInlineStart k,task",k,task,  GetTableSize(self.TERRAIN))
		local node = nil
		if task.gen_method == "lagoon" then
			node = self:GenerateIslandFromTask(task, false)
		elseif task.gen_method == "volcano" then
			node = self:GenerateIslandFromTask(task, true)
		else
			node = self:GenerateNodesFromTask(task, task.crosslink_factor or 1)--0.5)
		end
		self.TERRAIN[task.id] = node
		unusedTasks[task.id] = node
	end

	local startParentNode = GetRandomItem(self.TERRAIN)

	self.finalNode = linkFn(self, startParentNode, unusedTasks)
end

function Story:AddRoadPoison()
	for id,task in pairs(self.rootNode:GetChildren()) do
		for k, v in pairs(task.nodes) do
			if v.type ~= "blank" and v.type ~= "water" then
				if v.data.tags == nil then v.data.tags = {} end
				table.insert(v.data.tags, "RoadPoison")
				table.insert(v.data.tags, "ForceConnected")
			end
		end
	end
end

function Story:AddMapLoop()
	if self.gen_params.loop_percent ~= nil then
		if math.random() < self.gen_params.loop_percent then
			--print("Adding map loop")
			self:SeperateStoryByBlanks(self.startNode, self.finalNode )
		end
	else
		if math.random() < 0.5 then
			--print("Adding map loop")
			self:SeperateStoryByBlanks(self.startNode, self.finalNode )
		end
	end
end

function Story:AddBGNodes(min_count, max_count)
	local tasksnodes = self.rootNode:GetChildren(false)
	local bg_idx = 0

	local function getBGRoom(task)
		local room = nil
		if type(task.data.background) == "table" then
			room = task.data.background[math.random(1, #task.data.background)]
		else
			room = task.data.background
		end
		return room
	end

	local function getBGRoomCount(task)
		local a = (task.background_node_range and task.background_node_range[1]) or min_count
		local b = (task.background_node_range and task.background_node_range[2]) or max_count
		return math.random(a, b)
	end

	for taskid, task in pairs(tasksnodes) do
		
		for nodeid,node in pairs(task:GetNodes(false)) do

			local background = getBGRoom(task)
			if background then
				local background_template = self:GetRoom(background) --self:GetRoom(task.data.background)
				assert(background_template, "Couldn't find room with name "..background)
				local blocker_blank_template = self:GetRoom(self.level.blocker_blank_room_name)
				if blocker_blank_template == nil then
					blocker_blank_template = {
						type="blank",
						tags = {"RoadPoison", "ForceDisconnected"},					 
						colour={r=0.3,g=.8,b=.5,a=.50},
						value = self.impassible_value
					}
				end

				self:RunTaskSubstitution(task, background_template.contents.distributeprefabs)

				if not node.data.entrance then

					local count = getBGRoomCount(task) --math.random(min_count,max_count)
					local prevNode = nil
					for i=1,count do

						local new_room = deepcopy(background_template)
						new_room.id = nodeid..":BG_"..bg_idx..":"..background
						new_room.task = task.id


						-- this has to be inside the inner loop so that things like teleportato tags
						-- only get processed for a single node.
						local extra_contents, extra_tags = self:GetExtrasForRoom(new_room)

						
						local newNode = task:AddNode({
											id=new_room.id, 
											data={
													type="background",
													colour = new_room.colour,
													value = new_room.value,
													internal_type = new_room.internal_type,
													tags = extra_tags,
													terrain_contents = new_room.contents,
													terrain_contents_extra = extra_contents,
													terrain_filter = self.terrain.filter,
													entrance = new_room.entrance
												  }										
											})

						task:AddEdge({node1id=newNode.id, node2id=nodeid})
						-- This will probably cause crushng so it is commented out for now
						-- if prevNode then
						-- 	task:AddEdge({node1id=newNode.id, node2id=prevNode.id})
						-- end

						bg_idx = bg_idx + 1
						prevNode = newNode
					end
				else -- this is an entrance node
					for i=1,2 do
						local new_room = deepcopy(blocker_blank_template)
						new_room.task = task.id

						local extra_contents, extra_tags = self:GetExtrasForRoom(new_room)

						local blank_subnode = task:AddNode({
												id=nodeid..":BLOCKER_BLANK_"..tostring(i), 
												data={
														type= new_room.type or "blank",
														colour = new_room.colour,
														value = new_room.value,
														internal_type = new_room.internal_type,
														tags = extra_tags,
														terrain_contents = new_room.contents,
														terrain_contents_extra = extra_contents,
														terrain_filter = self.terrain.filter,
														blocker_blank = true,
													  }										
											})

						task:AddEdge({node1id=nodeid, node2id=blank_subnode.id})
					end
				end
			end
		end

	end
end

function Story:SeperateStoryByBlanks(startnode, endnode )	
	local blank_node = Graph("LOOP_BLANK"..tostring(self.loop_blanks), {parent=self.rootNode, default_bg=GROUND.IMPASSABLE, colour = {r=0.3,g=.8,b=.5,a=1}, background="BGImpassable" })
	WorldSim:AddChild(self.rootNode.id, "LOOP_BLANK"..tostring(self.loop_blanks), GROUND.IMPASSABLE, 0, 0, 0, 1, "blank")
	local blank_subnode = blank_node:AddNode({
											id="LOOP_BLANK_SUB "..tostring(self.loop_blanks), 
											data={
													type="blank",
													tags = {"RoadPoison", "ForceDisconnected"},					 
													colour={r=0.3,g=.8,b=.5,a=.50},
													value = self.impassible_value
												  }										
										})

	self.loop_blanks = self.loop_blanks + 1
	self.rootNode:LockGraph(startnode.id..'->'..blank_subnode.id, 	startnode, 	blank_subnode, {type="none", key=KEYS.NONE, node=nil})
	self.rootNode:LockGraph(endnode.id..'->'..blank_subnode.id, 	endnode, 	blank_subnode, {type="none", key=KEYS.NONE, node=nil})
end

function Story:SeperateIslandsByOcean(startnode, endnode, links)
	--print("Link islands by ocean " .. startnode.id .. " -> " .. endnode.id)
	local ocean_graph = Graph("OCEAN_BLANK"..tostring(self.loop_blanks), {parent=self.rootNode, default_bg=GROUND.IMPASSABLE, colour = {r=1,g=0.8,b=1,a=1}, background="BGImpassable" })

	local nodes = {}
	local newNode = nil
	local prevNode = nil
	for i = 1, links, 1 do
		newNode = ocean_graph:AddNode({
									id="LOOP_BLANK_SUB "..tostring(self.loop_blanks),
									data={
											type="water",
											tags = {"RoadPoison", "ForceDisconnected"},
											colour={r=1.0,g=.8,b=1,a=1},
											value = self.impassible_value
										}
									})
		
		if prevNode then
			--print("Story:SeperateIslandsByOcean Adding edge "..newNode.id.." -> "..prevNode.id)
			local edge = ocean_graph:AddEdge({node1id=newNode.id, node2id=prevNode.id})
		end

		self.loop_blanks = self.loop_blanks + 1
		prevNode = newNode
		table.insert(nodes, newNode)
	end

	local firstNode = nodes[1]
	local lastNode = nodes[#nodes]

	self.rootNode:LockGraph(startnode.id..'->'..firstNode.id, 	startnode, 	firstNode, {type="none", key=KEYS.NONE, node=nil})
	self.rootNode:LockGraph(endnode.id..'->'..lastNode.id, 		endnode, 	lastNode, {type="none", key=KEYS.NONE, node=nil})

	--WorldSim:AddChild(self.rootNode.id, ocean_graph.id, ocean_graph.room_bg, ocean_graph.colour.r, ocean_graph.colour.g, ocean_graph.colour.b, ocean_graph.colour.a)
end

function Story:GetExtrasForRoom(next_room)
	local extra_contents = {}
	local extra_tags = {}
	if next_room.tags ~= nil then
		for i,tag in ipairs(next_room.tags) do
			local type, extra = self.map_tags.Tag[tag](self.map_tags.TagData)
			if type == "STATIC" then
				if extra_contents.static_layouts == nil then
					extra_contents.static_layouts = {}
				end
				table.insert(extra_contents.static_layouts, extra)
			end
			if type == "ITEM" then
				if extra_contents.prefabs == nil then
					extra_contents.prefabs = {}
				end
				table.insert(extra_contents.prefabs, extra)
			end
			if type == "TAG" then
				table.insert(extra_tags, extra)
			end
			if type == "GLOBALTAG" then
				if self.GlobalTags[extra] == nil then
					self.GlobalTags[extra] = {}
				end
				if self.GlobalTags[extra][next_room.task] == nil then
					self.GlobalTags[extra][next_room.task] = {}
				end
				--print("Adding GLOBALTAG", extra, next_room.task, next_room.id)
				table.insert(self.GlobalTags[extra][next_room.task], next_room.id)
			end
		end
	end

	return extra_contents, extra_tags
end

function Story:RunTaskSubstitution(task, items )
	if task.substitutes == nil or items == nil then
		return items
	end

	for k,v in pairs(task.substitutes) do 
		if items[k] ~= nil then 
			if v.percent == 1 or v.percent == nil then
				items[v.name] = items[k]
				items[k] = nil
			else
				items[v.name] = items[k] * v.percent
				items[k] = items[k] * (1.0-v.percent)
			end
		end
	end

	return items
end

-- Generate a subgraph containing all the items for this story
function Story:GenerateNodesFromTask(task, crossLinkFactor)
	--print("Story:GenerateNodesFromTask", task.id)
	-- Create stack of rooms
	local room_choices = Stack:Create()

	if task.entrance_room then
		local r = math.random()
		if task.entrance_room_chance == nil or task.entrance_room_chance > r then
			if type(task.entrance_room) == "table" then
				task.entrance_room = GetRandomItem(task.entrance_room)
			end
			--print("\tAdding entrance: ",task.entrance_room,"rolled:",r,"needed:",task.entrance_room_chance)
			local new_room = self:GetRoom(task.entrance_room)
			assert(new_room, "Couldn't find entrance room with name "..task.entrance_room)

			if new_room.contents == nil then
				new_room.contents = {}
			end

			if new_room.contents.fn then					
				new_room.contents.fn(new_room)
			end
			new_room.type = task.entrance_room
			new_room.entrance = true
			room_choices:push(new_room)
		--else
		--	print("\tHad entrance but didn't use it. rolled:",r,"needed:",task.entrance_room_chance)
		end
	end

	if task.room_choices then
		for room, count in pairs(task.room_choices) do
			--print("Story:GenerateNodesFromTask adding "..count.." of "..room, self.terrain.rooms[room].contents.fn)
			for id = 1, count do
				local new_room = self:GetRoom(room)

				assert(new_room, "Couldn't find room with name "..room)
				if new_room.contents == nil then
					new_room.contents = {}
				end			
				
				-- Do any special processing for this room
				if new_room.contents.fn then					
					new_room.contents.fn(new_room)
				end
				new_room.type = room --new_room.type or "normal"
				room_choices:push(new_room)
			end
		end
	end


	local task_node = Graph(task.id, {parent=self.rootNode, default_bg=task.room_bg, colour = task.colour, background=task.background_room, random_set_pieces = task.random_set_pieces, set_pieces=task.set_pieces, maze_tiles=task.maze_tiles, treasures=task.treasures, random_treasures=task.random_treasures})
	task_node.substitutes = task.substitutes
	--print ("Adding Voronoi Child", self.rootNode.id, task.id, task.room_bg, task.room_bg, task.colour.r, task.colour.g, task.colour.b, task.colour.a )

	WorldSim:AddChild(self.rootNode.id, task.id, task.room_bg, task.colour.r, task.colour.g, task.colour.b, task.colour.a)
	
	local newNode = nil
	local prevNode = nil
	-- TODO: we could shuffleArray here on rom_choices_.et to make it more random
	local roomID = 0
	--print("Story:GenerateNodesFromTask adding "..room_choices:getn().." rooms")
	while room_choices:getn() > 0 do
		local next_room = room_choices:pop()
		next_room.id = task.id..":"..roomID..":"..next_room.type	-- TODO: add room names for special rooms
		next_room.task = task.id

		self:RunTaskSubstitution(task, next_room.contents.distributeprefabs)
		
		-- TODO: Move this to 
		local extra_contents, extra_tags = self:GetExtrasForRoom(next_room)
		
		newNode = task_node:AddNode({
										id=next_room.id, 
										data={
												type= next_room.entrance and "blocker" or next_room.type, 
												colour = next_room.colour,
												value = next_room.value,
												internal_type = next_room.internal_type,
												tags = extra_tags,
												custom_tiles = next_room.custom_tiles,
												custom_objects = next_room.custom_objects,
												terrain_contents = next_room.contents,
												terrain_contents_extra = extra_contents,
												terrain_filter = self.terrain.filter,
												entrance = next_room.entrance
											  }										
									})
		
		if prevNode then
			--dumptable(prevNode)
			--print("Story:GenerateNodesFromTask Adding edge "..newNode.id.." -> "..prevNode.id)
			local edge = task_node:AddEdge({node1id=newNode.id, node2id=prevNode.id})
		end
		
		--dumptable(newNode)
		-- This will make long line of nodes
		prevNode = newNode
		roomID = roomID + 1
	end
	
	if task.make_loop then
		task_node:MakeLoop()
	end
	if crossLinkFactor then
		--print("Story:GenerateNodesFromTask crosslinking")
		-- do some extra linking.
		task_node:CrosslinkRandom(crossLinkFactor)
	end
	--print("Story:GenerateNodesFromTask done", task_node.id)
	return task_node
end

function Story:GenerateIslandFromTask(task, randomize)

	if task.room_choices == nil or type(task.room_choices[1]) ~= "table" then
		return nil
	end

	local task_node = Graph(task.id, {parent=self.rootNode, default_bg=task.room_bg, colour = task.colour, background=task.background_room, random_set_pieces = task.random_set_pieces, set_pieces=task.set_pieces, maze_tiles=task.maze_tiles, treasures=task.treasures, random_treasures=task.random_treasures})
	task_node.substitutes = task.substitutes

	WorldSim:AddChild(self.rootNode.id, task.id, task.room_bg, task.colour.r, task.colour.g, task.colour.b, task.colour.a)

	local layout = {}
	local layoutdepth = 1
	local roomID = 0

	for i = 1, #task.room_choices, 1 do
		layout[layoutdepth] = {}

		local rooms = {}
		for room, count in pairs(task.room_choices[i]) do
			--print("Story:GenerateIslandFromTask adding "..count.." of "..room, self.terrain.rooms[room].contents.fn)
			for id = 1, count do
				table.insert(rooms, room)
			end
		end
		if randomize then
			rooms = shuffleArray(rooms)
		end

		for _, room in ipairs(rooms) do
		--for room, count in pairs(task.room_choices[i]) do
			--print("Story:GenerateIslandFromTask adding "..count.." of "..room, self.terrain.rooms[room].contents.fn)
			--for id = 1, count do
				local new_room = self:GetRoom(room)

				assert(new_room, "Couldn't find room with name "..room)
				if new_room.contents == nil then
					new_room.contents = {}
				end			
				
				-- Do any special processing for this room
				if new_room.contents.fn then					
					new_room.contents.fn(new_room)
				end
				new_room.type = room --new_room.type or "normal"
				new_room.id = task.id..":"..roomID..":"..new_room.type
				new_room.task = task.id

				self:RunTaskSubstitution(task, new_room.contents.distributeprefabs)
				
				-- TODO: Move this to 
				local extra_contents, extra_tags = self:GetExtrasForRoom(new_room)
				
				local newNode = task_node:AddNode({
												id=new_room.id, 
												data={
														type= new_room.entrance and "blocker" or new_room.type, 
														colour = new_room.colour,
														value = new_room.value,
														internal_type = new_room.internal_type,
														tags = extra_tags,
														custom_tiles = new_room.custom_tiles,
														custom_objects = new_room.custom_objects,
														terrain_contents = new_room.contents,
														terrain_contents_extra = extra_contents,
														terrain_filter = self.terrain.filter,
														entrance = new_room.entrance
													  }										
											})

				table.insert(layout[layoutdepth], newNode)
				roomID = roomID + 1
			--end
		end
		layoutdepth = layoutdepth + 1
	end

	--link the nodes in a 'web'
	for depth = #layout, 2, -1 do
		--print("Linking " .. #layout[depth] .. " at depth " .. depth)
		for i = 1, #layout[depth], 1 do
			--link each task at this depth with a random task in the previous depth
			local node = math.floor(#layout[depth - 1] * ((i - 1) / #layout[depth]) + 1)
			--print(node .. " = " .. #layout[depth - 1] .. ", " .. i .. ", " .. #layout[depth])
			assert(1 <= node and node <= #layout[depth - 1])
			local roomnode = layout[depth][i]
			local roomnode2 = layout[depth - 1][node]

			--print("  Linking " .. roomnode.id .. " -> ".. roomnode2.id)
			task_node:AddEdge({node1id=roomnode.id, node2id=roomnode2.id})
		end

		--connect inner layer with itself
		for i = 2, #layout[1], 1 do
			local node1 = layout[1][1]
			local node2 = layout[1][i]
			--print("  Linking " .. node1.id .. " -> ".. node2.id)
			task_node:AddEdge({node1id=node1.id, node2id=node2.id})			
		end

		--connect layer nodes
		for i = 2, #layout[depth] - 1, 1 do
			local node1 = layout[depth][i]
			local node2 = layout[depth][i + 1]
			--print("  Linking " .. node1.id .. " -> ".. node2.id)
			task_node:AddEdge({node1id=node1.id, node2id=node2.id})
		end
		--print("  Linking " .. layout[depth][ #layout[depth] ].id .. " -> ".. layout[depth][1].id)
		task_node:AddEdge({node1id=layout[depth][ #layout[depth] ].id, node2id=layout[depth][1].id})
	end

	--print(GetTableSize(task_node))
	return task_node
end

--Generate an island usigng layer definitions
function Story:GenerateIsland(layerDefs)
	--layerDef[1] is the center of the island
	--other layers are formed around previous layers
end

------------------------------------------------------------------------------------------
---------             TESTING                   --------------------------------------
------------------------------------------------------------------------------------------

function DEFAULT_STORY(tasks, story_gen_params, level)
	print("Building DEFAULT STORY", tasks)
	local start_time = GetTimeReal()
	
	local story = Story("GAME", tasks, terrain, story_gen_params, level)
	--story:GenerationPipeline()
	story:GenerateNodesFromTasks(linkNodesByLocksOrKeys)
	story:AddMapLoop()

	local min_bg = level.background_node_range and level.background_node_range[1] or 0
	local max_bg = level.background_node_range and level.background_node_range[2] or 2
	story:AddBGNodes(min_bg, max_bg)
	story:InsertAdditionalSetPieces()
	story:ProcessExtraTags()
	    
	SetTimingStat("time", "generate_story", GetTimeReal() - start_time)
	
	--print("\n------------------------------------------------")
	--story.rootNode:Dump()
	--print("\n------------------------------------------------")
	
	return {root=story.rootNode, startNode=story.startNode, GlobalTags = story.GlobalTags, water = story.water_content}
end

function TEST_STORY(tasks, story_gen_params, level)
	return DEFAULT_STORY(tasks, story_gen_params, level)
end

function SHIPWRECKED_STORY(tasks, story_gen_params, level)
	print("Building SHIPWRECKED STORY", tasks)	
	local start_time = GetTimeReal()
	
	local story = Story("GAME", tasks, terrain, story_gen_params, level)
	story:GenerateNodesFromTasks(linkIslandsByKeys)
	story:AddRoadPoison()

	local min_bg = level.background_node_range and level.background_node_range[1] or 0
	local max_bg = level.background_node_range and level.background_node_range[2] or 2
	story:AddBGNodes(min_bg, max_bg)
	story:InsertAdditionalSetPieces()
	story:InsertAdditionalTreasures()
	story:ProcessExtraTags()
	story:ProcessWaterContent()
	story:InsertWaterSetPieces()
	    
	SetTimingStat("time", "generate_story", GetTimeReal() - start_time)
	
	--print("\n------------------------------------------------")
	--story.rootNode:Dump()
	--print("\n------------------------------------------------")
	
	return {root=story.rootNode, startNode=story.startNode, GlobalTags = story.GlobalTags, water = story.water_content}
end

function PORKLAND_STORY(tasks, story_gen_params, level)
	print("Building PORKLAND STORY", tasks)
	local start_time = GetTimeReal()
	
	local story = Story("GAME", tasks, terrain, story_gen_params, level)
	--story:GenerationPipeline()
	story:GenerateNodesFromTasks(RestrictNodesByKey)
	--story:AddMapLoop()

	local world_size = 0

	if story_gen_params.world_size then
		if story_gen_params.world_size == "default" then
			world_size = 0
		elseif story_gen_params.world_size == "medium" then
			world_size = 1
		elseif story_gen_params.world_size == "large" then
			world_size = 2
		elseif story_gen_params.world_size == "huge" then
			world_size = 3		
		end
	end

	local min_bg = level.background_node_range and level.background_node_range[1] or 0
	local max_bg = level.background_node_range and level.background_node_range[2] or 2
	min_bg = min_bg + world_size
	max_bg = max_bg + world_size
	story:AddBGNodes(min_bg, max_bg)
	story:InsertAdditionalSetPieces()
	story:ProcessExtraTags()
	    
	SetTimingStat("time", "generate_story", GetTimeReal() - start_time)
	
	--print("\n------------------------------------------------")
	--story.rootNode:Dump()
	--print("\n------------------------------------------------")
	
	return {root=story.rootNode, startNode=story.startNode, GlobalTags = story.GlobalTags, water = story.water_content}
end

function VOLCANO_STORY(tasks, story_gen_params, level)
	print("Building VOLCANO STORY", tasks)
	local start_time = GetTimeReal()
	
	local story = Story("GAME", tasks, terrain, story_gen_params, level)
	story:GenerateNodesFromTasksInlineStart(linkIslandsByKeys)
	story:AddRoadPoison()

	local min_bg = level.background_node_range and level.background_node_range[1] or 0
	local max_bg = level.background_node_range and level.background_node_range[2] or 2
	story:AddBGNodes(min_bg, max_bg)
	story:InsertAdditionalSetPieces()
	story:InsertAdditionalTreasures()
	story:ProcessExtraTags()
	--story:ProcessWaterContent()
	--story:InsertWaterSetPieces()
	    
	SetTimingStat("time", "generate_story", GetTimeReal() - start_time)
	
	--print("\n------------------------------------------------")
	--story.rootNode:Dump()
	--print("\n------------------------------------------------")
	
	return {root=story.rootNode, startNode=story.startNode, GlobalTags = story.GlobalTags, water = story.water_content}
end

