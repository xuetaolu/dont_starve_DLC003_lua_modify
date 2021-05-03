return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 36,
  height = 36,
  tilewidth = 16,
  tileheight = 16,
  properties = {},
  tilesets = {
    {
      name = "ground",
      firstgid = 1,
      filename = "../../../../../tools/tiled/dont_starve/ground.tsx",
      tilewidth = 64,
      tileheight = 64,
      spacing = 0,
      margin = 0,
      image = "../../../../../tools/tiled/dont_starve/tiles.png",
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
      width = 36,
      height = 36,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 37, 0, 0, 0, 37, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 37, 0, 0, 0, 0, 0, 0, 0, 37, 0, 0, 0, 37, 0, 0, 0, 37, 0, 0, 0, 37, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 37, 0, 0, 0, 37, 0, 0, 0, 37, 0, 0, 0, 40, 0, 0, 0, 40, 0, 0, 0, 37, 0, 0, 0, 37, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        37, 0, 0, 0, 37, 0, 0, 0, 37, 0, 0, 0, 40, 0, 0, 0, 40, 0, 0, 0, 40, 0, 0, 0, 37, 0, 0, 0, 37, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        37, 0, 0, 0, 40, 0, 0, 0, 40, 0, 0, 0, 40, 0, 0, 0, 40, 0, 0, 0, 40, 0, 0, 0, 40, 0, 0, 0, 37, 0, 0, 0, 37, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        37, 0, 0, 0, 37, 0, 0, 0, 40, 0, 0, 0, 40, 0, 0, 0, 40, 0, 0, 0, 40, 0, 0, 0, 37, 0, 0, 0, 37, 0, 0, 0, 37, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 37, 0, 0, 0, 40, 0, 0, 0, 40, 0, 0, 0, 40, 0, 0, 0, 40, 0, 0, 0, 37, 0, 0, 0, 37, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 37, 0, 0, 0, 37, 0, 0, 0, 40, 0, 0, 0, 40, 0, 0, 0, 37, 0, 0, 0, 37, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 37, 0, 0, 0, 37, 0, 0, 0, 37, 0, 0, 0, 37, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
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
          type = "fishinhole",
          shape = "rectangle",
          x = 256,
          y = 320,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_limestone",
          shape = "rectangle",
          x = 480,
          y = 240,
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
          x = 480,
          y = 224,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.75"
          }
        },
        {
          name = "",
          type = "seashell_beached",
          shape = "rectangle",
          x = 112,
          y = 464,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.5"
          }
        },
        {
          name = "",
          type = "fishingrod",
          shape = "rectangle",
          x = 288,
          y = 416,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.25"
          }
        },
        {
          name = "",
          type = "palmtree",
          shape = "rectangle",
          x = 80,
          y = 352,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.5"
          }
        },
        {
          name = "",
          type = "palmtree",
          shape = "rectangle",
          x = 416,
          y = 448,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.5"
          }
        },
        {
          name = "",
          type = "seashell_beached",
          shape = "rectangle",
          x = 432,
          y = 352,
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
          x = 96,
          y = 224,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.25"
          }
        },
        {
          name = "",
          type = "palmtree",
          shape = "rectangle",
          x = 160,
          y = 528,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.5"
          }
        },
        {
          name = "",
          type = "seaweed_planted",
          shape = "rectangle",
          x = 320,
          y = 192,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.25"
          }
        },
        {
          name = "",
          type = "seaweed_planted",
          shape = "rectangle",
          x = 176,
          y = 400,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.25"
          }
        },
        {
          name = "",
          type = "seaweed_planted",
          shape = "rectangle",
          x = 336,
          y = 320,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.25"
          }
        },
        {
          name = "",
          type = "seashell_beached",
          shape = "rectangle",
          x = 368,
          y = 80,
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
          x = 480,
          y = 208,
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
          x = 80,
          y = 224,
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
          x = 64,
          y = 224,
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
          x = 464,
          y = 208,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "0.25"
          }
        }
      }
    }
  }
}
