
local function OnCreate(inst, scenariorunner)
	local world = GetWorld()
	if not world or not world.Map then
		return 
	end

	local radius = 16
	local ex, ey, ez = inst.Transform:GetWorldPosition()
	local tx, ty = world.Map:GetTileCoordsAtPoint(ex, ey, ez)
	local extents = {left=tx, right=tx, bottom=ty, top=ty}

	--print("OCEAN_SHIPGRAVEYARD", tx, ty, tostring(world.Map:GetTile(tx, ty)))

	for y = ty - radius, ty + radius, 1 do
		local x = tx - 1
		repeat
			local tile = world.Map:GetTile(x, y)
			x = x - 1
			--print("OCEAN_SHIPGRAVEYARD left", tx - radius, x, tx)
		until x < tx - radius or tile ~= GROUND.OCEAN_SHIPGRAVEYARD
		extents.left = math.min(extents.left, x)

		x = tx + 1
		repeat
			local tile = world.Map:GetTile(x, y)
			x = x + 1
			--print("OCEAN_SHIPGRAVEYARD, right", tx, x, tx + radius)
		until x > tx + radius or tile ~= GROUND.OCEAN_SHIPGRAVEYARD
		extents.right = math.max(extents.right, x)
	end

	for x = extents.left, extents.right, 1 do
		local y = ty - 1
		repeat
			local tile = world.Map:GetTile(x, y)
			y = y - 1
			--print("OCEAN_SHIPGRAVEYARD bottom", ty - radius, y, ty)
		until y < ty - radius or tile ~= GROUND.OCEAN_SHIPGRAVEYARD
		extents.bottom = math.min(extents.bottom, y)

		y = ty + 1
		repeat
			local tile = world.Map:GetTile(x, y)
			y = y + 1
			--print("OCEAN_SHIPGRAVEYARD top", ty, y, ty + radius)
		until y > ty + radius or tile ~= GROUND.OCEAN_SHIPGRAVEYARD
		extents.top = math.max(extents.top, y)
	end

	local newrad = 0.5 * TILE_SCALE * math.max(extents.right - extents.left, extents.top - extents.bottom)
	inst:SetRadius(newrad)

	local width, height = world.Map:GetSize()
	local newx = ((0.5 * (extents.left + extents.right)) - width/2.0)*TILE_SCALE
	local newz = ((0.5 * (extents.top + extents.bottom)) - height/2.0)*TILE_SCALE
	inst.Transform:SetPosition(newx, ey, newz)

	scenariorunner:ClearScenario()
end

return 
{
	OnCreate = OnCreate
}