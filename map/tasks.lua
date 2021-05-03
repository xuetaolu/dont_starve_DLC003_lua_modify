------------------------------------------------------------------------------------------
---------             SAMPLE TASKS                   --------------------------------------
------------------------------------------------------------------------------------------
require("map/task")
require("map/lockandkey")
require("map/terrain")

SIZE_VARIATION = 3

local tasklist = {}
function AddTask(name, data)
	table.insert(tasklist, Task(name, data))
end

local function GetTaskByName(name, tasks)
	for i,task in ipairs(tasks) do 
		if task.id == name then
			return task
		end
	end

	return nil
end

-- A set of tasks to be performed 
local everything_sample2 = {
	Task("One of everything", {
		locks=LOCKS.NONE,
		keys_given=KEYS.PICKAXE,
		room_choices={
			["DenseRocks"] = 1,
			["DenseForest"] = 1,
			["SpiderCon"] = 3,
			["Forest"] = 1, 
		 }, 
		room_bg=GROUND.GRASS,
		background_room="BGGrass",
		colour={r=0,g=1,b=0,a=1}
	}) 
}
local everything_sample = {
	Task("One of everything", {
		locks=LOCKS.NONE, 
		keys_given=KEYS.PICKAXE, 
		room_choices={
			["Graveyard"] = 1, 
			["BeefalowPlain"] = 1, 		
			["SpiderVillage"] = 1, 
			["PigKingdom"] = 1, 
			["PigVillage"] = 1, 
			["MandrakeHome"] = 1,
			["BeeClearing"] = 1,
			["DenseRocks"] = 1,
			["DenseForest"] = 1,
			["Rockpile"] = 1,
			["Woodpile"] = 1,
			["Trapfield"] = 1,
			["Minefield"] = 1,
			["SpiderCon"] = 1,
			["Forest"] = 1, 
			["Rocky"] = 1, 
			["BarePlain"] = 1, 
			["Plain"] = 1, 
			["Marsh"] = 1, 
			["DeepForest"] = 1, 
			["Clearing"] = 1,
			["BurntForest"] = 1,
		}, 
		room_bg=GROUND.GRASS,
		background_room="BGGrass",
	 	colour={r=0,g=1,b=0,a=1}
	}) 
}

local params = nil

if rawget(_G, "GEN_PARAMETERS") ~= nil then
	params = json.decode(GEN_PARAMETERS)
end

if params == nil or (params.level_type == "porkland") then
	require ("map/tasks/porkland")
elseif (params.ROGEnabled or params.level_type == "shipwrecked" or params.level_type == "volcano") then
	require ("map/sw_tasks")
else
	require ("map/standard_tasks")
end

tasks = {
	sampletasks = tasklist,
	oneofeverything = everything_sample,
	GetTaskByName = GetTaskByName,
}
