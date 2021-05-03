local assets =
{
	--Also uses player animations but these should always be loaded with the player.
	Asset("ANIM", "anim/woodlegs.zip"),
}

local function UnlockWoodlegs(inst)
	--Character is unlocked the second the final key is put in so he will be unlocked already @ this point.
	inst.persists = false

	inst:DoTaskInTime(2, function()
		inst.AnimState:PlayAnimation("wakeup")
		inst.AnimState:PushAnimation("idle")
		inst.AnimState:PushAnimation("idle")
		inst.AnimState:PushAnimation("idle", false)

		local celebratefn = nil
		celebratefn = function()
			inst:RemoveEventCallback("animqueueover", celebratefn)
			inst.AnimState:PlayAnimation("research")			
			inst:DoTaskInTime(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/heelclick") end)
			inst:DoTaskInTime(21*FRAMES, function(inst)	inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/heelclick") end)
			inst:DoTaskInTime(32*FRAMES, function(inst)
				local smoke = SpawnPrefab("small_puff")
				smoke.Transform:SetPosition(inst:GetPosition():Get())
				smoke.Transform:SetScale(2,2,2)
				inst:Remove()
			end)
		end

		inst:ListenForEvent("animqueueover", celebratefn)
	end)

	inst:DoPeriodicTask(FRAMES, function()
		--Look @ the camera
 		local down = TheCamera:GetDownVec()
        local angle = math.atan2(down.z, down.x)*RADIANS
        inst.Transform:SetRotation(-angle)
	end)
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("woodlegs.png")

	MakeObstaclePhysics(inst, 1.5)

	inst.Transform:SetFourFaced()

	inst.AnimState:SetBank("wilson")
	inst.AnimState:SetBuild("woodlegs")
	inst.AnimState:PlayAnimation("sleep", true)

	inst.AnimState:Hide("ARM_carry")
	inst.AnimState:Hide("hat")
	inst.AnimState:Hide("hat_hair")
	inst.AnimState:Hide("PROPDROP")

	UnlockWoodlegs(inst)
	
	return inst
end

return Prefab("woodlegs_unlock", fn, assets)