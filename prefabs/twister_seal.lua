local assets =
{
    Asset("ANIM", "anim/twister_seal.zip"),
}

local prefabs = {}

SetSharedLootTable('twister_seal',
{
	{'meat', 1.00},	
	{'meat', 1.00},	
	{'meat', 1.00},	
	{'meat', 1.00},
	{'magic_seal', 1.00},
	--Drop an item here too?
})

local function OnEntitySleep(inst)
	--This means the player let the seal live.
	--Let the seal escape & leave a gift of some sort behind.
	local seal = SpawnPrefab("magic_seal")
	seal.Transform:SetPosition(inst:GetPosition():Get())
	inst:Remove()
end

local function fn()
    local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize(2.5, 1.5)

	MakePoisonableCharacter(inst)
	MakeCharacterPhysics(inst, 1000, 1)

	inst.Transform:SetTwoFaced()

	anim:SetBank('twister')
	anim:SetBuild('twister_build')
	anim:PlayAnimation('seal_idle', true)

	inst:AddComponent("inspectable")

	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetChanceLootTable('twister_seal')

	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(TUNING.TWISTER_SEAL_HEALTH)

	inst:AddComponent("combat")

	inst:SetStateGraph("SGtwister_seal")
    local brain = require("brains/twistersealbrain")
    inst:SetBrain(brain)

    inst:DoTaskInTime(1*FRAMES, function()
    	inst:ListenForEvent("entitysleep", OnEntitySleep)
    end)

	return inst
end

return Prefab("twister_seal", fn, assets, prefabs)
