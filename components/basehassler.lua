BaseHassler_SW = require "components/basehassler_sw"
BaseHassler_BaseGame = require "components/basehassler_basegame"

if SaveGameIndex:IsModeShipwrecked() or IsDLCInstalled(REIGN_OF_GIANTS) then
	return BaseHassler_SW
else
	return BaseHassler_BaseGame
end