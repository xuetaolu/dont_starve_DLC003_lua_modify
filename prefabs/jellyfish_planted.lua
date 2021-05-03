local assets=
{
	Asset("ANIM", "anim/jellyfish.zip"),
}

local prefabs=
{
	"jellyfish_dead",
}

local function OnWorked(inst, worker)
    if worker.components.inventory then
        local toGive = SpawnPrefab("jellyfish")
        worker.components.inventory:GiveItem(toGive, nil, Vector3(TheSim:GetScreenPos(inst.Transform:GetWorldPosition())))
        worker.SoundEmitter:PlaySound("dontstarve_DLC002/common/bugnet_inwater")
    end
    inst:Remove()
end

local function onattacked(inst, data)
    if data.attacker.components.health then
        if (data.weapon == nil or (not data.weapon:HasTag("projectile") and data.weapon.projectile == nil)) 
        and (data.attacker ~= GetPlayer() or (data.attacker == GetPlayer() and not GetPlayer().components.inventory:IsInsulated())) then
			data.attacker.components.health:DoDelta(-TUNING.JELLYFISH_DAMAGE)
            if data.attacker == GetPlayer() then
                data.attacker.sg:GoToState("electrocute")
            end
        end
    end
end

local brain = require "brains/jellyfishbrain"
local function fn(Sim)
	local inst = CreateEntity()
    inst:AddTag("aquatic")
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    local physics = inst.entity:AddPhysics()
    MakeCharacterPhysics(inst, 1, 0.5)
    inst.Transform:SetFourFaced()

    inst.AnimState:SetBank("jellyfish")
    inst.AnimState:SetBuild("jellyfish")  
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("seacreature")

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = TUNING.JELLYFISH_WALK_SPEED

    inst:SetStateGraph("SGjellyfish")
    --inst.AnimState:SetRayTestOnBB(true);

    inst.AnimState:SetLayer( LAYER_BACKGROUND )
    inst.AnimState:SetSortOrder( 3 )

    inst:SetBrain(brain)

    inst:AddComponent("combat")
    inst.components.combat:SetHurtSound("dontstarve_DLC002/creatures/jellyfish/hit")
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.JELLYFISH_HEALTH)

    MakeMediumFreezableCharacter(inst, "jelly")

    inst:ListenForEvent("attacked", onattacked)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"jellyfish_dead"}) 

    inst:AddComponent("inspectable")
    inst:AddComponent("knownlocations")
    inst:AddComponent("sleeper")
    inst.components.sleeper.onlysleepsfromitems = true 
    
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.NET)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(OnWorked)
	--MakeSmallBurnable(inst)
    --MakeSmallPropagator(inst)

    return inst
end

return Prefab( "common/inventory/jellyfish_planted", fn, assets, prefabs) 
