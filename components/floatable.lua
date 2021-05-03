local Floatable = Class(function(self, inst)
    self.inst = inst
    self.landanim = nil
    self.wateranim = nil
    self.onwater = false 
    self.onwaterfn = nil
    self.onlandfn = nil
end)

function Floatable:UpdateAnimations(water_anim, land_anim)
	self.wateranim = water_anim or self.wateranim
	self.landanim = land_anim or self.landanim

	if self.onwater then
		self:PlayWaterAnim()
	else
		self:PlayLandAnim()
	end
end

function Floatable:OnEntitySleep()
end

function Floatable:OnEntityWake()
end

--[[
function Floatable:Start()
	self.inst:StartUpdatingComponent(self)
end

function Floatable:Stop()
	self.inst:StopUpdatingComponent(self)
end
]]

function Floatable:PlayLandAnim()
	if not self.inst.AnimState:IsCurrentAnimation(self.landanim or "") then
		self.inst.AnimState:SetLayer( LAYER_WORLD)
		self.inst.AnimState:SetSortOrder(0)
	    if self.landanim then 
	    	self.inst.AnimState:PlayAnimation(self.landanim, true)
	    end
	end
	if not self.inst.useownripples then
		self.inst.AnimState:OverrideSymbol("water_ripple", "ripple_build", "water_ripple")
    	self.inst.AnimState:OverrideSymbol("water_shadow", "ripple_build", "water_shadow")
	end
end

function Floatable:PlayWaterAnim()
	if not self.inst.AnimState:IsCurrentAnimation(self.wateranim or "") then
		self.inst.AnimState:SetLayer( LAYER_BACKGROUND )
	    self.inst.AnimState:SetSortOrder( 3 )
		if self.wateranim then 
			self.inst.AnimState:PlayAnimation(self.wateranim, true)
			self.inst.AnimState:SetTime(math.random())
		end
	end
	if not self.inst.useownripples then
		self.inst.AnimState:OverrideSymbol("water_ripple", "ripple_build", "water_ripple")
    	self.inst.AnimState:OverrideSymbol("water_shadow", "ripple_build", "water_shadow")
	end
end  

function Floatable:PlayThrowAnim()

	if self.inst:GetIsOnWater() then
		if not self.inst.AnimState:IsCurrentAnimation(self.wateranim or "") then
			self.inst.AnimState:SetLayer( LAYER_BACKGROUND )
		    self.inst.AnimState:SetSortOrder( 3 )
			if self.wateranim then 
				self.inst.AnimState:PlayAnimation(self.wateranim, true)
				self.inst.AnimState:SetTime(math.random())
			end
		end
	else
		if not self.inst.AnimState:IsCurrentAnimation(self.landanim or "") then
			self.inst.AnimState:SetLayer( LAYER_WORLD)
			self.inst.AnimState:SetSortOrder(0)
		    if self.landanim then 
		    	self.inst.AnimState:PlayAnimation(self.landanim, true)
		    end
		end
	end
	
	self.inst.AnimState:ClearOverrideSymbol("water_ripple")
    self.inst.AnimState:ClearOverrideSymbol("water_shadow")
end


function Floatable:OnHitWater(skipcrocodogtest)
	self.onwater = true 
	--self:Start()
	self:PlayWaterAnim()
	if self.onwaterfn then
		self.onwaterfn(self.inst)
	end
	self.inst.PushEvent("hitwater")
	self.inst:AddTag("aquatic")

	if self.inst.components.burnable then
		self.inst.components.burnable:Extinguish()
	end

	if self.inst.components.sinkable then
		self.inst.components.sinkable:onhitwater()
	end


    if not skipcrocodogtest and GetWorld().components.hounded then
    	-- don't forget to reject all the crocodog drops here
		if self.inst.prefab ~= "shark_fin" and not self.inst:HasTag("monstermeat") and self.inst.components.edible and self.inst.components.edible.foodtype == "MEAT" and not self.inst:HasTag("spawnnosharx") then 		
            local roll = math.random()
			local chance = TUNING.SHARKBAIT_CROCODOG_SPAWN_MULT * self.inst.components.edible.hungervalue
	        if roll < chance then 
	        	if math.random()<0.6 then
                	GetWorld().components.hounded:SummonHound()
                else
                	for i=1,math.random(2,4) do
	                	GetWorld().components.hounded:SummonSharx()
                	end
            	end	
	        end
		end 
	end 
end

function Floatable:OnHitLand(loading)
	self.onwater = false 
	--self:Stop()
	if self.onlandfn then
		self.onlandfn(self.inst)
	end
	self.inst.PushEvent("hitland")
	self.inst:RemoveTag("aquatic")
	self:PlayLandAnim()
end

function Floatable:OnSave()
	return {onwater = self.onwater}
end

function Floatable:OnLoad(data)

	local world = GetWorld()
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local tile, tileinfo = self.inst:GetCurrentTileType(x, y, z)
    local onwater = not world.Map:IsLand(tile)
	
	if onwater == true then 
		self:OnHitWater(true)
	else 
		self:OnHitLand(true)
	end 

end

function Floatable:SetAnimationFromPosition()
	if not self.inst:GetIsOnWater() then
		self:OnHitLand()
	else 
		self:OnHitWater(true)
	end
end 

function Floatable:SetOnHitWaterFn(fn)
	self.onwaterfn = fn
end

function Floatable:SetOnHitLandFn(fn)
	self.onlandfn = fn
end

return Floatable
