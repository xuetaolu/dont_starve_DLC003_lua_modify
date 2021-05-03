local assets =
{
	Asset("ANIM", "anim/fish_dogfish.zip"),
}

local prefabs =
{
	"fish_med"
}

local brain = require "brains/solofishbrain"

local function SetLocoState(inst, state)
    --"above" or "below"
    inst.LocoState = string.lower(state)
end

local function IsLocoState(inst, state)
    return inst.LocoState == string.lower(state)
end

local function solofishfn()

	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	inst:AddTag("aquatic")
    inst:AddTag("seacreature")
	local anim = inst.entity:AddAnimState()

	MakePoisonableCharacter(inst)
    MakeCharacterPhysics(inst, 1, 0.5)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(GetWorldCollision())
    inst.entity:AddSoundEmitter()

	inst:AddComponent("locomotor")
	inst.components.locomotor.walkspeed = TUNING.SOLOFISH_WALK_SPEED
	inst.components.locomotor.runspeed = TUNING.SOLOFISH_RUN_SPEED

    inst.AnimState:SetBank("dogfish")
    inst.AnimState:SetBuild("fish_dogfish")
    inst.AnimState:PlayAnimation("shadow", true)
    anim:SetRayTestOnBB(true)
    anim:SetOrientation( ANIM_ORIENTATION.OnGround )

	anim:SetLayer( LAYER_BACKGROUND )
	anim:SetSortOrder( 3 )

    inst:AddComponent("inspectable")
    inst.no_wet_prefix = true

	inst:AddComponent("knownlocations")

	inst:AddComponent("combat")
    --inst.components.combat.hiteffectsymbol = "chest"
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.SOLOFISH_HEALTH)

    inst:AddComponent("eater")
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"fish_med"})

    inst:AddComponent("sleeper")
    inst.components.sleeper.onlysleepsfromitems = true 
    MakeMediumFreezableCharacter(inst, "dogfish_body")

    SetLocoState(inst, "below")
    inst.SetLocoState = SetLocoState
    inst.IsLocoState = IsLocoState

    inst:SetStateGraph("SGsolofish")

    inst:SetBrain(brain)

	return inst
end

return Prefab( "ocean/objects/solofish", solofishfn, assets, prefabs)
