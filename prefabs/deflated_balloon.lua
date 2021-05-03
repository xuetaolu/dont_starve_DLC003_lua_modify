--Should be empty during winter.

local assets =
{
    Asset("ANIM", "anim/balloon_wreckage.zip"),
    Asset("ANIM", "anim/trinkets_giftshop.zip"),
    Asset("MINIMAP_IMAGE", "balloon_wreckage"), 
    Asset("INV_IMAGE", "trinket_giftshop_4"),    
}

SetSharedLootTable('deflated_balloon_basket',
{
    {'boards',                1.00},
    {'trinket_giftshop_4',    1.00},
})

SetSharedLootTable( 'deflated_balloon',
{
    {'rope',                1.00},
    {'rope',                1.00},    
    {'cutgrass',            1.00},
    {'cutgrass',            1.00},
})


local function onhammered(inst, worker)
    if inst:HasTag("fire") and inst.components.burnable then
        inst.components.burnable:Extinguish()
    end    
    inst.components.lootdropper:DropLoot()
    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
    inst:Remove()
end

local function OnSave(inst, data)
 
end

local function OnLoad(inst, data)
    
end


local function basketfn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    local minimap = inst.entity:AddMiniMapEntity()

    minimap:SetIcon("balloon_wreckage.png")

    MakeObstaclePhysics(inst, 1.0, 1)

    inst.AnimState:SetBank("balloon_wreckage")
    inst.AnimState:SetBuild("balloon_wreckage")
    inst.AnimState:PlayAnimation("basket", true)

    inst:AddTag("structure")

    inst:AddComponent("inspectable")
	--inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('deflated_balloon_basket')

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(onhammered)

    inst.OnLoad = OnLoad
    inst.OnSave = OnSave

    return inst
end

local function balloonfn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    local minimap = inst.entity:AddMiniMapEntity()

    minimap:SetIcon("balloon_wreckage.png")

    MakeObstaclePhysics(inst, 1.0, 1)

    inst.AnimState:SetBank("balloon_wreckage")
    inst.AnimState:SetBuild("balloon_wreckage")
    inst.AnimState:PlayAnimation("balloon", true)

    inst:AddTag("structure")

    inst:AddComponent("inspectable")
    --inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('deflated_balloon')

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(onhammered)

    inst.OnLoad = OnLoad
    inst.OnSave = OnSave

    return inst
end

local function trinketfn(Sim)
    local inst = CreateEntity()
    
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("trinkets_giftshop")
    inst.AnimState:SetBuild("trinkets_giftshop")
    inst.AnimState:PlayAnimation(4)
    
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddTag("trinket")

    return inst
end

return Prefab("deflated_balloon_basket", basketfn, assets),
       Prefab("deflated_balloon", balloonfn, assets),
       Prefab("trinket_giftshop_4", trinketfn, assets)
