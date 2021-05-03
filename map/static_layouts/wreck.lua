return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 12,
  height = 12,
  tilewidth = 16,
  tileheight = 16,
  properties = {},
  tilesets = {},
  layers = {
    {
      type = "tilelayer",
      name = "BG_TILES",
      x = 0,
      y = 0,
      width = 12,
      height = 12,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
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
          type = "ship_area",
          shape = "rectangle",
          x = 6,
          y = 5,
          width = 62,
          height = 62,
          visible = true,
          properties = {
            ["data.isnamed"] = "true",
            ["data.wrecktype"] = "hull"
          }
        },
        {
          name = "",
          type = "debris_area",
          shape = "rectangle",
          x = 69,
          y = 68,
          width = 119,
          height = 120,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "mast_area",
          shape = "rectangle",
          x = 86,
          y = 86,
          width = 37,
          height = 37,
          visible = true,
          properties = {
            ["data.wrecktype"] = "mast"
          }
        }
      }
    }
  }
}
