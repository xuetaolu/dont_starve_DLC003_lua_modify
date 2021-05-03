local Manager_RoG = require "components/seasonmanager_rog"
local Manager_SW = require "components/seasonmanager_sw"
local Manager_PORK = require "components/seasonmanager_pork"
if SaveGameIndex:IsModePorkland() then
	return Manager_PORK
elseif SaveGameIndex:IsModeShipwrecked() then
	return Manager_SW
else
	return Manager_RoG
end
