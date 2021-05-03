local prefabs = { "rocks" }

local assets = { Asset("ANIM", "anim/rock_antcave.zip") }

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    MakeObstaclePhysics(inst, .5)

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("rock_antcave.png")

	anim:SetBank("rock")
	anim:SetBuild("rock_antcave")
	anim:PlayAnimation("full", true)

    inst:AddTag("structure")

    ---------------------
    inst:AddComponent("inspectable")

    ---------------------  
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"rocks", "rocks", "rocks"})

    ---------------------
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(TUNING.ROCKS_MINE)

    inst.components.workable:SetOnWorkCallback(
        function(inst, worker, workleft)
            local pt = Point(inst.Transform:GetWorldPosition())
            if workleft <= 0 then
                inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")
                inst.components.lootdropper:DropLoot(pt)
                inst:Remove()
            else
                if workleft < TUNING.ROCKS_MINE*(1/3) then
                    inst.AnimState:PlayAnimation("low")
                elseif workleft < TUNING.ROCKS_MINE*(2/3) then
                    inst.AnimState:PlayAnimation("med")
                else
                    inst.AnimState:PlayAnimation("full")
                end
            end
        end)

	return inst
end

return Prefab("anthill/items/rock_antcave", fn, assets, prefabs) 

