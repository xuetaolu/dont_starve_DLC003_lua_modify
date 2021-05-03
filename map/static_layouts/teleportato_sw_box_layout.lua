return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 16,
  height = 16,
  tilewidth = 16,
  tileheight = 16,
  properties = {},
  tilesets = {
    {
      name = "ground",
      firstgid = 1,
      filename = "../../../klei/DLC_Shipwrecked/tools/tiled/dont_starve/ground.tsx",
      tilewidth = 64,
      tileheight = 64,
      spacing = 0,
      margin = 0,
      image = "../../../klei/DLC_Shipwrecked/tools/tiled/dont_starve/tiles.png",
      imagewidth = 512,
      imageheight = 384,
      properties = {},
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "BG_TILES",
      x = 0,
      y = 0,
      width = 16,
      height = 16,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        47, 0, 0, 0, 0, 0, 0, 0, 47, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        47, 0, 0, 0, 47, 0, 0, 0, 47, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 47, 0, 0, 0, 47, 0, 0, 0, 47, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 47, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "",
          type = "teleportato_sw_box",
          shape = "rectangle",
          x = 124,
          y = 171,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_limestone",
          shape = "rectangle",
          x = 184,
          y = 115,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.25"
          }
        },
        {
          name = "",
          type = "wall_limestone",
          shape = "rectangle",
          x = 75,
          y = 143,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.75"
          }
        },
        {
          name = "",
          type = "wall_limestone",
          shape = "rectangle",
          x = 120,
          y = 92,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.5"
          }
        },
        {
          name = "",
          type = "wall_limestone",
          shape = "rectangle",
          x = 155,
          y = 93,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.75"
          }
        },
        {
          name = "",
          type = "wall_limestone",
          shape = "rectangle",
          x = 67,
          y = 177,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.5"
          }
        },
        {
          name = "",
          type = "wildborehouse",
          shape = "rectangle",
          x = 63,
          y = 89,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.25"
          }
        },
        {
          name = "",
          type = "fishingrod",
          shape = "rectangle",
          x = 131,
          y = 121,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.25"
          }
        },
        {
          name = "",
          type = "grass",
          shape = "rectangle",
          x = 33,
          y = 106,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.5"
          }
        },
        {
          name = "",
          type = "grass",
          shape = "rectangle",
          x = 233,
          y = 145,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.5"
          }
        },
        {
          name = "",
          type = "grass",
          shape = "rectangle",
          x = 165,
          y = 37,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.5"
          }
        }
      }
    }
  }
}
