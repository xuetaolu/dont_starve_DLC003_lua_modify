Task = Class(function(self, id, data)
	-- print("Task ",id)
	-- dumptable(data,1)
	self.id = id
	
	-- what locks this task
	self.locks = data.locks
	if type(self.locks) ~= "table" then
		self.locks = { self.locks }
	end
	-- the key that this task provides
	self.keys_given = data.keys_given
	if type(self.keys_given) ~= "table" then
		self.keys_given = { self.keys_given }
	end
	
	self.entrance_room = data.entrance_room
	self.entrance_room_chance = data.entrance_room_chance
	self.room_choices = data.room_choices
	self.room_choices_special = data.room_choices_special
	self.room_bg = data.room_bg
	self.background_room = data.background_room
	self.colour = data.colour
	self.maze_tiles = data.maze_tiles
	self.crosslink_factor = data.crosslink_factor
	self.make_loop = data.make_loop
	self.gen_method = data.gen_method or "default"
	self.background_node_range = data.background_node_range

	self.set_pieces = data.set_pieces or {}
	self.random_set_pieces = data.random_set_pieces or {}
	self.numrandom_set_pieces = data.numrandom_set_pieces or 0

	self.treasures = data.treasures or {}
	self.random_treasures = data.random_treasures or {}
	self.numrandom_treasures = data.numrandom_treasures or 0
end)



