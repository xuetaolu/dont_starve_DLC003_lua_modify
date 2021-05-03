AddTask("Volcano", {
		locks=LOCKS.NONE,
		keys_given={KEYS.ISLAND1},
		crosslink_factor=0,
		make_loop=true,
		gen_method = "volcano",
		room_choices={
			{
				["VolcanoLava"] = 6 + math.random(0, 1)
			},
			{
				["VolcanoNoise"] = 10 + math.random(0, 1)
			},
			{
				["VolcanoNoise"] = 13 + math.random(0, 1)
			},
			{
				["VolcanoStart"] = 1,
				["VolcanoAltar"] = 1,
				["VolcanoObsidianBench"] = 1,
				["VolcanoCage"] = 1,
				["VolcanoNoise"] = 13 + math.random(0, 1)
			},
		}, 
		room_bg=GROUND.VOLCANO,
		--background_room={"Volcano"},
		colour={r=1,g=1,b=0,a=1}
	})