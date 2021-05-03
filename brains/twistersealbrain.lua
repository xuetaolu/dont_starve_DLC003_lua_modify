require "behaviours/faceentity"

local TwisterSealBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local START_FACE_DIST = 14
local KEEP_FACE_DIST = 20

local function GetFaceTargetFn(inst)
    local target = GetClosestInstWithTag("player", inst, START_FACE_DIST)
    if target and not target:HasTag("notarget") then
        return target
    end
end

local function KeepFaceTargetFn(inst, target)
    return inst:GetDistanceSqToInst(target) <= KEEP_FACE_DIST * KEEP_FACE_DIST and not target:HasTag("notarget")
end

function TwisterSealBrain:OnStart()
    local root =
        PriorityNode(
        {
            FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        }, .25)
    
    self.bt = BT(self.inst, root)
end

return TwisterSealBrain