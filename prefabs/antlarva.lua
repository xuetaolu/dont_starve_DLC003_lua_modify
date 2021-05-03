require "stategraphs/SGantlarva"

local assets = 
{
	Asset("ANIM", "anim/ant_larva.zip"),
}

local prefabs = 
{
}



local function spawnant(inst)
	local ant = SpawnPrefab("antman")
	local pt = inst:GetPosition()
	ant.Transform:SetPosition(pt.x, pt.y, pt.z)	
end

local function OnHit(inst, dist)
	inst.sg:GoToState("land")
end

local function larava_fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()

    local physics = inst.entity:AddPhysics()
    physics:SetMass(1)
    physics:SetCapsule(0.2, 0.2)
    inst.Physics:SetFriction(10)
    inst.Physics:SetDamping(5)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(GetWorldCollision())
    inst.Physics:CollidesWith(COLLISION.INTWALL)

	anim:SetBank("ant_larva")
	anim:SetBuild("ant_larva")

    inst.persists = false

	inst:AddComponent("locomotor")
	inst:AddComponent("complexprojectile")
	inst.components.complexprojectile:SetOnHit(OnHit)
	inst.components.complexprojectile.yOffset = 2.5

	inst.SpawnAnt = spawnant

	inst:SetStateGraph("SGantlarva")

	return inst
end
require "prefabutil"
return Prefab("antlarva", larava_fn, assets)