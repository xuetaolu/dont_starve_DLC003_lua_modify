PI = 3.14159
DEGREES = PI/180
RADIANS = 180/PI
FRAMES = 1/30
TILE_SCALE = 4

RESOLUTION_X = 1280
RESOLUTION_Y = 720

MAX_FE_SCALE = 3 --Default if you don't call SetMaxPropUpscale

FACING_RIGHT = 0
FACING_UP = 1
FACING_LEFT = 2
FACING_DOWN = 3

-- Careful inserting into here. You will have to update game\render\RenderLayer.h
LAYER_BACKGROUND = 1
LAYER_WORLD_BACKGROUND = 2
LAYER_WORLD = 3
LAYER_WORLD_CEILING = 4
LAYER_FRONTEND = 6

ANCHOR_MIDDLE = 0
ANCHOR_LEFT = 1
ANCHOR_RIGHT = 2
ANCHOR_TOP = 1
ANCHOR_BOTTOM = 2

SCALEMODE_NONE = 0
SCALEMODE_FILLSCREEN = 1
SCALEMODE_PROPORTIONAL = 2
SCALEMODE_FIXEDPROPORTIONAL = 3
SCALEMODE_FIXEDSCREEN_NONDYNAMIC = 4

PHYSICS_TYPE_ANIMATION_CONTROLLED = 0
PHYSICS_TYPE_PHYSICS_CONTROLLED = 1

ALT_RENDERPATH = 1	-- You should really not use this unless you know what it is and how it works. Otherwise it can crash things, consume lots of memory, reduce performance, you name it.

MOVE_UP = 1
MOVE_DOWN = 2
MOVE_LEFT = 3
MOVE_RIGHT = 4


--push priorities
STATIC_PRIORITY = 10000

-- Controls: 
-- Must match the Control enum in DontStarveInputHandler.h
-- Must match STRINGS.UI.CONTROLSSCREEN.CONTROLS

-- player action controls
CONTROL_PRIMARY = 0
CONTROL_SECONDARY = 1
CONTROL_ATTACK = 2
CONTROL_INSPECT = 3
CONTROL_ACTION = 4

-- player movement controls
CONTROL_MOVE_UP = 5
CONTROL_MOVE_DOWN = 6
CONTROL_MOVE_LEFT = 7
CONTROL_MOVE_RIGHT = 8

-- view controls
CONTROL_ZOOM_IN = 9
CONTROL_ZOOM_OUT = 10
CONTROL_ROTATE_LEFT = 11
CONTROL_ROTATE_RIGHT = 12


-- player movement controls
CONTROL_PAUSE = 13
CONTROL_MAP = 14
CONTROL_INV_1 = 15
CONTROL_INV_2 = 16
CONTROL_INV_3 = 17
CONTROL_INV_4 = 18
CONTROL_INV_5 = 19
CONTROL_INV_6 = 20
CONTROL_INV_7 = 21
CONTROL_INV_8 = 22
CONTROL_INV_9 = 23
CONTROL_INV_10 = 24

CONTROL_FOCUS_UP = 25
CONTROL_FOCUS_DOWN = 26
CONTROL_FOCUS_LEFT = 27
CONTROL_FOCUS_RIGHT = 28

CONTROL_ACCEPT = 29
CONTROL_CANCEL = 30
CONTROL_PAGELEFT = 31
CONTROL_PAGERIGHT = 32

CONTROL_PREVVALUE = 33
CONTROL_NEXTVALUE = 34

CONTROL_SPLITSTACK = 35
CONTROL_TRADEITEM = 36
CONTROL_TRADESTACK = 37
CONTROL_FORCE_INSPECT = 38
CONTROL_FORCE_ATTACK = 39
CONTROL_FORCE_TRADE = 40
CONTROL_FORCE_STACK = 41

CONTROL_OPEN_DEBUG_CONSOLE = 42
CONTROL_TOGGLE_LOG = 43
CONTROL_TOGGLE_DEBUGRENDER = 44

CONTROL_OPEN_INVENTORY = 45
CONTROL_OPEN_CRAFTING = 46
CONTROL_INVENTORY_LEFT = 47
CONTROL_INVENTORY_RIGHT = 48
CONTROL_INVENTORY_UP = 49
CONTROL_INVENTORY_DOWN = 50
CONTROL_INVENTORY_EXAMINE = 51
CONTROL_INVENTORY_USEONSELF = 52
CONTROL_INVENTORY_USEONSCENE = 53
CONTROL_INVENTORY_DROP = 54
CONTROL_PUTSTACK = 55
CONTROL_CONTROLLER_ATTACK = 56
CONTROL_CONTROLLER_ACTION = 57
CONTROL_CONTROLLER_ALTACTION = 58
CONTROL_USE_ITEM_ON_ITEM = 59

CONTROL_MAP_ZOOM_IN = 60
CONTROL_MAP_ZOOM_OUT = 61

CONTROL_OPEN_DEBUG_MENU = 62

CONTROL_TOGGLE_BROADCASTING = 63

CONTROL_SCROLLBACK = 64
CONTROL_SCROLLFWD = 65

CONTROL_CUSTOM_START = 100



KEY_TAB = 9
KEY_KP_PERIOD		= 266
KEY_KP_DIVIDE		= 267
KEY_KP_MULTIPLY		= 268
KEY_KP_MINUS		= 269
KEY_KP_PLUS			= 270
KEY_KP_ENTER		= 271
KEY_KP_EQUALS		= 272
KEY_MINUS = 45
KEY_EQUALS = 61
KEY_SPACE = 32
KEY_ENTER = 13
KEY_ESCAPE = 27
KEY_HOME = 278
KEY_INSERT = 277
KEY_DELETE = 127
KEY_END    = 279
KEY_PAUSE = 19
KEY_PRINT = 316
KEY_CAPSLOCK = 301
KEY_SCROLLOCK = 302
KEY_RSHIFT = 303 -- use KEY_SHIFT instead
KEY_LSHIFT = 304 -- use KEY_SHIFT instead
KEY_RCTRL = 305 -- use KEY_CTRL instead
KEY_LCTRL = 306 -- use KEY_CTRL instead
KEY_RALT = 307 -- use KEY_ALT instead
KEY_LALT = 308 -- use KEY_ALT instead
KEY_ALT = 400
KEY_CTRL = 401
KEY_SHIFT = 402
KEY_BACKSPACE = 8
KEY_PERIOD = 46
KEY_SLASH = 47
KEY_LEFTBRACKET	= 91
KEY_BACKSLASH	= 92
KEY_RIGHTBRACKET= 93
KEY_TILDE = 96
KEY_A = 97
KEY_B = 98
KEY_C = 99
KEY_D = 100
KEY_E = 101
KEY_F = 102
KEY_G = 103
KEY_H = 104
KEY_I = 105
KEY_J = 106
KEY_K = 107
KEY_L = 108
KEY_M = 109
KEY_N = 110
KEY_O = 111
KEY_P = 112
KEY_Q = 113
KEY_R = 114
KEY_S = 115
KEY_T = 116
KEY_U = 117
KEY_V = 118
KEY_W = 119
KEY_X = 120
KEY_Y = 121
KEY_Z = 122
KEY_F1 = 282
KEY_F2 = 283
KEY_F3 = 284
KEY_F4 = 285
KEY_F5 = 286
KEY_F6 = 287
KEY_F7 = 288
KEY_F8 = 289
KEY_F9 = 290
KEY_F10 = 291
KEY_F11 = 292
KEY_F12 = 293

KEY_UP			= 273
KEY_DOWN		= 274
KEY_RIGHT		= 275
KEY_LEFT		= 276
KEY_PAGEUP		= 280
KEY_PAGEDOWN	= 281

KEY_0 = 48
KEY_1 = 49
KEY_2 = 50
KEY_3 = 51
KEY_4 = 52
KEY_5 = 53
KEY_6 = 54
KEY_7 = 55
KEY_8 = 56
KEY_9 = 57

-- DO NOT use these for gameplay!
MOUSEBUTTON_LEFT = 1000
MOUSEBUTTON_RIGHT = 1001
MOUSEBUTTON_MIDDLE = 1002
MOUSEBUTTON_SCROLLUP = 1003
MOUSEBUTTON_SCROLLDOWN = 1004


GESTURE_ZOOM_IN = 900
GESTURE_ZOOM_OUT = 901
GESTURE_ROTATE_LEFT = 902
GESTURE_ROTATE_RIGHT = 903
GESTURE_MAX = 904

SCREEN_FLASH_SCALING =
{
	0.9, -- default
	0.6, -- dim
	0.3, -- dimmest
}

BACKEND_PREFABS = {"hud", "forest", "cave", "shipwrecked", "porkland", "volcanolevel", "maxwell", "fire", "character_fire", "shatter"}
FRONTEND_PREFABS = {"frontend"}
RECIPE_PREFABS = {}

MAIN_CHARACTERLIST = 
{
	'wilson', 'willow', 'wolfgang', 'wendy', 'wx78', 'wickerbottom', 'woodie', 'wes', 'waxwell', 'wagstaff',
}

ROG_CHARACTERLIST =
{
	'wathgrithr', 'webber',
}

SHIPWRECKED_CHARACTERLIST = 
{
	"walani",
	"warly",
	"wilbur",
	"woodlegs",
}

-- REMEMBER THE CONSTANT FILES IN THE OTHER DLCs TOO!!
PORKLAND_CHARACTERLIST = 
{
	"warbucks",
	"wilba",
	"wormwood",
	"wheeler",
}

RETIRED_CHARACTERLIST =
{
	"warbucks",
}

RECIPE_GAME_TYPE =
{
	SHIPWRECKED = "shipwrecked",
	ROG = "rog",
	COMMON = "common",
	VANILLA = "vanilla",
	PORKLAND = "porkland",
}

SW_ICONS = 
{
	["dug_grass"] = "dug_grass_green",
	["cutgrass"] = "cutgrass_green",
	["log"] = "log_tropical",
	["butterfly"] = "butterfly_tropical",
	["butterflywings"] = "butterflywings_tropical",
	["cave_banana"] = "bananas",
	["cave_banana_cooked"] = "bananas_cooked",
}

PORK_ICONS = 
{
	["log"] = "log_rainforest",
	["snakeskin"] = "snakeskin_scaly",
	["snake"] = "snake_scaly",
	["snakeskinsail"] = "snakeskinsail_scaly",
	["armor_snakeskin"] = "armor_snakeskin_scaly",
	["snakeskinhat"] = "snakeskinhat_scaly",
	["fish"] = "coi",
	["fish_cooked"] = "coi_cooked",
}

MODCHARACTERLIST = 
{
	-- this gets populated by mods
}

CHARACTER_GENDERS = 
{
	FEMALE = {
		"willow",
		"wendy",
		"wickerbottom",
		"wathgrithr",
		"walani",
		"wheeler",
	},
	MALE = {
		"wilson",
		"woodie",
		"waxwell",
		"wolfgang",
		"wes",
		"woodlegs",
		"warly",
	},
	ROBOT = {
		"wx78",
		"webber",
		"wilbur",
		"wormwood",
	},
}

EQUIPSLOTS=
{
    HANDS = "hands",
    HEAD = "head",
    BODY = "body",
}

BOATEQUIPSLOTS=
{
    BOAT_SAIL = "sail", 
    BOAT_LAMP = "lamp", 
}

ITEMTAG=
{
    FOOD = "food",
    MEAT = "meat",
    WEAPON = "weapon",
    TOOL = "tool",
    TREASURE = "treasure",
    FUEL = "fuel",
    FIRE = "fire",
    STACKABLE = "stackable",
    FX = "FX",
}

-- See map_painter.h
GROUND =
{
	INVALID = 255,
    IMPASSABLE = 1,
    
    ROAD = 2,
    ROCKY = 3,
    DIRT = 4,
	SAVANNA = 5,
	GRASS = 6,
	FOREST = 7,
	MARSH = 8,
	WEB = 9,
	WOODFLOOR = 10,
	CARPET = 11,
	CHECKER = 12,

	-- CAVES
	CAVE = 13,
	FUNGUS = 14,
	SINKHOLE = 15,
    UNDERROCK = 16,
    MUD = 17,
    BRICK = 18,
    BRICK_GLOW = 19,
    TILES = 20,
    TILES_GLOW = 21,
    TRIM = 22,
    TRIM_GLOW = 23,
	FUNGUSRED = 24,
	FUNGUSGREEN = 25,

	DEEPRAINFOREST = 26,  			--porkland
	FOUNDATION = 27, 				--porkland
	COBBLEROAD = 28, 				--porkland
	LAWN = 29, 						--porkland

	DECIDUOUS = 30,
	DESERT_DIRT = 31,

	GASJUNGLE = 32,					--porkland
	RAINFOREST = 33, 				--porkland
	INTERIOR = 34, 				    --porkland

	SNAKESKIN = 35, 

	FIELDS = 36, 				    --porkland
	SUBURB = 37, 				    --porkland
	PIGRUINS = 38, 					--porkland
	PIGRUINS_NOCANOPY = 39, 		--porkland
	BATTLEGROUND = 40, 				--porkland
	PLAINS = 41,					--porkland
	PAINTED = 42,					--porkland				

	-- SHIPWRECKED
	VOLCANO_ROCK = 43,
	MEADOW = 44,
	BEACH = 45,
	JUNGLE = 46,
	SWAMP = 47,
	FLOOD = 48,
	VOLCANO = 49,
	VOLCANO_LAVA = 50,
	ASH = 51,
	
	MANGROVE = 52,
	MAGMAFIELD = 53,
	TIDALMARSH = 54,
	OCEAN_SHALLOW = 55,
	OCEAN_MEDIUM = 56,
	OCEAN_DEEP = 57,
	OCEAN_SHORE = 58,
	OCEAN_CORAL = 59,
	OCEAN_CORAL_SHORE = 60,
	MANGROVE_SHORE = 61,
	OCEAN_SHIPGRAVEYARD = 62,
	OCEAN_SHIPGRAVEYARD_SHORE = 63,
	LILYPOND = 64,							--porkland

	BEARDRUG = 65,							--porkland
	DEEPRAINFOREST_NOCANOPY = 66,			--porkland

	--The water tiles in SW need to be higher values than the land tiles 
    --Don't add land tile types greater than 55

    -- Noise
	BATTLEGROUND_PLAINS_NOISE = 119, 		--PORKLAND
	BATTLEGROUND_RAINFOREST_NOISE = 120, 	--PORKLAND

    JUNGLE_NOISE = 121,
    VOLCANO_NOISE = 122,
    DIRT_NOISE = 123,
	ABYSS_NOISE = 124,
	GROUND_NOISE = 125,
	CAVE_NOISE = 126,
	FUNGUS_NOISE = 127,

	UNDERGROUND = 128,


	
	WALL_ROCKY = 151,
	WALL_DIRT = 152,
	WALL_MARSH = 153,
	WALL_CAVE = 154,
	WALL_FUNGUS = 155,
	WALL_SINKHOLE = 156,
	WALL_MUD = 157,
	WALL_TOP = 158,
	WALL_WOOD = 159,
	WALL_HUNESTONE = 160,
	WALL_HUNESTONE_GLOW = 161,
	WALL_STONEEYE = 162,
	WALL_STONEEYE_GLOW = 163,
}

IS_CANOPY_TILE = 
{
	GROUND.GASJUNGLE,
	GROUND.DEEPRAINFOREST,
	GROUND.PIGRUINS,
}

TECH = {
	NONE = { SCIENCE = 0, MAGIC = 0, ANCIENT = 0, OBSIDIAN = 0, LOST = 0},
	SCIENCE_ONE = {SCIENCE = 1},
	SCIENCE_TWO = {SCIENCE = 2},
	SCIENCE_THREE = {SCIENCE = 3},
	-- Magic starts at level 2 so it's not teased from the start.
	MAGIC_TWO = {MAGIC = 2},
	MAGIC_THREE = {MAGIC = 3},
	ANCIENT_TWO = {ANCIENT = 2},
	ANCIENT_THREE = {ANCIENT = 3},
	ANCIENT_FOUR = {ANCIENT = 4},
	OBSIDIAN_TWO = {OBSIDIAN = 2},
	HOME_TWO = {HOME = 2},	
	CITY = {CITY = 2},	

	LOST = {LOST = 10},
}

CHARACTER_INGREDIENT =
{
    --NOTE: Value is used as key for NAME string and inventory image
    HEALTH = "decrease_health",
    MAX_HEALTH = "half_health",
    SANITY = "decrease_sanity",
    MAX_SANITY = "half_sanity",
}

--Character ingredient amounts must be multiples of 5
CHARACTER_INGREDIENT_SEG = 5

-- See cell_data.h
NODE_TYPE =
{
	Default = 0, 
	Blank = 1, 
	Background = 2, 
	Random = 3, 
	Blocker = 4, 
	Room = 5,
}

-- See cell_data.h
NODE_INTERNAL_CONNECTION_TYPE =
{
	EdgeCentroid = 0, 
	EdgeSite = 1, 
	EdgeEdgeDirect = 2, 
	EdgeEdgeLeft = 3, 
	EdgeEdgeRight = 4, 
	EdgeData = 5,
}

CA_SEED_MODE =
{
	SEED_RANDOM = 0,
	SEED_CENTROID = 1,
	SEED_SITE = 2,
	SEED_WALLS = 3
}

-- See maze.h
MAZE_TYPE =
{
	MAZE_DFS_4WAY_META = 0,
	MAZE_DFS_4WAY = 1,
	MAZE_DFS_8WAY = 2,
	MAZE_GROWINGTREE_4WAY = 3,
	MAZE_GROWINGTREE_8WAY = 4,
	MAZE_GROWINGTREE_4WAY_INV = 5,
}

-- NORTH	1
-- EAST		2
-- SOUTH	4
-- WEST		8
--[[
Meta maze def:
5 room types:
4 way,	3 way,	2 way,	1 way,	L shape
	1,		4,		2,		4,		4
	15 tiles needed
--]]

MAZE_CELL_EXITS =
{
	NO_EXITS = 		0, -- Dont place a cell here.
	SINGLE_NORTH = 	1,
	SINGLE_EAST = 	2,
	L_NORTH = 		3,
	SINGLE_SOUTH = 	4,
	TUNNEL_NS = 	5,
	L_EAST = 		6,
	THREE_WAY_N = 	7,
	SINGLE_WEST = 	8,
	L_WEST = 		9,
	TUNNEL_EW =		10,
	THREE_WAY_W = 	11,
	L_SOUTH = 		12,
	THREE_WAY_S = 	13,
	THREE_WAY_E = 	14,
	FOUR_WAY = 		15,
}

MAZE_CELL_EXITS_INV =
{
	"SINGLE_NORTH",
	"SINGLE_EAST",
	"L_NORTH",
	"SINGLE_SOUTH",
	"TUNNEL_NS",
	"L_EAST",
	"THREE_WAY_N",
	"SINGLE_WEST",
	"L_WEST",
	"TUNNEL_EW",
	"THREE_WAY_W",
	"L_SOUTH" ,
	"THREE_WAY_S",
	"THREE_WAY_E",
	"FOUR_WAY",
}

LAYOUT =
{
	STATIC = 0,
	CIRCLE_EDGE = 1,
	CIRCLE_RANDOM = 2,
	GRID = 3,
	RECTANGLE_EDGE = 4,
	CIRCLE_FILLED = 5,
}

LAYOUT_POSITION =
{
	RANDOM = 0,
	CENTER = 1,
}

LAYOUT_ROTATION =
{
	NORTH = 0, 	-- 0 Degrees
	EAST = 1, 	-- 90 Degrees
	SOUTH = 2, 	-- 180 Degrees
	WEST = 3, 	-- 270 Degrees
}

PLACE_MASK = 
{
	NORMAL = 0,
	IGNORE_IMPASSABLE = 1,
	IGNORE_BARREN = 2,
	IGNORE_IMPASSABLE_BARREN = 3,
	IGNORE_RESERVED = 4,
	IGNORE_IMPASSABLE_RESERVED = 5,
	IGNORE_BARREN_RESERVED = 6,
	IGNORE_IMPASSABLE_BARREN_RESERVED = 7,
	IGNORE_WATER = 8,
	IGNORE_IMPASSABLE_WATER = 9,
	IGNORE_BARREN_WATER = 10,
	IGNORE_IMPASSABLE_BARREN_WATER = 11,
	IGNORE_RESERVED_WATER = 12,
	IGNORE_IMPASSABLE_RESERVED_WATER = 13,
	IGNORE_BARREN_RESERVED_WATER = 14,
	IGNORE_IMPASSABLE_BARREN_RESERVED_WATER = 15,
}

COLLISION =
{
	INTWALL = 32,
    GROUND = 64, -- See BpWorld.cpp (ocean walls)
    LIMITS_01 = 128,
    WORLD_01 = 192, -- outer limits and ground
    ITEMS = 256,
    OBSTACLES = 512,
    CHARACTERS = 1024,
    FLYERS = 2048,
    SANITY = 4096,
    WAVES = 8192,
    LIMITS_02 = 16384,
    WORLD_02 = 16448 -- pond limits and ground
}

COLLISION_TYPE =
{
	NORMAL = 0, -- Original Don't Starve collision
	WATER = 1, -- Shipwrecked collision with water and land
	NONE = 2, -- No collision
	VOLCANO = 3, -- Volcano collision impassible and lava
	POND = 4, -- Pond collision and impassible
}

BLENDMODE =
{
	Disabled = 0,
	AlphaBlended = 1,
	Additive = 2,
	Premultiplied = 3,
	InverseAlpha = 4,
	Subtractive = 6,
	Modulate = 7,
}

LIGHTTYPE = 
{
	Additive = 0,
	Subtractive = 1,
	Modulate = 2,
}
DEFAULT_LIGHT_LAYER = 10

ANIM_ORIENTATION =
{
	Default = 0,
	OnGround = 1,
	RotatingBillboard = 2,
}


RECIPETABS =
{
    TOOLS              = { str = "TOOLS",         		sort =  0, icon = "tab_tool.tex"                 },
    LIGHT              = { str = "LIGHT",         		sort =  1, icon = "tab_light.tex"                },
    ARCHAEOLOGY        = { str = "ARCHAEOLOGY",   		sort =  2, icon = "tab_archaeology.tex"          },
    SURVIVAL           = { str = "SURVIVAL",      		sort =  3, icon = "tab_trap.tex"                 },   
    NAUTICAL           = { str = "NAUTICAL",      		sort =  4, icon = "tab_nautical.tex"             },
    FARM               = { str = "FARM",          		sort =  5, icon = "tab_farm.tex"                 },
    SCIENCE            = { str = "SCIENCE",       		sort =  6, icon = "tab_science.tex"              },
    WAR                = { str = "WAR",           		sort =  7, icon = "tab_fight.tex"                },
    TOWN               = { str = "TOWN",          		sort =  8, icon = "tab_build.tex"                },
    REFINE             = { str = "REFINE",        		sort =  9, icon = "tab_refine.tex"               },
    MAGIC              = { str = "MAGIC",         		sort =  10, icon = "tab_arcane.tex"              },
    DRESS              = { str = "DRESS",         		sort =  11, icon = "tab_dress.tex"               },
    
	-- tabs can also go in the multitab CRAFTINGSTATIONS. All are on index 12, priority determines their sorting order in the multitab (0 first)
    CRAFTINGSTATIONS   = { str = "CRAFTINGSTATIONS",	sort = 12, 				 icon = "tab_crafting.tex",             crafting_station = true  },
    HOME               = { str = "HOME",          		sort = 12, priority = 0, icon = "tab_home_decor.tex",        crafting_station = true  },
    CITY               = { str = "CITY",          		sort = 12, priority = 1, icon = "tab_city.tex",              crafting_station = true  },
    ANCIENT            = { str = "ANCIENT",       		sort = 12, priority = 2, icon = "tab_crafting_table.tex",    crafting_station = true  },
    OBSIDIAN           = { str = "OBSIDIAN",      		sort = 12, priority = 3, icon = "tab_obsidian.tex",          crafting_station = true  },
}

RENO_RECIPETABS =
{
	DOORS 		  = { str = "DOORS",       	 sort = 13, icon = "reno_doors_plate.tex",      isReno = true },
    HOME_KITS     = { str = "HOME KITS",     sort = 14, icon = "reno_tab_homekits.tex",     isReno = true },
    CHAIRS        = { str = "CHAIRS",        sort = 15, icon = "reno_tab_chairs.tex",       isReno = true },
    SHELVES       = { str = "SHELVES",       sort = 16, icon = "reno_tab_shelves.tex",      isReno = true },
    RUGS          = { str = "RUGS",          sort = 17, icon = "reno_tab_rugs.tex",         isReno = true },
    LAMPS         = { str = "LAMPS",         sort = 18, icon = "reno_tab_lamps.tex",        isReno = true },
    PLANT_HOLDERS = { str = "PLANT HOLDERS", sort = 19, icon = "reno_tab_plantholders.tex", isReno = true },
    TABLES        = { str = "TABLES",        sort = 20, icon = "reno_tab_tables.tex",       isReno = true },
    ORNAMENTS     = { str = "ORNAMENTS",     sort = 21, icon = "reno_tab_ornaments.tex",    isReno = true },
    WINDOWS       = { str = "WINDOWS",       sort = 22, icon = "reno_tab_windows.tex",      isReno = true },
    COLUMNS       = { str = "COLUMNS",       sort = 23, icon = "reno_tab_columns.tex",      isReno = true },
    FLOORING      = { str = "FLOORING",      sort = 24, icon = "reno_tab_floors.tex",       isReno = true },
    WALLPAPER     = { str = "WALL PAPER",    sort = 25, icon = "reno_tab_wallpaper.tex",    isReno = true },
    HANGING_LAMPS = { str = "HANGING LAMPS", sort = 26, icon = "reno_tab_hanginglamps.tex", isReno = true }
}

VERBOSITY =
{
	ERROR = 0,
	WARNING = 1,
	INFO = 2,
	DEBUG = 3,
}

RENDERPASS =
{
	Z = 0,
	BLOOM = 1,
	DEFAULT = 2,
}

NUM_TRINKETS = 23

NUM_RELICS = 5

SEASONS =
{
	AUTUMN = "autumn",
	WINTER = "winter",
	SPRING = "spring",
	SUMMER = "summer",
	CAVES = "caves",
	--shipwrecked
	MILD = "mild",
	WET = "wet", --hurricane
	GREEN = "green",
	DRY = "dry",

	TEMPERATE = "temperate",
	HUMID = "humid",
	LUSH = "lush",
	APORKALYPSE = "aporkalypse",
}

BATS = 
{
	EMPTY = "empty",
	CAVE = "cave",
	ATTACK = "attack",
	CAVE_NUM = 6,
}

RUINS =
{
	SMALL = 4,
}

RENDER_QUALITY = 
{
	LOW = 0,
	DEFAULT = 1,
	HIGH = 2,
}

CREATURE_SIZE =
{
	SMALL = 0,
	MEDIUM = 1,
	LARGE = 2,
}

ROAD_PARAMETERS =
{
	NUM_SUBDIVISIONS_PER_SEGMENT = 50,
	MIN_WIDTH = 2,
	MAX_WIDTH = 3,
	MIN_EDGE_WIDTH = 0.5,
	MAX_EDGE_WIDTH = 1,
	WIDTH_JITTER_SCALE=1,
}

BGCOLOURS =
{
	RED = {255/255, 89/255, 46/255},
	PURPLE = {184/255, 87/255, 198/255},
	YELLOW = {255/255, 196/255, 45/255},
	TEAL = {80/255,193/255,204/255},
	--MUSTARD = {229/255,191/255,65/255},	pea soup?
	--MUSTARD = {193/255,151/255,165/255},	grey/purple
	--MUSTARD = {196/255,235/255,179/255},	  
	--MUSTARD = {177/255,236/255,151/255},	  -- pisatchio
	--MUSTARD = {206/255,162/255,182/255},	  
	--MUSTARD = {160/255,84/255,117/255},	  
	--MUSTARD = {234/255,187/255,205/255},	  --grey purple new
	--MUSTARD = {255/255,192/255,0/255},	  -- new mustard
	--MUSTARD = {255/255,223/255,147/255},	 -- yellow/gray
	MUSTARD = {255/255,127/255,159/255},
	GREEN = {87/255,164/255,86/255},	 -- THIS ONE
}

WET_TEXT_COLOUR = {149/255, 191/255, 242/255, 1}
NORMAL_TEXT_COLOUR = {1, 1, 1, 1}

ROAD_STRIPS = 
{
	CORNERS = 0,
	ENDS = 1,
	EDGES = 2,
	CENTER = 3,
}

WRAP_MODE = 
{
	WRAP = 0,
	CLAMP = 1,
	MIRROR = 2,
	CLAMP_TO_EDGE = 3,
}

RESET_ACTION =
{
	LOAD_FRONTEND = 0,
	LOAD_SLOT = 1,
	DO_DEMO = 2,
}

HUD_ATLAS = "images/hud.xml"
UI_ATLAS = "images/ui.xml"

SNOW_THRESH = .015

VIBRATION_CAMERA_SHAKE = 0
VIBRATION_BLOOD_FLASH = 1
VIBRATION_BLOOD_OVER = 2

NUM_SAVE_SLOTS = 5

SAVELOAD = 
{    
    OPERATION = 
    {
        PREPARE = 0,
        LOAD = 1,
        SAVE = 2,
        DELETE = 3,
        NONE = 4,
    },
    
    STATUS = 
    {
        OK = 0,
        DAMAGED = 1,
        NOT_FOUND = 2,
        NO_SPACE = 3,
        FAILED = 4,
    },
}

EXIT_DESTINATION =
{
	WATER = 1,
	LAND = 2
}

DONT_STARVE_TOGETHER_APPID = 322330
DONT_STARVE_APPID = 219740

SCREEN_FADE_TIME = .2
SWIPE_FADE_TIME = .4

FADE_OUT = false
FADE_IN = true

FOG_STATE = {
	SETTING = 1,
	FOGGY = 2,
	LIFTING = 3,
	CLEAR = 4,
}

-- Domestication tendencies
TENDENCY =
{
    DEFAULT = "DEFAULT",
    ORNERY = "ORNERY",
    RIDER = "RIDER",
    PUDGY = "PUDGY",
}

DEPLOYSPACING =
{
    DEFAULT = 0,
    MEDIUM = 1,
    LESS = 2,
    NONE = 3,
	PLACER_DEFAULT = 4,
}

-- Mirrors enum in SystemService.h
LANGUAGE = 
{
    ENGLISH = 0,
    ENGLISH_UK = 1,
    FRENCH = 2,
    FRENCH_CA = 3,
    SPANISH = 4,
    SPANISH_LA = 5,
    GERMAN = 6,
    ITALIAN = 7,
    PORTUGUESE = 8,
    PORTUGUESE_BR = 9,
    DUTCH = 10,
    FINNISH = 11,
    SWEDISH = 12,
    DANISH = 13,
    NORWEGIAN = 14,
    POLISH = 15,
    RUSSIAN = 16,
    TURKISH = 17,
    ARABIC = 18,
    KOREAN = 19,
    JAPANESE = 20,
    CHINESE_T = 21,
    CHINESE_S = 22,
    CHINESE_S_RAIL = 23,
}

LANGUAGE_STEAMCODE_TO_ID =
{
    brazilian = LANGUAGE.PORTUGUESE_BR,
    bulgarian = nil,
    czech = nil,
    danish = LANGUAGE.DANISH,
    dutch = LANGUAGE.DUTCH,
    english = LANGUAGE.ENGLISH,
    finnish = LANGUAGE.FINNISH,
    french = LANGUAGE.FRENCH,
    german = LANGUAGE.GERMAN,
    greek = nil,
    hungarian = nil,
    italian = LANGUAGE.ITALIAN,
    japanese = LANGUAGE.JAPANESE,
    korean = LANGUAGE.KOREAN,
    norwegian = LANGUAGE.NORWEGIAN,
    polish = LANGUAGE.POLISH,
    portuguese = LANGUAGE.PORTUGUESE,
    romanian = nil,
    russian = LANGUAGE.RUSSIAN,
    schinese = LANGUAGE.CHINESE_S,
    spanish = LANGUAGE.SPANISH,
    swedish = LANGUAGE.SWEDISH,
    tchinese = LANGUAGE.CHINESE_T,
    thai = nil,
    turkish = LANGUAGE.TURKISH,
    ukrainian = nil,
}
