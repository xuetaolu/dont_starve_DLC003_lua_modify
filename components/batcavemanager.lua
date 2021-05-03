
local BatCaveManager = Class(function(self, inst)
	self.inst = inst
	self.my_bats = {}
	self.batstospawn = 0
	self.lastupdated = 10
	self.inst:StartUpdatingComponent(self)
end)


local function SpawnBat(self)
	local bat = SpawnPrefab("vampirebat")
	bat.cavebat = true 
	local pt = Vector3(self.inst.Transform:GetWorldPosition())
	local angle = math.random(0,360)
	local offset = FindValidPositionByFan(angle*DEGREES, 6, 12, function() return true end)
	local final = pt + offset
	bat.Transform:SetPosition(final.x, final.y, final.z)
	table.insert(self.my_bats, bat)
end 
  
function BatCaveManager:UpdateBats()
	local batted = GetWorld().components.batted
 	local bats_num = self.batstospawn

 	if bats_num == 0 then 
 		--We're either not in CAVE phase or don't have any bats to spawn here. 
 	else 
	 	for i = 1, bats_num do 
	 		SpawnBat(self)
	 	end 
	 	self.batstospawn = 0
	end
end 

function BatCaveManager:OnUpdate(dt)
	self.lastupdated = self.lastupdated - dt
	if self.lastupdated <= 0 then 
		self.lastupdated = 10 
		self:UpdateBats()
	end 
end

--LONG UPDATE

--SAVE 

--LOAD 

return BatCaveManager

