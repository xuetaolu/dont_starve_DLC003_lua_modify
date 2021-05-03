STATES = {
	IDLE = 1,
	MOVING = 2,
	DEAD = 3,
}

local Segmented = Class(function(self, inst)
    self.inst = inst    
    self.segments = {}
    self.vulnerablesegments = 0
    self.segmentstotal = 0
    self.state = STATES.IDLE
    self.groundpoint_start = nil
    self.groundpoint_end = nil
    self.segmentprefab = "pugalisk_segment"    
    self.nextseg = 0
    self.segtimeMax = 1 --1.5
    self.loopcomplete = false
    self.ease = 1

    self.inst:ListenForEvent("death", function(inst, data)
        self:onhostdeath(inst)
    end)  
    self.inst:ListenForEvent("dohitanim", function(inst, data)
        self:onhit()
    end)        
end)

function Segmented:Start(angle, segtimeMax, advancetime)
	self.started = true

	if segtimeMax then
		self.segtimeMax = segtimeMax
	end

    local pos =  Vector3(self.inst.Transform:GetWorldPosition())
	self:SetGroundStart(pos)                        

    if not angle then
        angle = -PI/2
     end

    self.inst.angle = angle

    local radius = 6        

    local offset = Vector3(radius * math.cos( angle ), 0, -radius * math.sin( angle ))

    pos= pos + offset
    self:SetGroundTarget(pos)

    local exit = SpawnPrefab("pugalisk_body")
    exit.AnimState:PlayAnimation("thisisbroken", true)
    exit.Transform:SetPosition(pos.x,pos.y,pos.z)
    exit.Physics:SetActive(false)
    exit:AddTag("exithole")
    self.inst.exitpt = exit
    exit.startpt = self.inst
    exit.host = self.inst.host

   -- if self.startfn then
   -- 	self.startfn(self.inst, pos)
   -- end

    self.state = STATES.MOVING
    self.inst:StartUpdatingComponent(self)
    if advancetime then
    	while advancetime > 0 do
    		local dt = 1/30
    		self:OnUpdate( dt )
    		advancetime = advancetime - dt
    	end
    end
end

function Segmented:StartMove()
	if self.state ~= STATES.DEAD then
		--print("STARTING SEGMENT MOVE", self.inst:HasTag("switchToTailProp"))
		self.state = STATES.MOVING
	end
end
function Segmented:StopMove()
	if self.state ~= STATES.DEAD then
		print("STOPPING SEGMENT MOVE", self.inst:HasTag("switchToTailProp"))
		self.state = STATES.IDLE	
	end
end

function Segmented:SetStartFn(fn)
	self.startfn = fn
end

function Segmented:SetGroundTarget(point)
	self.groundpoint_end = point
	self.groundpoint_dist = self.inst:GetDistanceSqToPoint(self.groundpoint_end)

	self.xdiff = (self.groundpoint_end.x - self.groundpoint_start.x)
	self.zdiff = (self.groundpoint_end.z - self.groundpoint_start.z)
end
function Segmented:SetGroundStart(point)
	self.groundpoint_start = point
end

function Segmented:removeSegment(segment)
	for i, testsegment in ipairs(self.segments)do
		if segment == testsegment then
			table.remove(self.segments,i)
		end
	end

	self.segmentstotal = self.segmentstotal -1
	if segment.vulnerable then
		self.vulnerablesegments = self.vulnerablesegments - 1
	end

	self.inst.exitpt.AnimState:PlayAnimation("dirt_segment_in_pst")
	self.inst.exitpt.AnimState:OverrideSymbol("segment_swap",segment.build, "segment_swap")

	self.inst.exitpt.AnimState:Hide("broken01")
    self.inst.exitpt.AnimState:Hide("broken02")
    
	if segment.showbroken01 then
		self.inst.exitpt.AnimState:Show("broken01")
		self.inst.exitpt.showbroken01 = true
	end
	if segment.showbroken02 then
		self.inst.exitpt.AnimState:Show("broken02")
		self.inst.exitpt.showbroken02 = true
	end	
	segment:Remove()
end

function Segmented:removeAllSegments()
	for i=#self.segments, 1, -1 do
		self:removeSegment(self.segments[i])		
	end	
end

function Segmented:updatesegmentart(segment, percentdist)

		local anim = "test_segment"
		local build = "python_segment_build"

		if segment.head then
			anim = "test_head"
			build = "python_test"
		end	
		if segment.tail then
			build = "python_segment_tail_build"		
		end		
		if segment.tail02 then
			build = "python_segment_tail02_build"
		end					
		if segment.vulnerable then
			build = "python_segment_broken02_build"			
		end		   
		segment.AnimState:OverrideSymbol("segment_swap", build, "segment_swap")
		--segment.AnimState:SetBuild(build)
		segment.build = build
		if percentdist then
			segment.AnimState:SetPercent(anim,percentdist)
		end
end

function Segmented:addSegment(tail)
	if not self.tailfinished  then

		local segment = SpawnPrefab(self.segmentprefab)
		segment.host = self.inst.host
		segment.playerpickerproxy = self.inst

		--segment.Transform:SetPosition(self.groundpoint_start.x,self.groundpoint_start.y,self.groundpoint_start.z)
		segment.segtime = self.segtimeMax * 0.01

			local p1 = Vector3(self.groundpoint_end.x,0,self.groundpoint_end.z)
			local p0 = Vector3(self.groundpoint_start.x,0,self.groundpoint_start.z) 

			local pdelta = p1 - p0					

			local t = segment.segtime/self.segtimeMax

			local pf = (pdelta * t) + p0 

			pf.y = 0 

			segment.setheight = pf.y

			segment.Transform:SetPosition(pf.x,pf.y,pf.z)

		local angle = segment:GetAngleToPoint(self.groundpoint_end.x,self.groundpoint_end.y,self.groundpoint_end.z)					
		segment.Transform:SetRotation(angle)

		segment.startpt = self.inst

		table.insert(self.segments, segment)
		self.segmentstotal = self.segmentstotal +1	

		if not self.firstsegment then  
			self.firstsegment = true
			segment.head = true
		end

		if tail then
			if self.tailadded  then		
				self.tailfinished = true
				segment.tail = true
				self.inst:DoTaskInTime(0.5, function() self.inst.AnimState:PlayAnimation("dirt_collapse") end)

			else		
				self.tailadded = true
				segment.tail02 = true				
			end
		end

		if not self.inst.invulnerable then		
			if math.random() < 0.7 then
				segment.AnimState:Show("broken01")
				segment.showbroken01 = true
			end
			if math.random() < 0.7 then
				segment.AnimState:Show("broken02")
				segment.showbroken02 = true
			end
			
			segment.vulnerable = true
			self.vulnerablesegments = self.vulnerablesegments + 1
		end
		self:updatesegmentart(segment,0)
	end
end

function Segmented:onhostdeath()
	self.state = STATES.DEAD
	self.inst.SoundEmitter:KillSound("speed")
	self.inst.exitpt.SoundEmitter:KillSound("speed")

	for i, segment in ipairs(self.segments)do
		self.inst:DoTaskInTime(math.random()*1+ 1, function() self:killsegment(segment) end)
	end	

	if self.inst.exitpt then
		self.inst.exitpt:DoTaskInTime(2,function()			
		  self.inst.exitpt:Remove() 
		end)
	end
end

function Segmented:onhit()
	self.hit = 1
end

function Segmented:getSegment(index)
	local step = 1

	for i,segment in ipairs(self.segments)do
		if step == index then			
			return segment			
		end
		step = step + 1
	end
end

function Segmented:scaleSegment(index, scale)

	local segment = self:getSegment(index)
	if segment then
		local s = scale
		segment.Transform:SetScale(s,s,s)		
	end
end

function Segmented:killsegment(segment)
	if self.segment_deathfn then
		self.segment_deathfn(segment)
	end
	--local bone = SpawnPrefab("boneshard")
	self:removeSegment(segment)
end

function Segmented:switchtotail()
	self.inst.SoundEmitter:KillSound("speed")
	self.inst.exitpt.SoundEmitter:KillSound("speed")

	local newtail = SpawnPrefab("pugalisk_tail")
	newtail.sg:GoToState("tail_ready") 
	newtail.wantstotaunt = nil
	local pt = Vector3(self.inst.exitpt.Transform:GetWorldPosition())
	newtail.Transform:SetPosition(pt.x,pt.y,pt.z)
	self:removeAllSegments()
	self.inst.host.components.multibody.tail = newtail
	self.inst:PushEvent("bodyfinished")	
end

function Segmented:SetToEnd()
	self.lastrun = true
	if self.inst.host and self.inst.host.components.multibody.tail then
		print("PURGE OLD TAIL")
		self.inst.host.components.multibody.tail:PushEvent("tail_should_exit")
	end
end

function Segmented:OnUpdate( dt )
	for i, segment in ipairs(self.segments)do
		segment.percentdist = segment.segtime/self.segtimeMax
		self:updatesegmentart(segment,segment.percentdist)
	end

	if self.state ~= STATES.DEAD then

		local rate = 1/30
		local speed = 0
	
		-- CALCULATE THE EASE
		if self.state == STATES.MOVING then
			self.ease = math.min(self.ease + rate,1)	
		else
			self.ease = math.max(self.ease - rate,0)
		end	

		speed = self.ease
		
		-- if this body has been told its the end, just have it run out until it's gone. If it should stop, it will stop as a tail.
		if self.lastrun then -- self.tailfinished and self.state == STATES.IDLE 
			speed = 1
		end			

		self.inst.SoundEmitter:SetParameter("speed", "intensity", speed)
		--self.inst.exitpt.SoundEmitter:SetParameter("speed", "intensity", speed)

		-- PROCESS THE EASE
		if self.groundpoint_end then
			for i, segment in ipairs(self.segments)do

				local p1 = Vector3(self.groundpoint_end.x,0,self.groundpoint_end.z)
				local p0 = Vector3(self.groundpoint_start.x,0,self.groundpoint_start.z) 

				local pdelta = p1 - p0

				segment.segtime = math.min(segment.segtime + (dt * speed) , self.segtimeMax)

				local t = segment.segtime/self.segtimeMax

				local pf = (pdelta * t) + p0 
				
				--pf.y =  math.sin( PI * t) * 3				               										

				segment.setheight = pf.y

				segment.Transform:SetPosition(pf.x,pf.y,pf.z)	

				if t > 0.5 then
					segment.playerpickerproxy = self.inst.exitpt				
				end

				if t > 0.7 and segment.tail and self.inst:HasTag("switchToTailProp")  then
					self:switchtotail()
				end				

				if t > 0.98 then
					if not self.loopcomplete then
						--print("BODY COMPLETE EVENT")
						self.inst:PushEvent("bodycomplete")
						self.loopcomplete = true
					end
					
					self:removeSegment(segment)	
				end

			end
		end

		if self.state == STATES.IDLE then
			if self.segments and #self.segments > 0 then

				local function positionandscale(segment, scale, height)
					if scale then
						segment.scalegoal = scale
					end
					if height then
						segment.heightgoal = segment.setheight * height
					end
				end				

				local SEGMENTIDLETIME = 0.1

				if not self.idletimer then
					self.idletimer = SEGMENTIDLETIME + (math.random() *1)
					self.idlesegment = 1
				end

				self.idletimer = self.idletimer - dt
				
				if self.idletimer < 0 then

					if self.segments[self.idlesegment -1] then
						positionandscale(self.segments[self.idlesegment -1], 1.5, 1)		
					end
					if self.segments[self.idlesegment +1] then
						positionandscale(self.segments[self.idlesegment +1], 1.5, 1)	
					end	
					if self.segments[self.idlesegment] then
						positionandscale(self.segments[self.idlesegment], 1.5, 1)					
					end

					self.idlesegment = self.idlesegment +1
					self.idletimer = SEGMENTIDLETIME
					if self.idlesegment > #self.segments  then
						self.idlesegment = 1		
						self.idletimer = SEGMENTIDLETIME  -- + (math.random()*1.5)
					end					
				end
				
				local HEIGHT_SUB = 0.97
				local HEIGHT = 0.95

				local SCALE_SUB = 1.55  --1.52
				local SCALE = 1.6  -- 1.55
				
				if self.segments[self.idlesegment -1] then	
					positionandscale(self.segments[self.idlesegment -1], SCALE_SUB, HEIGHT_SUB)				
				end

				if self.segments[self.idlesegment +1] then
					positionandscale(self.segments[self.idlesegment +1], SCALE_SUB, HEIGHT_SUB)
				end

				if self.segments[self.idlesegment] then
					positionandscale(self.segments[self.idlesegment], SCALE, HEIGHT)		
				end

				for i, segment in ipairs(self.segments)do					
		
					local SCALE_VEL = 0.008
					if segment.scalegoal then
									
						local scale = segment.Transform:GetScale()
					
						if scale ~= segment.scalegoal then
							if scale > segment.scalegoal then
								scale = math.max(scale - SCALE_VEL, segment.scalegoal )
							else
								scale = math.min(scale + SCALE_VEL, segment.scalegoal )
								if scale == segment.scalegoal then
									segment.SoundEmitter:PlaySound("dontstarve_DLC003/creatures/boss/pugalisk/scales")
								end
							end							
						end						
						segment.Transform:SetScale(scale,scale,scale)						
					end

					local HEIGHT_VEL = 0.005

					if segment.heightgoal then
						local pf = segment:GetPosition()
						if pf.y ~= segment.heightgoal then
							if pf.y > segment.heightgoal then
								pf.y = math.max(pf.y - HEIGHT_VEL,segment.heightgoal)
							else
								pf.y = math.min(pf.y + HEIGHT_VEL,segment.heightgoal)
							end
						end						
						segment.Transform:SetPosition(pf.x,pf.y,pf.z)	
					end												

				end			
    		end		
		else
			self.idletimer = nil
			self.idlesegment = nil
		end

		if self.hit and self.hit > 0 then
			for i, segment in ipairs(self.segments)do
				local s = 1.5 
				s = Remap(self.hit, 1, 0, 1, 1.5)
				segment.Transform:SetScale(s,s,s)

				local pf = segment:GetPosition()
				pf.y = 0

				segment.Transform:SetPosition(pf.x,pf.y,pf.z)
			end
			self.hit = self.hit -(dt*5)
		end

		if self.nextseg <= 0 then
			self:addSegment(self.lastrun)				
			self.nextseg = 1/15
		else			
			self.nextseg = self.nextseg  - (dt * speed)		-- self.ease
		end			

		if self.segmentstotal <= 0 and self.lastrun then
			self.inst.exitpt.AnimState:PlayAnimation("dirt_collapse")
			self.inst.exitpt:ListenForEvent("animover", function(localinst, data)
				localinst:Remove()
			end)			
			self.inst:PushEvent("bodyfinished")
		end		
	end
end

return Segmented


