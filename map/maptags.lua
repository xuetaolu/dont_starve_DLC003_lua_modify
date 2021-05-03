
local function MakeTags()
	local map_data =
		{
			["Chester_Eyebone"] = true,
			["Packim_Fishbone"] = true,
		}
		
	local map_tags = 
		{
			-- porkland tags
			["interior_potential"] = function(tagdata)
								return "GLOBALTAG", "interior_potential"
							end,			
			["City2"] = function(tagdata)
								return "GLOBALTAG", "City2"
							end,							
			["City1"] = function(tagdata)
								return "GLOBALTAG", "City1"
							end,			
			["Suburb"] = function(tagdata)
								return "GLOBALTAG", "Suburb"
							end,	
			["City_Foundation"] = function(tagdata)
								return "GLOBALTAG", "City_Foundation"
							end,
			["Cultivated"] = function(tagdata)
								return "GLOBALTAG", "Cultivated"
							end,							
			["Bramble"] = function(tagdata)
								return "GLOBALTAG", "Bramble"
							end,
			["Canopy"] = function(tagdata)
								return "TAG", "Canopy"								
							end,
			["Maze"] = function(tagdata)
								return "GLOBALTAG", "Maze"
							end,
			["MazeEntrance"] = function(tagdata)
								return "GLOBALTAG", "MazeEntrance"
							end,
			["Labyrinth"] = function(tagdata)
								return "GLOBALTAG", "Labyrinth"
							end,
			["LabyrinthEntrance"] = function(tagdata)
								return "GLOBALTAG", "LabyrinthEntrance"
							end,
			["OverrideCentroid"] = function(tagdata)
								return "GLOBALTAG", "OverrideCentroid"
							end,
			["RoadPoison"] = function(tagdata)
								return "TAG", "RoadPoison"
							end,
			["ForceConnected"] = function(tagdata)
								return "TAG", "ForceConnected"
							end,
			["ForceDisconnected"] = function(tagdata)
								return "TAG", "ForceDisconnected"
							end,
			["OneshotWormhole"] = function(tagdata)
								return "TAG", "OneshotWormhole"
							end,
			["ExitPiece"] = function(tagdata)
								return "TAG", "ExitPiece"
							end,							
			--["ExitPiece"]	= 	function(tagdata)
									--if #tagdata["ExitPiece"] == 0 then
										--return
									--end
																		
									--local item = GetRandomItem(tagdata["ExitPiece"])
									
									--for idx,v in pairs(tagdata["ExitPiece"]) do
										--if v == item then
											--table.remove(tagdata["ExitPiece"], idx)
											--break
										--end
									--end								
									
									--print("Exit piece adding bit", item)
									--return "STATIC", item	
								--end,
								
			["Town"] =  function(tagdata)
							return "TAG", 0x000001	
						end,
			["Chester_Eyebone"] =	function(tagdata)
										if tagdata["Chester_Eyebone"] == false then
											return
										end
										tagdata["Chester_Eyebone"] = false
										return "ITEM", "chester_eyebone"
									end,
			["Packim_Fishbone"] =	function(tagdata)
										if tagdata["Packim_Fishbone"] == false then
											return
										end
										tagdata["Packim_Fishbone"] = false
										return "ITEM", "packim_fishbone"
									end,
 			
 			["sandstorm"] =			function(tagdata)
										return "TAG", "sandstorm" 
									end,									
		}
	return {Tag = map_tags, TagData = map_data }
end
return MakeTags
