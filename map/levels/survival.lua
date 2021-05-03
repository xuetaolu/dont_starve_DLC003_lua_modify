require("map/level")

----------------------------------
-- Survival levels
----------------------------------
local rog_installed = false
local level_type = nil

if rawget(_G, "GEN_PARAMETERS") ~= nil then
	local params = json.decode(GEN_PARAMETERS)
	rog_installed = params.ROGEnabled
	level_type = params.level_type
end

if IsDLCEnabled(REIGN_OF_GIANTS) or rog_installed or level_type == "shipwrecked" or level_type == "volcano" then
	require ("map/levels/survival_sw")
else
	require ("map/levels/survival_standard")
end