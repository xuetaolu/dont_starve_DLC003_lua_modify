
local VolcanoWave = Class(function(self, inst)
	self.inst = inst
	self.waves = nil
	self.inst:StartUpdatingComponent(self)
end)

function VolcanoWave:OnUpdate( dt )
	if self.waves then
		local map = GetWorld().Map
		local px, py, pz = GetPlayer().Transform:GetWorldPosition()
		local x, y = map:GetTileXYAtPoint(px, py, pz)

		local disttolava = map:GetClosestTileDist(x, y, GROUND.VOLCANO_LAVA, 20)
		local disttocloud = map:GetClosestTileDist(x, y, GROUND.IMPASSABLE, 20)

		--print(string.format("lava %f, cloud %f\n", disttolava, disttocloud))
		if disttocloud < disttolava then
		    self.waves:SetWaveTexture( "images/volcano_cloud.tex" )
		else
			self.waves:SetWaveTexture( "images/lava_active.tex" )
		end
	end
end

return VolcanoWave