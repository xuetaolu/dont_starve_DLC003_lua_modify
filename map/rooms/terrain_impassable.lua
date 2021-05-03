
AddRoom("BGImpassable", {
					colour={r=.6,g=.35,b=.8,a=.50},
					value = GROUND.IMPASSABLE,
					contents =  { }
					})
AddRoom("BGImpassableRock", {
					colour={r=.8,g=.8,b=.8,a=.90},
					value = GROUND.ABYSS_NOISE,
					contents =  { }
					})
AddRoom("Nothing", {
					colour={r=.45,g=.45,b=.35,a=.50},
					value = GROUND.IMPASSABLE,
					contents =  {
					            }
					})
AddRoom("ForceDisconnectedRoom", {
					colour={r=.45,g=.75,b=.45,a=.50},
					type = "blank",
					tags = {"ForceDisconnected"},
					value = GROUND.IMPASSABLE,
					contents = {},
			})