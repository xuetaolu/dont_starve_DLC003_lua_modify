local assets =
{
	--Also uses player animations but these should always be loaded with the player.
	Asset("ANIM", "anim/wilbur.zip"),
	Asset("ANIM", "anim/wilbur_nocrown.zip"),
	Asset("ANIM", "anim/crown_wilbur.zip"),
	Asset("ANIM", "anim/wilbur_raft_build.zip"),
}

local prefabs =
{
	"wilbur_crown"
}

local function UnlockWilbur(inst)
	--Give player wilbur access
	local player = GetPlayer()
	player.profile:UnlockCharacter("wilbur")
	player.profile.dirty = true
	player.profile:Save()

	inst.persists = false

	inst.SoundEmitter:PlaySound("dontstarve_DLC002/characters/wilbur/wilbur_reveal")

	inst.AnimState:SetBuild("wilbur")

	inst.AnimState:PlayAnimation("wakeup")
	inst.AnimState:PushAnimation("idle")
	inst.AnimState:PushAnimation("idle")
	inst.AnimState:PushAnimation("idle", false)

	local drownfn = nil
	drownfn = function()
		inst:RemoveEventCallback("animqueueover", drownfn)
		inst.AnimState:PlayAnimation("research")
		
		inst:DoTaskInTime(13*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/heelclick") end)
		inst:DoTaskInTime(21*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/heelclick") end)

		inst:DoTaskInTime(32*FRAMES, function()
			inst.AnimState:PlayAnimation("boat_death", false)

            local death_fx = SpawnPrefab("boat_death")
            death_fx.Transform:SetPosition(inst:GetPosition():Get())
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/characters/wilbur/sinking_death")
			inst:DoTaskInTime(50*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/boat_sinking_shadow") end)
			inst:ListenForEvent("animover", inst.Remove)
		end)
	end

	inst:ListenForEvent("animqueueover", drownfn)

	inst:DoPeriodicTask(FRAMES, function()
		--Look @ the camera
 		local down = TheCamera:GetDownVec()
        local angle = math.atan2(down.z, down.x)*RADIANS
        inst.Transform:SetRotation(-angle)
	end)
end

local function ShouldAccept(inst, item, giver)
	--Only if the item is the crown
	return item.prefab == "wilbur_crown"
end

local function OnAccept(inst, giver, item)
	if item.prefab == "wilbur_crown" then
		UnlockWilbur(inst)
	end
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("wilbur.png")

	MakeObstaclePhysics(inst, 1.5)

	inst.Transform:SetFourFaced()

	inst.AnimState:SetBank("wilson")
	inst.AnimState:SetBuild("wilbur_nocrown")
	inst.AnimState:PlayAnimation("sleep", true)

	inst.AnimState:Hide("ARM_carry")
	inst.AnimState:Hide("hat")
	inst.AnimState:Hide("hat_hair")
	inst.AnimState:Hide("PROPDROP")

	inst.AnimState:OverrideSymbol("fx_wipe", "wilson_fx", "fx_wipe")
	inst.AnimState:OverrideSymbol("fx_liquid", "wilson_fx", "fx_liquid")
	inst.AnimState:OverrideSymbol("shadow_hands", "shadow_hands", "shadow_hands")

	inst.AnimState:OverrideSymbol("ripplebase", "player_boat_death", "ripplebase")
	inst.AnimState:OverrideSymbol("waterline", "player_boat_death", "waterline")
	inst.AnimState:OverrideSymbol("waterline", "player_boat_death", "waterline")

	inst:AddComponent("inspectable")

	inst:AddComponent("trader")
	inst.components.trader:SetAcceptTest(ShouldAccept)
	inst.components.trader.onaccept = OnAccept

 	inst.AnimState:AddOverrideBuild("wilbur_raft_build")
    inst.AnimState:OverrideSymbol("flotsam", "flotsam_lograft_build", "flotsam")

	return inst
end

local function crownfn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()


	inst.AnimState:SetBank("crown_wilbur")
	inst.AnimState:SetBuild("crown_wilbur")
	inst.AnimState:PlayAnimation("idle")

	MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "idle_water", "idle")
    MakeBlowInHurricane(inst, TUNING.WINDBLOWN_SCALE_MIN.HEAVY, TUNING.WINDBLOWN_SCALE_MAX.HEAVY)

	inst:AddComponent("inspectable")
	inst:AddComponent("inventoryitem")

    inst:AddComponent("tradable")

    inst:AddTag("wilbur_crown")

	return inst
end

local function markerfn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	return inst
end

return Prefab("wilbur_unlock", fn, assets, prefabs),
Prefab("wilbur_crown", crownfn, assets),
Prefab("wilbur_unlock_marker", markerfn)