local ROT_SPEED = 1 / 1.5		-- 1.5 seconds per rotation
local TRANS_SPEED = 1 / 2.0		-- 2.0 seconds per translation
local MAX_ROTATION = 20			-- max 20 degrees from base rotation
local MAX_TRANSLATION = 1		-- max 1 world unit from base position
local SCALE = 6				-- scale for the texture
local MIN_STRENGTH = 0.2		-- blend min strength - modulated with avg ambient
local MAX_STRENGTH = 0.7		-- blend max strength - modulated with avg ambient
local GRID_RADIUS = 7			-- number of tiles around player
local TILE_DISTANCE = 7			-- distance in world units between grid elements
local CULL_DISTANCE = 40		-- grid elements get culled at this distance from the player

local CanopyManager = Class(function(self, inst)
	self.inst = inst

	self.minstrength = MIN_STRENGTH
	self.maxstrength = MAX_STRENGTH

	self:SetRotSpeed(ROT_SPEED)
	self:SetTransSpeed(TRANS_SPEED)
	self:SetMaxRotation(MAX_ROTATION)
	self:SetMaxTranslation(MAX_TRANSLATION)
	self:SetScale(SCALE)
	self:SetMinStrength(MIN_STRENGTH)
	self:SetMaxStrength(MAX_STRENGTH)

	self:SetTileGridRadius(GRID_RADIUS)
	self:SetTileDistance(TILE_DISTANCE)
	self:SetCullTileDistance(CULL_DISTANCE)

    self.inst:ListenForEvent( "renderjunglecanopy", 
          function(it, data) 
				self:SetEnabled(data.value)
				if self.enabled then
					self.inst:StartUpdatingComponent(self)
				else
					self.inst:StopUpdatingComponent(self)
				end	
          end, GetWorld()) 
end)

function CanopyManager:OnUpdate( dt )	
	if self.enabled then
		local r,g,b = TheSim:GetAmbientColour()
		local avg = (r+g+b)/3
		local strength = Lerp(self.minstrength, self.maxstrength, avg/255)
		TheSim:SetCanopyStrength(strength)
		TheSim:UpdateCanopyRenderer(dt)
	end
end

function CanopyManager:SetTexture(name)	
	TheSim:SetCanopyTexture(name)
end

function CanopyManager:SetRotSpeed(speed)
	TheSim:SetCanopyRotSpeed(speed)
end

function CanopyManager:SetTransSpeed(speed)
	TheSim:SetCanopyTransSpeed(speed)
end

function CanopyManager:SetMaxRotation(angle)
	TheSim:SetCanopyMaxRotation(angle)
end

function CanopyManager:SetMaxTranslation(units)
	TheSim:SetCanopyMaxTranslation(units)
end

function CanopyManager:SetScale(scale)
	TheSim:SetCanopyScale(scale)
end

function CanopyManager:SetMaxStrength(strength)
	self.maxstrength = strength
end

function CanopyManager:SetMinStrength(strength)
	self.minstrength = strength
end

function CanopyManager:SetEnabled(enabled)
	self.enabled = enabled
	TheSim:SetCanopyEnabled(enabled)
end

function CanopyManager:SetTileGridRadius(radius)
	TheSim:SetCanopyTileGridRadius(radius)
end

function CanopyManager:SetTileDistance(distance)
	TheSim:SetCanopyTileDistance(distance)
end

function CanopyManager:SetCullTileDistance(distance)
	TheSim:SetCanopyCullTileDistance(distance)
end

function CanopyManager:SetTileTypes(list)
	TheSim:SetCanopyTileTypes(list)
end

return CanopyManager
