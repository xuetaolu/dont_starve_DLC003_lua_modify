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
      filename = "../../../../../tools/tiled/dont_starve/ground.tsx",
      tilewidth = 64,
      tileheight = 64,
      spacing = 0,
      margin = 0,
      image = "../../../../../tools/tiled/dont_starve/tiles.png",
      imagewidth = 512,
      imageheight = 448,
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
        50, 0, 0, 0, 50, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        50, 0, 0, 0, 50, 0, 0, 0, 50, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        50, 0, 0, 0, 50, 0, 0, 0, 50, 0, 0, 0, 50, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        50, 0, 0, 0, 0, 0, 0, 0, 50, 0, 0, 0, 0, 0, 0, 0
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
          type = "coffeebush",
          shape = "rectangle",
          x = 64,
          y = 64,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["makebarren"] = "true"
          }
        },
        {
          name = "",
          type = "coffeebush",
          shape = "rectangle",
          x = 176,
          y = 80,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["makebarren"] = "true"
          }
        },
        {
          name = "",
          type = "coffeebush",
          shape = "rectangle",
          x = 208,
          y = 176,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["makebarren"] = "true"
          }
        },
        {
          name = "",
          type = "coffeebush",
          shape = "rectangle",
          x = 144,
          y = 224,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["makebarren"] = "true"
          }
        },
        {
          name = "",
          type = "coffeebush",
          shape = "rectangle",
          x = 48,
          y = 192,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["makebarren"] = "true"
          }
        },
        {
          name = "",
          type = "coffeebush",
          shape = "rectangle",
          x = 32,
          y = 112,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["makebarren"] = "true"
          }
        },
        {
          name = "",
          type = "coffeebush",
          shape = "rectangle",
          x = 112,
          y = 112,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["makebarren"] = "true"
          }
        },
        {
          name = "",
          type = "coffeebush",
          shape = "rectangle",
          x = 160,
          y = 144,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["makebarren"] = "true"
          }
        },
        {
          name = "",
          type = "coffeebush",
          shape = "rectangle",
          x = 112,
          y = 176,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["makebarren"] = "true"
          }
        }
      }
    }
  }
}
