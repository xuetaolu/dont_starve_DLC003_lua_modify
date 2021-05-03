local assets=
{
	Asset("ANIM", "anim/silvernecklace.zip"),
    Asset("ANIM", "anim/torso_silvernecklace.zip"),
    Asset("MINIMAP_IMAGE", "silvernecklace"),
}


local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "torso_silvernecklace", "silvernecklace")
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
end


local function fn()
	local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)   

    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon( "silvernecklace.png" )

    MakeInventoryFloatable(inst, "silvernecklace_water", "silvernecklace")

    inst.AnimState:SetBank("silvernecklace")
    inst.AnimState:SetBuild("silvernecklace")
    inst.AnimState:PlayAnimation("silvernecklace")
    
    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )  

    inst:AddComponent("inspectable")
	
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )    
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/jewlery"

    inst:AddTag("irreplaceable")

    inst:ListenForEvent("ready_to_transform", function()
        inst.components.equippable.dapperness = -TUNING.DAPPERNESS_LARGE
    end, GetPlayer())

    inst:ListenForEvent("end_ready_to_transform", function()
        inst.components.equippable.dapperness = 0
    end, GetPlayer())


    inst:DoTaskInTime(0, function() if not GetPlayer() or GetPlayer().prefab ~= "wilba" then inst:Remove() end end)
    
    return inst
end

return Prefab( "common/inventory/silvernecklace", fn, assets)