local assets =
{
    Asset("ANIM", "anim/hound_base.zip"),
	Asset("SOUND", "sound/hound.fsb"),
    Asset("MINIMAP_IMAGE", "hound_mound"),
}

local prefabs =
{
    "hound",
    "firehound",
    "icehound",
    "crocodog",
    "poisoncrocodog",
    "watercrocodog",    
    "houndstooth",
    "boneshard"
}

SetSharedLootTable( 'hound_mound',
{
    {'houndstooth', 1.00},
    {'houndstooth', 1.00},
    {'houndstooth', 1.00},
    {'boneshard',   1.00},
    {'boneshard',   1.00},
    {'redgem',      0.01},
    {'bluegem',     0.01},
})

local function GetSpecialHoundChance()
	local day = GetClock().numcycles
	local chance = 0
	for k,v in ipairs(TUNING.HOUND_SPECIAL_CHANCE) do
	    if day > v.minday then
	        chance = v.chance
	    elseif day <= v.minday then
	        return chance
	    end
	end
    return chance
end

local function SpawnGuardHound(inst, attacker)

    local prefab = "hound"
    if SaveGameIndex:IsModeShipwrecked() then
        prefab = "crocodog"
    end

    if math.random() < GetSpecialHoundChance() then
        if GetSeasonManager():IsWinter() or GetSeasonManager():IsSpring() then
            prefab = "icehound"
        elseif GetSeasonManager():IsGreenSeason() or GetSeasonManager():IsWetSeason() then
            prefab = "watercrocodog"
        else
            if SaveGameIndex:IsModeShipwrecked() then
                prefab = "poisoncrocodog"
            else
	           prefab = "firehound"
            end
	    end
	end
    local defender = inst.components.childspawner:SpawnChild(attacker, prefab)
    if defender and attacker and defender.components.combat then
        defender.components.combat:SetTarget(attacker)
        defender.components.combat:BlankOutAttacks(1.5 + math.random()*2)
    end
end

local function SpawnGuards(inst)
    if not inst.components.health:IsDead() and inst.components.childspawner then
        local num_to_release = math.min(3, inst.components.childspawner.childreninside)
        for k = 1,num_to_release do
            SpawnGuardHound(inst)
        end
    end
end

local function SpawnAllGuards(inst, attacker)
    if not inst.components.health:IsDead() and inst.components.childspawner then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle", false)
        local num_to_release = inst.components.childspawner.childreninside
        for k = 1,num_to_release do
            SpawnGuardHound(inst)
        end
    end
end

local function OnKilled(inst)
    if inst.components.childspawner then
        inst.components.childspawner:ReleaseAllChildren()
    end
    inst.AnimState:PlayAnimation("death", false)
    inst.SoundEmitter:KillSound("loop")
    inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
end

local function OnEntityWake(inst)
    inst.components.childspawner:StartSpawning()
    inst.SoundEmitter:PlaySound("dontstarve/creatures/hound/mound_LP", "loop")
end

local function OnEntitySleep(inst)
	inst.SoundEmitter:KillSound("loop")
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

    inst.entity:AddSoundEmitter()

    MakeObstaclePhysics(inst, .5)

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "hound_mound.png" )

	anim:SetBank("houndbase")
	anim:SetBuild("hound_base")
	anim:PlayAnimation("idle")

    inst:AddTag("structure")
    inst:AddTag("houndmound")

    -------------------
	inst:AddComponent("health")
    inst.components.health:SetMaxHealth(300)

    inst:ListenForEvent("death", OnKilled)

    -------------------
    local child =  "hound"    
    if SaveGameIndex:IsModeShipwrecked() then
        child = "crocodog"
    end
	inst:AddComponent("childspawner")
	inst.components.childspawner.childname = child
	inst.components.childspawner:SetRegenPeriod(TUNING.HOUNDMOUND_REGEN_TIME)
	inst.components.childspawner:SetSpawnPeriod(TUNING.HOUNDMOUND_RELEASE_TIME)

	inst.components.childspawner:SetMaxChildren(math.random(TUNING.HOUNDMOUND_HOUNDS_MIN, TUNING.HOUNDMOUND_HOUNDS_MAX))

    inst:ListenForEvent("seasonChange", function(it, data) 
        if data.season == SEASONS.DRY then
            inst.components.childspawner:SetRareChild("poisoncrocodog", 0.2)        
        elseif data.season == SEASONS.SUMMER then
            inst.components.childspawner:SetRareChild("firehound", 0.2)
        elseif SaveGameIndex:IsModeShipwrecked() then
            inst.components.childspawner:SetRareChild("crocodog", 0)
        else
            inst.components.childspawner:SetRareChild("firehound", 0)
        end
    end, GetWorld())
 
    ---------------------
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('hound_mound')

    inst:AddComponent("combat")
    inst.components.combat:SetOnHit(SpawnAllGuards)


    ---------------------
    inst:AddComponent("inspectable")
	inst.OnEntitySleep = OnEntitySleep
	inst.OnEntityWake = OnEntityWake
	MakeSnowCovered(inst)
    
	return inst
end

return Prefab( "forest/monsters/houndmound", fn, assets, prefabs ) 

