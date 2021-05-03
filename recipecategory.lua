require "recipe"

RecipeCategory = Class(Recipe, function(self, name, category, tab, level, game_type, image, tooltip)
	Recipe._ctor(self, 	name, {}, tab, level, game_type, nil, nil, true, nil, nil, nil, nil, nil, image)
	self.subcategory = category
	self.skipCategoryCheck = false
	self.tooltip = tooltip
end)

