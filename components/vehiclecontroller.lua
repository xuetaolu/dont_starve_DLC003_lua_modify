require "class"

local easing = require "easing"

local trace = function() end

local START_DRAG_TIME = (1/30)*8


local VehicleController = Class(function(self, inst)
    self.inst = inst
    self.enabled = false
    
    --Tunable variables 
    self.angularAcceleration = 40 --How sharply the boat the can turn, the higher the number the lower the turn radius 
    self.linearAcceleration = 3   -- How quickly the boat speeds up
    self.linearDecceleration = 3  -- how quikcly the boat slows down 
    self.maxSpeed = 9--TUNING.WILSON_RUN_SPEED --maximum speed of the boat, I think this is 6 
    self.abruptChangeThreshold = 120 -- Do abrupt change logic if the difference between the current direction and the control angle is greater than this number 
    self.abruptDecceleration = 8 -- how quickly the boat slows down when doing an abrupt change 
    self.warmUpTime = 1  --The amount of time before you start moving from a standstill 

  
    self.standStillTimer = 0
    self.currentAngle = nil 
    self.currentSpeed = 0 
    self.targetAngle = 0 
    self.atStandStill = false

    self.handler = TheInput:AddGeneralControlHandler(function(control, value) self:OnControl(control, value) end)
    self.inst:StartUpdatingComponent(self)
    
    --For mouse dragging controls 
    self.draggingonground = false
    self.startdragtime = nil

	--self.inst:ListenForEvent("buildstructure", function(inst, data) self:OnBuild() end, GetPlayer())

 	--self.inst:ListenForEvent("equip", function(inst, data) self:OnEquip(data) end, GetPlayer() )
    --self.inst:ListenForEvent("unequip", function(inst, data) self:OnUnequip(data) end,  GetPlayer() )


    self.LMBaction = nil
    self.RMBaction = nil

    self.directwalking = false



    self.deploy_mode = not TheInput:ControllerAttached()
end)

function VehicleController:OnControl(control, down)
    if not self:IsEnabled() then return end

    --ToDo: Check if we're clicking on ourself, if so, dismount 
    if control == CONTROL_PRIMARY then
        self:OnLeftClick(down)
        return 
    elseif control == CONTROL_SECONDARY then
        self:OnRightClick(down)
        return 
    elseif control == CONTROL_CONTROLLER_ALTACTION and down then
        if(self.atStandStill) then 
            self:ReleasePlayer()
        end 
    end
end

function VehicleController:OnLeftClick(down)
    
    if TheInput:GetHUDEntityUnderMouse() then 
        return
    end 

    if not down then return self:OnLeftUp() end
   
    local clicked = TheInput:GetWorldEntityUnderMouse()
    if not clicked then
        self.startdragtime = GetTime()
        --local buffaction = BufferedAction(self.inst, nil, ACTIONS.WALKTO, nil, TheInput:GetWorldPosition())       
        --self.inst.components.locomotor:PushAction(buffaction, true)
    elseif clicked == self.inst  and self.atStandStill == true then --Either clicking on the vehicle or the player, need to exit vehicle(always?)
        self:ReleasePlayer()
    end  
end


function VehicleController:OnLeftUp()
    if not self:IsEnabled() then return end    

        if self.draggingonground then
            self.draggingonground = false
            TheFrontEnd:LockFocus(false)
        end
    self.startdragtime = nil
    
end 


function VehicleController:OnRightClick(down)
      if TheInput:GetHUDEntityUnderMouse() then 
        return
    end 

    if not down then return self:OnRightUp() end

end

function VehicleController:OnRightUp()
   

end 


function VehicleController:ReleasePlayer()
    
    --local buffaction = self.inst.components.playeractionpicker:GetClickActions(self.inst)
    --self.inst.components.locomotor:PushAction(buffaction, true)
    self.inst.components.driver:OnDismount()

end 



function VehicleController:WalkButtonDown()
    return  TheInput:IsControlPressed(CONTROL_MOVE_UP) or TheInput:IsControlPressed(CONTROL_MOVE_DOWN) or TheInput:IsControlPressed(CONTROL_MOVE_LEFT) or TheInput:IsControlPressed(CONTROL_MOVE_RIGHT)
end



--Called every frame with the world angle that the player should run in 
function VehicleController:SetTargetAngle(angle)
   --self.inst.Transform:SetRotation(angle)
    --self.inst.components.locomotor:RunInDirection(angle)
    self.targetAngle = angle 
    
end 

function VehicleController:OnUpdate(dt)

    if not TheInput:IsControlPressed(CONTROL_PRIMARY) then --If we're doing dragging controls but primary is no longer down, stop dragging controls 
        if self.draggingonground then
            self.draggingonground = false
            TheFrontEnd:LockFocus(false)
            self.startdragtime = nil
        end
    end


    if self:IsEnabled() then 

        local loco = self.inst.components.locomotor
        
        local throttleDown = false 


        if self.startdragtime and not self.draggingonground and TheInput:IsControlPressed(CONTROL_PRIMARY) then  --Should I switch to dragging around mouse controls?    
            local now = GetTime()
            if now - self.startdragtime > START_DRAG_TIME then
                TheFrontEnd:LockFocus(true)
                self.draggingonground = true
            end
        end

        if self.draggingonground then --Already in dragging mode controls 
            local pt = TheInput:GetWorldPosition()
            local dst = distsq(pt, Vector3(self.inst.Transform:GetWorldPosition()))    
            if dst > 1 then
                local angle = self.inst:GetAngleToPoint(pt)
                self.inst:ClearBufferedAction()
                self:SetTargetAngle(angle)
                throttleDown = true
            end
            self.directwalking = false
        else
            self:DoDirectWalking(dt)  --Not in in dragging mode, check direct walking 
            throttleDown = self.directwalking
        end


        --Figure out the smallest difference btween my target angle and my current angle, and which direction I should turn to get to the target 
        local currentAngle = self.inst.Transform:GetRotation()
        local difference = self.targetAngle - currentAngle
        local turnDir = 1
        if(difference < 0) then turnDir = -1 end 
        if math.abs(difference) > 360 then difference = difference - 360 * Sign(difference) end   --Make sure the difference is in the range -360 to 360 
        if math.abs(difference) > 180 then 
            turnDir = turnDir * -1 
            difference = 360 - difference * Sign(difference)  --Make sure the difference is less than 180
        end 


        local doingAbruptChange = false 
        if math.abs(difference) > self.abruptChangeThreshold and not self.atStandStill then 
            if self.currentSpeed == 0 then
                self.inst.Transform:SetRotation(self.targetAngle)
                difference = 0
            else
                doingAbruptChange = true
            end 
            turnDir = 0
        end 

        if self.atStandStill then 
            if throttleDown then 
                self.standStillTimer = self.standStillTimer + dt
            else
                self.standStillTimer = 0
            end 
            if self.standStillTimer > self.warmUpTime then 
                self.atStandStill = false 
                self.standStillTimer = 0
                self.inst.Transform:SetRotation(self.targetAngle)
            end
        --Do throttling 
         elseif doingAbruptChange then 
            self.currentSpeed = self.currentSpeed - self.abruptDecceleration * dt
            self.targetAngle = self.inst.Transform:GetRotation()
            if(self.currentSpeed < 0) then 
                self.currentSpeed = 0
            end 
        elseif throttleDown then 
            self.currentSpeed = self.currentSpeed + self.linearAcceleration * dt
            if(self.currentSpeed > self.maxSpeed) then 
                self.currentSpeed = self.maxSpeed
            end 
        else
            self.currentSpeed = self.currentSpeed - self.linearDecceleration * dt
            self.targetAngle = self.inst.Transform:GetRotation()
            if(self.currentSpeed < 0) then 
                self.currentSpeed = 0
                self.atStandStill = true
            end 
        end 
        
        loco.runspeed = self.currentSpeed
        --Do turning 
        if self.currentSpeed > 0 then 
            local change = turnDir * dt * self.angularAcceleration
            local newAngle

            if math.abs(change) >= math.abs(difference) then 
                newAngle = self.targetAngle
            else 
                newAngle = currentAngle + change
            end 

            self.inst.Transform:SetRotation(newAngle)
            self.inst.components.locomotor:RunInDirection(newAngle)
        else 
            self.inst.components.locomotor:Stop()
        end 

    end
end 


function VehicleController:DoDirectWalking(dt)

    local dir = self:GetWorldControllerVector()

    if dir then
        local ang = -math.atan2(dir.z, dir.x)/DEGREES
 
        self.inst.components.locomotor:SetBufferedAction(nil)
        self:SetTargetAngle(ang)
        self.directwalking = true 
    else
        if self.directwalking then
            self.directwalking = false
        end
    end
end


function VehicleController:GetWorldControllerVector()
    local xdir = TheInput:GetAnalogControlValue(CONTROL_MOVE_RIGHT) - TheInput:GetAnalogControlValue(CONTROL_MOVE_LEFT)
    local ydir = TheInput:GetAnalogControlValue(CONTROL_MOVE_UP) - TheInput:GetAnalogControlValue(CONTROL_MOVE_DOWN)
    local deadzone = .3

    if math.abs(xdir) < deadzone and math.abs(ydir) < deadzone then xdir = 0 ydir = 0 end
    if xdir ~= 0 or ydir ~= 0 then
        local CameraRight = TheCamera:GetRightVec()
        local CameraDown = TheCamera:GetDownVec()
        local dir = CameraRight * xdir - CameraDown * ydir
        dir = dir:GetNormalized()
        return dir
    end
end


function VehicleController:Enable(val)
    self.enabled = val
end

function VehicleController:IsEnabled()
    return self.enabled
end 

function VehicleController:OnEquip(data)

end

function VehicleController:OnUnequip(data)

end


return VehicleController