local assets=
{
	Asset("ANIM", "anim/bat_leather.zip"),
    Asset("INV_IMAGE", "bat_leather"),
}

local function fn(Sim)
	local inst = CreateEntity()
    
    local newinst = SpawnPrefab("pigskin")
    newinst.name = STRINGS.NAMES.BAT_HIDE
    newinst.components.inventoryitem:ChangeImageName("bat_leather")
    newinst.AnimState:SetBank("bat_leather")
    newinst.AnimState:SetBuild("bat_leather")

    newinst.imagenameoverride = "bat_leather"
    newinst.animbankoverride = "bat_leather"
    newinst.animbuildoverride = "bat_leather"
    newinst.nameoverride = "BAT_HIDE"

    inst:Remove()

    return newinst
end

return Prefab( "common/inventory/bat_hide", fn, assets) 
