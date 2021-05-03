
local MakePlayerCharacter = require "prefabs/player_common"


local assets = 
{
	Asset("ANIM", "anim/watricia.zip"),
	Asset("SOUND", "sound/woodie.fsb")    
}

local prefabs = 
{
	"mailpack",
	"rawling"
}

local start_inv = 
{
	"mailpack",
	"rawling"
}

local fn = function(inst)
	inst.soundsname = "woodie"

	inst.components.inventory:GuaranteeItems(start_inv)

end


return MakePlayerCharacter("watricia", prefabs, assets, fn, start_inv)
