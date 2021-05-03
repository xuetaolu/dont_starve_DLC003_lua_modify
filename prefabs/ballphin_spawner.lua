local assets = {}

local prefabs = 
{
	"ballphin",
	"ballphinpod",
}

local function spawnchildren(inst)
	local numChildren = 6
	local numBranches = 2
	local maxAngle = 120 * DEGREES
	local distanceBetween = 3
	local lastAngle = 0
	local x,y,z = inst.Transform:GetWorldPosition()
	local startAngle = math.random() * 360 * DEGREES
	local spawnedatleastone = false 
	
	for i = 1, numBranches do 
		local startAngle = startAngle + ((45 + math.random() * 270 ) * DEGREES)
		for ii = 1, numChildren do 


			local angle  = startAngle + -maxAngle/2 +  math.random() * maxAngle
			x = x + math.cos(angle) * distanceBetween
			z = z + math.sin(angle) * distanceBetween

			local onWater = inst:IsPosSurroundedByWater(x,y,z,2) 
			if not onWater then --If we're too close to land, bail out 
				break; 
			end 

			local child = SpawnPrefab("ballphin")
			child.Transform:SetPosition(x,y,z)
			spawnedatleastone = true 
			--x = x + distanceBetween
		end
	end
	if spawnedatleastone then 
		local herd = SpawnPrefab("ballphinpod")
	    if herd then
	        herd.Transform:SetPosition(inst.Transform:GetWorldPosition()) --Assumes the ballphinspawner was properly placed on the water during worldgen 
	        if herd.components.herd then
	            herd.components.herd:GatherNearbyMembers()
	        end
	    end
	end 

	inst:Remove() --Might want to keep this around to manage the spawned children, but for now just get rid of it
end

local function onsave(inst, data)
	if inst.targettime then
		local time = GetTime()
		if inst.targettime > time then
			data.time = math.floor(inst.targettime - time)
		end
	end
end
local function onload(inst, data)
	if data and data.time then
		local time = GetTime()
		local spawntime = data.time
		inst.targettime = time + spawntime
		inst.task = inst:DoTaskInTime(spawntime, spawnchildren)
	end
end

local function LongUpdate(inst, dt)

	if inst.targettime then
		
		if inst.task then
			inst.task:Cancel()
		end
		
		local time = GetTime()
		
		if inst.targettime > time + dt then
			--resechedule
			local spawntime = inst.targettime - time - dt

			inst.targettime = time + spawntime
			inst.task = inst:DoTaskInTime(spawntime, spawnchildren)
		else
			spawnchildren(inst)
		end
	end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()

	inst.OnLongUpdate = LongUpdate
	inst.OnSave = onsave
	inst.OnLoad = onload

	local spawntime = TUNING.TOTAL_DAY_TIME*15 + TUNING.TOTAL_DAY_TIME*math.random()

	inst.targettime = GetTime() + spawntime
	inst.task = inst:DoTaskInTime(spawntime, spawnchildren)

	return inst
end

return Prefab( "common/ballphin_spawner", fn, assets, prefabs) 
