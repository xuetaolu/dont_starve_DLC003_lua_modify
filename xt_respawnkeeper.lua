local SHOP_CONFIG = {
    {
        tag    = 'pig_shop_academy',
        keeper = { name = "pigman_professor_shopkeep",   x_offset = -2.3, z_offset = 4,  startstate = "desk_pre" },
    },
    {
        tag    = 'pig_shop_antiquities',
        keeper = { name = "pigman_collector_shopkeep", x_offset = -3, z_offset = 4, startstate = "desk_pre" },
    },
    {
        tag    = 'pig_shop_hatshop',
        keeper = { name = "pigman_hatmaker_shopkeep",       x_offset = -3.5, z_offset = 5, startstate = "desk_pre" },
    },
    {
        tag    = 'pig_shop_weapons',
        keeper = { name = "pigman_hunter_shopkeep", x_offset = -3,    z_offset =  0, startstate = "desk_pre" },
    },
    {
        tag    = 'pig_shop_arcane',
        keeper = { name = "pigman_erudite_shopkeep", x_offset = -3,   z_offset = 4, startstate = "desk_pre" },
    },
    {
        tag    = 'pig_shop_florist',
        keeper = { name = "pigman_florist_shopkeep", x_offset = -1,   z_offset =  4,    startstate = "desk_pre" },
    },
    {
        tag    = 'pig_shop_hoofspa',
        keeper = { name = "pigman_beautician_shopkeep", x_offset = -3, z_offset = 3, startstate = "desk_pre" },
    },
    {
        tag    = 'pig_shop_general',
        keeper = { name = "pigman_banker_shopkeep", x_offset = -1, z_offset = 4, startstate = "desk_pre" },
    },
    {
        tag    = 'pig_shop_produce',
        keeper = { name = "pigman_storeowner_shopkeep", x_offset = -2.5,         z_offset = 4, startstate = "desk_pre" } ,
    },
    {
        tag    = 'pig_shop_deli',
        keeper = { name = "pigman_storeowner_shopkeep", x_offset = -1, z_offset = 4, startstate = "desk_pre" },
    },
    {
        tag    = 'pig_shop_cityhall',
        keeper = { name = "pigman_mayor_shopkeep",    x_offset = -3, z_offset = 4 },
    },
    {
        tag    = 'pig_shop_cityhall_player',
        --keeper = { name = "pigman_mayor_shopkeep",    x_offset = -3, z_offset = 4 },
    },
    {
        tag    = 'pig_shop_bank',
        keeper = { name = "pigman_banker_shopkeep",     x_offset = -2.5,         z_offset = 0, startstate = "desk_pre" }, 
    },
    {
        tag    = 'pig_shop_tinker',
        keeper = { name = "pigman_mechanic_shopkeep",     x_offset = -2,         z_offset = -3, startstate = "desk_pre" }, 
    },
}

local spawn_keeper=function( inst )
    for i,v in ipairs(SHOP_CONFIG) do
        if inst:HasTag( v.tag ) then
            if v.keeper then
                local pt = GetInteriorSpawner():getSpawnOrigin()
                local object = SpawnPrefab(v.keeper.name)
                object.Transform:SetPosition(pt.x + v.keeper.x_offset, 0, pt.z + v.keeper.z_offset) 
                local desk = FindEntity( object, 4, function( item ) return item.prefab == 'pigman_shopkeeper_desk' end )
                if desk then desk:Remove() end
                object.sg:GoToState(v.keeper.startstate)
            end
            break
        end
    end

end

local room = GetInteriorSpawner():GetCurrentInterior()
local id = room and room.unique_name
if id then
    print( 'id: ' .. id )
    for k,v in pairs( GetInteriorSpawner().doors ) do
        local partten = '[%l%u]+(' .. id .. ')_door$'
        if type(k) == 'string' and k:find( partten ) then
            -- { my_interior_name = door_definition.my_interior_name, inst = inst, target_interior = door_definition.target_interior }
            local door = v
            print( v.inst.prefab )
            local pt = GetInteriorSpawner():getSpawnOrigin()
            for k,v in pairs( TheSim:FindEntities(pt.x,pt.y,pt.z, 16, {'shop_pedestal'}) ) do
                v:RemoveTag( 'nodailyrestock' )
                v:RemoveTag( 'robbed' )
            end
            if 0 == #TheSim:FindEntities(pt.x,pt.y,pt.z, 16, {'shopkeep'}) then
                spawn_keeper( v.inst )
            end
            -- SetDebugEntity( v.inst.prefab )
        end
    end
end