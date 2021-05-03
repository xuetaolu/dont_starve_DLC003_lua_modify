TUNING = {}


function Tune(overrides)
	if overrides == nil then
		overrides = {}
	end

	local seg_time = 30 --each segment of the clock is 30 seconds
	local total_day_time = seg_time*16

	local day_segs = 10
	local dusk_segs = 4
	local night_segs = 2

	--default day composition. changes in winter, etc
	local day_time = seg_time * day_segs
	local dusk_time = seg_time * dusk_segs
	local night_time = seg_time * night_segs

	local wilson_attack = 34
	local wilson_health = 150
	local calories_per_day = 75

	local wilson_attack_period = .5
	-----------------------

	local perish_warp = 1--/200

	TUNING =
	{
		DEMO_TIME = total_day_time * 2 + day_time*.2,
		AUTOSAVE_INTERVAL = total_day_time,
	    SEG_TIME = seg_time,
	    TOTAL_DAY_TIME = total_day_time,
		DAY_SEGS_DEFAULT = day_segs,
		DUSK_SEGS_DEFAULT = dusk_segs,
		NIGHT_SEGS_DEFAULT = night_segs,

		STACK_SIZE_LARGEITEM = 10,
		STACK_SIZE_MEDITEM = 20,
		STACK_SIZE_SMALLITEM = 40,

		GOLDENTOOLFACTOR = 4,
		OBSIDIANTOOLFACTOR = 2.5,
		OBSIDIANTOOL_WORK = 2.5,

	    DARK_CUTOFF = 0,
	    DARK_SPAWNCUTOFF = 0.1,
	    WILSON_HEALTH = wilson_health,
	    WILSON_ATTACK_PERIOD = .5,
	    WILSON_HUNGER = 150, --stomach size
	    WILSON_HUNGER_RATE = calories_per_day/total_day_time, --calories burnt per day

	    WX78_MIN_HEALTH = 100,
	    WX78_MIN_HUNGER = 100,
	    WX78_MIN_SANITY = 100,

	    WX78_MAX_HEALTH = 400,
	    WX78_MAX_HUNGER = 200,
	    WX78_MAX_SANITY = 300,

	    WILSON_SANITY = 200,
	    WILLOW_SANITY = 120,

	    HAMMER_LOOT_PERCENT = .5,
	    BURNT_HAMMER_LOOT_PERCENT = .25,
	    AXE_USES = 100,
	    HAMMER_USES = 75,
	    SHOVEL_USES = 25,
	    PITCHFORK_USES = 25,
	    PICKAXE_USES = 33,
	    BUGNET_USES = 10,
	    SPEAR_USES = 150,
	    WATHGRITHR_SPEAR_USES = 200,
	    SPIKE_USES = 100,
	    FISHINGROD_USES = 9,
	    FISHINGROD_MIN_WAIT_TIME = 4,
	    FISHINGROD_MAX_WAIT_TIME = 40,
	    TRAP_USES = 8,
	    BOOMERANG_USES = 10,
	    BOOMERANG_DISTANCE = 12,
	    NIGHTSWORD_USES = 100,
	    ICESTAFF_USES = 20,
	    FIRESTAFF_USES = 20,
	    TELESTAFF_USES = 5,
	    HAMBAT_USES = 100,
	    BATBAT_USES = 75,
	    MULTITOOL_AXE_PICKAXE_USES = 400,
	    RUINS_BAT_USES = 150,
	    LITTLE_HAMMER_USES = 10,
	    CORK_BAT_USES = 20,

	    AXTINGUISHER_USES = 250,
		FLAREGUN_USES = 30,

	    REDAMULET_USES = 20,
	    REDAMULET_CONVERSION = 5,

	    BLUEAMULET_FUEL = total_day_time * 0.75,
	    BLUEGEM_COOLER = -20,


		PURPLEAMULET_FUEL = total_day_time * 0.4,

		YELLOWAMULET_FUEL = total_day_time,
		YELLOWSTAFF_USES = 20,

		ORANGEAMULET_USES = 225,
		ORANGEAMULET_RANGE = 4,
		ORANGEAMULET_ICD = 0.33,
		ORANGESTAFF_USES = 20,

		GREENAMULET_USES = 5,
		GREENAMULET_INGREDIENTMOD = 0.5,
		GREENSTAFF_USES = 5,

		BRUSH_USES = 75,


	    FISHING_MINWAIT = 2,
	    FISHING_MAXWAIT = 20,

		RESEARCH_MACHINE_DIST = 4,

	    UNARMED_DAMAGE = 10,
	    NIGHTSWORD_DAMAGE = wilson_attack*2,
	    -------
	    BATBAT_DAMAGE = wilson_attack * 1.25,
	    BATBAT_DRAIN = wilson_attack * 0.2,
		-------
	    SPIKE_DAMAGE = wilson_attack*1.5,
		HAMBAT_DAMAGE = wilson_attack*1.75,
		HAMBAT_MIN_DAMAGE_MODIFIER = .5,
	    SPEAR_DAMAGE = wilson_attack,
	    WATHGRITHR_SPEAR_DAMAGE = wilson_attack * 1.25,
	    AXE_DAMAGE = wilson_attack*.8,
	    PICK_DAMAGE = wilson_attack*.8,
	    BOOMERANG_DAMAGE = wilson_attack*.8,
	    TORCH_DAMAGE = wilson_attack*.5,
	    HAMMER_DAMAGE = wilson_attack*.5,
	    SHOVEL_DAMAGE = wilson_attack*.5,
	    PITCHFORK_DAMAGE = wilson_attack*.5,
	    BUGNET_DAMAGE = wilson_attack*.125,
	    FISHINGROD_DAMAGE = wilson_attack*.125,
	    UMBRELLA_DAMAGE = wilson_attack*.5,
	    CANE_DAMAGE = wilson_attack*.5,
	    WALKING_STICK_DAMAGE = wilson_attack*.6,
	    BEAVER_DAMAGE = wilson_attack*1.5,
	    WEREWILBA_DAMAGE = wilson_attack*1.75,
	    MULTITOOL_DAMAGE = wilson_attack*.9,
	    RUINS_BAT_DAMAGE = wilson_attack * 1.75,
	    NIGHTSTICK_DAMAGE = wilson_attack*.85, -- Due to the damage being electric, it will get multiplied by 1.5 against any mob
	    OBSIDIAN_SPEAR_DAMAGE = wilson_attack * 1.5, --Deals up to double damage with use.
	    PIG_RUINS_DART_DAMAGE = wilson_attack,
	    MAGNIFYING_GLASS_DAMAGE = wilson_attack *.125,
	    CORK_BAT_DAMAGE = wilson_attack * 1.5,
	    BRUSH_DAMAGE = wilson_attack*.8,
	    
	    TRUSTY_SHOOTER_DAMAGE_HIGH = 60,
	    TRUSTY_SHOOTER_DAMAGE_MEDIUM = 45,
	    TRUSTY_SHOOTER_DAMAGE_LOW = wilson_attack,

	    TRUSTY_SHOOTER_ATTACK_RANGE_HIGH = 11,
		TRUSTY_SHOOTER_ATTACK_RANGE_MEDIUM = 9,
		TRUSTY_SHOOTER_ATTACK_RANGE_LOW = 7,

		TRUSTY_SHOOTER_HIT_RANGE_HIGH = 13,
		TRUSTY_SHOOTER_HIT_RANGE_MEDIUM = 11,
		TRUSTY_SHOOTER_HIT_RANGE_LOW = 9,

		TRUSTY_SHOOTER_TIERS = 
		{
			AMMO_HIGH = {
				"gears",
			    "purplegem",
				"bluegem",
				"redgem",
				"orangegem",
				"yellowgem",
				"greengem",
			    "oinc10",
			    "oinc100",
			    "nightmarefuel",
			    "gunpowder",
			    "relic_1",
			    "relic_2",
			    "relic_3",
			    "relic_4",
			    "relic_5",
			},

			AMMO_LOW = 
			{
				"feather_crow",
				"feather_robin",
				"feather_robin_winter",
				"feather_thunder",
				"ash",
				"beardhair",
				"beefalowool",
				"butterflywings",
				"clippings",
				"cutgrass",
				"cutreeds",
				"foliage",
				"palmleaf",
				"papyrus",
				"petals",
				"petals_evil",
				"pigskin",
				"silk",
				"seaweed",
			},
		},

		LITTLE_HAMMER_DAMAGE = wilson_attack*0.3,
	    SHEARS_DAMAGE = wilson_attack * .5,
	    SHEARS_USES = 20,

	    MAGNIFYING_GLASS_USES = 10,

		HALBERD_DAMAGE = wilson_attack*1.3,
		HALBERD_USES = 100,

		CANE_SPEED_MULT = 0.25,
		WALKING_STICK_SPEED_MULT = 0.3,
		PIGGYBACK_SPEED_MULT = -0.1,
		YELLOW_AMULET_SPEED_MULT = 0.2,
		ICE_HAT_SPEED_MULT = -0.1,
		RUINS_BAT_SPEED_MULT = 0.1,

	    TORCH_ATTACK_IGNITE_PERCENT = 1,

	    SPRING_COMBAT_MOD = 1.33,

	    PIG_DAMAGE = 33,
	    PIG_HEALTH = 250,
	    PIG_ATTACK_PERIOD = 3,
	    PIG_TARGET_DIST = 16,
	    PIG_LOYALTY_MAXTIME = 2.5*total_day_time,
	    PIG_LOYALTY_PER_HUNGER = total_day_time/25,
	    PIG_MIN_POOP_PERIOD = seg_time * .5,

	    SPIDER_LOYALTY_MAXTIME = 2.5*total_day_time,
	    SPIDER_LOYALTY_PER_HUNGER = total_day_time/25,

	    WEREPIG_DAMAGE = 40,
	    WEREPIG_HEALTH = 350,
	    WEREPIG_ATTACK_PERIOD = 2,

	    PIG_GUARD_DAMAGE = 33,
	    PIG_GUARD_HEALTH = 300,
	    PIG_GUARD_ATTACK_PERIOD = 1.5,
	    PIG_GUARD_TARGET_DIST = 8,
	    PIG_GUARD_DEFEND_DIST = 20,	    

	    PIG_BANDIT_DAMAGE = 33,
	    PIG_BANDIT_HEALTH = 250,
	    PIG_BANDIT_ATTACK_PERIOD = 3,
	    PIG_BANDIT_TARGET_DIST = 16,
	    PIG_BANDIT_LOYALTY_MAXTIME = 2.5*total_day_time,
	    PIG_BANDIT_LOYALTY_PER_HUNGER = total_day_time/25,
	    PIG_BANDIT_MIN_POOP_PERIOD = seg_time * .5,
	    PIG_BANDIT_TARGET_DIST = 16,

	    CITY_PIG_GUARD_TARGET_DIST = 20,

	    PIG_RUN_SPEED = 5,
	    PIG_WALK_SPEED = 3,

	    WEREPIG_RUN_SPEED = 7,
	    WEREPIG_WALK_SPEED = 3,

	    PIG_BANDIT_RUN_SPEED = 7,
	    PIG_BANDIT_WALK_SPEED = 3,

	    WILSON_WALK_SPEED = 4,
	    WILSON_RUN_SPEED = 6,

	    PERD_SPAWNCHANCE = 0.1,
	    PERD_DAMAGE = 20,
	    PERD_HEALTH = 50,
	    PERD_ATTACK_PERIOD = 3,
	    PERD_RUN_SPEED = 8,
	    PERD_WALK_SPEED = 3,

	    THUNDERBIRD_RUN_SPEED = 5.5,
	    THUNDERBIRD_WALK_SPEED = 2,

	    MERM_DAMAGE = 30,
	    MERM_HEALTH = 250,
	    MERM_ATTACK_PERIOD = 3,
	    MERM_RUN_SPEED = 8,
	    MERM_WALK_SPEED = 3,
	    MERM_TARGET_DIST = 10,
	    MERM_DEFEND_DIST = 30,

	    MERM_FISHER_HEALTH = 150,

	    WALRUS_DAMAGE = 33,
	    WALRUS_HEALTH = 150,
	    WALRUS_ATTACK_PERIOD = 3,
	    WALRUS_ATTACK_DIST = 15,
	    WALRUS_DART_RANGE = 25,
        WALRUS_MELEE_RANGE = 5,
        WALRUS_TARGET_DIST = 10,
        WALRUS_LOSETARGET_DIST = 30,
        WALRUS_REGEN_PERIOD = total_day_time*2.5,

        LITTLE_WALRUS_DAMAGE = 22,
        LITTLE_WALRUS_HEALTH = 100,
        LITTLE_WALRUS_ATTACK_PERIOD = 3 * 1.7,
        LITTLE_WALRUS_ATTACK_DIST = 15,

        PIPE_DART_DAMAGE = 100,

	    PENGUIN_DAMAGE = 33,
	    PENGUIN_HEALTH = 150,
	    PENGUIN_ATTACK_PERIOD = 3,
	    PENGUIN_ATTACK_DIST = 2.5,
	    PENGUIN_MATING_SEASON_LENGTH = 6,
	    PENGUIN_MATING_SEASON_WAIT = 1,
	    PENGUIN_MATING_SEASON_BABYDELAY = total_day_time*1.5,
	    PENGUIN_MATING_SEASON_BABYDELAY_VARIANCE = 0.5*total_day_time,
	    PENGUIN_TARGET_DIST = 15,
	    PENGUIN_CHASE_DIST = 30,
	    PENGUIN_FOLLOW_TIME = 10,
	    PENGUIN_HUNGER = total_day_time * 12,  -- takes all winter to starve
	    PENGUIN_STARVE_TIME = total_day_time * 12,
	    PENGUIN_STARVE_KILL_TIME = 20,

	    KNIGHT_DAMAGE = 40,
	    KNIGHT_HEALTH = 300,
	    KNIGHT_ATTACK_PERIOD = 2,
	    KNIGHT_WALK_SPEED = 5,
	    KNIGHT_TARGET_DIST = 10,

	    BISHOP_DAMAGE = 40,
	    BISHOP_HEALTH = 300,
	    BISHOP_ATTACK_PERIOD = 4,
	    BISHOP_ATTACK_DIST = 6,
	    BISHOP_WALK_SPEED = 5,
	    BISHOP_TARGET_DIST = 12,

	    ROOK_DAMAGE = 45,
	    ROOK_HEALTH = 300,
	    ROOK_ATTACK_PERIOD = 2,
	    ROOK_WALK_SPEED = 5,
	    ROOK_RUN_SPEED = 16,
	    ROOK_TARGET_DIST = 12,

	    MINOTAUR_DAMAGE = 100,
	    MINOTAUR_HEALTH = 2500,
	    MINOTAUR_ATTACK_PERIOD = 2,
	    MINOTAUR_WALK_SPEED = 5,
	    MINOTAUR_RUN_SPEED = 17,
	    MINOTAUR_TARGET_DIST = 25,

	    SLURTLE_DAMAGE = 25,
	    SLURTLE_HEALTH = 600,
	    SLURTLE_ATTACK_PERIOD = 4,
	    SLURTLE_ATTACK_DIST = 2.5,
	    SLURTLE_WALK_SPEED = 3,
	    SLURTLE_TARGET_DIST = 10,
	    SLURTLE_SHELL_ABSORB = 0.95,
	    SLURTLE_DAMAGE_UNTIL_SHIELD = 150,

	    SLURTLE_EXPLODE_DAMAGE = 300,
	    SLURTLESLIME_EXPLODE_DAMAGE = 50,

	   	SNURTLE_WALK_SPEED = 4,
	    SNURTLE_DAMAGE = 5,
	    SNURTLE_HEALTH = 200,
	    SNURTLE_SHELL_ABSORB = 0.8,
	    SNURTLE_DAMAGE_UNTIL_SHIELD = 10,
	    SNURTLE_EXPLODE_DAMAGE = 300,

	    LIGHTNING_DAMAGE = 10,
		LIGHTING_HITTARGET_CHANCE = 0.3,

	    ELECTRIC_WET_DAMAGE_MULT = 1,
	    ELECTRIC_DAMAGE_MULT = 1.5,

	    LIGHTNING_GOAT_DAMAGE = 25,
	    LIGHTNING_GOAT_ATTACK_RANGE = 3,
	    LIGHTNING_GOAT_ATTACK_PERIOD = 2,
	    LIGHTNING_GOAT_WALK_SPEED = 4,
	    LIGHTNING_GOAT_RUN_SPEED = 8,
	    LIGHTNING_GOAT_TARGET_DIST = 5,
	    LIGHTNING_GOAT_CHASE_DIST = 30,
	    LIGHTNING_GOAT_FOLLOW_TIME = 30,
	    LIGHTNING_GOAT_MATING_SEASON_BABYDELAY = total_day_time*1.5,
	    LIGHTNING_GOAT_MATING_SEASON_BABYDELAY_VARIANCE = 0.5*total_day_time,

	    BUZZARD_DAMAGE = 15,
	    BUZZARD_ATTACK_RANGE = 2,
	    BUZZARD_ATTACK_PERIOD = 2,
	    BUZZARD_WALK_SPEED = 4,
	    BUZZARD_RUN_SPEED = 8,
	    BUZZARD_HEALTH = 125,

	    FREEZING_KILL_TIME = 120,
	    STARVE_KILL_TIME = 120,
	    HUNGRY_THRESH = .333,

	    GRUEDAMAGE = wilson_health*.667,

	    MARSHBUSH_DAMAGE = wilson_health*.02,
	    CACTUS_DAMAGE = wilson_health*.04,

	    GHOST_SPEED = 2,
	    GHOST_HEALTH = 200,
	    GHOST_RADIUS = 1.8,
	    GHOST_DAMAGE = wilson_health*0.1,
	    GHOST_DMG_PERIOD = 1.2,
	    GHOST_DMG_PLAYER_PERCENT = 1,

	    ABIGAIL_SPEED = 5,
	    ABIGAIL_HEALTH = wilson_health*4,
	    ABIGAIL_DAMAGE_PER_SECOND = 20,
	    ABIGAIL_DMG_PERIOD = 1.5,
	    ABIGAIL_DMG_PLAYER_PERCENT = 0.25,

	    MIN_LEAF_CHANGE_TIME = .1 * day_time,
	    MAX_LEAF_CHANGE_TIME = 3 * day_time,
	    MIN_SWAY_FX_FREQUENCY = 1 * seg_time,
	    MAX_SWAY_FX_FREQUENCY = 2 * seg_time,
	    SWAY_FX_FREQUENCY = 1 * seg_time,

		EVERGREEN_GROW_TIME =
	    {
	        {base=1.5*day_time, random=0.5*day_time},   --short
	        {base=5*day_time, random=2*day_time},   --normal
	        {base=5*day_time, random=2*day_time},   --tall
	        {base=1*day_time, random=0.5*day_time}   --old
	    },
	    
	    PINECONE_GROWTIME = {base=0.75*day_time, random=0.25*day_time},
	    EVERGREEN_CHOPS_SMALL = 5,
	    EVERGREEN_CHOPS_NORMAL = 10,
	    EVERGREEN_CHOPS_TALL = 15,
	    EVERGREEN_WINDBLOWN_SPEED = 0.2,
	    EVERGREEN_WINDBLOWN_FALL_CHANCE = 0.01,

	    DECIDUOUS_GROW_TIME =
	    {
	        {base=1.5*day_time, random=0.5*day_time},   --short
	        {base=5*day_time, random=2*day_time},   --normal
	        {base=5*day_time, random=2*day_time},   --tall
	        {base=1*day_time, random=0.5*day_time}   --old
	    },

	    ACORN_GROWTIME = {base=0.75*day_time, random=0.25*day_time},
	   	DECIDUOUS_CHOPS_SMALL = 5,
	    DECIDUOUS_CHOPS_NORMAL = 10,
	    DECIDUOUS_CHOPS_TALL = 15,
	    DECIDUOUS_CHOPS_MONSTER = 12,
	    DECIDUOUS_WINDBLOWN_SPEED = 0.2,
	    DECIDUOUS_WINDBLOWN_FALL_CHANCE = 0.01,

	    MUSHTREE_CHOPS_SMALL = 10,
	    MUSHTREE_CHOPS_MEDIUM = 10,
	    MUSHTREE_CHOPS_TALL = 15,

	    HONEY_LANTERN_MINE = 6,
	    HONEY_LANTERN_MINE_MED = 4,
	    HONEY_LANTERN_MINE_LOW = 2,

	    HONEY_CHEST_MINE = 6,
	    HONEY_CHEST_MINE_MED = 4,
	    HONEY_CHEST_MINE_LOW = 2,

	    ICE_MINE = 6,
	    ROCKS_MINE_GIANT = 10,
	    ROCKS_MINE = 6,
	    ROCKS_MINE_MED = 4,
	    ROCKS_MINE_LOW = 2,
	    SPILAGMITE_SPAWNER = 2,
	    SPILAGMITE_ROCK = 4,
	    MARBLEPILLAR_MINE = 10,
	    MARBLETREE_MINE = 8,

        BEEFALO_HEALTH = 500, 
        BEEFALO_DAMAGE =
        {
            DEFAULT = 34,
            RIDER = 25,
            ORNERY = 50,
            PUDGY = 20,
        },        
        BEEFALO_HEALTH_REGEN_PERIOD = 10,
        BEEFALO_HEALTH_REGEN = (500*2)/(total_day_time*3)*10,

        BEEFALO_MATING_SEASON_LENGTH = 3,
        BEEFALO_MATING_SEASON_WAIT = 20,
        BEEFALO_MATING_SEASON_BABYDELAY = total_day_time*1.5,
        BEEFALO_MATING_SEASON_BABYDELAY_VARIANCE = 0.5*total_day_time,
        BEEFALO_TARGET_DIST = 5,
        BEEFALO_CHASE_DIST = 30,
        BEEFALO_FOLLOW_TIME = 30,
        BEEFALO_HUNGER = (calories_per_day*4)/0.8, -- so a 0.8 fullness lasts a day
        BEEFALO_HUNGER_RATE = (calories_per_day*4)/total_day_time,
        BEEFALO_WALK_SPEED = 1.0,
        BEEFALO_RUN_SPEED =
        {
            DEFAULT = 7,
            RIDER = 8.0,
            ORNERY = 7.0,
            PUDGY = 6.5,
        },
        BEEFALO_HAIR_GROWTH_DAYS = 3,
        BEEFALO_SADDLEABLE_OBEDIENCE = 0.1,
        BEEFALO_KEEP_SADDLE_OBEDIENCE = 0.4,
        BEEFALO_MIN_BUCK_OBEDIENCE = 0.5,
        BEEFALO_MIN_BUCK_TIME = 50,
        BEEFALO_MAX_BUCK_TIME = 800,
        BEEFALO_BUCK_TIME_VARIANCE = 3,
        BEEFALO_MIN_DOMESTICATED_OBEDIENCE =
        {
            DEFAULT = 0.8,
            ORNERY = 0.45,
            RIDER = 0.95,
            PUDGY = 0.6,
        },
        BEEFALO_BUCK_TIME_MOOD_MULT = 0.2,
        BEEFALO_BUCK_TIME_UNDOMESTICATED_MULT = 0.3,
        BEEFALO_BUCK_TIME_NUDE_MULT = 0.2,

        BEEFALO_BEG_HUNGER_PERCENT = 0.45,

        BEEFALO_DOMESTICATION_STARVE_OBEDIENCE = -1/(total_day_time*1),
        BEEFALO_DOMESTICATION_FEED_OBEDIENCE = 0.1,
        BEEFALO_DOMESTICATION_OVERFEED_OBEDIENCE = -0.3,
        BEEFALO_DOMESTICATION_ATTACKED_BY_PLAYER_OBEDIENCE = -1,
        BEEFALO_DOMESTICATION_BRUSHED_OBEDIENCE = 0.4,
        BEEFALO_DOMESTICATION_SHAVED_OBEDIENCE = -1,

        BEEFALO_DOMESTICATION_LOSE_DOMESTICATION = -1/(total_day_time*4),
        BEEFALO_DOMESTICATION_GAIN_DOMESTICATION = 1/(total_day_time*20),
        BEEFALO_DOMESTICATION_MAX_LOSS_DAYS = 10, -- days
        BEEFALO_DOMESTICATION_OVERFEED_DOMESTICATION = -0.01,
        BEEFALO_DOMESTICATION_ATTACKED_DOMESTICATION = 0,
        BEEFALO_DOMESTICATION_ATTACKED_OBEDIENCE = -0.01,
        BEEFALO_DOMESTICATION_ATTACKED_BY_PLAYER_DOMESTICATION = -0.3,
        BEEFALO_DOMESTICATION_BRUSHED_DOMESTICATION = (1-(15/20))/15, -- (1-(targetdays/basedays))/targetdays

        BEEFALO_PUDGY_WELLFED = 1/(total_day_time*5),
        BEEFALO_PUDGY_OVERFEED = 0.02,
        BEEFALO_RIDER_RIDDEN = 1/(total_day_time*5),
        BEEFALO_ORNERY_DOATTACK = 0.004,
        BEEFALO_ORNERY_ATTACKED = 0.004,

	    BABYBEEFALO_HEALTH = 300,
	    BABYBEEFALO_GROW_TIME = {base=3*day_time, random=2*day_time},

	    KOALEFANT_HEALTH = 500,
	    KOALEFANT_DAMAGE = 50,
	    KOALEFANT_TARGET_DIST = 5,
	    KOALEFANT_CHASE_DIST = 30,
	    KOALEFANT_FOLLOW_TIME = 30,

	    HUNT_ALTERNATE_BEAST_CHANCE_MIN = 0.05,
	    HUNT_ALTERNATE_BEAST_CHANCE_MAX = 0.33,
	    HUNT_SPAWN_DIST = 40,
	    HUNT_COOLDOWN = total_day_time*1.2,
	    HUNT_COOLDOWNDEVIATION = total_day_time*.3,

	    HUNT_RESET_TIME = 5,
	    HUNT_SPRING_RESET_TIME = total_day_time * 3,

	    TRACK_ANGLE_DEVIATION = 30,
	    MIN_HUNT_DISTANCE = 300, -- you can't find a new beast without being at least this far from the last one
	    MAX_DIRT_DISTANCE = 200, -- if you get this far away from your dirt pile, you probably aren't going to see it any time soon, so remove it and place a new one

	   	BAT_DAMAGE = 20,
	    BAT_HEALTH = 50,
	    BAT_ATTACK_PERIOD = 1,
	    BAT_ATTACK_DIST = 1.5,
	    BAT_WALK_SPEED = 8,
	    BAT_TARGET_DIST = 12,

	    SPIDER_HEALTH = 100,
	    SPIDER_DAMAGE = 20,
	    SPIDER_ATTACK_PERIOD = 3,
	    SPIDER_TARGET_DIST = 4,
	    SPIDER_INVESTIGATETARGET_DIST = 6,
	    SPIDER_WAKE_RADIUS = 4,
	    SPIDER_FLAMMABILITY = .33,
		SPIDER_SUMMON_WARRIORS_RADIUS = 12,
		SPIDER_EAT_DELAY = 1.5,

	    SPIDER_WALK_SPEED = 3,
	    SPIDER_RUN_SPEED = 5,

	    SPIDER_WARRIOR_HEALTH = 200,
	    SPIDER_WARRIOR_DAMAGE = 20,
	    SPIDER_WARRIOR_ATTACK_PERIOD = 4,
	    SPIDER_WARRIOR_ATTACK_RANGE = 6,
	    SPIDER_WARRIOR_HIT_RANGE = 3,
	    SPIDER_WARRIOR_MELEE_RANGE = 3,
	    SPIDER_WARRIOR_TARGET_DIST = 10,
	    SPIDER_WARRIOR_WAKE_RADIUS = 6,

	    SPIDER_WARRIOR_WALK_SPEED = 4,
	    SPIDER_WARRIOR_RUN_SPEED = 5,

	    SPIDER_HIDER_HEALTH = 150,
	    SPIDER_HIDER_DAMAGE = 20,
	    SPIDER_HIDER_ATTACK_PERIOD = 3,
	    SPIDER_HIDER_WALK_SPEED = 3,
	    SPIDER_HIDER_RUN_SPEED = 5,
	    SPIDER_HIDER_SHELL_ABSORB = 0.75,

	    SPIDER_SPITTER_HEALTH = 175,
	    SPIDER_SPITTER_DAMAGE_MELEE = 20,
	    SPIDER_SPITTER_DAMAGE_RANGED = 20,
	    SPIDER_SPITTER_ATTACK_PERIOD = 5,
	    SPIDER_SPITTER_ATTACK_RANGE = 5,
	    SPIDER_SPITTER_MELEE_RANGE = 2,
	    SPIDER_SPITTER_HIT_RANGE = 3,
	    SPIDER_SPITTER_WALK_SPEED = 4,
	    SPIDER_SPITTER_RUN_SPEED = 5,

	    LEIF_HEALTH = 2000,
	    LEIF_DAMAGE = 150,
	    LEIF_ATTACK_PERIOD = 3,
	    LEIF_FLAMMABILITY = .333,

	    LEIF_MIN_DAY = 3,
	    LEIF_PERCENT_CHANCE = 1/75,
	    LEIF_MAXSPAWNDIST = 15,

	    LEIF_PINECONE_CHILL_CHANCE_CLOSE = .33,
	    LEIF_PINECONE_CHILL_CHANCE_FAR = .15,
	    LEIF_PINECONE_CHILL_CLOSE_RADIUS = 5,
	    LEIF_PINECONE_CHILL_RADIUS = 16,
	    LEIF_REAWAKEN_RADIUS = 20,

	    LEIF_BURN_TIME = 10,
	    LEIF_BURN_DAMAGE_PERCENT = 1/8,

	    DEERCLOPS_HEALTH = 2000,
	    DEERCLOPS_DAMAGE = 150,
	    DEERCLOPS_ATTACK_PERIOD = 3,
	    DEERCLOPS_ATTACK_RANGE = 6,
	    DEERCLOPS_AOE_RANGE = 6,
	    DEERCLOPS_AOE_SCALE = 0.8,

	    BIRD_SPAWN_MAX = 4,
	    BIRD_SPAWN_DELAY = {min=5, max=15},
	    BIRD_SPAWN_MAX_FEATHERHAT = 7,
	    BIRD_SPAWN_DELAY_FEATHERHAT = {min=2, max=10},

		FROG_RAIN_DELAY = {min=0.1, max=2},
		FROG_RAIN_SPAWN_RADIUS = 60,
		FROG_RAIN_MAX = 300,
		FROG_RAIN_LOCAL_MIN_EARLY = 5,
		FROG_RAIN_LOCAL_MAX_EARLY = 15,
		FROG_RAIN_LOCAL_MIN_LATE = 20,
		FROG_RAIN_LOCAL_MAX_LATE = 35,
		FROG_RAIN_LOCAL_MIN_ADVENTURE = 10,
		FROG_RAIN_LOCAL_MAX_ADVENTURE = 25,
		FROG_RAIN_MAX_RADIUS = 50,
		FROG_RAIN_PRECIPITATION = 0.8, -- 0-1, 0.8 by default (old "often" setting for Adventure)
		FROG_RAIN_MOISTURE = 2500, -- 0-4000ish, 2500 by default (old "often" setting for Adventure)
		SURVIVAL_FROG_RAIN_PRECIPITATION = 0.67,
		FROG_RAIN_CHANCE = .16,

	    BEE_HEALTH = 100,
	    BEE_DAMAGE = 10,
	    BEE_ATTACK_PERIOD = 2,
	    BEE_TARGET_DIST = 8,

	    BEEMINE_BEES = 4,
	    BEEMINE_RADIUS = 3,

	    SPIDERDEN_GROW_TIME = {day_time*8, day_time*8, day_time*20},
	    SPIDERDEN_HEALTH = {50*5, 50*10, 50*20},
	    SPIDERDEN_SPIDERS = {3, 6, 9},
	    SPIDERDEN_WARRIORS = {0, 1, 3},  -- every hit, release up to this many warriors, and fill remainder with regular spiders
	    SPIDERDEN_SPIDER_TYPE = {"spider", "spider_warrior", "spider_warrior"},
		SPIDERDEN_REGEN_TIME = 3*seg_time,
		SPIDERDEN_RELEASE_TIME = 5,

		HOUNDMOUND_HOUNDS_MIN = 2,
		HOUNDMOUND_HOUNDS_MAX = 3,
		HOUNDMOUND_REGEN_TIME = seg_time * 4,
		HOUNDMOUND_RELEASE_TIME = seg_time,

		POND_FROGS = 4,
		POND_REGEN_TIME = day_time/2,
		POND_SPAWN_TIME = day_time/4,
		POND_RETURN_TIME = day_time*3/4,
	    FISH_RESPAWN_TIME = day_time/3,


	    FISH_FARM_CYCLE_TIME_MIN = seg_time * 8,
	    FISH_FARM_CYCLE_TIME_MAX = seg_time * 12,
	    FISH_FARM_LURE_TEST_TIME = seg_time * 7,

	    BEEHIVE_BEES = 6,
	    BEEHIVE_RELEASE_TIME = day_time/6,
	    BEEHIVE_REGEN_TIME = seg_time,
	    BEEBOX_BEES = 4,
	    WASPHIVE_WASPS = 6,
	    BEEBOX_RELEASE_TIME = (0.5*day_time)/4,
	    BEEBOX_HONEY_TIME = day_time,
	    BEEBOX_REGEN_TIME = seg_time*4,

	    WORM_DAMAGE = 75,
	    WORM_ATTACK_PERIOD = 4,
	    WORM_ATTACK_DIST = 3,
	    WORM_HEALTH = 900,
	    WORM_CHASE_TIME = 20,
	    WORM_LURE_TIME = 20,
	    WORM_LURE_VARIANCE = 10,
	    WORM_FOOD_DIST = 15,
	    WORM_CHASE_DIST = 50,
	    WORM_WANDER_DIST = 30,
	    WORM_TARGET_DIST = 20,
	    WORM_LURE_COOLDOWN = 30,
	    WORM_EATING_COOLDOWN = 30,

	    WORMLIGHT_RADIUS = 3,
	    WORMLIGHT_DURATION = 90,

	    TENTACLE_DAMAGE = 34,
	    TENTACLE_ATTACK_PERIOD = 2,
	    TENTACLE_ATTACK_DIST = 4,
	    TENTACLE_STOPATTACK_DIST = 6,
	    TENTACLE_HEALTH = 500,

	    TENTACLE_PILLAR_HEALTH = 500,
        TENTACLE_PILLAR_ARMS = 12,   -- max spawned at a time
        TENTACLE_PILLAR_ARMS_TOTAL = 25,  -- max simultaneous arms
	    TENTACLE_PILLAR_ARM_DAMAGE = 5,
	    TENTACLE_PILLAR_ARM_ATTACK_PERIOD = 3,
	    TENTACLE_PILLAR_ARM_ATTACK_DIST = 3,
	    TENTACLE_PILLAR_ARM_STOPATTACK_DIST = 5,
	    TENTACLE_PILLAR_ARM_HEALTH = 20,
	    TENTACLE_PILLAR_ARM_EMERGE_TIME = 200,

	    EYEPLANT_DAMAGE = 20,
	    EYEPLANT_HEALTH = 30,
	    EYEPLANT_ATTACK_PERIOD = 1,
	    EYEPLANT_ATTACK_DIST = 2.5,
	    EYEPLANT_STOPATTACK_DIST = 4,

	    LUREPLANT_HIBERNATE_TIME = total_day_time * 2,
	    LUREPLANT_GROWTHCHANCE = 0.02,
	    LUREPLANT_SPAWNTIME = total_day_time * 12,
	    LUREPLANT_SPAWNTIME_VARIANCE = total_day_time * 3,

	    TALLBIRD_HEALTH = 400,
	    TALLBIRD_DAMAGE = 50,
	    TALLBIRD_ATTACK_PERIOD = 2,
	    TALLBIRD_HATEPIGS_DIST = 16,
	    TALLBIRD_TARGET_DIST = 8,
	    TALLBIRD_DEFEND_DIST = 12,
	    TALLBIRD_ATTACK_RANGE = 3,

	    TEENBIRD_HEALTH = 400*.75,
	    TEENBIRD_DAMAGE = 50*.75,
	    TEENBIRD_ATTACK_PERIOD = 2,
	    TEENBIRD_ATTACK_RANGE = 3,
	    TEENBIRD_DAMAGE_PECK = 2,
	    TEENBIRD_PECK_PERIOD = 4,
	    TEENBIRD_HUNGER = 60,
	    TEENBIRD_STARVE_TIME = total_day_time * 1,
	    TEENBIRD_STARVE_KILL_TIME = 240,
	    TEENBIRD_GROW_TIME = total_day_time*18,
	    TEENBIRD_TARGET_DIST = 8,

	    SMALLBIRD_HEALTH = 50,
	    SMALLBIRD_DAMAGE = 10,
	    SMALLBIRD_ATTACK_PERIOD = 1,
	    SMALLBIRD_ATTACK_RANGE = 3,
	    SMALLBIRD_HUNGER = 20,
	    SMALLBIRD_STARVE_TIME = total_day_time * 1,
	    SMALLBIRD_STARVE_KILL_TIME = 120,
	    SMALLBIRD_GROW_TIME = total_day_time*10,

	    SMALLBIRD_HATCH_CRACK_TIME = 10, -- set by fire for this much time to start hatching progress
	    SMALLBIRD_HATCH_TIME = total_day_time * 3, -- must be content for this amount of cumulative time to hatch
	    SMALLBIRD_HATCH_FAIL_TIME = night_time * .5, -- being too hot or too cold this long will kill the egg

	    MIN_SPRING_SMALL_BIRD_SPAWN_TIME = total_day_time * 2,
	    MAX_SPRING_SMALL_BIRD_SPAWN_TIME = total_day_time * 8,

	    HATCH_UPDATE_PERIOD = 3,
	    HATCH_CAMPFIRE_RADIUS = 4,

	    CHESTER_HEALTH = wilson_health*3,
	    CHESTER_RESPAWN_TIME = total_day_time * 1,
	    CHESTER_HEALTH_REGEN_AMOUNT = (wilson_health*3) * 3/60,
	    CHESTER_HEALTH_REGEN_PERIOD = 3,

		PROTOTYPER_TREES = {
		    SCIENCEMACHINE =
		    {
		    	SCIENCE = 1,
		    	MAGIC = 1,
		    	ANCIENT = 0,
		    	OBSIDIAN = 0,
		    	WATER = 0,
				HOME = 0,	
				CITY = 0,	
				LOST = 0,
			},

			ALCHEMYMACHINE =
			{
				SCIENCE = 2,
				MAGIC = 1,
				ANCIENT = 0,
				OBSIDIAN = 0,
				WATER = 0,
				HOME = 0,
				CITY = 0,
				LOST = 0,
			},

			PRESTIHATITATOR =
			{
				SCIENCE = 0,
				MAGIC = 2,
				ANCIENT = 0,
				OBSIDIAN = 0,
				WATER = 0,
				HOME = 0,
				CITY = 0,
				LOST = 0,
			},

		    SEALAB =
		    {
		    	SCIENCE = 2,
		    	MAGIC = 0,
		    	ANCIENT = 0,
		    	OBSIDIAN = 0,
		    	WATER = 2,
				HOME = 0,
				CITY = 0,
				LOST = 0,
			},
			
			SHADOWMANIPULATOR =
			{
				SCIENCE = 0,
				MAGIC = 3,
				ANCIENT = 0,
				OBSIDIAN = 0,
				WATER = 0,
				HOME = 0,				
				CITY = 0,				
				LOST = 0,
			},

			ANCIENTALTAR_LOW =
			{
				SCIENCE = 0,
				MAGIC = 0,
				ANCIENT = 2,
				OBSIDIAN = 0,
				WATER = 0,
				HOME = 0,
				CITY = 0,								
				LOST = 0,
			},

			ANCIENTALTAR_HIGH =
			{
				SCIENCE = 0,
				MAGIC = 0,
				ANCIENT = 4,
				OBSIDIAN = 0,
				WATER = 0,
				HOME = 0,
				CITY = 0,
				LOST = 0,
			},

			OBSIDIAN_BENCH =
			{
				SCIENCE = 0,
				MAGIC = 0,
				ANCIENT = 0,
				OBSIDIAN = 2,
				WATER = 0,
				HOME = 0,	
				CITY = 0,							
				LOST = 0,
			},
			
			HOME =
			{
				SCIENCE = 0,
				MAGIC = 0,
				ANCIENT = 0,
				OBSIDIAN = 0,
				WATER = 0,
				HOME = 2,
				CITY = 0,					
				LOST = 0,
			},	

			HOGUSPORKUSATOR =
			{
				SCIENCE = 0,
				MAGIC = 2,
				ANCIENT = 0,
				OBSIDIAN = 0,
				WATER = 0,
				HOME = 0,
				CITY = 0,				
				LOST = 0,
			},

			CITY =
			{
				SCIENCE = 0,
				MAGIC = 0,
				ANCIENT = 0,
				OBSIDIAN = 0,
				WATER = 0,
				HOME = 0,
				CITY = 2,				
				LOST = 0,
			},			

		},

	    RABBIT_HEALTH = 25,
	    MOLE_HEALTH = 30,

	    FROG_HEALTH = 100,
	    FROG_DAMAGE = 10,
	    FROG_ATTACK_PERIOD = 1,
	    FROG_TARGET_DIST = 4,

	    HOUND_SPECIAL_CHANCE =
	    {
	        {minday=0, chance=0},
	        {minday=15, chance=.1},
	        {minday=30, chance=.2},
	        {minday=50, chance=.333},
	        {minday=75, chance=.5},
	    },



	    HOUND_HEALTH = 150,
	    HOUND_DAMAGE = 20,
	    HOUND_ATTACK_PERIOD = 2,
	    HOUND_TARGET_DIST = 20,
	    HOUND_SPEED = 10,

        HOUND_FOLLOWER_TARGET_DIST = 10,
        HOUND_FOLLOWER_TARGET_KEEP = 20,

	    FIREHOUND_HEALTH = 100,
	    FIREHOUND_DAMAGE = 30,
	    FIREHOUND_ATTACK_PERIOD = 2,
	    FIREHOUND_SPEED = 10,

	    ICEHOUND_HEALTH = 100,
	    ICEHOUND_DAMAGE = 30,
	    ICEHOUND_ATTACK_PERIOD = 2,
	    ICEHOUND_SPEED = 10,

		MOSQUITO_WALKSPEED = 8,
		MOSQUITO_RUNSPEED = 12,
		MOSQUITO_DAMAGE = 3,
		MOSQUITO_HEALTH = 100,
		MOSQUITO_ATTACK_PERIOD = 7,
		MOSQUITO_MAX_DRINKS = 4,
		MOSQUITO_BURST_DAMAGE = 34,
		MOSQUITO_BURST_RANGE = 4,

	    KRAMPUS_HEALTH = 200,
	    KRAMPUS_DAMAGE = 50,
	    KRAMPUS_ATTACK_PERIOD = 1.2,
	    KRAMPUS_SPEED = 7,
	    KRAMPUS_THRESHOLD = 30,
	    KRAMPUS_THRESHOLD_VARIANCE = 20,
	    KRAMPUS_INCREASE_LVL1 = 50,
	    KRAMPUS_INCREASE_LVL2 = 100,
	    KRAMPUS_INCREASE_RAMP = 2,
	    KRAMPUS_NAUGHTINESS_DECAY_PERIOD = 60,

	    SCARER_SPEED = 2.5, 

	    TERRORBEAK_SPEED = 7,
	    TERRORBEAK_HEALTH = 400,
	    TERRORBEAK_DAMAGE = 50,
	    TERRORBEAK_ATTACK_PERIOD= 1.5,

	    CRAWLINGHORROR_SPEED = 3,
	    CRAWLINGHORROR_HEALTH = 300,
	    CRAWLINGHORROR_DAMAGE = 20,
	    CRAWLINGHORROR_ATTACK_PERIOD= 2.5,

	    SHADOWCREATURE_TARGET_DIST = 20,

		FROSTY_BREATH = -5,

	    SEEDS_GROW_TIME = day_time*6,
	    FARM1_GROW_BONUS = 1,
	    FARM2_GROW_BONUS = .6667,
	    FARM3_GROW_BONUS = .333,

	    POOP_FERTILIZE = day_time,
	    POOP_SOILCYCLES = 10,
	    POOP_WITHEREDCYCLES = 1,
	    POOP_CAN_USES = 8,

	    GUANO_FERTILIZE = day_time * 1.5,
	    GUANO_SOILCYCLES = 12,
	    GUANO_WITHEREDCYCLES = 1,

	    POOP_WILBUR_FERTILIZE = day_time * 0.5,
	    POOP_WILBUR_SOILCYCLES = 5,
	    POOP_WILBUR_WITHEREDCYCLES = 0.5,

	    GLOMMERFUEL_FERTILIZE = day_time,
	    GLOMMERFUEL_SOILCYCLES = 8,

	    SPOILEDFOOD_FERTILIZE = day_time/4,
	    SPOILEDFOOD_SOILCYCLES = 2,
	    SPOILEDFOOD_WITHEREDCYCLES = 0.5,



	    FISHING_CATCH_CHANCE = 0.4,
	    FISHING_LOSEROD_CHANCE = 0.4,

		WET_FUEL_PENALTY = 0.75,

	    TINY_FUEL = seg_time*.25,
	    SMALL_FUEL = seg_time * .5,
	    MED_FUEL = seg_time * 1.5,
	    MED_LARGE_FUEL = seg_time * 3,
	    LARGE_FUEL = seg_time * 6,

	    TINY_BURNTIME = seg_time*.1,
	    SMALL_BURNTIME = seg_time*.25,
	    MED_BURNTIME = seg_time*0.5,
	    LARGE_BURNTIME = seg_time,

	    CAMPFIRE_RAIN_RATE = 2.5,
	    CAMPFIRE_FUEL_MAX = (night_time+dusk_time)*1.5,
	    CAMPFIRE_FUEL_START = (night_time+dusk_time)*.75,
	    CAMPFIRE_FLOOD_RATE = 500,
	    CAMPFIRE_WIND_RATE = 10,

	    COLDFIRE_RAIN_RATE = 2.5,
	    COLDFIRE_FUEL_MAX = (night_time+dusk_time)*1.5,
	    COLDFIRE_FUEL_START = (night_time+dusk_time)*.75,
	    COLDFIRE_FLOOD_RATE = 500,
	    COLDFIRE_WIND_RATE = 10,

        ROCKLIGHT_FUEL_MAX = (night_time+dusk_time)*1.5,

		FIREPIT_RAIN_RATE = 2,
	    FIREPIT_FUEL_MAX = (night_time+dusk_time)*2,
	    FIREPIT_FUEL_START = night_time+dusk_time,
	    FIREPIT_BONUS_MULT = 2,
	    FIREPIT_FLOOD_RATE = 500,
	    FIREPIT_WIND_RATE = 10,

	    COLDFIREPIT_RAIN_RATE = 2,
	    COLDFIREPIT_FUEL_MAX = (night_time+dusk_time)*2,
	    COLDFIREPIT_FUEL_START = night_time+dusk_time,
	    COLDFIREPIT_BONUS_MULT = 2,
	    COLDFIREPIT_FLOOD_RATE = 500,
	    COLDFIREPIT_WIND_RATE = 10,

	    PIGTORCH_RAIN_RATE = 2,
	    PIGTORCH_FUEL_MAX = night_time,
	    PIGTORCH_WIND_RATE = 2,

	    NIGHTLIGHT_FUEL_MAX = (night_time+dusk_time)*3,
	    NIGHTLIGHT_FUEL_START = (night_time+dusk_time),

	    TORCH_RAIN_RATE = 1.5,
	    TORCH_FUEL = night_time*1.25,
	    TORCH_WIND_RATE = 2,

	    NIGHTSTICK_FUEL = night_time*6,

	    MINERHAT_LIGHTTIME = (night_time+dusk_time)*2.6,
	    LANTERN_LIGHTTIME = (night_time+dusk_time)*2.6,
	    SPIDERHAT_PERISHTIME = 4*seg_time,
	    SPIDERHAT_RANGE = 12,
	    ONEMANBAND_PERISHTIME = 6*seg_time,
	    ONEMANBAND_RANGE = 12,

	    GRASS_UMBRELLA_PERISHTIME = 2*total_day_time*perish_warp,
	    UMBRELLA_PERISHTIME = total_day_time*6,
	    EYEBRELLA_PERISHTIME = total_day_time*9,

		STRAWHAT_PERISHTIME = total_day_time*5,
		EARMUFF_PERISHTIME = total_day_time*5,
		WINTERHAT_PERISHTIME = total_day_time*10,
		BEEFALOHAT_PERISHTIME = total_day_time*10,

		GASMASK_PERISHTIME = total_day_time*3,		

		TRUNKVEST_PERISHTIME = total_day_time*15,
		REFLECTIVEVEST_PERISHTIME = total_day_time*8,
		HAWAIIANSHIRT_PERISHTIME = total_day_time*15,
		SWEATERVEST_PERISHTIME = total_day_time*10,
		HUNGERBELT_PERISHTIME = total_day_time*8,
		BEARGERVEST_PERISHTIME = total_day_time*7,
		RAINCOAT_PERISHTIME = total_day_time*10,

		WALRUSHAT_PERISHTIME = total_day_time*25,
		FEATHERHAT_PERISHTIME = total_day_time*8,
		PEAGAWKHAT_PERISHTIME = total_day_time*0.9,
		TOPHAT_PERISHTIME = total_day_time*8,
		PITHHAT_PERISHTIME = total_day_time*8,
		
		--PORKLAND HATS
		BANDITHAT_PERISHTIME = total_day_time*1,
		THUNDERHAT_PERISHTIME = total_day_time*4,


		SNEAK_SIGHTDISTANCE = 8,

		ICEHAT_PERISHTIME = total_day_time*4,
		MOLEHAT_PERISHTIME = total_day_time*1.5,
		RAINHAT_PERISHTIME = total_day_time*10,
		CATCOONHAT_PERISHTIME = total_day_time*10,
		BATHAT_PERISHTIME = total_day_time*2,
		HAYFEVERHAT_PERISHTIME = total_day_time*5,

		WALKING_STICK_PERISHTIME = total_day_time*3,

	    GRASS_REGROW_TIME = total_day_time*3,
	    SAPLING_REGROW_TIME = total_day_time*4,
	    MARSHBUSH_REGROW_TIME = total_day_time*4,
	    CACTUS_REGROW_TIME = total_day_time*4,
	    FLOWER_CAVE_REGROW_TIME = total_day_time*3,
	    LICHEN_REGROW_TIME = total_day_time*5,

	    BERRY_REGROW_TIME = total_day_time*3,
	    BERRY_REGROW_INCREASE = total_day_time*.5,
	    BERRY_REGROW_VARIANCE = total_day_time*2,
	    BERRYBUSH_CYCLES = 3,

	    FLIPPABLE_ROCK_REPOPULATE_TIME = total_day_time*5,
	    FLIPPABLE_ROCK_REPOPULATE_INCREASE = total_day_time*.5,
	    FLIPPABLE_ROCK_REPOPULATE_VARIANCE = total_day_time*2,
	    FLIPPABLE_ROCK_CYCLES = 3,

	    REEDS_REGROW_TIME = total_day_time*3,

	    CROW_LEAVINGS_CHANCE = .3333,
	    BIRD_TRAP_CHANCE = 0.025,
	    BIRD_HEALTH = 25,

	    BUTTERFLY_SPAWN_TIME = 10,
	    BUTTERFLY_POP_CAP = 4,

	    FLOWER_SPAWN_TIME_VARIATION = 20,
	    FLOWER_SPAWN_TIME = 30,
	    MAX_FLOWERS_PER_AREA = 50,

	    MOLE_RESPAWN_TIME = day_time*4,

	    RABBIT_RESPAWN_TIME = day_time*4,
	    MIN_RABBIT_HOLE_TRANSITION_TIME = day_time*.5,
	    MAX_RABBIT_HOLE_TRANSITION_TIME = day_time*2,

	    FULL_ABSORPTION = 1,
	    ARMORGRASS = wilson_health*1.5,
		ARMORGRASS_ABSORPTION = .6,
	    ARMORWOOD = wilson_health*3,
		ARMORWOOD_ABSORPTION = .8,
		ARMORMARBLE = wilson_health*7,
		ARMORMARBLE_ABSORPTION = .95,
		ARMORSNURTLESHELL_ABSORPTION = 0.6,
		ARMORSNURTLESHELL = wilson_health*7,
		ARMORMARBLE_SLOW = -0.3,
		ARMORRUINS_ABSORPTION = 0.9,
		ARMORRUINS = wilson_health * 12,
		ARMORSLURPER_ABSORPTION = 0.6,
		ARMORSLURPER_SLOW_HUNGER = -0.4,
		ARMORSLURPER = wilson_health * 4,
	    ARMOR_FOOTBALLHAT = wilson_health*3,
		ARMOR_FOOTBALLHAT_ABSORPTION = .8,

	    ARMOR_OXHAT = wilson_health*4,
		ARMOR_OXHAT_ABSORPTION = .85,

		ARMORDRAGONFLY = wilson_health * 9,
		ARMORDRAGONFLY_ABSORPTION = 0.7,
		ARMORDRAGONFLY_FIRE_RESIST = 1,

		ARMORBEARGER_SLOW_HUNGER = -0.25,


		ARMOR_WATHGRITHRHAT = wilson_health * 5,
		ARMOR_WATHGRITHRHAT_ABSORPTION = .8,


		ARMOR_RUINSHAT = wilson_health*8,
		ARMOR_RUINSHAT_ABSORPTION = 0.9,
		ARMOR_RUINSHAT_PROC_CHANCE = 0.33,
		ARMOR_RUINSHAT_COOLDOWN = 5,
		ARMOR_RUINSHAT_DURATION = 4,
		ARMOR_RUINSHAT_DMG_AS_SANITY = 0.05,

		ARMOR_SLURTLEHAT = wilson_health*5,
		ARMOR_SLURTLEHAT_ABSORPTION = 0.9,
	    ARMOR_BEEHAT = wilson_health*5,
		ARMOR_BEEHAT_ABSORPTION = .8,
		ARMOR_SANITY = wilson_health * 5,
		ARMOR_SANITY_ABSORPTION = .95,
		ARMOR_SANITY_DMG_AS_SANITY = 0.10,

		ARMORVORTEX = wilson_health*3,
		ARMORVORTEX_ABSORPTION = 1,

	    PANFLUTE_SLEEPTIME = 20,
	    PANFLUTE_SLEEPRANGE = 15,
	    PANFLUTE_USES = 10,
	    HORN_RANGE = 25,
	    HORN_USES = 10,
	    HORN_EFFECTIVE_TIME = 20,
	    HORN_MAX_FOLLOWERS = 5,
	    MANDRAKE_SLEEP_TIME = 10,
	    MANDRAKE_SLEEP_RANGE = 15,
	    MANDRAKE_SLEEP_RANGE_COOKED = 25,

	    GOLD_VALUES=
	    {
	        MEAT = 1,
	        RAREMEAT = 5,
	        TRINKETS=
	        {
	            4,6,4,5,4,5,4,8,7,2,5,8, -- ROG trinkets 1-12
	            6,8,6,7,6,7,6,9,9,4,10, -- SW trinkets 13-23
	        },
	        SUNKEN_BOAT_TRINKETS =
	        { 2, 2, 7, 1, 4 },
	    },

	    DUBLOON_VALUES=
	    {
	        SEAFOOD = 1+3,
	        RARESEAFOOD = 5+3,
	        TRINKETS=
	        {
				6+3,8+3,6+3,7+3,6+3,7+3,6+3,9+3,9+3,4+3,7+3,9+3, -- ROG trinkets 1-12
	            4+3,4+3,5+3,2+3,2+3,8+3,5+3,8+3,5+3,2+3,8+3, -- SW trinkets 13-23
	        }
	    },

		RESEARCH_COST_CHEAP = 30,
		RESEARCH_COST_MEDIUM = 100,
		RESEARCH_COST_EXPENSIVE = 200,

	    SPIDERQUEEN_WALKSPEED = 1.75,
	    SPIDERQUEEN_HEALTH = 1250,
	    SPIDERQUEEN_DAMAGE = 80,
	    SPIDERQUEEN_ATTACKPERIOD = 3,
	    SPIDERQUEEN_ATTACKRANGE = 5,
	    SPIDERQUEEN_FOLLOWERS = 16,
	    SPIDERQUEEN_GIVEBIRTHPERIOD = 20,
	    SPIDERQUEEN_MINWANDERTIME = total_day_time * 1.5,
	    SPIDERQUEEN_MINDENSPACING = 20,

	    TRAP_TEETH_USES = 10,
	    TRAP_TEETH_DAMAGE = 60,
	    TRAP_TEETH_RADIUS = 1.5,


	    HEALING_TINY = 1,
	    HEALING_SMALL = 3,
	    HEALING_MEDSMALL = 8,
	    HEALING_MED = 20,
	    HEALING_MEDLARGE = 30,
	    HEALING_LARGE = 40,
	    HEALING_HUGE = 60,
	    HEALING_SUPERHUGE = 100,

	    SANITY_SUPERTINY = 1,
	    SANITY_TINY = 5,
	    SANITY_SMALL = 10,
	    SANITY_MED = 15,
	    SANITY_MEDLARGE = 20,
	    SANITY_LARGE = 33,
	    SANITY_HUGE = 50,

		PERISH_ONE_DAY = 1*total_day_time*perish_warp,
		PERISH_TWO_DAY = 2*total_day_time*perish_warp,
		PERISH_SUPERFAST = 3*total_day_time*perish_warp,
		PERISH_FAST = 6*total_day_time*perish_warp,
		PERISH_FASTISH = 8*total_day_time*perish_warp,
		PERISH_MED = 10*total_day_time*perish_warp,
		PERISH_SLOW = 15*total_day_time*perish_warp,
		PERISH_PRESERVED = 20*total_day_time*perish_warp,
		PERISH_SUPERSLOW = 40*total_day_time*perish_warp,

		DRY_FAST = total_day_time,
		DRY_MED = 2*total_day_time,

		CALORIES_TINY = calories_per_day/8, -- berries
		CALORIES_SMALL = calories_per_day/6, -- veggies
		CALORIES_MEDSMALL = calories_per_day/4,
		CALORIES_MED = calories_per_day/3, -- meat
		CALORIES_LARGE = calories_per_day/2, -- cooked meat
		CALORIES_HUGE = calories_per_day, -- crockpot foods?
		CALORIES_SUPERHUGE = calories_per_day*2, -- crockpot foods?

	    SPOILED_HEALTH = -1,
	    SPOILED_HUNGER = -10,
	    PERISH_COLD_FROZEN_MULT = 0, -- frozen things don't spoil in an ice box or if it's cold out
	    PERISH_FROZEN_FIRE_MULT = 30, -- frozen things spoil very quickly if near a fire
	    PERISH_FRIDGE_MULT = .5,
	    PERISH_GROUND_MULT = 1.5,
	    PERISH_APORKALYPSE_MULT = 1.5,
	    PERISH_WET_MULT = 1.3,
	    PERISH_GLOBAL_MULT = 1,
	    PERISH_WINTER_MULT = .75,
	    PERISH_SUMMER_MULT = 1.25,
	    PERISH_POISON_MULT = 3,

	    STALE_FOOD_HUNGER = .667,
	    SPOILED_FOOD_HUNGER = .5,

	    STALE_FOOD_HEALTH = .333,
	    SPOILED_FOOD_HEALTH = 0,

		BASE_COOK_TIME = night_time*.3333,

	    TALLBIRDEGG_HEALTH = 15;
	    TALLBIRDEGG_HUNGER = 15,
	    TALLBIRDEGG_COOKED_HEALTH = 25;
	    TALLBIRDEGG_COOKED_HUNGER = 30,

		REPAIR_CUTSTONE_HEALTH = 50,
		REPAIR_ROCKS_HEALTH = 50/3,
		REPAIR_GEMS_WORK = 1,
		REPAIR_GEARS_WORK = 1,

		REPAIR_THULECITE_WORK = 1.5,
		REPAIR_THULECITE_HEALTH = 100,

		REPAIR_THULECITE_PIECES_WORK = 1.5/6,
		REPAIR_THULECITE_PIECES_HEALTH = 100/6,

		REPAIR_BOARDS_HEALTH = 25,
		REPAIR_LOGS_HEALTH = 25/4,
		REPAIR_STICK_HEALTH = 13,
		REPAIR_CUTGRASS_HEALTH = 13,

		HAYWALL_HEALTH = 100,
		WOODWALL_HEALTH = 200,
		STONEWALL_HEALTH = 400,
		RUINSWALL_HEALTH = 800,

		EFFIGY_HEALTH_PENALTY = 30,

		SANITY_HIGH_LIGHT = .6,
		SANITY_LOW_LIGHT =  0.1,

		SANITY_DAPPERNESS = 1,

		SANITY_BECOME_SANE_THRESH = 35/200,
		SANITY_BECOME_INSANE_THRESH = 30/200,

		
		SANITY_PLAYERHOUSE_GAIN = 100/(day_time*32),

		SANITY_DAY_GAIN = 0,--100/(day_time*32),

		SANITY_NIGHT_LIGHT = -100/(night_time*20),
		SANITY_NIGHT_MID = -100/(night_time*20),
		SANITY_NIGHT_DARK = -100/(night_time*2),

		SANITYAURA_TINY = 100/(seg_time*32),
		SANITYAURA_SMALL = 100/(seg_time*8),
		SANITYAURA_MED = 100/(seg_time*5),
		SANITYAURA_LARGE = 100/(seg_time*2),
		SANITYAURA_HUGE = 100/(seg_time*.5),

		DAPPERNESS_TINY = 100/(day_time*15),
		DAPPERNESS_SMALL = 100/(day_time*10),
		DAPPERNESS_MED = 100/(day_time*6),
		DAPPERNESS_MED_LARGE = 100/(day_time*4.5),
		DAPPERNESS_LARGE = 100/(day_time*3),
		DAPPERNESS_HUGE = 100/(day_time),

		MOISTURE_SANITY_PENALTY_MAX = -100/(day_time*6), -- Was originally 10 days

		CRAZINESS_SMALL = -100/(day_time*2),
		CRAZINESS_MED = -100/(day_time),

		RABBIT_RUN_SPEED = 5,
		SANITY_EFFECT_RANGE	= 10,
		AUTUMN_LENGTH = 20,
		WINTER_LENGTH = 15,
		SPRING_LENGTH = 20,
		SUMMER_LENGTH = 15,

		SEASON_LENGTH_FRIENDLY_DEFAULT = 20,
		SEASON_LENGTH_HARSH_DEFAULT = 15,

		SEASON_LENGTH_FRIENDLY_VERYSHORT = 5,
		SEASON_LENGTH_FRIENDLY_SHORT = 12,
		SEASON_LENGTH_FRIENDLY_LONG = 30,
		SEASON_LENGTH_FRIENDLY_VERYLONG = 50,
		SEASON_LENGTH_HARSH_VERYSHORT = 5,
		SEASON_LENGTH_HARSH_SHORT = 10,
		SEASON_LENGTH_HARSH_LONG = 22,
		SEASON_LENGTH_HARSH_VERYLONG = 40,

		CREEPY_EYES =
		{
		    {maxsanity=.8, maxeyes=0},
		    {maxsanity=.6, maxeyes=2},
		    {maxsanity=.4, maxeyes=4},
		    {maxsanity=.2, maxeyes=6},
		},

		DIVINING_DISTANCES =
		{
		    {maxdist=50, describe="hot", pingtime=1},
		    {maxdist=100, describe="warmer", pingtime=2},
		    {maxdist=200, describe="warm", pingtime=4},
		    {maxdist=400, describe="cold", pingtime=8},
		},
		DIVINING_MAXDIST = 300,
		DIVINING_DEFAULTPING = 8,

		--expressed in 'additional time before you freeze to death'
		INSULATION_TINY = seg_time,
		INSULATION_SMALL = seg_time*2,
		INSULATION_MED = seg_time*4,
		INSULATION_MED_LARGE = seg_time*6,
		INSULATION_LARGE = seg_time*8,
		INSULATION_PER_BEARD_BIT = seg_time*.5,
		WEBBER_BEARD_INSULATION_FACTOR = .75,

		CAVE_INSULATION_BONUS = seg_time*8,

		DUSK_INSULATION_BONUS = seg_time*2,
		NIGHT_INSULATION_BONUS = seg_time*4,

		PLAYER_FREEZE_WEAR_OFF_TIME = 3,

		--CROP_BONUS_TEMP = 28,
		MIN_CROP_GROW_TEMP = 5,
		--CROP_HEAT_BONUS = 1,
		CROP_RAIN_BONUS = 3,

		WITHER_BUFFER_TIME = 15,
		SPRING_GROWTH_MODIFIER = 0.75,
		APORKALYPSE_GROWTH_MODIFIER = 1.5,

		-- RoG wither values
		MIN_PLANT_WITHER_TEMP = 70,
		MAX_PLANT_WITHER_TEMP = 110,
		MIN_PLANT_REJUVENATE_TEMP = 45,
		MAX_PLANT_REJUVENATE_TEMP = 55,

		-- SW wither values
		SW_MIN_PLANT_WITHER_TEMP = 60,
		SW_MAX_PLANT_WITHER_TEMP = 75,
		SW_MIN_PLANT_REJUVENATE_TEMP = 50,
		SW_MAX_PLANT_REJUVENATE_TEMP = 55,

		MIN_TUMBLEWEEDS_PER_SPAWNER = 4,
		MAX_TUMBLEWEEDS_PER_SPAWNER = 7,
		MIN_TUMBLEWEED_SPAWN_PERIOD = total_day_time*.5,
		MAX_TUMBLEWEED_SPAWN_PERIOD = total_day_time*3,
		TUMBLEWEED_REGEN_PERIOD = total_day_time*1.5,

		HEAT_ROCK_CARRIED_BONUS_HEAT_FACTOR = 2.1,--1.85,

		MIN_SEASON_TEMP = -25,
		MAX_SEASON_TEMP = 95,
		SUMMER_CROSSOVER_TEMP = 55,
		SPRING_START_WINTER_CROSSOVER_TEMP = 15,
		AUTUMN_START_SUMMER_CROSSOVER_TEMP = 45,
		WINTER_CROSSOVER_TEMP = 5,
		DAY_HEAT = 8,
		NIGHT_COLD = -10,
		CAVES_MOISTURE_MULT = 3,--6.5,
		CAVES_TEMP = 0,--20,
		SUMMER_RAIN_TEMP = -20,
		STARTING_TEMP = 35,
		OVERHEAT_TEMP = 70,
		TARGET_SLEEP_TEMP = 35,
		MIN_ENTITY_TEMP = -20,
		MAX_ENTITY_TEMP = 90,
		WARM_DEGREES_PER_SEC = 1,
		THAW_DEGREES_PER_SEC = 5,
		FIRE_SUPPRESSOR_TEMP_REDUCTION = 5,
		POLLEN_PARTICLES = 0.5, -- 0.5 is a pretty good value to use when pollen is on

		ICEHAT_COOLER = 40,
		WATERMELON_COOLER = 55,
		TREE_SHADE_COOLER = 45,
		TREE_SHADE_COOLING_THRESHOLD = 63,

		HOT_FOOD_BONUS_TEMP = 40,
		COLD_FOOD_BONUS_TEMP = -40,
		FOOD_TEMP_BRIEF = 5,
		FOOD_TEMP_AVERAGE = 10,
		FOOD_TEMP_LONG = 15,

		WET_HEAT_FACTOR_PENALTY = 0.75,

		SPRING_FIRE_RANGE_MOD = 0.67,

		WILDFIRE_THRESHOLD = 80,
		WILDFIRE_CHANCE = 0.2,
		WILDFIRE_RETRY_TIME = seg_time * 1.5,
		MIN_SMOLDER_TIME = .5*seg_time,
		MAX_SMOLDER_TIME = seg_time,

		TENT_USES = 6,
		SIESTA_CANOPY_USES = 6,

		BEARDLING_SANITY = .4,
		UMBRELLA_USES = 20,

		GUNPOWDER_RANGE = 3,
		GUNPOWDER_DAMAGE = 200,
		BIRD_RAIN_FACTOR = .25,

		RESURRECT_HEALTH = 50,

		SEWINGKIT_USES = 5,
		SEWINGKIT_REPAIR_VALUE = total_day_time*5,


		RABBIT_CARROT_LOYALTY = seg_time*8,
	    BUNNYMAN_DAMAGE = 40,
	    BEARDLORD_DAMAGE = 60,
	    BUNNYMAN_HEALTH = 200,
	    BUNNYMAN_ATTACK_PERIOD = 2,
	    BEARDLORD_ATTACK_PERIOD = 1,
	    BUNNYMAN_RUN_SPEED = 6,
	    BUNNYMAN_WALK_SPEED = 3,
		BUNNYMAN_PANIC_THRESH = .333,
		BEARDLORD_PANIC_THRESH = .25,
		BUNNYMAN_HEALTH_REGEN_PERIOD = 5,
		BUNNYMAN_HEALTH_REGEN_AMOUNT = (200/120)*5,
		BUNNYMAN_SEE_MEAT_DIST = 8,

		CAVE_BANANA_GROW_TIME = 4*total_day_time,
		ROCKY_SPAWN_DELAY = 4*total_day_time,
		ROCKY_SPAWN_VAR = 0,

		ROCKY_DAMAGE = 75,
		ROCKY_HEALTH = 1500,
		ROCKY_WALK_SPEED = 2,
		ROCKY_MAX_SCALE = 1.2,
		ROCKY_MIN_SCALE = .75,
		ROCKY_GROW_RATE = (1.2-.75) / (total_day_time*40),
		ROCKY_LOYALTY = seg_time*6,
		ROCKY_ABSORB = 0.95,
		ROCKY_REGEN_AMOUNT = 10,
		ROCKY_REGEN_PERIOD = 1,
		ROCKYHERD_RANGE = 40,
		ROCKYHERD_MAX_IN_RANGE = 12,


		MONKEY_MELEE_DAMAGE = 20,
		MONKEY_HEALTH = 125,
		MONKEY_ATTACK_PERIOD = 2,
		MONKEY_MELEE_RANGE = 3,
		MONKEY_RANGED_RANGE = 17,
		MONKEY_MOVE_SPEED = 7,
		MONKEY_NIGHTMARE_CHASE_DIST = 40,

		MOOSE_HEALTH = 3000,
		MOOSE_DAMAGE = 150,
		MOOSE_ATTACK_PERIOD = 3,
		MOOSE_ATTACK_RANGE = 5.5,
		MOOSE_WALK_SPEED = 8,
		MOOSE_RUN_SPEED = 12,

		MOOSE_EGG_NUM_MOSSLINGS = 5,
		MOOSE_EGG_HATCH_TIMER = total_day_time * 2,
		MOOSE_EGG_DAMAGE = 10,

		MOSSLING_HEALTH = 350,
		MOSSLING_DAMAGE = 50,
		MOSSLING_ATTACK_PERIOD = 3,
		MOSSLING_ATTACK_RANGE = 2,
		MOSSLING_WALK_SPEED = 5,

		DRAGONFLY_HEALTH = 2750,
	    DRAGONFLY_DAMAGE = 150,
	    DRAGONFLY_ATTACK_PERIOD = 2.5,
	    DRAGONFLY_SLEEP_WHEN_SATISFIED_TIME = .5 * total_day_time,
	    DRAGONFLY_VOMIT_TARGETS_FOR_SATISFIED = 40,
	    DRAGONFLY_ASH_EATEN_FOR_SATISFIED = 20,

		BEARGER_HEALTH = 3000,
		BEARGER_DAMAGE = 200,
		BEARGER_ATTACK_PERIOD = 3,
		BEARGER_MELEE_RANGE = 6,
		BEARGER_ATTACK_RANGE = 6,
		BEARGER_CALM_WALK_SPEED = 3,
		BEARGER_ANGRY_WALK_SPEED = 6,
		BEARGER_RUN_SPEED = 10,
		BEARGER_DISGRUNTLE_TIME = 60,
		BEARGER_CHARGE_INTERVAL = 10,
		BEARGER_STOLEN_TARGETS_FOR_AGRO = 3,
		BEARGER_NUM_FOOD_FOR_SATISFIED = 10, -- Specifically honey foods. He will eat infinite of other kinds.
		BEARGER_SLEEP_WHEN_SATISFIED_TIME = .5 * total_day_time,
		BEARGER_GROWL_INTERVAL = 10,

	    LIGHTER_ATTACK_IGNITE_PERCENT = .5,
	    LIGHTER_DAMAGE = wilson_attack*.5,
		WILLOW_LIGHTFIRE_SANITY_THRESH = .5,
		WX78_RAIN_HURT_RATE = 1,
		WX78_MIN_MOISTURE_DAMAGE= -.1,
		WX78_MAX_MOISTURE_DAMAGE = -.5,
		WX78_MOISTURE_DRYING_DAMAGE = -.3,

		WALANI_HEALTH = 120,
		WALANI_SANITY = 200,
		WALANI_HUNGER = 200,
		WALANI_SANITY_RATE_MODIFIER = -0.1,
		WALANI_HUNGER_RATE_MODIFIER = 0.2,

		WARLY_HUNGER = 250,
		WARLY_HUNGER_RATE_MODIFIER = 0.33,
		WARLY_MULT_PREPARED = 1.33, -- warly's crock pot bonus
		WARLY_MULT_COOKED = 0.9,
		WARLY_MULT_DRIED = 0.8,
		WARLY_MULT_RAW = 0.7,
		WARLY_MULT_SAME_OLD = {0.9, 0.8, 0.65, 0.5, 0.3}, -- applied as a scale when eating the same thing in a row.
		WARLY_SAME_OLD_COOLDOWN = total_day_time * 1.75,

		WILBUR_WALK_SPEED_PENALTY = -0.5,
		WILBUR_SPEED_BONUS = 2.5,
		WILBUR_TIME_TO_RUN = 3,
		WILBUR_RUN_HUNGER_RATE_MULT = 0.33,
		WILBUR_HEALTH = 125,
		WILBUR_HUNGER = 175,
		WILBUR_SANITY = 150,

		WOLFGANG_HUNGER = 300,
		WOLFGANG_START_HUNGER = 200,
		WOLFGANG_START_MIGHTY_THRESH = 225,
		WOLFGANG_END_MIGHTY_THRESH = 220,
		WOLFGANG_START_WIMPY_THRESH = 100,
		WOLFGANG_END_WIMPY_THRESH = 105,

		WOLFGANG_HUNGER_RATE_MULT_MIGHTY = 2.0,
		WOLFGANG_HUNGER_RATE_MULT_NORMAL = 0.5,
		WOLFGANG_HUNGER_RATE_MULT_WIMPY = 0.0,

		WOLFGANG_HEALTH_MIGHTY = 300,
		WOLFGANG_HEALTH_NORMAL = 200,
		WOLFGANG_HEALTH_WIMPY = 150,

		WOLFGANG_ATTACKMULT_MIGHTY_MAX 	= 1.00,
		WOLFGANG_ATTACKMULT_MIGHTY_MIN 	= 0.25,
		WOLFGANG_ATTACKMULT_NORMAL 		= 0.00,
		WOLFGANG_ATTACKMULT_WIMPY_MAX 	= -0.25,
		WOLFGANG_ATTACKMULT_WIMPY_MIN 	= -0.50,

		WATHGRITHR_HEALTH = 200,
		WATHGRITHR_SANITY = 120,
		WATHGRITHR_HUNGER = 120,
		WATHGRITHR_DAMAGE_MULT = 0.25,
		WATHGRITHR_ABSORPTION = 0.25,

		WEBBER_HEALTH = 175,
		WEBBER_SANITY = 100,
		WEBBER_HUNGER = 175,

		WENDY_DAMAGE_MULT = -0.25,
		WENDY_SANITY_MULT = .75,

		WES_DAMAGE_MULT = -0.25,

		WICKERBOTTOM_SANITY = 250,
	    WICKERBOTTOM_STALE_FOOD_HUNGER = .333,
	    WICKERBOTTOM_SPOILED_FOOD_HUNGER = .167,

	    WICKERBOTTOM_STALE_FOOD_HEALTH = .25,
	    WICKERBOTTOM_SPOILED_FOOD_HEALTH = 0,

	    WARBUCKS_HEALTH = 150,
	    WARBUCKS_HUNGER = 120,
	    WARBUCKS_SANITY = 200,

	    WILBA_HEALTH = 150,
	    WILBA_HUNGER = 200,
	    WILBA_SANITY = 100,

	    WEREWILBA_HEALTH = 350,

	    WHEELER_HEALTH = 100,
	    WHEELER_HUNGER = 150,
	    WHEELER_SANITY = 200,
	    WHEELER_DODGE_COOLDOWN = 1.5,
	    DODGE_TIMEOUT = 0.25,

	    FISSURE_CALMTIME_MIN = 600,
	    FISSURE_CALMTIME_MAX = 1200,
	    FISSURE_WARNTIME_MIN = 20,
	    FISSURE_WARNTIME_MAX = 30,
	    FISSURE_NIGHTMARETIME_MIN = 160,
	    FISSURE_NIGHTMARETIME_MAX = 260,
	    FISSURE_DAWNTIME_MIN = 30,
	    FISSURE_DAWNTIME_MAX = 45,

	    EYETURRET_DAMAGE = 65,
	    EYETURRET_HEALTH = 1000,
	    EYETURRET_REGEN = 12,
	    EYETURRET_RANGE = 15,
	    EYETURRET_ATTACK_PERIOD = 3,

	    TRANSITIONTIME =
	    {
	    	CALM = 2,
	    	WARN = 2,
	    	NIGHTMARE = 2,
	    	DAWN = 2,
		},

		SHADOWWAXWELL_LIFETIME = total_day_time * 2.5,
		SHADOWWAXWELL_SPEED = 6,
		SHADOWWAXWELL_DAMAGE = 40,
		SHADOWWAXWELL_LIFE = 75,
		SHADOWWAXWELL_ATTACK_PERIOD = 2,
		SHADOWWAXWELL_SANITY_PENALTY = 55,
		SHADOWWAXWELL_HEALTH_COST = 15,
		SHADOWWAXWELL_FUEL_COST = 2,

		LIVINGTREE_CHANCE = 0.55,

		DECID_MONSTER_MIN_DAY = 3,
	    DECID_MONSTER_DAY_THRESHOLDS = { 20, 35, 70 },
	    DECID_MONSTER_SPAWN_CHANCE_BASE = .033,
	    DECID_MONSTER_SPAWN_CHANCE_LOW = .08,
	    DECID_MONSTER_SPAWN_CHANCE_MED = .15,
	    DECID_MONSTER_SPAWN_CHANCE_HIGH = .33,

		DECID_MONSTER_TARGET_DIST = 7,
		DECID_MONSTER_ATTACK_PERIOD = 2.3,
		DECID_MONSTER_ROOT_ATTACK_RADIUS = 3.7,
		DECID_MONSTER_DAMAGE = 30,
		DECID_MONSTER_ADDITIONAL_LOOT_CHANCE = .2,
		DECID_MONSTER_DURATION = total_day_time*.5,
		MIN_TREE_DRAKES = 3,
		MAX_TREE_DRAKES = 5,
		PASSIVE_DRAKE_SPAWN_NUM_NORMAL = 1,
		PASSIVE_DRAKE_SPAWN_NUM_LARGE = 2,
		PASSIVE_DRAKE_SPAWN_INTERVAL = 12,
		PASSIVE_DRAKE_SPAWN_INTERVAL_VARIANCE = 3,

		WET_TIME =  10, --seg_time,
		DRY_TIME = 10, --seg_time * 2,
		WET_ITEM_DAPPERNESS = -0.1,
		WET_EMPTY_SLOT_DAPPERNESS = -0.2,

		MOISTURE_TEMP_PENALTY = 10,
		MOISTURE_WET_THRESHOLD = 35,
		MOISTURE_DRY_THRESHOLD = 15,
		MOISTURE_MAX_WETNESS = 100,
		MOISTURE_MIN_WETNESS = 0,
		MOISTURE_FLOOD_WETNESS = 50,
		MOISTURE_SPRINKLER_PERCENT_INCREASE_PER_SPRAY = 0.5,

		SLEEP_MOISTURE_DELTA = 30,

		FIRE_DETECTOR_PERIOD = 1,
		FIRE_DETECTOR_RANGE = 15,
		FIRESUPPRESSOR_RELOAD_TIME = 3,
		FIRESUPPRESSOR_MAX_FUEL_TIME = total_day_time*5,
		FIRESUPPRESSOR_EXTINGUISH_HEAT_PERCENT = 0,
		SMOTHERER_EXTINGUISH_HEAT_PERCENT = .2,

		WATERPROOFNESS_SMALL = 0.2,
		WATERPROOFNESS_SMALLMED = 0.35,
		WATERPROOFNESS_MED = 0.5,
		WATERPROOFNESS_LARGE = 0.7,
		WATERPROOFNESS_HUGE = 0.9,
		WATERPROOFNESS_ABSOLUTE = 1,

		CATCOONDEN_REGEN_TIME = seg_time * 4,
		CATCOONDEN_RELEASE_TIME = seg_time,

		CATCOON_ATTACK_RANGE = 4,
		CATCOON_MELEE_RANGE = 3,
		CATCOON_TARGET_DIST = 25,
		CATCOON_SPEED = 3,
		CATCOON_DAMAGE = 25,
		CATCOON_LIFE = 150,
		CATCOON_ATTACK_PERIOD = 2,
		CATCOON_LOYALTY_MAXTIME = total_day_time,
	    CATCOON_LOYALTY_PER_ITEM = total_day_time*.1,
	    CATCOON_MIN_HAIRBALL_TIME_FRIENDLY = .25 * total_day_time,
	    CATCOON_MAX_HAIRBALL_TIME_FRIENDLY = total_day_time,
	    CATCOON_MIN_HAIRBALL_TIME_BASE = .75 * total_day_time,
	    CATCOON_MAX_HAIRBALL_TIME_BASE = 1.5 * total_day_time,
	    MIN_CATNAP_INTERVAL = 30,
	    MAX_CATNAP_INTERVAL = 120,
	    MIN_CATNAP_LENGTH = 20,
	    MAX_CATNAP_LENGTH = 40,
	    MIN_HAIRBALL_FRIEND_INTERVAL = 30,
	    MAX_HAIRBALL_FRIEND_INTERVAL = 90,
	    MIN_HAIRBALL_NEUTRAL_INTERVAL = .5*total_day_time,
	    MAX_HAIRBALL_NEUTRAL_INTERVAL = total_day_time,
	    CATCOON_PICKUP_ITEM_CHANCE = .67,
	    CATCOON_ATTACK_CONNECT_CHANCE = .25,

		FERTILIZER_USES = 10,

		GLOMMERBELL_USES = 3,

	    WARG_RUNSPEED = 5.5,
	    WARG_HEALTH = 600,
	    WARG_DAMAGE = 50,
	    WARG_ATTACKPERIOD = 3,
	    WARG_ATTACKRANGE = 5,
	    WARG_FOLLOWERS = 6,
	    WARG_SUMMONPERIOD = 15,
	    WARG_MAXHELPERS = 10,
	    WARG_TARGETRANGE = 10,

	    FAN_COOLING = -50,

	    SMOTHER_DAMAGE = 5,

	    TORNADO_WALK_SPEED = 25,
	    TORNADO_DAMAGE = 7,
	    TORNADO_LIFETIME = 5,
	    TORNADOSTAFF_USES = 15,

	    FEATHER_FAN_USES = 15,

	    NO_BOSS_TIME = 20,



	    ------------------CAPY DLC--------------------------
	    ---------------SHIPWRECKED VARIABLES----------------

	    PRIMEAPE_MELEE_DAMAGE = 20,
		PRIMEAPE_HEALTH = 125,
		PRIMEAPE_ATTACK_PERIOD = 2,
		PRIMEAPE_MELEE_RANGE = 3,
		PRIMEAPE_RANGED_RANGE = 17,
		PRIMEAPE_MOVE_SPEED = 7,
		PRIMEAPE_NIGHTMARE_CHASE_DIST = 40,
		PRIMEAPE_LOYALTY_MAXTIME = 2.5*total_day_time,
	    PRIMEAPE_LOYALTY_PER_HUNGER = total_day_time/25,
	    PRIMEAPE_THROW_COOLDOWN = seg_time * 2,
		PRIMEAPE_GOHOME_DELAY = seg_time * 9,

	    MONKEYBALL_USES = 10,
	    MONKEYBALL_PASS_TO_PLAYER_CHANCE = 0.5,

	    OX_HEALTH = 500,
	    OX_DAMAGE = 34,
	    OX_MATING_SEASON_LENGTH = 3,
	    OX_MATING_SEASON_WAIT = 20,
	    OX_MATING_SEASON_BABYDELAY = total_day_time*0.5,
	    OX_MATING_SEASON_BABYDELAY_VARIANCE = total_day_time*0.5,
	    OX_TARGET_DIST = 5,
	    OX_CHASE_DIST = 30,
	    OX_FOLLOW_TIME = 30,

	    BABYOX_HEALTH = 300,
	    BABYOX_GROW_TIME = {base=3*day_time, random=2*day_time},

	    OXHERD_RANGE = 40,
	    OXHERD_MAX_IN_RANGE = 20,

	    -- character vars
	    WOODLEGS_WATER_SANITY = -0.08,
	    WOODLEGS_WALK_SPEED = 2,
	    WOODLEGS_RUN_SPEED = 4,

	    -- standard poison vars
	    VENOM_GLAND_DAMAGE = 75,
	    VENOM_GLAND_MIN_HEALTH = 5,

	    GAS_DAMAGE_PER_INTERVAL = 5, -- the amount of health damage gas causes per interval
	    GAS_INTERVAL = 1, -- how frequently damage is applied

	    POISON_IMMUNE_DURATION = total_day_time, -- the time you are immune to poison after taking antivenom
	    POISON_DURATION = 120, -- the time in seconds that poison normally endures
	    POISON_DAMAGE_PER_INTERVAL = 2, -- the amount of health damage poison causes per interval
	    POISON_INTERVAL = 10, -- how frequently damage is applied

	    -- Total poison attack dmg = normal attack dmg + (POISON_DURATION/POISON_INTERVAL * POISON_DAMAGE_PER_INTERVAL)

	    POISON_DAMAGE_RAMP = -- Elapsed time must be greater than the time value for the associated damage_scale/fxlevel value to be used
	    {
	    	-- (total damage after 3 days: 289.54)
	    	{time = 0.00*total_day_time,	damage_scale = 0.50, 	interval_scale = 1.0, 	fxlevel = 1}, -- 48.00 DMG
	    	{time = 1.00*total_day_time, 	damage_scale = 0.75, 	interval_scale = 1.0, 	fxlevel = 1}, -- 54.00 DMG
	    	{time = 1.75*total_day_time, 	damage_scale = 1.00, 	interval_scale = 1.0, 	fxlevel = 2}, -- 48.00 DMG
	    	{time = 2.25*total_day_time, 	damage_scale = 1.25, 	interval_scale = 0.9, 	fxlevel = 2}, -- 60.00 DMG
	    	{time = 2.70*total_day_time, 	damage_scale = 1.5, 	interval_scale = 0.7, 	fxlevel = 3}, -- 41.14 DMG
	    	{time = 2.90*total_day_time, 	damage_scale = 2.00, 	interval_scale = 0.5, 	fxlevel = 4}, -- 38.40 DMG
		},

		POISON_PERISH_PENALTY = 0.5,

		POISON_HUNGER_DRAIN_MOD = -0.20,
		POISON_DAMAGE_MOD = -0.25,
		POISON_ATTACK_PERIOD_MOD = 0.25,
		POISON_SPEED_MOD = -0.25,

	    AREA_POISONER_CHECK_INTERVAL = .5, -- How frequently an area poisoner checks for nearby entities to infect

	    POISON_SANITY_SCALE = 0.05, -- sanity hit = poison hit * POISON_SANITY_SCALE  set to 0 to turn off

	    REDBARREL_RANGE = 6,
		REDBARREL_DAMAGE = 400,

	    -- Global doydoy controls
	    DOYDOY_MAX_POPULATION = 20,
	    DOYDOY_SPAWN_TIMER = total_day_time * 2, -- try to mate some doydoy's after this ammount of time + random variance
		DOYDOY_SPAWN_VARIANCE = total_day_time,
		DOYDOY_MATING_RANGE = 15,
		DOYDOY_MATING_DANCE_TIME = 3, -- how long should they dance?
		DOYDOY_MATING_DANCE_DIST = 3, -- how far away should they dance?
		DOYDOY_MATING_FEATHER_CHANCE = 0.2, -- feather drop chance after mating

		-- doesn't really matter much for the herds
	    DOYDOY_HERD_SIZE = 20,
	    DOYDOY_HERD_GATHER_RANGE = 40,

		DOYDOY_EGG_HATCH_TIMER = total_day_time * 2,
		DOYDOY_EGG_HATCH_VARIANCE = total_day_time/2,

		DOYDOY_HEALTH = 100,
		DOYDOY_WALK_SPEED = 2,

		DOYDOY_BABY_HEALTH = 25,
		DOYDOY_BABY_WALK_SPEED = 5,
		DOYDOY_BABY_GROW_TIME = total_day_time * 2, --time to grow up

		DOYDOY_TEEN_HEALTH = 75,
		DOYDOY_TEEN_WALK_SPEED = 1.5,
		DOYDOY_TEEN_SCALE = 0.8,
		DOYDOY_TEEN_GROW_TIME = total_day_time * 1, --time to grow up

		-- When you kill doydoys
		DOYDOY_INNOCENCE_REALLY_BAD = 50, -- less than 2 doydoy's left, you get krampus
		DOYDOY_INNOCENCE_BAD = 10, -- less than or equal to 4 doydoy's left, that's BAD
		DOYDOY_INNOCENCE_LITTLE_BAD = 4, -- less than or equal to 10 doydoy's left, that's a LITTLE BAD
		DOYDOY_INNOCENCE_OK = 1, -- there are more than 10 doydoy's so that's OK

		-- Take a look at the regular FIREPIT values way above for reference
		OBSIDIANFIREPIT_BONUS_MULT = 3, -- regular firepit is 2
		OBSIDIANFIREPIT_RAIN_RATE = 2, -- regular rirepit is 2
	    OBSIDIANFIREPIT_FUEL_MAX = (night_time+dusk_time)*3,
	    OBSIDIANFIREPIT_FUEL_START = night_time+dusk_time,
		OBSIDIANFIRE_WINDBLOWN_SPEED = 0.7,
	    OBSIDIANFIRE_BLOWOUT_CHANCE = 0, -- never blow out
	    OBSIDIANFIREPIT_FLOOD_RATE = 10,

	    -- light radius stages for the level of the OBSIDIANFIREFIRE
	    OBSIDIANLIGHT_RADIUS_1 = 4,
	    OBSIDIANLIGHT_RADIUS_2 = 8,
	    OBSIDIANLIGHT_RADIUS_3 = 12,
	    OBSIDIANLIGHT_RADIUS_4 = 14,

		MUSSEL_CATCH_TIME =
	    {
	        {base=1*total_day_time, random=0.5*total_day_time},   --tall to short
	        {base=1*total_day_time, random=0.5*total_day_time},   --tall to short
	        {base=1*total_day_time, random=0.5*total_day_time},   --tall to short
	        {base=1*total_day_time, random=0.5*total_day_time},   --tall to short
	        {base=1*total_day_time, random=0.5*total_day_time},   --tall to short
	        {base=1*total_day_time, random=0.5*total_day_time},   --tall to short
	    },
		MUSSEL_CATCH_SMALL = 1,
		MUSSEL_CATCH_MED = 3,
		MUSSEL_CATCH_LARGE = 6,

		MAPREVEAL_NO_BONUS = 1,
		MAPREVEAL_RAFT_BONUS = 1.5,
		MAPREVEAL_LOGRAFT_BONUS = 1.5,
		MAPREVEAL_ROWBOAT_BONUS = 2,
		MAPREVEAL_CARGOBOAT_BONUS = 2.5,
		MAPREVEAL_ARMOUREDBOAT_BONUS = 2.5,
		MAPREVEAL_PIRATEHAT_BONUS = 3,
		MAPREVEAL_WOODLEGSBOAT_BONUS = 2,
		MAPREVEAL_WORNPIRATEHAT_BONUS = 1.25,
		MAPREVEAL_HURRICANE_PENALTY = 0.5,


	    MACHETE_DAMAGE = wilson_attack* .88,
	    MACHETE_USES = 100,

	    CUTLASS_DAMAGE = wilson_attack*2,
	    CUTLASS_BONUS_DAMAGE = wilson_attack*1,
	    CUTLASS_USES = 150,

	    BAMBOO_HACKS = 6,
	    BAMBOO_REGROW_TIME = total_day_time*4,
	    BAMBOO_WINDBLOWN_SPEED = 0.2,
	    BAMBOO_WINDBLOWN_FALL_CHANCE = 0.1,

	    VINE_HACKS = 6,
	    VINE_REGROW_TIME = total_day_time*4,
	    VINE_WINDBLOWN_SPEED = 0.2,
	    VINE_WINDBLOWN_FALL_CHANCE = 0.1,

	    FISHINGHOLE_MIN_FISH = 6,
	    FISHINGHOLE_MAX_FISH = 10,

	    FISHINGHOLE_ACTIVE_PERIOD = total_day_time,
	    FISHINGHOLE_INACTIVE_PERIOD = total_day_time,

	    CRAB_WALK_SPEED = 1.5,
	    CRAB_RUN_SPEED = 5,
	    CRAB_HEALTH = 50,

	    BLUBBERSUIT_PERISHTIME = total_day_time*8,
	    
	    TARSUIT_PERISHTIME = total_day_time,

	    ROWBOAT_HEALTH = 250,
	    ROWBOAT_PERISHTIME = total_day_time*3,
	    ROWBOAT_SANITY_DRAIN = 0,-- -0.08,
	    ROWBOAT_SPEED = 0,
	    ROWBOAT_LEAKING_HEALTH = 40,

	    RAFT_HEALTH = 150,
	    RAFT_PERISHTIME = total_day_time*2,
	    RAFT_SANITY_DRAIN = 0,-- -0.12,
	    RAFT_SPEED = -1,
	    RAFT_HITMOISTURERATE = 1.25,
	    RAFT_LEAKING_HEALTH = 40,

	    LOGRAFT_HEALTH = 150,
	    LOGRAFT_PERISHTIME = total_day_time*2,
	    LOGRAFT_SANITY_DRAIN = 0,-- -0.12,
	    LOGRAFT_SPEED = -2,
	    LOGRAFT_LEAKING_HEALTH = 40,

	    CARGOBOAT_HEALTH = 300,
	    CARGOBOAT_PERISHTIME = total_day_time*3,
	    CARGOBOAT_SANITY_DRAIN = 0,-- -0.08,
	    CARGOBOAT_SPEED = -1,
	    CARGOBOAT_LEAKING_HEALTH = 40,

	    ARMOUREDBOAT_HEALTH = 500,
	    ARMOUREDBOAT_PERISHTIME = total_day_time*4,
	    ARMOUREDBOAT_SANITY_DRAIN = 0,-- -0.08,
	    ARMOUREDBOAT_SPEED = 0,
	    ARMOUREDBOAT_LEAKING_HEALTH = 40,
	    ARMOUREDBOAT_HIT_IMMUNITY = 3,

		ENCRUSTEDBOAT_HEALTH = 800,
	    ENCRUSTEDBOAT_PERISHTIME = total_day_time*5,
	    ENCRUSTEDBOAT_SANITY_DRAIN = 0,
	    ENCRUSTEDBOAT_SPEED = -2,
	    ENCRUSTEDBOAT_LEAKING_HEALTH = 40,
	    ENCRUSTEDBOAT_HIT_IMMUNITY = 4,

	    WOODLEGSBOAT_SPEED = 0,
	    WOODLEGSBOAT_HEALTH = 500,
	    WOODLEGSBOAT_DAMAGESCALE = 0.5,
	    WOODLEGSBOAT_LEAKING_HEALTH = 40,
	    WOODLEGSBOAT_HIT_IMMUNITY = 2,

	    CORKBOAT_HEALTH = 80,
	    CORKBOAT_PERISHTIME = total_day_time*3,
	    CORKBOAT_SANITY_DRAIN = 0,-- -0.08,
	    CORKBOAT_SPEED = -2,
	    CORKBOAT_LEAKING_HEALTH = 30,	    

	    BOAT_TORCH_LIGHTTIME = night_time*1.75,
	    BOAT_LANTERN_LIGHTTIME = (night_time+dusk_time)*2.6,
	    BOTTLE_LANTERN_LIGHTTIME = (night_time+dusk_time)*2.6,

	    SAIL_SPEED_MULT = 0.2,
	    SAIL_ACCEL_MULT = 0,
	    SAIL_PERISH_TIME = total_day_time*2,

	    CLOTH_SAIL_SPEED_MULT = 0.3,
	    CLOTH_SAIL_ACCEL_MULT = 0.5,
	    CLOTH_SAIL_PERISH_TIME = total_day_time*3,

	    SNAKESKIN_SAIL_SPEED_MULT = 0.25,
	    SNAKESKIN_SAIL_ACCEL_MULT = 0.25,
	    SNAKESKIN_SAIL_PERISH_TIME = total_day_time*4,

	    FEATHER_SAIL_SPEED_MULT = 0.4,
	    FEATHER_SAIL_ACCEL_MULT = 1,
	    FEATHER_SAIL_PERISH_TIME = total_day_time*2,

	    IRON_WIND_SPEED_MULT =  0.5,
	    IRON_WIND_ACCEL_MULT = 2,
	   	IRON_WIND_PERISH_TIME = total_day_time*4,

	   	WOODLEGS_SAIL_ACCEL_MULT = -0.5,

	    LIMPET_REGROW_TIME =  total_day_time*3,

	    TELESCOPE_USES = 5,
	    TELESCOPE_RANGE = 200,
	    TELESCOPE_ARC = 15, --degrees

	    SUPERTELESCOPE_RANGE = 400,

	    -- cactus spike
	    NEEDLESPEAR_DAMAGE = wilson_attack/2, -- wilson_attack is the default damage of a normal spear
	    NEEDLESPEAR_USES = 5,

	    PEG_LEG_DAMAGE = wilson_attack, -- wilson_attack is the default damage of a normal spear
	    PEG_LEG_USES = 50,


	    HARPOON_DAMAGE = 200,
	    HARPOON_USES = 10,
	    HARPOON_RANGE = 6,
	    HARPOON_SPEED = 30,

	    VOLCANOSTAFF_USES = 5,
	    VOLCANOSTAFF_FIRERAIN_COUNT = 8,
	    VOLCANOSTAFF_FIRERAIN_RADIUS = 5,
	    VOLCANOSTAFF_FIRERAIN_DELAY = 0.5,
	    VOLCANOSTAFF_ASH_TIMER = 10.0,

	    VOLCANOBOOK_FIRERAIN_COUNT = 4,
	    VOLCANOBOOK_FIRERAIN_RADIUS = 5,
	    VOLCANOBOOK_FIRERAIN_DELAY = 0.5,

	    COCONADE_FUSE = 5,
	  	COCONADE_DAMAGE = 250,
    	COCONADE_EXPLOSIONRANGE = 6,
    	COCONADE_BUILDINGDAMAGE = 10,

    	COCONADE_POISON_CLOUD_DURATION = 3,

	  	COCONADE_OBSIDIAN_DAMAGE = 350,
    	COCONADE_OBSIDIAN_EXPLOSIONRANGE = 9,
    	COCONADE_OBSIDIAN_BUILDINGDAMAGE = 15,

    	FLOODING_WET_SEASON_PERCENT = 0.9, --percent into wet season floods start spawning
    	FLOODING_SPAWN_TIME = 8 * total_day_time, --time floods will spawn after start
    	FLOODING_SPAWN_PER_SEC = 1.0/30.0, --flood spawns per second
    	FLOODING_FLOOD_TIME = 2 * seg_time, --seconds flood take to reach max size
    	--FLOODING_FLOOD_RATE = 0.15, --rate floods increase in size, a scale of rain rate; smaller is slower
    	FLOODING_DRY_TIME_VARIANCE = 2 * total_day_time, --dry time is days left in green season plus this random variance
    	--FLOODING_DRY_RATE = 0.4, --rate floods decrease in size, a scale of tempurature, and atmosphere moisture
    	FLOODING_MAX_WATERLEVEL = 8, -- radius of max flood size in tiles

    	--These values shouldn't be used anymore, but leaving the tuning in the file just in case!
    	SEASON_LENGTH_MILD_DEFAULT = 20,
    	SEASON_LENGTH_WET_DEFAULT = 15,
    	SEASON_LENGTH_GREEN_DEFAULT = 20,
    	SEASON_LENGTH_DRY_DEFAULT = 15,

    	--Season temps:
    	--Mild: TROPICAL_DRY_CROSSOVER_TEMP (or TROPICAL_MILD_START_WET_CROSSOVER_TEMP in early game) to TROPICAL_WET_CROSSOVER_TEMP
    	--Wet: TROPICAL_WET_CROSSOVER_TEMP to TROPICAL_MIN_SEASON_TEMP to TROPICAL_WET_CROSSOVER_TEMP
    	--Green: TROPICAL_WET_CROSSOVER_TEMP to TROPICAL_DRY_CROSSOVER_TEMP
    	--Dry: TROPICAL_DRY_CROSSOVER_TEMP to TROPICAL_MAX_SEASON_TEMP to TROPICAL_DRY_CROSSOVER_TEMP

		TROPICAL_DRY_STARTEND_TEMP = 50, --Dry start/end temp
		TROPICAL_DRY_MID_TEMP = 65, --Dry middle
		TROPICAL_DRY_RAIN_TEMP = -10, --Temp drop during dry season rain
		TROPICAL_WET_MID_TEMP = 35, --Wet middle
		TROPICAL_WET_STARTEND_TEMP = 40, --Wet start/end temp
		TROPICAL_MILD_START_TEMP = 40, --Only first 10 days of game
		TROPICAL_DAY_TEMP = 10, --Peak temp change during the day
		TROPICAL_NIGHT_TEMP = -5, --Peak temp change during the night
		TROPICAL_HURRICANE_TEMP = -10, --Peak temp change during a hurricane
		TROPICAL_HURRICANE_WIND_TEMP = -10, --Peak temp change during hurricane wind gusts 'wind chill'

		PLATEAU_LUSH_START_TEMP = 40, --50
		PLATEAU_LUSH_DEVIATE_TEMP = 0, --30
		PLATEAU_LUSH_DAY_TEMP_INCREASE = 20,
		PLATEAU_LUSH_NIGHT_TEMP_INCREASE = -10,
		PLATEAU_LUSH_DUSK_TEMP_INCREASE = -5,

		PLATEAU_LUSH_POLLEN_PARTICLES = 1,		

		PLATEAU_HUMID_START_TEMP = 30,
		PLATEAU_HUMID_DEVIATE_TEMP = 0,  -- -30,
		PLATEAU_HUMID_MIN_TEMP = 0,
		PLATEAU_HUMID_NIGHT_TEMP_INCREASE = -20,
		PLATEAU_HUMID_DUSK_TEMP_INCREASE = -10,

		PLATEAU_TEMPERATE_START_TEMP = 40,
		PLATEAU_DAY_TEMP = 10, --Peak temp change during the day
		PLATEAU_NIGHT_TEMP = -5, --Peak temp change during the night

		PLATEAU_HURRICANE_TEMP = -10, --Peak temp change during a hurricane
		PLATEAU_HURRICANE_WIND_TEMP = -10, --Peak temp change during hurricane wind gusts 'wind chill'		

		WIND_GUSTSPEED_PEAK_MIN = 0.9,
		WIND_GUSTSPEED_PEAK_MAX = 1.0,
		WIND_GUSTRAMPUP_TIME = 0.5,
		WIND_GUSTRAMPDOWN_TIME = 32.0/30.0, --Hacky, exact time of windshirl anim
		WIND_GUSTLENGTH_MIN = 7, -- measured in seconds
		WIND_GUSTLENGTH_MAX = 10,
		WIND_GUSTDELAY_MIN = 15, -- time between gusts
		WIND_GUSTDELAY_MAX = 16,

		HURRICANE_LENGTH_MIN = total_day_time,
		HURRICANE_LENGTH_MAX = 2.5 * total_day_time,
		HURRICANE_PERCENT_WIND_START = 0.01,
		HURRICANE_PERCENT_WIND_END = 0.8,
		HURRICANE_PERCENT_RAIN_START = 0.25,
		HURRICANE_PERCENT_RAIN_END = 0.95,
		HURRICANE_PERCENT_HAIL_START = 0.25,
		HURRICANE_PERCENT_HAIL_END = 0.95,
		HURRICANE_PERCENT_LIGHTNING_START = 0.2,
		HURRICANE_PERCENT_LIGHTNING_END = 0.95,
		HURRICANE_LIGHTNING_STRIKE_CHANCE = 0.1,
		HURRICANE_RAIN_SCALE = 0.5,
		HURRICANE_HAIL_SCALE = 0.5,
		HURRICANE_HAIL_DAMAGE = 1,
		HURRICANE_HAIL_BREAK_CHANCE = 0.8,

		HURRICANE_TEASE_LENGTH = 0.5 * total_day_time,

		WIND_GUSTDELAY_MIN_LUSH = 15,
		WIND_GUSTDELAY_MAX_LUSH = 720,

		WINDBLOWN_DESTROY_DIST = 15, --distance from player wind blown prefabs can be destroyed, fall over, get picked, etc
		WINDBLOWN_SCALE_MIN =
		{
			LIGHT = 0.1,
			MEDIUM = 0.1,
			HEAVY = 0.01
		},
		WINDBLOWN_SCALE_MAX =
		{
			LIGHT = 1.0,
			MEDIUM = 0.25,
			HEAVY = 0.05
		},

		WINDPROOFNESS_SMALL = 0.2,
		WINDPROOFNESS_SMALLMED = 0.35,
		WINDPROOFNESS_MED = 0.5,
		WINDPROOFNESS_LARGE = 0.7,
		WINDPROOFNESS_HUGE = 0.9,
		WINDPROOFNESS_ABSOLUTE = 1,

		PARROT_PIRATE_CHANCE = 0.1,

		-- whale hunt stuff
		WHALEHUNT_ALTERNATE_BEAST_CHANCE_MIN = 0.05,
	    WHALEHUNT_ALTERNATE_BEAST_CHANCE_MAX = 0.33,
	    WHALEHUNT_SPAWN_DIST = 40,
	    WHALEHUNT_COOLDOWN = total_day_time*1.2,
	    WHALEHUNT_COOLDOWNDEVIATION = total_day_time*.3,
	    WHALEHUNT_MIN_TRACKS = 5,
	    WHALEHUNT_MAX_TRACKS = 7,
	    WHALEHUNT_RESET_TIME = 5,

	    WHALEHUNT_TRACK_ANGLE_DEVIATION = 160,
	    MIN_WHALEHUNT_DISTANCE = 300, -- you can't find a new beast without being at least this far from the last one
	    MAX_DIRT_DISTANCE = 200, -- if you get this far away from your dirt pile, you probably aren't going to see it any time soon, so remove it and place a new one
	    -- end whale hunt

	    WHALE_BLUE_HEALTH = 650,
	    WHALE_BLUE_DAMAGE = 50,
	    WHALE_BLUE_TARGET_DIST = 10,
	    WHALE_BLUE_CHASE_DIST = 30,
	    WHALE_BLUE_FOLLOW_TIME = 60,
	    WHALE_BLUE_SPEED = 4,
	    WHALE_BLUE_EXPLOSION_HACKS = 3,
	    WHALE_BLUE_EXPLOSION_DAMAGE = 25,

	    WHALE_WHITE_HEALTH = 800,
	    WHALE_WHITE_DAMAGE = 75,
	    WHALE_WHITE_TARGET_DIST = 15,
	    WHALE_WHITE_CHASE_DIST = 40,
	    WHALE_WHITE_FOLLOW_TIME = 90,
	    WHALE_WHITE_SPEED = 5,
	    WHALE_WHITE_EXPLOSION_HACKS = 3,
	    WHALE_WHITE_EXPLOSION_DAMAGE = 50,

    	SNAKE_SPEED = 3,
    	SNAKE_TARGET_DIST = 8,
    	SNAKE_KEEP_TARGET_DIST= 15,
    	SNAKE_HEALTH = 100,
	    SNAKE_DAMAGE = 10,
	    SNAKE_ATTACK_PERIOD = 3,
	    SNAKE_POISON_CHANCE = 0.25,
	    SNAKE_POISON_START_DAY = 3, -- the day that poison snakes have a chance to show up
	    SNAKEDEN_REGEN_TIME = 3*seg_time,
		SNAKEDEN_RELEASE_TIME = 5,
	    SNAKE_JUNGLETREE_CHANCE = 0.5, -- chance of a normal snake
	    SNAKE_JUNGLETREE_POISON_CHANCE = 0.25, -- chance of a poison snake
	    SNAKE_JUNGLETREE_AMOUNT_TALL = 2, -- num of times to try and spawn a snake from a tall tree
	    SNAKE_JUNGLETREE_AMOUNT_MED = 1, -- num of times to try and spawn a snake from a normal tree
	    SNAKE_JUNGLETREE_AMOUNT_SMALL = 1, -- num of times to try and spawn a snake from a small tree
	    SNAKEDEN_MAX_SNAKES = 3,
        SNAKEDEN_CHECK_DIST = 20,
        SNAKEDEN_TRAP_DIST = 2,

       	STINKRAY_DAMAGE = 3,
        STINKRAY_HEALTH = 50,
        STINKRAY_ATTACK_PERIOD = 1,
        STINKRAY_ATTACK_DIST = 1.5,
	    STINKRAY_TARGET_DIST = 6,
        STINKRAY_WALK_SPEED = 8,
        STINKRAY_CHASE_TIME = 3,
        STINKRAY_CHASE_DIST = 10,
        STINKRAY_SCALE_FLYING = 1.05,
		STINKRAY_SCALE_WATER = 1.00,

        BALLPHIN_TARGET_DIST = 8,
		BALLPHIN_KEEP_TARGET_DIST = 15,
		BALLPHIN_FRIEND_CHANCE = 0.01, -- chance that ballphins will spawn to assist you during a crocodog attack
		BALLPHIN_LOYALTY_PER_HUNGER = total_day_time/12,
		BALLPHIN_LOYALTY_MAX_TIME = total_day_time * 3,
		BALLPHIN_MIN_POOP_PERIOD = seg_time * .5,
		BALLPHIN_DROWN_RESCUE_CHANCE = .8,
		BALLPHIN_HEALTH = 200,
		BALLPHIN_DAMAGE = 25,
		BALLPHIN_ATTACK_PERIOD = 3,
		BALLPHIN_PALACE_MAX_CHILDREN = 1,		

	    DRAGOON_TARGET_DIST = 8,
		DRAGOON_KEEP_TARGET_DIST = 10,
		DRAGOON_WALK_SPEED = 3,
		DRAGOON_RUN_SPEED = 15,
		DRAGOON_HEALTH = 300,
		DRAGOON_DAMAGE = 25,
		DRAGOON_ATTACK_PERIOD = 1,
		DRAGOON_CHASE_TIME = 3,
		DRAGOONEGG_HATCH_TIMER = 120,
		DRAGOONFIRE_FUEL_MAX = (night_time+dusk_time),
		DRAGOONFIRE_FUEL = 2,

		WHALE_ROT_TIME =
	    {
	        {base=2*day_time, random=0.5*day_time}, -- bloat1
	        {base=2*day_time, random=0.5*day_time}, -- bloat2
	        {base=1*day_time, random=0.5*day_time}, -- bloat3
	    },

	    JUNGLETREE_CHOPS_SMALL = 5,
	    JUNGLETREE_CHOPS_NORMAL = 10,
	    JUNGLETREE_CHOPS_TALL = 15,
	    JUNGLETREE_WINDBLOWN_SPEED = 0.2,
	    JUNGLETREE_WINDBLOWN_FALL_CHANCE = 0.01,

	   	JUNGLETREESEED_GROWTIME = {base=4.5*day_time, random=0.75*day_time},

	    JUNGLETREE_GROW_TIME =
	    {
	        {base=4.5*day_time, random=0.5*day_time},   --tall to short
	        {base=8*day_time, random=5*day_time},   --short to normal
	        {base=8*day_time, random=5*day_time},   --normal to tall
	    },

	    COCONUT_GROWTIME = {base=2.5*day_time, random=0.75*day_time},

	    PALMTREE_GROW_TIME =
	    {
	        {base=1.5*day_time, random=0.5*day_time},   --tall to short
	        {base=5*day_time, random=2*day_time},   --short to normal
	        {base=5*day_time, random=2*day_time},   --normal to tall
	    },

	   	PALMTREE_CHOPS_SMALL = 5,
	    PALMTREE_CHOPS_NORMAL = 10,
	    PALMTREE_CHOPS_TALL = 15,
	    PALMTREE_COCONUT_CHANCE = 0.01,

	    MANGROVETREE_CHOPS_SMALL = 5,
	    MANGROVETREE_CHOPS_NORMAL = 10,
	    MANGROVETREE_CHOPS_TALL = 15,
	    MANGROVETREE_WINDBLOWN_SPEED = 0.2,
	    MANGROVETREE_WINDBLOWN_FALL_CHANCE = 0.01,
	    MANGROVETREE_GROW_TIME =
	    {
	        {base=4.5*day_time, random=0.5*day_time},   --tall to short
	        {base=8*day_time, random=5*day_time},   --short to normal
	        {base=8*day_time, random=5*day_time},   --normal to tall
	        {base=2.5*day_time, random=0.75*day_time}   --stump to short
	    },

	    SPEARGUN_DAMAGE = 100,

	    ARMOR_SNAKESKIN_PERISHTIME = total_day_time*8, --was 10
	    SNAKESKINHAT_PERISHTIME = total_day_time*8, --was 10

	    JELLYFISH_WALK_SPEED = 2,
	    JELLYFISH_DAMAGE = 5,
	    JELLYFISH_HEALTH = 50,

		RAINBOWJELLYFISH_WALKSPEED = 3,
		RAINBOWJELLYFISH_LIGHT_RADIUS = 3,
		RAINBOWJELLYFISH_LIGHT_DURATION = 90,

	    ELEPHANTCACTUS_DAMAGE = 20,
	    ELEPHANTCACTUS_HEALTH = 400,
	    ELEPHANTCACTUS_RANGE = 5,
	    ELEPHANTCACTUS_REGROW_PERIOD = 2,

	    TWISTER_CALM_WALK_SPEED = 5,
	    TWISTER_ANGRY_WALK_SPEED = 8,
	    TWISTER_RUN_SPEED = 13,
	    TWISTER_HEALTH = 3000,
	    TWISTER_DAMAGE = 150,
	    TWISTER_VACUUM_DAMAGE = 500,
	    TWISTER_VACUUM_SANITY_HIT = -33,
	    TWISTER_VACUUM_DISTANCE = 15,
	    TWISTER_PLAYER_VACUUM_DISTANCE = 30,
	    TWISTER_ATTACK_PERIOD = 3,
		TWISTER_MELEE_RANGE = 6,
		TWISTER_ATTACK_RANGE = 6,
		TWISTER_VACUUM_COOLDOWN = 20,
		TWISTER_CHARGE_COOLDOWN = 10,

		TWISTER_VACUUM_ANTIC_TIME = 5,
		TWISTER_VACUUM_TIME = 5,

		TWISTER_WAVES_ANTIC_TIME = 7,
		TWISTER_WAVES_TIME = 5,

		TWISTER_SEAL_HEALTH = 10,

	    WIND_PUSH_MULTIPLIER = 0.4, --was 0.5
	    FLOOD_SPEED_MULTIPLIER = 0.8, --was 0.6

	    WIND_HUNGER_MULTIPLIER = 1.1,
	    FLOOD_HUNGER_MULTIPLIER = 1.1,

	    PALMTREE_WINDBLOWN_SPEED = 0.2,
	    PALMTREE_WINDBLOWN_FALL_CHANCE = 0.01,
	    GRASS_WINDBLOWN_SPEED = 0.2,
	    GRASS_WINDBLOWN_FALL_CHANCE = 0.01,
	    SAPLING_WINDBLOWN_SPEED = 0.2,
	    SAPLING_WINDBLOWN_FALL_CHANCE = 0.1,
	    REEDS_WINDBLOWN_SPEED = 0.2,
	    REEDS_WINDBLOWN_FALL_CHANCE = 0.1,
	    BERRYBUSH_WINDBLOWN_SPEED = 0.2,
	    BERRYBUSH_WINDBLOWN_FALL_CHANCE = 0.01,
	    FLOWER_WINDBLOWN_SPEED = 0.2,
	    FLOWER_WINDBLOWN_FALL_CHANCE = 0.1,
	    PIGHOUSE_WINDBLOWN_SPEED = 0.2,
	    PIGHOUSE_WINDBLOWN_FALL_CHANCE = 0.1,
	    WALLHAY_WINDBLOWN_SPEED = 0.2,
	    WALLHAY_WINDBLOWN_DAMAGE_CHANCE = 0.9,
	    WALLHAY_WINDBLOWN_DAMAGE = wilson_attack,
	    WALLWOOD_WINDBLOWN_SPEED = 0.2,
	    WALLWOOD_WINDBLOWN_DAMAGE_CHANCE = 0.9,
	    WALLWOOD_WINDBLOWN_DAMAGE = 0.5*wilson_attack,
	    MUSSELFARM_WINDBLOWN_SPEED = 0.2,
	    MUSSELFARM_WINDBLOWN_FALL_CHANCE = 0.1,
	    SAND_WINDBLOWN_SPEED = 0.2,
	    SAND_WINDBLOWN_FALL_CHANCE = 0.1,

	    SANDBAG_HEALTH = 200,

	    FIRE_WINDBLOWN_SPEED = 0.7,
	    FIRE_BLOWOUT_CHANCE = 0.9, --chance a fire blows out when wind gets fast enough

	    TREE_CREAK_WINDBLOWN_SPEED = 0.2, --creak sound (all trees)
	    TREE_CREAK_RANGE = 16,

	    FISHING_ROD_BASE_NIBBLE_TIME = 5,
	    FISHING_ROD_NIBBLE_TIME_VARIANCE = 5,
	    FISHING_ROD_STEAL_CHANCE = 50,

	    BIG_FISHING_ROD_BASE_NIBBLE_TIME = 2, --For catching fish entities (fishing 2)
	    BIG_FISHING_ROD_NIBBLE_TIME_VARIANCE = 2, --For catching fish entities (fishing 2)
	    BIG_FISHING_ROD_STEAL_CHANCE = 0,
	    BIG_FISHING_ROD_USES = 14,
	    BIG_FISHING_ROD_MIN_WAIT_TIME = 4, --For pond fishing
	    BIG_FISHING_ROD_MAX_WAIT_TIME = 20, --For pond fishing

	    CAFFEINE_FOOD_BONUS_SPEED = 5, -- player base speed plus this, 6 is normal walk speed
		HYDRO_FOOD_BONUS_DRY = 1, -- player base speed plus this, 6 is normal walk speed
		HYDRO_FOOD_BONUS_DRY_RATE = 3, -- player base speed plus this, 6 is normal walk speed
		HYDRO_FOOD_BONUS_SURF = 2, -- player base speed plus this, 6 is normal walk speed
		HYDRO_FOOD_BONUS_COOL_RATE = 3,
		HYDRO_BONUS_COOL_RATE = 4,

		FOOD_SPEED_BRIEF = 0, -- eating coffeebeans gives you the bonus for this many seconds
		FOOD_SPEED_AVERAGE = 30, -- eating roasted coffee beans
		FOOD_SPEED_LONG = total_day_time / 2, -- drinking coffee

		SAND_REGROW_TIME = total_day_time*2, -- sand dune regrow time
		SAND_REGROW_VARIANCE = total_day_time, -- sand dune regrow variance
		SAND_DEPLETE_CHANCE = 0.25, -- chance of sandhill depleting during "green" season (0.25 means a 25% chance)

		WAVEBOOST = 5,
		ENCRUSTEDBOAT_WAVEBOOST = 20,
		SURFBOARD_WAVEBOOST = 25,
		SURFBOARD_ROGUEBOOST = 35,
		SURFBOARD_WAVESANITYBOOST = 1, -- same as supertiny
	    SURFBOARD_HEALTH = 100,
	    SURFBOARD_PERISHTIME = total_day_time*2,
	    SURFBOARD_SANITY_DRAIN = 0,
	    SURFBOARD_SPEED = 0.5,
	    SURFBOARD_HITMOISTURERATE = 1.5,
	    WAVE_HIT_MOISTURE = 15,
	    WAVE_HIT_DAMAGE = 5,

	    ROGUEWAVE_HIT_MOISTURE = 25,
	    ROGUEWAVE_HIT_DAMAGE = 10,
	    ROGUEWAVE_SPEED_MULTIPLIER = 3,

	    ARMORSEASHELL = wilson_health * 5,
	    ARMORSEASHELL_ABSORPTION = 0.75,

	    SOLOFISH_WALK_SPEED = 5,
	    SOLOFISH_RUN_SPEED = 8,
	    SOLOFISH_HEALTH = 100,
	    SOLOFISH_WANDER_DIST = 10,

	    TIGERSHARK_WALK_SPEED = 8,
	    TIGERSHARK_RUN_SPEED = 12,
	    TIGERSHARK_HEALTH = 2500,
	    TIGERSHARK_DAMAGE = 100,
	    TIGERSHARK_ATTACK_PERIOD = 3,
	    TIGERSHARK_ATTACK_RANGE = 4,
	    TIGERSHARK_SPLASH_RADIUS = 5,
	    TIGERSHARK_SPLASH_DAMAGE = 125,

	    SHARKITTEN_REGEN_PERIOD = total_day_time * 5,
	    SHARKITTEN_SPAWN_PERIOD = seg_time,
	    SHARKITTEN_SPEED = 10,
	    SHARKITTEN_HEALTH = 150,


	    ICEMAKER_SPAWN_TIME = seg_time,
	    ICEMAKER_FUEL_MAX = seg_time * 3,
	    CORAL_MINE = 9,

	    CORAL_BRAIN_REGROW = total_day_time * 20,

	    SHARX_HEALTH = 150,
	    SHARX_DAMAGE = 20,
	    SHARX_ATTACK_PERIOD = 1.5,
	    SHARX_TARGET_DIST = 20,
	    SHARX_SPEED = 10,

	    TRAWLNET_MAX_ITEMS = 9, --Don't make this larger than 9 without talking to Dave
	    TRAWLNET_ITEM_DISTANCE = 100, --How far you have to travel to get another item
	    TRAWLING_SPEED_MULT = -0.25,
	    TRAWL_SINK_TIME = seg_time * 3,

	    LIMESTONEWALL_HEALTH = 500,
		ENFORCEDLIMESTONEWALL_HEALTH = 750,
	    ARMORLIMESTONE = wilson_health * 5.5,
		ARMORLIMESTONE_ABSORPTION = 0.7,
		ARMORLIMESTONE_SPEED_MULT = -0.1,

		ARMORCACTUS = wilson_health*3,
		ARMORCACTUS_ABSORPTION = .8,
		ARMORCACTUS_DMG = wilson_attack/2,

		MAPWRAPPER_TELEPORT_RANGE = 2,
		MAPWRAPPER_LOSECONTROL_RANGE = 8,
		MAPWRAPPER_GAINCONTROL_RANGE = 8,
		MAPWRAPPER_WARN_RANGE = 14,
		MAPWRAPPER_EDGEFOG_RANGE = 6,

		MAPEDGE_PADDING = 14 + 10, --Should be greater than MAPWRAPPER_WARN_RANGE

		WOODLEGS_BOATCANNON_DAMAGE = 50,
		BOATCANNON_DAMAGE = 100,
		BOATCANNON_RADIUS = 4,
		BOATCANNON_BUILDINGDAMAGE = 10,
	    BOATCANNON_AMMO_COUNT = 15,

	    WINDBREAKER_PERISHTIME = total_day_time*10, --was 15
	    AERODYNAMICHAT_PERISHTIME = 48*seg_time, --was 8
	    AERODYNAMICHAT_SPEED_MULT = 0.25,

	    CAPTAINHAT_PERISHTIME = total_day_time*2, --I boosted pirate and captain from 10 segments
	    PIRATEHAT_PERISHTIME = total_day_time*2,
	    GASHAT_PERISHTIME = 80*seg_time,  --was 10

	    SWORDFISH_WALK_SPEED = 5,
	    SWORDFISH_RUN_SPEED = 8,
	    SWORDFISH_HEALTH = 200,
	    SWORDFISH_WANDER_DIST = 10,
	    SWORDFISH_TARGET_DIST =12,
	    SWORDFISH_DAMAGE = 30,
	    SWORDFISH_ATTACK_PERIOD = 2,

	    SANDCASTLE_PERISHTIME = total_day_time,
	    SANDCASTLE_RAIN_PERISH_RATE = 2,
	    SANDCASTLE_WIND_PERISH_RATE = 2,

	    FISHING_CROCODOG_SPAWN_CHANCE = 0.2,
	    SHARKBAIT_CROCODOG_SPAWN_MULT = 0.005, --Chance of spawning a crocodog is this number multiplied by hunger value of the food
        PUDDLE_CROCODOG_SPAWN_CHANCE = 0.2,

	    SHARK_HAT_PERISHTIME = total_day_time*9,

	 	DO_SEA_DAMAGE_TO_BOAT = true,
	 	BOAT_REPAIR_KIT_HEALING = 100,
	 	BOAT_REPAIR_KIT_USES = 3,

	 	APPEASEMENT_TINY = 4,
	 	APPEASEMENT_SMALL = 8,
	 	APPEASEMENT_MEDIUM = 16,
	 	APPEASEMENT_LARGE = 32,
	 	APPEASEMENT_HUGE = 64,

	 	WRATH_SMALL = -8,
	 	WRATH_LARGE = -16,

	 	VOLCANO_ALTAR_MAXAPPEASEMENTS = 5,
	 	VOLCANO_ALTAR_DAMAGE = 6,

	 	VOLCANO_FIRERAIN_WARNING = 2,
	 	VOLCANO_FIRERAIN_RADIUS = 20,
	 	VOLCANO_FIRERAIN_DAMAGE = 300,
	 	VOLCANO_FIRERAIN_LAVA_CHANCE = 0.5,
	 	VOLCANO_DRAGOONEGG_CHANCE = 0.25,

	    CHIMINEA_FUEL_MAX = (night_time+dusk_time)*2,
	    CHIMINEA_FUEL_START = night_time+dusk_time,
	    CHIMINEA_BONUS_MULT = 2,

	    LAVAPOOL_FUEL_MAX = (night_time+dusk_time),
	    LAVAPOOL_FUEL_START = (night_time+dusk_time)*.75,

	    DOUBLE_UMBRELLA_PERISHTIME = total_day_time*12,

	    PACKIM_MAX_HUNGER = 150,
	    PACKIM_TRANSFORM_HUNGER = 120,
	    PACKIM_HUNGER_DRAIN = 0.1,
	    PACKIM_FIRE_DELAY_MIN = 5,
	    PACKIM_FIRE_DELAY_MAX = 10,

	    SEAWEED_REGROW_TIME = total_day_time*3,
	    SEAWEED_REGROW_VARIANCE = total_day_time*2,

	    VOLCANORIM_ACTIVE_HEAT = 70,
	    VOLCANORIM_ACTIVE_MULT = 32,
	    VOLCANORIM_LAVA_HEAT = 140,
	    VOLCANORIM_LAVA_MULT = 32,
	    VOLCANORIM_LAVA_DIST = 4,

	    FISHING_HOLE_RESPAWN = total_day_time/2,

	    FLUP_JUMPATTACK_RANGE = 4,
	    FLUP_MELEEATTACK_RANGE = 2,
	    FLUP_HIT_RANGE = 1.75,
	    FLUP_HEALTH = 100,
	    FLUP_ATTACK_PERIOD = 2,
	    FLUP_DAMAGE = 25,

	    FLUP_DART_DAMAGE = 20,

	    FIRE_DART_DAMAGE = 5,

	    FLAMEGEYSER_SPAWN_CHANCE = 0.5,
	    FLAMEGEYSER_FUEL_MAX = seg_time*0.5,
	    FLAMEGEYSER_FUEL_START = seg_time*0.5,
	    FLAMEGEYSER_REIGNITE_TIME = seg_time,
	    FLAMEGEYSER_REIGNITE_TIME_VARIANCE = seg_time*0.5,

	    SUNKENPREFAB_REMOVE_TIME = total_day_time*2,

	    LOBSTER_HEALTH = 25,
	    LOBSTER_WALK_SPEED = 1.5,
	    LOBSTER_RUN_SPEED = 4,

		-- PALMTREEGUARD
	    PALMTREEGUARD_MELEE = 5,

		PALMTREEGUARD_HEALTH = 750,
	    PALMTREEGUARD_DAMAGE = 150,
	    PALMTREEGUARD_ATTACK_PERIOD = 3,
	    PALMTREEGUARD_FLAMMABILITY = .333,

	    PALMTREEGUARD_MIN_DAY = 3,
	    PALMTREEGUARD_PERCENT_CHANCE = 1/75,
	    PALMTREEGUARD_MAXSPAWNDIST = 30,

	    PALMTREEGUARD_PINECONE_CHILL_CHANCE_CLOSE = .33,
	    PALMTREEGUARD_PINECONE_CHILL_CHANCE_FAR = .15,
	    PALMTREEGUARD_PINECONE_CHILL_CLOSE_RADIUS = 5,
	    PALMTREEGUARD_PINECONE_CHILL_RADIUS = 16,
	    PALMTREEGUARD_REAWAKEN_RADIUS = 20,

	    PALMTREEGUARD_BURN_TIME = 10,
	    PALMTREEGUARD_BURN_DAMAGE_PERCENT = 1/8,
		---------------------------------------------------

		-- JUNGLETREEGUARD
		JUNGLETREEGUARD_MELEE = 5,

		JUNGLETREEGUARD_HEALTH = 750,
	    JUNGLETREEGUARD_DAMAGE = 150,
	    JUNGLETREEGUARD_ATTACK_PERIOD = 7,
		JUNGLETREEGUARD_RANGED_ATTACK_PERIOD = 4,
		JUNGLETREEGUARD_RANGED_ATTACK_CHANCE = 0.5,
	    JUNGLETREEGUARD_FLAMMABILITY = .333,

	    -- cumulative on top of snake chance: X chance to throw snake, then Y chance for that snake to be poisonous
	    JUNGLETREEGUARD_SNAKE_POISON_CHANCE = 0.25,

	    JUNGLETREEGUARD_MIN_DAY = 3,
	    JUNGLETREEGUARD_PERCENT_CHANCE = 1/75,
	    JUNGLETREEGUARD_MAXSPAWNDIST = 30,

	    JUNGLETREEGUARD_PINECONE_CHILL_CHANCE_CLOSE = .33,
	    JUNGLETREEGUARD_PINECONE_CHILL_CHANCE_FAR = .15,
	    JUNGLETREEGUARD_PINECONE_CHILL_CLOSE_RADIUS = 5,
	    JUNGLETREEGUARD_PINECONE_CHILL_RADIUS = 16,
	    JUNGLETREEGUARD_REAWAKEN_RADIUS = 20,

		JUNGLETREEGUARD_BURN_TIME = 10,
	    JUNGLETREEGUARD_BURN_DAMAGE_PERCENT = 1/8,
		---------------------------------------------------

		-- QUACKERINGRAM
		QUACKERINGRAM_USE_COUNT = 15,
		QUACKERINGRAM_DAMAGE = 150,
		QUACKERINGRAM_TIMEOUT = 1,

	    SEASHELL_REGEN_TIME = total_day_time * 2, --So small for temp testing
		LIVINGJUNGLETREE_CHANCE = 0.90,

	    WAVE_BOOST_ANGLE_THRESHOLD = 90,

		KNIGHTBOAT_RADIUS = 1.5,
		KNIGHTBOAT_DAMAGE = 50,

		MAX_FLOOD_LEVEL = 15,
		FLOOD_FREQUENCY = 0.005,

		SAILSTICK_PERISHTIME = total_day_time * 10,
		WIND_CONCH_USES = 10,

		OBSIDIAN_TOOL_MAXCHARGES = 75,
		OBSIDIAN_TOOL_MAXHEAT = 60,

		OBSIDIAN_WEAPON_MAXCHARGES = 30,

		FLOTSAM_REBATCH_TIME = total_day_time * 15,
        FLOTSAM_INDIVIDUAL_TIME = total_day_time * 0.2,
        FLOTSAM_BATCH_SIZE = { min = 2, max = 5 },
        FLOTSAM_SPAWN_RADIUS = 35,
        FLOTSAM_DRIFT_SPEED = 1,
        FLOTSAM_DECAY_TIME = total_day_time * 2,

        SPEAR_LAUNCHER_DAMAGE_MOD = 3,
        SPEAR_LAUNCHER_ATTACK_RANGE = 12,
        SPEAR_LAUNCHER_HIT_RANGE = 14,
        SPEAR_LAUNCHER_USES = 8,
        SPEAR_LAUNCHER_SPEAR_WEAR = 10,

        BLUNDERBUSS_ATTACK_RANGE = 9,
        BLUNDERBUSS_HIT_RANGE = 11,

        WOODLEGSHAT_PERISHTIME = total_day_time*10,
        WOODLEGSHAT_TREASURES = 6,

        POOP_THROWN_DAMAGE = 10,

        OX_FLUTE_USES = 5,
        TAR_EXTRACTOR_MAX_FUEL_TIME = total_day_time*2,
        SEA_YARD_MAX_FUEL_TIME = seg_time*6,

        TAR_TRAP_TIME = seg_time,

        SLOWING_OBJECT_SLOWDOWN = 0.35,

		DUNG_BEETLE_RUN_SPEED = 6, --7  
		DUNG_BEETLE_WALK_SPEED = 3.5,    --3		
		DUNG_BEETLE_HEALTH = 60,  

		SPIDER_MONKEY_SPEED_AGITATED = 5.5,  --4
		SPIDER_MONKEY_SPEED = 5.5, --2		
		SPIDER_MONKEY_HEALTH = 550,

	    SPIDER_MONKEY_DAMAGE = 60,
	    SPIDER_MONKEY_ATTACK_PERIOD = 2,
	    SPIDER_MONKEY_ATTACK_RANGE = 4,
	    SPIDER_MONKEY_HIT_RANGE = 3,
	    SPIDER_MONKEY_MELEE_RANGE = 4,
	    SPIDER_MONKEY_TARGET_DIST = 8,
	    SPIDER_MONKEY_WAKE_RADIUS = 6,

	    SPIDER_MONKEY_DEFEND_DIST = 12,

		SPIDER_MONKEY_MATING_SEASON_BABYDELAY = total_day_time*1.5,
		SPIDER_MONKEY_MATING_SEASON_BABYDELAY_VARIANCE = 0.5*total_day_time,

	    RUINS_ENTRANCE_VINES_HACKS = 4,
	    RUINS_DOOR_VINES_HACKS = 2,

	   	GRABBING_VINE_HEALTH = 100,
	    GRABBING_VINE_DAMAGE = 10,
	    GRABBING_VINE_ATTACK_PERIOD = 1,
	    GRABBING_VINE_TARGET_DIST = 3,	

	    ZEB_DAMAGE = 20,
	    ZEB_ATTACK_RANGE = 3,
	    ZEB_ATTACK_PERIOD = 2,
	    ZEB_WALK_SPEED = 6,
	    ZEB_RUN_SPEED = 10,
	    ZEB_TARGET_DIST = 5,
	    ZEB_CHASE_DIST = 30,
	    ZEB_FOLLOW_TIME = 30,
	    ZEB_MATING_SEASON_BABYDELAY = total_day_time*1.5,
	    ZEB_MATING_SEASON_BABYDELAY_VARIANCE = 0.5*total_day_time,	 

	    SCORPION_HEALTH = 200,
	    SCORPION_DAMAGE = 20,
	    SCORPION_ATTACK_PERIOD = 3,
	    SCORPION_TARGET_DIST = 4,
	    SCORPION_INVESTIGATETARGET_DIST = 6,
	    SSCORPION_WAKE_RADIUS = 4,
	    SCORPION_FLAMMABILITY = .33,
		SCORPION_SUMMON_WARRIORS_RADIUS = 12,
		SCORPION_EAT_DELAY = 1.5,
		SCORPION_ATTACK_RANGE = 3,		
		SCORPION_STING_RANGE = 2,		

	    SCORPION_WALK_SPEED = 3,
	    SCORPION_RUN_SPEED = 5,

		BILL_TUMBLE_SPEED = 8,
	    BILL_RUN_SPEED = 5,
	    BILL_DAMAGE = wilson_attack * 0.5,
	    BILL_HEALTH = 250,
	    BILL_ATTACK_PERIOD = 3,
	    BILL_TARGET_DIST = 50,
	    BILL_AGGRO_DIST = 15,
	    BILL_EAT_DELAY = 3.5,
	   	BILL_SPAWN_CHANCE = 0.2,

	    GIANT_GRUB_WALK_SPEED = 2,
	    GIANT_GRUB_DAMAGE = 44,
	    GIANT_GRUB_HEALTH = 600,
	    GIANT_GRUB_ATTACK_PERIOD = 3,
	    GIANT_GRUB_ATTACK_RANGE = 3,
	    GIANT_GRUB_TARGET_DIST = 25,

	    ANTMAN_DAMAGE = wilson_attack * 2/3,
	    ANTMAN_HEALTH = 250,
	    ANTMAN_ATTACK_PERIOD = 3,
	    ANTMAN_TARGET_DIST = 16,
	    ANTMAN_LOYALTY_MAXTIME = 2.5*total_day_time,
	    ANTMAN_LOYALTY_PER_HUNGER = total_day_time/25,
	    ANTMAN_MIN_POOP_PERIOD = seg_time * .5,

   	    ANTMAN_RUN_SPEED = 5,
	    ANTMAN_WALK_SPEED = 3,

	    ANTMAN_MIN = 3,
		ANTMAN_MAX = 4,
		ANTMAN_REGEN_TIME = seg_time * 4,
		ANTMAN_RELEASE_TIME = seg_time,

		ANTMAN_ATTACK_ON_SIGHT_DIST = 4,
		ANTMAN_LOYALTY_PER_HUNGER = total_day_time/25,


-------------------------------------------------------------------


		ANTMAN_WARRIOR_DAMAGE = wilson_attack * 1.25,
	    ANTMAN_WARRIOR_HEALTH = 300,
	    ANTMAN_WARRIOR_ATTACK_PERIOD = 3,
	    ANTMAN_WARRIOR_TARGET_DIST = 16,

   	    ANTMAN_WARRIOR_RUN_SPEED = 7,
	    ANTMAN_WARRIOR_WALK_SPEED = 3.5,

		ANTMAN_WARRIOR_REGEN_TIME = seg_time,
		ANTMAN_WARRIOR_RELEASE_TIME = seg_time,

		ANTMAN_WARRIOR_ATTACK_ON_SIGHT_DIST = 8,

--------------------------------------------------------------------

		ANTQUEEN_HEALTH = 3500,
		
		ANCIENT_HERALD_HEALTH = 2000,
		ANCIENT_HERALD_DAMAGE = 50,

		CHICKEN_HEALTH = 100,
		CHICKEN_RESPAWN_TIME = day_time*4,
		CHICKEN_RUN_SPEED = 4,

		PIKO_HEALTH = 100,
		PIKO_RESPAWN_TIME = day_time*4,
		PIKO_RUN_SPEED = 4,
		PIKO_DAMAGE = 2,
	    PIKO_ATTACK_PERIOD = 2,
	    PIKO_TARGET_DIST = 20,
	    PIKO_RABID_SANITY_THRESHOLD = 0.8,

	    RABID_BEETLE_HEALTH = 60,
	    RABID_BEETLE_DAMAGE =  10,
	    RABID_BEETLE_ATTACK_PERIOD = 2,
	    RABID_BEETLE_TARGET_DIST = 20,
	    RABID_BEETLE_SPEED = 12,

        RABID_BEETLE_FOLLOWER_TARGET_DIST = 10,
        RABID_BEETLE_FOLLOWER_TARGET_KEEP = 20,

        DECO_RUINS_BEAM_WORK = 6,

	    PEAGAWK_DAMAGE = 20,
	    PEAGAWK_HEALTH = 50,
	    PEAGAWK_ATTACK_PERIOD = 3,
	    PEAGAWK_RUN_SPEED = 8,
	    PEAGAWK_WALK_SPEED = 3,
	    PEAGAWK_REGROW_TIME =  total_day_time,
		PEAGAWK_PICKTIMER = 180,
		PEAGAWK_PRISM_STOP_TIMER = 45,
		PEAGAWK_TAIL_FEATHERS_MAX = 7,

	    VAMPIREBAT_HEALTH = 130,
	    VAMPIREBAT_DAMAGE = 25,
	    VAMPIREBAT_ATTACK_PERIOD = 1.8,
	    VAMPIREBAT_WALK_SPEED = 10, -- 8?

	    FLYTRAP_CHILD_HEALTH = 250,
	    FLYTRAP_CHILD_DAMAGE = 15,
        FLYTRAP_CHILD_SPEED = 4,   

	    FLYTRAP_TEEN_HEALTH = 300,
	    FLYTRAP_TEEN_DAMAGE = 20,
	    FLYTRAP_TEEN_SPEED = 3.5,

    	FLYTRAP_HEALTH = 350,
	    FLYTRAP_DAMAGE = 25,
        FLYTRAP_SPEED = 3,

    	FLYTRAP_TARGET_DIST = 8,
    	FLYTRAP_KEEP_TARGET_DIST= 15,
	    FLYTRAP_ATTACK_PERIOD = 3,

	    ADULT_FLYTRAP_HEALTH = 400,
	    ADULT_FLYTRAP_DAMAGE = 30,
	    ADULT_FLYTRAP_ATTACK_PERIOD = 5,
	    ADULT_FLYTRAP_ATTACK_DIST = 4,
	   	ADULT_FLYTRAP_STOPATTACK_DIST = 6,

	    LOTUS_REGROW_TIME = total_day_time*5,

	    GLOWFLY_COCOON_HEALTH = 300,	

	    MANDRAKEMAN_DAMAGE = 40,
	    MANDRAKEMAN_HEALTH = 200,
	    MANDRAKEMAN_ATTACK_PERIOD = 2,	   
	    MANDRAKEMAN_RUN_SPEED = 6,
	    MANDRAKEMAN_WALK_SPEED = 3,
		MANDRAKEMAN_PANIC_THRESH = .333,
		MANDRAKEMAN_HEALTH_REGEN_PERIOD = 5,
		MANDRAKEMAN_HEALTH_REGEN_AMOUNT = (200/120)*5,
		MANDRAKEMAN_SEE_MANDRAKE_DIST = 8,
		MANDRAKEMAN_TARGET_DIST = 10,
		MANDRAKEMAN_DEFEND_DIST = 30,

		HOME_RESEARCH_MACHINE_DIST = 30,

		BRAMBLE_THORN_DAMAGE = 3,

        GROGGINESS_DECAY_RATE = .01,
        GROGGINESS_WEAR_OFF_DURATION = 0.5,
        MIN_KNOCKOUT_TIME = 10,
        MIN_GROGGY_SPEED_MOD = .4,
        MAX_GROGGY_SPEED_MOD = .6,

        FOG_GROGGY_SPEED_MOD = .7,

       	HIPPO_DAMAGE = 50,
	    HIPPO_HEALTH = 500,
	    HIPPO_ATTACK_PERIOD = 2,
	    HIPPO_WALK_SPEED = 5,
	    HIPPO_RUN_SPEED = 6,
	    HIPPO_TARGET_DIST = 12,

		PUGALISK_HEALTH = 3000,
	    PUGALISK_ATTACK_PERIOD = 3,
	    PUGALISK_MELEE_RANGE = 6,
	    PUGALISK_DAMAGE = 200,
	   	PUGALISK_TARGET_DIST = 40,
	    PUGALISK_TAIL_TARGET_DIST = 6,

	    PUGALISK_RUINS_PILLAR_WORK = 3,

	    DISARMINGKIT_USES = 10,

	    SPEAR_TRAP_HEALTH = 100,
	    SPEAR_TRAP_DAMNAGE = wilson_attack,

	    CLAWPALMTREE_GROW_TIME =
	    {
	        {base=8*day_time, random=0.5*day_time},   --tall to short
	        {base=12*day_time, random=5*day_time},   --short to normal
	        {base=12*day_time, random=5*day_time},   --normal to tall
	    },	    

        WEEVOLE_WALK_SPEED = 5,
        WEEVOLE_HEALTH = 150,
        WEEVOLE_DAMAGE = 6,
        WEEVOLE_PERIOD_MIN = 4,
        WEEVOLE_PERIOD_MAX = 5,
        WEEVOLE_ATTACK_RANGE = 5,
        WEEVOLE_HIT_RANGE = 1.5,
        WEEVOLE_MELEE_RANGE = 1.5,
        WEEVOLE_RUN_AWAY_DIST = 3,
        WEEVOLE_STOP_RUN_AWAY_DIST = 5,
        WEEVOLE_TARGET_DIST = 6,
        WEEVOLEDEN_MAX_WEEVOLES = 3,        

        ARMOR_WEEVOLE_DURABILITY = wilson_health*6,
        ARMOR_WEEVOLE_ABSORPTION = .6,

	    CANDLEHAT_LIGHTTIME = night_time*2,      

	    ROBOT_TARGET_DIST = 15,  
	    ROBOT_RIBS_DAMAGE = wilson_attack,
	    ROBOT_RIBS_HEALTH = 1000,
	    ROBOT_LEG_DAMAGE = wilson_attack*2,

	    LASER_DAMAGE = 20,

	   	PAN_USES = 30,

		POG_ATTACK_RANGE = 3,
		POG_MELEE_RANGE = 2.5,
		POG_TARGET_DIST = 25,
		POG_WALK_SPEED = 2,
		POG_RUN_SPEED = 4.5,
		POG_DAMAGE = 25,
		POG_HEALTH = 150,
		POG_ATTACK_PERIOD = 2,

	    MIN_POGNAP_INTERVAL = 30,
	    MAX_POGNAP_INTERVAL = 120,
	    MIN_POGNAP_LENGTH = 20,
	    MAX_POGNAP_LENGTH = 40,		

	    POG_LOYALTY_MAXTIME = total_day_time,
	    POG_LOYALTY_PER_ITEM = total_day_time*.1,
	    POG_EAT_DELAY = 0.5,
	    POG_SEE_FOOD = 30,

	    PANGOLDEN_HEALTH = 500,
	    PANGOLDEN_DAMAGE = 34,	 
	    PANGOLDEN_TARGET_DIST = 5,

	   	PANGOLDEN_CHASE_DIST = 30,	  
	   	PANGOLDEN_BALL_DEFENCE = 0.75,  
	--    PANGOLDEN_CHASE_DIST = 30,
	--    PANGOLDEN_FOLLOW_TIME = 30,

		-- INTERIOR ROOM SIZES
		ROOM_TINY_WIDTH   = 15,
		ROOM_TINY_DEPTH   = 10,

		ROOM_SMALL_WIDTH  = 18,
		ROOM_SMALL_DEPTH  = 12,

		ROOM_MEDIUM_WIDTH = 24,
		ROOM_MEDIUM_DEPTH = 16,

		ROOM_LARGE_WIDTH  = 26,
		ROOM_LARGE_DEPTH  = 18,

		ROC_SPEED = 20,
		ROC_SHADOWRANGE = 8,

		ROC_LEGDSIT = 6,

		GNATMOUND_REGEN_TIME = seg_time * 4,
		GNATMOUND_RELEASE_TIME = seg_time,
		GNATMOUND_MAX_WORK	= 6,
		GNATMOUND_MAX_CHILDREN	= 1,
		
		GNAT_WALK_SPEED = 2,
		GNAT_RUN_SPEED = 7,

		ROBIN_HATCH_TIME = total_day_time * 3,

	    ARMORMETAL = wilson_health*8,
		ARMORMETAL_ABSORPTION = .8,
		ARMORMETAL_SLOW = -0.20,

	    ARMOR_KNIGHT = wilson_health*8,
		ARMOR_KNIGHT_ABSORPTION = .8,

		SPRINKLER_MAX_FUEL_TIME = total_day_time,

		BUGREPELLENT_USES = 20,

		MOSQUITO_MAX_SPAWN = 1,
		MOSQUITO_REGEN_TIME = day_time/2,
		FROG_POISON_MAX_SPAWN = 1,
		FROG_POISON_REGEN_TIME = day_time/2,

		PIGHOUSE_CITY_RESPAWNTIME = total_day_time*3,
		GUARDTOWER_CITY_RESPAWNTIME = total_day_time*3,

		NETTLE_REGROW_TIME = total_day_time*3,
		NETTLE_MOISTURE_WET_THRESHOLD = 20,
		NETTLE_MOISTURE_DRY_THRESHOLD = 10,

		BIRDWHISLE_USES = 5,

        SALTLICK_CHECK_DIST = 20,
        SALTLICK_USE_DIST = 4,
        SALTLICK_DURATION = total_day_time / 8,
        SALTLICK_MAX_LICKS = 240, -- 15 days @ 8 beefalo licks per day
        SALTLICK_BEEFALO_USES = 2,
        SALTLICK_KOALEFANT_USES = 4,
        SALTLICK_LIGHTNINGGOAT_USES = 1,
        SALTLICK_DEER_USES = 1,		

        SADDLE_BASIC_BONUS_DAMAGE = 0,
        SADDLE_WAR_BONUS_DAMAGE = 16,
        SADDLE_RACE_BONUS_DAMAGE = 0,

        SADDLE_BASIC_USES = 5,
        SADDLE_WAR_USES = 8,
        SADDLE_RACE_USES = 8,

        SADDLE_BASIC_SPEEDMULT = 1.4,
        SADDLE_WAR_SPEEDMULT = 1.25,
        SADDLE_RACE_SPEEDMULT = 1.55,

        SADDLEHORN_DAMAGE = wilson_attack*.5,
        SADDLEHORN_USES = 10,

        SPAT_HEALTH = 500,
        SPAT_PHLEGM_DAMAGE = 5,
        SPAT_PHLEGM_ATTACKRANGE = 12,
        SPAT_PHLEGM_RADIUS = 4,
        SPAT_MELEE_DAMAGE = 60,
        SPAT_MELEE_ATTACKRANGE = 0.5,
        SPAT_TARGET_DIST = 10,
        SPAT_CHASE_DIST = 30,
        SPAT_FOLLOW_TIME = 30,

        PINNABLE_WEAR_OFF_TIME = 10,
        PINNABLE_ATTACK_WEAR_OFF = 2.0,
        PINNABLE_RECOVERY_LEEWAY = 1.5,   
        FIRECRACKERS_STARTLE_RANGE = 10,   
       	FIRECRACKERS_FUSE = 2,

        ARMORBRAMBLE_DMG = wilson_attack/1.5,     
        ARMORBRAMBLE_ABSORPTION = .65,
        ARMORBRAMBLE = wilson_health*2.5,

	    TRAP_BRAMBLE_USES = 10,
	    TRAP_BRAMBLE_DAMAGE = 40,
	    TRAP_BRAMBLE_RADIUS = 2.5,     	

		GOGGLES_NORMAL_PERISHTIME = 10*total_day_time,
		GOGGLES_HEAT_PERISHTIME = 2*total_day_time,

		GOGGLES_ARMOR_ARMOR = wilson_health*4,	
		GOGGLES_ARMOR_ABSORPTION = 0.85,		

		GOGGLES_SHOOT_USES = 10,

		NEARSIGHTED_BLUR_START_RADIUS = 0.0,
		NEARSIGHTED_BLUR_STRENGTH = 3.0,
	
		GOGGLES_HEAT=
		{
			HOT=
			{
				BLOOM = true,
				DESATURATION = 1.0,
				MULT_COLOUR = {0.0, 1.0, 0.5, 1.0},
				ADD_COLOUR  = {1.0, 0.1, 0.3, 1.0},
			},
			COLD=
			{
				BLOOM = false,
				DESATURATION = 0.7,
				MULT_COLOUR = {0.0, 0.0, 0.3, 1.0},
				ADD_COLOUR  = {0.1, 0.1, 0.5, 1.0},
			},
			GROUND=
			{
				MULT_COLOUR = {0.0, 0.1, 0.3, 1.0},
                	ADD_COLOUR  = {0.1, 0.1, 0.5, 1.0}
			},
			WAVES=
			{
				MULT_COLOUR = {0.0, 0.0, 0.3, 1.0},
				ADD_COLOUR  = {0.1, 0.1, 0.6, 1.0},
			},
			BLUR=
			{
				ENABLED = true,
				START_RADIUS = -5.0,
				STRENGTH = 0.16,
			},
	 	},

	 	TELEBRELLA_USES = 10,
	 	NEARSIGHTED_ACTION_RANGE = 4,

	 	ANCIENT_HULK_DAMAGE = 200,
	 	ANCIENT_HULK_MINE_DAMAGE = 100,
	 	ANCIENT_HULK_MELEE_RANGE = 5.5,
		ANCIENT_HULK_ATTACK_RANGE = 5.5,

		IRON_LORD_DAMAGE = wilson_attack*2,
		IRON_LORD_TIME = 3*60,

		INFUSED_IRON_PERISHTIME = total_day_time*2,
	}
end

Tune()
