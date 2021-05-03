local easing = require("easing")


local ShakeDeltas =
{
    --------------------------------------------------------------------------
    --     4
    --  7     1
    -- 2   S   6
    --  5     3
    --     0
    --------------------------------------------------------------------------
    Vector3( 0,-1):GetNormalized(),
    Vector3( 1, 1):GetNormalized(),
    Vector3(-1, 0):GetNormalized(),
    Vector3( 1,-1):GetNormalized(),
    Vector3( 0, 1):GetNormalized(),
    Vector3(-1,-1):GetNormalized(),
    Vector3( 1, 0):GetNormalized(),
    Vector3(-1, 1):GetNormalized(),
}

local UIAnim = Class(function(self, inst)
    self.inst = inst
end)

function UIAnim:ForceStartWallUpdating( widget )
    if not widget.GetAnimState then
        return
    end
    self.forceWallUpdateTime = 0
    self.forceWallUpdatingWidget = widget
    self.inst:StartWallUpdatingComponent(self)
end

function UIAnim:ForceStopWallUpdating()
    self.forceWallUpdateTime = nil
    self.forceWallUpdatingWidget = nil
    self.inst:StopWallUpdatingComponent(self)
end

function UIAnim:ScaleTo(start, dest, duration, whendone)
    self.scale_start = start
    self.scale_dest = dest
    self.scale_duration = duration
    self.scale_t = 0

    if self.scale_whendone then
		self.scale_whendone()
    end
    self.scale_whendone = whendone
    self.inst:StartWallUpdatingComponent(self)
end

function UIAnim:MoveTo(start, dest, duration, whendone)
    self.pos_start = start
    self.pos_dest = dest
    self.pos_duration = duration
    self.pos_t = 0
    
    if self.pos_whendone then
		self.pos_whendone()
    end
    self.pos_whendone = whendone
    
    
    self.inst:StartWallUpdatingComponent(self)
    self.inst.UITransform:SetPosition(start.x, start.y, start.z)
end


function UIAnim:Shake(duration, speed, scale)
    if self.shaking then return end
    self.shake_pos_start = Vector3(self.inst.UITransform:GetLocalPosition())
    self.shake_scale_start = self.inst.UITransform:GetScale()

    self.shake_timer = 0
    self.shake_speed = speed
    self.shake_duration = duration
    self.shake_scale = scale
    self.shaking = true

    self.inst:StartWallUpdatingComponent(self)
end


function UIAnim:OnWallUpdate(dt)
    if not self.inst:IsValid() then
		self.inst:StopWallUpdatingComponent(self)
		return
    end

    if self.forceWallUpdateTime then
       local animState = self.forceWallUpdatingWidget:GetAnimState()
       if animState then
           self.forceWallUpdateTime = self.forceWallUpdateTime + dt
           self.forceWallUpdatingWidget:GetAnimState():SetTime(self.forceWallUpdateTime)
       end
    end

    if self.shaking then
        self.shake_duration = self.shake_duration - dt
        if self.shake_duration > 0 then
            self.shake_timer = self.shake_timer + dt
            if self.shake_timer > self.shake_speed then

                local scale = GetRandomWithVariance(1, 0.1)
                self:MoveTo(Vector3(self.inst.UITransform:GetLocalPosition()), (self.shake_pos_start + (ShakeDeltas[math.random(#ShakeDeltas)] * self.shake_scale)), self.shake_speed)
                self:ScaleTo(self.inst.UITransform:GetScale(), self.shake_scale_start * scale, self.shake_speed)
                self.shake_timer = 0
            end
        else
            --Stop shaking...
            self:MoveTo(Vector3(self.inst.UITransform:GetLocalPosition()), self.shake_pos_start, self.shake_speed)
            self:ScaleTo(self.inst.UITransform:GetScale(), self.shake_scale_start, self.shake_speed)
            self.shaking = false
        end
    end

    local done = false
    
    if self.scale_t then
        local val = 1
        local sx, sy, sz = self.inst.UITransform:GetScale()
        if sx and sy and sz then
	        
			self.scale_t = self.scale_t + dt
			if self.scale_t < self.scale_duration then
				val = easing.outCubic( self.scale_t, self.scale_start, self.scale_dest - self.scale_start, self.scale_duration)
			else
				val = self.scale_dest
				self.scale_t = nil
				
				if self.scale_whendone then
					self.scale_whendone()
					self.scale_whendone = nil
				end
				
			end
			self.inst.UITransform:SetScale(sx >= 0 and val or -val, sy >= 0 and val or -val, sz >= 0 and val or -val)
		end
    end

    if self.pos_t then
        local valx = 0
        local valy = 0
        local valz = 0
        --local sx, sy, sz = self.inst.UITransform:GetPosition()
        
        self.pos_t = self.pos_t + dt
        if self.pos_t < self.pos_duration then
            valx = easing.outCubic( self.pos_t, self.pos_start.x, self.pos_dest.x - self.pos_start.x, self.pos_duration)
            valy = easing.outCubic( self.pos_t, self.pos_start.y, self.pos_dest.y - self.pos_start.y, self.pos_duration)
            valz = easing.outCubic( self.pos_t, self.pos_start.z, self.pos_dest.z - self.pos_start.z, self.pos_duration)
        else
            valx= self.pos_dest.x
            valy= self.pos_dest.y
            valz= self.pos_dest.z
            self.pos_t = nil
            if self.pos_whendone then
				self.pos_whendone()
				self.pos_whendone = nil
            end
        end
        self.inst.UITransform:SetPosition(valx, valy, valz)
    end
    
    if not self.scale_t and not self.pos_t and not self.forceWallUpdateTime and not self.shaking then
        self.inst:StopWallUpdatingComponent(self)
    end
end

return UIAnim
