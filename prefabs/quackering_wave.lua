local assets=
{
	Asset("ANIM", "anim/rowboat_wake_quack.zip")
}

local function fn(Sim)

	local inst = CreateEntity()
	inst.persists = false

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	--inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
	inst.AnimState:SetLayer(LAYER_BACKGROUND )
	inst.AnimState:SetSortOrder( 3 )
    inst.AnimState:SetBuild("rowboat_wake_quack")
    inst.AnimState:SetBank("wakeTrail")
    inst.AnimState:PlayAnimation("quack_dn", true)

	inst.lastDirection = -1

	inst.ChangeDirection = function(self, newDirection)

		-- starting up
		if newDirection ~= self.lastDirection then
			if newDirection == 0 then
				self.AnimState:PlayAnimation("quack_sd", true) -- right
			elseif newDirection == 1 then
				self.AnimState:PlayAnimation("quack_oop", true)
			elseif newDirection == 2 then
				self.AnimState:PlayAnimation("quack_sd2", true)
			elseif newDirection == 3 then
				self.AnimState:PlayAnimation("quack_dn", true)
			end
		end

		self.lastDirection = newDirection
	end

	inst.ShowEffect = function(self, direction)
		self.lastDirection = -1
		self:ChangeDirection(direction)
		self:Show()
	end

	inst.HideEffect = function(self)
		self.lastDirection = -1
		self:Hide()
	end

    return inst
end

return Prefab( "common/fx/quackering_wave", fn, assets)
