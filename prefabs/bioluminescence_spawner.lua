

local prefabs = 
{
	"bioluminescence",
}
  

local function spawnchildren(inst)
	local numChildren = 6
	local numBranches = 2
	local maxAngle = 120 * DEGREES
	local distanceBetween = 3
	local lastAngle = 0
	local x,y,z = inst.Transform:GetWorldPosition()
	local startAngle = math.random() * 360 * DEGREES
	
	for i = 1, numBranches do 
		local startAngle = startAngle + ((45 + math.random() * 270 ) * DEGREES)
		for ii = 1, numChildren do 

			local angle  = startAngle + -maxAngle/2 +  math.random() * maxAngle
			x = x + math.cos(angle) * distanceBetween
			z = z + math.sin(angle) * distanceBetween
			--print("spawning children", angle)
			local onWater = inst:IsPosSurroundedByWater(x,y,z,2) 
			if not onWater then --If we're too close to land, bail out 
				break; 
			end 

			local child = SpawnPrefab("bioluminescence")
	     	child.Transform:SetPosition(x,y,z)
	     	--x = x + distanceBetween
		end 
	end 
	inst:Remove() --Might want to keep this around to manage the spawned children, but for now just get rid of it
end 


local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	inst:DoTaskInTime(5*FRAMES, spawnchildren)
    return inst
end

return Prefab( "common/bioluminescence_spawner", fn, {}, prefabs) 
