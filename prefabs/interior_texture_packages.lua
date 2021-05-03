local assets =
{
    Asset("INV_IMAGE", "interior_floor_marble"),
    Asset("INV_IMAGE", "interior_floor_check"),
    Asset("INV_IMAGE", "interior_floor_plaid_tile"),
    Asset("INV_IMAGE", "interior_floor_sheet_metal"),
    Asset("INV_IMAGE", "interior_floor_wood"),
    Asset("INV_IMAGE", "interior_wall_wood"),
    Asset("INV_IMAGE", "interior_wall_checkered"),
    Asset("INV_IMAGE", "interior_wall_floral"),
    Asset("INV_IMAGE", "interior_wall_sunflower"),
    Asset("INV_IMAGE", "interior_wall_harlequin"),                
}

local prefabs =
{

}

local FACE = {
    WALL = 1,
    FLOOR = 2,
}

local function paint(inst,face,texture)

    local interiorSpawner = GetWorld().components.interiorspawner
    if interiorSpawner.current_interior then
        if face == FACE.FLOOR then
            interiorSpawner.current_interior.floortexture = texture
        elseif face == FACE.WALL then
            interiorSpawner.current_interior.walltexture = texture        
        end

        interiorSpawner:UpdateInteriorHandle(interiorSpawner.current_interior)
    end
    inst:DoTaskInTime(0,function() inst:Remove() end)
end

local function common(face, texture)
    local function fn(Sim)
        local inst = CreateEntity()

        paint(inst, face, texture)

        return inst
    end
    return fn
end

local function material(name, face, texture)
    return Prefab( name, common(face,texture), assets, prefabs)
end

return  material("interior_floor_marble", FACE.FLOOR, "levels/textures/interiors/shop_floor_marble.tex"),
        material("interior_floor_check", FACE.FLOOR, "levels/textures/interiors/shop_floor_checker.tex"),
        material("interior_floor_check2", FACE.FLOOR, "levels/textures/interiors/shop_floor_checkered.tex"),
        material("interior_floor_plaid_tile", FACE.FLOOR, "levels/textures/interiors/floor_cityhall.tex"),
        material("interior_floor_sheet_metal", FACE.FLOOR, "levels/textures/interiors/shop_floor_sheetmetal.tex"),
        material("interior_floor_wood", FACE.FLOOR, "levels/textures/noise_woodfloor.tex"),

        material("interior_wall_wood", FACE.WALL, "levels/textures/interiors/shop_wall_woodwall.tex"),
        material("interior_wall_checkered", FACE.WALL, "levels/textures/interiors/shop_wall_checkered_metal.tex"),
        material("interior_wall_floral", FACE.WALL, "levels/textures/interiors/shop_wall_floraltrim2.tex"),
        material("interior_wall_sunflower", FACE.WALL, "levels/textures/interiors/shop_wall_sunflower.tex"),        
        material("interior_wall_harlequin", FACE.WALL, "levels/textures/interiors/harlequin_panel.tex"),

--
        material("interior_floor_gardenstone", FACE.FLOOR, "levels/textures/interiors/floor_gardenstone.tex"),
        material("interior_floor_geometrictiles", FACE.FLOOR, "levels/textures/interiors/floor_geometrictiles.tex"),
        material("interior_floor_shag_carpet", FACE.FLOOR, "levels/textures/interiors/floor_shag_carpet.tex"),
        material("interior_floor_transitional", FACE.FLOOR, "levels/textures/interiors/floor_transitional.tex"),
        material("interior_floor_woodpanels", FACE.FLOOR, "levels/textures/interiors/floor_woodpanels.tex"),
        material("interior_floor_herringbone", FACE.FLOOR, "levels/textures/interiors/shop_floor_herringbone.tex"),
        material("interior_floor_hexagon", FACE.FLOOR, "levels/textures/interiors/shop_floor_hexagon.tex"),
        material("interior_floor_hoof_curvy", FACE.FLOOR, "levels/textures/interiors/shop_floor_hoof_curvy.tex"),
        material("interior_floor_octagon", FACE.FLOOR, "levels/textures/interiors/shop_floor_octagon.tex"),
        
        material("interior_wall_peagawk", FACE.WALL, "levels/textures/interiors/wall_peagawk.tex"),
        material("interior_wall_plain_ds", FACE.WALL, "levels/textures/interiors/wall_plain_DS.tex"),
        material("interior_wall_plain_rog", FACE.WALL, "levels/textures/interiors/wall_plain_RoG.tex"),
        material("interior_wall_rope", FACE.WALL, "levels/textures/interiors/wall_rope.tex"),
        material("interior_wall_circles", FACE.WALL, "levels/textures/interiors/shop_wall_circles.tex"),
        material("interior_wall_marble", FACE.WALL, "levels/textures/interiors/shop_wall_marble.tex"),
        material("interior_wall_mayorsoffice", FACE.WALL, "levels/textures/interiors/wall_mayorsoffice_whispy.tex"),
        material("interior_wall_fullwall_moulding", FACE.WALL, "levels/textures/interiors/shop_wall_fullwall_moulding.tex"),
        material("interior_wall_upholstered", FACE.WALL, "levels/textures/interiors/shop_wall_upholstered.tex")
