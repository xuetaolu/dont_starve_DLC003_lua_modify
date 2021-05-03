local foods=
{
	butterflymuffin =
	{
		test = function(cooker, names, tags) return names.butterflywings and not tags.meat and tags.veggie end,
		priority = 1,
		weight = 1,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		cooktime = 2,
	},
	
	frogglebunwich =
	{
		test = function(cooker, names, tags) return (names.froglegs or names.froglegs_cooked) and tags.veggie end,
		priority = 1,
		foodtype = "MEAT",
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		cooktime = 2,
		yotp = true,
	},
	
	taffy =
	{
		test = function(cooker, names, tags) return tags.sweetener and tags.sweetener >= 3 and not tags.meat end,
		priority = 10,
		foodtype = "VEGGIE",
		health = -TUNING.HEALING_SMALL,
		hunger = TUNING.CALORIES_SMALL*2,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_MED,
		cooktime = 2,
		tags = {"honeyed"}
	},
	
	pumpkincookie =
	{
		test = function(cooker, names, tags) return (names.pumpkin or names.pumpkin_cooked) and tags.sweetener and tags.sweetener >= 2 end,
		priority = 10,
		foodtype = "VEGGIE",
		health = 0,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_MED,
		cooktime = 2,
		tags = {"honeyed"},
		yotp = true,
	},	
	
	stuffedeggplant =
	{
		test = function(cooker, names, tags) return (names.eggplant or names.eggplant_cooked) and tags.veggie and tags.veggie > 1 end,
		priority = 1,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_SMALL,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		temperature = TUNING.HOT_FOOD_BONUS_TEMP,
		temperatureduration = TUNING.FOOD_TEMP_BRIEF,
		cooktime = 2,
		yotp = true,
	},
	
	fishsticks =
	{
		test = function(cooker, names, tags) return tags.fish and names.twigs and (tags.inedible and tags.inedible <= 1) end,
		priority = 10,
		foodtype = "MEAT",
		health = TUNING.HEALING_LARGE,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_TINY,
		cooktime = 2,
		tags = {"catfood"}
	},
	
	honeynuggets =
	{
		test = function(cooker, names, tags)  return names.honey and tags.meat and tags.meat <= 1.5 and not tags.inedible end,
		priority = 2,
		foodtype = "MEAT",
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		cooktime = 2,
		tags = {"honeyed"},
		yotp = true,
	},
	
	honeyham =
	{
		test = function(cooker, names, tags)  return names.honey and tags.meat and tags.meat > 1.5 and not tags.inedible end,
		priority = 2,
		foodtype = "MEAT",
		health = TUNING.HEALING_MEDLARGE,
		hunger = TUNING.CALORIES_HUGE,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		temperature = TUNING.HOT_FOOD_BONUS_TEMP,
		temperatureduration = TUNING.FOOD_TEMP_AVERAGE,
		cooktime = 2,
		tags = {"honeyed"},
		yotp = true,
	},

	dragonpie =
	{
		test = function(cooker, names, tags)  return (names.dragonfruit or names.dragonfruit_cooked) and not tags.meat end,
		priority = 1,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_LARGE,
		hunger = TUNING.CALORIES_HUGE,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		temperature = TUNING.HOT_FOOD_BONUS_TEMP,
		temperatureduration = TUNING.FOOD_TEMP_AVERAGE,
		cooktime = 2,
		yotp = true,
	},

	kabobs =
	{
		test = function(cooker, names, tags) return tags.meat and names.twigs and (not tags.monster or tags.monster <= 1) and (tags.inedible and tags.inedible <= 1) end,
		priority = 5,
		foodtype = "MEAT",
		health = TUNING.HEALING_SMALL,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		cooktime = 2,
	},

	mandrakesoup =
	{
		test = function(cooker, names, tags) return names.mandrake end,
		priority = 10,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_SUPERHUGE,
		hunger = TUNING.CALORIES_SUPERHUGE,
		perishtime = TUNING.PERISH_FAST,
		sanity = TUNING.SANITY_TINY,
		cooktime = 3,
	},

	baconeggs =
	{
		test = function(cooker, names, tags) return tags.egg and tags.egg > 1 and tags.meat and tags.meat > 1 and not tags.veggie end,
		priority = 10,
		foodtype = "MEAT",
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_HUGE,
		perishtime = TUNING.PERISH_PRESERVED,
		sanity = TUNING.SANITY_TINY,
		cooktime = 2,
	},

	meatballs =
	{
		test = function(cooker, names, tags) return tags.meat and not tags.inedible end,
		priority = -1,
		foodtype = "MEAT",
		health = TUNING.HEALING_SMALL,
		hunger = TUNING.CALORIES_SMALL*5,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_TINY,
		cooktime = .75,
		yotp = true,
	},

	bonestew =
	{
		test = function(cooker, names, tags) return tags.meat and tags.meat >= 3 and not tags.inedible end,
		priority = 0,
		foodtype = "MEAT",
		health = TUNING.HEALING_SMALL*4,
		hunger = TUNING.CALORIES_LARGE*4,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_TINY,
		temperature = TUNING.HOT_FOOD_BONUS_TEMP,
		temperatureduration = TUNING.FOOD_TEMP_LONG,
		cooktime = .75,
	},

	perogies =
	{
		test = function(cooker, names, tags) return tags.egg and tags.meat and tags.veggie and not tags.inedible end,
		priority = 5,
		foodtype = "MEAT",
		health = TUNING.HEALING_LARGE,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_PRESERVED,
		sanity = TUNING.SANITY_TINY,
		cooktime = 1,
		yotp = true,
	},

	turkeydinner =
	{
		test = function(cooker, names, tags) return names.drumstick and names.drumstick > 1 and tags.meat and tags.meat > 1 and (tags.veggie or tags.fruit) end,
		priority = 10,
		foodtype = "MEAT",
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_HUGE,
		perishtime = TUNING.PERISH_FAST,
		sanity = TUNING.SANITY_TINY,
		temperature = TUNING.HOT_FOOD_BONUS_TEMP,
		temperatureduration = TUNING.FOOD_TEMP_AVERAGE,
		cooktime = 3,
		yotp = true,
	},

	ratatouille =
	{
		test = function(cooker, names, tags) return not tags.meat and tags.veggie and not tags.inedible end,
		priority = 0,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_SMALL,
		hunger = TUNING.CALORIES_MED,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		cooktime = 1,
		yotp = true,
	},

	jammypreserves =
	{
		test = function(cooker, names, tags) return tags.fruit and not tags.meat and not tags.veggie and not tags.inedible end,
		priority = 0,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_SMALL,
		hunger = TUNING.CALORIES_SMALL*3,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		cooktime = .5,
	},
	
	fruitmedley =
	{
		test = function(cooker, names, tags) return tags.fruit and tags.fruit >= 3 and not tags.meat and not tags.veggie end,
		priority = 0,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_MED,
		perishtime = TUNING.PERISH_FAST,
		sanity = TUNING.SANITY_TINY,
		temperature = TUNING.COLD_FOOD_BONUS_TEMP,
		temperatureduration = TUNING.FOOD_TEMP_BRIEF,
		cooktime = .5,
	},

	fishtacos =
	{
		test = function(cooker, names, tags) return tags.fish and (names.corn or names.corn_cooked) end,
		priority = 10,
		foodtype = "MEAT",
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_FAST,
		sanity = TUNING.SANITY_TINY,
		cooktime = .5,
	},

	waffles =
	{
		test = function(cooker, names, tags) return names.butter and (names.berries or names.berries_cooked) and tags.egg end,
		priority = 10,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_HUGE,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_FAST,
		sanity = TUNING.SANITY_TINY,
		cooktime = .5,
		yotp = true,
	},	
	
	monsterlasagna =
	{
		test = function(cooker, names, tags) return tags.monster and tags.monster >= 2 and not tags.inedible end,
		priority = 10,
		foodtype = "MEAT",
		health = -TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_FAST,
		sanity = -TUNING.SANITY_MEDLARGE,
		cooktime = .5,
		tags = {"monstermeat"},
		yotp = true,
	},

	powcake =
	{
		test = function(cooker, names, tags) return names.twigs and names.honey and (names.corn or names.corn_cooked) end,
		priority = 10,
		foodtype = "VEGGIE",
		health = -TUNING.HEALING_SMALL,
		hunger = 0,
		perishtime = 9000000,
		sanity = 0,
		cooktime = 0.5,
		tags = {"honeyed"}
	},

	unagi =
	{
		test = function(cooker, names, tags) return names.cutlichen and (names.eel or names.eel_cooked) end,
		priority = 20,
		foodtype = "MEAT",
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_MEDSMALL,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_TINY,
		cooktime = 0.5,
	},
	
	wetgoop =
	{
		test = function(cooker, names, tags) return true end,
		priority = -2,
		health=0,
		hunger=0,
		perishtime = TUNING.PERISH_FAST,
		sanity = 0,
		cooktime = .25,
		wet_prefix = STRINGS.WET_PREFIX.WETGOOP,
	},

	flowersalad =
	{
		test = function(cooker, names, tags) return names.cactus_flower and tags.veggie and tags.veggie >= 2 and not tags.meat and not tags.inedible and not tags.egg and not tags.sweetener and not tags.fruit end,
		priority = 10,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_LARGE,
		hunger = TUNING.CALORIES_SMALL,
		perishtime = TUNING.PERISH_FAST,
		sanity = TUNING.SANITY_TINY,
		cooktime = .5,
		rog_recipe = true,
	},	

	icecream =
	{
		test = function(cooker, names, tags) return tags.frozen and tags.dairy and tags.sweetener and not tags.meat and not tags.veggie and not tags.inedible and not tags.egg end,
		priority = 10,
		foodtype = "VEGGIE",
		health = 0,
		hunger = TUNING.CALORIES_MED,
		perishtime = TUNING.PERISH_SUPERFAST,
		sanity = TUNING.SANITY_HUGE,
		temperature = TUNING.COLD_FOOD_BONUS_TEMP,
		temperatureduration = TUNING.FOOD_TEMP_LONG,
		cooktime = .5,
		rog_recipe = true,
	},	

	watermelonicle =
	{
		test = function(cooker, names, tags) return names.watermelon and tags.frozen and names.twigs and not tags.meat and not tags.veggie and not tags.egg end,
		priority = 10,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_SMALL,
		hunger = TUNING.CALORIES_SMALL,
		perishtime = TUNING.PERISH_SUPERFAST,
		sanity = TUNING.SANITY_MEDLARGE,
		temperature = TUNING.COLD_FOOD_BONUS_TEMP,
		temperatureduration = TUNING.FOOD_TEMP_AVERAGE,
		cooktime = .5,
		rog_recipe = true,
	},	

	trailmix =
	{
		test = function(cooker, names, tags) return names.acorn_cooked and tags.seed and tags.seed >= 1 and (names.berries or names.berries_cooked) and tags.fruit and tags.fruit >= 1 and not tags.meat and not tags.veggie and not tags.egg and not tags.dairy end,
		priority = 10,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_MEDLARGE,
		hunger = TUNING.CALORIES_SMALL,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		cooktime = .5,
		rog_recipe = true,
	},

	hotchili =
	{
		test = function(cooker, names, tags) return tags.meat and tags.veggie and tags.meat >= 1.5 and tags.veggie >= 1.5 end,
		priority = 10,
		foodtype = "MEAT",
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_MED,
		sanity = 0,
		temperature = TUNING.HOT_FOOD_BONUS_TEMP,
		temperatureduration = TUNING.FOOD_TEMP_LONG,
		cooktime = .5,
		rog_recipe = true,
	},	

	guacamole = 
	{
		test = function(cooker, names, tags) return names.mole and names.cactus_meat and not tags.fruit end,
		priority = 10,
		foodtype = "MEAT",
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_MED,
		sanity = 0,
		cooktime = .5,
		rog_recipe = true,
	},

	--Shipwrecked--

	californiaroll = 
	{
		test = function(cooker, names, tags) return (names.seaweed and names.seaweed == 2) and (tags.fish and tags.fish >= 1) end,
		priority = 20,
		foodtype = "MEAT",
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_SMALL,
		cooktime = .5,
	},

	seafoodgumbo = 
	{
		test = function(cooker, names, tags) return tags.fish and tags.fish > 2 end,
		priority = 10,
		foodtype = "MEAT",
		health = TUNING.HEALING_LARGE,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_MEDLARGE,
		cooktime = 1,
	},

	bisque = 
	{
		test = function(cooker, names, tags) return names.limpets and names.limpets == 3 and tags.frozen end,
		priority = 30,
		foodtype = "MEAT",
		health = TUNING.HEALING_HUGE,
		hunger = TUNING.CALORIES_MEDSMALL,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_TINY,
		cooktime = 1,
	},

	ceviche = 
	{
		test = function(cooker, names, tags) return tags.fish and tags.fish >= 2 and tags.frozen end,
		priority = 20,
		foodtype = "MEAT",
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_MED,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_TINY,
		temperature = TUNING.COLD_FOOD_BONUS_TEMP,
		temperatureduration = TUNING.FOOD_TEMP_AVERAGE,
		cooktime = 0.5,
	},

	jellyopop = 
	{
		test = function(cooker, names, tags) return tags.jellyfish and tags.frozen and tags.inedible end,
		priority = 20,
		foodtype = "MEAT",
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_SMALL,
		perishtime = TUNING.PERISH_SUPERFAST,
		sanity = 0,
		temperature = TUNING.COLD_FOOD_BONUS_TEMP,
		temperatureduration = TUNING.FOOD_TEMP_AVERAGE,
		cooktime = 0.5,
	},

	bananapop = 
	{
		test = function(cooker, names, tags) return names.cave_banana and tags.frozen and tags.inedible and not tags.meat and not tags.fish end,
		priority = 20,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_SMALL,
		perishtime = TUNING.PERISH_SUPERFAST,
		sanity = TUNING.SANITY_LARGE,
		temperature = TUNING.COLD_FOOD_BONUS_TEMP,
		temperatureduration = TUNING.FOOD_TEMP_AVERAGE,
		cooktime = 0.5,
	},

	lobsterbisque = 
	{
		test = function(cooker, names, tags) return names.lobster and tags.frozen end,
		priority = 30,
		foodtype = "MEAT",
		health = TUNING.HEALING_HUGE,
		hunger = TUNING.CALORIES_MED,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_SMALL,
		cooktime = 0.5,
	},

	lobsterdinner = 
	{
		test = function(cooker, names, tags) return names.lobster and names.butter and not tags.meat and not tags.frozen end,
		priority = 25,
		foodtype = "MEAT",
		health = TUNING.HEALING_HUGE,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_HUGE,
		cooktime = 1,
	},

	sharkfinsoup = 
	{
		test = function(cooker, names, tags) return names.shark_fin end,
		priority = 20,
		foodtype = "MEAT",
		health = TUNING.HEALING_LARGE,
		hunger = TUNING.CALORIES_SMALL,
		perishtime = TUNING.PERISH_MED,
		sanity = -TUNING.SANITY_SMALL,
		naughtiness = 10,
		cooktime = 1,
	},

	surfnturf = 
	{
		test = function(cooker, names, tags) return tags.meat and tags.meat >= 2.5 and tags.fish and tags.fish >= 1.5 and not tags.frozen end,
		priority = 30,
		foodtype = "MEAT",
		health = TUNING.HEALING_HUGE,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_LARGE,
		cooktime = 1,
	},

	coffee = 
	{
		test = function(cooker, names, tags) return names.coffeebeans_cooked and (names.coffeebeans_cooked == 4 or (names.coffeebeans_cooked == 3 and (tags.dairy or tags.sweetener)))	end,
		priority = 30,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_SMALL,
		hunger = TUNING.CALORIES_TINY,
		perishtime = TUNING.PERISH_MED,
		sanity = -TUNING.SANITY_TINY,
		caffeinedelta = TUNING.CAFFEINE_FOOD_BONUS_SPEED,
		caffeineduration = TUNING.FOOD_SPEED_LONG,
		cooktime = 0.5,
	},

	tropicalbouillabaisse =
	{
		test = function(cooker, names, tags) return (names.fish3 or names.fish3_cooked) and (names.fish4 or names.fish4_cooked) and (names.fish5 or names.fish5_cooked) and tags.veggie end,
		priority = 35,
		foodtype = "MEAT",
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_MED,
		cooktime = 2,
		boost_dry = 		true,
		boost_cool = 		true,
		boost_surf = 		true,
	},

	caviar =
	{
		test = function(cooker, names, tags) return (names.roe or names.roe_cooked == 3) and tags.veggie end,
		priority = 20,
		foodtype = "MEAT",
		health = TUNING.HEALING_SMALL,
		hunger = TUNING.CALORIES_SMALL,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_LARGE,
		cooktime = 2,
	},	

	nettlelosange =
	{
		test = function(cooker, names, tags) return tags.antihistamine and tags.antihistamine >= 3  end,
		priority = 0,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_MED,
		perishtime = TUNING.PERISH_FAST,
		sanity = TUNING.SANITY_TINY,
		antihistamine = 720,
		cooktime = .5,
		yotp = true,
	},

	snakebonesoup = 
	{
		test = function(cooker, names, tags) return tags.bone and tags.bone >= 2 and tags.meat and tags.meat >= 2 end,
		priority = 20,
		foodtype = "MEAT",
		health = TUNING.HEALING_LARGE,
		hunger = TUNING.CALORIES_MED,
		perishtime = TUNING.PERISH_MED,
		sanity = TUNING.SANITY_SMALL,
		cooktime = 1,
		yotp = true,
	},

	tea = 
	{
		test = function(cooker, names, tags) return tags.filter and tags.filter >= 2 and tags.sweetener and not tags.meat and not tags.veggie and not tags.inedible end,
		priority = 25,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_SMALL,
		hunger = TUNING.CALORIES_SMALL,
		perishtime = TUNING.PERISH_ONE_DAY,
		sanity = TUNING.SANITY_LARGE,
		caffeinedelta = TUNING.CAFFEINE_FOOD_BONUS_SPEED/2,
		caffeineduration = TUNING.FOOD_SPEED_LONG/2,		
		temperaturebump = 15,
		cooktime = 0.5,
		spoiled_product = "icedtea",
		yotp = true,
	},	

	icedtea = 
	{
		test = function(cooker, names, tags) return tags.filter and tags.filter >= 2 and tags.sweetener and tags.frozen end,
		priority = 30,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_SMALL,
		hunger = TUNING.CALORIES_SMALL,
		perishtime = TUNING.PERISH_FAST,
		sanity = TUNING.SANITY_LARGE,
		caffeinedelta = TUNING.CAFFEINE_FOOD_BONUS_SPEED/3,
		caffeineduration = TUNING.FOOD_SPEED_LONG/3,		
		temperaturebump = -10,
		cooktime = 0.5,
		yotp = true,
	},		

	asparagussoup = 
	{
		test = function(cooker, names, tags) return (names.asparagus or names.asparagus_cooked) and tags.veggie and tags.veggie > 1 end,
		priority = 10,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_MEDSMALL,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,	
		cooktime = 0.5,
		yotp = true,
	},	

	spicyvegstinger = 
	{
		test = function(cooker, names, tags) return (names.asparagus or names.asparagus_cooked or names.radish or names.radish_cooked) and tags.veggie and tags.veggie > 2 and tags.frozen and not tags.meat end,
		priority = 15,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_SMALL,
		hunger = TUNING.CALORIES_MED,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_LARGE,	
		cooktime = 0.5,
		yotp = true,
	},

	feijoada = 
	{
		test = function(cooker, names, tags) return tags.meat and (names.jellybug == 3) or (names.jellybug_cooked == 3) or
						(names.jellybug and names.jellybug_cooked and names.jellybug + names.jellybug_cooked == 3) end,

		priority = 30,
		foodtype = "MEAT",
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_HUGE,
		perishtime = TUNING.PERISH_FASTISH,
		sanity = TUNING.SANITY_MED,
		cooktime = 3.5,
		yotp = true,
	},
    
	steamedhamsandwich =
	{
		test = function(cooker, names, tags) return (names.meat or names.meat_cooked) and (tags.veggie and tags.veggie >= 2) and names.foliage end,
		priority = 5,
		foodtype = "MEAT",
		health = TUNING.HEALING_LARGE,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_FAST,
		sanity = TUNING.SANITY_MED,
		cooktime = 2,
		yotp = true,
	},

	hardshell_tacos = 
	{
		test = function(cooker, names, tags) return (names.weevole_carapace == 2) and  tags.veggie end,

		priority = 1,
		foodtype = "VEGGIE",
		health = TUNING.HEALING_MED,
		hunger = TUNING.CALORIES_LARGE,
		perishtime = TUNING.PERISH_SLOW,
		sanity = TUNING.SANITY_TINY,
		cooktime = 1,
		yotp = true,
	},

	gummy_cake = 
	{
		test = function(cooker, names, tags) return (names.slugbug or names.slugbug_cooked) and tags.sweetener end,

		priority = 1,
		foodtype = "MEAT",
		health = -TUNING.HEALING_SMALL,
		hunger = TUNING.CALORIES_SUPERHUGE,
		perishtime = TUNING.PERISH_PRESERVED,
		sanity = -TUNING.SANITY_TINY,
		cooktime = 2,
		yotp = true,
	},		
}

for k,v in pairs(foods) do
	v.name = k
	v.weight = v.weight or 1
	v.priority = v.priority or 0
end

return foods