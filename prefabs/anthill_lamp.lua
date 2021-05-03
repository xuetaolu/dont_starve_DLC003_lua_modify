local prefabs = 
{
}

local assets =
{
    Asset("ANIM", "anim/ant_cave_lantern.zip"),
}

local function fn(Sim)
	local inst  = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim  = inst.entity:AddAnimState()
    local light = inst.entity:AddLight()
    inst.entity:AddSoundEmitter()

    MakeObstaclePhysics(inst, 0.5)

    light:SetFalloff(0.4)
    light:SetIntensity(0.8)
    light:SetRadius(2.5)
    light:SetColour(180/255, 195/255, 150/255)

    light:Enable(true)

	local minimap = inst.entity:AddMiniMapEntity()
	minimap:SetIcon("ant_cave_lantern.png")

	anim:SetBank("ant_cave_lantern")
	anim:SetBuild("ant_cave_lantern")
	anim:PlayAnimation("idle", true)

    inst:AddComponent("inspectable")

    ---------------------  
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"honey", "honey", "honey"})

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.MINE)
    inst.components.workable:SetWorkLeft(TUNING.HONEY_LANTERN_MINE)

    inst.components.workable:SetOnWorkCallback(
        function(inst, worker, workleft)
            local pt = Point(inst.Transform:GetWorldPosition())
            if workleft <= 0 then
                inst.SoundEmitter:PlaySound("dontstarve/wilson/rock_break")
                inst.components.lootdropper:DropLoot(pt)
                inst:Remove()
            else
                if workleft < TUNING.HONEY_LANTERN_MINE*(1/3) then
                    inst.AnimState:PlayAnimation("break")
                elseif workleft < TUNING.HONEY_LANTERN_MINE*(2/3) then
                    inst.AnimState:PlayAnimation("hit")
                else
                    inst.AnimState:PlayAnimation("idle")
                end
            end
        end)

    local aporkalypse = GetAporkalypse()

    inst:ListenForEvent("beginaporkalypse", function() inst.Light:Enable(false) end, GetWorld())
    inst:ListenForEvent("endaporkalypse", function() inst.Light:Enable(true) end, GetWorld())
    inst:ListenForEvent("exitlimbo", function(inst) inst.Light:Enable(not (aporkalypse and aporkalypse:IsActive())) end)

    inst.Light:Enable(not (aporkalypse and aporkalypse:IsActive()))

	return inst
end

return Prefab("anthill/items/ant_cave_lantern", fn, assets, prefabs) 
