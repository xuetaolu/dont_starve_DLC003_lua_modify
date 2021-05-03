local Mixer_BaseGame = require "components/ambientsoundmixer_basegame"
local Mixer_RoG = require "components/ambientsoundmixer_rog"
local Mixer_SW = require "components/ambientsoundmixer_sw"
local Mixer_PORK = require "components/ambientsoundmixer_pork"

if SaveGameIndex:IsModePorkland() then
	return Mixer_PORK
elseif SaveGameIndex:IsModeShipwrecked() then
	return Mixer_SW
elseif IsDLCInstalled(REIGN_OF_GIANTS) then
	return Mixer_RoG
else
	return Mixer_BaseGame
end