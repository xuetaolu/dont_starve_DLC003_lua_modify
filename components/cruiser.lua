local easing = require("easing")

local SCREEN_DIST = 50
local HEAD_ATTACK_DIST = 3
local SCALERATE = 1/(30 *2)  -- 2 seconds to go from 0 to 1

local HEADDIST = 17
local HEADDIST_TARGET = 15
local HEADDIST_REVERSE = 13

local TAILDIST = 13
local TAILDIST_REVERSE = 12

local LEGDIST = TUNING.ROC_LEGDSIT
local LEG_WALKDIST = 4
local LAND_PROX = 7

local Cruiser = Class(function(self, inst)
    self.inst = inst    
    self.speed = 10	
    self.stages = 3
    self.startscale = 0.35   

    self.head_vel = 0
    self.head_acc = 3
    self.head_vel_max = 10
    self.body_vel = 0
    self.body_acc = 0.3
    self.body_dec = 1
    self.body_vel_max = 6
end)

function Cruiser:Setup(speed, scale, stages)
	if speed then
		self.speed = speed
	end
	if scale then	
		self.startscale = scale
	end
	if stages then
		self.stages = stages		
	end

	self.inst:ListenForEvent("liftoff", function() self:doliftoff() end, self.inst) 

	self.inst:DoTaskInTime(0,function() self:setscale(self.startscale) self.inst:PushEvent("fly") end)

	--self.inst:DoPeriodicTask(30+(math.random()*30), function() self:CheckScale() end )
	self.inst:DoPeriodicTask(1, function() self:CheckScale() end )
end

function Cruiser:Start()
	self.inst:StartUpdatingComponent(self)
end

function Cruiser:Stop()
	self.inst:StopUpdatingComponent(self)
end

function Cruiser:CheckScale()
--	print("CHECKING SCALE",self.inst.Transform:GetScale())
	if self.inst.Transform:GetScale() ~= 1.5 then

		local delta = (1-self.startscale) / self.stages

		self.scaleup = {
			targetscale = math.min(self.inst.Transform:GetScale() + delta, 1.5)
		}
		print("SET TARGET SCALE",self.scaleup.targetscale)
	end
end

function Cruiser:setscale(scale)
	self.inst.Transform:SetScale(scale,scale,scale)
	if self.scalefn then
		self.scalefn(self.inst,scale)
	end
end

function Cruiser:doliftoff()
	if #self.inst.bodyparts > 0 then
		for i,part in ipairs(self.inst.bodyparts) do
			part:PushEvent("exit")
		end
		self.inst.bodyparts = nil
		self.liftoff = true
		self.landed = nil

		self.inst:PushEvent("takeoff")
	end
end

function Cruiser:Spawnbodyparts()

		if not self.inst.bodyparts then
			self.inst.bodyparts = {}
		end

		local angle = self.inst.Transform:GetRotation()*DEGREES
		local pos = Vector3(self.inst.Transform:GetWorldPosition())

		local offset = nil


		offset = Vector3(LEGDIST * math.cos( angle+(PI/2) ), 0, -LEGDIST * math.sin( angle+(PI/2) ))
		local leg1 = SpawnPrefab("roc_leg")
		leg1.Transform:SetPosition(pos.x + offset.x,0,pos.z + offset.z)
		leg1.Transform:SetRotation(self.inst.Transform:GetRotation())
		leg1.sg:GoToState("enter")
		leg1.body = self.inst
		leg1.legoffsetdir = PI/2
		table.insert(self.inst.bodyparts,leg1)
		self.leg1 = leg1
		self.currentleg = self.leg1

		offset = Vector3(LEGDIST * math.cos( angle-(PI/2) ), 0, -LEGDIST * math.sin( angle-(PI/2) ))	
		local leg2 = SpawnPrefab("roc_leg")
		leg2.Transform:SetPosition(pos.x + offset.x,0,pos.z + offset.z)
		leg2.Transform:SetRotation(self.inst.Transform:GetRotation())
		leg2.sg:GoToState("enter")			
		leg2.body = self.inst
		leg2.legoffsetdir = -PI/2
		table.insert(self.inst.bodyparts,leg2)
		self.leg2 = leg2

		self.inst:DoTaskInTime(0.5,function()								
			offset = Vector3(HEADDIST * math.cos( angle ), 0, -HEADDIST * math.sin( angle ))
			local head = SpawnPrefab("roc_head")
			head.Transform:SetPosition(pos.x + offset.x,0,pos.z + offset.z)
			head.Transform:SetRotation(self.inst.Transform:GetRotation())
			head.sg:GoToState("enter")
			table.insert(self.inst.bodyparts,head)
			self.head = head
		end)

		offset = Vector3(TAILDIST * math.cos( angle -PI ), 0, -TAILDIST * math.sin( angle -PI ))
		local tail = SpawnPrefab("roc_tail")
		tail.Transform:SetPosition(pos.x + offset.x,0,pos.z + offset.z)
		tail.Transform:SetRotation(self.inst.Transform:GetRotation())
		tail.sg:GoToState("enter")
		self.tail = tail
		table.insert(self.inst.bodyparts,tail)
end

function Cruiser:OnUpdate(dt)
	local player = GetPlayer()
	local disttoplayer = self.inst:GetDistanceSqToInst(player)
	if disttoplayer > SCREEN_DIST*SCREEN_DIST then
		-- has landed and is flying again, should leave now
		print("HERE!!!!!!!!!!!!!!")
		if self.liftoff then
			print("FLY AWAY")
			self.inst:Remove()
		elseif not self.landed then
			local x,y,z = player.Transform:GetWorldPosition()
			self.inst.Transform:SetRotation(self.inst:GetAngleToPoint(x, y, z))
		end
	end

	if self.scaleup then
		local currentscale = self.inst.Transform:GetScale()
		if currentscale ~= self.scaleup.targetscale then
			local setscale = math.min( currentscale + (SCALERATE*dt), self.scaleup.targetscale )
			self:setscale(setscale)			
		else 
			self.scaleup = nil
		end
	end

	if self.inst.Transform:GetScale() == 1 and not self.landed and not self.liftoff then

		if disttoplayer < LAND_PROX*LAND_PROX then
			self.landed = true
			self.inst:PushEvent("land")
		end
	end

	if self.landed and self.head and self.tail and self.leg1 and self.leg2 then
		local target = GetPlayer()
		
		if not self.head.sg:HasStateTag("busy") then
			local targetpos =Vector3(target.Transform:GetWorldPosition())	
			local headdistsq = self.head:GetDistanceSqToInst(target) 
			if headdistsq > HEAD_ATTACK_DIST*HEAD_ATTACK_DIST then			
				self.head_vel = math.min(self.head_vel + (self.head_acc *dt), self.head_vel_max)
			else
				self.head:PushEvent("bash")
				self.head_vel = math.max(self.head_vel - (self.head_acc *dt), 0)
			end
			local HEAD_VEL = self.head_vel *dt
			local angle = self.head:GetAngleToPoint(targetpos)*DEGREES
			local offset = Vector3(HEAD_VEL * math.cos( angle ), 0, -HEAD_VEL * math.sin( angle ))
			local pos = Vector3(self.head.Transform:GetWorldPosition())
			self.head.Transform:SetPosition(pos.x+offset.x,0,pos.z+offset.z)
			
		end

--[[

		local bodistsq = self.inst:GetDistanceSqToInst(self.head) 
		if bodistsq > HEADDIST*HEADDIST or bodistsq < HEADDIST_REVERSE*HEADDIST_REVERSE then
			self.body_vel = math.min(self.body_vel + (self.body_acc *dt), self.body_vel_max)
		else
			self.body_vel = math.max(self.body_vel + (self.body_dec *dt), 0)
		end
		]]

		local bodistsq = self.inst:GetDistanceSqToInst(self.head) 
		if bodistsq > HEADDIST*HEADDIST then

			-- move body to range of body.
			local BOD_VEL = 10*dt
			local targetpos =Vector3(self.head.Transform:GetWorldPosition())
			local angle = self.inst:GetAngleToPoint(targetpos)*DEGREES
			local offset = Vector3(BOD_VEL * math.cos( angle ), 0, -BOD_VEL * math.sin( angle ))
			local pos = Vector3(self.inst.Transform:GetWorldPosition())
			self.inst.Transform:SetPosition(pos.x+offset.x,0,pos.z+offset.z)		
							
		elseif bodistsq < HEADDIST_REVERSE*HEADDIST_REVERSE then
			-- move body to range of body.
			local BOD_VEL = 6*dt
			local targetpos =Vector3(self.head.Transform:GetWorldPosition())
			local angle = self.inst:GetAngleToPoint(targetpos)*DEGREES
			local offset = Vector3(BOD_VEL * math.cos( angle -PI), 0, -BOD_VEL * math.sin( angle -PI ))
			local pos = Vector3(self.inst.Transform:GetWorldPosition())
			self.inst.Transform:SetPosition(pos.x+offset.x,0,pos.z+offset.z)		
		
		end



		local angle = (self.inst.Transform:GetRotation()*DEGREES) + PI
		local tailtarget = Vector3(self.inst.Transform:GetWorldPosition()) + Vector3(TAILDIST * math.cos( angle ), 0, -TAILDIST * math.sin( angle ))
		local taildistsq = self.head:GetDistanceSqToPoint(tailtarget) 
		if taildistsq > TAILDIST*TAILDIST or taildistsq < TAILDIST_REVERSE*TAILDIST_REVERSE then
			-- move head to target at some speed.
			local HEAD_VEL = 10*dt
			local angle = self.tail:GetAngleToPoint(tailtarget)*DEGREES
			local offset = Vector3(HEAD_VEL * math.cos( angle ), 0, -HEAD_VEL * math.sin( angle ))
			local pos = Vector3(self.tail.Transform:GetWorldPosition())
			self.tail.Transform:SetPosition(pos.x+offset.x,0,pos.z+offset.z)
		end
		

		-- set rotations
		local headpos =Vector3(self.head.Transform:GetWorldPosition())
		self.inst.Transform:SetRotation( self.inst:GetAngleToPoint(headpos) )
		self.head.Transform:SetRotation(self.inst.Transform:GetRotation())	
		self.tail.Transform:SetRotation(self.inst.Transform:GetRotation())	

		-- legs
		if not self.leg1.sg:HasStateTag("walking") and not self.leg2.sg:HasStateTag("walking") then

			local legdir = PI/2
			if self.currentleg == 2 then
				legdir = legdir * -1
			end

			local angle = self.inst.Transform:GetRotation()*DEGREES

			local currentlegtargetpos = Vector3(self.inst.Transform:GetWorldPosition()) + Vector3(LEGDIST * math.cos( angle+legdir ), 0, -LEGDIST * math.sin( angle+legdir ))
			local legdistsq = self.currentleg:GetDistanceSqToPoint(currentlegtargetpos) 
			if legdistsq > LEG_WALKDIST * LEG_WALKDIST or self.currentleg.Transform:GetRotation() ~= self.inst.Transform:GetRotation() then
				self.currentleg:PushEvent("walk")
								
				if self.currentleg == self.leg1 then
					self.currentleg = self.leg2
				else
					self.currentleg = self.leg1
				end
			end			
		end

		-- move tail to point in position like head. 
	end
end

function Cruiser:OnEntitySleep()
	self:Stop()
end

function Cruiser:OnEntityWake()
	self:Start()
end

return Cruiser