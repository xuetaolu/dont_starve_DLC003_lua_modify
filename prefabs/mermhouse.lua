local assets =
{
	Asset("ANIM", "anim/merm_sw_house.zip"),
	Asset("MINIMAP_IMAGE", "mermhouse_tropical"),
	Asset("ANIM", "anim/pig_house.zip"),
}

local prefabs = 
{
	"merm",
	"collapse_big",
}

local sw_loot = 
{
    "boards",
    "rocks",
    "tropical_fish",
}

local base_loot = 
{
	"boards",
    "rocks",
    "fish",
}
        
local function onhammered(inst, worker)
	if inst:HasTag("fire") and inst.components.burnable then
        inst.components.burnable:Extinguish()
    end
    inst:RemoveComponent("childspawner")
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_big").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function onhit(inst, worker)
	if not inst:HasTag("burnt") then
	    if inst.components.childspawner then
	        inst.components.childspawner:ReleaseAllChildren(worker)
	    end
		inst.AnimState:PlayAnimation("hit")
		inst.AnimState:PushAnimation("idle")
	end
end

local function StartSpawning(inst)
	if not inst:HasTag("burnt") then
		if inst.components.childspawner and GetSeasonManager() and not GetSeasonManager():IsWinter() then
			inst.components.childspawner:StartSpawning()
		end
	end
end

local function StopSpawning(inst)
	if not inst:HasTag("burnt") then
		if inst.components.childspawner then
			inst.components.childspawner:StopSpawning()
		end
	end
end

local function OnSpawned(inst, child)
	if not inst:HasTag("burnt") then
		inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")
		if GetClock():IsDay() and inst.components.childspawner and inst.components.childspawner:CountChildrenOutside() >= 1 and not child.components.combat.target then
	        StopSpawning(inst)
	    end
	end
end

local function OnGoHome(inst, child) 
	if not inst:HasTag("burnt") then
		inst.SoundEmitter:PlaySound("dontstarve/common/pighouse_door")
		if inst.components.childspawner and inst.components.childspawner:CountChildrenOutside() < 1 then
	        StartSpawning(inst)
	    end
	end
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or inst:HasTag("fire") then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()


	local minimap = inst.entity:AddMiniMapEntity()
	inst:AddComponent("lootdropper")

	if SaveGameIndex and SaveGameIndex:IsModeShipwrecked() then
		minimap:SetIcon( "mermhouse_tropical.png" )
    	anim:SetBank("merm_sw_house")
    	anim:SetBuild("merm_sw_house")
    	inst.components.lootdropper:SetLoot(sw_loot)
    	anim:PlayAnimation("idle")
    else
    	minimap:SetIcon( "mermhouse.png" )
    	anim:SetBank("pig_house")
    	anim:SetBuild("pig_house")
    	inst.components.lootdropper:SetLoot(base_loot)
    	anim:PlayAnimation("rundown")
	end
    
    MakeObstaclePhysics(inst, 1)

    inst:AddTag("structure")
    inst:AddTag("mermhouse")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(2)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)
	
	inst:AddComponent("childspawner")
	inst.components.childspawner.childname = "merm"
	inst.components.childspawner:SetSpawnedFn(OnSpawned)
	inst.components.childspawner:SetGoHomeFn(OnGoHome)
	inst.components.childspawner:SetRegenPeriod(TUNING.TOTAL_DAY_TIME*4)
	inst.components.childspawner:SetSpawnPeriod(10)
	inst.components.childspawner:SetMaxChildren(4)

	inst:ListenForEvent("dusktime", function() 
		if not inst:HasTag("burnt") then
		    if GetSeasonManager() and not GetSeasonManager():IsWinter() then
			    inst.components.childspawner:ReleaseAllChildren()
			end
			StartSpawning(inst)
		end
	end, GetWorld())
	inst:ListenForEvent("daytime", function() StopSpawning(inst) end , GetWorld())
	StartSpawning(inst)

	MakeMediumBurnable(inst, nil, nil, true)
    MakeLargePropagator(inst)
    inst:ListenForEvent("onignite", function(inst)
        if inst.components.childspawner then
            inst.components.childspawner:ReleaseAllChildren()
        end
    end)
    inst:ListenForEvent("burntup", function(inst)
    	inst.AnimState:PlayAnimation("burnt")
    end)


    inst:AddComponent("inspectable")

	inst:AddComponent("named")
    inst.components.named:SetName(STRINGS.NAMES.MERMHOUSE["SW"])
	
	MakeSnowCovered(inst, .01)
    return inst
end

return Prefab( "common/objects/mermhouse", fn, assets, prefabs )  
