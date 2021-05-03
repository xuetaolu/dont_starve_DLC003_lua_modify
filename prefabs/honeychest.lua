local prefabs = 
{
	"bee",
	"killerbee",
    "honey",
    "honeycomb",
}

local assets =
{
    Asset("ANIM", "anim/ant_chest.zip"),
	-- Asset("SOUND", "sound/bee.fsb"),
}


local function OnEntityWake(inst)
    -- inst.SoundEmitter:PlaySound("dontstarve/bee/bee_hive_LP", "loop")
end

local function OnEntitySleep(inst)
	-- inst.SoundEmitter:KillSound("loop")
end

local function OnIgnite(inst)
    if inst.components.childspawner then
        inst.components.childspawner:ReleaseAllChildren()
        inst:RemoveComponent("childspawner")
    end
    inst.SoundEmitter:KillSound("loop")
    DefaultBurnFn(inst)
end

local function OnFreeze(inst)
    print(inst, "OnFreeze")
    inst.SoundEmitter:PlaySound("dontstarve/common/freezecreature")
    inst.AnimState:PlayAnimation("frozen", true)
    inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
end

local function OnThaw(inst)
    print(inst, "OnThaw")
    inst.AnimState:PlayAnimation("frozen_loop_pst", true)
    inst.SoundEmitter:PlaySound("dontstarve/common/freezethaw", "thawing")
    inst.AnimState:OverrideSymbol("swap_frozen", "frozen", "frozen")
end

local function OnUnFreeze(inst)
    print(inst, "OnUnFreeze")
    inst.AnimState:PlayAnimation("cocoon_small", true)
    inst.SoundEmitter:KillSound("thawing")
    inst.AnimState:ClearOverrideSymbol("swap_frozen")
end

local function OnKilled(inst)
    inst:RemoveComponent("childspawner")
    inst.AnimState:PlayAnimation("cocoon_dead", true)
    inst.Physics:ClearCollisionMask()
    
    inst.SoundEmitter:KillSound("loop")
    
    inst.SoundEmitter:PlaySound("dontstarve/bee/beehive_destroy")
    inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
end


local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    MakeObstaclePhysics(inst, .5)

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon( "beehive.png" )

	anim:SetBank("beehive")
	anim:SetBuild("beehive")
	anim:PlayAnimation("cocoon_small", true)

    inst:AddTag("structure")
	inst:AddTag("hive")
    inst:AddTag("honeychest")

    ---------------------  
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"honey", "honey", "honey", "honeycomb"})

    ---------------------        
    MakeLargeBurnable(inst)
    inst.components.burnable:SetOnIgniteFn(OnIgnite)

    ---------------------
    MakeMediumFreezableCharacter(inst)
    inst:ListenForEvent("freeze", OnFreeze)
    inst:ListenForEvent("onthaw", OnThaw)
    inst:ListenForEvent("unfreeze", OnUnFreeze)

    ---------------------
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(TUNING.HONEY_CHEST_MINE)

    inst.components.workable:SetOnWorkCallback(
        function(inst, worker, workleft)
            local pt = Point(inst.Transform:GetWorldPosition())
            if workleft <= 0 then
                inst.SoundEmitter:PlaySound("dontstarve/bee/beehive_hit")
                inst.components.lootdropper:DropLoot(pt)
                inst:Remove()
            else
                if workleft < TUNING.HONEY_CHEST_MINE*(1/3) then
                    inst.AnimState:PlayAnimation("open")
                    inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/objects/honey_chest/open")
                elseif workleft < TUNING.HONEY_CHEST_MINE*(2/3) then
                    inst.AnimState:PlayAnimation("hit")
                else
                    inst.AnimState:PlayAnimation("close")
                    inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/objects/honey_chest/close")
                end
            end
        end)

    ---------------------       
    MakeLargePropagator(inst)
    MakeSnowCovered(inst)

    ---------------------
    inst:AddComponent("inspectable")

	inst.OnEntitySleep = OnEntitySleep
	inst.OnEntityWake = OnEntityWake

	return inst
end

return Prefab("anthill/items/honeychest", fn, assets, prefabs) 

