local assets=
{
	Asset("ANIM", "anim/quackering_charge_fx.zip")
}

local function fn(Sim)

	local inst = CreateEntity()
	inst.persists = false

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

    inst.entity:AddTransform()
	inst.entity:AddAnimState()

    inst.AnimState:SetBank("quackering_charge_fx")
    inst.AnimState:SetBuild("quackering_charge_fx")
    inst.AnimState:PlayAnimation("down_loop_FX")

	inst.lastDirection = -1

	inst.ChangeDirection = function(self, newDirection)

		-- starting up
		if self.lastDirection == -1 then
			if newDirection == 0 then
				self.AnimState:PlayAnimation("right_pre_FX")
				self.AnimState:PushAnimation("right_loop_FX", true)
			elseif newDirection == 1 then
				self.AnimState:PlayAnimation("up_pre_FX")
				self.AnimState:PushAnimation("up_loop_FX", true)
			elseif newDirection == 2 then
				self.AnimState:PlayAnimation("left_pre_FX")
				self.AnimState:PushAnimation("left_loop_FX", true)
			elseif newDirection == 3 then
				self.AnimState:PlayAnimation("down_pre_FX")
				self.AnimState:PushAnimation("down_loop_FX", true)
			end
		-- was running, changing direction
		elseif newDirection ~= self.lastDirection then
			if newDirection == 0 then
				self.AnimState:PlayAnimation("right_loop_FX", true)
			elseif newDirection == 1 then
				self.AnimState:PlayAnimation("up_loop_FX", true)
			elseif newDirection == 2 then
				self.AnimState:PlayAnimation("left_loop_FX", true)
			elseif newDirection == 3 then
				self.AnimState:PlayAnimation("down_loop_FX", true)
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

return Prefab( "common/inventory/quackering_charge_fx", fn, assets)
