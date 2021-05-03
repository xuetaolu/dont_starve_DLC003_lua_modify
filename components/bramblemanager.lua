require("constants")


local BrambleManager = Class(function(self, inst)
    self.inst = inst
    self.bramblespots = {}
    self.bramblesToSpawn = 7
    self.bramblesspawned = false
	self.inst:ListenForEvent("seasonChange", function(it, data) 
			if self.disabled then
				print("BRAMBLES DISABLED!!!!")
			end
			if not self.disabled then
		    	if data.season == SEASONS.LUSH then
		    		if not self.bramblesspawned then
		    			self:SpawnBrambles()
		    		end
		    	else
		    		self.bramblesspawned = false
				end    	
			end
	    end)
end)

function BrambleManager:SpawnBrambles()
	self.bramblesspawned = true
	local selected = {}
	local tempselctionset = deepcopy(self.bramblespots)

	for i=#tempselctionset,1,-1 do
		local x,y,z = tempselctionset[i].Transform:GetWorldPosition()
		local tile = GetWorld().Map:GetTileAtPoint(x, 0, z)
		if      tile ~= GROUND.DEEPRAINFOREST 
			and tile ~= GROUND.GASJUNGLE 
			and tile ~= GROUND.RAINFOREST 
			and tile ~= GROUND.PLAINS 
			and tile ~= GROUND.PAINTED
			and tile ~= GROUND.BATTLEGROUND
			and tile ~= GROUND.DIRT then
				print("REMOVING SPAWN OPTION",tile)
				table.remove(tempselctionset,i)
		end
	end

	for i=1,self.bramblesToSpawn do
		if #tempselctionset > 0 then
			local choice = math.random(1,#tempselctionset)
			local point = tempselctionset[choice]
			table.insert(selected,point)
			
			for i=#tempselctionset,1,-1 do
				local testpoint = tempselctionset[i]
				if point:GetDistanceSqToInst(testpoint) < 40*40 then
					table.remove(tempselctionset,i)
				end				
			end
		end
	end
	for i,point in ipairs(selected)do

	    local bramble = SpawnPrefab("bramble")
	    local x,y,z = point.Transform:GetWorldPosition()
	    bramble.Transform:SetPosition(x,y,z)
	end
end

function BrambleManager:RegisterBramble(inst)

	local x,y,z = inst.Transform:GetWorldPosition()
	local tile = GetWorld().Map:GetTileAtPoint(x, 0, z)
    if tile ~= GROUND.IMPASSABLE and tile ~= GROUND.INVALID then
		table.insert(self.bramblespots,inst)
	end
end

function BrambleManager:OnLoad(data)
	if data.disabled then 
		self.disabled = data.disabled	
	end
	if data.bramblesspawned then
		self.bramblesspawned = data.bramblesspawned
	end
end

function BrambleManager:OnSave()
	return
	{
		disabled = self.disabled,
		bramblesspawned = self.bramblesspawned
	}
end

return BrambleManager
