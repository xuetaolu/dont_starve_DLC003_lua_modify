local assets =
{
	Asset("ANIM", "anim/antman_basic.zip"),
	Asset("ANIM", "anim/antman_attacks.zip"),
	Asset("ANIM", "anim/antman_actions.zip"),
    Asset("ANIM", "anim/antman_egghatch.zip"),
    Asset("ANIM", "anim/antman_guard_build.zip"),

    Asset("ANIM", "anim/antman_translucent_build.zip"),
}

local function dohatch(inst, hatch_time)
	inst.updatetask = inst:DoTaskInTime(hatch_time, function()
		
		if not inst.inlimbo then
			inst.AnimState:PlayAnimation("hatch")
			inst.components.health:SetInvincible(true)
			
			inst.updatetask = inst:DoTaskInTime(11 * FRAMES, 
				function()
					if not inst.inlimbo then
						ChangeToInventoryPhysics(inst)
						local warrior = SpawnPrefab("antman_warrior")
						warrior.Transform:SetPosition(  inst.Transform:GetWorldPosition() )
						warrior.sg:GoToState("hatch")

						-- re-register us with the childspawner and interior
						ReplaceEntity(inst, warrior)

						local aporkalypse = GetAporkalypse()

						if inst.queen then
							warrior.queen = inst.queen
						elseif aporkalypse and aporkalypse:IsActive() then
							warrior:AddTag("aporkalypse_cleanup")
						end

						warrior.components.combat:SetTarget(GetPlayer())

						if warrior.queen then
							warrior:ListenForEvent("death", function(warrior, data) 
								warrior.queen:WarriorKilled()
							end)
						end
					end
				end
			)
		end
	end)
end

local function ground_detection(inst)
	local pos = inst:GetPosition()

	if pos.y <= 0.2 then

		ChangeToObstaclePhysics(inst)
		inst.AnimState:PlayAnimation("land", false)
		inst.AnimState:PushAnimation("idle", true)

		if inst.updatetask then
			inst.updatetask:Cancel()
			inst.updatetask = nil
		end

		dohatch(inst, math.random(2, 6))
	end
end

local function start_grounddetection(inst)
	inst.updatetask = inst:DoPeriodicTask(FRAMES, ground_detection)
end

local function onremove(inst)
	GetWorld():RemoveEventCallback("doorused", inst.ondoorused)
	
	if inst.updatetask then
		inst.updatetask:Cancel()
		inst.updatetask = nil
	end
end

local function OnSave(inst, data)
	if inst.queen then
		data.queen_guid = inst.queen.GUID
	end
end

local function OnLoadPostPass(inst, ents, data)
    if data.queen_guid and ents[data.queen_guid] then
        local queen = ents[data.queen_guid].entity
        queen.WarriorKilled()
    end

	inst:Remove()
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	
	inst.AnimState:SetRayTestOnBB(true);
	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("antman_egg")
	inst.AnimState:SetBuild("antman_guard_build")
	inst.AnimState:AddOverrideBuild("antman_egghatch")

	inst.AnimState:PlayAnimation("flying", true)

	inst:AddComponent("inspectable")
	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(200)
	
	inst:AddComponent("combat")
	inst.components.combat:SetOnHit(function()
		if inst.components.health:IsDead() then
			inst.AnimState:PlayAnimation("break")
			inst.queen:WarriorKilled()
			onremove(inst)
		elseif not inst.components.health:IsInvincible() then
			inst.AnimState:PlayAnimation("hit", false)
		end
	end)

	inst.OnRemoveEntity = onremove
	inst.Transform:SetScale(1.15, 1.15, 1.15)

	inst:ListenForEvent("animover", function (inst) 
		if inst.AnimState:IsCurrentAnimation("hatch") then
			inst:Remove()
		end
	end)

	local function ondoorused( world , data)
		if data.from_door.components.door.target_interior == "FINAL_QUEEN_CHAMBER" then
			dohatch(inst, math.random(2, 4))
		else
			onremove(inst)
		end
	end

	inst.ondoorused = ondoorused
	GetWorld():ListenForEvent("doorused", inst.ondoorused)

	inst.start_grounddetection = start_grounddetection
	inst.eggify = function (inst)
		inst.AnimState:PlayAnimation("eggify", false)
		inst.AnimState:PushAnimation("idle", false)
		dohatch(inst, 1)
	end

	inst.OnSave = OnSave
	inst.OnLoadPostPass = OnLoadPostPass

	return inst
end

return Prefab("common/inventory/antman_warrior_egg", fn, assets)