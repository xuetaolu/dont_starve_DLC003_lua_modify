local assets = 
{
	Asset("ANIM", "anim/snake_bone.zip")
}

local function onspoiledhammered(inst, worker)
    local to_hammer = (inst.components.stackable and inst.components.stackable:Get(1)) or inst
    if to_hammer == inst then
        to_hammer.components.inventoryitem:RemoveFromOwner(true)
    end
    if to_hammer:IsInLimbo() then
        to_hammer:ReturnToScene()
    end

    to_hammer.Transform:SetPosition(inst:GetPosition():Get())
    to_hammer.components.lootdropper:DropLoot()
    SpawnPrefab("collapse_small").Transform:SetPosition(to_hammer.Transform:GetWorldPosition())
    to_hammer.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")

    inst.components.workable:SetWorkLeft(1)
    
    to_hammer:Remove()
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)

    anim:SetBank("snake_bone")
    anim:SetBuild("snake_bone")
    anim:PlayAnimation("idle",false)

    MakeInventoryFloatable(inst, "idle_water", "idle")

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.atlasname = "images/inventoryimages.xml"

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({"boneshard", "boneshard"})

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(onspoiledhammered)

    inst:AddComponent("stackable")

    inst:AddComponent("edible")   
    inst.components.edible.foodtype = "BONE"

    inst:AddComponent("appeasement")
    inst.components.appeasement.appeasementvalue = TUNING.APPEASEMENT_TINY

    inst:AddComponent("floatable")
    inst.components.floatable:SetOnHitWaterFn(function(inst) inst.AnimState:PlayAnimation("idle_water", true) end)
    inst.components.floatable:SetOnHitLandFn(function(inst) inst.AnimState:PlayAnimation("idle", true) end)

	return inst
end

return Prefab("common/inventory/snake_bone", fn, assets)
