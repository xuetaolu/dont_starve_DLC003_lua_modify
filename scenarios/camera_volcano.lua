require("mathutil")

local zoomdistance = 100 
local distToFinish = 10 --Distance to volcano where you reach max zoom 
local distToStart = 65 --Distance from the volcano where you start to zoom 
local distToStart_SQ = distToStart * distToStart
local distToFinish_SQ = distToFinish * distToFinish
local distToLerpOver = distToStart_SQ - distToFinish_SQ
local percentFromPlayer = 1



--local STARTING_CAMERA_OFFSET = 1.5
--local FINAL_CAMERA_OFFSET = 3

local function roundToNearest(numToRound, multiple)
	local half = multiple/2
	return numToRound+half - (numToRound+half) % multiple
end

local function Update(inst)
	local closest = GetWorld().components.volcanomanager:GetClosestVolcano()
	--print(closest .. inst)
	if closest and closest == inst then 

		local distToTarget = inst:GetDistanceSqToInst(inst.objToTrack)

		if distToTarget < distToStart_SQ then
			TheCamera:SetControllable(false)
			percentFromPlayer = (distToTarget - distToFinish_SQ)/distToLerpOver
			--print("percentFromPlayer is " .. percentFromPlayer)
			--if percentFromPlayer < 0 then percentFromPlayer = 0 end
			if percentFromPlayer >= 0 and percentFromPlayer <= 1 then
				--local camAngle = Lerp(roundToNearest(inst.prevCamAngle, 360), inst.prevCamAngle, percentFromPlayer)
				local camDist = Lerp(zoomdistance, inst.prevCamDist, percentFromPlayer)
				--TheCamera:SetOffset(Vector3(0,Lerp(FINAL_CAMERA_OFFSET,STARTING_CAMERA_OFFSET,percentFromPlayer),0))
				TheCamera:SetDistance(camDist)
				--TheCamera:SetHeadingTarget(camAngle)
				TheCamera:Apply()
			elseif percentFromPlayer < 0 then			
				--if TheCamera:GetHeadingTarget() ~= roundToNearest(inst.prevCamAngle, 360) then
					--TheCamera:SetOffset(Vector3(0,FINAL_CAMERA_OFFSET,0))
					TheCamera:SetDistance(zoomdistance)
					--TheCamera:SetHeadingTarget(roundToNearest(inst.prevCamAngle, 360))
					TheCamera:Apply()
				--end						
			end
		else
			--print("out of range")
			if not TheCamera:IsControllable() then
				TheCamera:SetDistance(inst.prevCamDist)
				TheCamera:SetHeadingTarget(inst.prevCamAngle)
				TheCamera:Apply()
			end
			TheCamera:SetControllable(true)
			inst.prevCamAngle = TheCamera:GetHeadingTarget()
			inst.prevCamDist = TheCamera:GetDistance()
		end
	end 
end

local function OnLoad(inst, scenariorunner)
	inst.objToTrack = GetPlayer()
	inst.updatetask = inst:DoPeriodicTask(0.05, Update)
	inst.prevCamDist = 30
	inst.prevCamAngle = 45
end

return 
{
	OnLoad = OnLoad,
}