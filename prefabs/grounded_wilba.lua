local assets = 
{
    Asset("ANIM", "anim/wilba.zip"),
}

local prefabs = {}

local function sayrandom(inst, string_set)
	inst.components.talker:Say(string_set[math.random(1, #string_set)]) 
end

local function callGuards(inst, attacker, count)
    local x,y,z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, 30,{"guard_entrance"})
    if #ents > 0 then
        count = count or 1

        for i=1, count do
            inst:DoTaskInTime(i * math.random(), function()
                local guardprefab = "pigman_royalguard"
                local cityID = 1
                if inst:HasTag("city2") then 
                    guardprefab = "pigman_royalguard_2"
                    cityID = 2
                end
                local spawnpt = Vector3(ents[math.random(#ents)].Transform:GetWorldPosition() )
                local guard = SpawnPrefab(guardprefab)
                guard.components.citypossession:SetCity(cityID)
                guard.Transform:SetPosition(spawnpt.x,spawnpt.y,spawnpt.z)
                guard:PushEvent("attacked", {attacker = attacker, damage = 0, weapon = nil})
                if attacker then
                    attacker:AddTag("wanted_by_guards")
                end
            end)
        end
    end
end

local fn = function()
	local inst = CreateEntity()

    local trans = inst.entity:AddTransform()
    trans:SetFourFaced()

	inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()

	local anim = inst.entity:AddAnimState()
	anim:SetBank("wilson")
	anim:SetBuild("wilba")
	anim:Hide("ARM_carry")

	MakeCharacterPhysics(inst, 75, .5)
	inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.runspeed = TUNING.PIG_RUN_SPEED --5
    inst.components.locomotor.walkspeed = TUNING.PIG_WALK_SPEED --3

	local brain = require "brains/groundedwilbabrain"
    inst:SetBrain(brain)
    inst:SetStateGraph("SGgrounded_wilba")

    inst:AddComponent("talker")
    inst:AddComponent("trader")
    
    inst.components.trader:SetAcceptTest(function(inst, item) 
        if item.components.equippable then
            sayrandom(inst, STRINGS.GROUNDED_WILBA_REFUSE)
            return false
        end

        return true
    end)

    inst.components.trader.onaccept = function ()
    	sayrandom(inst, STRINGS.GROUNDED_WILBA_THANKS)
    end

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.WILBA_HEALTH)
    
    inst:AddComponent("combat")
    inst:ListenForEvent("attacked", function(_, data) callGuards(inst, data.attacker, 2) end)

	inst:AddTag("pigroyalty")

	local function IsUnlocked()
		if Profile:IsCharacterUnlocked("wilba") then
            inst:Remove()
        end
	end

	local function say_grounded()
		inst:DoTaskInTime(math.random(4, 10), function(_) 
			sayrandom(inst, STRINGS.GROUNDED_WILBA_TALK)
			say_grounded()
		end)
	end

	inst:ListenForEvent("exitlimbo", function(_) IsUnlocked() end)
	inst:DoTaskInTime(0.1, function(_) IsUnlocked() end)
	say_grounded()

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"meat", "pigskin"})

	return inst
end

return Prefab( "common/grounded_wilba", fn, assets, prefabs)